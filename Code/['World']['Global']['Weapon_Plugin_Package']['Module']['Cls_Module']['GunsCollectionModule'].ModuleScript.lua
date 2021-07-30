---@module GunsCollection 枪械模块：所有的枪械子类的集合
---@copyright Lilith Games, Avatar Team
---@author Sharif Ma
local GunsCollection = {}

---@module AssaultRifleBase:GunBase
local AssaultRifleBase = class('AssaultRifleBase', GunBase)

---@module SniperRifleBase :GunBase
local SniperRifleBase = class('SniperRifleBase', GunBase)

---@module ShotGunBase:GunBase 霰弹枪的逻辑
local ShotGunBase = class('ShotGun', GunBase)

---@module SubMachineGunBase
local SubMachineGunBase = class('SubMachineGunBase', GunBase)

---@module PistolBase :GunBase
local PistolBase = class('PistolBase', GunBase)

---狙击枪开枪后的弹壳抛射
function SniperRifleBase:MakeBulletShell()
    if self.toss == nil then
        return
    end
    local temp = EulerDegree(180 * math.random(), 0, 180 * math.random())
    local shell =
        GunBase.static.utility:UseCacheObject(
        self,
        self.bulletShell,
        true,
        {
            Position = self.toss.Position,
            Forward = self.toss.Forward,
            Block = false
        },
        nil,
        ObjectTypeEnum.Shell
    )
    shell.Rotation = temp
    local dir =
        (-0.7 * self.character.Forward.Normalized + 0.5 * self.character.Right.Normalized + 0.3 * Vector3.Up).Normalized
    shell.LinearVelocity =
        (3 + 2 * math.random()) * RandomRotate(dir, 30) +
        Vector3(self.character.LinearVelocity.x, 0, self.character.LinearVelocity.z)
end

---@module RocketLauncherBase:GunBase 实体子弹发射器逻辑,命中后爆炸,给予爆炸范围内的敌人一定伤害
local RocketLauncherBase = class('RocketLauncherBase', GunBase)

function RocketLauncherBase:Fire(delay, consume)
    local isFriend = false
    local direction = self:CalculateRayCastDirection()
    local hit = self:OverloadRayCast(direction)

    if self.character then
    --self.Character:IK()
    end

    if not isFriend and hit then
        local endPos = hit.HitPoint
        local endNorm = hit.HitNormal
        local endObj = hit.HitObject
        print('火箭筒开火成功', consume)
        if consume then
            self:Consume()
        end

        if not hit.HitObject then
            endPos = self:RayCastOrigin() + self.config_distance * direction
        end

        self:MakeFireEffect()
        self:MakeBullet(endObj, endPos, endNorm)

        self.m_hasJustFired = true
        return true
    else
        self.m_hasJustFired = true
        return false
    end
end

---真实子弹,命中后爆炸,给予范围内敌人一定伤害
function RocketLauncherBase:MakeBullet(_endObj, _endPos, _endNorm)
    local speed = self:GetBulletSpeed()
    --local rocket = GunBase.static.utility:UseCacheObject(self, self.bulletName, false, { Position = self.muzzleObj.Position }, world)
    local rocket = world:CreateInstance(self.bulletName, self.bulletName, world, self.muzzleObj.Position)
    local hasCollide = false
    if rocket then
        local dir = (_endPos - self.muzzleObj.Position).Normalized
        local bullet = rocket:GetChildren()[1]
        --bullet.IsStatic = true
        rocket.Forward = dir
        --bullet.LocalPosition = Vector3.Zero
        bullet.AngularVelocity = dir
        bullet.IsStatic = false
        bullet.LinearVelocity = dir * speed
        bullet.Trailing:SetActive(true)
        bullet.OnCollisionBegin:Connect(
            function(_obj, _point, _normal)
                if not self or not self.character then
                    return
                end
                if _obj.Block and ParentPlayer(_obj) ~= self.character then
                    _point = _point - 0.4 * dir
                    self:MakeHitEffect(_point)
                    invoke(
                        function()
                            ---进行伤害的判定和计算
                            if _obj and not _obj:IsNull() then
                                self:Damage({HitPoint = _point, HitObject = _obj, HitNormal = _normal})
                            end
                        end,
                        self.config_damageResponseWaitTime
                    )
                    hasCollide = true
                    bullet.OnCollisionBegin:Clear()
                    bullet.Trailing:SetActive(false)
                    bullet.LinearVelocity = Vector3.Zero
                    bullet.AngularVelocity = Vector3.Zero
                    rocket:Destroy()
                --GunBase.static.utility:Recycle(self, self.bulletName, rocket)
                end
            end
        )
        local time = self.config_distance / speed
        invoke(
            function()
                if not hasCollide then
                    bullet.OnCollisionBegin:Clear()
                    bullet.Trailing:SetActive(false)
                    bullet.LinearVelocity = Vector3.Zero
                    bullet.AngularVelocity = Vector3.Zero
                    rocket:Destroy()
                --GunBase.static.utility:Recycle(self, self.bulletName, rocket)
                end
            end,
            time
        )
        world.S_Event.WeaponObjCreatedEvent:Fire(self.character, rocket)
    else
        print('Rocket creation failed! Make sure rocket "' .. self.bulletName .. '" exist')
    end
end

---没有弹壳
function RocketLauncherBase:MakeBulletShell()
end

function RocketLauncherBase:Damage(_hit)
    ---爆炸没有爆头判定,后续可能根据距离爆炸中心店距离进行计算
    local totalWeight, hitBoneWeight = 0, 0
    for k, v in pairs(self.boneWeight) do
        totalWeight = totalWeight + v
    end
    local hitRes = {}
    local playersInRange, fortsInRange =
        GunBase.static.utility:GetEnemyByRange(
        self.character,
        self.config_isHitSelf,
        self.config_isHitFriend,
        self.config_explosionRange,
        180,
        _hit.HitPoint
    )
    for _, v in pairs(playersInRange) do
        ---表示此玩家在爆炸范围内,检查玩家和爆炸中心之间是否有阻挡
        local dis = (v.Position - _hit.HitPoint).Magnitude
        for k1, v1 in pairs(self.boneWeight) do
            local raycastAll = Physics:RaycastAll(_hit.HitPoint, v.Avatar[k1].Position, false)
            local isHit_ThisBone = true
            for k2, v2 in pairs(raycastAll.HitObjectAll) do
                if v2.Block and not ParentPlayer(v2) and v.CollisionGroup ~= 10 then
                    print('中间有东西阻挡了爆炸', v2, k1)
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
        local attenuation = GunBase.static.utility:GetAttenuationByGunId(2, self, dis)
        local damage = self.config_damage
        damage = damage + attenuation
        damage = damage <= 0 and 0 or damage
        damage = damage * rate
        if damage > 0 then
            local info = {
                Player = v,
                Damage = damage,
                HitPart = HitPartEnum.None,
                HitPos = _hit.HitPoint
            }
            table.insert(hitRes, info)
        end
    end
    ---检测炮台是否在范围内
    for i, v in pairs(fortsInRange) do
        local dis = (v.Position - _hit.HitPoint).Magnitude
        local attenuation = GunBase.static.utility:GetAttenuationByGunId(2, self, dis)
        local damage = self.config_damage
        damage = damage + attenuation
        damage = damage <= 0 and 0 or damage
        if damage > 0 then
            local info = {
                Player = v.Owner.Value,
                Damage = damage,
                HitPart = HitPartEnum.Fort,
                HitPos = _hit.HitPoint
            }
            table.insert(hitRes, info)
        end
    end
    ---伤害判定
    for i, v in pairs(hitRes) do
        self.successfullyHit:Trigger({Position = v.HitPos, Player = v.Player, Damage = v.Damage, HitPart = v.HitPart})
        PlayerGunMgr:FireGunDamage(localPlayer, v.Player, self.gun_Id, v.Damage, v.HitPart)
    end
