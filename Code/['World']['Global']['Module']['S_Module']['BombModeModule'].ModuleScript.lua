--- @module BombMode 爆破模式服务器控制脚本,此模式下A阵营为进攻方,B阵营为防守方
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local BombMode, this = ModuleUtil.New('BombMode', ServerBase)

---点上的炸弹基类
local BombBase = class('BombBase')

function BombBase:initialize(_bombTime, _stateChangeCallback, _pointKey, _key, _parent)
    self.m_pointKey = _pointKey
    self.m_key = _key
    self.m_state = Const.BombStateEnum.NoBomb
    self.bombTime = _bombTime
    ---此炸弹剩余多长时间爆炸
    self.m_bombTimeLeft = _bombTime
    self.m_callback = _stateChangeCallback
    ---炸弹模型
    self.m_bombObj = world:CreateInstance('BombModeBomb', 'BombModeBomb', _parent)
    ---炸弹爆炸特效
    self.m_explosionEff = world:CreateInstance('BombModeExplosion', 'BombModeExplosion', _parent)
    self.m_bombObj.LocalRotation = EulerDegree(0, 0, 0)
    self.m_bombObj.LocalPosition = Vector3.Zero
    self.m_explosionEff.LocalRotation = EulerDegree(0, 0, 0)
    self.m_explosionEff.LocalPosition = Vector3.Zero

    self.m_bombObj:SetActive(false)
    self.m_explosionEff:SetActive(false)
end

function BombBase:Set()
    if self.m_state == Const.BombStateEnum.NoBomb then
        self.m_state = Const.BombStateEnum.BombFlashing
        self.m_bombTimeLeft = self.bombTime
        self.m_bombObj:SetActive(true)
        self:StateChangeCallback(Const.BombStateEnum.NoBomb, Const.BombStateEnum.BombFlashing)
    end
end

function BombBase:Remove()
    if self.m_state == Const.BombStateEnum.BombFlashing then
        self.m_state = Const.BombStateEnum.NoBomb
        self.m_bombTimeLeft = self.bombTime
        self.m_bombObj:SetActive(false)
        self:StateChangeCallback(Const.BombStateEnum.BombFlashing, Const.BombStateEnum.NoBomb)
    end
end

---炸弹爆炸调用
function BombBase:Explode()
    if self.m_state == Const.BombStateEnum.BombFlashing then
        self.m_state = Const.BombStateEnum.Exploded
        self.m_bombTimeLeft = self.bombTime
        self.m_bombObj:SetActive(false)
        self.m_explosionEff:SetActive(true)
        self:StateChangeCallback(Const.BombStateEnum.BombFlashing, Const.BombStateEnum.Exploded)
        self:Damage()
    end
end

---炸弹给予伤害
function BombBase:Damage()
    local players = BombMode:GetPlayersByRange(self.m_bombObj.Position, BombMode.explosionRange)
    local totalWeight, hitBoneWeight = 0, 0
    for k, v in pairs(BombMode.damageWeight) do
        totalWeight = totalWeight + v
    end
    for _, v in pairs(players) do
        ---表示此玩家在爆炸范围内,检查玩家和爆炸中心之间是否有阻挡
        for k1, v1 in pairs(BombMode.damageWeight) do
            local raycastAll = Physics:RaycastAll(self.m_bombObj.Position, v.Avatar[k1].Position, false)
            local isHit_ThisBone = true
            for k2, v2 in pairs(raycastAll.HitObjectAll) do
                if v2.Block and not ParentPlayer(v2) and v.CollisionGroup ~= 10 then
                    isHit_ThisBone = false
                    break
                end
            end
            if isHit_ThisBone then
                hitBoneWeight = hitBoneWeight + v1
            end
        end
        print('总权重为', totalWeight, '命中权重为', hitBoneWeight)
        local rate = 1
        if totalWeight == 0 then
            rate = 1
        else
            rate = hitBoneWeight / totalWeight
        end
        local damage = BombMode.explosionDamage * rate
        ---伤害的发起者  伤害来源的枪械  伤害的数值  伤害部位,暂时为UZI命中效果
        NetUtil.Fire_C('PlayerBeHitEvent', v, {{v, 1001, damage, HitPartEnum.Body}})
    end
