--- @module DeathmatchMode 死斗模式数据管理模块
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local DeathmatchMode, this = ModuleUtil.New('DeathmatchMode', ServerBase)

--- 初始化
function DeathmatchMode:Init()
    ---玩家列表,包含了NPC
    self.playerList = {}
    ---场景对象
    self.sceneObj = nil
    ---场景ID
    self.sceneId = nil
    self.curTime = 0
    self.enable = false
    ---双方击杀数
    self.teamKillNum = {}
    self.teamKillNum[Const.TeamEnum.Team_A] = 0
    self.teamKillNum[Const.TeamEnum.Team_B] = 0
    ---双方玩家的连杀数
    self.continuousKillNum = {}
    self.pos1_A, self.pos2_A, self.pos1_B, self.pos2_B = Vector3.Zero, Vector3.Zero, Vector3.Zero, Vector3.Zero

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
end

--- Update函数
--- @param dt number delta time 每帧时间
function DeathmatchMode:Update(dt, tt)
    if not self.enable then
        return
    end
    if
        GameFlowMgr.gameFms.current ~= Const.GameStateEnum.OnGame and
            GameFlowMgr.gameFms.current ~= Const.GameStateEnum.OnReady
     then
        return
    end
    ---更新游戏时间
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
        if self.teamKillNum[Const.TeamEnum.Team_A] > self.teamKillNum[Const.TeamEnum.Team_B] then
            self:GameOver(Const.TeamEnum.Team_A)
        else
            self:GameOver(Const.TeamEnum.Team_B)
        end
    end
end

---模式开始
---@param _sceneId number 场景ID
---@param _sceneObj Object 场景对象
function DeathmatchMode:ModeStart(_sceneId, _sceneObj)
    self.sceneId = _sceneId
    self.sceneObj = _sceneObj
    self.maxTime = Config.Scenes[_sceneId].MaxTime
    self.readyWaitTime = Config.Scenes[_sceneId].WaitTime
    self.modeParams = Config.Scenes[_sceneId].ModeParams
    self.maxKillNum = self.modeParams.MaxKillNum
    self.killAdd = self.modeParams.KillAdd
    self.enable = true
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
    NetUtil.Broadcast('GameStartEvent', Const.GameModeEnum.DeathmatchMode, _sceneId, nil, self.sceneObj)
end

---重置模式中的数据
function DeathmatchMode:Reset()
    print('重置模式中的数据')
    self.teamKillNum[Const.TeamEnum.Team_A] = 0
    self.teamKillNum[Const.TeamEnum.Team_B] = 0
    self.curTime = 0
    for i, v in pairs(self.continuousKillNum) do
        self.continuousKillNum[i] = 0
    end
end

---模式中,游戏结束后主动调用
---@param _team number 胜利的一方
function DeathmatchMode:GameOver(_team)
    self.enable = false
    local info = {}
    info.WinTeam = _team
    GameFlowMgr:GameOver(info)
end

---开战前的准备阶段结束后调用
function DeathmatchMode:Ready2Start()
end

---玩家加入游戏
function DeathmatchMode:PlayerAdd(_player)
    table.insert(self.playerList, _player)
    self.continuousKillNum[_player] = 0
end

---玩家离开游戏
function DeathmatchMode:OnPlayerLeaveEventHandler(_player)
    table.removebyvalue(self.playerList, _player)
    self.continuousKillNum[_player] = nil
end

---NPC创建成功事件
function DeathmatchMode:NpcCreateEventHandler(_npc)
    table.insert(self.playerList, _npc)
    self.continuousKillNum[_npc] = 0
end

---NPC销毁事件
function DeathmatchMode:NpcDestroyEventHandler(_npc)
    table.removebyvalue(self.playerList, _npc)
    self.continuousKillNum[_npc] = nil
end

---@param _killer PlayerInstance 击杀者
---@param _killed PlayerInstance 被杀的人
---@param _weaponId number 伤害来源的枪械ID
---@param _hitPart number 击杀部位
function DeathmatchMode:PlayerDieEventHandler(_killer, _killed, _weaponId, _hitPart)
    if not self.enable then
        print('玩法未启用')
        return
    end
    if _killer == _killed then
        ---击杀者和死亡者一样,不做玩法上的处理
        print('击杀者和死亡者一样,不做玩法上的处理')
        return
    end
    ---重置死亡者的连杀数量
    self.continuousKillNum[_killed] = 0

    local team = _killer.PlayerType.Value
    local curKillNum = self.continuousKillNum[_killer]
    curKillNum = curKillNum and curKillNum + 1 or 1
    self.continuousKillNum[_killer] = curKillNum
    local addKillNum = self.killAdd[curKillNum] or self.killAdd[#self.killAdd]
    self.teamKillNum[team] = self.teamKillNum[team] + addKillNum
    NetUtil.Broadcast('TeamKillNumChangeEvent', team, self.teamKillNum[team])
    if self.teamKillNum[team] >= self.maxKillNum then
        ---此方胜利
        self:GameOver(team)
    end
end

return DeathmatchMode