end

---@module RPGBase:RocketLauncherBase PRG火箭发射筒
local RPGBase = class('RPGBase', RocketLauncherBase)

function RPGBase:Fire(delay, consume)
    local fireRes = RocketLauncherBase.Fire(self, delay, consume)
    if fireRes then
        ---火箭发射成功,需要将枪口的子弹隐藏
        print('火箭发射成功,需要将枪口的子弹隐藏')
        self.gun.Module.RPGBullet:SetActive(false)
    end
    return fireRes
end

function RPGBase:MakeBullet(_endObj, _endPos, _endNorm)
    RocketLauncherBase.MakeBullet(self, _endObj, _endPos, _endNorm)
end

---重新父类的后构造函数,用于子弹装弹完成的回调监听
function RPGBase:LaterInitialize()
    self:CreateCacheObjects()
    self.gun.Module.RPGBullet:SetActive(false)
    local function ReloadFinished()
        print('装弹结束,显示枪口的子弹')
        if self and self.gun then
            self.gun.Module.RPGBullet:SetActive(true)
        end
    end
    self.reloadFinished:Bind(ReloadFinished)
end

---@module GrenadeLauncherBase:GunBase 实体子弹发射器逻辑,命中后爆炸,给予爆炸范围内的敌人一定伤害
local GrenadeLauncherBase = class('GrenadeLauncherBase', RocketLauncherBase)

function GrenadeLauncherBase:Fire(delay, consume)
    local isFriend = false
    local direction = self:CalculateRayCastDirection()
    if consume then
        self:Consume()
    end
    self:MakeFireEffect()
    self:MakeBullet(direction.Normalized)
    self.m_hasJustFired = true
    return true
end

---真实子弹
function GrenadeLauncherBase:MakeBullet(_dir)
    local speed = self:GetBulletSpeed()
    local rocket =
        world:CreateInstance(
        self.bulletName,
        self.bulletName,
        world,
        self.muzzleObj.Position + self.character.Forward * 0.5
    )
    if rocket then
        rocket.Forward = _dir
        rocket.Cartridge.LocalPosition = Vector3.Zero
        rocket.Cartridge.GravityEnable = true
        rocket.Cartridge.GravityScale = self.config_gravityScale
        rocket.Cartridge.OnCollisionBegin:Connect(
            function(_obj, _point, _normal)
                if ParentPlayer(_obj) ~= self.character then
                    self:MakeHitEffect(_point)
                    rocket:Destroy()
                    ---进行伤害的判定和计算
                    self:Damage({HitPoint = _point, HitObject = _obj, HitNormal = _normal})
                end
            end
        )
        rocket.Cartridge.AngularVelocity = _dir
        rocket.Cartridge.LinearVelocity = _dir * speed
        local time = 10
        invoke(
            function()
                if (rocket) then
                    rocket:Destroy()
                end
            end,
            time
        )
        world.S_Event.WeaponObjCreatedEvent:Fire(self.character, rocket)
    else
        print('Rocket creation failed! Make sure rocket "' .. self.bulletName .. '" exist')
    end
end

---@module TrailingGunBase:GunBase 实体子弹发射器逻辑,自动追踪
local TrailingGunBase = class('TrailingGunBase', GunBase)

function TrailingGunBase:Fire(delay, consume)
    local isFriend = false
    local direction = (self:RayCastTarget() - self:RayCastOrigin()).Normalized
    local hit = self:OverloadRayCast(direction)

    if not isFriend and hit then
        local endPos = hit.HitPoint
        local endObj = hit.HitObject

        if consume then
            self:Consume()
        end

        if not hit.HitObject or hit.HitObject:IsNull() then
            endPos = self:RayCastOrigin() + self.config_distance * direction
        end

        self:MakeFireEffect()
        self:MakeBullet(endObj, endPos)

        self.m_hasJustFired = true
        return true
    else
        self.m_hasJustFired = true
        return false
    end
end

---真实子弹
function TrailingGunBase:MakeBullet(_endObj, _endPos)
    local enemy
    local speed = self.config_bulletSpeed
    if (_endObj and _endObj:IsA('PlayerInstance')) then
        enemy = _endObj
    end
    --
    invoke(
        function()
            local bullet =
                world:CreateInstance(
                self.bulletName,
                self.bulletName,
                world,
                self.muzzleObj.Position + world.CurrentCamera.Forward * 0.3,
                EulerDegree.LookRotation(-1 * world.CurrentCamera.Forward, Vector3.Up)
            )
            bullet.OnCollisionBegin:Connect(
                function(_obj, _point, _normal)
                    if (not _obj) then
                        bullet:Destroy()
                        return
                    end

                    local maybePlayer = ParentPlayer(_obj)
                    --碰撞到了子弹或者自身玩家
                    if (_obj.Name == self.bulletName or maybePlayer == self.character) then
                        ---非玩家
                        goto Continue
                    elseif (maybePlayer == nil) then
                        bullet:Destroy()
                        self:MakeHitEffect(_endPos)
                        goto Continue
                    end
                    ---碰撞到其他玩家
                    self:Damage({HitObject = maybePlayer})

                    ---TODO
                    bullet:Destroy()
                    self:MakeHitEffect(_endPos)
                    ::Continue::
                end
            )

            local firstDis = _endPos - bullet.Position
            local firstSpd = RandomRotate(speed * world.CurrentCamera.Forward.Normalized, self.error)
            bullet.LinearVelocity = firstSpd
            local time = 0
            local targetPos = _endPos
            while (bullet) do
                time = time + wait()
                if (enemy) then
                    targetPos = enemy.Position + Vector3(0, 1, 0)
                end
                if (not bullet) then
                    return
                end
                if (((bullet.Position - targetPos).Magnitude < 0.5 and time > 3) or time > 7) then
                    bullet:Destroy()
                    return
                end
                local nowDis = targetPos - bullet.Position
                local alpha = math.clamp(1 - nowDis.Magnitude / firstDis.Magnitude, 0, 1)
                bullet.LinearVelocity =
                    Vector3.Slerp(firstSpd.Normalized, nowDis.Normalized, math.sqrt(alpha)).Normalized * speed
                bullet.Up = bullet.LinearVelocity.Normalized
            end
        end
    )