end

---炸弹自身的更新函数,用于爆炸时间的更新
function BombBase:Update(_dt)
    if self.m_state == Const.BombStateEnum.BombFlashing then
        self.m_bombTimeLeft = self.m_bombTimeLeft - _dt
        if self.m_bombTimeLeft <= 0 then
            ---炸弹的倒计时结束
            self:Explode()
        end
    elseif self.m_state == Const.BombStateEnum.NoBomb then
        ---没有炸弹状态下的更新
    elseif self.m_state == Const.BombStateEnum.BombFlashing then
    ---炸弹闪烁状态下的更新
    end
end

function BombBase:StateChangeCallback(_old, _new)
    if self.m_callback then
        self.m_callback(BombMode, _old, _new, self.m_pointKey, self.m_key)
    end
end

--- 初始化
function BombMode:Init()
    ---配置读取
    self:InitConfig()
    self.m_enable = false
    self.m_playersList = {}
    self.m_bombPointsList = {}
    ---A阵营下玩家持有的炸弹列表
    self.m_teamABombsList = {}
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
function BombMode:Update(dt, tt)
    if not self.m_enable then
        return
    end
    if
        GameFlowMgr.gameFms.current ~= Const.GameStateEnum.OnGame and
            GameFlowMgr.gameFms.current ~= Const.GameStateEnum.OnReady
     then
        return
    end
    ---更新场景中的所有炸弹
    for i, v in pairs(self.m_bombPointsList) do
        for i1, v1 in pairs(v.bombs) do
            if v1.m_state then
                v1:Update(dt)
            end
        end
    end
    ---更新游戏时间
    if self.m_curTime < self.readyWaitTime and self.m_curTime + dt > self.readyWaitTime then
        ---触发准备结束事件
        self:Ready2Start()
    end
    if math.floor(self.m_curTime) ~= math.floor(self.m_curTime + dt) then
        ---广播游戏时间的变化
        NetUtil.Broadcast('GameTimeChangeEvent', math.floor(self.m_curTime))
    end
    self.m_curTime = self.m_curTime + dt
    if self.m_curTime >= self.maxTime then
        ---游戏时间结束,判定防守方胜利
        self:GameOver(Const.TeamEnum.Team_B)
    end
end

---爆破模式开始
function BombMode:ModeStart(_sceneId, _sceneObj)
    self:InitSceneConfig(_sceneId)
    self:CreateDepot()
    self:TransferPlayers()
    local pointObjList = {}
    for i, v in pairs(self.m_bombPointsList) do
        pointObjList[i] = v.obj
    end
    NetUtil.Broadcast('GameStartEvent', Const.GameModeEnum.BombMode, _sceneId, pointObjList, self.sceneObj)
end

---创建弹药库,绑定碰撞事件
function BombMode:CreateDepot()
    local obj = world:CreateInstance('ArmsDepot', 'ArmsDepot', world)
    obj.Rotation = EulerDegree(0, 0, 0)
    obj.Position = self.armsPos
    print(self.armsPos)
    obj.Range.OnCollisionBegin:Connect(
        function(_obj)
            if _obj:IsA('PlayerInstance') then
                self:PlayerEnterDepot(_obj)
            end
        end
    )
end

---碰撞到弹药库的事件
function BombMode:PlayerEnterDepot(_player)
    ---进攻方增加炸弹
    if _player.PlayerType and _player.PlayerType.Value == Const.TeamEnum.Team_A then
        if self.m_teamABombsList[_player] < self.maxBombs then
            self.m_teamABombsList[_player] = self.m_teamABombsList[_player] + 1
            NetUtil.Fire_C('NoticeEvent', _player, 1010)
            NetUtil.Fire_C('TeamABombCountChangeEvent', _player, self.m_teamABombsList[_player])
        else
            NetUtil.Fire_C('NoticeEvent', _player, 1011)
        end
    end
end

