--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local MoveState = class('MoveState', PlayerActState)

function MoveState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)

    local animsM = {
        {'anim_man_idle_01', 0.0, 1.0},
        {'anim_man_walkfront_01', 0.25, 1.0},
        {'anim_man_runfront_01', 0.5, 1.0},
        {'anim_man_sprint_01', 1, 1.0}
    }

    local animsW = {
        {'anim_woman_idle_01', 0.0, 1.0},
        {'anim_woman_walkfront_01', 0.25, 1.0},
        {'anim_woman_runfront_01', 0.5, 1.0},
        {'anim_woman_sprint_01', 1, 1.0}
    }
    PlayerAnimMgr:Create1DClipNode(animsM, 'speedXZ', _stateName, 1)
    PlayerAnimMgr:Create1DClipNode(animsW, 'speedXZ', _stateName, 2)
end
function MoveState:InitData()
    self:AddTransition(
        'ToMoveStopState',
        self.controller.states['MoveStopState'],
        -1,
        function()
            return not self:MoveMonitor()
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
        'ToJumpHighestState',
        self.controller.states['JumpHighestState'],
        -1,
        function()
            return self.controller.triggers['JumpHighestState']
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

function MoveState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
end

function MoveState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:SpeedMonitor()
    self:Move(true)
    self:FallMonitor()
end
function MoveState:OnLeave()
    PlayerActState.OnLeave(self)
    self.controller:GetStopInfo()
end

return MoveState
