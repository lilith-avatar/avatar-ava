--- @module DebugGUI 枪械模块：开发工具面板
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local DebugGUI = {}

local originOffset_Y = -10
local height = 80

---尝试将字符串转为布尔类型
local function Str2Boolean(_str)
    if _str == 'TRUE' or _str == 'true' then
        return true
    elseif _str == 'FALSE' or _str == 'false' then
        return false
    end
    return
end

---临时开发工具方案
function DebugGUI:SettingReadyEventHandler()
    self:DeclareValue()
    --self:BindBtn()
end

function DebugGUI:SwitchWeapon()
    --self:ShowChangeWeaponDataPnl()
end

--- 初始化
function DebugGUI:Init()
    this = self
    self:InitListeners()
    ---self:DeclareValue()
    ---self:BindBtn()
end

--- 初始化DebugGUI自己的监听事件
function DebugGUI:InitListeners()
    LinkConnects(localPlayer.C_Event, DebugGUI, this)
end

--- Update函数
--- @param dt number delta time 每帧时间
function DebugGUI:Update(dt, tt)
    --self.root.F1.Text = dt
end

---声明变量
function DebugGUI:DeclareValue()
    ---self.root = world:CreateInstance('DebugUI', 'DebugUI', localPlayer.Local)
    ---self.root.Order = 9999
    ---self.showMainPnlBtn =self.root.ShowBtn
    ---self.closeMainPnlBtn = self.root.Functions.CloseBtn
    ---self.changeWeaponBtn = self.root.Functions.ChangeWeaponBtn
    self.root = SettingGUI.OperationPnl
    self.weaponData_des = self.root.Functions.WeaponInfoPnl.WeaponDes
    self.weaponData_des.Text = '当前持有的武器后坐力配置\n只有当前持有武器才会显示并生效'
    self.weaponConfigData_des = self.root.Functions.WeaponConfigPnl.WeaponDes
    self.weaponConfigData_des.Text = '当前持有的武器的基础配置\n只有当前持有武器才会显示并生效'
    self.globalConfigData_des = self.root.Functions.GlobalConfigPnl.WeaponDes
    self.globalConfigData_des.Text = '当前全局配置'

    self.weaponData_dataList = {}
    self.weaponConfigData_dataList = {}
    self.globalConfigData_dataList = {}
    world.OnRenderStepped:Connect(
        function(dt)
            self.root.F2.Text = dt
        end
    )
end

--- 绑定事件函数
function DebugGUI:BindBtn()
    --self:ShowChangeWeaponDataPnl()
end

--- 绑定事件函数
function DebugGUI:BindBtn2()
    self.showMainPnlBtn.OnClick:Connect(
        function()
            self:ShowMainPnl()
        end
    )
    self.closeMainPnlBtn.OnClick:Connect(
        function()
            self:HideMainPnl()
        end
    )
    self.changeWeaponBtn.OnClick:Connect(
        function()
            if self.root.Functions.WeaponInfoPnl.ActiveSelf then
                self:HideChangeWeaponDataPnl()
            else
                self:ShowChangeWeaponDataPnl()
            end
        end
    )
end

function DebugGUI:ShowMainPnl()
    self.root.Functions:SetActive(true)
end

function DebugGUI:HideMainPnl()
    self.root.Functions:SetActive(false)
end

