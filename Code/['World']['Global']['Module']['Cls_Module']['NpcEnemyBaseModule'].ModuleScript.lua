--- @module NpcEnemyBase AI敌人模块
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local NpcEnemyBase = class('NpcEnemyBase')

---npc的配置的索引,保证生成的Npc配置不同
NpcEnemyBase.npcIndex = 0

---范围检测的Y值极限
local RANGE_HIGH = 10
---NPC寻路时长阈值
local MOVE_MAX_TIME = 10

---@param _self NpcEnemyBase
local function RandomCreateCloth(_self)
    --生成个16随机数对应16个服装部位
    local numGender = math.random(1, 2)
    local numClothes = math.random(1, 47)
    local numTrousers = math.random(1, 37)
    local numHair = math.random(1, 7)
    local numHands = math.random(1, 16)
    local numShoes = math.random(1, 38)
    local numFace = math.random(1, 10)
    local numSkinColor = math.random(1, 8)
    local numHeadAccessory = math.random(1, 39)
    local numLegAccessory = math.random(1, 8)
    local numHandsAccessory = math.random(1, 5)
    local numBodyAccessory = math.random(1, 16)
    local numWaistAccessory = math.random(1, 7)
    local numNeckAccessory = math.random(1, 5)
    local numFaceAccessory = math.random(1, 4)

    --根据性别换装
    if numGender == 1 then
        --性别
        _self.cloths.Gender = numGender
        --衣服
        _self.cloths.Clothes = Config.Clothes_Male['Clothes'][numClothes].Des
        --裤子
        _self.cloths.Trousers = Config.Clothes_Male['Trousers'][numTrousers].Des
        --头发
        _self.cloths.Hair = Config.Clothes_Male['Hair'][numHair].Des
        --手
        _self.cloths.Hands = Config.Clothes_Male['Hands'][numHands].Des
        --鞋子
        _self.cloths.Shoes = Config.Clothes_Male['Shoes'][numShoes].Des
        --面部
        _self.cloths.Face = Config.Clothes_Male['Face'][numFace].Des
        --皮肤颜色
        _self.cloths.SkinColor = Config.Clothes_Male['SkinColor'][numSkinColor].Des
        --头部装饰
        _self.cloths.HeadAccessory = Config.Clothes_Male['HeadAccessory'][numHeadAccessory].Des
        --腿部装饰
        _self.cloths.LegsAccessory = Config.Clothes_Male['LegAccessory'][numLegAccessory].Des
        --手部装饰
        _self.cloths.HandsAccessory = Config.Clothes_Male['HandsAccessory'][numHandsAccessory].Des
        --身体装饰
        _self.cloths.BodyAccessory = Config.Clothes_Male['BodyAccessory'][numBodyAccessory].Des
        --腰部装饰
        _self.cloths.WaistAccessory = Config.Clothes_Male['WaistAccessory'][numWaistAccessory].Des
        --脖子装饰
        _self.cloths.NeckAccessory = Config.Clothes_Male['NeckAccessory'][numNeckAccessory].Des
        --面部装饰
        _self.cloths.FaceAccessory = Config.Clothes_Male['FaceAccessory'][numFaceAccessory].Des
    else
        -- 女
        _self.cloths.Gender = numGender
        _self.cloths.Clothes = Config.Clothes_Female['Clothes'][numClothes].Des
        _self.cloths.Trousers = Config.Clothes_Female['Trousers'][numTrousers].Des
        _self.cloths.Hair = Config.Clothes_Female['Hair'][numHair].Des
        _self.cloths.Hands = Config.Clothes_Female['Hands'][numHands].Des
        _self.cloths.Shoes = Config.Clothes_Female['Shoes'][numShoes].Des
        _self.cloths.Face = Config.Clothes_Female['Face'][numFace].Des
        _self.cloths.SkinColor = Config.Clothes_Female['SkinColor'][numSkinColor].Des
        _self.cloths.HeadAccessory = Config.Clothes_Female['HeadAccessory'][numHeadAccessory].Des
        _self.cloths.LegsAccessory = Config.Clothes_Female['LegAccessory'][numLegAccessory].Des
        _self.cloths.HandsAccessory = Config.Clothes_Female['HandsAccessory'][numHandsAccessory].Des
        _self.cloths.BodyAccessory = Config.Clothes_Female['BodyAccessory'][numBodyAccessory].Des
        _self.cloths.WaistAccessory = Config.Clothes_Female['WaistAccessory'][numWaistAccessory].Des
        _self.cloths.NeckAccessory = Config.Clothes_Female['NeckAccessory'][numNeckAccessory].Des
        _self.cloths.FaceAccessory = Config.Clothes_Female['FaceAccessory'][numFaceAccessory].Des
    end
