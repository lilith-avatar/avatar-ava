--- @module PlayerBehavior 枪械模块：玩家行为树
--- @copyright Lilith Games, Avatar Team
--- @author RopzTao
local PlayerBehavior, this =
    {
        playerActionStateFunc = {} ---状态触发表
    },
    nil

local firParam = nil

local function OnKeyDown()
    ---按C下蹲
    if Input.GetPressKeyData(Enum.KeyCode.C) ~= Enum.KeyState.KeyStateNone then
        PlayerBehavior:PlayerCrouch()
    end
    ---按Shift进入快跑
    if Input.GetPressKeyData(Enum.KeyCode.LeftShift) ~= Enum.KeyState.KeyStateNone then
        ---速度变化
        PlayerBehavior:PlayerBehaviorChanged('isQuickly')
        ---准星消失
        if PlayerGunMgr.gun then
        ---PlayerBehavior.gun.m_gui.crosshair:SetActive(false)
        end
    end
    ---按下空格键跳
    if Input.GetPressKeyData(Enum.KeyCode.Space) ~= Enum.KeyState.KeyStateNone then
        PlayerBehavior:PlayerJump()
    end
end

local function OnKeyUp()
    ---抬起Shift结束快跑
    if Input.GetPressKeyData(Enum.KeyCode.LeftShift) == Enum.KeyState.KeyStateRelease then
        PlayerBehavior:PlayerBehaviorChanged('isQuickly')
    end
end

---初始化函数
function PlayerBehavior:Init()
    this = self
    self:InitListener()

    ---@type PlayerInstance 当前的玩家对象
    self.player = localPlayer
    self.state = PlayerActionModeEnum.Run
    ---不同职业的配速
    self.SpeedStdCoeft = self.player.SpeedScale.Value
    ---人物移动状态系数
    self.coefInertia = 1
    ---人物加速度系数
    self.InerPara = GunConfig.GlobalConfig.InertialParam
    self.GunWeight = 1

    self:InitialDataRead()
    self:InitPlayerAttributes()
    self:PlayerBehaviorChanged('isRun')

    Input.OnKeyDown:Connect(OnKeyDown)
    Input.OnKeyUp:Connect(OnKeyUp)
    self.player.OnDead:Connect(
        function()
            self.state = PlayerActionModeEnum.Run
            self.BehJudgeTab.isAim = false
        end
    )
end

---监听函数
function PlayerBehavior:InitListener()
    LinkConnects(localPlayer.C_Event, PlayerBehavior, this)
end

---初始数据
function PlayerBehavior:InitialDataRead()
    ---玩家行为判断参数
    self.BehJudgeTab = {
        isRun = false,
        isCrouch = false,
        isQuickly = false,
        isAim = false
    }
    self.keyDownTab = {}
end

---玩家职业不同速度标准系数不同
---@param _occ 职业种类
function PlayerBehavior:ChangeOccEventHandler(_occ)
    ---更新参数
    self.SpeedStdCoeft = localPlayer.SpeedScale.Value
end

---初始玩家设定
function PlayerBehavior:InitPlayerAttributes()
    self.player.JumpUpVelocity = GunConfig.GlobalConfig.JumpSpeed
end

---装备枪更新跳跃速度
function PlayerBehavior:OnEquipWeaponEventHandler()
    if PlayerGunMgr.curGun == nil then
        return
    end
    self.player.JumpUpVelocity = GunConfig.GlobalConfig.JumpSpeed * self.SpeedStdCoeft * self.GunWeight
end

---玩家行为判断
function PlayerBehavior:PlayerBehaviorChanged(_behavior)
    if self.BehJudgeTab[_behavior] then
        self.BehJudgeTab[_behavior] = false
    else
        self.BehJudgeTab[_behavior] = true
    end

    for k, v in pairs(self.BehJudgeTab) do
        if v then
            table.insert(self.keyDownTab, k)
        end
    end

    if #self.keyDownTab == 1 then
        firParam = string.gsub(tostring(self.keyDownTab[1]), 'is', '')
        self:PlayerModeChanged(firParam)
    elseif #self.keyDownTab == 2 then
        for i, j in pairs(self.keyDownTab) do
            firParam = string.gsub(tostring(j), 'is', '')
            if firParam ~= 'Run' then
                self:PlayerModeChanged(firParam .. 'Run')
            end
        end
    elseif #self.keyDownTab == 3 then
        for m, n in pairs(self.keyDownTab) do
            firParam = string.gsub(tostring(n), 'is', '')
            if firParam ~= 'Run' and firParam ~= 'Crouch' then
                self:PlayerModeChanged(firParam .. 'CrouchRun')
            end
        end
    end

    self.keyDownTab = {}
