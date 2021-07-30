--- @module BottomGUI，枪械模块：底部UI
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma,RopzTao
local BottomGUI, this = {}, nil

local mainGunPos, deputyGunPos, shined, tt = Vector2(0.315, 0.5), Vector2(0.587, 0.5), true, 0

---模块初始化函数
function BottomGUI:Init()
    this = self
    self:InitListeners()
    self.root = world:CreateInstance('BottomGUI', 'BottomGUI', localPlayer.Local)
    self.root.Order = 501
    self.weapon1 = self.root.BottomPart.Weapon1
    self.weapon2 = self.root.BottomPart.Weapon2
    self.weapon3 = self.root.BottomPart.Weapon3
    self.weapon4 = self.root.BottomPart.Prop1
    self.weapon5 = self.root.BottomPart.Prop2
    self.weapon1.WeaponBtn.OnClick:Connect(
        function()
            self:ChooseWeapon(1)
        end
    )
    self.weapon2.WeaponBtn.OnClick:Connect(
        function()
            self:ChooseWeapon(2)
        end
    )
    self.weapon3.WeaponBtn.OnClick:Connect(
        function()
            self:ChooseWeapon(3)
        end
    )
    self.weapon4.WeaponBtn.OnClick:Connect(
        function()
            self:ChooseWeapon(4)
        end
    )
    self.weapon5.WeaponBtn.OnClick:Connect(
        function()
            self:ChooseWeapon(5)
        end
    )
    self.weapon1.FireMode.OnClick:Connect(
        function()
            self:ChangeWeaponShootMode(1)
        end
    )
    self.weapon2.FireMode.OnClick:Connect(
        function()
            self:ChangeWeaponShootMode(2)
        end
    )
    self.weapon3.FireMode.OnClick:Connect(
        function()
            self:ChangeWeaponShootMode(3)
        end
    )

    self.player = localPlayer
    for k, v in pairs(self.root.BottomPart.Health:GetChildren()) do
        self[tostring(v)] = v
    end

    self.isShing = false
    self.HealthFillRed:SetActive(false)
    self.player.OnHealthChange:Connect(
        function()
            self:BeHitHealthFill(self.player.Health)
        end
    )
end

function BottomGUI:InitListeners()
    LinkConnects(localPlayer.C_Event, BottomGUI, this)
end

