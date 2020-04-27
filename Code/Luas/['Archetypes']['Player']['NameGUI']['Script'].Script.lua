local Namebar = script.Parent.NameBar
local NameGUI = script.Parent
local HealthGUI = script.Parent.Parent.HealthGUI.Health
local player = script.Parent.Parent

while true do
    Namebar:SetActive(player.DisplayName)
    Namebar.Text = player.Name

    if HealthGUI == nil or HealthGUI.ActiveSelf == false then
        NameGUI.Position = player.Position + Vector3(0, 1 + player.Avatar.Height, 0)
    else
        NameGUI.Position = player.Position + Vector3(0, 1.1 + player.Avatar.Height, 0)
    end
    if Namebar:GetClosestTeam() ~= world.Players and Namebar:GetClosestTeam() ~= nil then
        Namebar.Color = Namebar:GetClosestTeam().TeamColor
    end
    wait()
end
