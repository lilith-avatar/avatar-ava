--- @module BattleGUI 枪械模块：战斗UI
--- @copyright Lilith Games, Avatar Team
--- @author RopzTao
local BattleGUI, this = {}, nil

local OffPos = {0, 60, 120, 180}
local tt, players, dis, realDis, warning, downTime, reloadAni = 0, {}, 0, 0, false, 0, false
local selfColor, enemyColor = Color(71, 81, 224, 180), Color(255, 0, 0, 150)

---初始化函数
function BattleGUI:Init()
    this = self
    self:InitListener()
    ---是否开始滑屏
    self.swipeStarted = false
    ---self.gun = nil
    self.battleNodeTab = {}

    ---@type PlayerInstance
    self.player = localPlayer

    ---在玩家本地创建战斗ui
    ---@type UiScreenUiObject
    self.root = world:CreateInstance('BattleGUI', 'BattleGUI', self.player.Local)
    self.root.Order = 500

    ---声明战斗ui节点
    self:DeclareNode()

    ---部分节点初始禁用
    self:PartNodeMgr()

    ---声明一些需要用到的数据
    self:DeclareInitData()

    self:KeyBinding()

    ---绕行编辑器BUG
    self:DetourEditorBug()

    local co =
        coroutine.create(
        function()
            BattleGUI:ManualUpd()
        end
    )
    coroutine.resume(co)
end

function BattleGUI:DeclareNode()
    for _, v in pairs(self.root:GetChildren()) do
        self[tostring(v)] = v
    end

    ---下蹲按钮
    self.CrouchBtn = ButtonBase:new(self.root.CrouchBtn, UIBase.AniTypeEnum.Scale)
    ---跳跃按钮
    self.BtnJump = ButtonBase:new(self.root.BtnJump, UIBase.AniTypeEnum.Scale)
    ---换弹按钮
    self.BtnReload = ButtonBase:new(self.root.BtnReload, UIBase.AniTypeEnum.Scale)
    ---瞄准按钮
    self.BtnAim = ButtonBase:new(self.root.BtnAim, UIBase.AniTypeEnum.Scale)
    ---左侧开火按钮
    self.BtnFireLeft = ButtonBase:new(self.root.ImgFireLeft.BtnFireLeft)
    ---右侧开火按钮
    self.BtnFire = ButtonBase:new(self.root.ImgFire.BtnFire)
    ---准星上换弹的进度
    self.ReloadPrs = ImageBase:new(self.root.ReloadPrs)

    self.SimHandle = self.root.SimJoy.SimHandle
    self.BagImage = self.BtnDrop.BagImage
    self.FireLeftCdImage = self.ImgFireLeft.FireLeftCdImage
    self.FireCdImage = self.ImgFire.FireCdImage
    self.SimHandleSure = self.SimJoy.SimHandleSure
    self.BtnRunHes = self.ImgRunHes.BtnRunHes
    self.BtnRunHes2 = self.ImgRunHes.BtnRunHes2
    self.ReloadCdImage = self.BtnReload.m_ui.ReloadCdImage

    self.ReloadCdImage.Clockwise = false
end

function BattleGUI:DeclareInitData()
    self.finalScreenSize = self.root.Size
    if self.finalScreenSize.x > 100000 or self.finalScreenSize.x <= 0 then
        self.finalScreenSize = Vector2(1920, 1080)
    end
    self.AimTouchSize = self.root.ImgFire.BtnFire.FinalSize
    self.MoveTouchSize = self.root.FigLeft.FinalSize
    self.forwardDir = Vector3.Forward
    self.rightDir = Vector3.Right
    self.finalDir = Vector3.Zero
    self.simHor = 0
    self.simVer = 0
    ---当前帧的更新时间间隔
    self.curRefreshInterval = 1 / 60

    ---定义一些参数
    ---与键盘事件兼容
    self.keyUsing = true
    self.using = false
    self.fingerLastPos = nil
    self.firstPickGun = 0
    self.killInfoNum = 0
    self.defaultSens = 0.5
    self.autoRun = false
    self.BtnRunHes2:SetActive(false)
    self.rightAimFire = false
    self.rightDown = false
    self.ReloadPrs:CallFunction('SetActive', false)

    ---击杀滚动条
    self.SlidingKill = self.root.SlidingKill
    self.SlidingKill:SetActive(false)
    ---显示在UI上的图标列表
    self.curKillTab = {}

    self.BattleJoy.ValidArea = self.MoveTouchSize
    self.BattleJoy.Threshold = 0
    self.BattleJoy.Normalized = false

    ---资源读取
    self.btnAimRes = ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/Icon_Fight_Player_Aim')
    self.btnAimRes2 = ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/Icon_Fight_Player_Aim2')
