---客户端UI默认触摸移动脚本
---@script Default Touch
---@copyright Lilith Games, Avatar Team
local TouchNumber = 0

local function CameraMove(pos, dis, deltapos, speed)
    local Camera = world.CurrentCamera
    if
        ((Camera.CameraMode == Enum.CameraMode.Social and Camera.Distance > 0) or
            Camera.CameraMode == Enum.CameraMode.Orbital) and
            TouchNumber == 1
     then
        Camera:CameraMove(deltapos)
    elseif
        ((Camera.CameraMode == Enum.CameraMode.Social and Camera.Distance < 0) or
            Camera.CameraMode == Enum.CameraMode.Fpp or
            Camera.CameraMode == Enum.CameraMode.Tpp) and
            TouchNumber == 1
     then
        localPlayer:RotateAround(localPlayer.Position, Camera.UpVector, deltapos.x)
        Camera:CameraMove(Vector2(0, deltapos.y))
    end
end

local function CameraZoom(pos1, pos2, dis, speed)
    if world.CurrentCamera.CameraMode == Enum.CameraMode.Social then
        world.CurrentCamera.Distance = world.CurrentCamera.Distance - dis / 50
    end
end

local function CountTouch(container)
    TouchNumber = #container
end

script.Parent.OnPanStay:Connect(CameraMove)
script.Parent.OnPinchStay:Connect(CameraZoom)
script.Parent.OnTouched:Connect(CountTouch)
