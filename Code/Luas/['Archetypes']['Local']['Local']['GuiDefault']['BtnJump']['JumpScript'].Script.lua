---客户端UI默认跳跃脚本
---@script Default Jump
---@copyright Lilith Games, Avatar Team

local Player = localPlayer.Player

local function Jump()
    if Player.IsOnGround and Player.State ~= Enum.CharacterState.Died then
        Player:Jump()
    end
end

script.Parent.OnClick:Connect(Jump)
