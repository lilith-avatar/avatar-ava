--- @module BagGUI 武器背包相关功能,背包的道具只显示配件和子弹
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local BagGUI, this = {}, nil

local mainGunPos = Vector2(0.295, 0.77)
local deputyGunPos = Vector2(0.295, 0.455)
local miniGunPos = Vector2(0.4, 0.18)
local deputyGunArea = {AnchorsX = Vector2(0.45, 0.73), AnchorsY = Vector2(0.35, 0.57)}
local mainGunArea = {AnchorsX = Vector2(0.45, 0.73), AnchorsY = Vector2(0.6, 0.82)}
local miniGunArea = {AnchorsX = Vector2(0.55, 0.74), AnchorsY = Vector2(0.18, 0.34)}
local selectTime = 0.1
local locationName = {'MuzzleAcc', 'GripAcc', 'MagazineAcc', 'ButtAcc', 'SightAcc'}

local function MergeTables(_table1, _table2)
    local res = {}
    for k, v in pairs(_table1) do
        res[k] = v
    end
    for k, v in pairs(_table2) do
        res[k] = v
    end
    return res
end

---计算指定索引的UI的位置
local function GetItemPosition(_index)
    local x, y = 1, 1
    local posX, posY = 0.13, 0.85
    x = _index % 4
    if x == 0 then
        x = 4
    end
    y = math.ceil(_index / 4)
    posX = (x - 1) * 0.25 + 0.13
    posY = (y - 1) * 0.29 + 0.15
    posY = 1 - posY
    return Vector2(posX, posX), Vector2(posY, posY)
end

---@param _table1 table 现有的UI列表
---@param _table2 table 最新的配件列表和子弹列表之和
local function CompareTwoTable(_table1, _table2)
    local table1_more, table2_more = {}, {}
    for k, v in pairs(_table1) do
        if _table2[k] == nil then
            ---表一有的表二没有
            table1_more[k] = v
        end
    end
    for k, v in pairs(_table2) do
        if _table1[k] == nil then
            ---表二有的表一没有
            table2_more[k] = v
        end
    end
    return table1_more, table2_more
end

---正在拖动一个东西,每帧更新影子位置
local function UpdateDragUI()
    local _pos
    if world:GetDevicePlatform() == Enum.Platform.Android then
        _pos = BagGUI.figurePos
    else
        _pos = Input.GetMouseScreenPos()
    end
    local _ui = BagGUI.root.WeaponShadow
    local finalSize = BagGUI.root.Size
    _ui.AnchorsX = Vector2(_pos.X / finalSize.X, _pos.X / finalSize.X)
    _ui.AnchorsY = Vector2(_pos.Y / finalSize.Y, _pos.Y / finalSize.Y)
    _ui:SetActive(true)
end

---正在拖动一个道具
local function UpdateDragItemUI(_dt)
    local _pos
    if world:GetDevicePlatform() == Enum.Platform.Android then
        _pos = BagGUI.figurePos
    else
        _pos = Input.GetMouseScreenPos()
    end
    local ui = BagGUI.root.ItemShadow
    ui.DownTime.Value = ui.DownTime.Value + _dt
    if ui.DownTime.Value >= selectTime then
        ui:SetActive(true)
    end
    local finalSizeX = BagGUI.root.Size.X
    local finalSizeY = BagGUI.root.Size.Y
    local mouseX = _pos.X
    local mouseY = _pos.Y
    local anchorsXRate = mouseX / finalSizeX
    local anchorsYRate = mouseY / finalSizeY
    ui.AnchorsX = Vector2(anchorsXRate, anchorsXRate)
    ui.AnchorsY = Vector2(anchorsYRate, anchorsYRate)
    if
        anchorsXRate > deputyGunArea.AnchorsX.X and anchorsXRate < deputyGunArea.AnchorsX.Y and
            anchorsYRate > deputyGunArea.AnchorsY.X and
            anchorsYRate < deputyGunArea.AnchorsY.Y
     then
        ---在副枪区域内
        if BagGUI.deputyGunUI then
            BagGUI.deputyGunUI.BorderColor = Color(255, 255, 255, 20)
        end
    else
        if BagGUI.deputyGunUI then
            BagGUI.deputyGunUI.BorderColor = Color(255, 255, 255, 0)
        end
    end
    if
        anchorsXRate > mainGunArea.AnchorsX.X and anchorsXRate < mainGunArea.AnchorsX.Y and
            anchorsYRate > mainGunArea.AnchorsY.X and
            anchorsYRate < mainGunArea.AnchorsY.Y
     then
        ---在主枪区域内
        if BagGUI.mainGunUI then
            BagGUI.mainGunUI.BorderColor = Color(255, 255, 255, 20)
        end
    else
        if BagGUI.mainGunUI then
            BagGUI.mainGunUI.BorderColor = Color(255, 255, 255, 0)
        end
    end