end

---@module GatlingBase : GunBase 加特林机枪的实体类,开镜逻辑替换为部署
local GatlingBase = class('GatlingBase', GunBase)

function GatlingBase:LaterInitialize()
    GunBase.LaterInitialize(self)
    self.originError_min = self.m_recoil.config_minError
    self.originError_max = self.m_recoil.config_maxError
    self.originVerticalJumpAngle = self.m_recoil.config_verticalJumpAngle
    self.originHorizontalJumpRange = self.m_recoil.config_horizontalJumpRange
    self.originWeight = self.config_weight
    self.fortObj = world:CreateInstance('GatlingFort', 'GatlingFort', self.character.Avatar)
    self.fortObj.LocalPosition = Vector3.Up * 0.4
    self.fortObj.LocalRotation = EulerDegree(0, 0, 0)
    self.fortObj:SetActive(false)
    self.allowFort = true
    ---是否正在部署
    self.isForting = false
    ---架枪部署时间
    self.fortWaitTime = 0.75

    ---当前部署剩余时间
    self.fortLeftTime = self.fortWaitTime
    self.UpdateFortAnimation = function(_dt)
        self.fortLeftTime = self.fortLeftTime - _dt
        if self.fortLeftTime <= 0 then
            ---架枪部署结束,进入开镜状态
            world.OnRenderStepped:Disconnect(self.UpdateFortAnimation)
            self:FortOver()
        end
        ---更新动画
        self.fortObj.LocalPosition = Vector3.Up * 1.1 * _dt / self.fortWaitTime + self.fortObj.LocalPosition
    end
end

function GatlingBase:StartFort()
    self.fortLeftTime = self.fortWaitTime
    self.fortObj.LocalPosition = Vector3.Up * -0.7
    self.isForting = true
    world.OnRenderStepped:Connect(self.UpdateFortAnimation)
end

---外部强制结束部署,最终不会进入部署状态
function GatlingBase:StopFort()
    self.isForting = false
    self.fortObj.LocalPosition = Vector3.Up * -0.7
    world.OnRenderStepped:Disconnect(self.UpdateFortAnimation)
    ---重置动画
    self.config_weight = self.originWeight
    self.fortObj:SetActive(false)
    invoke(
        function()
            if self.allowFort ~= nil then
                self.allowFort = true
            end
        end,
        3
    )
end

---部署结束后的调用
function GatlingBase:FortOver()
    print('部署结束后的调用')
    self.fortObj.LocalPosition = Vector3.Up * 0.4
    self.isForting = false
    self.m_isZoomIn = true
    self.m_cameraControl:MechanicalAimStart()
    self.m_gui:MechanicalAimStart()
    self.aimIn:Trigger()
    self.m_recoil.config_minError = 1
    self.m_recoil.config_maxError = 2
    self.m_recoil.config_verticalJumpAngle = 0.2
    self.m_recoil.config_horizontalJumpRange = 0.2
end

---加特林开镜更改为架枪
function GatlingBase:MechanicalAimStart()
    if not self.allowFort then
        localPlayer.C_Event.NoticeEvent:Fire(1002)
        return
    end
    if self.m_isZoomIn or not self.m_isDraw then
        return
    end
    if not self.character.IsOnGround or self.m_isPumping or self.m_onReload then
        return
    end
    self:StartFort()
    self.config_weight = 20
    self.fortObj:SetActive(true)
    self.allowFort = false
end

function GatlingBase:RayCastOrigin()
    return localPlayer.Position + 0.3 * localPlayer.Forward + 0.2 * localPlayer.Right +
        (localPlayer.CharacterHeight / 2) * Vector3.Up
end

---加特林关镜更改为退出架枪模式
function GatlingBase:MechanicalAimStop()
    print('加特林关镜更改为退出架枪模式')
    if self.isForting then
        self:StopFort()
        return
    end
    if not self.isForting and not self.m_isZoomIn then
        return
    end
    if not self.m_isDraw then
        return
    end
    self.m_isZoomIn = false
    self.m_gui:MechanicalAimStop()
    self.m_cameraControl:MechanicalAimStop()
    self.aimOut:Trigger()
    self.m_recoil.config_minError = self.originError_min
    self.m_recoil.config_maxError = self.originError_max
    self.m_recoil.config_verticalJumpAngle = self.originVerticalJumpAngle
    self.m_recoil.config_horizontalJumpRange = self.originHorizontalJumpRange
    self.config_weight = self.originWeight
    self.fortObj:SetActive(false)
    invoke(
        function()
            if self.allowFort ~= nil then
                self.allowFort = true
            end
        end,
        3
    )
end

function GatlingBase:WithdrawGun()
    GunBase.WithdrawGun(self)
    if self.isForting then
        self:StopFort()
    end
    --self:MechanicalAimStop()
end

function GatlingBase:EarlyDestructor()
    GunBase.EarlyDestructor(self)
    self.fortObj:Destroy()
end

---@module BarrettBase : SniperRifleBase 巴雷特类,尝试使用实体子弹进行检测
local BarrettBase = class('BarrettBase', SniperRifleBase)

function BarrettBase:Fire(_delay, _consume)
    local isFriend = false
    local direction = self:CalculateRayCastDirection()
    local hit = self:OverloadRayCast(direction)
    if not isFriend and hit then
        local endPos = hit.HitPoint

        if _consume then
            self:Consume()
        end

        if not hit.HitObject or hit.HitObject:IsNull() then
            endPos = self:RayCastOrigin() + self.config_distance * direction
        end

        self:MakeFireEffect()
        self:MakeBullet(nil, endPos, nil)

        self.m_hasJustFired = true
        return true
    else
        self.m_hasJustFired = true
        return false
    end
end

