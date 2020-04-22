-- script
function Jump()
	if localPlayer.IsOnGround and localPlayer.State~=Enum.CharacterState.Died then
		localPlayer:Jump()
	end
end

script.Parent.OnClick:Connect(Jump)