end

function BattleGUI:PartNodeMgr()
    ---cd图ui
    self.MaskTab = {
        self.ReloadCdImage,
        self.InfoKill,
        ---self.BagImage,
        self.FireLeftCdImage,
        self.FireCdImage,
        self.HitRange
    }
    self:SwitchNode(false, self.MaskTab)

    ---开火节点管理表
    self.battleNodeTab = {
        self.ImgFireLeft,
        self.BtnReload.m_ui,
        self.ImgFire,
        self.BtnAim.m_ui
        ---self.FigRight,
    }
    ---禁用开枪部分
    self:SwitchNode(false, self.battleNodeTab)
end

---按键事件绑定
function BattleGUI:KeyBinding()
    ---滑动屏幕
    self.FigRight.OnTouched:Connect(
        function(_touchInfo)
            self.RightFingerTouch(_touchInfo)
        end
    )

    self.FigRight.OnPanEnd:Connect(
        function()
            self.swipeStarted = false
        end
    )

    ---跳事件处理函数绑定
    self.BtnJump:BindHandler('OnClick', self.PlayerJumpClick)

    ---蹲事件处理函数
    self.CrouchBtn:BindHandler('OnClick', self.PlayerCrouchClick)

    ---打开背包
    --[[
    self.BtnDrop.OnClick:Connect(function()
        BagGUI:Show()
    end)]]
    ---快跑
    self.BtnRunHes.OnEnter:Connect(
        function()
            self.BtnRunHes.Size = Vector2(self.FigLeft.FinalSize.x, 500)
            self:ReadyToRun()
            self.BtnRunHes2:SetActive(true)
            self.ImgRunHes.Texture = ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/Icon_Fight_Player_Run2')
        end
    )

    self.BtnRunHes.OnLeave:Connect(
        function()
            self.BtnRunHes2:SetActive(false)
            self.BtnRunHes.Size = Vector2(120, 120)
            PlayerBehavior:PlayerBehaviorChanged('isQuickly')
            self.ImgRunHes.Texture = ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/Icon_Fight_Player_Run')
        end
    )

    self.BtnRunHes2.OnLeave:Connect(
        function()
            self:ReadyToRun()
        end
    )

    ---解除快跑
    self.SimHandle.OnEnter:Connect(
        function()
            self.ImgRunHes.Texture = ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/Icon_Fight_Player_Run')
            PlayerBehavior:PlayerBehaviorChanged('isQuickly')
        end
    )

    self.IsAimOrNot.OnValueChanged:Connect(
        function()
            if localPlayer.Health <= 0 then
                return
            end
            PlayerBehavior:PlayerBehaviorChanged('isAim')
        end
    )
end

function BattleGUI:DetourEditorBug()
    ---判定当前平台是否为PC
    if (world:GetDevicePlatform() == Enum.Platform.Windows) then
        world.CurrentCamera.CursorLock = true
        world.CurrentCamera.EnableMouseDrag = true
    else
        world.CurrentCamera.CursorLock = false
        world.CurrentCamera.EnableMouseDrag = false
    end
end

---监听函数
function BattleGUI:InitListener()
    LinkConnects(localPlayer.C_Event, BattleGUI, this)
end

function BattleGUI:FixInit()
    ---战斗界面需要用到的控件启动
    self:SwitchNode(true, self.battleNodeTab)
    ---换子弹按钮按下
    self.BtnReload:BindHandler('OnClick', self.BtnReloadClick)
    ---瞄准按键按下
    self.BtnAim:BindHandler('OnClick', self.AimBtnClick)
    ---瞄准按钮失活
    self.BtnAim:BindHandler('OnDeactiveInHierarchy', self.AimBtnDisable)
    ---左边开火按钮按下
    self.BtnFireLeft:BindHandler('OnDown', self.BtnFireLeftDown)
    ---左边开火按钮抬起
    self.BtnFireLeft:BindHandler('OnUp', self.BtnFireLeftUp)
    ---右边开火按钮按下
    self.BtnFire:BindHandler('OnDown', self.BtnFireRightDown)
    ---右边开火按钮抬起
    self.BtnFire:BindHandler('OnUp', self.BtnFireRightUp)
    ---开火后滑动屏幕
    self.BtnFire:BindHandler('OnTouched', self.RightFingerTouch)

    self.player.OnHealthChange:Connect(
        function()
            if PlayerGunMgr.curGun == nil then
                return
            end
            if self.player.Health <= 0 then
                self.using = false
                ---如果玩家死后还是开镜
                if PlayerGunMgr.curGun.m_isZoomIn then
                    PlayerGunMgr.curGun:MechanicalAimStop()
                    PlayerBehavior:PlayerBehaviorChanged('isAim')
                end
                if self.rightDown then
                    self:OnUpCon()
                end
            end
        end
    )
