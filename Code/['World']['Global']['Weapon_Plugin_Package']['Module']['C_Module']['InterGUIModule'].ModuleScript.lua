--- @module InterGUI 枪械模块：内部UI
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local InterGUI, this = {}, nil
local _SAY_ = 0.81

local accName = {'muzzle', 'grip', 'magazine', 'butt', 'sight'}
local function Sort(_item1, _item2)
    if _item1.IsMarked and not _item2.IsMarked then
        return true
    elseif not _item1.IsMarked and _item2.IsMarked then
        return false
    else
        if _item1.Order >= _item2.Order then
            return false
        else
            return true
        end
    end
end

---检查附近的枪是否需要标记
local function CheckNearByWeapon(_list)
    for k, v in pairs(_list) do
        if v.GunId then
            local id = v.GunId
            local canBeEquipPosition = GunConfig.GunConfig[id].CanBeEquipPosition
            if canBeEquipPosition == CanBeEquipPositionEnum.MainOrDeputy then
                ---此武器装备在主武器或者副武器位置
                if not PlayerGunMgr.mainGun or not PlayerGunMgr.deputyGun then
                    _list[k].IsMarked = true
                else
                    _list[k].IsMarked = false
                end
            elseif canBeEquipPosition == CanBeEquipPositionEnum.Mini then
                if not PlayerGunMgr.miniGun then
                    _list[k].IsMarked = true
                else
                    _list[k].IsMarked = false
                end
            end
        end
    end
end

---监测附近的配件是否需要标记
local function CheckNearByAccessory(_list)
    for k, v in pairs(_list) do
        if v.AccId then
            local isMarked = false
            local id = v.AccId
            local location = GunConfig.WeaponAccessoryConfig[id].Location
            local order = GunConfig.WeaponAccessoryConfig[id].Order
            local key = accName[location]
            if PlayerGunMgr.mainGun then
                local mainGunId = PlayerGunMgr.mainGun.gun_Id
                if GunBase.static.utility:CheckAcc2Weapon(id, mainGunId) then
                    ---主枪能装备这个配件
                    local curAcc = PlayerGunMgr.mainGun.m_weaponAccessoryList[key]
                    if not curAcc then
                        isMarked = true
                    else
                        ---主枪上有这个配件,需要判断这两个配件的优先级
                        local curAccOrder = curAcc.order
                        isMarked = curAccOrder > order
                    end
                else
                    isMarked = false
                end
            end
            if PlayerGunMgr.deputyGun then
                local deputyGunId = PlayerGunMgr.deputyGun.gun_Id
                if GunBase.static.utility:CheckAcc2Weapon(id, deputyGunId) then
                    ---副枪能装备这个配件
                    local curAcc = PlayerGunMgr.deputyGun.m_weaponAccessoryList[key]
                    if not curAcc then
                        isMarked = true
                    else
                        ---副枪上有这个配件,需要判断这两个配件的优先级
                        local curAccOrder = curAcc.order
                        isMarked = curAccOrder > order
                    end
                else
                    isMarked = false
                end
            end
            if PlayerGunMgr.miniGun then
                local miniGunId = PlayerGunMgr.miniGun.gun_Id
                if GunBase.static.utility:CheckAcc2Weapon(id, miniGunId) then
                    ---主枪能装备这个配件
                    local curAcc = PlayerGunMgr.miniGun.m_weaponAccessoryList[key]
                    if not curAcc then
                        isMarked = true
                    else
                        ---主枪上有这个配件,需要判断这两个配件的优先级
                        local curAccOrder = curAcc.order
                        isMarked = curAccOrder > order
                    end
                else
                    isMarked = false
                end
            end
            _list[k].IsMarked = isMarked
        end
    end
end

---监测附近的子弹是否需要标记
local function CheckNearByAmmo(_list)
    for k, v in pairs(_list) do
        if v.AmmoId then
            local id = v.AmmoId
            local isMarked = false
            local isMatched = false
            if PlayerGunMgr.mainGun then
                local matchAmmo = GunBase.static.utility:GetWeaponAmmoId(PlayerGunMgr.mainGun.gun_Id)
                if matchAmmo == id then
                    isMatched = true
                end
            end
            if PlayerGunMgr.deputyGun then
                local matchAmmo = GunBase.static.utility:GetWeaponAmmoId(PlayerGunMgr.deputyGun.gun_Id)
                if matchAmmo == id then
                    isMatched = true
                end
            end
            if PlayerGunMgr.miniGun then
                local matchAmmo = GunBase.static.utility:GetWeaponAmmoId(PlayerGunMgr.miniGun.gun_Id)
                if matchAmmo == id then
                    isMatched = true
                end
            end
            if isMatched then
                local maxNum = GunConfig.AmmoConfig[id].MarkedMaxNum
                local curNum = PlayerGunMgr.hadAmmoList[id] and PlayerGunMgr.hadAmmoList[id].count or 0
                if curNum < maxNum then
                    isMarked = true
                end
            end
            _list[k].IsMarked = isMarked
        end
    end