end

local function HighLightLocation(_accId, _active)
    if _accId == -1 then
        return
    end
    local location = GunConfig.WeaponAccessoryConfig[_accId].Location
    local key = locationName[location]
    if not key then
        return
    end
    if PlayerGunMgr.mainGun and GunBase.static.utility:CheckAcc2Weapon(_accId, PlayerGunMgr.mainGun.gun_Id) then
        ---主武器存在并且可以装备这个配件
        BagGUI.mainGunUI[key].HighLight:SetActive(_active)
    end
    if PlayerGunMgr.deputyGun and GunBase.static.utility:CheckAcc2Weapon(_accId, PlayerGunMgr.deputyGun.gun_Id) then
        ---副武器存在并且可以装备这个配件
        BagGUI.deputyGunUI[key].HighLight:SetActive(_active)
    end
    if PlayerGunMgr.miniGun and GunBase.static.utility:CheckAcc2Weapon(_accId, PlayerGunMgr.miniGun.gun_Id) then
        ---手枪武器存在并且可以装备这个配件
        BagGUI.miniGunUI[key].HighLight:SetActive(_active)
    end
end

---向UI集合中增加指定UUID或者ID的UI
local function AddUI(_table)
    local needUpdate = false
    for k, v in pairs(_table) do
        local ui = world:CreateInstance('Item_Bag', 'Item_Bag', BagGUI.root.Background.BagList)
        ui.AnchorsX = Vector2(10, 10)
        ui.Offset = Vector2.Zero
        local icon
        if type(k) == 'string' then
            ---新增的为配件
            ui.NumTxt.Text = ''
            icon = v.icon
            ui.ItemIcon.Image = ResourceManager.GetTexture('WeaponPackage/UI/EquipmentGUI/' .. icon)
        elseif type(k) == 'number' then
            ---新增的为子弹
            ui.NumTxt.Text = v.count
            icon = GunConfig.AmmoConfig[k].Icon
            ui.ItemIcon.Image = ResourceManager.GetTexture('WeaponPackage/UI/EquipmentGUI/' .. icon)
        end
        ui.ItemButton.OnClick:Connect(
            function()
                ---BagGUI:ItemClick(k)
            end
        )
        ui.ItemButton.OnDown:Connect(
            function()
                BagGUI:ItemClick(k)
                BagGUI.root.ItemShadow.ItemIcon.Image =
                    ResourceManager.GetTexture('WeaponPackage/UI/EquipmentGUI/' .. icon)
                BagGUI.root.ItemShadow.NumTxt.Text = ui.NumTxt.Text
                local accId = -1
                if type(k) == 'string' then
                    accId = PlayerGunMgr.hadAccessoryList[k].id
                end
                HighLightLocation(accId, true)
                world.OnRenderStepped:Connect(UpdateDragItemUI)
            end
        )
        ui.ItemButton.OnUp:Connect(
            function()
                world.OnRenderStepped:Disconnect(UpdateDragItemUI)
                local accId = -1
                if type(k) == 'string' then
                    accId = PlayerGunMgr.hadAccessoryList[k].id
                end
                HighLightLocation(accId, false)
                BagGUI.root.ItemShadow.DownTime.Value = 0
                BagGUI.root.ItemShadow:SetActive(false)
                local mousePos = Input.GetMouseScreenPos()
                local anchorsXRate = mousePos.X / BagGUI.root.Size.X
                local anchorsYRate = mousePos.Y / BagGUI.root.Size.Y
                if anchorsXRate < 0.45 then
                    BagGUI:DropBtnClick()
                end
                if
                    anchorsXRate > deputyGunArea.AnchorsX.X and anchorsXRate < deputyGunArea.AnchorsX.Y and
                        anchorsYRate > deputyGunArea.AnchorsY.X and
                        anchorsYRate < deputyGunArea.AnchorsY.Y
                 then
                    ---在副枪区域内
                    if BagGUI.deputyGunUI then
                        BagGUI.deputyGunUI.BorderColor = Color(255, 255, 255, 0)
                        PlayerGunMgr:TryEquipAccessoryToWeapon(PlayerGunMgr.hadAccessoryList[k], PlayerGunMgr.deputyGun)
                    end
                elseif
                    anchorsXRate > mainGunArea.AnchorsX.X and anchorsXRate < mainGunArea.AnchorsX.Y and
                        anchorsYRate > mainGunArea.AnchorsY.X and
                        anchorsYRate < mainGunArea.AnchorsY.Y
                 then
                    ---在主枪区域内
                    if BagGUI.mainGunUI then
                        BagGUI.mainGunUI.BorderColor = Color(255, 255, 255, 0)
                        PlayerGunMgr:TryEquipAccessoryToWeapon(PlayerGunMgr.hadAccessoryList[k], PlayerGunMgr.mainGun)
                    end
                elseif
                    anchorsXRate > miniGunArea.AnchorsX.X and anchorsXRate < miniGunArea.AnchorsX.Y and
                        anchorsYRate > miniGunArea.AnchorsY.X and
                        anchorsYRate < miniGunArea.AnchorsY.Y
                 then
                    ---在手枪区域内
                    if BagGUI.miniGunUI then
                        BagGUI.miniGunUI.BorderColor = Color(255, 255, 255, 0)
                        PlayerGunMgr:TryEquipAccessoryToWeapon(PlayerGunMgr.hadAccessoryList[k], PlayerGunMgr.miniGunUI)
                    end
                end
            end
        )
        BagGUI.currentUIList[k] = ui
        needUpdate = true
    end
    if needUpdate then
        BagGUI:RefreshItem()
    end