---初始化爆破模式的配置
function BombMode:InitConfig()
    self.pointRange = Config.GlobalConfig.BombMode_PointRange
    self.explosionTime = Config.GlobalConfig.BombMode_ExplosionTime
    self.explosionCount = Config.GlobalConfig.BombMode_ExplosionCount
    self.setTime = Config.GlobalConfig.BombMode_SetTime
    self.removeTime = Config.GlobalConfig.BombMode_RemoveTime
    self.maxBombs = Config.GlobalConfig.BombMode_TeamAMaxBombs
    self.explosionDamage = Config.GlobalConfig.BombMode_ExplosionDamage
    self.damageWeight = Config.GlobalConfig.BombMode_DamageWeight
    self.explosionRange = Config.GlobalConfig.BombMode_ExplosionRange
end

---初始化场景的配置
function BombMode:InitSceneConfig(_sceneId)
    self.pointsPos = Config.Scenes[_sceneId].PointsPos
    self.m_bombPointsList = {}
    for i, v in pairs(self.pointsPos) do
        local point = world:CreateInstance('BombPoint', 'BombPoint', world, v, EulerDegree(0, 0, 0))
        point.LocalRotation = EulerDegree(0, 0, 0)
        point.Range.Size = Vector3(self.pointRange, 10, self.pointRange)
        local info = {}
        info.obj = point
        info.bombs = {}
        for i1 = 1, self.explosionCount do
            ---初始化此点上的炸弹实例
            info.bombs[i1] = BombBase:new(self.explosionTime, self.BombStateChange, i, i1, point)
        end
        self.m_bombPointsList[i] = info
    end
    self.maxTime = Config.Scenes[_sceneId].MaxTime
    self.m_curTime = 0
    self.m_enable = true
    self.readyWaitTime = Config.Scenes[_sceneId].WaitTime
    self.m_readyWaitTime = self.readyWaitTime
    self.pos1_A = Config.Scenes[_sceneId].BornArea[1][1]
    self.pos2_A = Config.Scenes[_sceneId].BornArea[1][2]
    self.pos1_B = Config.Scenes[_sceneId].BornArea[2][1]
    self.pos2_B = Config.Scenes[_sceneId].BornArea[2][2]
    self.modeParams = Config.Scenes[_sceneId].ModeParams
    self.armsPos = self.modeParams.ArmsPos
end

---游戏准备阶段到正式开始阶段
function BombMode:Ready2Start()
    GameFlowMgr:Ready2Start()
end

---将玩家传送到自己所在的阵营的出生区域
function BombMode:TransferPlayers()
    for i, v in pairs(self.m_playersList) do
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
end

---玩家加入游戏
function BombMode:PlayerAdd(_player)
    table.insert(self.m_playersList, _player)
    self.m_teamABombsList[_player] = 1
    _player.OnDead:Connect(
        function()
            self:PlayerDead(_player)
        end
    )
end

function BombMode:OnPlayerLeaveEventHandler(_player)
    table.removebyvalue(self.m_playersList, _player)
    self.m_teamABombsList[_player] = nil
end

---玩家死亡,炸弹清空
function BombMode:PlayerDead(_player)
    if self.m_teamABombsList[_player] then
        self.m_teamABombsList[_player] = 0
        NetUtil.Fire_C('TeamABombCountChangeEvent', _player, 0)
    end
end

