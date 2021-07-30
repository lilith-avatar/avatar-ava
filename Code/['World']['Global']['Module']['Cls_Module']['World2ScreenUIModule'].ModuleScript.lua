--- @module World2ScreenUI 将世界物体和UI绑定
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local World2ScreenUI = class('World2ScreenUI')

local edgePix = 0.1
local redis = 0.4
local usedType = 2 ---1为四边形 2为圆形

--- 构造函数
function World2ScreenUI:initialize(_ui, _obj, _dir, _content, _offset)
    self.worldObj = _obj
    self.ui = _ui
    self.dirUI = _dir
    self.contentUI = _content
    self.offset = _offset or Vector3.Zero
    self.FixUpdate = function()
        if self.worldObj then
            self:UIProjectionRefresh()
        end
    end
    world.OnRenderStepped:Connect(self.FixUpdate)
end

---根据世界上物体的位置更新UI位置
function World2ScreenUI:UIProjectionRefresh()
    local cam = world.CurrentCamera
    if not cam then
        return
    end
    local UIPos = cam:WorldToViewportPoint(self.worldObj.Position + self.offset)
    local x, y, z = UIPos.x, UIPos.y, UIPos.z
    if z < 0 then
        x = 1 - x
        y = 1 - y
    end
    local dir = Vector2(x, y) - Vector2.One * 0.5
    if math.abs(dir.x) < 0.0001 then
        return
    end
    ---斜率
    local k = dir.y / dir.x
    ---截距
    local b = (dir.x - dir.y) / (2 * dir.x)
    local angle = Vector2.Angle(dir, Vector2(1, 0))
    angle = angle * math.pi / 180
    if dir.y < 0 then
        angle = 2 * math.pi - angle
    end
    local uiDir = self.dirUI
    local uiContent = self.contentUI
    if usedType == 1 then
        if x >= edgePix and x <= 1 - edgePix and y >= edgePix and y <= 1 - edgePix and z >= 0 then
            ---在视野范围内
            if uiDir then
                uiDir:SetActive(false)
            end
            if uiContent then
                uiContent:SetActive(true)
            end
        else
            ---在视野范围外
            if angle >= math.pi / 4 and angle < 3 * math.pi / 4 then
                y = 1 - edgePix
                x = (y - b) / k
            elseif angle >= 3 * math.pi / 4 and angle < 5 * math.pi / 4 then
                x = edgePix
                y = k * x + b
            elseif angle >= 5 * math.pi / 4 and angle < 7 * math.pi / 4 then
                y = edgePix
                x = (y - b) / k
            elseif angle >= 7 * math.pi / 4 or angle < 1 * math.pi / 4 then
                x = 1 - edgePix
                y = k * x + b
            end
            if uiContent then
                uiContent:SetActive(false)
            end
            if uiDir then
                uiDir:SetActive(true)
            end
            uiDir.Angle = angle / math.pi * 180 + 90
        end
    elseif usedType == 2 then
        local dis = dir.Magnitude
        if dis <= redis and z >= 0 then
            ---视野范围内
            if uiDir then
                uiDir:SetActive(false)
            end
            if uiContent then
                uiContent:SetActive(true)
            end
        else
            ---视野范围外
            if uiContent then
                uiContent:SetActive(false)
            end
            if uiDir then
                uiDir:SetActive(true)
                uiDir.Angle = angle / math.pi * 180 + 90
            end
            if angle >= 3 * math.pi / 2 or angle < math.pi / 2 then
                x = math.sqrt(redis * redis / (1 + k * k)) + 0.5
                y = k * x + b
            else
                x = -math.sqrt(redis * redis / (1 + k * k)) + 0.5
                y = k * x + b
            end
        end
    end
    self.ui.AnchorsX = Vector2.One * x
    self.ui.AnchorsY = Vector2.One * y
end

---解绑这个实例上的关系并销毁
function World2ScreenUI:Unbind()
    world.OnRenderStepped:Disconnect(self.FixUpdate)
    for i, v in pairs(self) do
        self[i] = nil
    end
    self = nil
end

return World2ScreenUI
