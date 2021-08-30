--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local MoveStopState = class('MoveStopState', PlayerActState)

function MoveStopState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)

    self.animsM = {
        {'LW', 'anim_man_stop_l_05', 0.2, 1.0},
        {'LR1', 'anim_man_stop_l_03', 0.2, 1.0},
        {'LR2', 'anim_man_stop_l_07', 0.2, 1.0},
        {'LS', 'anim_man_stop_l_06', 0.2, 1.0},
        {'RW', 'anim_man_stop_r_05', 0.2, 1.0},
        {'RR1', 'anim_man_stop_r_03', 0.2, 1.0},
        {'RR2', 'anim_man_stop_r_07', 0.2, 1.0},
        {'RS', 'anim_man_stop_r_06', 0.2, 1.0}
    }
    self.animsW = {
        {'LW', 'anim_woman_stop_l_05', 0.2, 1.0},
        {'LR1', 'anim_woman_stop_l_03', 0.2, 1.0},
        {'LR2', 'anim_woman_stop_l_07', 0.2, 1.0},
        {'LS', 'anim_woman_stop_l_06', 0.2, 1.0},
        {'RW', 'anim_woman_stop_r_05', 0.2, 1.0},
        {'RR1', 'anim_woman_stop_r_03', 0.2, 1.0},
        {'RR2', 'anim_woman_stop_r_07', 0.2, 1.0},
        {'RS', 'anim_woman_stop_r_06', 0.2, 1.0}
    }
    for i, v in pairs(self.animsM) do
        PlayerAnimMgr:CreateSingleClipNode(v[2], v[4], _stateName .. i, 1)
    end
    for i, v in pairs(self.animsW) do
        PlayerAnimMgr:CreateSingleClipNode(v[2], v[4], _stateName .. i, 2)
    end
end
function MoveStopState:InitData()
    self:AddTransition('ToIdleState', self.controller.states['IdleState'], 0.5)
    self:AddTransition(
        'ToMoveState',
        self.controller.states['MoveState'],
        -1,
        function()
            return self:MoveMonitor()
        end
    )
    self:AddTransition(
        'ToJumpBeginState',
        self.controller.states['JumpBeginState'],
        -1,
        function()
            return self.controller.triggers['JumpBeginState']
        end
    )
    self:AddTransition(
        'ToCrouchBeginState',
        self.controller.states['CrouchBeginState'],
        -1,
        function()
            return self.controller.isCrouch
        end
    )
    self:AddTransition(
        'ToFlyBeginState',
        self.controller.states['FlyBeginState'],
        -1,
        function()
            return self.controller.triggers['FlyBeginState']
        end
    )
end

--确定该播放哪个停步动作
function MoveStopState:GetStopIndex()
    local stopSSpeed = 0.9
    local stopRSpeed = 0.4
    local stopDisGap = 0.7
    local index = 1
    if math.clamp(self.controller.stopInfo.speed / localPlayer.MaxWalkSpeed, 0, 1) > stopSSpeed then
        index = 4
    elseif math.clamp(self.controller.stopInfo.speed / localPlayer.MaxWalkSpeed, 0, 1) > stopRSpeed then
        if self.controller.stopInfo.footDis > stopDisGap then
            index = 2
        else
            index = 3
        end
    end
    if self.controller.stopInfo.footIndex == 1 then
        index = index + 4
    end
    return index
end

function MoveStopState:OnEnter()
    PlayerActState.OnEnter(self)
    local index = self:GetStopIndex()
    PlayerAnimMgr:Play(self.stateName .. index, 0, 1, 0.2, 0.2, true, false, 1)
end

function MoveStopState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end
function MoveStopState:OnLeave()
    PlayerActState.OnLeave(self)
end

return MoveStopState