function BarrettBase:MakeBullet(_endObj, _endPos, _endNorm)
    local speed = self:GetBulletSpeed()
    local bullet =
        world:CreateInstance(self.bulletName, self.bulletName, world, self.muzzleObj.Position, self.muzzleObj.Rotation)
    local isHit = false
    if bullet then
        local dir = (_endPos - bullet.Position).Normalized
        bullet.LinearVelocity = dir * speed
        bullet.GravityEnable = true
        bullet.GravityScale = self.config_gravityScale
        ---上一帧的子弹尾部位置
        local prePos = self.muzzleObj.Position
        --- 每个渲染帧执行的碰撞监测
        local function CheckCollision(_dt)
            if not self or not self.muzzleObj or not bullet or bullet:IsNull() then
                world.OnRenderStepped:Disconnect(CheckCollision)
                return
            end
            local curHeadPos = bullet.Head.Position
            local curDir = (curHeadPos - prePos).Normalized
            local hitResults = Physics:RaycastAll(prePos, curHeadPos, false)
            local isHitOtherPlayer = false
            local otherPlayer = nil
            for k, v in pairs(hitResults.HitObjectAll) do
                if v.Block and not v:IsA('PlayerInstance') and v.CollisionGroup ~= 10 then
                    ---射线检测到了碰撞到的是刚体
                    _endObj = v
                    _endNorm = hitResults.HitNormalAll[k]
                    _endPos = hitResults.HitPointAll[k]
                    self:MakeHitEffect(_endPos)
                    GunBase.static.utility:UseCacheObject(
                        self,
                        self.bulletHole,
                        true,
                        {Position = _endPos, Up = _endNorm, Size = Vector3(0.07, 0.07, 0.07)},
                        _endObj,
                        nil,
                        ObjectTypeEnum.Hole
                    )
                    bullet.IsStatic = true
                    bullet.Position = _endPos
                    bullet.LinearVelocity = Vector3.Zero
                    invoke(
                        function()
                            if bullet then
                                bullet:SetActive(false)
                                bullet:Destroy()
                            end
                        end,
                        3
                    )
                    isHit = true
                    world.OnRenderStepped:Disconnect(CheckCollision)
                    return
                end
                if v:IsA('PlayerInstance') and v ~= self.character then
                    ---短射线碰到了其他玩家
                    isHitOtherPlayer = true
                    otherPlayer = v
                    _endObj = v
                    _endNorm = hitResults.HitNormalAll[k]
                    _endPos = hitResults.HitPointAll[k]
                    break
                end
            end
            local hitPart = HitPartEnum.Limb
            if isHitOtherPlayer then
                local extendHitResults = Physics:RaycastAll(prePos - curDir, curHeadPos + curDir, false)
                for k, v in pairs(extendHitResults.HitObjectAll) do
                    if v.Name == 'HeadPoint' and ParentPlayer(v) == otherPlayer then
                        hitPart = HitPartEnum.Head
                        break
                    elseif v.Name == 'BodyPoint' and ParentPlayer(v) == otherPlayer then
                        hitPart = HitPartEnum.Body
                        break
                    end
                end
                if bullet then
                    bullet:SetActive(false)
                    bullet:Destroy()
                end
                ---进行伤害的判定和计算
                self:Damage({HitPoint = _endPos, HitObject = _endObj, HitNormal = _endNorm, HitPart = hitPart})
                world.OnRenderStepped:Disconnect(CheckCollision)
                return
            end
        end
        world.OnRenderStepped:Connect(CheckCollision)

        local time = self.config_distance / speed
        invoke(
            function()
                if bullet and not isHit then
                    bullet:SetActive(false)
                    bullet:Destroy()
                end
                world.OnRenderStepped:Disconnect(CheckCollision)
            end,
            time
        )
        world.S_Event.WeaponObjCreatedEvent:Fire(self.character, bullet)
    else
        print('Rocket creation failed! Make sure bullet "' .. self.bulletName .. '" exist')
    end
end

---@module MeleeBase:GunBase 近战武器
local MeleeBase = class('MeleeBase', GunBase)

---近战武器向指定方向做攻击判定检测
---@param _dir Vector3 方向
---@param _angel number 范围角度
---@return table
function MeleeBase:OverloadRayCast(_dir, _angel)
    local dis = self.config_distance
    local res = {}
    for i, v in pairs(FindAllPlayers()) do
        local len = (v.Position - self.character.Position).Magnitude
        if len <= dis and Vector3.Angle(v.Position - self.character.Position, _dir) < _angel and v ~= self.character then
            table.insert(res, v)
        end
    end
    return res
end

---近战武器暂时不创建对象缓存池,之后若有命中特效等再添加
function MeleeBase:LaterInitialize()
    ---声明攻击结束的事件
    self.waveOver = EventMgr:new('WaveOver', self)
    self.pointsCount = 5
    self.prePointsPosList = {} ---上一帧各个点的位置
    self.curPointsPosList = {} ---这一帧各个点的位置
    self.hadHitPlaysList = {} ---已经命中的玩家对象,在下一帧会排除这个玩家
    self.hitPlayersList = {} ---命中的玩家对象,一次挥剑至多对一名玩家造成一次伤害
    ---每帧进行的射线碰撞监测
    function self.DifFrameCheck()
        if not self.pointsCount then
            return
        end
        for i = 1, self.pointsCount + 1 do
            self.curPointsPosList[i] =
                self.toss.Position + (i - 1) / self.pointsCount * (self.muzzleObj.Position - self.toss.Position)
        end
        for i, v in pairs(self.curPointsPosList) do
            local raycastAll = Physics:RaycastAll(v, self.prePointsPosList[i], false)
            for _, v1 in pairs(raycastAll.HitObjectAll) do
                if v1.Name ~= 'PickJudge' then
                    local player = ParentPlayer(v1)
                    if player then
                        ---检测到命中了玩家
                        self.hitPlayersList[player] = self.hitPlayersList[player] or {}
                        if v1.Name == 'HeadPoint' then
                            self.hitPlayersList[player].HeadPoint = true
                        elseif v1.Name == 'BodyPoint' then
                            self.hitPlayersList[player].BodyPoint = true
                        end
                    end
                end
            end
        end
        ---按照配置剔除自身或者队友
        if not self.config_isHitSelf then
            self.hitPlayersList[self.character] = nil
        end
        if not self.config_isHitFriend then
            local selfTeam = self.character.PlayerType.Value
            for i, v in pairs(self.hitPlayersList) do
                if i.PlayerType.Value == selfTeam then
                    self.hitPlayersList[i] = nil
                end
            end
        end
        ---检测命中的玩家是否在范围内,和是否有阻挡
        for i, v in pairs(self.hitPlayersList) do
            local dis = (i.Position - self.character.Position).Magnitude
            if
                dis > self.config_distance or
                    Vector3.Angle(i.Position - self.character.Position, self.character.Forward) > 40 or
                    v == self.character
             then
                self.hitPlayersList[i] = nil
            end
            local raycastAll =
                Physics:RaycastAll(self.character.Avatar.Bone_Pelvis.Position, i.Avatar.Bone_Pelvis.Position, false)
            local hasBlock = false
            for i1, v1 in pairs(raycastAll.HitObjectAll) do
                if v1.Block and not ParentPlayer(v1) and v1.CollisionGroup ~= 10 then
                    hasBlock = true
                end
            end
            if hasBlock then
                self.hitPlayersList[i] = nil
            end
        end
        ---对此帧检测到的命中的玩家进行伤害判定
        for i, v in pairs(self.hitPlayersList) do
            if not self.hadHitPlaysList[i] then
                print('这个玩家之前没有被命中')
                ---这个玩家之前没有被命中
                if v.HeadPoint then
                    ---爆头命中
                    print('爆头命中', i)
                    self:Damage({HitObject = i, HitPart = HitPartEnum.Head})
                elseif v.BodyPoint then
                    ---躯干命中
                    print('躯干命中', i)
                    self:Damage({HitObject = i, HitPart = HitPartEnum.Body})
                else
                    ---四肢命中
                    print('四肢命中', i)
                    self:Damage({HitObject = i, HitPart = HitPartEnum.Limb})
                end
                self.hadHitPlaysList[i] = true
            end
        end
        self.hitPlayersList = {}
        for i, v in pairs(self.curPointsPosList) do
            self.prePointsPosList[i] = v
        end
    end
    ---绑定攻击结束的事件
    self.waveOver:Bind(
        function()
            if self.DifFrameCheck then
                world.OnRenderStepped:Disconnect(self.DifFrameCheck)
                self.hadHitPlaysList = {}
            end
        end
    )
    local function HitShake(_sender, _infoList)
        if _infoList.Player.Health <= 0 then
            return
        end
        CameraShake(0.1, 0.1)
    end
    self.successfullyHit:Bind(HitShake)