end

function BattleGUI:OnUpCon()
    self.rightDown = false
    ---表现逻辑
    self.BtnFire:SetValue('Size', Vector2(200, 200))
    self.FigRight:SetActive(true)
    self.using = false
    self.FireCdImage:SetActive(false)
    ---功能逻辑
    if not self.rightAimFire then
        PlayerGunMgr.curGun:TryPump(self.rightAimFire)
    else
        PlayerGunMgr.curGun:TryPump(self.rightAimFire)
    end

    if self.rightAimFire and PlayerGunMgr.curGun.m_cameraControl.AimingIsOver then
        if PlayerGunMgr.curGun.m_curShootMode == FireModeEnum.Single then
            self:FireModeCheck()
        end
        ---调用开火之后立刻调用其他函数，函数和开火之间的时序可能会有1-2帧的误差
        invoke(
            function()
                PlayerGunMgr.curGun:MechanicalAimStop()
            end,
            0.1
        )
        self.rightAimFire = false
    end
end

---右边开火检测逻辑
---开火时间
---根据开火时间的快慢决定开镜
---根据枪械类型决定开火模式
function BattleGUI:RightFireCheck(dt)
    if self.rightDown then
        downTime = downTime + dt
        if downTime > 0.25 and PlayerGunMgr.curGun and not PlayerGunMgr.curGun.m_isZoomIn then
            PlayerGunMgr.curGun:MechanicalAimStart()
            self.rightAimFire = true
            downTime = 0
        end
        ---功能逻辑
        if self.rightAimFire then
            if PlayerGunMgr.curGun.m_curShootMode ~= FireModeEnum.Single then
                self:FireModeCheck()
            end
        end
    end
end

---开火组件事件解绑
function BattleGUI:FireComponentDestruct()
    self.BtnReload:UnbindHandler('OnClick')
    self.BtnAim:UnbindHandler('OnClick')
    self.BtnFireLeft:UnbindHandler('OnDown')
    self.BtnFireLeft:UnbindHandler('OnUp')
    self.BtnFire:UnbindHandler('OnDown')
    self.BtnFire:UnbindHandler('OnUp')
    self.BtnFire:UnbindHandler('OnTouched')
end

---拾起一把枪并装备
function BattleGUI:OnEquipWeaponEventHandler()
    if PlayerGunMgr.curGun == nil then
        return
    end
    self.firstPickGun = self.firstPickGun + 1
    if self.firstPickGun == 1 then
        self:FixInit()
    end
end

---将一把枪脱下的事件
function BattleGUI:OnUnEquipWeaponEvent()
    self.using = false
    if PlayerGunMgr.curGun == nil or PlayerGunMgr.curGun == PlayerGunMgr.mainGun then
        self:SwitchNode(false, self.battleNodeTab)
    end
end

function BattleGUI:WithDrawOrNot()
    if PlayerGunMgr.curGun == nil then
        return
    end
    self.using = false
    if PlayerGunMgr.curGun.m_isDraw then
        self:SwitchNode(true, self.battleNodeTab)
    else
        self.horizontal = 0
        self.vertical = 0
        self:SwitchNode(false, self.battleNodeTab)
    end
end

---控制部分节点开关
---@param _res boolean 控制节点开关的布尔值
---@param _tab table 存放需要控制的节点的表
function BattleGUI:SwitchNode(_res, _tab)
    for _, v in pairs(_tab) do
        v:SetActive(_res)
    end
end

---玩家按下跳跃键，如果为站立状态则跳，如果为蹲下状态则恢复站立
function BattleGUI.PlayerJumpClick()
    local self = BattleGUI
    if localPlayer.Health <= 0 then
        return
    end
    PlayerBehavior:PlayerJump()
    self:JumpResourceChange()
