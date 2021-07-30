---@module WeaponAmmoBase 枪械模块：枪械子弹基类
---@copyright Lilith Games, Avatar Team
---@author Sharif Ma
local WeaponAmmoBase = class('WeaponAmmoBase')

---WeaponAmmoBase类的构造函数
---@param _id number 子弹ID
---@param _count number 拾取的数量
---@param _character PlayerInstance 拾取的玩家
function WeaponAmmoBase:initialize(_id, _count, _character)
    self.id = _id
    self.order = GunConfig.AmmoConfig[self.id].Order
    self.pickSound = GunConfig.AmmoConfig[self.id].PickSound
    self.count = _count
    self.character = _character
    self:PickSound()
end

---玩家拾取一定数量的子弹
function WeaponAmmoBase:PlayerPickAmmo(_weaponAmmo, _count)
    if _weaponAmmo then
        if _count >= _weaponAmmo.Count.Value then
            _count = _weaponAmmo.Count.Value
            world.S_Event.DestroyAmmoEvent:Fire(_weaponAmmo)
        else
            _weaponAmmo.Count.Value = _weaponAmmo.Count.Value - _count
        end
    end
    self.count = self.count + _count
    self:PickSound()
end

---玩家丢弃一定数量的子弹
---@param _count number 丢弃子弹的数量
function WeaponAmmoBase:PlayerDropAmmo(_count)
    local isDroppedAll = false
    if self.count <= 0 then
        return
    end
    if _count >= self.count then
        ---丢弃了所有的子弹
        _count = self.count
        world.S_Event.CreateAmmoEvent:Fire(self.id, _count, self.character.Position)
        world.S_Event.PlayerPickAmmoEvent:Fire(localPlayer, {[self.id] = -_count})
        isDroppedAll = true
    else
        ---丢弃部分子弹
        world.S_Event.CreateAmmoEvent:Fire(self.id, _count, self.character.Position)
        world.S_Event.PlayerPickAmmoEvent:Fire(localPlayer, {[self.id] = -_count})
    end
    self.count = self.count - _count
    return isDroppedAll
end

---玩家换弹消耗一定数量的子弹
---@param _count number 消耗子弹的数量
---@return number 返回真正消耗的子弹数量
function WeaponAmmoBase:PlayerConsumeAmmo(_count)
    if self.count <= 0 then
        self.count = 0
        return 0
    end
    if _count >= self.count then
        _count = self.count
    end
    self.count = self.count - _count
    return _count
end

---直接设置子弹数量为指定值
function WeaponAmmoBase:SetCount(_count)
    self.count = _count
end

---析构函数
function WeaponAmmoBase:Destructor()
    self.count = nil
    self.id = nil
    ClearTable(self)
    self = nil
end

function WeaponAmmoBase:PickSound()
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

return WeaponAmmoBase