---展示枪械的可热更新的配置数据
function DebugGUI:ShowChangeWeaponDataPnl()
    self.root.Functions.WeaponInfoPnl:SetActive(true)
    self.root.Functions.WeaponConfigPnl:SetActive(true)
    self.root.Functions.GlobalConfigPnl:SetActive(true)
    local num = 0
    print('展示枪械的可热更新的配置数据')
    for i, v in pairs(GunConfig.GlobalConfig) do
        if type(v) == 'string' or type(v) == 'number' or type(v) == 'boolean' then
            local obj =
                self:CreateOneData(
                i,
                v,
                nil,
                num * (height - originOffset_Y) + originOffset_Y,
                self.root.Functions.GlobalConfigPnl.DataPnl,
                true
            )
            self.globalConfigData_dataList[i] = obj
            num = num - 1
        end
    end
    self.root.Functions.GlobalConfigPnl.DataPnl.ScrollRange = math.abs(num * height + originOffset_Y) + 500
    if not PlayerGunMgr.curGun then
        return
    end
    num = 0
    for i, v in pairs(PlayerGunMgr.curGun.m_recoil) do
        if
            type(i) == 'string' and i:sub(1, 7) == 'config_' and
                (type(v) == 'number' or type(v) == 'string' or type(v) == 'boolean')
         then
            local obj =
                self:CreateOneData(
                i,
                v,
                'm_recoil',
                num * (height - originOffset_Y) + originOffset_Y,
                self.root.Functions.WeaponInfoPnl.DataPnl
            )
            self.weaponData_dataList[i] = obj
            num = num - 1
        end
    end
    for i, v in pairs(PlayerGunMgr.curGun.m_cameraControl) do
        if
            type(i) == 'string' and i:sub(1, 7) == 'config_' and
                (type(v) == 'number' or type(v) == 'string' or type(v) == 'boolean')
         then
            local obj =
                self:CreateOneData(
                i,
                v,
                'm_recoil',
                num * (height - originOffset_Y) + originOffset_Y,
                self.root.Functions.WeaponInfoPnl.DataPnl
            )
            self.weaponData_dataList[i] = obj
            num = num - 1
        end
    end
    self.root.Functions.WeaponInfoPnl.DataPnl.ScrollRange = math.abs(num * height + originOffset_Y) + 500
    num = 0
    for i, v in pairs(PlayerGunMgr.curGun) do
        if
            type(i) == 'string' and i:sub(1, 7) == 'config_' and
                (type(v) == 'number' or type(v) == 'string' or type(v) == 'boolean')
         then
            local obj =
                self:CreateOneData(
                i,
                v,
                nil,
                num * (height - originOffset_Y) + originOffset_Y,
                self.root.Functions.WeaponConfigPnl.DataPnl
            )
            self.weaponConfigData_dataList[i] = obj
            num = num - 1
        end
    end
    self.root.Functions.WeaponConfigPnl.DataPnl.ScrollRange = math.abs(num * height + originOffset_Y) + 500
end

function DebugGUI:HideChangeWeaponDataPnl()
    self.root.Functions.WeaponInfoPnl:SetActive(false)
    self.root.Functions.WeaponConfigPnl:SetActive(false)
    self.root.Functions.GlobalConfigPnl:SetActive(false)
end

function DebugGUI:CreateOneData(_key, _originData, _sub, _offsetY, _parent, _isGlobal)
    local obj
    if _parent == self.root.Functions.WeaponInfoPnl.DataPnl then
        obj = self.weaponData_dataList[_key]
    elseif _parent == self.root.Functions.WeaponConfigPnl.DataPnl then
        obj = self.weaponConfigData_dataList[_key]
    end
    if _isGlobal then
        obj = self.globalConfigData_dataList[_key]
    end
    if not obj then
        obj = world:CreateInstance('Debug_OneData', 'OneData_' .. _key, _parent)
        obj.Size = Vector2(0, height)
        obj.Offset = Vector2(0, _offsetY)
    end
    if _key:sub(1, 7) == 'config_' then
        obj.TitleTxt.Text = _key:sub(8, #_key)
    else
        obj.TitleTxt.Text = _key
    end
    if type(_originData) == 'number' then
        obj.OriginData.Text = tostring(keepDecimal(_originData, 2))
    elseif type(_originData) == 'string' then
        obj.OriginData.Text = _originData
    elseif type(_originData) == 'boolean' then
        obj.OriginData.Text = tostring(_originData)
    end
    obj.TargetData.Text = obj.OriginData.Text
    obj.ChangeBtn.OnClick:Connect(
        function()
            local newData
            if type(_originData) == 'number' then
                newData = tonumber(obj.TargetData.Text)
            elseif type(_originData) == 'string' then
                newData = tostring(obj.TargetData.Text)
            elseif type(_originData) == 'boolean' then
                newData = Str2Boolean(obj.TargetData.Text)
            end
            if _isGlobal then
                GunConfig.GlobalConfig[_key] = newData
                obj.OriginData.Text = tostring(newData)
                return obj
            end
            if PlayerGunMgr.curGun and PlayerGunMgr.curGun.gun_Id then
                obj.OriginData.Text = tostring(newData)
                if _sub then
                    PlayerGunMgr.curGun[_sub][_key] = newData
                else
                    PlayerGunMgr.curGun[_key] = newData
                end
            end
        end
    )
    return obj
end

return DebugGUI