end

---玩家蹲下，不仅要考虑avatar的动画，还要加入相机的offset
function BattleGUI.PlayerCrouchClick()
    local self = BattleGUI
    if localPlayer.Health <= 0 then
        return
    end
    PlayerBehavior:PlayerCrouch()
    self:CrouchResourceChange()
end

---跳资源替换
function BattleGUI:JumpResourceChange()
    if (self.player.IsOnGround or self.player.State == Enum.CharacterState.Seated) and not isDead then
        if self.player:IsCrouch() then
            self.CrouchBtn:SetValue(
                'Texture',
                ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/Icon_Fight_Player_Squat')
            )
        else
            self.BtnJump:SetValue(
                'Texture',
                ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/Icon_Fight_Player_Jump2')
            )
            invoke(
                function()
                    self.BtnJump:SetValue(
                        'Texture',
                        ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/Icon_Fight_Player_Jump')
                    )
                end,
                0.6
            )
        end
    end
end

---蹲下资源替换
function BattleGUI:CrouchResourceChange()
    if not self.player:IsCrouch() then
        self.CrouchBtn:SetValue(
            'Texture',
            ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/Icon_Fight_Player_Squat2')
        )
    else
        self.CrouchBtn:SetValue(
            'Texture',
            ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/Icon_Fight_Player_Squat')
        )
    end
end

---瞄准资源替换
function BattleGUI:AimResourceChange()
    if not PlayerGunMgr.curGun.m_isZoomIn then
        self.BtnAim:SetValue('Texture', self.btnAimRes)
    else
        self.BtnAim:SetValue('Texture', self.btnAimRes2)
    end
end

