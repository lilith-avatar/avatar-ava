TouchNumber=0
function cameraMove(pos,dis,deltapos,speed)
	local Camera = world.CurrentCamera
	if ((Camera.CameraMode==1 and Camera.Distance>0) or Camera.CameraMode==5) and TouchNumber==1 then
		Camera:CameraMove(deltapos)
	elseif ((Camera.CameraMode==1 and Camera.Distance<0) or Camera.CameraMode==2 or Camera.CameraMode==3) and TouchNumber==1 then
		localPlayer:RotateAround(localPlayer.Position,Camera.UpVector,deltapos.x)
		Camera:CameraMove(Vector2(0,deltapos.y))
	end
end

function cameraZoom(pos1,pos2,dis,speed)
	if world.CurrentCamera.CameraMode==1 then
		world.CurrentCamera.Distance=world.CurrentCamera.Distance-dis/50
	end
end

function countTouch(container)
	TouchNumber=#container
end

script.Parent.OnPanStay:Connect(cameraMove)
script.Parent.OnPinchStay:Connect(cameraZoom)
script.Parent.OnTouched:Connect(countTouch)
