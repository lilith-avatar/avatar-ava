--- 玩家默认UI
--- @module Player Default GUI
--- @copyright Lilith Games, Avatar Team
local PlayerGuiDefault, this = ModuleUtil.New('PlayerGuiDefault', ClientBase)

-- 获取本地玩家
local player

-- 姓名板
local nameGUI

-- 血条
local healthGUI, background, healthBar
local RED_BAR = ResourceManager.GetTexture('Internal/Blood_Red')
local GREEN_BAR = ResourceManager.GetTexture('Internal/Blood_Green')
local ORANGE_BAR = ResourceManager.GetTexture('Internal/Blood_Orange')
local HIT_LAST_TIME = 2
local healthBarShowTime = 0

function PlayerGuiDefault:Init()
    -- 获取本地玩家
    player = localPlayer
    self:InitNameGui()
    self:InitHealthBarGui()
    self:InitListener()
end

-- 姓名板
function PlayerGuiDefault:InitNameGui()
    nameGUI = player.NameGui
    nameGUI.NameBarTxt1.Text = player.Name
    nameGUI.NameBarTxt2.Text = player.Name
end

-- 血条
function PlayerGuiDefault:InitHealthBarGui()
    healthGUI = player.HealthGui
    --background = healthGUI.BackgroundImg
    --healthBar = background.HealthBarImg
end

-- 初始化事件
function PlayerGuiDefault:InitListener()
    player.OnHealthChange:Connect(HealthChange)
    world.OnRenderStepped:Connect(MainGUI)
end

-- 姓名板的显示逻辑
function NameBarLogic()
    nameGUI.Visible = player.DisplayName
    if player.DisplayName then
        local addedHeight = (healthGUI and healthGUI.ActiveSelf) and 1.1 or 1
        nameGUI.LocalPosition = Vector3(0, addedHeight + player.Avatar.Height, 0)
    end
end

-- 血条随生命值颜色改变而改变
function HealthChange(_oldHealth, _newHealth)
    if _oldHealth > _newHealth then
        healthBarShowTime = 2
    end
    local percent = player.Health / player.MaxHealth
    if percent >= 0.7 then
        healthBar.Texture = GREEN_BAR
    elseif percent >= 0.3 then
        healthBar.Texture = ORANGE_BAR
    else
        healthBar.Texture = RED_BAR
    end
    healthBar.AnchorsX = Vector2(0.05, 0.9 * percent + 0.05)
end

-- 血条在各显示模式下的显示逻辑
function HealthBarLogic(_delta)
    healthBarShowTime = healthBarShowTime - _delta
    if player.HealthDisplayMode == Enum.HealthDisplayMode.Always then
        healthGUI.Visible = true
    elseif player.HealthDisplayMode == Enum.HealthDisplayMode.Never then
        healthGUI.Visible = false
    elseif player.HealthDisplayMode == Enum.HealthDisplayMode.OnHit then
        healthGUI.Visible = player.Health ~= player.MaxHealth
    else
        healthGUI.Visible = healthBarShowTime > 0
    end
end

-- 每个渲染帧更新姓名板和血条的显示逻辑
function MainGUI(_delta)
    NameBarLogic()
    HealthBarLogic(_delta)
end

return PlayerGuiDefault
