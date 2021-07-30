--- @module SettingGUI 枪械模块：设置UI
--- @copyright Lilith Games, Avatar Team
--- @author RopzTao
local SettingGUI, this = {}, nil

---屏幕参数
local VPX, VPY, X_2000, Y_1000, PixelX, PixelY = nil, nil, nil, nil, nil, nil

---初始化函数
---设置界面全部逻辑
---包括基础设置，灵敏度设置，准星样式选择，操作设置
function SettingGUI:Init()
    this = self
    self:InitListener()

    ---创建设置界面实例
    self.root = world:CreateInstance('SettingGUI', 'SettingGUI', localPlayer.Local)
    self.root.Order = 800
    self.player = localPlayer

    ---声明SettingGUI节点
    self.SettingBtn = self.root.SettingBtn
    self.SetFig = self.root.SetFig

    ---需要创建滑条类的节点表
    self.SliderClassTab = {}

    ---右侧按钮节点声明
    self:RightBtnPnlInit()
    ---左侧面板节点声明
    self:LeftSetFigInit()

    ---基础设置节点
    self:BasePnlSetting()

    ---灵敏度设置节点
    self:SensPnlSetting()

    ---准星设置节点
    self:CrosshairPnlSetting()
    ---准星按钮事件绑定
    self:CrosshairKeyBinding()

    ---操作设置节点
    self:OperationPnlSetting()

    ---底层面板节点管理表
    self.SetPnlCtr = {
        self.BasePnl,
        self.SensPnl,
        self.CrosshairPnl,
        self.OperationPnl
    }

    ---面板初始化设置
    self:SwitchNodeCtr(false, self.SetPnlCtr, self.BasePnl)

    ---右侧按键绑定相关
    self:KeyBinding()

    ---临时开发工具放置解决方案
    localPlayer.C_Event.SettingReadyEvent:Fire()

    ---统一人物模型
    invoke(
        function()
            self.player.CharacterHeight = 1.75
            self.player.CharacterWidth = 0.8
            self.player.Avatar.HeadSize = 0.92
            self.player.Avatar.Width = 1
            self.player.Avatar.Height = 0.92
        end,
        1
    )
end

---右侧按钮节点声明
function SettingGUI:RightBtnPnlInit()
    for k, v in pairs(self.SetFig.BtnPnl.BgImg:GetChildren()) do
        self[tostring(v)] = v
    end
end

---左侧面板节点
function SettingGUI:LeftSetFigInit()
    for k, v in pairs(self.SetFig:GetChildren()) do
        self[tostring(v)] = v
    end
end

---开关节点控制器
---@param _bool 期望的布尔值
---@param _tarTab 目标表格
---@param _spNode 排除节点
function SettingGUI:SwitchNodeCtr(_bool, _tarTab, _spNode)
    for k, v in pairs(_tarTab) do
        if v == _spNode then
            v:SetActive(not _bool)
        else
            v:SetActive(_bool)
        end
    end
end

---右侧按键绑定函数
function SettingGUI:KeyBinding()
    ---打开设置
    self.SettingBtn.OnClick:Connect(
        function()
            self.SettingBtn:SetActive(false)
            self.SetFig:SetActive(true)
        end
    )

    ---关闭设置
    self.SetClose.OnClick:Connect(
        function()
            self.SetFig:SetActive(false)
            self.SettingBtn:SetActive(true)
            ---记录数据
            self:RecordSettingData()
        end
    )

    for k, v in pairs(self.SetFig.BtnPnl.BgImg:GetChildren()) do
        self[tostring(v)].OnClick:Connect(
            function()
                self:SwitchNodeCtr(false, self.SetPnlCtr, self[string.gsub(tostring(v), 'Set', '') .. 'Pnl'])
            end
        )
    end
end

---创建滑条类
function SettingGUI:CreateSliderClass(_obj, _maxValue, _minValue)
    local SliderEntity = SettingGUI:New(_obj, _maxValue, _minValue)
    SliderEntity:Inititial()

    local oneData = {
        Entity = SliderEntity,
        obj = _obj,
        MaxValue = _maxValue,
        MinValue = _minValue
    }
    table.insert(self.SliderClassTab, oneData)
end

---析构全部滑条类
function SettingGUI:DestAllSliderClass()
    for k, v in pairs(self.SliderClassTab) do
        v.Entity:Destructor()
    end
end

---在关闭设置界面后记录玩家的设置数据
function SettingGUI:RecordSettingData()
    for k, v in pairs(self.SliderClassTab) do
        if v.obj == self.BasePnl.ImgSlider then
            localPlayer.C_Event.SettingAssAimRefreshEvent:Fire(v.Entity.NowValue)
            world.S_Event.PlayerDataModifiEvent:Fire(localPlayer, 'defaultSens', v.Entity.NowValue)
        end
    end
    world.S_Event.SyncAndSaveEvent:Fire(localPlayer)
end