end

---玩家状态判断
---@param _modeName String
function PlayerBehavior:PlayerModeChanged(_modeName)
    self.playerActionStateFunc[PlayerActionModeEnum[_modeName]] = function()
        self.state = PlayerActionModeEnum[_modeName]
    end
    self.playerActionStateFunc[PlayerActionModeEnum[_modeName]]()
end

---@param direParam Float 摇杆方向对应不同速度的参数
local direRes, direParam, tt = 0, 1, 0
local directionFactor = Vector2.Zero
---前后左右移动速度不一致
function PlayerBehavior:DiffDireMovement(dt)
    ---如果摇杆的位移坐标前一帧为directionFactor,后一帧为原点
    if
        Vector2(BattleGUI.horizontal, BattleGUI.vertical) == directionFactor and
            Vector2(BattleGUI.horizontal, BattleGUI.vertical) == Vector2.Zero
     then
        tt = 0
        self.coefInertia = 1
    else
        tt = tt + dt
        self.coefInertia = Asymptote(self.InerPara * tt)
    end

    directionFactor = Vector2(BattleGUI.horizontal, BattleGUI.vertical)
    if directionFactor ~= Vector2.Zero then
        direRes = Vector2.Dot(directionFactor, Vector2(0, 1)) / directionFactor.Magnitude
        if direRes >= 0.5 then
            direParam = 1.35 * directionFactor.Magnitude
        elseif direRes <= -0.5 then
            direParam = (1 / 1.2) * directionFactor.Magnitude
        else
            direParam = (1 / 1.05) * directionFactor.Magnitude
        end
    end
end

---Update函数
function PlayerBehavior:Update(dt)
    localPlayer.ActionState.Value = self.state
    self:DiffDireMovement(dt)
    self:CharacterStartInertia()
    ---更新速度
    for k, v in pairs(PlayerActionModeEnum) do
        if v == self.state then
            self.player.WalkSpeed =
                GunConfig.GlobalConfig[tostring(k) .. 'Speed'] * self.SpeedStdCoeft * self.coefInertia * direParam *
                self.GunWeight
        end
    end
end

---人物启动加速惯性函数
---匹配到对应的枪械的重量
function PlayerBehavior:CharacterStartInertia()
    ---不同枪械的质量系数
    if PlayerGunMgr.curGun then
        self.GunWeight = 1 / PlayerGunMgr.curGun.config_weight
    end
end

---玩家跳跃
function PlayerBehavior:PlayerJump()
    if (self.player.IsOnGround or self.player.State == Enum.CharacterState.Seated) and not isDead then
        if self.player:IsCrouch() then
            self.player:EndCrouch()
            self:PlayerBehaviorChanged('isCrouch')
            CameraControl:Crouch()
            return
        else
            if (PlayerGunMgr.curGun and PlayerGunMgr.curGun.m_isZoomIn) then
                PlayerGunMgr.curGun:MechanicalAimStop()
            end
            self.player:Jump()
            return
        end
    end
end

---玩家蹲下
function PlayerBehavior:PlayerCrouch()
    self:PlayerBehaviorChanged('isCrouch')

    if not self.player:IsCrouch() then
        self.player:StartCrouch()
    else
        self.player:EndCrouch()
    end

    CameraControl:Crouch()
end

---玩家蹲下重置
function PlayerBehavior:CrouchReset()
    if self.player:IsCrouch() then
        BattleGUI:PlayerCrouchClick()
    end
end

---状态初始化或重置
function PlayerBehavior:InitsetOrReset()
    ---表现重置
    self:CrouchReset()
    BattleGUI:GunInterReset()

    ---数据重置
    self:InitialDataRead()
    self:InitPlayerAttributes()
    self:PlayerBehaviorChanged('isRun')
    self.player.Health = 100
end

return PlayerBehavior
