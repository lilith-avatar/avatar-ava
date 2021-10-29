--- 角色镜头模块
--- @module Player Cam Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local PlayerCam, this = Ava.Util.Mod.New('PlayerCam', ClientBase)

--- 初始化
function PlayerCam:Init()
    --print('[PlayerCam] Init()')
    this:DataInit()
    this:InitCamera()
end

--- 数据变量初始化
function PlayerCam:DataInit()
    -- 当前的相机
    this.curCamera = nil

    -- 玩家跟随相机
    this.playerGameCam = localPlayer.Local.Independent.GameCam
end

function PlayerCam:InitCamera()
    if not this.curCamera and this.playerGameCam then
        this.curCamera = this.playerGameCam
    end
    this.playerGameCam.LookAt = localPlayer
    world.CurrentCamera = this.curCamera
end

-- 玩家移动方向是否遵循玩家摄像机方向
function PlayerCam:IsFreeMode()
    return (this.curCamera.CameraMode == Enum.CameraMode.Social and this.curCamera.Distance >= 0) or
        this.curCamera.CameraMode == Enum.CameraMode.Orbital or
        this.curCamera.CameraMode == Enum.CameraMode.Custom or
        this.curCamera.CameraMode == Enum.CameraMode.Smart
end

-- 滑屏转向
function PlayerCam:CameraMove(touchInfo)
    if #touchInfo == 1 then
        if this:IsFreeMode() then
            this.curCamera:CameraMove(touchInfo[1].DeltaPosition)
        else
            this.curCamera.LookAt:Rotate(0, touchInfo[1].DeltaPosition.x * 0.2, 0)
            this.curCamera:CameraMove(Vector2(0, touchInfo[1].DeltaPosition.y))
        end
    end
end

-- 双指缩放摄像机距离
function PlayerCam:CameraZoom(_pos1, _pos2, _dis, _speed)
    if this.curCamera.CameraMode == Enum.CameraMode.Social then
        this.curCamera.Distance = this.curCamera.Distance - _dis / 50
    end
end

-- Fov缩放
function PlayerCam:CameraFOVZoom(_fovChange, _maxFov)
    if _fovChange > 0 and this.curCamera.FieldOfView > _maxFov + 1 then
        _fovChange = -0.2
    elseif _fovChange > 0 and this.curCamera.FieldOfView > _maxFov then
        _fovChange = 0
    end
    this.curCamera.FieldOfView = math.clamp(this.curCamera.FieldOfView + _fovChange, 60, 90)
end

-- 修改玩家当前相机
function PlayerCam:SetCurCamEventHandler(_cam, _lookAt)
    this.curCamera = _cam or this.playerGameCam
    this.curCamera.LookAt = _lookAt or localPlayer
    world.CurrentCamera = this.curCamera
end

return PlayerCam