---基础设置面板执行逻辑
function SettingGUI:BasePnlSetting()
    self.BtnTrue = self.BasePnl.AssAimFig.BtnTrue
    self.BtnFalse = self.BasePnl.AssAimFig.BtnFalse
    self.BasePnl.ImgSlider:SetActive(false)

    self.BtnTrue.OnClick:Connect(
        function()
            self.BtnTrue.Color = Color(255, 255, 255, 255)
            self.BtnFalse.Color = Color(0, 0, 0, 255)
            self.BasePnl.ImgSlider:SetActive(true)
        end
    )

    self.BtnFalse.OnClick:Connect(
        function()
            self.BtnTrue.Color = Color(0, 0, 0, 255)
            self.BtnFalse.Color = Color(255, 255, 255, 255)
            self.BasePnl.ImgSlider:SetActive(false)
        end
    )

    self:CreateSliderClass(self.BasePnl.ImgSlider, 10, 0)
end

---灵敏度设置面板执行逻辑
function SettingGUI:SensPnlSetting()
    for k, v in pairs(self.SensPnl:GetChildren()) do
        self:CreateSliderClass(v, 100, 0)
    end
end

---准星设置面板执行逻辑
function SettingGUI:CrosshairPnlSetting()
    self.TitleBg = self.CrosshairPnl.CrosshairBg.TitleBg
    self.ContentBg = self.CrosshairPnl.CrosshairBg.ContentBg

    for k, v in pairs(self.TitleBg:GetChildren()) do
        self[tostring(v)] = v
    end

    for m, n in pairs(self.ContentBg:GetChildren()) do
        self[tostring(n)] = n
    end

    self.CrosshairCtr = {
        self.CroPnlDe,
        self.CroPnlRd,
        self.CroPnlHo,
        self.CroPnl2x,
        self.CroPnl3x
    }
    self:SwitchNodeCtr(false, self.CrosshairCtr, self.CroPnlDe)
end

---准星按钮事件绑定
function SettingGUI:CrosshairKeyBinding()
    for k, v in pairs(self.TitleBg:GetChildren()) do
        self[tostring(v)].OnClick:Connect(
            function()
                self:SwitchNodeCtr(false, self.CrosshairCtr, self['CroPnl' .. string.gsub(tostring(v), 'Choose', '')])
            end
        )
    end
end

---操作设置面板执行逻辑
---暂时用作开发工具
function SettingGUI:OperationPnlSetting()
end

---监听函数
function SettingGUI:InitListener()
    LinkConnects(localPlayer.C_Event, SettingGUI, this)
end

---Update函数
function SettingGUI:Update()
end

---将滑块实例与代码实例绑定
---@param _obj 目标滑块UI实例
---@param _MaxValue 滑块区间的最大值
---@param _MinValue 滑块区间的最小值..可不传..默认为0
function SettingGUI:New(_obj, _MaxValue, _MinValue)
    ---初始化屏幕参数
    VPX = self.root.Size.x
    VPY = self.root.Size.y
    X_2000 = VPX / 2000
    Y_1000 = VPY / 1000
    PixelX = X_2000 < Y_1000 and 2000 or X_2000 / Y_1000 * 2000
    PixelY = Y_1000 < X_2000 and 1000 or Y_1000 / X_2000 * 1000

    local tSlider = {}
    setmetatable(tSlider, self)
    self.__index = self

    tSlider.BtnSub = _obj.BtnSub
    tSlider.BtnAdd = _obj.BtnAdd

    tSlider.TxtCountMax = _obj.TxtCountMax
    tSlider.TxtCountNow = _obj.TxtCountNow
    tSlider.MaxValue = _MaxValue
    tSlider.MinValue = _MinValue or 0
    tSlider.NowValue = tSlider.MinValue

    tSlider.ImgBar = _obj.ImgBar
    tSlider.ImgHandle = _obj.ImgBar.ImgHandle
    tSlider.ImgArea = _obj.ImgBar.ImgArea
    tSlider.APart = tSlider.ImgBar.Size.x / (tSlider.MaxValue - tSlider.MinValue)

    ---鼠标滑动参数
    tSlider.MouseIn = false

    return tSlider
end

---滑块类的初始化
function SettingGUI:Inititial()
    ---减号按键
    self.BtnSub.OnClick:Connect(
        function()
            self:SubNum()
        end
    )

    ---加号按键
    self.BtnAdd.OnClick:Connect(
        function()
            self:AddNum()
        end
    )

    ---滑条触控区域
    self.ImgArea.OnTouched:Connect(
        function(_info)
            self:TapSlid(_info)
        end
    )

    ---鼠标滑动逻辑，测试用，上线请注释掉
    self.ImgArea.OnEnter:Connect(
        function()
            self.MouseIn = true
        end
    )
    self.ImgArea.OnLeave:Connect(
        function()
            self.MouseIn = false
        end
    )

    ---无法释放，保留在外部Connect便于析构
    world.OnRenderStepped:Connect(
        function()
            self:MouseSlid()
        end
    )

    self:Refresh()
end

