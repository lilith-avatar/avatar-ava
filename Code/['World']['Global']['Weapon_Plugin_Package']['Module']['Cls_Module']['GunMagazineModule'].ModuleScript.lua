---@module GunMagazine 枪械模块：弹夹基类
---@copyright Lilith Games, Avatar Team
---@author Sharif Ma
local GunMagazine = class('GunMagazine')

---GunMagazine类的构造函数
---@param _gun GunBase
function GunMagazine:initialize(_gun)
    ---弹夹装载的武器
    self.gun = _gun
    ---弹夹的id
    self.id = _gun.magazineUsed
    ---弹夹配置初始化
    GunBase.static.utility:InitGunMagazineConfig(self)

    ---弹夹剩余子弹数量
    self.m_leftAmmo = _gun.gun.AmmoLeft.Value
    ---弹夹中多余的子弹
    local moveAmmo = self.m_leftAmmo - self.maxNum
    if moveAmmo > 0 then
        self.m_leftAmmo = self.maxNum
    else
        moveAmmo = 0
    end

    if PlayerGunMgr.hadAmmoList[self.matchAmmo] then
        ---这个子弹在玩家身上已经有了
        PlayerGunMgr.hadAmmoList[self.matchAmmo]:PlayerPickAmmo(nil, moveAmmo)
    else
        ---这个子弹是玩家首次拾取的
        local ammoObj = WeaponAmmoBase:new(self.matchAmmo, moveAmmo, localPlayer)
        PlayerGunMgr.hadAmmoList[self.matchAmmo] = ammoObj
    end

    ---@type WeaponAmmoBase 弹夹中子弹类
    self.m_ammoInventory = PlayerGunMgr.hadAmmoList[self.matchAmmo]
    ---弹药的负载百分比
    self.m_loadPercentage = 100
    ---枪满子弹了吗
    self.m_isFullyLoaded = false
    ---弹夹空了么
    self.m_isEmptyLoaded = false
    ---枪里可以装更多子弹吗
    self.m_canLoad = false

    self.m_loadTimeRateTable = {}
    self.m_loadTimeRateScale = 1
    self.m_maxAmmoRateTable = {}
    self.m_maxAmmoRateScale = 0

    ---上一帧弹夹中可以装的子弹数量
    self.preMaxAmmo = self.maxNum

    self:Update()
end

---检查当前弹夹是否装满子弹
function GunMagazine:UpdateFullyLoaded()
    self.m_isFullyLoaded = self.m_leftAmmo >= self:GetMaxAmmo()
    return self.m_isFullyLoaded
end

---检查当前弹夹中子弹是否空了
function GunMagazine:UpdateEmptyLoaded()
    self.m_isEmptyLoaded = self.m_leftAmmo <= 0
    return self.m_isEmptyLoaded
end

---检查当前是否可以装弹
function GunMagazine:UpdateCanLoad()
    self.m_canLoad = not self.m_isFullyLoaded and self.m_ammoInventory and self.m_ammoInventory.count > 0
    return self.m_canLoad
end

---更新当前的子弹负载百分比
function GunMagazine:UpdateLoadPercentage()
    self.m_loadPercentage = math.floor(self.m_leftAmmo / self:GetMaxAmmo() * 100)
    return self.m_loadPercentage
end

---消耗一颗子弹
---@return function
function GunMagazine:Consume()
    local function OverrideConsume()
        if self.m_leftAmmo > 0 then
            self.m_leftAmmo = self.m_leftAmmo - 1
            world.S_Event.PlayerPickAmmoEvent:Fire(localPlayer, {[self.matchAmmo] = -1})
            return true
        else
            return false
        end
    end
    return OverrideConsume
end

---装一发子弹
function GunMagazine:LoadOneBullet()
    if self.m_canLoad then
        self.m_leftAmmo = self.m_leftAmmo + 1
        self.m_ammoInventory:PlayerConsumeAmmo(1)
    end
    ---self:Update()
end

---装整个弹夹
function GunMagazine:LoadMagazine()
    if self.m_canLoad then
        local addition = self:GetMaxAmmo() - self.m_leftAmmo
        addition = self.m_ammoInventory:PlayerConsumeAmmo(addition)
        self.m_leftAmmo = self.m_leftAmmo + addition
        self:UpdateFullyLoaded()
    end
    ---self:Update()
end

---枪械卸载/更换后,需要将枪械的子弹更新在配件的节点下
---@param _isBackToBulletInventory boolean 枪械的子弹是否回退到子弹仓库中
function GunMagazine:RecordingBulletsLeft(_isBackToBulletInventory)
    if _isBackToBulletInventory and self.m_ammoInventory then
        self.m_ammoInventory.count = self.m_leftAmmo + self.m_ammoInventory.count
        self.m_leftAmmo = 0
    end
    self:Update()
end

---更新函数
function GunMagazine:Update()
    if self.preMaxAmmo > self:GetMaxAmmo() then
        ---这一帧卸下了扩容弹夹,需要强行减少当前的子弹
        if self:GetMaxAmmo() < self.m_leftAmmo then
            local deltaAmmo = self.m_leftAmmo - self:GetMaxAmmo()
            self.m_leftAmmo = self.m_leftAmmo - deltaAmmo
            self.m_ammoInventory.count = self.m_ammoInventory.count + deltaAmmo
        end
    end
    self.preMaxAmmo = self:GetMaxAmmo()
    self:UpdateFullyLoaded()
    self:UpdateEmptyLoaded()
    self:UpdateCanLoad()
    self:UpdateLoadPercentage()
    ---将当前的剩余子弹更新到场景中的节点上
    self.m_ammoInventory = PlayerGunMgr.hadAmmoList[self.matchAmmo]
    self.gun.gun.AmmoLeft.Value = self.m_leftAmmo
    self.m_loadTimeRateTable = {}
    self.m_maxAmmoRateTable = {}
    for k, v in pairs(self.gun.m_weaponAccessoryList) do
        self.m_loadTimeRateTable[k] = v.magazineLoadTimeRate
        self.m_maxAmmoRateTable[k] = v.maxAmmoRate[self.gun.gun_Id]
    end
    self:RefreshScales()
end

function GunMagazine:RefreshScales()
    local factor = 1
    factor = 1
    for k, v in pairs(self.m_loadTimeRateTable) do
        factor = factor * v
    end
    self.m_loadTimeRateScale = factor
    factor = 0
    for k, v in pairs(self.m_maxAmmoRateTable) do
        factor = factor + v
    end
    self.m_maxAmmoRateScale = factor
end

function GunMagazine:GetLoadTime()
    return self.loadTime * self.m_loadTimeRateScale
end

function GunMagazine:GetMaxAmmo()
    return self.m_maxAmmoRateScale + self.maxNum > 0 and self.m_maxAmmoRateScale + self.maxNum or 1
end

function GunMagazine:Destructor()
    ClearTable(self)
    self = nil
end

return GunMagazine
