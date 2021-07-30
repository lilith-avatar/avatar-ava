--- @module DragUI 枪械模块：拖动UI
--- @copyright Lilith Games, Avatar Team
--- @author RopzTao
local DragUI, this = {}, nil

---屏幕参数
local VPX, VPY, X_2000, Y_1000, PixelX, PixelY = nil, nil, nil, nil, nil, nil

---UIanchors的x和y值
local function AnchorsXY(_tarUI)
    return Vector2(_tarUI.AnchorsX.x, _tarUI.AnchorsY.y)
end

---UI拖放初始化
function DragUI:Init()
    self.root = world:CreateInstance('TestScr', 'TestScr', localPlayer.Local)
    self.MouseIn = false
    self.root:SetActive(false)

    invoke(
        function()
            ---创建拖动UI
            local testBtn = world:CreateInstance('TestBtn', 'TestBtn', self.root)
            local DragUIEntity = DragUI:New(testBtn)
            testBtn:ToTop()
            testBtn:SetActive(false)
            ---DragUIEntity:Inititial()
        end,
        5
    )
end

---Update函数
function DragUI:Update(_deltaTime)
end

function DragUI:New(_obj)
    ---初始化底板参数
    VPX = self.root.Size.x
    VPY = self.root.Size.y

    local tDragUI = {}
    setmetatable(tDragUI, self)
    self.__index = self

    ---目标显示ui
    tDragUI.Base = _obj
    ---手指识别范围
    tDragUI.BtnIdentify = _obj.BtnIdentify
    return tDragUI
end

---析构解绑函数
function DragUI:Destructor()
    self.BtnIdentify.OnTouched:Clear()
    ---鼠标滑动逻辑，测试用，上线请注释掉
    self.BtnIdentify.OnEnter:Clear()
    self.BtnIdentify.OnLeave:Clear()
end

---拖动UI的初始化函数
function DragUI:Inititial()
    ---1.判断鼠标和手指是否在指定UI范围内..手指
    self.BtnIdentify.OnTouched:Connect(
        function(_touchInfo)
            self:GetFingerPos(_touchInfo)
        end
    )

    ---识别区域逻辑
    self.BtnIdentify.OnDown:Connect(
        function()
            self.BtnIdentify.Size = Vector2(700, 700)
            if world:GetDevicePlatform() == Enum.Platform.Windows then
                self.MouseIn = true
            end
            self:OnDragBegin()
        end
    )

    self.BtnIdentify.OnUp:Connect(
        function()
            self.BtnIdentify.Size = Vector2(200, 200)
            if world:GetDevicePlatform() == Enum.Platform.Windows then
                self.MouseIn = false
            end
            self:OnDragEnd()

            ---松手判断是否要媳妇
            self:DragBox(self.Base, self.root.TarBox)
        end
    )

    ---无法释放，保留在外部Connect便于析构
    world.OnRenderStepped:Connect(
        function()
            if self.MouseIn then
                self:GetMousePos()
            end
        end
    )
end

---2.获取鼠标和手指的位置（屏幕坐标）..手指
function DragUI:GetFingerPos(_touchInfo)
    local fingerPos, tarPos
    for k, v in pairs(_touchInfo) do
        ---触摸信息
        fingerPos = v.Position
    end
    tarPos = Vector2(fingerPos.x / VPX, fingerPos.y / VPY)

    self:DisplayUIAtTarPos(tarPos)
end

---2.获取鼠标和手指的位置（屏幕坐标）..鼠标
function DragUI:GetMousePos()
    local mousePos, tarPos
    mousePos = Input.GetMouseScreenPos()
    tarPos = Vector2(mousePos.x / VPX, mousePos.y / VPY)

    self:DisplayUIAtTarPos(tarPos)
end

---3.让UI显示在鼠标和手指的位置..手指
function DragUI:DisplayUIAtTarPos(_tarPos)
    self.Base.AnchorsX = Vector2(_tarPos.x, _tarPos.x)
    self.Base.AnchorsY = Vector2(_tarPos.y, _tarPos.y)
end

---4.按下，松开执行函数
function DragUI:OnDragBegin()
end

function DragUI:OnDragEnd()
end

---5.防止出屏幕，设定可拖拽范围
function DragUI:DragRange()
end

---6.拖选框，吸附功能
---@param _tarBox UiObject 目标框
function DragUI:DragBox(_tarUI, _tarBox)
    if (AnchorsXY(_tarUI) - AnchorsXY(_tarBox)).Magnitude < 0.12 then
        _tarUI.AnchorsX = _tarBox.AnchorsX
        _tarUI.AnchorsY = _tarBox.AnchorsY
    end
end

---UI拖动至有内容的框内，内容互换
function DragUI:ContentExchange()
end

--TODO
---按住一个UI，移动鼠标（手指）时拖拽它(可能新一个新的图标)，
---松开时候根据鼠标（手指）的位置做不同的处理，如果在鼠标（手指）在目标槽范围内，则替换目标位置的UI

---注意：
---1.如按住不直接出icon，而是按住后鼠标出了当前按住的技能icon范围后再显示

return DragUI