end

---重写枪械基类的开火方法,自定义攻击检测
function MeleeBase:Fire()
    ---一秒钟后触发攻击结束事件
    invoke(
        function()
            wait(0.2)
            if self and self.DifFrameCheck then
                world.OnRenderStepped:Connect(self.DifFrameCheck)
            end
            wait(0.3)
            if self and self.waveOver then
                self.waveOver:Trigger()
            end
        end
    )
    ---进行刀剑多段差帧射线检测
    for i = 1, self.pointsCount + 1 do
        self.prePointsPosList[i] =
            self.toss.Position + (i - 1) / self.pointsCount * (self.muzzleObj.Position - self.toss.Position)
    end
    return true
end

function MeleeBase:MechanicalAimStart()
    return
end

function MeleeBase:MechanicalAimStop()
    return
end

function MeleeBase:LoadMagazine()
end

function MeleeBase:Consume()
end

function MeleeBase:ChangeShootMode()
end

function MeleeBase:MakeBulletShell()
end

---刀销毁方法中,解绑事件
function MeleeBase:EarlyDestructor()
    GunBase.EarlyDestructor(self)
    if self.DifFrameCheck then
        world.OnRenderStepped:Disconnect(self.DifFrameCheck)
    end
end

---@module FlameLauncher :GunBase 火焰发射器
local FlameLauncher = class('FlameLauncher', GunBase)

function FlameLauncher:LaterInitialize()
    self:CreateCacheObjects()
    self.m_flame_isFiring = false
    ---特效的回收倒计时
    self.m_flame_recycleTime = 0.3
    local onDead = function()
        self:RecycleFireEffect()
    end
    self.character.OnDead:Connect(onDead)
end

---开枪后创建开火特效,特效在自身计时结束后停止播放
function FlameLauncher:MakeFireEffect()
    self.m_flame_recycleTime = 0.3
    if not self.m_flame_isFiring then
        ---当前没有播放开火特效
        self.m_flame_fireEffObj =
            GunBase.static.utility:UseCacheObject(self, self.fireEffect, false, {}, nil, ObjectTypeEnum.FireEff)
        self.m_flame_fireEffObj:SetParentTo(self.muzzleObj, Vector3.Zero, EulerDegree(0, 0, 0))
        self.m_flame_isFiring = true
    end
end

function FlameLauncher:Fire(delay, consume)
    print('喷火器开火')
    self:MakeFireEffect()
    self.m_hasJustFired = true
    if consume then
        self:Consume()
    end
    self:Damage()
    return true
end

function FlameLauncher:Update(_deltaTime)
    GunBase.Update(self, _deltaTime)
    if self.m_flame_isFiring then
        self.m_flame_recycleTime = self.m_flame_recycleTime - _deltaTime
    end
    if self.m_flame_recycleTime <= 0 and self.m_flame_isFiring then
        self:RecycleFireEffect()
    end
end

function FlameLauncher:RecycleFireEffect()
    print('回收特效', self.m_flame_fireEffObj)
    self.m_flame_isFiring = false
    GunBase.static.utility:Recycle(self, self.fireEffect, self.m_flame_fireEffObj)
end

function FlameLauncher:Damage()
    ---火焰发射器没有爆头,需要扇形范围和距离监测
    local totalWeight, hitBoneWeight = 0, 0
    for k, v in pairs(self.boneWeight) do
        totalWeight = totalWeight + v
    end
    local otherPlayers, otherForts =
        GunBase.static.utility:GetEnemyByRange(
        self.character,
        self.config_isHitSelf,
        self.config_isHitFriend,
        self.config_distance,
        50,
        self.muzzleObj.Position
    )

    for _, v in pairs(otherPlayers) do
        ---检查玩家和喷火点中心之间是否有阻挡
        for k1, v1 in pairs(self.boneWeight) do
            local raycastAll = Physics:RaycastAll(self.muzzleObj.Position, v.Avatar[k1].Position, false)
            local isHit_ThisBone = true
            for k2, v2 in pairs(raycastAll.HitObjectAll) do
                if v2.Block and not ParentPlayer(v2) and v.CollisionGroup ~= 10 then
                    print('中间有东西阻挡了爆炸', v2, k1)
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
        local dis = (v.Position - self.character.Position).Magnitude
        local attenuation = GunBase.static.utility:GetAttenuationByGunId(2, self, dis)
        local damage = self.config_damage
        damage = damage + attenuation
        damage = damage <= 0 and 0 or damage
        damage = damage * rate
        if damage > 0 then
            self.successfullyHit:Trigger({Player = v, Damage = damage, HitPart = HitPartEnum.None})
            print('命中敌人')
            PlayerGunMgr:FireGunDamage(self.character, v, self.gun_Id, damage, HitPartEnum.None)
        end
    end
    for i, v in pairs(otherForts) do
        local dis = (v.Position - self.character.Position).Magnitude
        local attenuation = GunBase.static.utility:GetAttenuationByGunId(2, self, dis)
        local damage = self.config_damage
        damage = damage + attenuation
        damage = damage <= 0 and 0 or damage
        if damage > 0 then
            self.successfullyHit:Trigger({Player = v.Owner.Value, Damage = damage})
            print('命中炮台')
            PlayerGunMgr:FireGunDamage(self.character, v.Owner.Value, self.gun_Id, damage, HitPartEnum.Fort)
        end
    end