end

---@param _self NpcEnemyBase
local function ChangeCloth(_self)
    _self.model.Avatar.Gender = _self.cloths.Gender
    _self.model.Avatar.Clothes = _self.cloths.Clothes
    _self.model.Avatar.Trousers = _self.cloths.Trousers
    _self.model.Avatar.Hair = _self.cloths.Hair
    _self.model.Avatar.Hands = _self.cloths.Hands
    _self.model.Avatar.Shoes = _self.cloths.Shoes
    _self.model.Avatar.Face = _self.cloths.Face
    _self.model.Avatar.SkinColor = _self.cloths.SkinColor
    _self.model.Avatar.HeadAccessory = _self.cloths.HeadAccessory
    _self.model.Avatar.LegsAccessory = _self.cloths.LegsAccessory
    _self.model.Avatar.HandsAccessory = _self.cloths.HandsAccessory
    _self.model.Avatar.BodyAccessory = _self.cloths.BodyAccessory
    _self.model.Avatar.WaistAccessory = _self.cloths.WaistAccessory
    _self.model.Avatar.NeckAccessory = _self.cloths.NeckAccessory
    _self.model.Avatar.FaceAccessory = _self.cloths.FaceAccessory
end

---选择表中下一个预设
local function RandomInfo()
    NpcEnemyBase.npcIndex = NpcEnemyBase.npcIndex + 1
    local config = Config.NpcEnemy[NpcEnemyBase.npcIndex]
    if not config then
        NpcEnemyBase.npcIndex = 1
    end
    config = Config.NpcEnemy[NpcEnemyBase.npcIndex]
    return config
end

---npc接受的事件
local eventList = {
    'PlayerBeHitEvent',
    'PlayerScoreAddEvent'
}

---创建NPC接受的事件对象
---@param _self NpcEnemyBase
local function CreateEvent(_self)
    for i, v in pairs(eventList) do
        world:CreateObject('CustomEvent', v, _self.eventFolder)
    end
end

---和出生区域的距离检测
---@param _pos1 Vector3 位置点1
---@param _pos2 Vector3 位置点2
---@param _selfPos Vector3 待检测的点
local function CheckRange(_pos1, _pos2, _selfPos)
    local y = _pos1.Y + _pos2.Y
    y = y * 0.5
    if math.abs(y - _selfPos.Y) > RANGE_HIGH then
        return false
    end
    local x1, x2 = _pos1.X, _pos2.X
    local z1, z2 = _pos1.Z, _pos2.Z
    local x, z = _selfPos.X, _selfPos.Z
    if x >= x1 and x <= x2 or x >= x2 and x <= x1 then
        if z >= z1 and z <= z2 or z >= z2 and z <= z1 then
            return true
        end
    end
    return false
end

