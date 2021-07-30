--- 游戏中的UI节点管理类
--- @module UIBase utilities
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local UIBase = class('UIBase')

---UI列表
UIBase.uiList = {}
---UI动画枚举
UIBase.AniTypeEnum = {
    None = -1, ---无动效
    Scale = 1 ---缩放效果
}
---UI动画播放状态
UIBase.AniStateEnum = {
    None = -1, ---无状态
    Playing = 1, ---播放中
    Completed = 2 ---播放完成
}

---创建
---@param _strOrObj any 字符串或者对象,若为字符串,则创建一个对象,若为对象则以此对象为UI
---@param _aniType number 动效类型
---@param _parent Object 若要创建,则创建的UI的父物体
function UIBase:initialize(_strOrObj, _aniType, _parent)
    self.m_ui = nil
    self.m_eventHandler = {}
    self.m_events = {}
    ---事件的音效播放函数
    self.m_eventsSound = {}
    self.m_aniType = _aniType or UIBase.AniTypeEnum.None
    ---当前播放的动画绑定的事件名称
    self.m_curAni = nil
    ---动画播放状态
    self.m_aniState = UIBase.AniStateEnum.None
    if type(_strOrObj) == 'string' then
        ---需要创建一个UI
        self.m_ui =
            world:CreateInstance(_strOrObj, _strOrObj, _parent) or world:CreateObject(_strOrObj, _strOrObj, _parent)
    elseif type(_strOrObj) == 'userdata' then
        ---已经存在这个UI
        self.m_ui = _strOrObj
    else
        error('请检查输入参数')
    end
    UIBase.uiList = UIBase.uiList or {}
    table.insert(UIBase.uiList, self)
end

---销毁
function UIBase:Destroy()
    self:Trigger('OnDestroyed')
    if self.m_ui and not self.m_ui:IsNull() then
        self.m_ui:Destroy()
    end
    for i, v in pairs(self) do
        self[i] = nil
    end
    table.removebyvalue(UIBase.uiList, self)
    self = nil
end

