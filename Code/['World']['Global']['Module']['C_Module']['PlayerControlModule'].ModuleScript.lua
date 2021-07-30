--- @module PlayerControl 玩家PC上的移动控制逻辑
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local PlayerControl, this = ModuleUtil.New('PlayerControl', ClientBase)

--- PC端交互按键
local FORWARD_KEY = Enum.KeyCode.W
local BACK_KEY = Enum.KeyCode.S
local LEFT_KEY = Enum.KeyCode.A
local RIGHT_KEY = Enum.KeyCode.D

--- 初始化
function PlayerControl:Init()
    ---@type PlayerInstance 获取本地玩家
    self.player = localPlayer

    ---声明变量
    self.forwardDir = Vector3.Forward
    self.rightDir = Vector3.Right
    self.finalDir = Vector3.Zero

    --- 摄像机看向自己
    self.camera = world.CurrentCamera
    self.mode = Camera.CameraMode
    if (self.camera.CameraMode ~= 4) then
        self.camera.LookAt = self.player
    end

    --- 键盘的输入值
    self.moveForwardAxis = 0
    self.moveBackAxis = 0
    self.moveLeftAxis = 0
    self.moveRightAxis = 0

    self.player.OnHealthChange:Connect(
        function(oldHealth, newHealth)
            self:HealthCheck(oldHealth, newHealth)
        end
    )
end

--- 移动方向是否遵循摄像机方向
function PlayerControl:IsFreeMode()
    return (mode == Enum.CameraMode.Social and camera.Distance >= 0) or mode == Enum.CameraMode.Orbital or
        mode == Enum.CameraMode.Custom
end

---获取按键盘时的移动方向最终取值
function PlayerControl:GetKeyValue()
    self.moveForwardAxis = Input.GetPressKeyData(FORWARD_KEY) > 0 and 1 or 0
    self.moveBackAxis = Input.GetPressKeyData(BACK_KEY) > 0 and -1 or 0
    self.moveLeftAxis = Input.GetPressKeyData(LEFT_KEY) > 0 and 1 or 0
    self.moveRightAxis = Input.GetPressKeyData(RIGHT_KEY) > 0 and -1 or 0
    if self.player.State == Enum.CharacterState.Died then
        self.moveForwardAxis, self.moveBackAxis, self.moveLeftAxis, self.moveRightAxis = 0, 0, 0, 0
    end
end

--- 获取移动方向
function PlayerControl:GetMoveDir()
    self.forwardDir = self:IsFreeMode() and self.camera.Forward or self.player.Forward
    self.forwardDir.y = 0
    self.rightDir = Vector3(0, 1, 0):Cross(self.forwardDir)
    self:GetKeyValue()
    self.finalDir =
        self.forwardDir * (self.moveForwardAxis + self.moveBackAxis) -
        self.rightDir * (self.moveLeftAxis + self.moveRightAxis)
end

--- 移动逻辑
function PlayerControl:PlayerMove(dir)
    dir.y = 0
    if self.player.State == Enum.CharacterState.Died then
        dir = Vector3.Zero
    end
    if dir.Magnitude > 0 then
        if self:IsFreeMode() then
            self.player:FaceToDir(dir, 4 * math.pi)
        end
        self.player:MoveTowards(Vector2(dir.x, dir.z).Normalized )
    else
        self.player:MoveTowards(Vector2.Zero)
    end
end

--- Update函数
--- @param _dt number delta time 每帧时间
function PlayerControl:Update(_dt, _tt)
end

--- FixUpdate函数
--- @param _dt number delta time 每帧时间
function PlayerControl:FixUpdate(_dt)
    if not world.CurrentCamera then
        return
    end
    self.camera = world.CurrentCamera
    self.mode = self.camera.CameraMode
    self:GetMoveDir()
    self:PlayerMove(self.finalDir)
end

--- 生命值检测
function PlayerControl:HealthCheck(oldHealth, newHealth)
    if newHealth <= 0 then
        self.player:Die()
    end
end

return PlayerControl
