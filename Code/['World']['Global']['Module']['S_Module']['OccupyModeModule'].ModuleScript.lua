--- @module OccupyMode 占点玩法控制模块
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local OccupyMode, this = ModuleUtil.New('OccupyMode', ServerBase)

local progressStart, progressEnd = 0, 4

--- 初始化
function OccupyMode:Init()
    ---占点数据管理表
    self.holdPointsList = {}
    self.range = Config.GlobalConfig.Stronghold_PointRange
    self.speed = Config.GlobalConfig.Stronghold_SpeedPer
    self.speedUp = Config.GlobalConfig.Stronghold_SpeedUp
    self.maxSpeed = Config.GlobalConfig.Stronghold_SpeedMax
    self.pointGrade = Config.GlobalConfig.Stronghold_PointGrade
    self.playerList = {}
    self.teamATotalGrade = 0
    self.teamBTotalGrade = 0
    ---上一帧游戏中的玩家和所有据点的距离
    self.prePlayerDisList = {}

    world.OnPlayerAdded:Connect(
        function(_player)
            self:PlayerAdd(_player)
        end
    )
    world.OnPlayerRemoved:Connect(
        function(_player)
            --self:PlayerRemove(_player)
        end
    )
    self.enable = false
    self.maxGrade = 0
    self.curTime = 0
    self.maxTime = 0
    self.readyWaitTime = 0
    self.teamAGradeAddWait = tonumber(self.pointGrade[1])
    self.teamBGradeAddWait = tonumber(self.pointGrade[1])
    self.teamGradeAdd = tonumber(self.pointGrade[2])
    self.pos1_A, self.pos2_A, self.pos1_B, self.pos2_B = Vector3.Zero, Vector3.Zero, Vector3.Zero, Vector3.Zero
    print('占点玩法初始化完成')
end

---占点玩法开始
---@param _sceneId number 场景的ID
function OccupyMode:ModeStart(_sceneId, _sceneObj)
    self.sceneObj = _sceneObj
    self.sceneObj.Team_B_Boundary.Door:SetActive(true)
    self.sceneObj.Team_A_Boundary.Door:SetActive(true)
    local pointsPos = Config.Scenes[_sceneId].PointsPos
    for i, v in pairs(pointsPos) do
        local point = world:CreateInstance('HoldPoint', 'HoldPoint', world, v, EulerDegree(0, 0, 0))
        local info = {}
        info.obj = point
        info.players = {}
        info.players[Const.TeamEnum.Team_A] = {}
        info.players[Const.TeamEnum.Team_B] = {}
        info.teamValue = {}
        info.teamValue[Const.TeamEnum.Team_A] = 0
        info.teamValue[Const.TeamEnum.Team_B] = 0
        self.holdPointsList[i] = info
        point.LocalRotation = EulerDegree(0, 0, 0)
        point.Flag.SurfaceGUI.Text.Text = i
    end
    self.teamAGradeAddWait = tonumber(self.pointGrade[1])
    self.teamBGradeAddWait = tonumber(self.pointGrade[1])
    self.teamGradeAdd = tonumber(self.pointGrade[2])
    self.prePlayerDisList = {}
    self.teamATotalGrade = 0
    self.teamBTotalGrade = 0
    self.curTime = 0
    self.enable = true
    self.modeParams = Config.Scenes[_sceneId].ModeParams
    self.maxGrade = self.modeParams.MaxGrade
    self.maxTime = Config.Scenes[_sceneId].MaxTime
    self.readyWaitTime = Config.Scenes[_sceneId].WaitTime
    ---将玩家传送到指定的位置
    self.pos1_A = Config.Scenes[_sceneId].BornArea[1][1]
    self.pos2_A = Config.Scenes[_sceneId].BornArea[1][2]
    self.pos1_B = Config.Scenes[_sceneId].BornArea[2][1]
    self.pos2_B = Config.Scenes[_sceneId].BornArea[2][2]
    for i, v in pairs(self.playerList) do
        local x, y, z
        if v.PlayerType.Value == Const.TeamEnum.Team_A then
            x = Random_X2Y(self.pos1_A.X, self.pos2_A.X)
            z = Random_X2Y(self.pos1_A.Z, self.pos2_A.Z)
            y = self.pos1_A.Y
        else
            x = Random_X2Y(self.pos1_B.X, self.pos2_B.X)
            z = Random_X2Y(self.pos1_B.Z, self.pos2_B.Z)
            y = self.pos1_B.Y
        end
        NetUtil.Fire_C('TransferEvent', v, Vector3(x, y, z))
    end
    local pointObjList = {}
    for i, v in pairs(self.holdPointsList) do
        pointObjList[i] = v.obj
    end
    NetUtil.Broadcast('GameStartEvent', Const.GameModeEnum.OccupyMode, _sceneId, pointObjList, self.sceneObj)
end

