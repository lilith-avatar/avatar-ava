--- 玩家姓名板UI脚本
-- @script Name GUI
-- @copyright Lilith Games, Avatar Team
local TxtNameBar = script.Parent.TxtNameBar
local GuiName = script.Parent
local ImgHealth = script.Parent.Parent.GuiHealth.ImgHealth
local player = localPlayer.Player

while true do
    TxtNameBar:SetActive(player.DisplayName)
    TxtNameBar.Text = localPlayer.Name

    if ImgHealth == nil or ImgHealth.ActiveSelf == false then
        GuiName.Position = player.Position + Vector3(0, 1 + player.Avatar.Height, 0)
    else
        GuiName.Position = player.Position + Vector3(0, 1.1 + player.Avatar.Height, 0)
    end
    if TxtNameBar:GetClosestTeam() ~= world.Players and TxtNameBar:GetClosestTeam() ~= nil then
        TxtNameBar.Color = TxtNameBar:GetClosestTeam().TeamColor
    end
    wait()
end