--- 初始化
function NpcEnemyBase:initialize(_team, _bornArea, _parent, _sceneId)
    self.config = RandomInfo()
    self.cloths = {}
    self.uuid = UUID()
    self.isUpdating = false
    self.bornPos1 = _bornArea[1]
    self.bornPos2 = _bornArea[2]
    self.team = _team
    self.sceneId = _sceneId
    self.gameMode = Config.Scenes[_sceneId].ModeType
    self.staticTarget = table.readRandomValueInTable(Config.Scenes[_sceneId].ModeParams.NPCTarget)
    self.occupationConfig = Config.Occupation[self.config.Occupation]
    self.damageRate = self.config.DamageRate
    self.shootSpeedRate = self.config.ShootSpeedRate
    self.gunId = self.occupationConfig.Weapon_1
    self.walkSpeed = GunCsv.GunConfig.GlobalConfig.RunSpeed
    self.updateDelay = self.config.UpdateDelay
    self.maxHp = self.occupationConfig.MaxHp
    self.pursuitDis = self.config.PursuitDis
    self.attackDis = self.config.AttackDis
    self.updateFrequency = self.config.UpdateFrequency
    ---NPC的行为树
    self.behaviourTree = NpcBehavior:CreateBT(self.gameMode)
    self.blackBoard = B3.Blackboard.new()
    ---双方死亡复活时间,1为A阵营,2为B阵营
    self.reviveWaitTime = Config.Scenes[_sceneId].ReviveWaitTime

    ---@type PlayerInstance
    self.model = world:CreateInstance('NpcEnemy', self.config.Name, _parent)
    self.model.CollisionGroup = 2
    self.model.Avatar:SetBlendSubtree(Enum.BodyPart.FullBody, 3)
    ---NPC自身的爆头判定区域和身体判定区域初始化
    self.headPoint = world:CreateInstance('HeadPoint', 'HeadPoint', self.model.Avatar.Bone_Head)
    self.bodyPoint = world:CreateInstance('BodyPoint', 'BodyPoint', self.model.Avatar.Bone_Pelvis)
    self.limbPoint = world:CreateInstance('LimbPoint', 'LimbPoint', self.model.Avatar.Bone_Pelvis)
    self.headPoint.LocalPosition = Vector3(-0.229, 0.032, 0)
    self.bodyPoint.LocalPosition = Vector3(-0.1684, 0, 0)
    self.limbPoint.LocalPosition = Vector3(0.391, 0, 0)

    self.teamValueNode = world:CreateObject('IntValueObject', 'PlayerType', self.model)
    self.uuidValueNode = world:CreateObject('StringValueObject', 'UUID', self.model)
    self.eventFolder = world:CreateObject('FolderObject', 'C_Event', self.model)
    self.playerStateValueNode = world:CreateObject('IntValueObject', 'PlayerState', self.model)
    self.actionStateValueNode = world:CreateObject('IntValueObject', 'ActionState', self.model)
    self.invincibleCover = world:CreateInstance('InvincibleCover', 'InvincibleCover', self.model)
    self.isNpcNode = world:CreateObject('NodeObject', 'IsNpc', self.model)

    self.invincibleCover.LocalPosition = Vector3.Up * 0.8
    self.teamValueNode.Value = _team
    self.uuidValueNode.Value = self.uuid
    self.actionStateValueNode.Value = PlayerActionModeEnum.Run
    self.playerStateValueNode.Value = Const.PlayerStateEnum.OnGame

    ---@type NpcGunBase
    self.m_gunIns = NpcGunBase:new(self)
    ---@type PlayerInstance 这个机器人当前的目标玩家,用来进行攻击和追击逻辑
    self.m_targetPlayer = nil
    ---@type Vector3 当前的目标点(占点模式中的据点坐标,最近的敌人坐标,爆破模式中的据点坐标)
    self.m_targetPoint = nil
    ---@type Vector3 上一帧的目标点,用来判断是否要更新当前的寻路路径
    self.m_preTargetPoint = nil
    self.m_deathNum = 0
    self.m_updateLeftTime = 1 / self.updateFrequency
    ---NPC当前的寻路路径坐标列表
    self.m_wayPointsList = {}
    ---NPC剩余的寻路路径坐标
    self.m_wayPointsLeftList = {}
    ---当前角色是否无敌
    self.m_invincible = false
    ---当期是否在出生区域内
    self.m_inBornArea = true
    ---当前寻路时间倒计时
    self.m_moveTimeLeft = MOVE_MAX_TIME

    RandomCreateCloth(self)
    CreateEvent(self)
    ---{ { v, 1001, damage, HitPartEnum.Body } }
    self.model.C_Event.PlayerBeHitEvent:Connect(
        function(_msg)
            for i, v in pairs(_msg) do
                local origin = v[1]
                local weaponId = v[2]
                local damage = v[3]
                local hitPart = v[4]
                self:BeAttack(origin, damage, weaponId, hitPart)
            end
        end
    )
    ---给NPC死亡动画添加事件
    self.deadAniEvent = self.model.Avatar:AddAnimationEvent('Dead', 1)
    self.deadAniEvent:Connect(
        function()
            if self.model then
                self.model.Avatar:PlayAnimation('DeadKeep', 3, 1, 0, true, true, 1)
            end
        end
    )

    --print('出生区域', self.bornPos1, self.bornPos2, self.model)
