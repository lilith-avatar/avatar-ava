---@module WeaponGUI 枪械模块：枪械的瞄准ui管理类
---@copyright Lilith Games, Avatar Team
---@author Sharif Ma, RopzTao, An Dai
local WeaponGUI = class('WeaponGUI')

---WeaponGUI类的构造函数
---@param _gunController GunBase 这个UI所属的枪械类
function WeaponGUI:initialize(_gunController)
    self.m_gui = world:CreateInstance('WeaponGUI', 'WeaponGUI', localPlayer.Local)
    self.gunController = _gunController
    self.m_gui:SetActive(false)
    self:GetScreenSize()
    ---枪的准星
    self.aimer = nil
    self.banShooting = self.m_gui.BanShooting
    self.crosshair = self.m_gui.LineCrosshair
    self.scope = self.m_gui.OpticalSight.Telescope
    self.dot = self.m_gui.OpticalSight.RedDot
    --镜的跳动部分
    self.uiJumpOmega = self.gunController.m_recoil.config_uiJumpOmega
    self.uiJumpMax = self.gunController.m_recoil.config_uiJumpMax
    self.uiJumpAmpl = self.gunController.m_recoil.config_uiJumpAmpl
    self.uiJumpDump = self.gunController.m_recoil.config_uiJumpDump
    self.uiJumpAngle = self.gunController.m_recoil.config_uiJumpAngle * math.pi / 180
    --默认镜
    self.scopeName, self.dotName, self.crosshairName = table.unpack(self.gunController.defaultAimImage)
    ---屏幕数据
    self.scopeStandardSize = nil
    ---初始化资源
    if (self.gunController.WaistAimMode == 'RightAngle') then
        self.crosshair.Size = Vector2(24, 17)
        self.crosshair.Color = Color(255, 255, 255, 255)
    elseif (self.gunController.WaistAimMode == 'Ring') then
        for i = 1, 4 do
            self.crosshair['LineCrosshair' .. tostring(i)].Texture =
                ResourceManager.GetTexture('WeaponPackage/UI/WeaponGUI/Img_Ring_' .. tostring(i))
            self.crosshair['LineCrosshair' .. tostring(i)].Size = Vector2(21 * (i % 2) + 7, 28 - 21 * (i % 2))
            self.crosshair['LineCrosshair' .. tostring(i)].Color = Color(255, 255, 255, 255)
        end
    elseif (self.gunController.WaistAimMode == 'Crosshair') then
        self.crosshair.Size = Vector2(5, 5)
        self.crosshair.Texture = ResourceManager.GetTexture('WeaponPackage/UI/WeaponGUI/Img_Crosshair_Middle')
        self.crosshair.Color = Color(255, 255, 255, 255)
        for i = 1, 4 do
            self.crosshair['LineCrosshair' .. tostring(i)].Color = Color(255, 255, 255, 255)
        end
    else
        error('undefined WaistAimMode!!!')
    end
    self.crosshair.Size = self.crosshair.Size
    for i = 1, 4 do
        self.crosshair['LineCrosshair' .. tostring(i)].Size = self.crosshair['LineCrosshair' .. tostring(i)].Size
    end

    self.crs1offsets = {}
    for k, v in ipairs(self.crosshair:GetChildren()) do
        v.Offset = v.Offset * self.screenSize.x / 2000
        table.insert(self.crs1offsets, v.Offset)
    end

    self.isZoomIn = false
    ---持有的变量
    --准心的相对移动
    self.deltaAngle = Vector2.Zero
    ---准心移动offset随角度的变化
    self.dotAngleToOffset = nil
    ---准心的回复倍率（屏幕宽度为1,单位为1/s）
    self.backRate = 5
    ---准心的最大偏移（屏幕为1）
    self.maxProportion = GunConfig.GlobalConfig.DotAnchorMax
    ---准心的最大偏移（单位为像素）
    self.maxAngle = nil
    ---动画控制器
    self.UpdateTable = {}
    self.FixUpdateTable = {}
    ---开镜总动画
    self.aimController =
        TweenController:new(
        'aim',
        self,
        function()
            return self.gunController.m_cameraControl:GetAimTime()
        end,
        function(_t1, _t2, _dt)
            local por = math.sqrt(_t1 / _t2)
            self.scope.Angle = (1 - por) * self.aimController.initAngle + por * self.aimController.finalAngle
            self.scope.Size = (1 - por) * self.aimController.initSize + por * self.aimController.finalSize
            local poor = math.sqrt(por)
            self.scope.Offset =
                Vector2(
                (1 - por) * self.aimController.initOffset.x + por * self.aimController.finalOffset.x,
                (1 - poor) * self.aimController.initOffset.y + poor * self.aimController.finalOffset.y
            )
            self:SizeEqual()
        end,
        function()
            self.scope.Offset = self.aimController.finalOffset
            self.scope.Angle = self.aimController.finalAngle
            self.scope.Size = self.aimController.finalSize
            self:SizeEqual()
        end,
        true,
        function()
            self.deltaAngle = Vector2.Zero
            self.m_gui.OpticalSight:SetActive(true)
            self.aimController.finalOffset = Vector2.Zero
            self.aimController.finalAngle = 0
            self.aimController.finalSize = self.scopeStandardSize * 1.1
            self.aimController.initOffset = self.scope.Offset
            self.aimController.initAngle = (self.scope.Angle < 0) and self.scope.Angle or self.scope.Angle - 360
            self.aimController.initSize = self.scope.Size
            self:SizeEqual()
        end
    )

    self.uiJumpController =
        TweenController:new(
        'uiJump',
        self,
        function()
            local remnPhase = 2 * math.pi - self.uiJumpController.phaseY
            return remnPhase / self.uiJumpOmega
        end,
        function(_time, _totalTime, _dt)
            local exp = math.exp(-self.uiJumpDump * _time)
            self.uiJumpController.valueY =
                self.uiJumpController.AmplY * exp * math.sin(self.uiJumpOmega * _time + self.uiJumpController.phaseY)
            self.uiJumpController.valueX =
                self.uiJumpController.AmplX * exp * math.sin(self.uiJumpOmega * _time + self.uiJumpController.phaseX)
            local finValueY =
                self.uiJumpMax == 0 and 0 or
                self.uiJumpMax * AsymtoteBi(self.uiJumpController.valueY / self.uiJumpMax) / 12 + 0.5
            local finValueX =
                self.uiJumpMax == 0 and 0 or
                self.uiJumpMax * AsymtoteBi(self.uiJumpController.valueX / self.uiJumpMax) / 12 + 0.5
            self.uiJumpController.ui.AnchorsY = Vector2(finValueY, finValueY)
            self.uiJumpController.ui.AnchorsX = Vector2(finValueX, finValueX)
        end,
        function()
            self.uiJumpController.ui.AnchorsY = Vector2(0.5, 0.5)
            self.uiJumpController.ui.AnchorsX = Vector2(0.5, 0.5)
        end,
        true,
        function()
            self.uiJumpController.valueY = self.uiJumpController.valueY or 0
            self.uiJumpController.valueX = self.uiJumpController.valueX or 0
            self.uiJumpController.ui = self.scope.Parent
            local remn = self.FixUpdateTable.uiJump
            if (not remn) then
                self.uiJumpController.phaseY = 0
                self.uiJumpController.phaseX = 0
                self.uiJumpController.angle = self.uiJumpAngle * GaussRandom()
                self.uiJumpController.AmplY = self.uiJumpAmpl
                self.uiJumpController.AmplX = self.uiJumpController.AmplY * math.tan(self.uiJumpController.angle)
            else
                local exp = math.exp(-self.uiJumpDump * self.uiJumpController.time)
                local tempAY = self.uiJumpController.AmplY * exp
                local tempAX = self.uiJumpController.AmplX * exp
                local tempOY =
                    tempAY * self.uiJumpOmega *
                    math.cos(self.uiJumpOmega * self.uiJumpController.time + self.uiJumpController.phaseY)
                local tempOX =
                    tempAX * self.uiJumpOmega *
                    math.cos(self.uiJumpOmega * self.uiJumpController.time + self.uiJumpController.phaseX)
                local deltaY = self.uiJumpOmega * self.uiJumpAmpl
                self.uiJumpController.angle = self.uiJumpAngle * GaussRandom()
                local deltaX = deltaY * math.tan(self.uiJumpController.angle)
                local newPhaseY = math.atan(self.uiJumpController.valueY * self.uiJumpOmega / (deltaY + tempOY))
                local newPhaseX = math.atan(self.uiJumpController.valueX * self.uiJumpOmega / (deltaX + tempOX))
                local newAmplY = (deltaY + tempOY) / self.uiJumpOmega / math.cos(newPhaseY)
                local newAmplX = (deltaX + tempOX) / self.uiJumpOmega / math.cos(newPhaseX)
                self.uiJumpController.AmplY = newAmplY
                self.uiJumpController.AmplX = newAmplX
                self.uiJumpController.phaseY = newPhaseY
                self.uiJumpController.phaseX = newPhaseX
            end
        end
    )
    self:GetScreenInfo()
    self:RefreshAimer()
    self:ScopeBack()
    ---是否允许显示准星命中特效
    self.isAllowShowHitCross = true
    ---命中后的自身的准心反馈
    function self.HitCrosshairEffect(_sender, _infoList)
        if not GunConfig.GlobalConfig.EnableHitCallBack then
            return
        end
        if _infoList.Player.Health <= 0 then
            return
        end
        if not _infoList.Player or not _infoList.Player.Health then
            return
        end
        if not self.m_gui then
            return
        end
        if not self.isAllowShowHitCross then
            return
        end
        self.isAllowShowHitCross = false
        local delay = 0
        if PlayerGunMgr.quality == QualityBalance.QualityEnum.Middle then
            ---中画质
            delay = 0.3
        elseif PlayerGunMgr.quality == QualityBalance.QualityEnum.Low then
            ---低画质
            delay = 0.5
        end
        invoke(
            function()
                self.isAllowShowHitCross = true
            end,
            delay
        )
        local hitPart = _infoList.HitPart
        if hitPart and hitPart == HitPartEnum.Head then
            self.m_gui.ShootCross.Normal:SetActive(false)
            self.m_gui.ShootCross.Head:SetActive(true)
        else
            self.m_gui.ShootCross.Normal:SetActive(true)
            self.m_gui.ShootCross.Head:SetActive(false)
        end
        NetUtil.Fire_C(
            'StartAnimationEvent',
            localPlayer,
            'Weapon_HitCross',
            false,
            {
                self.m_gui.ShootCross,
                self.m_gui.ShootCross.Normal,
                self.m_gui.ShootCross.Head
            }
        )
    end
    ---绑定击中成功的回调
    self.gunController.successfullyHit:Bind(self.HitCrosshairEffect)
