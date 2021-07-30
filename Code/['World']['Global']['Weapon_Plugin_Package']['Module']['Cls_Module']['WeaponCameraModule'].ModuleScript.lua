---@module WeaponCamera 枪械模块：武器镜头基类
---@copyright Lilith Games, Avatar Team
---@author Sharif Ma, An Dai
local WeaponCamera = class('WeaponCamera')
---WeaponCamera类的构造函数
---@param _gunRecoil GunRecoil
function WeaponCamera:initialize(_gunRecoil)
    self.gunRecoil = _gunRecoil
    ---枪械配置初始化
    GunBase.static.utility:InitGunCameraConfig(self)
    ---枪械对象
    self.gun = _gunRecoil.gun
    ---@type Camera 相机对象
    self.m_camera = nil
    ---初始FOV
    self.m_originZoom = self.gun.config_waistAimFOV
    ---设定FOV
    self.m_supposedZoom = self.m_originZoom
    ---开镜FOV,初始为枪械自身的配置
    self.m_sightZoom = self.gun.config_mechanicalAimFOV
    ---开镜时间,初始为枪械自身的开镜速度
    self.aimTime = self.gun.config_aimTime
    ---当前是否处于开镜的状态
    self.m_isZoomIn = false
    ---初始相机位移
    self.m_originOffset = GunConfig.GlobalConfig.CameraOriginOffset
    ---开镜相机位移
    self.m_aimOffset = GunConfig.GlobalConfig.CameraAimOffset
    ---当前相机位移
    self.m_currentOffset = self.m_originOffset
    ---未装备枪支的时候的镜头配置
    self.stateBefore = {}
    ---是否开始进行枪械的更新
    self.isUpdating = false
    ---屏幕大小(pxl²)
    self.screenSize = localPlayer.Local.GuiControl.Size
    print(self.screenSize.Magnitude, self.screenSize.Magnitude, self.screenSize.x)
    if self.screenSize.x > 100000 or self.screenSize.x <= 0 then
        print(self.screenSize, '编辑器问题,获取屏幕尺寸异常,使用默认尺寸')
        self.screenSize = Vector2(1920, 1080)
    end
    ---鼠标灵敏度(rad/屏占比)
    self.m_sensitivity = GunConfig.GlobalConfig.Sensitivity
    ---初始相机到瞄准点的距离(R)
    self.m_originDistance = GunConfig.GlobalConfig.CameraDistance
    ---当前的瞄准距离
    self.distance = self.m_originDistance
    ---开镜时的瞄准距离
    self.m_aimDistance = GunConfig.GlobalConfig.CameraAimDistance
    --变量
    ---自旋角
    self.m_gamma = 0
    ---下一帧中Phy的改变量
    self.deltaPhy = 0
    ---下一帧中Theta的改变量
    self.deltaTheta = 0
    ---下一帧中FOV的增量
    self.m_deltaFOV = 0
    ---暂存鼠标位置
    self.m_lastMousePos = nil
    ---z轴振动最大振幅
    self.vibrationAmpl = nil
    ------后坐力部分(变量)
    ---回复总时间
    self.m_backTime = nil
    ---跳动总位移
    self.m_jumpTotal = nil
    ---总回复量
    self.m_backTotal = nil
    ---是否开启自动瞄准
    self.enableAssistAim = GunConfig.GlobalConfig.EnableAssistAim
    ---要自瞄的敌人
    self.aimEnemy = nil
    ---开镜已经结束
    self.AimingIsOver = false

    self.m_jumpFovRateScale = 1
    self.m_aimTimeRateScale = 1

    self.m_jumpFovRateTable = {}
    self.m_aimTimeRateTable = {}

    self.UpdateTable = {}
    self.FixUpdateTable = {}
    ---尝试使用协程控制器
    --z轴旋转动画
    self.selfSpinController =
        TweenController:new(
        'selfSpin',
        self,
        function()
            local remnPhase = 2 * math.pi - self.selfSpinController.phase
            return math.min(self.m_backTime, remnPhase / self.config_vibrationOmega)
        end,
        function(_time, _totalTime)
            self.m_gamma =
                self.selfSpinController.Ampl * math.exp(-self.config_vibrationDump * _time) *
                math.sin(self.config_vibrationOmega * _time + self.selfSpinController.phase)
        end,
        function()
            self.m_gamma = 0
        end,
        true,
        function()
            local remn = self.FixUpdateTable.selfSpin
            if (not remn) then
                self.selfSpinController.phase = 0
                self.selfSpinController.Ampl = self.vibrationAmpl * GaussRandom()
            else
                local tempA =
                    self.selfSpinController.Ampl * math.exp(-self.config_vibrationDump * self.selfSpinController.time)
                local tempO =
                    tempA * self.config_vibrationOmega *
                    math.cos(self.config_vibrationOmega * self.selfSpinController.time + self.selfSpinController.phase)
                local delta = self.config_vibrationOmega * self.vibrationAmpl * GaussRandom()
                local newPhase = math.atan(self.m_gamma * self.config_vibrationOmega / (delta + tempO))
                local newAmpl = (delta + tempO) / self.config_vibrationOmega / math.cos(newPhase)
                self.selfSpinController.Ampl = newAmpl
                self.selfSpinController.phase = newPhase
            end
        end
    )

    ---FOV跳动总动画
    self.jumpFOVController =
        TweenController:new(
        'jumpFOV',
        self,
        function()
            local stdSpeed = self.jumpFOVController.jumpFOV / self.config_jumpTime
            if (stdSpeed == 0) then
                return 0
            else
                return 2 * self.config_jumpTime + (self.jumpFOVController.jumpFOV - self.m_deltaFOV) / stdSpeed
            end
        end,
        function(_t1, _t2, _dt)
            if (_t2 - _t1 > 2 * self.config_jumpTime) then
                self.m_deltaFOV = self.m_deltaFOV + _dt * self.jumpFOVController.jumpFOV / self.config_jumpTime
            else
                self.m_deltaFOV = (_t2 - _t1) / (2 * self.config_jumpTime) * self.jumpFOVController.jumpFOV
            end
        end,
        function()
            self.m_deltaFOV = 0
        end,
        true,
        function()
            self.jumpFOVController.jumpFOV = self:GetJumpFOV()
        end
    )

    ---枪口跳动总动画
    self.jumpController =
        TweenController:new(
        'jump',
        self,
        function()
            return self.config_jumpTime
        end,
        function(_t1, _t2, _dt)
            local omega = 0.5 * math.pi / _t2
            local power = omega * math.cos(omega * (_t1 - 0.5 * _dt)) * _dt
            self.deltaTheta = self.deltaTheta + power * self.m_jumpTotal.y
            self.deltaPhy = self.deltaPhy + power * self.m_jumpTotal.x
            self.jumpController.total = self.jumpController.total - power * self.m_jumpTotal
        end,
        function()
            self.deltaTheta = self.deltaTheta + self.jumpController.total.y
            self.deltaPhy = self.deltaPhy + self.jumpController.total.x
            self.jumpController.total = Vector2(0, 0)
            if (self.aimEnemy) then
                self.assistAimController:Start()
            end
            self.gun.m_gui:Fire()
        end,
        true,
        function()
            local remn = self.FixUpdateTable.recover
            if (remn) then
                remn:Stop()
            end
            remn = self.FixUpdateTable.jump
            if (remn) then
                remn:Stop()
            end
            self.jumpController.total = self.m_jumpTotal
        end
    )

    ---枪口回复总动画
    self.recoverController =
        TweenController:new(
        'recover',
        self,
        function()
            return self.m_backTime
        end,
        function(_t1, _t2, _dt)
            local Ampl = self.m_backTotal * self.config_vibrationDump / (1 - math.exp(-self.config_vibrationDump * _t2))
            local delta = Ampl * math.exp(-self.config_vibrationDump * (_t1 - 0.5 * _dt)) * _dt
            self.deltaTheta = self.deltaTheta - delta
            self.recoverController.total = self.recoverController.total + delta
        end,
        function()
        end,
        true,
        function()
            self.recoverController.total = 0
        end
    )

    ---辅瞄动画
    self.assistAimController =
        TweenController:new(
        'assistAim',
        self,
        function()
            return self.gun.config_assistAimTime
        end,
        function(_t1, _t2, _dt)
            if (not self.aimEnemy) then
                return
            end
            local targetPos = self:GetAimPos(self.aimEnemy)
            ---如果已经在瞄着人了则停止
            local dir = self.m_camera.Forward.Normalized
            local pos = self:GetCameraPos()
            local rayCastAll = Physics:RaycastAll(pos + 0.5 * dir, pos + self.gun.config_distance * dir, false)
            local hitObjects = rayCastAll.HitObjectAll
            for i, v in pairs(hitObjects) do
                if (v == self.aimEnemy) then
                    self.assistAimController.isChange = true
                    break
                end
            end
            ---如果拉过头了则停止
            if (self:IsRight(targetPos) ~= self.assistAimController.isRight) then
                self.assistAimController.isChange = true
            end
            if (self.assistAimController.isChange) then
                return
            end
            self.deltaTheta = self.deltaTheta + _dt * self.assistAimController.omegaTheta
            self.deltaPhy = self.deltaPhy + _dt * self.assistAimController.omegaPhy
        end,
        function()
        end,
        true,
        function()
            local targetPos = self:GetAimPos(self.aimEnemy)
            local relativePos = targetPos - self:GetCameraPos()
            self.assistAimController.isRight = self:IsRight(targetPos)
            self.assistAimController.isChange = false
            local thetaTotal =
                math.atan(relativePos.y / Vector2(relativePos.x, relativePos.z).Magnitude) -
                (90 - Vector3.Angle(world.CurrentCamera.Forward, Vector3.Up)) / 180 * math.pi
            local phyTotal =
                Vector2.Angle(
                Vector2(relativePos.x, relativePos.z),
                Vector2(self.m_camera.Forward.x, self.m_camera.Forward.z)
            ) *
                math.pi /
                180 *
                (self.assistAimController.isRight and -1 or 1)
            local ratio = self.gun.config_assistAimRatio / self.gun.config_assistAimTime
            self.assistAimController.omegaTheta = thetaTotal * ratio
            self.assistAimController.omegaPhy = phyTotal * ratio
        end
    )

    ---开镜总动画
    self.aimController =
        TweenController:new(
        'aim',
        self,
        function()
            return self:GetAimTime()
        end,
        function(_t1, _t2, _dt)
            local por = _t1 / _t2
            self.m_supposedZoom = (1 - por) * self.m_originZoom + por * self.aimController.sightZoom
            por = math.sqrt(1 - (1 - por) * (1 - por))
            self.m_currentOffset = (1 - por) * self.m_originOffset + por * self.m_aimOffset
            self.distance = (1 - por) * self.m_originDistance + por * self.m_aimDistance
        end,
        function()
            self.m_supposedZoom = self.aimController.sightZoom
            self.m_currentOffset = self.m_aimOffset
            self.distance = self.m_aimDistance
            ---开镜结束
            self.AimingIsOver = true
        end,
        true,
        function()
            local remn = self.FixUpdateTable.deaim
            if (remn) then
                remn:Stop()
            end
            self.m_isZoomIn = true
            NotReplicate(
                function()
                    self.gun.character.Avatar:SetActive(false)
                end
            )
            self.aimController.sightZoom = self:GetSightFOV()
        end
    )

    --关镜总动画
    self.deaimController =
        TweenController:new(
        'deaim',
        self,
        function()
            return self.gun.config_stopAimTime
        end,
        function(_t1, _t2, _dt)
            local por = _t1 / _t2
            self.m_supposedZoom = (1 - por) * self.deaimController.preZoom + por * self.m_originZoom
            self.m_currentOffset = (1 - por) * self.m_aimOffset + por * self.m_originOffset
            self.distance = por * self.m_originDistance + (1 - por) * self.m_aimDistance
        end,
        function()
            self.m_supposedZoom = self.m_originZoom
            self.m_currentOffset = self.m_originOffset
            self.distance = self.m_originDistance
            NotReplicate(
                function()
                    self.gun.character.Avatar:SetActive(true)
                end
            )
            self:SetProperties()
        end,
        true,
        function()
            local remn = self.FixUpdateTable.aim
            if (remn) then
                remn:Stop()
            end
            self.m_isZoomIn = false
            self.deaimController.preZoom = self.m_supposedZoom
        end
    )
