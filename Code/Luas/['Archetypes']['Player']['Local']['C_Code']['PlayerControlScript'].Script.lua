--- 玩家控制
-- @script Player Controll
-- @copyright Lilith Games, Avatar Team
-- 获取本地玩家
local player = localPlayer

--声明变量
local isDead = false
local forwardDir = Vector3.Forward
local rightDir = Vector3.Right
local finalDir = Vector3.Zero
local horizontal = 0
local vertical = 0

-- 摄像机看向自己
world.CurrentCamera = localPlayer.Local.ConstraintFree.Cube.CamGame
local camera = world.CurrentCamera
local mode = Camera.CameraMode
camera.LookAt = player

-- 手机端交互UI
local gui = localPlayer.Local.GuiControl
local joystick = gui.Joystick
local touchScreen = gui.FigTouch
local jumpButton = gui.BtnJump

-- PC端交互按键
local FORWARD_KEY = Enum.KeyCode.W
local BACK_KEY = Enum.KeyCode.S
local LEFT_KEY = Enum.KeyCode.A
local RIGHT_KEY = Enum.KeyCode.D
local JUMP_KEY = Enum.KeyCode.Space

-- 键盘的输入值
local moveForwardAxis = 0
local moveBackAxis = 0
local moveLeftAxis = 0
local moveRightAxis = 0

-- 移动方向是否遵循摄像机方向
function IsFreeMode()
	return (mode == Enum.CameraMode.Social and camera.Distance >= 0) or mode == Enum.CameraMode.Orbital or
		mode == Enum.CameraMode.Custom
end

--获取按键盘时的移动方向最终取值
function GetKeyValue()
	moveForwardAxis = Input.GetPressKeyData(FORWARD_KEY) > 0 and 1 or 0
	moveBackAxis = Input.GetPressKeyData(BACK_KEY) > 0 and -1 or 0
	moveLeftAxis = Input.GetPressKeyData(LEFT_KEY) > 0 and 1 or 0
	moveRightAxis = Input.GetPressKeyData(RIGHT_KEY) > 0 and -1 or 0
	if player.State == Enum.CharacterState.Died then
		moveForwardAxis, moveBackAxis, moveLeftAxis, moveRightAxis = 0, 0, 0, 0
	end
end

-- 获取移动方向
function GetMoveDir()
	forwardDir = IsFreeMode() and camera.Forward or player.Forward
	forwardDir.y = 0
	rightDir = Vector3(0, 1, 0):Cross(forwardDir)
	horizontal = joystick.Horizontal
	vertical = joystick.Vertical
	if horizontal ~= 0 or vertical ~= 0 then
		finalDir = rightDir * horizontal + forwardDir * vertical
	else
		GetKeyValue()
		finalDir = forwardDir * (moveForwardAxis + moveBackAxis) - rightDir * (moveLeftAxis + moveRightAxis)
	end
end

-- 移动逻辑
function PlayerMove(dir)
	dir.y = 0
	if player.State == Enum.CharacterState.Died then
		dir = Vector3.Zero
	end
	if dir.Magnitude > 0 then
		if IsFreeMode then
			player:FaceToDir(dir, 4 * math.pi)
		end
		player:MoveTowards(Vector2(dir.x, dir.z).Normalized)
	else
		player:MoveTowards(Vector2.Zero)
	end
end

-- 跳跃逻辑
function PlayerJump()
	if (player.IsOnGround or player.State == Enum.CharacterState.Seated) and not isDead then
		player:Jump()
		return
	end
end
jumpButton.OnDown:Connect(PlayerJump)
Input.OnKeyDown:Connect(
	function()
		if Input.GetPressKeyData(JUMP_KEY) == 1 then
			PlayerJump()
		end
	end
)

-- 死亡逻辑
function PlayerDie()
	isDead = true
	wait(player.RespawnTime)
	player:Reset()
	isDead = false
end
player.OnDead:Connect(PlayerDie)

-- 生命值检测
function HealthCheck(oldHealth, newHealth)
	if newHealth <= 0 then
		player:Die()
	end
end
player.OnHealthChange:Connect(HealthCheck)

-- 每个渲染帧处理操控逻辑
function MainControl()
	camera = world.CurrentCamera
	mode = camera.CameraMode
	GetMoveDir()
	PlayerMove(finalDir)
end
world.OnRenderStepped:Connect(MainControl)

-- 检测触屏的手指数
local touchNumber = 0
function countTouch(container)
	touchNumber = #container
end
touchScreen.OnTouched:Connect(countTouch)

-- 滑屏转向
function cameraMove(pos, dis, deltapos, speed)
	if touchNumber == 1 then
		if IsFreeMode() then
			camera:CameraMove(deltapos)
		else
			player:RotateAround(player.Position, Vector3.Up, deltapos.x)
			camera:CameraMove(Vector2(0, deltapos.y))
		end
	end
end
touchScreen.OnPanStay:Connect(cameraMove)

-- 双指缩放摄像机距离
function cameraZoom(pos1, pos2, dis, speed)
	if mode == Enum.CameraMode.Social then
		camera.Distance = camera.Distance - dis / 50
	end
end
touchScreen.OnPinchStay:Connect(cameraZoom)