end

function FlameLauncher:MechanicalAimStart()
end

function FlameLauncher:MechanicalAimStop()
end

function FlameLauncher:MakeBulletShell()
end

---粘弹发射器
---@module ViscoelasticLauncher:RocketLauncherBase
local ViscoelasticLauncher = class('ViscoelasticLauncher', RocketLauncherBase)

function ViscoelasticLauncher:LaterInitialize()
    self:CreateCacheObjects()
    ---已经发射出去的粘弹
    self.m_bulletsFired = {}
end

---粘弹发射器开火
function ViscoelasticLauncher:Fire(delay, consume)
    local direction = self:CalculateRayCastDirection()
    if consume then
        self:Consume()
    end
    self:MakeFireEffect()
    self:MakeBullet(direction.Normalized)
    self.m_hasJustFired = true
    return true
end

function ViscoelasticLauncher:MakeBulletShell()
end

---粘弹发射
function ViscoelasticLauncher:MakeBullet(_dir)
    local speed = self:GetBulletSpeed()
    local rocket = world:CreateInstance(self.bulletName, self.bulletName, world, self.muzzleObj.Position)
    if not rocket then
        print('Rocket creation failed! Make sure rocket "' .. self.bulletName .. '" exist')
        return
    end
    table.insert(self.m_bulletsFired, rocket)
    world:CreateObject('Vector3ValueObject', 'HitNormal', rocket).Value = Vector3.Zero
    rocket.GravityEnable = true
    rocket.GravityScale = self.config_gravityScale
    rocket.OnCollisionBegin:Connect(
        function(_obj, _point, _normal)
            if ParentPlayer(_obj) ~= self.character and rocket then
                rocket.HitNormal.Value = _normal
                rocket.Position = _point + _normal * 0.2
                rocket.IsStatic = true
            end
        end
    )
    rocket.AngularVelocity = _dir
    rocket.LinearVelocity = _dir * speed
    ---10秒后自动爆炸
    invoke(
        function()
            if rocket and not rocket:IsNull() then
                self:MakeHitEffect(rocket.Position + rocket.HitNormal.Value * 0.4)
                rocket:Destroy()
                if self.m_bulletsFired then
                    table.removebyvalue(self.m_bulletsFired, rocket)
                end
            end
        end,
        self.config_damageResponseWaitTime
    )
    world.S_Event.WeaponObjCreatedEvent:Fire(self.character, rocket)
end

---粘弹引爆
function ViscoelasticLauncher:Detonate()
    for i, v in pairs(self.m_bulletsFired) do
        if not v:IsNull() then
            local pos, normal = v.Position, v.HitNormal.Value
            invoke(
                function()
                    if self.config_damage then
                        self:Damage({HitPoint = pos + normal * 0.4})
                    end
                end
            )
            self:MakeHitEffect(v.Position + v.HitNormal.Value * 0.4)
            v:Destroy()
        end
        self.m_bulletsFired[i] = nil
    end
end

---换弹时候尝试引爆
function ViscoelasticLauncher:LoadMagazine()
    GunBase.LoadMagazine(self)
    --self:Detonate()
end

---开镜逻辑变为引爆
function ViscoelasticLauncher:MechanicalAimStart()
    self:Detonate()
end

function ViscoelasticLauncher:MechanicalAimStop()
end

function ViscoelasticLauncher:EarlyDestructor()
    self:Detonate()
    self:DestroyCacheObject()
end

---@module MedicalGun:GunBase 医疗枪
local MedicalGun = class('MedicalGun', GunBase)

---医疗枪的伤害方法,击中敌人敌人扣血,击中队友队友加血
function MedicalGun:Damage(_hit)
    local hitPos = _hit.HitPoint
    local attenuation
    if not hitPos then
        ---未传命中点,默认没有伤害衰减
        attenuation = 0
    else
        local dis = (hitPos - self.character.Position).Magnitude
        attenuation = GunBase.static.utility:GetAttenuationByGunId(1, self, dis)
    end
    local damage = self.config_damage + attenuation
    damage = damage <= 0 and 0 or damage
    if _hit.HitPart == HitPartEnum.Limb then
        damage = damage * self.config_hitLimbDamageRate
    elseif _hit.HitPart == HitPartEnum.Body then
        damage = damage * self.config_hitBodyDamageRate
    elseif _hit.HitPart == HitPartEnum.Head then
        damage = damage * self.config_hitHeadDamageRate
    end
    ---判断击中的对象是否为己方玩家,之后从别的模块获取
    local isFriend = true
    if isFriend then
        damage = damage < 0 and damage or -damage
    else
        damage = damage > 0 and damage or -damage
    end
    if damage ~= 0 then
        print('开始调用击中事件')
        self.successfullyHit:Trigger(
            {Position = hitPos, Player = _hit.HitObject, Damage = damage, HitPart = _hit.HitPart}
        )
        PlayerGunMgr:FireGunDamage(localPlayer, _hit.HitObject, self.gun_Id, damage, _hit.HitPart)
    end
end

function MedicalGun:Fire(delay, consume)
    local isFriend = false
    local direction = self:CalculateRayCastDirection()
    local hit = self:OverloadRayCast(direction)

    if not isFriend and hit then
        local endPos = hit.HitPoint
        local endNorm = hit.HitNormal
        local endObj = hit.HitObject

        if consume then
            self:Consume()
        end

        if not hit.HitObject or hit.HitObject:IsNull() then
            endPos = self:RayCastOrigin() + self.config_distance * direction
        end

        self:MakeFireEffect()
        self:MakeBullet(endObj, endPos, endNorm)
        self:MakeHitEffect(hit)

        if hit.HitObject and hit.HitObject:IsA('PlayerInstance') then
            ---命中了玩家
            self:Damage(hit)
        end

        if hit.IsTarget then
            ---命中靶子
            self.successfullyHitTarget:Trigger(hit)
        end

        self.m_hasJustFired = true
        return true
    else
        self.m_hasJustFired = true
        return false
    end