end

---相机更新方法
function WeaponCamera:FixUpdate(_dt)
    if (not self.isUpdating) then
        return
    end
    ---流程控制的update部分
    local Todo = {}
    for k, v in pairs(self.FixUpdateTable) do
        Todo[#Todo + 1] = v
    end
    for i, v in ipairs(Todo) do
        v:FixUpdate(_dt)
    end
    ---同步数据,渲染
    self:SetProperties()
    ---清空缓存
    self.deltaPhy = 0
    self.deltaTheta = 0
end

function WeaponCamera:Update(_dt)
    if not self.isUpdating then
        return
    end
    ---进行配件数据的更新,所有更改必须在此更新,否则不会数据实装到武器上
    self.m_aimTimeRateTable = {}
    for k, v in pairs(self.gun.m_weaponAccessoryList) do
        self.m_aimTimeRateTable[k] = v.aimTimeRate
    end
    self.m_jumpFovRateTable = {}
    for k, v in pairs(self.gun.m_weaponAccessoryList) do
        self.m_jumpFovRateTable[k] = v.jumpFovRate
    end
    self:RefreshScales()
    self:RefreshSettings()
end

---装备枪支后自动进入腰射状态
---@param _gunController GunBase
function WeaponCamera:OnEquipWeapon(_gunController, info)
    self.gun = _gunController
    self.m_camera = localPlayer.Local.Independent.CamGame
    self.lastZoom = self.m_camera.FieldOfView
    self.m_camera.Offset = Vector3(0, localPlayer.CharacterHeight, 0) + self.m_currentOffset
    self.m_originZoom = self.gun.config_waistAimFOV
    self.m_sightZoom = self.gun.config_mechanicalAimFOV
    self.m_supposedZoom = self.m_originZoom
    CameraControl.fieldOfView = self.m_originZoom
    self.isUpdating = true
    CameraControl.gun = self.gun
end

---收到开火信号后处理相机部分的响应
---@param _recoil GunRecoil 后坐力类
function WeaponCamera:InputRecoil(_recoil)
    self.m_backTime = self:GetBackTime()
    local vert = _recoil:GetVertical() * math.pi / 180
    self.m_backTotal = _recoil.config_backTotal * vert
    self.vibrationAmpl = _recoil:GetSelfSpinRange() * math.pi / 180
    self.m_jumpTotal = Vector2(_recoil:GetHorizontal() * math.pi / 180, vert)
    self.selfSpinController:Start()
    self.jumpFOVController:Start()
    self.jumpController:Start()
    self.recoverController:Start()
end

---蹲下或者站起调用的函数
function WeaponCamera:Crouch()
    self.assistAimController:Stop()
end

---进入机瞄/开镜瞄准状态
function WeaponCamera:MechanicalAimStart()
    self.AimingIsOver = false
    self.aimController:Start()
end

function WeaponCamera:GetAssistAimDis()
    return self.m_isZoomIn and self.gun.config_assistAimDis1 or self.gun.config_assistAimDis0
end

---离开机瞄/开镜瞄准状态
function WeaponCamera:MechanicalAimStop()
    self.deaimController:Start()
end

---获取开镜速度
function WeaponCamera:GetAimTime()
    return self.aimTime * self.m_aimTimeRateScale
end

---获得返回时间
function WeaponCamera:GetBackTime()
    return self.gun.m_recoil:GetShakeTime()
end

---获取FOV抖动
function WeaponCamera:GetJumpFOV()
    return self.config_jumpFOV * self.m_jumpFovRateScale * world.CurrentCamera.FieldOfView / self.m_originZoom
end

---获取开镜的FOV
function WeaponCamera:GetSightFOV()
    ---若配件中有一个配件设置了大于零的开镜FOV则直接返回此数值,否则返回枪械自身的FOV
    for k, v in pairs(self.gun.m_weaponAccessoryList) do
        if v.aimFovRate > 0 then
            return v.aimFovRate
        end
    end
    return self.gun.config_mechanicalAimFOV
end

---卸下枪支后离开瞄准状态
---@param _useStateBefore boolean 是否使用之前的摄像机的配置
function WeaponCamera:OnUnEquipWeapon(_useStateBefore)
    CameraControl.gun = nil
    self:EndAll()
    CameraControl.fieldOfView = self.lastZoom
    self.isUpdating = false
end

---获取敌人的table
function WeaponCamera:GetEnemies()
    local res = {}
    for i, v in pairs(FindAllPlayers()) do
        if
            v ~= self.gun.character and v.PlayerType and v.PlayerType.Value ~= self.gun.character.PlayerType.Value and
                v.Health > 0 and
                v.Avatar.Bone_Head.HeadPoint
         then
            table.insert(res, v)
        end
    end
    return res
end

---检测敌人是否可见ToRewrite
function WeaponCamera:IsVisible(_enemy)
    local pos = self:GetCameraPos()
    local rayCastHead = Physics:RaycastAll(pos, _enemy.Avatar.Bone_Head.HeadPoint.Position, false)
    local hitObjects = rayCastHead.HitObjectAll
    for k, v in pairs(hitObjects) do
        local maybePlayer = ParentPlayer(v)
        if (maybePlayer ~= localPlayer and maybePlayer ~= _enemy and v.Block) then
            ---print('头被掩体阻挡')
            return false
        end
    end
    local rayCastBody = Physics:RaycastAll(pos, _enemy.Avatar.Bone_Pelvis.BodyPoint.Position, false)
    hitObjects = rayCastBody.HitObjectAll
    for k, v in pairs(hitObjects) do
        local maybePlayer = ParentPlayer(v)
        if (maybePlayer ~= localPlayer and maybePlayer ~= _enemy and v.Block) then
            ---print('身体被掩体阻挡')
            return false
        end
    end
    return true
end

---获得敌人瞄准位置
function WeaponCamera:GetAimPos(_enemy)
    local pos1, pos2
    if not _enemy.Avatar.Bone_Pelvis.BodyPoint then
        pos1 = _enemy.Avatar.Bone_Pelvis.Position
    else
        pos1 = _enemy.Avatar.Bone_Pelvis.BodyPoint.Position
    end
    if not _enemy.Avatar.Bone_Pelvis.HeadPoint then
        pos2 = _enemy.Avatar.Bone_Pelvis.Position
    else
        pos2 = _enemy.Avatar.Bone_Pelvis.HeadPoint.Position
    end
    return (2 * pos1 + pos2) / 3
end

--- 使相机根据方位角移动到正确的位置
function WeaponCamera:SetProperties()
    CameraControl.deltaTheta = CameraControl.deltaTheta + self.deltaTheta
    CameraControl.deltaPhy = CameraControl.deltaPhy + self.deltaPhy
    CameraControl.gamma = self.m_gamma
    CameraControl.fieldOfView = self.m_supposedZoom + self.m_deltaFOV
    CameraControl.distance = self.distance
    CameraControl.offset = self.m_currentOffset
end

--- 相机的悬臂的位置（肩膀上方的位置）
function WeaponCamera:GetCameraPos()
    local offset = self.m_camera.Offset
    return localPlayer.Position + offset:Rotate(Vector3.Up, localPlayer.Rotation.y)
end

--- 获得瞄准位置
--- 返回一个Vector3和一个boolean，为true代表空间的点，为false代表空间方向
function WeaponCamera:GetTarget()
    ---加入时间戳防止多次调用
    if (self.targetCallTime and Timer.GetTime() - self.targetCallTime < 0.01) then
        return self.targetReturn[1], self.targetReturn[2]
    end
    ---print('调用相机的寻找目标')
    local dir = self.m_camera.Forward.Normalized
    local pos = self:GetCameraPos()
    local rayCastAll = Physics:RaycastAll(pos + 0.5 * dir, pos + self.gun.config_distance * dir, false)
    self.aimEnemy = nil
    if (self.enableAssistAim) then
        local minDis = self:GetAssistAimDis()
        local candidate = nil
        for k, v in pairs(self:GetEnemies()) do
            ---找到最接近的人
            local targetPos = self:GetAimPos(v)
            local targetDis = (targetPos - pos).Magnitude
            local angle = Vector3.Angle(dir, targetPos - pos)
            local aimDis = targetDis * math.sin(angle * math.pi / 180)
            if (angle < 30 and aimDis <= minDis and self:IsVisible(v)) then
                minDis = aimDis
                candidate = v
            end
        end
        self.aimEnemy = candidate
    end
    local hitObjects = rayCastAll.HitObjectAll
    local hitPoints = rayCastAll.HitPointAll
    local finalPoint
    local i
    for i = 1, #hitObjects do
        if (not ParentPlayer(hitObjects[i]) and hitObjects[i].Block) and hitObjects[i].CollisionGroup ~= 10 then
            finalPoint = hitPoints[i]
            break
        end
    end
    if (finalPoint) then
        self.targetReturn = {finalPoint, true}
    else
        ---print('平行子弹')
        self.targetReturn = {dir, false}
    end
    self.targetCallTime = Timer.GetTime()
    return self.targetReturn[1], self.targetReturn[2]
end

--- 判断位置在左还是右
function WeaponCamera:IsRight(_pos)
    return (Vector3.Dot(Vector3.Cross(self.m_camera.Forward, Vector3.Up), _pos - self:GetCameraPos()) > 0)
end

---判断位置在上还是在下
function WeaponCamera:IsUp(_pos)
    local relativePos = _pos - self:GetCameraPos()
    return math.atan(relativePos.y / Vector2(relativePos.x, relativePos.z).Magnitude) >
        (90 - Vector3.Angle(world.CurrentCamera.Forward, Vector3.Up) * math.pi / 180)
end

--- 鼠标拖动部分
function WeaponCamera:DragStart()
    self.m_lastMousePos = Input.GetMouseScreenPos()
end

function WeaponCamera:GetSensitivity()
    return world.CurrentCamera.FieldOfView / 60 * self.m_sensitivity
end

function WeaponCamera:DragHold()
    local temp = Input.GetMouseScreenPos()
    if (not self.m_lastMousePos) then
        return
    end
    self.deltaPhy = self.deltaPhy + (temp.x - self.m_lastMousePos.x) / self.screenSize.x * self:GetSensitivity()
    self.deltaTheta = self.deltaTheta + (temp.y - self.m_lastMousePos.y) / self.screenSize.x * self:GetSensitivity()
    self.m_lastMousePos = temp
end

function WeaponCamera:DragEnd()
    self.m_lastMousePos = nil
end

---更新倍率
function WeaponCamera:RefreshScales()
    local factor = 1
    factor = 1
    for k, v in pairs(self.m_jumpFovRateTable) do
        factor = factor * v
    end
    self.m_jumpFovRateScale = factor
    factor = 1
    for k, v in pairs(self.m_aimTimeRateTable) do
        factor = factor * v
    end
    self.m_aimTimeRateScale = factor
end

---根据玩家设置改属性
function WeaponCamera:RefreshSettings()
    --self.enableAssistAim = SettingGui:
end

---结束一切协程(一部分可作为析构器用)
function WeaponCamera:EndAll()
    if (self.m_isZoomIn) then
        self:MechanicalAimStop()
    end
    while (true) do
        local toStop = {}
        for k, v in pairs(self.FixUpdateTable) do
            toStop[#toStop + 1] = v
        end
        for k, v in pairs(self.UpdateTable) do
            toStop[#toStop + 1] = v
        end
        if (#toStop == 0) then
            goto EndAllBreak
        end
        for i, v in ipairs(toStop) do
            v:Stop()
        end
    end
    ::EndAllBreak::
    ---print('结束一切相机动画')
    self:SetProperties()
    self.deltaPhy = 0
    self.deltaTheta = 0
end

function WeaponCamera:Destructor()
    self:EndAll()
    ClearTable(self)
    self = nil
end

return WeaponCamera