end

--- Update函数
--- @param dt number delta time 每帧时间
function NpcEnemyBase:Update(dt, tt)
    if not self.isUpdating then
        return
    end
    ---NPC的行为树更新,需要根据配置的频率进行
    self.m_updateLeftTime = self.m_updateLeftTime - dt
    if self.m_updateLeftTime <= 0 then
        self.behaviourTree:tick(self, self.blackBoard)
        self.m_updateLeftTime = 1 / self.updateFrequency
    end

    ---检测是否离开或者进入出生区域
    if CheckRange(self.bornPos1, self.bornPos2, self.model.Position) then
        ---当前在出生区域内
        self:EnterBornArea()
    else
        ---当前不在出生区域内
        self:LeaveBornArea()
    end

    self.m_gunIns:Update(dt, tt)
end

---销毁
function NpcEnemyBase:Destroy()
    self.m_gunIns:Destroy()
    self.model:Destroy()
    table.cleartable(self)
    self = nil
end

--- 攻击时候主动调用
function NpcEnemyBase:Attack()
    ---停下
    self.model:MoveTowards(Vector2.Zero)
    ---转向,朝向攻击者
    self.model:FaceToDir(self.m_targetPlayer.Position - self.model.Position, 15)
    if self.m_gunIns and self.m_targetPlayer then
        self.m_gunIns:Fire(self.m_targetPlayer)
    end
end

--- 被攻击时候由外部调用
---@param _origin PlayerInstance 攻击发起的玩家或者NPC
---@param _damage number
function NpcEnemyBase:BeAttack(_origin, _damage, _weaponId, _hitPart)
    if self.model.Health <= 0 then
        return
    end
    if self.m_invincible then
        return
    end
    if _origin.Health <= 0 then
        ---伤害发起者已经死亡则不响应此次伤害
        return
    end
    self.model:MoveTowards(
        Vector2(_origin.Position.X - self.model.Position.X, _origin.Position.Z - self.model.Position.Z)
    )
    self.model.Health = self.model.Health - _damage
    if self.model.Health <= 0 then
        ---死亡
        NetUtil.Broadcast('PlayerDieEvent', _origin, self.model, _weaponId, _hitPart)
        world.S_Event:BroadcastEvent('PlayerDieEvent', _origin, self.model, _weaponId, _hitPart)
        self:Die()
    end
end

---感知附近指定范围内是否有敌人
---@param _hasView boolean 是否看到敌人
---@param _dis number 范围
function NpcEnemyBase:PerceiveEnemy(_hasView, _dis)
    local playersInRange = {}
    for i, v in pairs(FindAllPlayers()) do
        if
            _dis >= (v.Position - self.model.Position).Magnitude and v.PlayerType and
                v.PlayerType.Value ~= self.model.PlayerType.Value
         then
            ---在范围内
            if v.Health > 0 then
                if not _hasView then
                    self.m_targetPlayer = v
                    return true
                end
                table.insert(playersInRange, v)
            end
        end
    end
    ---检查在范围内的活的敌人是否可见
    for i, v in pairs(playersInRange) do
        local bones = v.Avatar:GetChildren()
        local hasBlock = false
        for i1, v1 in pairs(bones) do
            local rayRes = Physics:RaycastAll(self.model.Avatar.Bone_Head.Position, v1.Position, false)
            for _, obj in pairs(rayRes.HitObjectAll) do
                if obj.Block and not ParentPlayer(obj) then
                    hasBlock = true
                end
            end
        end
        if not hasBlock then
            self.m_targetPlayer = v
            return true
        end
    end
    self.m_targetPlayer = nil
    return false
end

---获取最近的非己方占领的据点坐标,仅占点模式生效
function NpcEnemyBase:GetHoldPoint()
    if GameFlowMgr.curMode ~= Const.GameModeEnum.OccupyMode then
        return false
    end
    local team = self.team
    local dis = math.huge
    local hasPoint = false
    for i, v in pairs(OccupyMode.holdPointsList) do
        if v.teamValue[team] < 100 then
            if (v.obj.Position - self.model.Position).Magnitude < dis then
                self.m_targetPoint = v.obj.Position
                dis = (v.obj.Position - self.model.Position).Magnitude
                hasPoint = true
            end
        end
    end
    return hasPoint