end

function MedicalGun:MakeHitEffect(_hit)
    local player = _hit.HitObject
    if player.ClassName == 'PlayerInstance' then
        GunBase.static.utility:UseCacheObject(
            self,
            self.hitEffect,
            true,
            {Position = player.Position},
            player,
            ObjectTypeEnum.HitEff
        )
    end
end

---@module AutoShootFort:GunBase 自动射击炮台
local AutoShootFort = class('AutoShootFort', GunBase)

function AutoShootFort:LaterInitialize()
    ---@type FortBase 炮台实体
    self.m_fort = nil
    ---@type Object 炮台虚影
    self.m_fortShadow = world:CreateInstance(self.bulletName, self.bulletName, self.character.Local.Independent)
    if self.m_fortShadow then
        self.m_fortShadow.GravityEnable = false
        self.m_fortShadow.Block = false
        self.m_fortShadow.Color = Color(255, 255, 255, 100)
        world.S_Event.WeaponObjCreatedEvent:Fire(self.character, self.m_fortShadow)
    end
    self.m_fortDestroy = function(...)
        print('炮台销毁', ...)
    end
    self.m_fortBeHit = function(self, _player, _damage)
        print('炮台受击', _player, _damage)
    end
end

function AutoShootFort:EarlyDestructor()
    self:DestroyFort()
end

---子弹的目标位置
function AutoShootFort:RayCastTarget()
    local info = self.m_cameraControl:GetTarget()
    return info
end

function AutoShootFort:OverloadRayCast(_dir)
    local target = self:RayCastOrigin() + _dir * self.config_distance
    local info = Physics:RaycastAll(self:RayCastOrigin(), target, false)
    if info:HasHit() then
        for i, v in ipairs(info.HitObjectAll) do
            if v.Block and not ParentPlayer(v) then
                ---碰撞的不是玩家
                return {
                    HitPoint = info.HitPointAll[i],
                    HitObject = v,
                    HitNormal = info.HitNormalAll[i]
                }
            end
        end
    end
    return {HitPoint = target}
end

function AutoShootFort:FixUpdate(_dt)
    self:UpdateFortShadowPosition()
    GunBase.FixUpdate(self, _dt)
end

function AutoShootFort:UpdateFortShadowPosition()
    local direction = self:CalculateRayCastDirection()
    local hit = self:OverloadRayCast(direction)
    if hit.HitObject then
        self.m_fortShadow.Position = hit.HitPoint
    else
        self.m_fortShadow.Position = Vector3.Up * 10000
    end
end

function AutoShootFort:WithdrawGun()
    GunBase.WithdrawGun(self)
    self.m_fortShadow:SetActive(false)
end

function AutoShootFort:DrawGun(info)
    GunBase.DrawGun(self, info)
    self.m_fortShadow:SetActive(true)
end

function AutoShootFort:Fire(delay, consume)
    local direction = self:CalculateRayCastDirection()
    local hit = self:OverloadRayCast(direction)
    if not hit.HitObject or hit.HitObject:IsNull() then
        ---没有命中障碍物
        self.m_hasJustFired = true
        return false
    else
        ---射线命中了障碍物,在指定位置创建炮台
        local angle = Vector3.Angle(Vector3.Up, hit.HitNormal)
        if hit.HitNormal.Y < 0 or angle > 30 then
            ---命中的位置不能放置炮台
            self.m_hasJustFired = true
            return false
        end
        local fortFolder = world.FortFolder or world:CreateObject('FolderObject', 'FortFolder', world)
        local fort = world:CreateInstance(self.bulletName, self.bulletName .. '_' .. self.character.Name, fortFolder)
        if not fort then
            self.m_hasJustFired = true
            return false
        end
        world.S_Event.WeaponObjCreatedEvent:Fire(self.character, fort)
        fort.Color = Color(255, 255, 255, 0)
        local castResult = fort:ContactStaticTest(hit.HitPoint + Vector3.Up * 0.2, EulerDegree(0, 0, 0), Vector3.One)
        local canEquip = true
        for i, v in pairs(castResult.HitObjectAll) do
            if v.Block and not ParentPlayer(v) then
                canEquip = false
            end
        end
        if canEquip then
            ---可以放置炮台
            self:CreateFort(1001, fort, hit.HitPoint)
        else
            ---不可以放置
            fort:Destroy()
        end
    end
end

function AutoShootFort:CreateFort(_id, _fortObj, _pos)
    _fortObj.Color = Color(255, 255, 255, 255)
    _fortObj.Position = _pos
    self:DestroyFort()
    self.m_fort = FortBase:new(_id, _fortObj, self.character)
    self.m_fort.m_beHitEvent:Bind(self.m_fortBeHit)
    self.m_fort.m_onDestroyEvent:Bind(self.m_fortDestroy)
    self.m_fort:StartUpdate()
end

function AutoShootFort:MechanicalAimStop()
end

function AutoShootFort:MechanicalAimStart()
end

function AutoShootFort:Consume()
end

function AutoShootFort:MakeBulletShell()
end

function AutoShootFort:LoadMagazine()
end

---销毁当前的炮台
function AutoShootFort:DestroyFort()
    if self.m_fort and self.m_fort.id then
        self.m_fort:Destroy(self.character)
        self.m_fort = nil
    end
end

---@module GrenadeBase:GunBase 手雷
local GrenadeBase = class('GrenadeBase', GunBase)

function GrenadeBase:LaterInitialize()
    self:CreateCacheObjects()
    self.curveObjList = {}
    ---创建显示用的抛物线轨迹
    for i = 1, 20 do
        local obj = world:CreateInstance(self.bulletName, self.bulletName, self.character.Local)
        world.S_Event.WeaponObjCreatedEvent:Fire(self.character, obj)
        obj:SetActive(false)
        obj.IsStatic = true
        obj.Block = false
        obj.Scale = 0.3
        obj.Color = Color(255, 255, 255, 100)
        table.insert(self.curveObjList, obj)
    end
end

function GrenadeBase:EarlyInitialize()
    GunBase.EarlyInitialize(self)
    self.bombExplosion = EventMgr:new('BombExplosion', self)
end

---覆盖父类按下开火键的事件
function GrenadeBase:TryFireOneBullet()
    for i = 1, 20 do
        self.curveObjList[i]:SetActive(true)
    end
end

