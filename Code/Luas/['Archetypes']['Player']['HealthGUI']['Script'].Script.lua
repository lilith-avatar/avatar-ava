-- script
HealthBar = script.Parent.Health
HealthBackground = script.Parent.BackGround
OriginSize = HealthBar.Size
HealthRed = ResourceManager.GetTexture('Blood_Red')
HealthGreen = ResourceManager.GetTexture('Blood_Green')
HealthOrange = ResourceManager.GetTexture('Blood_Orange')
HealthChangeTime = 0
TimerNow = 0
player = script.Parent.Parent

function healthChange()
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

player.OnHealthChange:Connect(healthChange)

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