end

---开始向目标敌人m_targetPlayer移动
function NpcEnemyBase:StartMoveToTargetPlayer()
    if not self.m_targetPlayer then
        return
    end
    self.m_targetPoint = self.m_targetPlayer.Position
end

---逃跑,寻找最近的安全点
function NpcEnemyBase:StartFlee()
    --print('逃跑,寻找最近的安全点')
    local points
    if NavMesh.navMeshList[self.sceneId] and NavMesh.navMeshList[self.sceneId].SafePoints then
        points = NavMesh.navMeshList[self.sceneId].SafePoints
    end
    if points then
        self.m_targetPoint = NavMesh.ConvertStr2Pos(table.readRandomValueInTable(points))
    else
        self.m_targetPoint = nil
    end
end

---返回己方营地
function NpcEnemyBase:StartReturnHome()
    local target = self.bornPos1 + self.bornPos2
    target = target * 0.5
    self.m_targetPoint = target
end

---前往静态目标点
function NpcEnemyBase:StartMoveStaticTarget()
    ---print('前往静态目标点', self.staticTarget, self.model.Name)
    self.m_targetPoint = self.staticTarget
end

---前行,优先向目标玩家前进
function NpcEnemyBase:MoveForward()
    local pos
    if self.m_targetPoint then
        pos = self.m_targetPoint
    end
    if self.m_targetPlayer then
        pos = self.m_targetPlayer.Position
    end
    if pos then
        self.model:FaceToDir(pos - self.model.Position, 15)
    end
    self.model:MoveTowards(Vector2(self.model.Forward.x, self.model.Forward.z))
end

---停止移动
function NpcEnemyBase:StopMove()
    self.m_targetPoint = nil
end