end

---使用一个UI
local function UseNearByUI()
    local canUsedUI = nil
    for k, v in pairs(InterGUI.nearByUi_Cache) do
        if not v then
            canUsedUI = k
        end
    end
    if canUsedUI then
        canUsedUI:SetActive(true)
    else
        canUsedUI = world:CreateInstance('Item_NearBy', 'Item_NearBy', InterGUI.interGUI.BG.VP)
    end
    InterGUI.nearByUi_Cache[canUsedUI] = true
    return canUsedUI
end

---回收一个UI
local function RecoveryUI(_ui)
    if InterGUI.nearByUi_Cache[_ui] == nil then
        _ui:Destroy()
    else
        _ui.PickBtn.OnClick:Clear()
        _ui:SetActive(false)
        _ui.ItemName.Text = ''
        _ui.CountTxt.Text = ''
        _ui.MarkedImage:SetActive(false)
        InterGUI.nearByUi_Cache[_ui] = false
    end
end

---模块初始化函数
function InterGUI:Init()
    this = self
    self:InitListeners()
    ---@type UiScreenUiObject
    self.interGUI = world:CreateInstance('InterGUI', 'InterGUI', localPlayer.Local)
    self.interGUI:SetActive(false)
    ---缓存附近的武器对象的列表
    self.weaponsNearByList = {}
    ---缓存显示在UI上的图标列表
    self.weaponUiList = {}
    ---缓存创建的UI,Key - 当前的UI, Value - 是否正在被使用
    self.nearByUi_Cache = {}
end

function InterGUI:InitListeners()
    LinkConnects(localPlayer.C_Event, InterGUI, this)
end

---Update函数
---@param dt number delta time 每帧时间
---@param tt number total time 总时间
function InterGUI:Update(dt, tt)
end

---玩家靠近一把枪的事件
---@param _gun Accessory 靠近的枪械
function InterGUI:PlayerNearWeaponEventHandler(_gun)
    if self.weaponUiList[_gun] then
        return
    end
    if _gun.Player.Value then
        return
    end
    local ui = UseNearByUI()
    local id = _gun.ID.Value
    local order = GunConfig.GunConfig[id].Order
    ui.ItemIcon.Texture = ResourceManager.GetTexture('WeaponPackage/UI/BagPackGUI/' .. GunConfig.GunConfig[id].Icon)
    self.weaponUiList[_gun] = {
        UI = ui,
        Order = order,
        IsMarked = false,
        GunId = id
    }
    ui.PickBtn.OnClick:Connect(
        function()
            self:PickWeaponBtnClick(_gun)
        end
    )
    ui.ItemName.Text = _gun.Name
    ui.CountTxt.Text = ''
    self:RefreshWeaponList()
end

---玩家远离一把枪的事件
---@param _gun Accessory 远离的枪械
function InterGUI:PlayerFarWeaponEventHandler(_gun)
    if not self.weaponUiList[_gun] then
        return
    end
    local ui = self.weaponUiList[_gun].UI
    if ui == nil then
        self:RefreshWeaponList()
        return
    end
    RecoveryUI(ui)
    self.weaponUiList[_gun] = nil
    self:RefreshWeaponList()
end

---玩家靠近一个武器配件的事件
function InterGUI:PlayerNearWeaponAccessoryEventHandler(_gunAccessory)
    if self.weaponUiList[_gunAccessory] then
        return
    end
    if _gunAccessory.Player.Value then
        return
    end
    local id = _gunAccessory.ID.Value
    local order = GunConfig.WeaponAccessoryConfig[id].Order
    local ui = UseNearByUI()
    ui.ItemIcon.Texture =
        ResourceManager.GetTexture('WeaponPackage/UI/BagPackGUI/' .. GunConfig.WeaponAccessoryConfig[id].Icon)
    self.weaponUiList[_gunAccessory] = {
        UI = ui,
        Order = order,
        IsMarked = false,
        AccId = id
    }
    ui.PickBtn.OnClick:Connect(
        function()
            self:PickWeaponAccessoryBtnClick(_gunAccessory)
        end
    )
    ui.ItemName.Text = GunConfig.WeaponAccessoryConfig[_gunAccessory.ID.Value].Name
    ui.CountTxt.Text = ''
    self:RefreshWeaponList()