end

---从UI集合中删除指定的UI
local function DeleteUI(_table)
    local needUpdate = false
    for k, v in pairs(_table) do
        needUpdate = true
        v:Destroy()
        _table[k] = nil
        BagGUI.currentUIList[k] = nil
    end
    if needUpdate then
        BagGUI:RefreshItem()
    end
end

---模块初始化函数
function BagGUI:Init()
    this = self
    self:InitListeners()
    self.root = world:CreateInstance('EquipmentGUI', 'EquipmentGUI', localPlayer.Local)
    self.root:SetActive(false)
    self.root.Order = 30
    self.closeBtn = self.root.Background.BagClose
    self.dropBtn = self.root.Background.BagDrop
    self.useBtn = self.root.Background.BagUse
    self.desTxt = self.root.Background.DesText
    self.nameTxt = self.root.Background.NameText
    self.closeArea = self.root.CloseArea
    self.figureTouch = self.root.FigureTouch
    self.useBtn:SetActive(false)
    self.dropBtn:SetActive(false)
    self.figurePos = Vector2.Zero
    self.selectItemKey = nil
    ---背包中的UI列表,key-配件UUID和子弹的ID,value-UI对象
    self.currentUIList = {}
    ---当前身上的三把武器
    self.mainGunUI = nil
    self.deputyGunUI = nil
    self.miniGunUI = nil

    self.closeArea.OnClick:Connect(
        function()
            self:CloseBtnClick()
        end
    )
    self.closeBtn.OnClick:Connect(
        function()
            self:CloseBtnClick()
        end
    )
    self.dropBtn.OnClick:Connect(
        function()
            self:DropBtnClick()
        end
    )
    self.useBtn.OnClick:Connect(
        function()
            self:UseBtnClick()
        end
    )

    self.figureTouch.OnPanBegin:Connect(
        function(_pos)
            self.figurePos = _pos
        end
    )
    self.figureTouch.OnPanStay:Connect(
        function(_pos)
            self.figurePos = _pos
        end
    )
    self.figureTouch.OnPanEnd:Connect(
        function(_pos)
            self.figurePos = _pos
        end
    )
end

function BagGUI:InitListeners()
    LinkConnects(localPlayer.C_Event, BagGUI, this)
end

---Update函数
---@param dt number delta time 每帧时间
function BagGUI:Update(dt)
    --[[self:BSDiff()
    ---更新数量
    for k, v in pairs(self.currentUIList) do
        if type(k) == 'number' then
            ---是子弹
            v.NumTxt.Text = PlayerGunMgr.hadAmmoList[k].count
        end
    end]]
end

---关闭按钮按下
function BagGUI:CloseBtnClick()
    self:Hide()
end

