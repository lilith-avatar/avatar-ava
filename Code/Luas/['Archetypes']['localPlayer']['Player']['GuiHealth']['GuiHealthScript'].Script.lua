--- 生命血条UI脚本
-- @script Health GUI
-- @copyright Lilith Games, Avatar Team
local ImgHealth = script.Parent.ImgHealth
local ImgBg = script.Parent.ImgBackground
local OriginSize = ImgHealth.Size
local HealthRed = ResourceManager.GetTexture('Blood_Red')
local HealthGreen = ResourceManager.GetTexture('Blood_Green')
local HealthOrange = ResourceManager.GetTexture('Blood_Orange')
local HealthChangeTime = 0
local TimerNow = 0
local player = localPlayer.Player

local function HealthChange()
    HealthChangeTime = Timer.GetTime()
    Property = player.Health / player.MaxHealth
    if Property >= 0.7 then
        ImgHealth.Texture = HealthGreen
    elseif Property >= 0.3 then
        ImgHealth.Texture = HealthOrange
    else
        ImgHealth.Texture = HealthRed
    end
    ImgHealth.Size = Vector2(OriginSize.x * Property, OriginSize.y)
end

local function StartTimer()
    while true do
        TimerNow = Timer.GetTime()
        if player.HealthDisplayMode == Enum.HealthDisplayMode.Always then
            ImgHealth:SetActive(true)
            ImgBg:SetActive(true)
        elseif player.HealthDisplayMode == Enum.HealthDisplayMode.Never then
            ImgHealth:SetActive(false)
            ImgBg:SetActive(false)
        elseif player.HealthDisplayMode == Enum.HealthDisplayMode.OnHit then
            if player.Health ~= player.MaxHealth then
                ImgHealth:SetActive(true)
                ImgBg:SetActive(true)
            else
                ImgHealth:SetActive(false)
                ImgBg:SetActive(true)
            end
        else
            if TimerNow <= HealthChangeTime + 2 and HealthChangeTime ~= 0 then
                ImgHealth:SetActive(true)
                ImgBg:SetActive(true)
            else
                ImgHealth:SetActive(false)
                ImgBg:SetActive(false)
            end
        end
        wait()
    end
end

player.OnHealthChange:Connect(HealthChange)
StartTimer()
