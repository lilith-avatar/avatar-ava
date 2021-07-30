--- @module PlayerOccLogic
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local PlayerOccLogic, this = ModuleUtil.New('PlayerOccLogic', ClientBase)

function PlayerOccLogic:Init()
    ---@type FloatValueObject
    self.speedScale = localPlayer.SpeedScale
    ---重生时间
    self.rebornTime = 3
    localPlayer.OnSpawn:Connect(
        function()
            self:Reborn()
        end
    )
    ---当前角色是否无敌
    self.invincible = false
    self.invincibleCover = world:CreateInstance('InvincibleCover', 'InvincibleCover', localPlayer)
    self.invincibleCover.LocalPosition = Vector3.Up * 0.8
    self.invincibleCover:SetActive(false)
    self:ChangeOcc(Config.GlobalConfig.DefaultGunId)
end

--- Update
--- @param dt number delta time
function PlayerOccLogic:Update(dt, tt)
end

function PlayerOccLogic:ChangeOccEventHandler(_occ)
    self:RemoveCurOcc()
    self:ChangeOcc(_occ)
end

function PlayerOccLogic:RemoveCurOcc()
    local gun
    if PlayerGunMgr.mainGun then
        gun = PlayerGunMgr.mainGun.gun
        PlayerGunMgr:OnUnEquipWeaponEvent(PlayerGunMgr.mainGun)
        gun:Destroy()
    end
    if PlayerGunMgr.deputyGun then
        gun = PlayerGunMgr.deputyGun.gun
        PlayerGunMgr:OnUnEquipWeaponEvent(PlayerGunMgr.deputyGun)
        gun:Destroy()
    end
    if PlayerGunMgr.miniGun then
        gun = PlayerGunMgr.miniGun.gun
        PlayerGunMgr:OnUnEquipWeaponEvent(PlayerGunMgr.miniGun)
        gun:Destroy()
    end
    if PlayerGunMgr.prop1 then
        gun = PlayerGunMgr.prop1.gun
        PlayerGunMgr:OnUnEquipWeaponEvent(PlayerGunMgr.prop1)
        gun:Destroy()
    end
    if PlayerGunMgr.prop2 then
        gun = PlayerGunMgr.prop2.gun
        PlayerGunMgr:OnUnEquipWeaponEvent(PlayerGunMgr.prop2)
        gun:Destroy()
    end
    localPlayer.MaxHealth = 100
    self.speedScale.Value = 1

    for i, v in pairs(PlayerGunMgr.hadAmmoList) do
        v:Destructor()
        PlayerGunMgr.hadAmmoList[i] = nil
    end
end

function PlayerOccLogic:ChangeOcc(_occ)
    local occConfig = Config.Occupation[_occ]
    localPlayer.MaxHealth = occConfig.MaxHp
    localPlayer.Health = occConfig.MaxHp
    self.speedScale.Value = occConfig.Speed
    self.rebornTime = occConfig.ReBornTime
    localPlayer.RespawnTime = self.rebornTime
    local weapon1Id = occConfig.Weapon_1
    ---local weapon2Id = occConfig.Weapon_2
    ---local weapon3Id = occConfig.Weapon_3
    PlayerGunMgr:PickWeapon(self:CreateWeapon(weapon1Id, 99999999))
    ---PlayerGunMgr:PickWeapon(self:CreateWeapon(weapon2Id, 1000))
    ---PlayerGunMgr:PickWeapon(self:CreateWeapon(weapon3Id, 1000))
    ---local prop1 = occConfig.Prop1
    ---local prop2 = occConfig.Prop2
    ---PlayerGunMgr:PickWeapon(self:CreateWeapon(prop1, 2))
    ---PlayerGunMgr:PickWeapon(self:CreateWeapon(prop2, 2))
end

function PlayerOccLogic:CreateWeapon(_id, _ammoCount)
    if not GunConfig.GunConfig[_id] then
        return
    end
    local name = GunConfig.GunConfig[_id].Name
    ---@type Accessory
    local weaponObj = world:CreateInstance(name, name, localPlayer)
    weaponObj:SetParentTo(localPlayer.Avatar[weaponObj.Bone], weaponObj.AttachPos, weaponObj.AttachRot)
    weaponObj.Module.IsStatic = true
    weaponObj.Module.GravityEnable = false
    weaponObj.Module.Block = false
    weaponObj.Pickable = false
    weaponObj.GravityEnable = false
    weaponObj.CollisionGroup = 3
    weaponObj.IsStatic = true
    weaponObj.Collide = pickRegion
    weaponObj.Block = false
    local uuid = UUID()
    world:CreateObject('StringValueObject', 'UUID', weaponObj).Value = uuid
    world:CreateObject('IntValueObject', 'ID', weaponObj).Value = _id
    world:CreateObject('IntValueObject', 'AmmoLeft', weaponObj).Value = _ammoCount
    world:CreateObject('ObjRefValueObject', 'Player', weaponObj)
    return weaponObj
end

function PlayerOccLogic:CreateWeaponAmmo(_id, _count)
    if _count <= 0 then
        return
    end
    if not GunConfig.AmmoConfig[_id] then
        return
    end
    local name = GunConfig.AmmoConfig[_id].Name
    local model = GunConfig.AmmoConfig[_id].Model
    local ammoObj = world:CreateInstance(model, name, world)
    ammoObj:SetActive(false)
    ammoObj.Pickable = false
    ammoObj.CollisionGroup = 3
    ammoObj.Block = false
    ammoObj.IsStatic = true
    ammoObj.GravityEnable = false
    ammoObj.Module.IsStatic = true
    ammoObj.Module.GravityEnable = false
    ammoObj.Module.Block = false
    local uuid = WeaponUUID()
    world:CreateObject('StringValueObject', 'UUID', ammoObj).Value = uuid
    world:CreateObject('IntValueObject', 'ID', ammoObj).Value = _id
    world:CreateObject('IntValueObject', 'Count', ammoObj).Value = _count
    world:CreateObject('ObjRefValueObject', 'Player', ammoObj)
    return ammoObj
end

---玩家重生后的无敌设定
function PlayerOccLogic:Reborn()
    self:Invincible(true)
end

---无敌状态设定
function PlayerOccLogic:Invincible(_bool)
    if
        localPlayer.PlayerState.Value == Const.PlayerStateEnum.OnGame or
            localPlayer.PlayerState.Value == Const.PlayerStateEnum.OnOver
     then
        self.invincibleCover:SetActive(_bool)
        self.invincible = _bool
    end
end

return PlayerOccLogic