---更改属性
---@param _key string ui的属性名称
---@param _value any 设置的值
function UIBase:SetValue(_key, _value)
    local isUpdate = false
    if _key == 'AnchorsX' or _key == 'AnchorsY' or _key == 'Size' then
        isUpdate = true
    end
    local path = string.split(_key, '.')
    local ui = self.m_ui
    if #path > 0 then
        _key = path[#path]
        for i = 1, #path - 1 do
            ui = ui[path[i]]
        end
    end
    ui[_key] = _value
    if isUpdate then
        invoke(
            function()
                wait()
                if self.m_ui and not self.m_ui:IsNull() then
                    self:UpdateAniData()
                end
            end
        )
    end
end

---获取属性
---@param _key string ui的属性名称
function UIBase:GetValue(_key)
    local path = string.split(_key, '.')
    local ui = self.m_ui
    if #path > 0 then
        _key = path[#path]
        for i = 1, #path - 1 do
            ui = ui[path[i]]
        end
    end
    return ui[_key]
end

---调用节点函数
---@param _func string 函数名称
function UIBase:CallFunction(_func, ...)
    return self.m_ui[_func](self.m_ui, ...)
end

---更新动画数值
function UIBase:UpdateAniData()
end

---设置音效
---@param _event string 事件名称
---@param _soundId number 播放的音效ID
function UIBase:SetSound(_event, _soundId)
    local Play = function()
        SoundUtil:PlaySound(_soundId)
    end
    self.m_eventsSound[_event] = Play
end

---绑定事件
---@param _event string 事件的名字
---@param _handler function 事件的处理函数
function UIBase:BindHandler(_event, _handler, ...)
    assert(type(_handler) == 'function', '处理函数类型不正确')
    if not self.m_eventHandler[_event] then
        self.m_eventHandler[_event] = {}
        local function EventHandler(...)
            self:Trigger(_event, ...)
        end
        self.m_events[_event] = EventHandler
        self.m_ui[_event]:Connect(EventHandler)
    end
    table.insert(self.m_eventHandler[_event], {_handler, ...})
end

---更新函数
function UIBase:Update(_dt)
    self:UpdateAni(_dt)
end

---事件触发
function UIBase:Trigger(_event, ...)
    if not self.m_eventHandler[_event] then
        return
    end
    for i, v in pairs(self.m_eventHandler[_event]) do
        local handler = v[1]
        local params = {}
        for index = 1, #v - 1 do
            params[index] = v[index + 1]
        end
        if #params == 0 then
            handler(...)
        else
            handler(table.unpack(params), ...)
        end
    end
    ---播放事件触发的UI动画
    self:PlayAnimation(_event)
    ---播放事件触发的音效
    self:PlaySound(_event)
end

---动效播放
---@param _event string 事件名称
function UIBase:PlayAnimation(_event)
end

---音效播放
---@param _event string 事件的名字
function UIBase:PlaySound(_event)
end

---动效更新
function UIBase:UpdateAni(_dt)
end

---解绑事件,若不填具体函数则解绑所有同名事件
---@param _event string 事件的名字
---@param _handler function 事件的处理函数
function UIBase:UnbindHandler(_event, _handler)
    if _handler then
        for i, v in pairs(self.m_eventHandler[_event]) do
            if v[1] == _handler then
                table.remove(self.m_eventHandler[_event], i)
            end
        end
    else
        self.m_eventHandler[_event] = nil
    end
    if not self.m_eventHandler[_event] or self.m_eventHandler[_event] == {} then
        self.m_eventHandler[_event] = nil
        self.m_ui[_event]:Disconnect(self.m_events[_event])
    end
end

---按钮基础类
---@module ButtonBase:UIBase
local ButtonBase = class('ButtonBase', UIBase)

function ButtonBase:initialize(_strOrObj, _aniType, _parent)
    UIBase.initialize(self, _strOrObj, _aniType, _parent)
    ---按钮当前时候被按下
    self.m_isPressed = false
    ---是否长按的倒计时
    self.m_longPressCD = 1
    self:UpdateAniData()
    ---每帧更改的尺寸
    self.m_deltaSize = function(_dt)
        return (self.m_startFinalSize - self.m_endFinalSize) * _dt / 0.08
    end
    ---按钮动画事件绑定
    if _aniType ~= UIBase.AniTypeEnum.None then
        local function Nothing()
        end
        self:BindHandler('OnDown', Nothing)
        self:BindHandler('OnUp', Nothing)
    end
end

---按钮事件的绑定,暂时只支持 按下 抬起 点击 长按四种事件
---@param _event string 事件的名字
---@param _handler function 事件的处理函数
function ButtonBase:BindHandler(_event, _handler, ...)
    if _event == 'OnUp' then
        ---若绑定的是抬起事件,需要同时注册在隐藏和销毁事件上
        local func = function(...)
            if self.m_isPressed then
                _handler(...)
            end
        end
        UIBase.BindHandler(self, 'OnUp', _handler, ...)
        UIBase.BindHandler(self, 'OnDestroyed', func, ...)
        UIBase.BindHandler(self, 'OnDeactiveInHierarchy', func, ...)
    elseif _event == 'OnLongPress' then
        ---绑定的是长按事件
        assert(type(_handler) == 'function', '处理函数类型不正确')
        if not self.m_eventHandler[_event] then
            self.m_eventHandler[_event] = {}
            local function EventHandler(...)
                self:Trigger(_event, ...)
            end
            self.m_events[_event] = EventHandler
        end
        table.insert(self.m_eventHandler[_event], {_handler, ...})
    else
        UIBase.BindHandler(self, _event, _handler, ...)
    end
end

---动效播放
---@param _event string 事件名称
function ButtonBase:PlayAnimation(_event)
    if self.m_aniType == UIBase.AniTypeEnum.None then
        ---当前UI组件没有设置动画
        return
    end
    if _event == 'OnDown' or _event == 'OnUp' then
        self.m_curAni = _event
        self.m_aniState = UIBase.AniStateEnum.Playing
        return
    end
    if _event == 'OnDestroyed' or _event == 'OnDeactiveInHierarchy' then
        if self.m_isPressed then
            self.m_curAni = 'OnUp'
            self.m_aniState = UIBase.AniStateEnum.Playing
        end
    end
end

---音频播放重写
---@param _event string 事件的名字
function ButtonBase:PlaySound(_event)
    local playFunc = self.m_eventsSound[_event]
    if _event == 'OnDestroyed' or _event == 'OnDeactiveInHierarchy' then
        if self.m_isPressed then
            ---当前按钮按下状态,播放抬起的音效
            playFunc = self.m_eventsSound['OnUp']
        end
    end
    if not playFunc then
        ---此事件没有设置音效
        return
    end
    playFunc()
end

function ButtonBase:UpdateAniData()
    ---动画的数据
    self.m_startFinalSize = self.m_ui.FinalSize
    self.m_endFinalSize = self.m_startFinalSize * 0.8
    self.m_startSize = self.m_ui.Size
    self.m_endSize = self.m_startSize - self.m_startFinalSize + self.m_endFinalSize
end

---更新方法
function ButtonBase:Update(_dt)
    if self.m_isPressed then
        if self.m_longPressCD > 0 and self.m_longPressCD - _dt <= 0 then
            ---触发长按事件
            self:Trigger('OnLongPress')
        end
        self.m_longPressCD = self.m_longPressCD - _dt
    else
        self.m_longPressCD = 1
    end
    UIBase.Update(self, _dt)
end

---更新动画
function ButtonBase:UpdateAni(_dt)
    if self.m_aniType == UIBase.AniTypeEnum.None then
        ---组件无动画
        return
    end
    if self.m_aniType == UIBase.AniTypeEnum.Scale then
        ---当前是缩放动画
        if self.m_aniState ~= UIBase.AniStateEnum.Playing then
            return
        end
        if self.m_curAni == 'OnDown' then
            self.m_ui.Size = self.m_ui.Size - self.m_deltaSize(_dt)
            if self.m_ui.FinalSize.Magnitude <= self.m_endFinalSize.Magnitude then
                ---按下的动画播放完成
                self.m_aniState = UIBase.AniStateEnum.Completed
                self.m_ui.Size = self.m_endSize
            end
        end
        if self.m_curAni == 'OnUp' then
            self.m_ui.Size = self.m_ui.Size + self.m_deltaSize(_dt)
            if self.m_ui.FinalSize.Magnitude >= self.m_startFinalSize.Magnitude then
                ---抬起的动画播放完成
                self.m_aniState = UIBase.AniStateEnum.Completed
                self.m_ui.Size = self.m_startSize
            end
        end
    end
end

---触发方法
function ButtonBase:Trigger(_event, ...)
    if _event == 'OnDown' then
        self.m_isPressed = true
        self.m_longPressCD = 1
    elseif _event == 'OnUp' then
        self.m_isPressed = false
        self.m_longPressCD = 1
    end
    UIBase.Trigger(self, _event, ...)
end

---图形基础类,暂时没有特殊需求
---@module FigureBase:UIBase
local FigureBase = class('FigureBase', UIBase)

---图片基础类
---@module ImageBase:UIBase
local ImageBase = class('ImageBase', UIBase)

---图片基础类
---@module InputFieldBase:UIBase
local InputField = class('InputField', UIBase)

---面板基础类
---@module PanelBase:UIBase
local PanelBase = class('PanelBase', UIBase)

---子物体对齐方式枚举
PanelBase.AlignmentEnum = {
    Left_Top = 1,
    Center_Top = 2,
    Left_Middle = 3
}

---面板中元素的排布方式
PanelBase.LayoutTypeEnum = {
    Horizontal = 1,
    Vertical = 2,
    Grid = 3
}

function PanelBase:initialize(_strOrObj, _aniType, _parent)
    ---左上为默认对齐方式
    self.m_alignment = PanelBase.AlignmentEnum.Left_Top
    ---默认的面板边框和内容之间的空间
    self.m_padding = {
        Left = 10,
        Right = 10,
        Top = 10,
        Bottom = 10
    }
    ---元素之间的距离
    self.m_spacing = 8
    ---元素排布方式,默认网格
    self.m_layoutType = PanelBase.LayoutTypeEnum.Grid
    ---元素大小
    self.m_childSize = Vector2(80, 80)
    ---子物体列表
    self.m_childrenUI = {}
    ---是否启用滑动条
    self.m_enableScroll = false
    ---当前总行数
    self.m_totalRow = 0
    ---当前总列数
    self.m_totalColumn = 0
    ---上一帧所有子物体的偏移
    self.m_preOffsetLst = {}
    ---这一帧所有子物体的偏移
    self.m_curOffsetLst = {}
    UIBase.initialize(self, _strOrObj, _aniType, _parent)
end

---向面板中添加子物体,面板会自动进行布局
---@param _child UIBase 待添加的对象
---@param _index number 添加的对象索引
function PanelBase:AddItem(_child, _index)
    ---设置子物体的尺寸以方便面板的布局
    _child:SetValue('AnchorsX', Vector2.One * 0.5)
    _child:SetValue('AnchorsY', Vector2.One * 0.5)
    _child:SetValue('Size', self.m_childSize)
    _child:SetValue('Pivot', Vector2(0, 1))
    _child:SetValue('Offset', Vector2.One * 10000) --让面板自行更新偏移
    local DestroyEvent = function()
        self:RemoveItem(_child)
    end
    _child:BindHandler('OnDestroyed', DestroyEvent)
    table.insert(self.m_childrenUI, _index, _child)
    self:RefreshLayout()
end

---从面板中移除子物体
---@param _child UIBase 待移除的对象
function PanelBase:RemoveItem(_child)
    table.removebyvalue(self.m_childrenUI, _child)
    self:RefreshLayout()
end

---刷新面板中子物体的排布,暂时按照左上,网格进行排布
function PanelBase:RefreshLayout()
    if #self.m_childrenUI == 0 then
        return
    end
    if self.m_layoutType == PanelBase.LayoutTypeEnum.Horizontal then
        self:HorizontalLayout()
    elseif self.m_layoutType == PanelBase.LayoutTypeEnum.Vertical then
        self:VerticalLayout()
    else
        self:GridLayout()
    end
    ---是否开启滑动条
    self:CheckEnableScroll()
end

---网格刷新
function PanelBase:GridLayout()
    ---面板真实尺寸
    local finalSize = self.m_ui.FinalSize
    local childrenNum = #self.m_childrenUI
    local columnNum = (finalSize.X - self.m_padding.Left - self.m_padding.Right) / (self.m_childSize.X + self.m_spacing)
    columnNum = math.floor(columnNum)
    self.m_totalRow = #self.m_childrenUI / columnNum
    self.m_totalRow =
        self.m_totalRow == math.floor(self.m_totalRow) and math.floor(self.m_totalRow) - 1 or
        math.floor(self.m_totalRow)
    self.m_totalRow = self.m_totalRow + 1
    self.m_totalColumn = childrenNum < columnNum and childrenNum or columnNum
    ---第一个元素左上角的位置,按照面板左上为原点
    local startPos
    if self.m_alignment == PanelBase.AlignmentEnum.Left_Middle then
        ---左中对齐
        startPos =
            Vector2(
            self.m_padding.Left,
            finalSize.Y * 0.5 - (self.m_totalRow * (self.m_childSize.Y + self.m_spacing) - self.m_spacing) * 0.5
        )
    elseif self.m_alignment == PanelBase.AlignmentEnum.Left_Top then
        ---左上对齐
        startPos = Vector2(self.m_padding.Left, self.m_padding.Top)
    elseif self.m_alignment == PanelBase.AlignmentEnum.Center_Top then
        ---上中对齐
        if self.m_totalRow == 1 then
            startPos =
                Vector2(
                finalSize.X * 0.5 - (self.m_totalColumn * (self.m_childSize.X + self.m_spacing) - self.m_spacing) * 0.5,
                self.m_padding.Top
            )
        else
            startPos = Vector2(self.m_padding.Left, self.m_padding.Top)
        end
    end

    startPos = Vector2(-finalSize.X * 0.5 + startPos.X, startPos.Y)
    local finalPos = {}
    for i, v in pairs(self.m_childrenUI) do
        ---当前元素的行数
        local row = i / columnNum
        row = row == math.floor(row) and math.floor(row) - 1 or math.floor(row)
        row = row + 1
        ---当前元素的列数
        local column = i % columnNum == 0 and columnNum or i % columnNum
        local pos
        pos =
            Vector2(
            (column - 1) * (self.m_childSize.X + self.m_spacing),
            (row - 1) * (self.m_childSize.Y + self.m_spacing)
        )
        pos = pos + startPos
        pos =
            Vector2(pos.X, finalSize.Y - pos.Y) - Vector2(0, 2) * self.m_padding.Top -
            Vector2(0, 1) * (0.5 * finalSize.Y - 2 * self.m_padding.Top)
        if self.m_alignment == PanelBase.AlignmentEnum.Center_Top then
            ---上中对齐
            if row == self.m_totalRow and row ~= 1 then
                ---当前是最后一行
                local col_last =
                    childrenNum % self.m_totalColumn == 0 and self.m_totalColumn or childrenNum % self.m_totalColumn
                local startX = finalSize.X - col_last * (self.m_childSize.X + self.m_spacing) + self.m_spacing
                startX = startX * 0.5
                local col_cur = i % self.m_totalColumn == 0 and self.m_totalColumn or i % self.m_totalColumn
                local x = startX + (col_cur - 1) * (self.m_spacing + self.m_childSize.X) - finalSize.X * 0.5
                pos = Vector2(x, pos.Y)
            end
        end
        finalPos[i] = pos
        self.m_curOffsetLst[v] = pos
    end
end

---垂直刷新
function PanelBase:VerticalLayout()
    self.m_totalColumn = 1
    local finalSize = self.m_ui.FinalSize
    self.m_totalRow = #self.m_childrenUI
    ---第一个元素左上角的位置
    local startPos
    if self.m_alignment == PanelBase.AlignmentEnum.Left_Middle then
        startPos =
            Vector2(
            self.m_padding.Left,
            finalSize.Y * 0.5 - (self.m_totalRow * (self.m_childSize.Y + self.m_spacing) - self.m_spacing) * 0.5
        )
    elseif self.m_alignment == PanelBase.AlignmentEnum.Center_Top then
        startPos = Vector2(finalSize.X * 0.5 - self.m_childSize.X * 0.5, self.m_padding.Top)
    else
        startPos = Vector2(self.m_padding.Left, self.m_padding.Top)
    end

    startPos = Vector2(-finalSize.X * 0.5 + startPos.X, finalSize.Y * 0.5 - startPos.Y)
    local finalPos = {}
    for i, v in pairs(self.m_childrenUI) do
        local pos = Vector2(0, (i - 1) * (self.m_childSize.Y + self.m_spacing))
        pos = startPos - pos
        finalPos[i] = pos
        self.m_curOffsetLst[v] = pos
    end
end

---水平刷新
function PanelBase:HorizontalLayout()
    self.m_totalRow = 1
    local finalSize = self.m_ui.FinalSize
    self.m_totalColumn = #self.m_childrenUI
    ---第一个元素左上角的位置
    local startPos
    if self.m_alignment == PanelBase.AlignmentEnum.Left_Top then
        startPos = Vector2(self.m_padding.Left, self.m_padding.Top)
    elseif self.m_alignment == PanelBase.AlignmentEnum.Left_Middle then
        startPos = Vector2(self.m_padding.Left, finalSize.Y * 0.5 - self.m_childSize.Y * 0.5)
    elseif self.m_alignment == PanelBase.AlignmentEnum.Center_Top then
        ---上中对齐
        startPos =
            Vector2(
            finalSize.X * 0.5 - (self.m_totalColumn * (self.m_childSize.X + self.m_spacing) - self.m_spacing) * 0.5,
            self.m_padding.Top
        )
    end
    startPos = Vector2(-finalSize.X * 0.5 + startPos.X, finalSize.Y * 0.5 - startPos.Y)
    local finalPos = {}
    for i, v in pairs(self.m_childrenUI) do
        local pos = Vector2((i - 1) * (self.m_childSize.X + self.m_spacing), 0)
        pos = startPos + pos
        finalPos[i] = pos
        self.m_curOffsetLst[v] = pos
    end
end

---设置对其方式
function PanelBase:SetAlignment(_alignment)
    self.m_alignment = _alignment
    self:RefreshLayout()
end

---设置padding
function PanelBase:SetPadding(_padding)
    self.m_padding = _padding
    self:RefreshLayout()
end

---设置元素之间的距离
function PanelBase:SetSpacing(_spacing)
    self.m_spacing = _spacing
    self:RefreshLayout()
end

---设置元素排布方式
function PanelBase:SetLayoutType(_type)
    self.m_layoutType = _type
    self:RefreshLayout()
end

---检测当前子物体数量是否满足开启滑动条的条件
function PanelBase:CheckEnableScroll()
    local type
    if
        (self.m_childSize.Y + self.m_spacing) * self.m_totalRow >
            self.m_ui.FinalSize.Y - self.m_padding.Top - self.m_padding.Bottom
     then
        self.m_enableScroll = true
        type = Enum.ScrollBarType.Vertical
    elseif
        (self.m_childSize.X + self.m_spacing) * self.m_totalColumn >
            self.m_ui.FinalSize.X - self.m_padding.Left - self.m_padding.Right
     then
        self.m_enableScroll = true
        type = Enum.ScrollBarType.Horizontal
    else
        self.m_enableScroll = false
        type = Enum.ScrollBarType.None
    end
    self.m_ui.Scroll = type
    local range =
        self.m_padding.Top + (self.m_childSize.Y + self.m_spacing) * self.m_totalRow + self.m_ui.FinalSize.Y * 0.5
    self.m_ui.ScrollRange = range
end

---当前UI发生更改后的动画更新
function PanelBase:PosAnimation()
    for i, v in pairs(self.m_childrenUI) do
        local pre = self.m_preOffsetLst[v]
        local cur = self.m_curOffsetLst[v]
        if pre and cur then
            ---这个UI之前存在
            local delta = cur - pre
            delta = delta * 0.1
            v:SetValue('Offset', pre + delta)
            self.m_preOffsetLst[v] = pre + delta
        elseif pre and not cur then
            ---这个索引的UI现在没有了
            self.m_preOffsetLst[v] = nil
        elseif not pre and cur then
            ---这个索引的UI新出现的
            self.m_preOffsetLst[v] = cur
        end
    end
end

---面板销毁
function PanelBase:Destroy()
    ---先销毁子元素
    for i, v in pairs(self.m_childrenUI) do
        v:Destroy()
    end
    UIBase.Destroy(self)
end

---对子元素进行重排
---@param _func function 排序函数
function PanelBase:Sort(_func)
    table.sort(self.m_childrenUI, _func)
end

function PanelBase:UpdateAni(_dt)
    self:PosAnimation()
end

---文字UI
---@module TextBase:UIBase
local TextBase = class('TextBase', UIBase)

---2DUI面板
---@module ScreenUIBase:UIBase
local ScreenUIBase = class('ScreenUIBase', UIBase)

---3DUI面板
---@module SurfaceUIBase:UIBase
local SurfaceUIBase = class('SurfaceUIBase', UIBase)

local function Load()
    _G.ButtonBase = ButtonBase
    _G.FigureBase = FigureBase
    _G.ImageBase = ImageBase
    _G.InputField = InputField
    _G.PanelBase = PanelBase
    _G.ScreenUIBase = ScreenUIBase
    _G.SurfaceUIBase = SurfaceUIBase
    _G.TextBase = TextBase
end

return UIBase, Load()
