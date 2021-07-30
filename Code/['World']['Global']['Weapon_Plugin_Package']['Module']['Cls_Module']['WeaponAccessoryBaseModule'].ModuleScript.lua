---@module WeaponAccessoryBase 枪械模块：枪械配件基类
---@copyright Lilith Games, Avatar Team
---@author Sharif Ma
local WeaponAccessoryBase = class('WeaponAccessoryBase')

---WeaponAccessoryBase类的构造函数
---@param _weaponAccessory Accessory
function WeaponAccessoryBase:initialize(_weaponAccessory)
    self.weaponAccessory = _weaponAccessory
    self.id = _weaponAccessory.ID.Value
    self.uuid = _weaponAccessory.UUID.Value
    ---配置初始化
    GunBase.static.utility:InitGunAccessoryConfig(self)

    ---@type GunBase 此配件当前装备的枪械
    self.m_equippedWeapon = nil
    _weaponAccessory.Player.Value = localPlayer
    self:PickSound()
end

function WeaponAccessoryBase:Update()
end

---玩家装备此配件到指定的枪上调用
---@param _gun GunBase
function WeaponAccessoryBase:EquipToWeapon(_gun)
    self.m_equippedWeapon = _gun
end

---玩家将此配件从指定的枪上移除调用
function WeaponAccessoryBase:UnEquipFromWeapon()
    self.m_equippedWeapon = nil
end

---析构函数
function WeaponAccessoryBase:Destructor()
    self.weaponAccessory.Player.Value = nil
    ClearTable(self)
    self = nil
end

function WeaponAccessoryBase:PickSound()
    local audio = world:CreateInstance('AudioSource', 'Audio_' .. self.pickSound, world.CurrentCamera)
    audio.LocalPosition = Vector3.Zero
    audio.SoundClip = ResourceManager.GetSoundClip('WeaponPackage/Audio/' .. self.pickSound)
    audio.Volume = 60
    audio.MaxDistance = 30
    audio.MinDistance = 30
    audio.Loop = false
    audio.Doppler = 0
    audio:Play()
    invoke(
        function()
            if audio then
                audio:Destroy()
            end
        end,
        2
    )
end

return WeaponAccessoryBase