--- Update函数
--- @param dt number delta time 每帧时间
function OccupyMode:Update(dt, tt)
    if not self.enable then
        return
    end
    if
        GameFlowMgr.gameFms.current ~= Const.GameStateEnum.OnGame and
            GameFlowMgr.gameFms.current ~= Const.GameStateEnum.OnReady
     then
        return
    end
    ---更新玩家的距离以触发事件
    for i, v in pairs(self.playerList) do
        self.prePlayerDisList[v] = self.prePlayerDisList[v] or {}
        for i1, v1 in pairs(self.holdPointsList) do
            local obj = v1.obj
            local dis = (v.Position - obj.Position).Magnitude
            self.prePlayerDisList[v][i1] = self.prePlayerDisList[v][i1] or 99999999
            if dis < self.range and self.prePlayerDisList[v][i1] > self.range then
                ---这一帧进入这个点
                self:PlayerEnterPoint(v, i1)
            elseif dis > self.range and self.prePlayerDisList[v][i1] < self.range then
                ---这一帧离开这个点
                self:PlayerLeavePoint(v, i1)
            end
            self.prePlayerDisList[v][i1] = dis
        end
    end
    ---更新每个点的占点比例
    for i, v in pairs(self.holdPointsList) do
        local teamAPlayers = v.players[Const.TeamEnum.Team_A]
        local teamBPlayers = v.players[Const.TeamEnum.Team_B]
        local teamAValue = v.teamValue[Const.TeamEnum.Team_A]
        local teamBValue = v.teamValue[Const.TeamEnum.Team_B]
        local teamANUm = #teamAPlayers
        local teamBNUm = #teamBPlayers
        if teamANUm > 0 and teamBNUm == 0 then
            ---此点A阵营占点中
            if teamBValue == 0 then
                ---当前B阵营没有积分了,直接开始给A阵营加分
                v.teamValue[Const.TeamEnum.Team_A] = teamAValue + self:GetSpeedByNum(teamANUm) * dt
                if teamAValue < 100 and v.teamValue[Const.TeamEnum.Team_A] >= 100 then
                    ---此点A占下了
                    NetUtil.Broadcast('PointBeOccupiedEvent', i, Const.TeamEnum.Team_A)
                end
            else
                ---当前B阵营还有积分,需要减少B阵营积分
                v.teamValue[Const.TeamEnum.Team_B] = teamBValue - self:GetSpeedByNum(teamANUm) * dt
            end
            v.teamValue[Const.TeamEnum.Team_A] =
                v.teamValue[Const.TeamEnum.Team_A] >= 100 and 100 or v.teamValue[Const.TeamEnum.Team_A]
            v.teamValue[Const.TeamEnum.Team_B] =
                v.teamValue[Const.TeamEnum.Team_B] <= 0 and 0 or v.teamValue[Const.TeamEnum.Team_B]
        elseif teamBNUm > 0 and teamANUm == 0 then
            ---此点B阵营占点中
            if teamAValue == 0 then
                ---当前A阵营没有积分了.直接开始给B阵营加分
                v.teamValue[Const.TeamEnum.Team_B] = teamBValue + self:GetSpeedByNum(teamBNUm) * dt
                if teamBValue < 100 and v.teamValue[Const.TeamEnum.Team_B] >= 100 then
                    ---此点B占下了
                    NetUtil.Broadcast('PointBeOccupiedEvent', i, Const.TeamEnum.Team_B)
                end
            else
                ---当前A阵营还有积分,需要减少A阵营积分
                v.teamValue[Const.TeamEnum.Team_A] = teamAValue - self:GetSpeedByNum(teamBNUm) * dt
            end
            v.teamValue[Const.TeamEnum.Team_B] =
                v.teamValue[Const.TeamEnum.Team_B] >= 100 and 100 or v.teamValue[Const.TeamEnum.Team_B]
            v.teamValue[Const.TeamEnum.Team_A] =
                v.teamValue[Const.TeamEnum.Team_A] <= 0 and 0 or v.teamValue[Const.TeamEnum.Team_A]
        end
        v.obj.Flag.Progress.ProgressTeamA.LocalPosition =
            Vector3(0, progressStart + (progressEnd - progressStart) * v.teamValue[Const.TeamEnum.Team_A] * 0.01, 0)
        v.obj.Flag.Progress.ProgressTeamB.LocalPosition =
            Vector3(0, progressStart + (progressEnd - progressStart) * v.teamValue[Const.TeamEnum.Team_B] * 0.01, 0)
    end
    ---更新每个点的积分产出
    for i, v in pairs(self.holdPointsList) do
        if v.teamValue[Const.TeamEnum.Team_A] >= 100 then
            ---这个点由A阵营占领
            self.teamAGradeAddWait = self.teamAGradeAddWait - dt
            if self.teamAGradeAddWait <= 0 then
                self.teamAGradeAddWait = tonumber(self.pointGrade[1])
                ---给A阵营加分
                self.teamATotalGrade = self.teamATotalGrade + self.teamGradeAdd
                NetUtil.Broadcast('GradeChangeEvent', Const.TeamEnum.Team_A, self.teamATotalGrade)
            end
        elseif v.teamValue[Const.TeamEnum.Team_B] >= 100 then
            ---这个点由B阵营占领
            self.teamBGradeAddWait = self.teamBGradeAddWait - dt
            if self.teamBGradeAddWait <= 0 then
                self.teamBGradeAddWait = tonumber(self.pointGrade[1])
                ---给B阵营加分
                self.teamBTotalGrade = self.teamBTotalGrade + self.teamGradeAdd
                NetUtil.Broadcast('GradeChangeEvent', Const.TeamEnum.Team_B, self.teamBTotalGrade)
            end
        end
    end
    self.teamATotalGrade = self.teamATotalGrade >= self.maxGrade and self.maxGrade or self.teamATotalGrade
    self.teamBTotalGrade = self.teamBTotalGrade >= self.maxGrade and self.maxGrade or self.teamBTotalGrade
    ---更新游戏时间
    if self.teamATotalGrade == self.maxGrade then
        self:GameOver(Const.TeamEnum.Team_A)
    elseif self.teamBTotalGrade == self.maxGrade then
        self:GameOver(Const.TeamEnum.Team_B)
    end
    if self.curTime < self.readyWaitTime and self.curTime + dt >= self.readyWaitTime then
        ---触发准备结束事件
        self:Ready2Start()
    end
    if math.floor(self.curTime) ~= math.floor(self.curTime + dt) then
        ---广播游戏时间的变化
        NetUtil.Broadcast('GameTimeChangeEvent', math.floor(self.curTime))
    end
    self.curTime = self.curTime + dt
    if self.curTime >= self.maxTime then
        if self.teamBTotalGrade > self.teamATotalGrade then
            self:GameOver(Const.TeamEnum.Team_B)
        else
            self:GameOver(Const.TeamEnum.Team_A)
        end
    end