---Update函数
---@param dt number delta time 每帧时间
function BottomGUI:Update(dt)
    local curIndex = PlayerGunMgr:GetCurGunIndex()
    if curIndex == -1 then
        ---当前没有枪,不更新
        return
    end
    for i = 1, 3 do
        if curIndex ~= i then
        --self['weapon' .. i].SelectedIcon:SetActive(false)
        --self['weapon' .. i].Icon:SetActive(true)
        end
    end
    ---当前有枪并且持枪状态
    --self['weapon' .. curIndex].SelectedIcon:SetActive(true)
    --self['weapon' .. curIndex].Icon:SetActive(false)
    local leftAmmo = PlayerGunMgr.curGun.m_magazine.m_leftAmmo
    local loadPercent = PlayerGunMgr.curGun.m_magazine:UpdateLoadPercentage()
    self.weapon1.CurAmmo.Text = leftAmmo
    self.weapon1.CurAmmo.BulletFill.FillAmount = loadPercent * 0.01
    --print(leftAmmo)
    if leftAmmo == 0 then
        self.weapon1.CurAmmo.Color = Color(255, 0, 5, 255)
        self.weapon1.CurAmmo.BulletBG.Color = Color(255, 0, 0, 99)
    else
        self.weapon1.CurAmmo.Color = Color(255, 255, 255, 255)
        self.weapon1.CurAmmo.BulletBG.Color = Color(255, 255, 255, 99)
    end
    --[[
    if loadPercent < 5 then
        self['weapon' .. curIndex].Grade.Texture = ResourceManager.GetTexture('WeaponPackage/UI/BagPackGUI/Icon_Fight_Weapon_Grade0')
    elseif loadPercent >= 5 and loadPercent < 50 then
        self['weapon' .. curIndex].Grade.Texture = ResourceManager.GetTexture('WeaponPackage/UI/BagPackGUI/Icon_Fight_Weapon_Grade1')
    elseif loadPercent >= 50 and loadPercent < 75 then
        self['weapon' .. curIndex].Grade.Texture = ResourceManager.GetTexture('WeaponPackage/UI/BagPackGUI/Icon_Fight_Weapon_Grade2')
    elseif loadPercent >= 75 then
        self['weapon' .. curIndex].Grade.Texture = ResourceManager.GetTexture('WeaponPackage/UI/BagPackGUI/Icon_Fight_Weapon_Grade3')
    end]]
    ---更新武器的弹药总数
    --[[if PlayerGunMgr.mainGun then
        local mainGunAmmoId = PlayerGunMgr.mainGun.m_magazine.matchAmmo
        local mainGunAmmo = PlayerGunMgr.hadAmmoList[mainGunAmmoId]
        if mainGunAmmo then
            self.weapon1.TotalAmmo.Text = mainGunAmmo.count
        else
            self.weapon1.TotalAmmo.Text = '0'
        end
        if self.weapon1.TotalAmmo.Text == '0' then
            self.weapon1.TotalAmmo.Color = Color(255, 0, 5, 255)
        else
            self.weapon1.TotalAmmo.Color = Color(255, 175, 5, 255)
        end
    end
    if PlayerGunMgr.deputyGun then
        local deputyGunAmmoId = PlayerGunMgr.deputyGun.m_magazine.matchAmmo
        local deputyGunAmmo = PlayerGunMgr.hadAmmoList[deputyGunAmmoId]
        if deputyGunAmmo then
            self.weapon2.TotalAmmo.Text = deputyGunAmmo.count
        else
            self.weapon2.TotalAmmo.Text = '0'
        end
        if self.weapon2.TotalAmmo.Text == '0' then
            self.weapon2.TotalAmmo.Color = Color(255, 0, 5, 255)
        else
            self.weapon2.TotalAmmo.Color = Color(255, 175, 5, 255)
        end
    end
    if PlayerGunMgr.miniGun then
        local miniGunAmmoId = PlayerGunMgr.miniGun.m_magazine.matchAmmo
        local miniGunAmmo = PlayerGunMgr.hadAmmoList[miniGunAmmoId]
        if miniGunAmmo then
            self.weapon3.TotalAmmo.Text = miniGunAmmo.count
        else
            self.weapon3.TotalAmmo.Text = '0'
        end
        if self.weapon3.TotalAmmo.Text == '0' then
            self.weapon3.TotalAmmo.Color = Color(255, 0, 5, 255)
        else
            self.weapon3.TotalAmmo.Color = Color(255, 175, 5, 255)
        end
    end]]
    self:LowHealthShing(dt)
end

---更新下方武器列表
---@param _targetGun GunBase
function BottomGUI:UpdateList(_targetGun, _targetIndex)
    if _targetGun then
        self:ShowInfo(_targetGun, _targetIndex)
    else
        self:HideInfo(_targetGun, _targetIndex)
    end
end

---隐藏一个枪的信息
function BottomGUI:HideInfo(_targetGun, _index)
    local weaponUI = self['weapon' .. _index]
    if not weaponUI then
        return
    end
    weaponUI.Icon:SetActive(false)
    weaponUI.SelectionOutline:SetActive(false)
    weaponUI.WeaponBtn:SetActive(false)
    weaponUI.FireMode:SetActive(false)
    weaponUI.CurAmmo:SetActive(false)
    weaponUI.TotalAmmo:SetActive(false)
    weaponUI.Gap:SetActive(false)
    weaponUI.Grade:SetActive(false)
end

---展示一个枪的信息
---@param _targetGun GunBase
function BottomGUI:ShowInfo(_targetGun, _index)
    local weaponUI = self['weapon' .. _index]
    if not weaponUI then
        return
    end
    weaponUI.Icon:SetActive(true)
    ---weaponUI.SelectionOutline:SetActive(true)
    weaponUI.WeaponBtn:SetActive(true)
    ---临时修改删去切换模式
    ---weaponUI.FireMode:SetActive(false)
    weaponUI.CurAmmo:SetActive(true)
    ---weaponUI.TotalAmmo:SetActive(true)
    ---weaponUI.Gap:SetActive(true)
    ---weaponUI.Grade:SetActive(true)
    weaponUI.Icon.Texture = ResourceManager.GetTexture('UI/Icon/' .. _targetGun.icon)
    weaponUI.Icon:SetActive(true)
    --print('UI/Icon/' .. _targetGun.icon)
    --weaponUI.SelectedIcon.Texture = ResourceManager.GetTexture('UI/Icon/' .. _targetGun.selectedIcon)
    weaponUI.CurAmmo.Text = _targetGun.m_magazine.m_leftAmmo
    if _targetGun.m_magazine.m_leftAmmo == 0 then
        weaponUI.CurAmmo.Color = Color(255, 0, 5, 255)
    else
        weaponUI.CurAmmo.Color = Color(255, 255, 255, 255)
    end
