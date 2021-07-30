---@module GunAnimation 枪械模块：玩家的动画控制类
---@copyright Lilith Games, Avatar Team
---@author Sharif Ma
local GunAnimation = class('GunAnimation')

---GunAnimation类的构造函数
---@param _gun GunBase
function GunAnimation:initialize(_gun)
    self.gun = _gun
    self.id = _gun.animationId
    self.player = _gun.character
    ---玩家的右肩骨骼点
    self.bone_R_UpperArm = _gun.character.Avatar.Bone_R_UpperArm
    ---玩家的左肩骨骼点
    self.bone_L_UpperArm = _gun.character.Avatar.Bone_L_UpperArm
    self.config = GunConfig.GunAnimationConfig[self.id] or {}
    self.shoulderRayMinDistance = GunConfig.GlobalConfig.ShoulderRayMinDistance
    ---当前是否处于不可射击状态
    self.noShootingState = false
    self.layer = 4
    for i, v in pairs(self.config) do
        local nameList = StringSplit(v.AnimationName, ':', false)
        local weight, transitionDuration, interrupt, loop, scale =
            v.Weight,
            v.TransitionDuration,
            v.CoverPlay,
            v.IsLoop,
            v.Speed
        local function PlayerAnimation()
            if #nameList == 0 then
                return
            end

            local name = nameList[RandomNum(1, #nameList)]

            if i == 'fired' and not self.noShootingState then
                self:PlayAnimation(name, self.layer, weight, transitionDuration, interrupt, loop, scale)
            elseif i ~= 'fired' then
                self:PlayAnimation(name, self.layer, weight, transitionDuration, interrupt, loop, scale)
            end
        end
        if self.gun[i] then
            self.gun[i]:Bind(PlayerAnimation)
        end
        local function StopAnimation()
            if #nameList == 0 then
                return
            end
            for i1, v1 in pairs(nameList) do
                self:StopAnimation(v1, self.layer)
            end
        end
        self.gun.withDrawWeapon:Bind(StopAnimation)
    end
end

function GunAnimation:Update(_dt)
    ---加速跑状态下收枪,其他状态正常持枪
    if PlayerBehavior.BehJudgeTab.isQuickly then
        ---加速状态下
        self.player:StopAim()
    else
        if self.noShootingState then
            self.player:StopAim()
        else
            self.player:Aim(world.CurrentCamera.Rotation.x * -1, 2)
        end
    end
    ---是否靠近一个东西导致不可开枪检测
    if self.bone_R_UpperArm and self.gun.config_banShoot then
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
    if self.bone_L_UpperArm and self.gun.config_banShoot then
        local raycastResults =
            Physics:RaycastAll(
            self.bone_L_UpperArm.Position,
            self.bone_L_UpperArm.Position + self.player.Forward * self.shoulderRayMinDistance,
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

function GunAnimation:FixUpdate(_dt)
end

function GunAnimation:PlayAnimation(_name, _layer, _weight, _transitionDuration, _interrupt, _loop, _scale)
    if self.player then
        self.player.Avatar:PlayAnimation(_name, _layer, _weight, _transitionDuration, _interrupt, _loop, _scale)
    --[[wait()
        if(self.player) then
            self.player.Avatar:PlayAnimation(_name, _layer, _weight, _transitionDuration, _interrupt, _loop, _scale)
        end]]
    end
end

function GunAnimation:StopAnimation(_name, _layer)
    if self.player then
        self.player.Avatar:StopAnimation(_name, _layer)
    end
end

function GunAnimation:SetLayer(_layer)
    self.layer = _layer
end

function GunAnimation:Destructor()
    ClearTable(self)
    self = nil
end

return GunAnimation