end

---玩家远离一个武器配件的事件
function InterGUI:PlayerFarWeaponAccessoryEventHandler(_gunAccessory)
    if not self.weaponUiList[_gunAccessory] then
        return
    end
    local ui = self.weaponUiList[_gunAccessory].UI
    if ui == nil then
        return
    end
    RecoveryUI(ui)
    self.weaponUiList[_gunAccessory] = nil
    self:RefreshWeaponList()
end

---玩家靠近一个子弹的事件
---@param _ammo Accessory
function InterGUI:PlayerNearAmmoEventHandler(_ammo)
    if self.weaponUiList[_ammo] then
        return
    end
    if _ammo.Player.Value then
        return
    end
    local id = _ammo.ID.Value
    local order = GunConfig.AmmoConfig[id].Order
    local ui = UseNearByUI()
    ui.ItemIcon.Texture = ResourceManager.GetTexture('WeaponPackage/UI/BagPackGUI/' .. GunConfig.AmmoConfig[id].Icon)
    self.weaponUiList[_ammo] = {
        UI = ui,
        Order = order,
        IsMarked = false,
        AmmoId = id
    }
    ui.PickBtn.OnClick:Connect(
        function()
            self:PickAmmoBtnClick(_ammo)
        end
    )
    ui.ItemName.Text = GunConfig.AmmoConfig[_ammo.ID.Value].Name
    ui.CountTxt.Text = _ammo.Count.Value
    self:RefreshWeaponList()
end

---玩家远离一个子弹的事件
---@param _ammo Accessory
function InterGUI:PlayerFarAmmoEventHandler(_ammo)
    if not self.weaponUiList[_ammo] then
        return
    end
    local ui = self.weaponUiList[_ammo].UI
    if ui == nil then
        return
    end
    RecoveryUI(ui)
    self.weaponUiList[_ammo] = nil
    self:RefreshWeaponList()
end

---玩家点击按钮尝试拾取一个武器
---@param _pickGun Accessory
function InterGUI:PickWeaponBtnClick(_pickGun)
    print('玩家点击按钮尝试拾取一个武器')
    PlayerGunMgr:PickWeapon(_pickGun)
    self:RefreshWeaponList()
end

---玩家点击按钮尝试拾取一个配件
function InterGUI:PickWeaponAccessoryBtnClick(_pickAccessory)
    PlayerGunMgr:PickAccessory(_pickAccessory)
    self:RefreshWeaponList()
end

---玩家点击按钮拾取子弹的事件
function InterGUI:PickAmmoBtnClick(_pickAmmo)
    PlayerGunMgr:PickAmmo(_pickAmmo)
    self:RefreshWeaponList()
end

---刷新附近的武器列表
function InterGUI:RefreshWeaponList()
    local startAnchorsY = _SAY_
    local cacheUIList = {}
    local index = 1
    for k, v in pairs(self.weaponUiList) do
        cacheUIList[index] = v
        index = index + 1
    end
    CheckNearByAccessory(cacheUIList)
    CheckNearByAmmo(cacheUIList)
    CheckNearByWeapon(cacheUIList)
    table.sort(cacheUIList, Sort)
    for i = 1, #cacheUIList do
        local value = cacheUIList[i]
        value.UI.AnchorsY = Vector2(startAnchorsY, startAnchorsY)
        startAnchorsY = startAnchorsY - 0.3
        if value.IsMarked then
            value.UI.MarkedImage:SetActive(true)
        else
            value.UI.MarkedImage:SetActive(false)
        end
    end
    if #cacheUIList == 0 then
        self.interGUI:SetActive(false)
    else
        self.interGUI:SetActive(true)
    end
end

---隐藏附近的武器列表
function InterGUI:HideWeaponList()
    self.interGUI:SetActive(false)
end

---展示附近的武器列表
function InterGUI:ShowWeaponList()
    self.interGUI:SetActive(true)
end

return InterGUI
