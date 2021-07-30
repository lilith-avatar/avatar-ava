--- @module CameraControl，枪械模块：相机控制
--- @copyright Lilith Games, Avatar Team
--- @author An Dai
local CameraControl = {}

function CameraControl:Init()
    --初始化数据
    self.m_camera = world.CurrentCamera
    self.gun = nil
    self:ClearData()
    self.offset = GunConfig.GlobalConfig.CameraOriginOffset
    self.m_currentHeight = localPlayer.CharacterHeight
    self.m_supposedHeight = self.m_currentHeight
    self.deltaOffset = Vector3.Zero
    --协程初始化
    self.FixUpdateTable = {}
    --蹲高度变化
    self.crouchController =
        TweenController:new(
        'crouch',
        self,
        function()
            return 0.4
        end,
        function(_t1, _t2, _dt)
            self.m_supposedHeight = localPlayer.CharacterHeight
            local fin = self.m_currentHeight + 10 * _dt * (self.m_supposedHeight - self.m_currentHeight)
            self.m_currentHeight = fin
        end,
        function()
            self.m_currentHeight = self.m_supposedHeight
        end,
        true
    )

    ---挨打镜头抖动
    self.ShakeController =
        TweenController:new(
        'shake',
        self,
        function()
            return self.shakeTime
        end,
        function(_t1, _t2)
            math.randomseed(Timer.GetTime() * 10000)
            self.deltaOffset =
                Vector3(Shake(self.shakeStrenth), Shake(self.shakeStrenth), Shake(self.shakeStrenth)) * _t1 / _t2
        end,
        function()
            self.deltaOffset = Vector3.Zero
        end,
        true
    )
end

function CameraControl:FixUpdate(_dt)
    ---插入协程
    local Todo = {}
    for k, v in pairs(self.FixUpdateTable) do
        Todo[#Todo + 1] = v
    end
    for i, v in ipairs(Todo) do
        v:FixUpdate(_dt)
    end
    --根据数据调整
    if (self.deltaPhy ~= 0) then
        localPlayer:Rotate(0, self.deltaPhy * 180 / math.pi, 0)
    end
    if (self.deltaTheta ~= 0) then
        self.m_camera:CameraMoveInDegree(Vector2(0, self.deltaTheta) * 180 / math.pi)
    end
    if (self.distance) then
        self.m_camera.Distance = self.distance
    end
    self.m_camera:RollTo(self.gamma * 180 / math.pi)
    if (self.fieldOfView ~= self.m_camera.FieldOfView) then
        self.m_camera.FieldOfView = self.fieldOfView
    end
    self:SetOffset()

    --插一段小功能：准心延迟
    if (self.gun and self.gun.m_isDraw) then
        self.gun.m_gui.deltaAngle = self.gun.m_gui.deltaAngle - Vector2(self.deltaPhy, self.deltaTheta)
    end
    --数据清空
    self:ClearData()
end

function CameraControl:ClearData()
    self.deltaPhy = 0
    self.deltaTheta = 0
    self.gamma = 0
    self.distance = nil
    self.fieldOfView = self.m_camera.FieldOfView
end

function CameraControl:Crouch()
    self.crouchController:Start()
    if (self.gun and self.gun.m_isDraw) then
        self.gun.m_cameraControl:Crouch()
    end
end

function CameraControl:SetOffset()
    self.m_camera.Offset = self.offset + self.m_currentHeight * Vector3.Up + self.deltaOffset
end

function CameraControl:CameraShake(_strength, _time)
    self.shakeStrenth = _strength
    self.shakeTime = _time
    self.ShakeController:Start()
end

return CameraControl
