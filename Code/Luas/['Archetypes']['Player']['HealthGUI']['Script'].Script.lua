-- script
local HealthBar = script.Parent.Health
local HealthBackground = script.Parent.BackGround
local OriginSize = HealthBar.Size
local HealthRed = ResourceManager.GetTexture('Blood_Red')
local HealthGreen = ResourceManager.GetTexture('Blood_Green')
local HealthOrange = ResourceManager.GetTexture('Blood_Orange')
local HealthChangeTime = 0
local TimerNow = 0
local player = script.Parent.Parent

local function HealthChange()
    HealthChangeTime = Timer.GetTime()
    Property = player.Health / player.MaxHealth
    if Property >= 0.7 then
        HealthBar.Texture = HealthGreen
    elseif Property >= 0.3 then
        HealthBar.Texture = HealthOrange
    else
        HealthBar.Texture = HealthRed
    end
    HealthBar.Size = Vector2(OriginSize.x * Property, OriginSize.y)
end

local function StartTimer()
    while true do
        TimerNow = Timer.GetTime()
        if player.HealthDisplayMode == Enum.HealthDisplayMode.Always then
            HealthBar:SetActive(true)
            HealthBackground:SetActive(true)
        elseif player.HealthDisplayMode == Enum.HealthDisplayMode.Never then
            HealthBar:SetActive(false)
            HealthBackground:SetActive(false)
        elseif player.HealthDisplayMode == Enum.HealthDisplayMode.OnHit then
            if player.Health ~= player.MaxHealth then
                HealthBar:SetActive(true)
                HealthBackground:SetActive(true)
            else
                HealthBar:SetActive(false)
                HealthBackground:SetActive(true)
            end
        else
            if TimerNow <= HealthChangeTime + 2 and HealthChangeTime ~= 0 then
                HealthBar:SetActive(true)
                HealthBackground:SetActive(true)
            else
                HealthBar:SetActive(false)
                HealthBackground:SetActive(false)
            end
        end
        wait(0.01)
    end
end

player.OnHealthChange:Connect(HealthChange)
StartTimer()