---鼠标按住后显示抛物线
function GrenadeBase:TryKeepFire()
    if self.m_fireWait > 0 then
        return
    end
    local dir = self:CalculateRayCastDirection() + Vector3.Up
    dir = dir.Normalized
    local curve =
        GenerateCurve(
        self.character.Avatar.Bone_Head.Position + self.character.Right * 0.1 + Vector3.Up * 0.2,
        self:GetBulletSpeed() * dir,
        20,
        0.05,
        self.config_gravityScale
    )
    for i = 1, 20 do
        self.curveObjList[i].Position = curve[i]
    end
end

---抬起开火键后尝试丢手雷
function GrenadeBase:TryPump()
    for i = 1, 20 do
        self.curveObjList[i]:SetActive(false)
    end
    GunBase.TryFireOneBullet(self)
end

function GrenadeBase:MakeBullet(_dir)
    _dir = _dir + Vector3.Up
    _dir = _dir.Normalized
    local speed = self:GetBulletSpeed()
    local rocket = world:CreateInstance(self.bulletName, self.bulletName, world)
    if not rocket then
        print('Rocket creation failed! Make sure rocket "' .. self.bulletName .. '" exist')
        return
    end
    rocket:SetActive(false)
    local interval = 1 / self.config_shootSpeed

    invoke(
        function()
            if self.gun then
                self.gun.Module.Origin.G_Bomb_Black_01:SetActive(true)
            end
        end,
        interval
    )
    invoke(
        function()
            rocket:SetActive(true)
            rocket.Position = self.character.Avatar.Bone_Head.Position + self.character.Right * 0.1 + Vector3.Up * 0.2
            rocket.GravityEnable = true
            rocket.GravityScale = self.config_gravityScale
            rocket.LinearVelocity = _dir * speed
            self.gun.Module.Origin.G_Bomb_Black_01:SetActive(false)
        end,
        0.4
    )
    invoke(
        function()
            if self.hitEffect then
                self:MakeHitEffect(rocket.Position)
                self:Damage({HitPoint = rocket.Position + Vector3.Up * 0.5})
                self.bombExplosion:Trigger(rocket.Position)
            end
            rocket:Destroy()
        end,
        self.config_damageResponseWaitTime
    )
    world.S_Event.WeaponObjCreatedEvent:Fire(self.character, rocket)
end

function GrenadeBase:Fire(delay, consume)
    local direction = self:CalculateRayCastDirection()
    if consume then
        self:Consume()
    end
    self:MakeBullet(direction.Normalized)
    self.m_hasJustFired = true
    return true
end

function GrenadeBase:Damage(_hit)
    ---爆炸没有爆头判定,后续可能根据距离爆炸中心店距离进行计算
    local totalWeight, hitBoneWeight = 0, 0
    for k, v in pairs(self.boneWeight) do
        totalWeight = totalWeight + v
    end
    local hitRes = {}
    local playersInRange, fortsInRange =
        GunBase.static.utility:GetEnemyByRange(
        self.character,
        self.config_isHitSelf,
        self.config_isHitFriend,
        self.config_explosionRange,
        180,
        _hit.HitPoint
    )
    for _, v in pairs(playersInRange) do
        ---表示此玩家在爆炸范围内,检查玩家和爆炸中心之间是否有阻挡
        local dis = (v.Position - _hit.HitPoint).Magnitude
        for k1, v1 in pairs(self.boneWeight) do
            local raycastAll = Physics:RaycastAll(_hit.HitPoint, v.Avatar[k1].Position, false)
            local isHit_ThisBone = true
            for k2, v2 in pairs(raycastAll.HitObjectAll) do
                if v2.Block and not ParentPlayer(v2) and v.CollisionGroup ~= 10 then
                    print('中间有东西阻挡了爆炸', v2, k1)
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
        local attenuation = GunBase.static.utility:GetAttenuationByGunId(2, self, dis)
        local damage = self.config_damage
        damage = damage + attenuation
        damage = damage <= 0 and 0 or damage
        damage = damage * rate
        if damage > 0 then
            local info = {
                Player = v,
                Damage = damage,
                HitPart = HitPartEnum.None,
                HitPos = _hit.HitPoint
            }
            table.insert(hitRes, info)
        end
    end
    ---检测炮台是否在范围内
    for i, v in pairs(fortsInRange) do
        local dis = (v.Position - _hit.HitPoint).Magnitude
        local attenuation = GunBase.static.utility:GetAttenuationByGunId(2, self, dis)
        local damage = self.config_damage
        damage = damage + attenuation
        damage = damage <= 0 and 0 or damage
        if damage > 0 then
            local info = {
                Player = v.Owner.Value,
                Damage = damage,
                HitPart = HitPartEnum.Fort,
                HitPos = _hit.HitPoint
            }
            table.insert(hitRes, info)
        end
    end
    ---伤害判定
    for i, v in pairs(hitRes) do
        self.successfullyHit:Trigger({Position = v.HitPos, Player = v.Player, Damage = v.Damage, HitPart = v.HitPart})
        PlayerGunMgr:FireGunDamage(localPlayer, v.Player, self.gun_Id, v.Damage, v.HitPart)
    end
end

function GrenadeBase:MechanicalAimStart()
end

function GrenadeBase:MechanicalAimStop()
end

---@module SmokeBombBase:GrenadeBase 烟雾弹
local SmokeBombBase = class('SmokeBombBase', GrenadeBase)

function SmokeBombBase:Damage(_hit)
end

function SmokeBombBase:MakeHitEffect(_endPos)
    local eff =
        GunBase.static.utility:UseCacheObject(
        self,
        self.hitEffect,
        true,
        {Position = _endPos},
        nil,
        ObjectTypeEnum.HitEff
    )
    eff.BaseParticle.Duration = 10
    eff.BaseParticle.LifeTime = Vector2(10, 10)
end

function GunsCollection:Init()
    _G.SniperRifleBase = SniperRifleBase
    _G.AssaultRifleBase = AssaultRifleBase
    _G.RocketLauncherBase = RocketLauncherBase
    _G.GrenadeLauncherBase = GrenadeLauncherBase
    _G.ShotGunBase = ShotGunBase
    _G.SubMachineGunBase = SubMachineGunBase
    _G.PistolBase = PistolBase
    _G.TrailingGunBase = TrailingGunBase
    _G.GatlingBase = GatlingBase
    _G.BarrettBase = BarrettBase
    _G.RPGBase = RPGBase
    _G.MeleeBase = MeleeBase
    _G.FlameLauncher = FlameLauncher
    _G.ViscoelasticLauncher = ViscoelasticLauncher
    _G.MedicalGun = MedicalGun
    _G.AutoShootFort = AutoShootFort
    _G.GrenadeBase = GrenadeBase
    _G.SmokeBombBase = SmokeBombBase
end

return GunsCollection:Init()