end

---占点模式的数据重置
function OccupyMode:Reset()
    print('占点模式的数据重置')
    for i, v in pairs(self.holdPointsList) do
        if not v.obj:IsNull() then
            v.obj:Destroy()
        end
    end
    self.holdPointsList = {}
end

function OccupyMode:GameOver(_win)
    self.enable = false
    local info = {}
    info.WinTeam = _win
    GameFlowMgr:GameOver(info)
end

---开战前的准备时间结束
function OccupyMode:Ready2Start()
    print('将阻挡去掉')
    self.sceneObj.Team_B_Boundary.Door:SetActive(false)
    self.sceneObj.Team_A_Boundary.Door:SetActive(false)
end

---玩家进入据点
function OccupyMode:PlayerEnterPoint(_player, _pointKey)
    print('玩家进入据点', _player, _pointKey)
    local playerType = _player.PlayerType.Value
    local pointInfo = self.holdPointsList[_pointKey]
    if not pointInfo.players[playerType] then
        return
    end
    table.insert(pointInfo.players[playerType], _player)
    table.unique(pointInfo.players[playerType])
end

---玩家离开据点
function OccupyMode:PlayerLeavePoint(_player, _pointKey)
    print('玩家离开据点', _player, _pointKey)
    local playerType = _player.PlayerType.Value
    local pointInfo = self.holdPointsList[_pointKey]
    if not pointInfo.players[playerType] then
        return
    end
    table.removebyvalue(pointInfo.players[playerType], _player)
    table.unique(pointInfo.players[playerType])
end

---玩家加入游戏
function OccupyMode:PlayerAdd(_player)
    table.insert(self.playerList, _player)
end

---玩家离开游戏
function OccupyMode:OnPlayerLeaveEventHandler(_player)
    table.removebyvalue(self.playerList, _player)
end

---NPC创建成功事件
function OccupyMode:NpcCreateEventHandler(_npc)
    table.insert(self.playerList, _npc)
end

---NPC销毁事件
function OccupyMode:NpcDestroyEventHandler(_npc)
    table.removebyvalue(self.playerList, _npc)
end

---根据点中人数获取当前占点的速度
function OccupyMode:GetSpeedByNum(_num)
    if _num <= 0 then
        return 0
    end
    local res = self.speed
    res = (_num - 1) * self.speedUp + res
    if res >= 50 then
        res = 50
    end
    return res
end

---检查玩家是否在一个据点的范围内
---@param _player PlayerInstance
---@return string, number, number 在的点的key,A阵营的进度,B阵营的进度
function OccupyMode:CheckPlayerInOccPoint(_player)
    local key
    for i, v in pairs(self.holdPointsList) do
        if (_player.Position - v.obj.Position).Magnitude < self.range then
            key = i
            break
        end
    end
    if not key then
        return
    end
    local info = self.holdPointsList[key]
    local teamA = info.teamValue[Const.TeamEnum.Team_A]
    local teamB = info.teamValue[Const.TeamEnum.Team_B]
    return key, teamA, teamB
end

return OccupyMode
