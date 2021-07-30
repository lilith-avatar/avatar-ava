---@module PlayerAnimation 枪械模块：玩家的动画控制类
---@copyright Lilith Games, Avatar Team
---@author Sharif Ma
local PlayerAnimation = class('PlayerAnimation')

---PlayerAnimation类的构造函数
---@param _gun GunBase
function PlayerAnimation:initialize(_gun)
    self.gun = _gun
    self.id = _gun.animationId
    self.player = _gun.character
    ---玩家的右肩骨骼点
    self.bone_R_UpperArm = _gun.character.Avatar.Bone_R_UpperArm
    ---动画配置初始化
    GunBase.static.utility:InitGunAnimationConfig(self)
    ---设置动画的播放层级
    self.player.Avatar:SetBlendSubtree(Enum.BodyPart.UpperBody, self.animationTree)
    self.shoulderRayMinDistance = GunConfig.GlobalConfig.ShoulderRayMinDistance
    ---当前是否处于不可射击状态
    self.noShootingState = false
end

function PlayerAnimation:Update(_dt)
    ---奔跑状态下进行持枪状态,站立状态下进行瞄准
    if self.player.State == Enum.CharacterState.Walk or self.noShootingState then
        self.player:StopAim()
    else
        self.player:Aim(world.CurrentCamera.Rotation.x * -1, 2)
    end
    ---是否靠近一个东西导致不可开枪检测
    if self.bone_R_UpperArm then
        local raycastResults =
            Physics:RaycastAll(
            self.bone_R_UpperArm.Position,
            self.bone_R_UpperArm.Position + self.player.Forward * self.shoulderRayMinDistance,
            false
        )
        local state = false
        for k, v in pairs(raycastResults.HitObjectAll) do
            if v.Block and not ParentPlayer(v) and v.CollisionGroup ~= 10 then
                ---前方有阻挡
                state = true
            end
        end
        self.noShootingState = state
    end
end

function PlayerAnimation:FixUpdate(_dt)
end

---装备武器的动作
function PlayerAnimation:EquipWeapon()
    if self.equip and #self.equip > 0 then
        local speed = self.equip[2] and tonumber(self.equip[2]) or 1
        self.player.Avatar:PlayAnimation(self.equip[1], self.animationTree, 1, 0, true, false, speed)
    else
        self.player:Equip(1)
    end
end

---换子弹的动作
function PlayerAnimation:MagazineLoadStarted()
    if self.magazineLoadStarted and #self.magazineLoadStarted > 0 then
        local speed = self.magazineLoadStarted[2] and tonumber(self.magazineLoadStarted[2]) or 1
        self.player.Avatar:PlayAnimation(self.magazineLoadStarted[1], self.animationTree, 1, 0, true, false, speed)
    else
        self.player:Reload(1)
    end
end

---拉枪栓结束
function PlayerAnimation:PumpStopped()
    if self.pumpStopped and #self.pumpStopped > 0 then
        local speed = self.pumpStopped[2] and tonumber(self.pumpStopped[2]) or 1
        self.player.Avatar:PlayAnimation(self.pumpStopped[1], self.animationTree, 1, 0, true, false, speed)
    else
    end
end

---开火动作
function PlayerAnimation:Fired()
    if self.noShootingState then
        return
    end
    if self.fired and #self.fired > 0 then
        local speed = self.fired[2] and tonumber(self.fired[2]) or 1
        self.player.Avatar:PlayAnimation(self.fired[1], self.animationTree, 1, 0, true, false, speed)
    else
        self.player:Attack(1, 1)
    end
end

---空仓动作
function PlayerAnimation:EmptyFire()
    if self.emptyFire and #self.emptyFire > 0 then
        local speed = self.emptyFire[2] and tonumber(self.emptyFire[2]) or 1
        self.player.Avatar:PlayAnimation(self.emptyFire[1], self.animationTree, 1, 0, true, false, speed)
    else
    end
end

---拉枪栓动作
function PlayerAnimation:PumpStarted()
    if self.pumpStarted and #self.pumpStarted > 0 then
        local speed = self.pumpStarted[2] and tonumber(self.pumpStarted[2]) or 1
        self.player.Avatar:PlayAnimation(self.pumpStarted[1], self.animationTree, 1, 0, true, false, speed)
    else
    end
end
---开火后
function PlayerAnimation:FireStopped()
    if self.fireStopped and #self.fireStopped > 0 then
        local speed = self.fireStopped[2] and tonumber(self.fireStopped[2]) or 1
        self.player.Avatar:PlayAnimation(self.fireStopped[1], self.animationTree, 1, 0, true, false, speed)
    else
    end
end

function PlayerAnimation:Destructor()
    ClearTable(self)
    self = nil
end

return PlayerAnimation