---玩家枪械交互重置
function BattleGUI:GunInterReset()
    self.rightDown = false
    self.BtnFire:SetValue('Size', Vector2(200, 200))
    self.FigRight:SetActive(true)
    self.using = false
    self.FireCdImage:SetActive(false)
    self.BtnAim:SetValue('Texture', ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/Icon_Fight_Player_Aim'))
    self.IsAimOrNot.Value = false
end

---换子弹UI动效
function BattleGUI:ReloadResourceChange(dt)
    local delta = (1 / PlayerGunMgr.curGun.m_magazine:GetLoadTime()) * dt
    self.ReloadCdImage.FillAmount = self.ReloadCdImage.FillAmount - delta
    local curFillAmount = self.ReloadPrs:GetValue('FillAmount')
    self.ReloadPrs:SetValue('FillAmount', delta + curFillAmount)
    if self.ReloadCdImage.FillAmount <= 0 then
        self.ReloadCdImage:SetActive(false)
        self.ReloadPrs:CallFunction('SetActive', false)
        reloadAni = false
        return
    end
end

---背包按钮按下效果
function BattleGUI:BagResourceChange(_bool)
    ---self.BagImage:SetActive(_bool)
end

---开火模式判断
function BattleGUI:FireModeCheck()
    self:BtnFireClick()
    self.using = true
end

---单发子弹
function BattleGUI:BtnFireClick()
    if PlayerGunMgr.curGun then
        PlayerGunMgr.curGun:TryFireOneBullet()
    end
end

---长按功能实现
function BattleGUI:BtnFireLongPress()
    if PlayerGunMgr.curGun then
        PlayerGunMgr.curGun:TryKeepFire()
    end
end

---瞄准按钮按下
function BattleGUI.AimBtnClick()
    if localPlayer.Health <= 0 then
        return
    end
    if PlayerGunMgr.curGun then
        if not PlayerGunMgr.curGun.m_isZoomIn then
            PlayerGunMgr.curGun:MechanicalAimStart()
        else
            PlayerGunMgr.curGun:MechanicalAimStop()
        end
    end
end

---瞄准按钮失活
function BattleGUI.AimBtnDisable()
    if PlayerGunMgr.curGun then
        PlayerGunMgr.curGun:MechanicalAimStop()
    end
end

---左边按钮按下事件
function BattleGUI.BtnFireLeftDown()
    local self = BattleGUI
    if PlayerGunMgr.curGun == nil then
        return
    end
    if localPlayer.Health <= 0 then
        return
    end
    self:FireModeCheck()
    self.FireLeftCdImage:SetActive(true)
end

---左边按钮抬起
function BattleGUI.BtnFireLeftUp()
    local self = BattleGUI
    if PlayerGunMgr.curGun == nil then
        return
    end
    self.using = false
    self.FireLeftCdImage:SetActive(false)
    PlayerGunMgr.curGun:TryPump()
end

---右边开火按钮按下
function BattleGUI.BtnFireRightDown()
    local self = BattleGUI
    if PlayerGunMgr.curGun == nil then
        return
    end
    if localPlayer.Health <= 0 then
        return
    end
    self.rightDown = true
    ---表现逻辑
    self.BtnFire:SetValue('Size', Vector2(0.5 * self.finalScreenSize.x, self.finalScreenSize.y))
    self.FigRight:SetActive(false)
    self.FireCdImage:SetActive(true)
    ---武器类型SniperRifle = 1
    if PlayerGunMgr.curGun.gunMode ~= 1 then
        self:FireModeCheck()
    elseif PlayerGunMgr.curGun.m_isZoomIn then
        self:FireModeCheck()
    end
end

---右边开火按钮抬起
function BattleGUI.BtnFireRightUp()
    local self = BattleGUI
    if PlayerGunMgr.curGun == nil then
        return
    end
    self:OnUpCon()
end

---换弹调用
function BattleGUI.BtnReloadClick(_player)
    local self = BattleGUI
    if localPlayer.Health <= 0 then
        return
    end
    if PlayerGunMgr.curGun then
        PlayerGunMgr.curGun:LoadMagazine()
        if
            PlayerGunMgr.curGun.m_isDraw and not PlayerGunMgr.curGun.m_isPumping and
                PlayerGunMgr.curGun.m_magazine.m_canLoad and
                not PlayerGunMgr.curGun.m_onReload
         then
            self.ReloadCdImage.FillAmount = 1
            self.ReloadPrs:SetValue('FillAmount', 0)
            self.ReloadCdImage:SetActive(true)
            self.ReloadPrs:CallFunction('SetActive', true)
            reloadAni = true
        end
    end
end

---设置界面返回的灵敏度
function BattleGUI:SettingAssAimRefreshEventHandler(_assAimData)
    self.defaultSens = (0.07 * _assAimData + 0.1) * GunConfig.GlobalConfig.SensParam
end

---灵敏度控制函数
function BattleGUI:GetSensitivity()
    return self.defaultSens * world.CurrentCamera.FieldOfView / 60
end

---手指触摸右半边
function BattleGUI.RightFingerTouch(_touchInfo)
    local self = BattleGUI
    local rate = self.curRefreshInterval * 60
    for _, v in pairs(_touchInfo) do
        if v.DeltaPosition == Vector2.Zero then
            return
        end
        self.simHor = v.DeltaPosition.x
        self.simVer = v.DeltaPosition.y
        if (not self.swipeStarted) then
            self.swipeStarted = true
            self.simHor = self.simHor / 3
            self.simVer = self.simVer / 3
        end
        local scalar = AccelerateScalar(Vector2(self.simHor, self.simVer).Magnitude, 25, 2)
        self.simHor = scalar * self.simHor
        self.simVer = scalar * self.simVer

        ---统一相机操作
        CameraControl.deltaPhy =
            CameraControl.deltaPhy + 0.7 * rate * self.simHor / self.AimTouchSize.x * self:GetSensitivity()
        CameraControl.deltaTheta =
            CameraControl.deltaTheta + 0.7 * rate * self.simVer / self.AimTouchSize.x * self:GetSensitivity()
    end
end

---模拟摇杆来获取移动方向
function BattleGUI:GetMoveDir()
    self.forwardDir = self.player.Forward
    self.forwardDir.y = 0
    self.rightDir = Vector3(0, 1, 0):Cross(self.forwardDir)
    self.horizontal = self.BattleJoy.Horizontal
    self.vertical = self.BattleJoy.Vertical
    if self.autoRun then
        self.finalDir = self.forwardDir
    elseif self.horizontal ~= 0 or self.vertical ~= 0 then
        self.keyUsing = false
        self.finalDir = self.rightDir * self.horizontal + self.forwardDir * self.vertical
    elseif self.horizontal == 0 or self.vertical == 0 then
        self.keyUsing = true
        self.finalDir = Vector3.Zero
    end
end

---移动实现
---@param _dir Vector3 玩家移动的方向
function BattleGUI:PlayerMove(_dir)
    local dir = _dir
    dir.y = 0
    if self.player.State == Enum.CharacterState.Died then
        dir = Vector3.Zero
    end
    if dir.Magnitude > 0 then
        self.player:MoveTowards(Vector2(dir.x, dir.z).Normalized)
    else
        self.player:MoveTowards(Vector2.Zero)
    end
end

---模拟摇杆Handle
function BattleGUI:SimJoystickMove()
    local handleX = self.BattleJoy.Horizontal / 2 + 0.5
    local handleY = self.BattleJoy.Vertical / 2 + 0.5

    self.SimHandle.AnchorsX = Vector2(handleX, handleX)
    self.SimHandle.AnchorsY = Vector2(handleY, handleY)
end

---Update函数
function BattleGUI:Update(dt)
    if
        self.player.PlayerState.Value == Const.PlayerStateEnum.OnGame or
            self.player.PlayerState.Value == Const.PlayerStateEnum.OnHall_NoMatching
     then
        tt = tt + dt
        if tt > 1 then
            self:CalDistance()
            tt = 0
        end
        if PlayerGunMgr.curGun then
            self:RightFireCheck(dt)
        end
    end
    if reloadAni then
        self:ReloadResourceChange(dt)
    end
end

---60帧渲染
function BattleGUI:FixUpdate(dt)
    self:GetMoveDir()
    self:UpdPlayerMove()
    self:AutoFire()
    self:WhetherReadyToRun(dt)
    self.curRefreshInterval = dt
    if PlayerGunMgr.curGun then
        self:AimStateCheck()
    end
end

function BattleGUI:UpdPlayerMove()
    if not self.keyUsing then
        self:PlayerMove(self.finalDir)
    end

    if PlayerGunMgr.curGun and PlayerGunMgr.curGun.m_isDraw then
        self:AimResourceChange()
    end
end

---连发
function BattleGUI:AutoFire()
    if self.using then
        self:BtnFireLongPress()
    end
end

---击杀动效
---@param _killer PlayerInstance 击杀者
---@param _killed PlayerInstance 被杀的人
---@param _weaponId number 伤害来源的枪械ID
---@param _hitPart number 击杀部位
function BattleGUI:PlayerDieEventHandler(_killer, _killed, _weaponId, _hitPart)
    self:SlidingKillInfo(_killer, _killed, _weaponId, _hitPart)
    if _killer == localPlayer then
        self:KillEffect(_killed, _hitPart)
    end
end

---击杀玩家反馈
function BattleGUI:KillEffect(_killed, _hitPart)
    if _hitPart == 1 then
        self.InfoKill.KillEffect.Texture =
            ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/Icon_Fight_Kill_Death2')
    else
        self.InfoKill.KillEffect.Texture =
            ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/Icon_Fight_Kill_Death')
    end
    self.InfoKill.KillTxt.Text = 'KILL   ' .. splitString(_killed.Name, Config.GlobalConfig.NameLengthShow)
    self.killInfoNum = self.killInfoNum + 1
    self.InfoKill:SetActive(true)
    NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'Weapon_Kill', false, {self.InfoKill.KillEffect})
    invoke(
        function()
            if self.killInfoNum == 1 then
                self.InfoKill:SetActive(false)
                self.killInfoNum = 0
            else
                self.killInfoNum = self.killInfoNum - 1
                return
            end
        end,
        1
    )