---丢弃按钮按下
function BagGUI:DropBtnClick()
    if self.selectItemKey == nil then
        return
    end
    if type(self.selectItemKey) == 'number' then
        ---子弹
        local ammo = PlayerGunMgr.hadAmmoList[self.selectItemKey]
        PlayerGunMgr:DropAmmo(ammo, ammo.count)
    else
        ---配件
        PlayerGunMgr:DropAccessory(PlayerGunMgr.hadAccessoryList[self.selectItemKey])
    end
end

---使用按钮按下
function BagGUI:UseBtnClick()
    print('使用按钮按下')
    if not self.selectItemKey then
        return
    end
    if type(self.selectItemKey) == 'number' then
        ---子弹,不可以使用
        print('不可以使用子弹')
    else
        ---配件
        if not PlayerGunMgr.curGun then
            return
        end
        ---@type WeaponAccessoryBase
        local acc = PlayerGunMgr.hadAccessoryList[self.selectItemKey]
        PlayerGunMgr:TryEquipAccessoryToWeapon(acc, PlayerGunMgr.curGun)
    end
end

---展示界面
function BagGUI:Show()
    self.root:SetActive(true)
    BattleGUI:BagResourceChange(true)
end

---隐藏界面
function BagGUI:Hide()
    self.root:SetActive(false)
    BattleGUI:BagResourceChange(false)
end

---每帧进行的差异更新监测
function BagGUI:BSDiff()
    ---进行背包中的物品的差异更新检测
    local moreThanZeroAmmoList = {}
    for k, v in pairs(PlayerGunMgr.hadAmmoList) do
        if v.count > 0 then
            moreThanZeroAmmoList[k] = v
        end
    end
    local moreThanZeroAccList = {}
    for k, v in pairs(PlayerGunMgr.hadAccessoryList) do
        if not v.m_equippedWeapon then
            moreThanZeroAccList[k] = v
        end
    end
    local table1_more, table2_more =
        CompareTwoTable(BagGUI.currentUIList, MergeTables(moreThanZeroAccList, moreThanZeroAmmoList))
    DeleteUI(table1_more)
    AddUI(table2_more)
end

---更新背包中的道具列表
function BagGUI:RefreshItem()
    local num = 1
    for k, v in pairs(self.currentUIList) do
        v.AnchorsX, v.AnchorsY = GetItemPosition(num)
        num = num + 1
    end
end

---道具点击事件
---@param _key any 点击的道具在表中的Key
function BagGUI:ItemClick(_key)
    local preSelectItem = self.selectItemKey and self.currentUIList[self.selectItemKey] or nil
    self.selectItemKey = _key
    local curSelectItem = self.currentUIList[_key]
    if preSelectItem then
        preSelectItem.Color = Color(255, 255, 255, 255)
    end
    curSelectItem.Color = Color(255, 0, 0, 255)
    ---更新ui的描述
    if type(_key) == 'number' then
        self.nameTxt.Text = GunConfig.AmmoConfig[_key].Name
        self.desTxt.Text = GunConfig.AmmoConfig[_key].Des
        self.useBtn:SetActive(false)
        self.dropBtn:SetActive(true)
    else
        local id = PlayerGunMgr.hadAccessoryList[_key].id
        self.nameTxt.Text = GunConfig.WeaponAccessoryConfig[id].Name
        self.desTxt.Text = GunConfig.WeaponAccessoryConfig[id].Des
        self.useBtn:SetActive(true)
        self.dropBtn:SetActive(true)
    end
end

