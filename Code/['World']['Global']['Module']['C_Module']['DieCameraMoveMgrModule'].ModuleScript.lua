---  死亡运镜模块
--- @module  DieCameraMoveMgr
--- @copyright Lilith Games, Avatar Team
--- @author Mane
local DieCameraMoveMgr, this = ModuleUtil.New('DieCameraMoveMgr', ClientBase)

function DieCameraMoveMgr:Init()
    print('DieCameraMoveMgr:Init')
    this = self
    this:NodeRef()
    this:DataInit()
end

--节点引用
function DieCameraMoveMgr:NodeRef()
    this.Camera = 0
    this.time = 0
    this.enable = false
end

--数据变量声明
function DieCameraMoveMgr:DataInit()
    ---可配置内容
    this.CameraMoveTime = Config.GlobalConfig.DieCameraMoveTime
    this.CameraHoldTime = Config.GlobalConfig.DieCameraHoldTime
    this.CameraHeight = Config.GlobalConfig.DieCameraHeight
    this.CameraXRotation = Config.GlobalConfig.DieCameraXRotation
end

---游戏开始事件
function DieCameraMoveMgr:GameStartEventHandler()
    this.enable = true
end

---游戏结束事件
function DieCameraMoveMgr:GameOverEventHandler()
    this.enable = false
end

---接收死亡信息
--@param _killer PlayerInstance 击杀者
--@param _killed PlayerInstance 被杀的人
--@param _weaponId number 伤害来源的枪械ID
--@param _hitPart number 击杀部位
local killerPos
function DieCameraMoveMgr:PlayerDieEventHandler(_killer, _killed, _weaponId, _hitPart)
    --判断死亡是否是自身并且当前是否在游戏中
    if _killed == localPlayer and this.enable then
        --开启死亡运镜
        killerPos = _killer.Position
        this:CameraMoveStart(killer, killerPos, _weaponId)
    end
end

---设置复活时间
--@param _time  复活时间
function DieCameraMoveMgr:SetTime(_time)
    this.time = _time
end

---死亡运镜开始
--@param _killerPos  击杀者位置
--@param _weaponId  击杀使用的枪械ID
local dieCameraTween
local cameraObj
function DieCameraMoveMgr:CameraMoveStart(killer, _killerPos, _weaponId)
    ---切换摄像机模式
    cameraObj =
        world:CreateInstance(
        'DieCamera',
        'DieCamera',
        localPlayer.Local.Independent,
        world.CurrentCamera.Position,
        world.CurrentCamera.Rotation
    )
    cameraObj.CameraMode = 3
    this.Camera = cameraObj
    world.CurrentCamera = cameraObj
    this.Camera.CameraMode = 4
    dieCameraTween =
        Tween:TweenProperty(
        this.Camera,
        {Position = this:TargetPos(_killerPos), Rotation = this:TargetRot(_killerPos)},
        this.CameraMoveTime,
        Enum.EaseCurve.Linear
    ):Play()
    wait(this.time)
    if this.enable then
        world.CurrentCamera = localPlayer.Local.Independent.CamGame
    end
    cameraObj:Destroy()
    this.time = 0
    return
end

--- 计算摄像机目标位置
--@param _killerPos
--@return targetPos 目标位置
local dirPos
local targetPos
local YPos
function DieCameraMoveMgr:TargetPos(_killerPos)
    dirPos = Vector2(localPlayer.Position.x, localPlayer.Position.z) - Vector2(_killerPos.x, _killerPos.z)
    dirPos = dirPos.Normalized
    YPos = localPlayer.Position.y >= _killerPos.y and localPlayer.Position.y or _killerPos.y
    targetPos =
        Vector3(dirPos.x * 2 + localPlayer.Position.x, YPos + this.CameraHeight, localPlayer.Position.z + dirPos.y * 2)
    return targetPos
end

--- 计算目标夹角
--@param _killerPos
--@return targetRot 目标夹角
local dirPos
local targetRot
local targetRot_Forward
local targetRot_Right
local targetRot_Up
function DieCameraMoveMgr:TargetRot(_killerPos)
    dirPos = Vector2(_killerPos.x, _killerPos.z) - Vector2(localPlayer.Position.x, localPlayer.Position.z)
    targetRot_Forward = Vector2.Angle(dirPos, Vector2(localPlayer.Forward.x, localPlayer.Forward.z))
    targetRot_Right = Vector2.Angle(dirPos, Vector2(localPlayer.Right.x, localPlayer.Right.z))
    --- 旋转方向判断
    targetRot_Up = _killerPos - Vector3(0, _killerPos.y + this.CameraHeight, 0)
    targetRot_Up = Vector3.Angle(Vector3(0, 1, 0), targetRot_Up)
    print(targetRot_Up)
    if targetRot_Right <= 90 then
        targetRot = EulerDegree(targetRot_Up + this.CameraXRotation - 90, this.Camera.Rotation.y + targetRot_Forward, 0)
    elseif targetRot_Right > 90 then
        targetRot = EulerDegree(targetRot_Up + this.CameraXRotation - 90, this.Camera.Rotation.y - targetRot_Forward, 0)
    end
    return targetRot
end
return DieCameraMoveMgr