---玩家尝试放置炸弹,只有阵营A玩家才可
---@param _player PlayerInstance 尝试放置炸弹的玩家
---@param _pointKey string 尝试放置的点的索引
function BombMode:PlayerTrySetBombEventHandler(_player, _pointKey)
    if _player.PlayerType.Value ~= Const.TeamEnum.Team_A then
        NetUtil.Fire_C('NoticeEvent', _player, 1004)
        return
    end
    local pointInfo = self.m_bombPointsList[_pointKey]
    if not pointInfo then
        return
    end
    local bombsInfo = pointInfo.bombs
    local targetKey
    for i, v in pairs(bombsInfo) do
        if v.m_state == Const.BombStateEnum.NoBomb then
            targetKey = i
            break
        end
    end
    local flashingKey
    for i, v in pairs(bombsInfo) do
        if v.m_state == Const.BombStateEnum.BombFlashing then
            flashingKey = i
            break
        end
    end
    if self.m_teamABombsList[_player] <= 0 then
        ---这个玩家身上已经没有炸弹了
        NetUtil.Fire_C('NoticeEvent', _player, 1012)
        return
    end
    if not targetKey then
        ---此点已经没有可以放置炸弹的位置
        NetUtil.Fire_C('NoticeEvent', _player, 1006)
        return
    end
    if flashingKey then
        ---此点已经有炸弹在倒计时
        NetUtil.Fire_C('NoticeEvent', _player, 1009)
        return
    end
    ---将此点对应索引的炸弹设置为闪烁状态
    bombsInfo[targetKey]:Set()
    ---给这个玩家加分
    ScoreMgr:AddScore(_player, ScoreMgr.setTNT)
    self.m_teamABombsList[_player] = self.m_teamABombsList[_player] - 1
    NetUtil.Fire_C('TeamABombCountChangeEvent', _player, self.m_teamABombsList[_player])
end

---玩家尝试拆除炸弹,只有阵营B玩家才可
---@param _player PlayerInstance 尝试拆除炸弹的玩家
---@param _pointKey string 尝试拆除的点的索引
function BombMode:PlayerTryRemoveBombEventHandler(_player, _pointKey)
    if _player.PlayerType.Value ~= Const.TeamEnum.Team_B then
        NetUtil.Fire_C('NoticeEvent', _player, 1005)
        return
    end
    local pointInfo = self.m_bombPointsList[_pointKey]
    print(pointInfo)
    if not pointInfo then
        return
    end
    local bombsInfo = pointInfo.bombs
    local targetKey
    for i, v in pairs(bombsInfo) do
        if v.m_state == Const.BombStateEnum.BombFlashing then
            targetKey = i
            break
        end
    end
    if not targetKey then
        ---此点已经没有可以拆除的炸弹
        NetUtil.Fire_C('NoticeEvent', _player, 1007)
        return
    end
    ---将此点对应索引的炸弹设置未放置状态
    bombsInfo[targetKey]:Remove()
    ---给这个玩家加分
    ScoreMgr:AddScore(_player, ScoreMgr.removeTNT)
end

---一个炸弹状态更改后
---@param _oldState number 之前的状态
---@param _newState number 新的状态
---@param _pointKey string 此炸弹所属的点的索引
---@param _key number 炸弹的自身索引
function BombMode:BombStateChange(_oldState, _newState, _pointKey, _key)
    if not self.m_enable then
        return
    end
    NetUtil.Broadcast('BombStateChangeEvent', _oldState, _newState, _pointKey, _key)
    ---若状态更改为已爆炸,检测当前是否全部炸弹都爆炸了
    if _newState == Const.BombStateEnum.Exploded then
        local allExploded = true
        for i, v in pairs(self.m_bombPointsList) do
            for i1, v1 in pairs(v.bombs) do
                if v1.m_state ~= Const.BombStateEnum.Exploded then
                    allExploded = false
                end
            end
        end
        if allExploded then
            self:GameOver(Const.TeamEnum.Team_A)
        end
    end
end

---爆破模式数据重置
function BombMode:Reset()
    for i, v in pairs(self.m_bombPointsList) do
        if not v.obj:IsNull() then
            v.obj:Destroy()
        end
    end
    self.m_bombPointsList = {}
    self.m_enable = false
    self.m_curTime = 0
    self.m_readyWaitTime = self.readyWaitTime
end

function BombMode:GameOver(_win)
    self.m_enable = false
    local info = {}
    info.WinTeam = _win
    GameFlowMgr:GameOver(info)
end

---获取指定范围的所有玩家
---@param _origin Vector3
function BombMode:GetPlayersByRange(_origin, _range)
    local res = {}
    for i, v in pairs(FindAllPlayers()) do
        if (v.Position - _origin).Magnitude < _range then
            table.insert(res, v)
        end
    end
    return res
end

return BombMode