end

function WeaponGUI:Update(_deltaTime)
    if self.gunController.m_animationControl.noShootingState then
        ---当前不允许射击
        self.banShooting:SetActive(true)
        if not self.isZoomIn then
            self.crosshair:SetActive(false)
        end
    else
        self.banShooting:SetActive(false)
        if not self.isZoomIn then
            self.crosshair:SetActive(true)
        end
    end
    self:InertiaActConditions(_deltaTime)
end

function WeaponGUI:Fire()
    if (self.isZoomIn) then
        self.uiJumpController:Start()
    end
end

function WeaponGUI:FixUpdate(_dt)
    if (not self.gunController.error) then
        return
    end
    local Todo = {}
    for k, v in pairs(self.FixUpdateTable) do
        Todo[#Todo + 1] = v
    end
    for i, v in ipairs(Todo) do
        v:FixUpdate(_dt)
    end
    for i, v in ipairs(self.crosshair:GetChildren()) do
        v.Offset =
            v.Offset / (math.abs(v.Offset.x) + math.abs(v.Offset.y)) *
            (self.gunController.error / self.standardRatio * math.min(self.screenSize.x, 2 * self.screenSize.y) / 240) +
            --ToRewrite
            self.crs1offsets[i]
    end
    if (self.isZoomIn) then
        self:DotFollow(_dt)
    end
end

--基本相当于OnEquip 和 OnUnEquip
function WeaponGUI:SetVisible(_active)
    if _active == false then
        for i, v in ipairs(self.crosshair:GetChildren()) do
            v.Offset = self.crs1offsets[i]
        end
        if (self.isZoomIn) then
            self:MechanicalAimStop()
        end
    elseif (_active == true) then
        self.m_gui.OpticalSight:SetActive(false)
    end
    self.m_gui:SetActive(_active)
end

function WeaponGUI:Destructor()
    self.m_gui:Destroy()
    ClearTable(self)
    self = nil
end

function WeaponGUI:RefreshAimer()
    self.aimer = self.gunController.m_weaponAccessoryList.sight
    if (not self.aimer) then
        self.scopeName, self.dotName, self.crosshairName = table.unpack(self.gunController.defaultAimImage)
    elseif (self.aimer.sightImage[self.gunController.gun_Id]) then
        self.scopeName, self.dotName, self.crosshairName =
            table.unpack(self.aimer.sightImage[self.gunController.gun_Id])
    else
        self.scopeName, self.dotName, self.crosshairName = table.unpack(self.aimer.sightImage[0])
    end

    self.scope.Texture = ResourceManager.GetTexture('WeaponPackage/UI/WeaponGUI/' .. self.scopeName)
    self.dot.ImgFill.InnerScope.Texture = ResourceManager.GetTexture('WeaponPackage/UI/WeaponGUI/' .. self.dotName)
    self.dot.ImgFill.Crosshair.Texture = ResourceManager.GetTexture('WeaponPackage/UI/WeaponGUI/' .. self.crosshairName)
    ---绕行白边
    if (self.scopeName ~= 'Img_Scope_4xxxx') then
        self.scope.Color = Color(255, 255, 255, 255)
        self.dot.ImgFill.InnerScope.Color = Color(255, 255, 255, 255)
        self.dot.ImgFill.Crosshair.Color = Color(255, 255, 255, 255)
    else
        self.scope.Color = Color(0, 0, 0, 255)
        self.dot.ImgFill.InnerScope.Color = Color(0, 0, 0, 255)
        self.dot.ImgFill.Crosshair.Color = Color(255, 255, 255, 255)
    end
end

function WeaponGUI:GetScreenSize()
    self.screenSize = self.m_gui.Size
    if self.screenSize.x > 100000 or self.screenSize.x <= 0 then
        self.screenSize = Vector2(1920, 1080)
    end
    self.standardRatio = math.min(self.screenSize.x / 2000, self.screenSize.y / 1000)
    return self.screenSize
end

---和检测屏幕相关的逻辑全都在这
function WeaponGUI:GetScreenInfo()
    self:GetScreenSize()
    self:ScopeAdapt()
    self:RedDotAdapt()
    local maxPhy = (self.gunController.m_cameraControl:GetSightFOV() * 2 * math.pi / 180) --开镜状态下屏幕从最左到最右的实际角度
    self.dotAngleToOffset = self.screenSize.x / maxPhy / 5
    --math.max(1, 5 - (math.log(60 / world.CurrentCamera.FieldOfView, 2)))--ToRewrite
    self.maxAngle = self.maxProportion * maxPhy
end

---获得镜的尺寸
function WeaponGUI:ScopeAdapt()
    local scopeInitSize = ImgSize[self.scopeName]
    local shapeRatio = scopeInitSize.x / scopeInitSize.y
    self.scopeStandardSize = Vector2(self.screenSize.y * shapeRatio, self.screenSize.y) / self.standardRatio
end

---获得面板和准心的尺寸
function WeaponGUI:RedDotAdapt()
    local scopeInitSize = ImgSize[self.scopeName]
    local panelInitSize = ImgSize[self.dotName]
    local scale = self.scopeStandardSize.y / scopeInitSize.y
    self.panelStandardSize = scale * panelInitSize
end

--使准心适配镜旋转
function WeaponGUI:SizeEqual()
    self.dot.Size = self.scope.Size.y / self.scopeStandardSize.y * self.panelStandardSize
    self.dot.Offset = self.scope.Offset
    self.dot.ImgFill.Crosshair.Angle = self.scope.Angle
end

--开镜
function WeaponGUI:MechanicalAimStart()
    if (self.isZoomIn) then
        return
    end
    self.crosshair:SetActive(false)
    self.isZoomIn = true
    self:RefreshAimer()
    self:GetScreenInfo()
    self:SizeEqual()
    self.aimController:Start()
end

--关镜
function WeaponGUI:MechanicalAimStop()
    if (not self.isZoomIn) then
        return
    end
    local remn = self.FixUpdateTable.uiJump
    if (remn) then
        --print('结束枪口跳动动画')
        remn:Stop()
    end
    remn = self.FixUpdateTable.aim
    if (remn) then
        remn:Stop()
    end
    self.isZoomIn = false
    self:ScopeBack()
    self.m_gui.LineCrosshair:SetActive(true)
end

--处理红点的延迟
function WeaponGUI:DotFollow(_dt)
    if (self.FixUpdateTable.aim) then
        return
    end
    local divider = math.max(self.deltaAngle.Magnitude, 1e-7)
    self.deltaAngle = math.clamp(self.deltaAngle.Magnitude, 0, self.maxAngle) / divider * self.deltaAngle
    local scaler = function(_x, _max)
        return _max * AsymtoteBi(_x / _max, 0.2)
    end
    self.dot.ImgFill.Offset =
        self.scope.Offset -
        Vector2(scaler(self.deltaAngle.x, self.maxAngle), scaler(self.deltaAngle.y, self.maxAngle)) *
            self.dotAngleToOffset /
            3
    self.deltaAngle =
        self.deltaAngle - self.deltaAngle * _dt * self.backRate * 3 * math.sqrt(world.CurrentCamera.FieldOfView / 60)
    --线性回归
end

---红点强行归位
function WeaponGUI:DotBack()
    self.dot.Offset = self.scope.Offset
end

---镜和红点归位
function WeaponGUI:ScopeBack()
    self.m_gui.OpticalSight:SetActive(false)
    local screenSize = self:GetScreenSize()
    self.m_gui.OpticalSight.Telescope.Offset = Vector2(0.3 * screenSize.x, -1 * screenSize.y)
    self.m_gui.OpticalSight.Telescope.Size = 0.3 * self.scopeStandardSize
    self.m_gui.OpticalSight.Telescope.Angle = -22
    self.dot.Size = Vector2(11, 11) / self.standardRatio
    self:DotBack()
end

---惯性启用条件
function WeaponGUI:InertiaActConditions(dt)
    if self.isZoomIn and not self.FixUpdateTable.aim then
    ---self:ScopeInertia(dt)
    end
end

---准镜惯性
local siCoeff, joyNum = Vector2.zero, 0
function WeaponGUI:ScopeInertia(dt)
    joyNum = Vector2(BattleGUI.horizontal, BattleGUI.vertical)
    siCoeff = Vector2.Slerp(joyNum, Vector2(BattleGUI.vertical, BattleGUI.horizontal), 0.5)
    print(siCoeff)
    self.m_gui.OpticalSight.Telescope.Offset = siCoeff * localPlayer.WalkSpeed * 10
end

return WeaponGUI