end

---击杀信息面板
---最新的击杀信息显示在最下方
local killInfoNum, stillShowUI = 1, nil
function BattleGUI:SlidingKillInfo(_killer, _killed, _weaponId, _hitPart)
    self.SlidingKill:SetActive(true)
    killInfoNum = killInfoNum + 1
    if killInfoNum >= 5 then
        killInfoNum = 1
    end
    stillShowUI = self.SlidingKill:GetChildren()

    local function ShowKillInfo(_type)
        stillShowUI[killInfoNum].AnchorsX = Vector2(0.5, 0.5)
        stillShowUI[killInfoNum].Killer.Text = splitString(_killer.Name, Config.GlobalConfig.NameLengthShow)
        stillShowUI[killInfoNum].Killed.Text = splitString(_killed.Name, Config.GlobalConfig.NameLengthShow)
        if _killer.PlayerType.Value == localPlayer.PlayerType.Value then
            stillShowUI[killInfoNum].Killer.Color = selfColor
            stillShowUI[killInfoNum].Killed.Color = enemyColor
        else
            stillShowUI[killInfoNum].Killer.Color = enemyColor
            stillShowUI[killInfoNum].Killed.Color = selfColor
        end
        stillShowUI[killInfoNum].GunType.Texture =
            ResourceManager.GetTexture(
            'WeaponPackage/UI/BattleGUI/Icon_Fight_Info_' .. GunConfig.GunConfig[_weaponId].Name .. _type
        )

        if _type == '' then
            stillShowUI[killInfoNum].GunType.Color = Color(255, 0, 0, 255)
        else
            stillShowUI[killInfoNum].GunType.Color = Color(255, 255, 255, 255)
        end
    end

    if _hitPart == 1 then
        ShowKillInfo('')
    else
        ShowKillInfo('Normal')
    end

    if #self.curKillTab < 3 then
        stillShowUI[killInfoNum].Offset = Vector2(0, OffPos[#self.curKillTab + 1])
    else
        self:RefreshSlidKill()
        stillShowUI[killInfoNum].Offset = Vector2(0, OffPos[#self.curKillTab + 1])
    end

    table.insert(self.curKillTab, stillShowUI[killInfoNum])
end

---刷新击杀信息面板,向上滚动
function BattleGUI:RefreshSlidKill()
    if self.curKillTab[1] ~= nil then
        for k, v in pairs(self.curKillTab) do
            v.Offset = Vector2(0, 0)
            if k == 1 then
                v.AnchorsX = Vector2(-0.5, -0.5)
            else
                v.Offset = Vector2(0, OffPos[k - 1])
            end
        end
        table.remove(self.curKillTab, 1)
    end
end

---在协程里的更新函数
function BattleGUI:ManualUpd()
    while true do
        if #self.curKillTab > 0 then
            wait(3)
            self:RefreshSlidKill()
        end
        wait(0.05)
    end
    coroutine.yield()
end

---玩家受击打范围提示
---玩家被打中的事件  伤害的发起者  伤害来源的枪械  伤害的数值
function BattleGUI:PlayerBeHitEventHandler(_msg)
    if PlayerOccLogic.invincible then
        return
    end
    for _, v in pairs(_msg) do
        local TempVec1 = localPlayer.Forward
        local TempVec2 = v[1].Position - localPlayer.Position
        TempVec1.y = 0
        TempVec2.y = 0
        local BeHitAngle = Vector3.Angle(TempVec1, TempVec2)
        local BeHitLeft = Vector3.Cross(TempVec1, TempVec2).y < 0

        ---受击打动作
        ---self:BeHitAnimation(v[3], BeHitAngle)

        if BeHitAngle >= 0 and BeHitAngle <= 22.5 then
            self:ShowBeHitAngle(0)
        elseif BeHitAngle >= 157.5 and BeHitAngle <= 180 then
            self:ShowBeHitAngle(180)
        elseif BeHitAngle > 22.5 and BeHitAngle <= 67.5 then
            if BeHitLeft then
                self:ShowBeHitAngle(45)
            else
                self:ShowBeHitAngle(-45)
            end
        elseif BeHitAngle > 67.5 and BeHitAngle <= 112.5 then
            if BeHitLeft then
                self:ShowBeHitAngle(90)
            else
                self:ShowBeHitAngle(270)
            end
        elseif BeHitAngle > 112.5 and BeHitAngle < 157.5 then
            if BeHitLeft then
                self:ShowBeHitAngle(135)
            else
                self:ShowBeHitAngle(-135)
            end
        end
    end
end

---受到击打后的动作
---@param _damageNum number 伤害的数值
---@param _beHitAngle Vector3 伤害发起者和接受者的角度
function BattleGUI:BeHitAnimation(_damageNum, _beHitAngle)
    local DamThreshold = _damageNum
    ---可以根据伤害数值来确定播动作的频率
    ---目前过于鬼畜
    if _beHitAngle <= 90 then
        localPlayer.Avatar:PlayAnimation('HitForward', 2, 1, 0, true, false, 3)
    else
        localPlayer.Avatar:PlayAnimation('HitBehind', 2, 1, 0, true, false, 3)
    end
end

---展示被击打的方向
---@param _angle number
function BattleGUI:ShowBeHitAngle(_angle)
    local curAngle = _angle
    local Tweener

    self.HitRange.Angle = curAngle
    self.HitRange:SetActive(true)
    self.HitRange.Color = Color(255, 255, 255, 255)

    if Tweener then
        Tweener:Complete()
    end
    Tweener = Tween:TweenProperty(self.HitRange, {Color = Color(255, 0, 0, 0)}, 2, 1)
    Tweener:Play()
    Tweener.OnComplete:Connect(
        function()
            self.HitRange:SetActive(false)
        end
    )
end

function BattleGUI:WhetherReadyToRun(dt)
    if self.vertical >= 0.98 and PlayerBehavior.state == 1 and not self.autoRun then
        ---self.ImgRunHes:SetActive(true)
    else
        ---self.ImgRunHes:SetActive(false)
    end
    ---进入冲刺状态
    if PlayerBehavior.state == 2 or PlayerBehavior.state == 5 then
        self.autoRun = true
        self.BattleJoy:SetActive(false)
        self.SimHandleSure:SetActive(true)
        self.SimHandle.AnchorsX = Vector2(0.5, 0.5)
        self.SimHandle.AnchorsY = Vector2(1, 1)
    else
        self.autoRun = false
        self.BattleJoy:SetActive(true)
        self:SimJoystickMove()
        self.SimHandleSure:SetActive(false)
    end
end

function BattleGUI:ReadyToRun()
    if localPlayer.Health <= 0 then
        return
    end
    self.ImgRunHes.Texture = ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/Icon_Fight_Player_Run2')
    PlayerBehavior:PlayerBehaviorChanged('isQuickly')
end

function BattleGUI:AimStateCheck()
    self.IsAimOrNot.Value = PlayerGunMgr.curGun.m_isZoomIn
end

function BattleGUI:SetActive(_active)
    self.root:SetActive(_active)
end

function BattleGUI:GetActive()
    return self.root.ActiveSelf
end

function BattleGUI:CalDistance()
    players = FindAllPlayers()
    for _, v in pairs(players) do
        if v ~= nil and v ~= self.player and v.PlayerType.Value ~= self.player.PlayerType.Value then
            dis = (v.Position - self.player.Position).Magnitude
            self:CheckFootStep(dis, v)
        end
    end
end

---@param _noisy PlayerInstance
function BattleGUI:CheckFootStep(_dis, _noisy)
    for k, v in pairs(PlayerActionModeEnum) do
        if v == _noisy.ActionState.Value then
            realDis = (GunConfig.GlobalConfig[tostring(k) .. 'Speed'] / GunConfig.GlobalConfig.RunSpeed) * _dis
            if realDis <= GunConfig.GlobalConfig.HearingRange and _noisy.LinearVelocity.Magnitude > 3 then
                self:CtnCheck(_noisy)
            end
        end
    end
end

---计算角度并映射到屏幕
function BattleGUI:CtnCheck(_otherObj)
    local TempVec1 = localPlayer.Forward
    local TempVec2 = _otherObj.Position - localPlayer.Position
    TempVec1.y = 0
    TempVec2.y = 0
    local BeHitAngle = Vector3.Angle(TempVec1, TempVec2)
    local BeHitLeft = Vector3.Cross(TempVec1, TempVec2).y < 0

    if BeHitAngle >= 0 and BeHitAngle <= 22.5 then
        self:ShowAngle(0, self.SimFootsteps)
    elseif BeHitAngle >= 157.5 and BeHitAngle <= 180 then
        self:ShowAngle(180, self.SimFootsteps)
    elseif BeHitAngle > 22.5 and BeHitAngle <= 67.5 then
        if BeHitLeft then
            self:ShowAngle(45, self.SimFootsteps)
        else
            self:ShowAngle(-45, self.SimFootsteps)
        end
    elseif BeHitAngle > 67.5 and BeHitAngle <= 112.5 then
        if BeHitLeft then
            self:ShowAngle(90, self.SimFootsteps)
        else
            self:ShowAngle(270, self.SimFootsteps)
        end
    elseif BeHitAngle > 112.5 and BeHitAngle < 157.5 then
        if BeHitLeft then
            self:ShowAngle(135, self.SimFootsteps)
        else
            self:ShowAngle(-135, self.SimFootsteps)
        end
    end
end

---展示方向
---@param _angle number
---@param _node UiFigureObject
function BattleGUI:ShowAngle(_angle, _node)
    local curAngle = _angle
    local Tweener

    _node.Angle = curAngle
    _node:SetActive(true)
    _node.Color = Color(255, 255, 255, 255)

    if Tweener then
        Tweener:Complete()
    end
    Tweener = Tween:TweenProperty(_node, {Color = Color(255, 255, 255, 0)}, 2, 1)
    Tweener:Play()
    Tweener.OnComplete:Connect(
        function()
            _node:SetActive(false)
        end
    )
end

return BattleGUI