end

---选择一个武器
function BottomGUI:ChooseWeapon(_index)
    PlayerGunMgr:SwitchWeapon(_index)
end

---尝试更改一个武器的射击模式
function BottomGUI:ChangeWeaponShootMode(_index)
    print('尝试更改一个武器的射击模式')
    if _index == 1 then
        if PlayerGunMgr.mainGun then
            return PlayerGunMgr.mainGun:ChangeShootMode()
        end
    elseif _index == 2 then
        if PlayerGunMgr.deputyGun then
            return PlayerGunMgr.deputyGun:ChangeShootMode()
        end
    elseif _index == 3 then
        if PlayerGunMgr.miniGun then
            return PlayerGunMgr.miniGun:ChangeShootMode()
        end
    end
end

function BottomGUI:BeHitHealthFill(_health)
    local showNum, Tweener = 0, nil
    if _health > 0 then
        showNum = _health
        self.HeartFill:SetActive(true)
        self.HeartFill.Size = Vector2(29, 24)
        self.HeartBG.Size = Vector2(40, 40)
        shined = true
    else
        showNum = 0
        self.HeartFill:SetActive(false)
    end
    self.HealthFill.FillAmount = showNum / 100
    --[[
    if Tweener then
        Tweener:Complete()
    end
    Tweener = Tween:TweenProperty(self.HealthFillRed, { FillAmount = self.HealthFill.FillAmount }, 0.25, Enum.EaseCurve.Linear)
    Tweener:Play()]]
    if _health > 0 and _health < 20 then
        self.HeartFill.Color = Color(255, 0, 0, 255)
        self.HealthFill.Color = Color(255, 0, 0, 255)
        self.isShing = true
    else
        self.HeartFill.Color = Color(3, 240, 153, 255)
        self.HealthFill.Color = Color(3, 240, 153, 255)
        self.isShing = false
    end
end

---闪烁
function BottomGUI:LowHealthShing(_dt)
    tt = tt + _dt
    if self.isShing and tt > 0.5 then
        if shined then
            self.HeartFill.Size = Vector2(29, 24) * 1.35
            self.HeartBG.Size = Vector2(40, 40) * 1.35
            shined = false
        else
            self.HeartFill.Size = Vector2(29, 24)
            self.HeartBG.Size = Vector2(40, 40)
            shined = true
        end
        tt = 0
    end
end

---主副枪交换
function BottomGUI:Main_Deputy()
    self.weapon1.AnchorsX = Vector2(deputyGunPos.X, deputyGunPos.X)
    self.weapon1.AnchorsY = Vector2(deputyGunPos.Y, deputyGunPos.Y)
    self.weapon2.AnchorsX = Vector2(mainGunPos.X, mainGunPos.X)
    self.weapon2.AnchorsY = Vector2(mainGunPos.Y, mainGunPos.Y)
    self.weapon1, self.weapon2 = self.weapon2, self.weapon1
    self.weapon1.WeaponBtn.OnClick:Clear()
    self.weapon2.WeaponBtn.OnClick:Clear()
    self.weapon1.FireMode.OnClick:Clear()
    self.weapon2.FireMode.OnClick:Clear()
    self.weapon1.WeaponBtn.OnClick:Connect(
        function()
            self:ChooseWeapon(1)
        end
    )
    self.weapon2.WeaponBtn.OnClick:Connect(
        function()
            self:ChooseWeapon(2)
        end
    )
    self.weapon1.FireMode.OnClick:Connect(
        function()
            self:ChangeWeaponShootMode(1)
        end
    )
    self.weapon2.FireMode.OnClick:Connect(
        function()
            self:ChangeWeaponShootMode(2)
        end
    )
end

function BottomGUI:SetActive(_active)
    self.root:SetActive(_active)
end

function BottomGUI:GetActive()
    return self.root.ActiveSelf
end

return BottomGUI