---拾取一把枪并装备
function BagGUI:EquipWeapon(_targetPosition)
    local ui, gunId
    if _targetPosition == 1 then
        gunId = PlayerGunMgr.mainGun.gun_Id
        ui = world:CreateInstance('WeaponMain', 'WeaponMain', self.root.Background)
        self.mainGunUI = ui
        ui.EquippedNameTxt.Text = PlayerGunMgr.mainGun.name
        ui.EquippedGunBtn.Image =
            ResourceManager.GetTexture('WeaponPackage/UI/BagPackGUI/' .. PlayerGunMgr.mainGun.icon)
        ui.AnchorsX = Vector2(mainGunPos.X, mainGunPos.X)
        ui.AnchorsY = Vector2(mainGunPos.Y, mainGunPos.Y)
        if PlayerGunMgr.curGun == PlayerGunMgr.mainGun then
            ui.CurGunTxt:SetActive(true)
        end
    elseif _targetPosition == 2 then
        gunId = PlayerGunMgr.deputyGun.gun_Id
        ui = world:CreateInstance('WeaponMain', 'WeaponMain', self.root.Background)
        self.deputyGunUI = ui
        ui.EquippedNameTxt.Text = PlayerGunMgr.deputyGun.name
        ui.EquippedGunBtn.Image =
            ResourceManager.GetTexture('WeaponPackage/UI/BagPackGUI/' .. PlayerGunMgr.deputyGun.icon)
        ui.AnchorsX = Vector2(deputyGunPos.X, deputyGunPos.X)
        ui.AnchorsY = Vector2(deputyGunPos.Y, deputyGunPos.Y)
        if PlayerGunMgr.curGun == PlayerGunMgr.deputyGun then
            ui.CurGunTxt:SetActive(true)
        end
    elseif _targetPosition == 3 then
        gunId = PlayerGunMgr.miniGun.gun_Id
        ui = world:CreateInstance('WeaponSec', 'WeaponSec', self.root.Background)
        self.miniGunUI = ui
        ui.EquippedNameTxt.Text = PlayerGunMgr.miniGun.name
        ui.EquippedGunBtn.Image =
            ResourceManager.GetTexture('WeaponPackage/UI/BagPackGUI/' .. PlayerGunMgr.miniGun.icon)
        ui.AnchorsX = Vector2(miniGunPos.X, miniGunPos.X)
        ui.AnchorsY = Vector2(miniGunPos.Y, miniGunPos.Y)
        if PlayerGunMgr.curGun == PlayerGunMgr.miniGun then
            ui.CurGunTxt:SetActive(true)
        end
    else
        return
    end
    local accLocations = GunBase.static.utility:GetWeaponAccLocations(gunId)
    for k, v in pairs(accLocations) do
        local key = locationName[v]
        if key then
            ui[key]:SetActive(true)
        end
    end
    ui.EquippedGunBtn.OnDown:Connect(
        function()
            world.OnRenderStepped:Connect(UpdateDragUI)
        end
    )
    ui.EquippedGunBtn.OnUp:Connect(
        function()
            world.OnRenderStepped:Disconnect(UpdateDragUI)
            self.root.WeaponShadow:SetActive(false)
            local mousePos = Input.GetMouseScreenPos()
            local anchorsXRate = mousePos.X / self.root.Size.X
            local anchorsYRate = mousePos.Y / self.root.Size.Y
            if anchorsXRate < 0.45 then
                ---在丢弃区域内
                if ui == self.mainGunUI then
                    PlayerGunMgr:DropWeapon(PlayerGunMgr.mainGun)
                elseif ui == self.deputyGunUI then
                    PlayerGunMgr:DropWeapon(PlayerGunMgr.deputyGun)
                elseif ui == self.miniGunUI then
                    PlayerGunMgr:DropWeapon(PlayerGunMgr.miniGun)
                end
            end
            if ui == self.mainGunUI then
                if
                    anchorsXRate > deputyGunArea.AnchorsX.X and anchorsXRate < deputyGunArea.AnchorsX.Y and
                        anchorsYRate > deputyGunArea.AnchorsY.X and
                        anchorsYRate < deputyGunArea.AnchorsY.Y
                 then
                    self:Main_DeputyWeapon()
                end
            end
            if ui == self.deputyGunUI then
                if
                    anchorsXRate > mainGunArea.AnchorsX.X and anchorsXRate < mainGunArea.AnchorsX.Y and
                        anchorsYRate > mainGunArea.AnchorsY.X and
                        anchorsYRate < mainGunArea.AnchorsY.Y
                 then
                    self:Main_DeputyWeapon()
                end
            end
        end
    )
end

---丢弃一把枪
function BagGUI:UnEquipWeapon(_targetPosition)
    if _targetPosition == 1 then
        if self.mainGunUI and not self.mainGunUI:IsNull() then
            self.mainGunUI:Destroy()
            self.mainGunUI = nil
        end
    elseif _targetPosition == 2 and not self.deputyGunUI:IsNull() then
        if self.deputyGunUI then
            self.deputyGunUI:Destroy()
            self.deputyGunUI = nil
        end
    elseif _targetPosition == 3 and not self.miniGunUI:IsNull() then
        if self.miniGunUI then
            self.miniGunUI:Destroy()
            self.miniGunUI = nil
        end
    end
end

