--- 玩家控制模块
--- @module Player Controll, client-side
--- @copyright Lilith Games, Avatar Team
local PlayerControl, this = ModuleUtil.New('PlayerControl', ClientBase)
local player
--声明变量
local isDead = false
local forwardDir = Vector3.Forward
local rightDir = Vector3.Right
local finalDir = Vector3.Zero
local horizontal = 0
local vertical = 0

-- 相机
local camera, mode

-- 手机端交互UI
local gui, joystick, touchScreen, jumpButton

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

function PlayerControl:Awake()
    -- 获取本地玩家
    player = localPlayer
    self:InitGui()
    self:InitCamera()
    self:InitListener()
end

function PlayerControl:InitListener()
    -- Main
    world.OnRenderStepped:Connect(MainControl)
    -- Player
    player.OnHealthChange:Connect(HealthCheck)
    player.OnDead:Connect(PlayerDie)
    -- GUI
    touchScreen.OnTouched:Connect(CountTouch)
    touchScreen.OnPanStay:Connect(CameraMove)
    touchScreen.OnPinchStay:Connect(CameraZoom)
    jumpButton.OnDown:Connect(PlayerJump)
    -- Keyboard
    Input.OnKeyDown:Connect(
        function()
            if Input.GetPressKeyData(JUMP_KEY) == 1 then
                PlayerJump()
            end
        end
    )
end

function PlayerControl:InitGui()
    gui = localPlayer.Local.ControlGui
    joystick = gui.Joystick
    touchScreen = gui.TouchFig
    jumpButton = gui.JumpBtn
end

function PlayerControl:InitCamera()
    if not world.CurrentCamera and localPlayer.Local.Independent.GameCam then
        world.CurrentCamera = localPlayer.Local.Independent.GameCam
    end
    camera = world.CurrentCamera
    mode = Camera.CameraMode
    camera.LookAt = player
end

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
function PlayerMove(_dir)
    _dir.y = 0
    if player.State == Enum.CharacterState.Died then
        _dir = Vector3.Zero
    end
    if _dir.Magnitude > 0 then
        if IsFreeMode then
            player:FaceToDir(_dir, 4 * math.pi)
        end
        player:MoveTowards(Vector2(_dir.x, _dir.z).Normalized)
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

-- 死亡逻辑
function PlayerDie()
    isDead = true
    wait(player.RespawnTime)
    player:Reset()
    isDead = false
end

-- 生命值检测
function HealthCheck(oldHealth, newHealth)
    if newHealth <= 0 then
        player:Die()
    end
end

-- 每个渲染帧处理操控逻辑
function MainControl()
    camera = world.CurrentCamera
    mode = camera.CameraMode
    GetMoveDir()
    PlayerMove(finalDir)
end

-- 检测触屏的手指数
local touchNumber = 0
function CountTouch(container)
    touchNumber = #container
end

-- 滑屏转向
function CameraMove(_pos, _dis, _deltapos, _speed)
    if touchNumber == 1 then
        if IsFreeMode() then
            camera:CameraMove(_deltapos)
        else
            player:RotateAround(player.Position, Vector3.Up, _deltapos.x)
            camera:CameraMove(Vector2(0, _deltapos.y))
        end
    end
end

-- 双指缩放摄像机距离
function CameraZoom(_pos1, _pos2, _dis, _speed)
    if mode == Enum.CameraMode.Social then
        camera.Distance = camera.Distance - _dis / 50
    end
end

return PlayerControl