---析构，解绑操作函数
function SettingGUI:Destructor()
    self.BtnSub.OnClick:Clear()
    self.BtnAdd.OnClick:Clear()
    self.ImgArea.OnTouched:Clear()
    ---鼠标滑动逻辑，测试用，上线请注释掉
    self.ImgArea.OnEnter:Clear()
    self.ImgArea.OnLeave:Clear()
end

---减号操作函数
function SettingGUI:SubNum()
    self.NowValue = self.NowValue > self.MinValue and self.NowValue - 1 or self.NowValue
    self:Refresh()
end

---加号操作函数
function SettingGUI:AddNum()
    self.NowValue = self.NowValue < self.MaxValue and self.NowValue + 1 or self.NowValue
    self:Refresh()
end

---数字滑块刷新函数
function SettingGUI:Refresh()
    self.TxtCountNow.Text = tostring(self.NowValue)
    self.TxtCountMax.Text = tostring(self.MaxValue)
    self.ImgHandle.Offset = Vector2(self.APart * self.NowValue, self.ImgHandle.Offset.y)
end

---获取一个UI的Pivot在屏幕上的位置
---@param _obj 目标UI实例
---@param _v2 已得偏移量..递归用..默认不传
function SettingGUI:UiScreenPos(_obj, _v2)
    if _v2 then
        if _obj.Parent.ClassName == 'UiScreenUiObject' then
            return _v2 +
                Vector2(
                    PixelX * (_obj.AnchorsX.x + _obj.AnchorsX.y) / 2 - _obj.FinalSize.x * _obj.Pivot.x,
                    PixelY * (_obj.AnchorsY.x + _obj.AnchorsY.y) / 2 - _obj.FinalSize.y * _obj.Pivot.y
                ) +
                _obj.Offset
        else
            return _v2 +
                self:UiScreenPos(
                    _obj.Parent,
                    Vector2(
                        _obj.Parent.FinalSize.x * (_obj.AnchorsX.x + _obj.AnchorsX.y) / 2 -
                            _obj.FinalSize.x * _obj.Pivot.x,
                        _obj.Parent.FinalSize.y * (_obj.AnchorsY.x + _obj.AnchorsY.y) / 2 -
                            _obj.FinalSize.y * _obj.Pivot.y
                    ) + _obj.Offset
                )
        end
    else
        _v2 = Vector2.Zero
        if _obj.Parent.ClassName == 'UiScreenUiObject' then
            return _v2 +
                Vector2(
                    PixelX * (_obj.AnchorsX.x + _obj.AnchorsX.y) / 2,
                    PixelY * (_obj.AnchorsY.x + _obj.AnchorsY.y) / 2
                ) +
                _obj.Offset
        else
            return _v2 +
                self:UiScreenPos(
                    _obj.Parent,
                    Vector2(
                        _obj.Parent.FinalSize.x * (_obj.AnchorsX.x + _obj.AnchorsX.y) / 2,
                        _obj.Parent.FinalSize.y * (_obj.AnchorsY.x + _obj.AnchorsY.y) / 2
                    ) + _obj.Offset
                )
        end
    end
end

---获取一个UI的Pivot转换为目标屏幕位置时的Offset值
---@param _obj 目标UI实例
---@param _v2 目标的屏幕坐标
function SettingGUI:ScreenPosToOffset(_obj, _v2)
    _v2 = Vector2(_v2.x / VPX * PixelX, _v2.y / VPY * PixelY)
    return _v2 - self:UiScreenPos(_obj) + _obj.Offset
end

---手机端滑块操作函数
---@param _info OnTouched参数
function SettingGUI:TapSlid(_info)
    local OffsetX =
        math.clamp(
        self:ScreenPosToOffset(self.ImgHandle, _info[1].Position).x,
        0,
        self.APart * (self.MaxValue - self.MinValue)
    )
    local Mod1, Mod2 = math.modf(OffsetX / self.APart)
    self.NowValue = Mod2 > 0.5 and Mod1 + 1 or Mod1
    self.TxtCountNow.Text = tostring(self.NowValue)
    self.TxtCountMax.Text = tostring(self.MaxValue)
    self.ImgHandle.Offset = Vector2(OffsetX, self.ImgHandle.Offset.y)
end

---鼠标滑块操作函数
function SettingGUI:MouseSlid()
    if self.MouseIn and Input.GetPressKeyData(Enum.KeyCode.Mouse0) > 0 then
        local OffsetX =
            math.clamp(
            self:ScreenPosToOffset(self.ImgHandle, Input.GetMouseScreenPos()).x,
            self.APart * self.MinValue,
            self.APart * self.MaxValue
        )
        local Mod1, Mod2 = math.modf(OffsetX / self.APart)
        self.NowValue = Mod2 > 0.5 and Mod1 + 1 or Mod1
        self.TxtCountNow.Text = tostring(self.NowValue)
        self.TxtCountMax.Text = tostring(self.MaxValue)
        self.ImgHandle.Offset = Vector2(OffsetX, self.ImgHandle.Offset.y)
    end
end

return SettingGUI