---装备一个配件到指定的枪上
---@param _accCls WeaponAccessoryBase
---@param _weaponCls GunBase
function BagGUI:EquipAccessory(_accCls, _weaponCls)
    local _index = PlayerGunMgr:GetIndexByWeapon(_weaponCls)
    local targetWeaponUI
    local accUUID, weaponUUID = _accCls.uuid, _weaponCls.uuid
    if _index == 1 then
        targetWeaponUI = self.mainGunUI
    elseif _index == 2 then
        targetWeaponUI = self.deputyGunUI
    elseif _index == 3 then
        targetWeaponUI = self.miniGunUI
    end
    local location = _accCls.location
    local icon = _accCls.icon
    local accUI
    if location == WeaponAccessoryTypeEnum.Muzzle then
        accUI = targetWeaponUI.MuzzleAcc
    elseif location == WeaponAccessoryTypeEnum.Grip then
        accUI = targetWeaponUI.GripAcc
    elseif location == WeaponAccessoryTypeEnum.Magazine then
        accUI = targetWeaponUI.MagazineAcc
    elseif location == WeaponAccessoryTypeEnum.Butt then
        accUI = targetWeaponUI.ButtAcc
    elseif location == WeaponAccessoryTypeEnum.Sight then
        accUI = targetWeaponUI.SightAcc
    end
    accUI.Acc:SetActive(true)
    accUI.Acc.Image = ResourceManager.GetTexture('WeaponPackage/UI/BagPackGUI/' .. icon)
    accUI.Acc.OnClick:Connect(
        function()
            PlayerGunMgr:TryUnEquipAccessoryFromWeapon(PlayerGunMgr.hadAccessoryList[accUUID], _weaponCls)
        end
    )
end

---从一把枪上将配件卸载
---@param _accCls WeaponAccessoryBase
---@param _weaponCls GunBase
function BagGUI:UnEquipAccessory(_accCls, _weaponCls)
    local _index = PlayerGunMgr:GetIndexByWeapon(_weaponCls)
    local targetWeaponUI
    if _index == 1 then
        targetWeaponUI = self.mainGunUI
    elseif _index == 2 then
        targetWeaponUI = self.deputyGunUI
    elseif _index == 3 then
        targetWeaponUI = self.miniGunUI
    end
    local location = _accCls.location
    local accUI
    if location == WeaponAccessoryTypeEnum.Muzzle then
        accUI = targetWeaponUI.MuzzleAcc
    elseif location == WeaponAccessoryTypeEnum.Grip then
        accUI = targetWeaponUI.GripAcc
    elseif location == WeaponAccessoryTypeEnum.Magazine then
        accUI = targetWeaponUI.MagazineAcc
    elseif location == WeaponAccessoryTypeEnum.Butt then
        accUI = targetWeaponUI.ButtAcc
    elseif location == WeaponAccessoryTypeEnum.Sight then
        accUI = targetWeaponUI.SightAcc
    end
    accUI.Acc:SetActive(false)
    accUI.Acc.Image = nil
    accUI.Acc.OnClick:Clear()
end

---切枪之后的逻辑
function BagGUI:SwitchWeapon(_targetIndex)
    if self.mainGunUI then
        self.mainGunUI.CurGunTxt:SetActive(false)
    end
    if self.deputyGunUI then
        self.deputyGunUI.CurGunTxt:SetActive(false)
    end
    if self.miniGunUI then
        self.miniGunUI.CurGunTxt:SetActive(false)
    end
    if _targetIndex == 1 then
        self.mainGunUI.CurGunTxt:SetActive(true)
    elseif _targetIndex == 2 then
        self.deputyGunUI.CurGunTxt:SetActive(true)
    elseif _targetIndex == 3 then
        self.miniGunUI.CurGunTxt:SetActive(true)
    end
end

---主枪副枪切换
function BagGUI:Main_DeputyWeapon()
    print('主枪副枪切换')
    if self.mainGunUI then
        self.mainGunUI.AnchorsX = Vector2(deputyGunPos.X, deputyGunPos.X)
        self.mainGunUI.AnchorsY = Vector2(deputyGunPos.Y, deputyGunPos.Y)
    end
    if self.deputyGunUI then
        self.deputyGunUI.AnchorsX = Vector2(mainGunPos.X, mainGunPos.X)
        self.deputyGunUI.AnchorsY = Vector2(mainGunPos.Y, mainGunPos.Y)
    end
    self.mainGunUI, self.deputyGunUI = self.deputyGunUI, self.mainGunUI
    PlayerGunMgr:Main_DeputyWeapon()
    BottomGUI:Main_Deputy()
end

return BagGUI