--- 死亡,自己主动调用
function NpcEnemyBase:Die()
    self.model.Health = 0
    --self.model:Die()
    self.m_targetPlayer = nil
    self.model.Avatar:PlayAnimation('Dead', 3, 1, 0, true, false, 1)
    self.m_deathNum = self.m_deathNum + 1
    local time = 0
    if self.model.PlayerType.Value == Const.TeamEnum.Team_A then
        time = self.reviveWaitTime[1][self.m_deathNum] or self.reviveWaitTime[1][#self.reviveWaitTime[1]]
    else
        time = self.reviveWaitTime[2][self.m_deathNum] or self.reviveWaitTime[2][#self.reviveWaitTime[2]]
    end
    self:Stop()
    self.model:MoveTowards(Vector2.Zero)
    self.model.CharacterHeight = 1
    self.model.CharacterWidth = 0.1
    --self.headPoint:SetActive(false)
    --self.bodyPoint:SetActive(false)
    invoke(
        function()
            if self.model then
                self:Born()
            end
        end,
        time
    )
end

---NPC的寻路方法,开始寻路时候调用,寻路中调用会直接返回
function NpcEnemyBase:Navigate()
    local wayPoints = {}
    if self.m_preTargetPoint and self.m_preTargetPoint == self.m_targetPoint then
        ---当前寻路的目标点未改变,不需要更新寻路路径
        return
    end
    if not self.m_targetPoint then
        ---没有目标点,不寻路
        self.m_wayPointsList = wayPoints
        self.m_wayPointsLeftList = wayPoints
        return
    end
    if not NavMesh.navMeshList[self.sceneId] then
        ---场景没有导航网格
        return
    end
    self.m_preTargetPoint = self.m_targetPoint
    ---获取自己最近的路点
    local points = NavMesh.navMeshList[self.sceneId].NavMeshData
    if not points then
        self.m_wayPointsList = wayPoints
        self.m_wayPointsLeftList = wayPoints
        return
    end
    local nearestPoint1, nearestPoint2
    local curDis1, curDis2 = math.huge, math.huge
    for i, v in pairs(points) do
        local pos = NavMesh.ConvertStr2Pos(i)
        local dis1 = (pos - self.model.Position).Magnitude
        if curDis1 > dis1 then
            nearestPoint1 = i
            curDis1 = dis1
        end
        local dis2 = (pos - self.m_targetPoint).Magnitude
        if curDis2 > dis2 then
            nearestPoint2 = i
            curDis2 = dis2
        end
    end
    local path = NavMesh.navMeshList[self.sceneId].NavMeshData[nearestPoint1][nearestPoint2]
    if path then
        for i, v in pairs(path) do
            table.insert(wayPoints, NavMesh.ConvertStr2Pos(v))
        end
    end
    table.insert(wayPoints, self.m_targetPoint)
    self.m_wayPointsList = wayPoints
    self.m_wayPointsLeftList = wayPoints
    self.m_moveTimeLeft = MOVE_MAX_TIME
    return
end

---寻路超时触发,暂时强制瞬移到目标点
function NpcEnemyBase:MoveTimeOut()
    print('NPC寻路超时', self.model)
    local target = self.m_wayPointsLeftList[1]
    if target then
        self.model.Position = target
    end
end

---NPC使用自身的寻路点进行移动的逻辑
function NpcEnemyBase:MoveByNavmesh()
    local curTarget = self.m_wayPointsLeftList[1]
    --print('当前移动目标点为', curTarget)
    --print('剩余移动点为')
    --printTable(self.m_wayPointsLeftList)
    if curTarget then
        local dis = Vector2(curTarget.x - self.model.Position.x, curTarget.z - self.model.Position.z).Magnitude
        if dis < 0.5 then
            ---NPC移动到了路径中的下一个目标点
            table.remove(self.m_wayPointsLeftList, 1)
            curTarget = self.m_wayPointsLeftList[1]
        end
    end
    local dir
    if curTarget then
        dir = curTarget - self.model.Position
        dir = Vector2(dir.X, dir.Z)
    else
        ---移动到了目标点,停止移动
        dir = Vector2.Zero
    end
    self.model:FaceToDir(Vector3(dir.x, 0, dir.y), 5)
    self.model:MoveTowards(dir)

    if curTarget then
        ---检测当前寻路是否超时
        self.m_moveTimeLeft = self.m_moveTimeLeft - 1 / self.updateFrequency
        if self.m_moveTimeLeft <= 0 then
            self:MoveTimeOut()
            self.m_moveTimeLeft = MOVE_MAX_TIME
        end
    end
end

--- 出生后调用,首次出生或者死亡后指定时间后出生
function NpcEnemyBase:Born()
    self.model:Reborn()
    ChangeCloth(self)
    self.model.MaxHealth = self.maxHp
    self.model.Health = self.model.MaxHealth
    self.model.WalkSpeed = self.walkSpeed
    self.model.Avatar:StopAnimation('DeadKeep', 3)
    local x = Random_X2Y(self.bornPos1.x, self.bornPos2.x)
    local y = Random_X2Y(self.bornPos1.y, self.bornPos2.y)
    local z = Random_X2Y(self.bornPos1.z, self.bornPos2.z)
    ---print('NPC出生', self.model.Name, x, y, z, self.model.PlayerType.Value)
    invoke(
        function()
            if self.model and not self.model:IsNull() then
                self.model.Position = Vector3(x, y, z) + Vector3.Up * 2
            end
        end,
        0.5
    )
    invoke(
        function()
            if self.model and not self.model:IsNull() then
                self:Start()
            end
        end,
        self.updateDelay
    )
    self:EnterBornArea()
    self.model.Position = Vector3(x, y, z) + Vector3.Up * 2
    self.m_preTargetPoint = nil
    self.model.CharacterHeight = 2
    self.model.CharacterWidth = 1
    self.headPoint:SetActive(true)
    self.bodyPoint:SetActive(true)
end

--- 进入出生区域
function NpcEnemyBase:EnterBornArea()
    self.invincibleCover:SetActive(true)
    self.m_invincible = true
    self.m_inBornArea = true
end

--- 离开出生区域
function NpcEnemyBase:LeaveBornArea()
    self.invincibleCover:SetActive(false)
    self.m_invincible = false
    self.m_inBornArea = false
end

--- 停止更新
function NpcEnemyBase:Stop()
    self.isUpdating = false
end

--- 开始更新
function NpcEnemyBase:Start()
    self.isUpdating = true
end

return NpcEnemyBase
