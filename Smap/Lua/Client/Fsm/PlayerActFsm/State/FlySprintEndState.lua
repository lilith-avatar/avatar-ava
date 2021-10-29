--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local FlySprintEndState = class('FlySprintEndState', PlayerActState)

function FlySprintEndState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_flytohover_01', 1, _stateName, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_flytohover_01', 1, _stateName, 2)
end
function FlySprintEndState:InitData()
    self:AddTransition('FlyMoveState', self.controller.states['FlyMoveState'], 0.5)
    self:AddTransition(
        'ToFlySprintEndState',
        self.controller.states['FlySprintEndState'],
        -1,
        function()
            return self:FloorMonitor(0.06)
        end
    )
end

function FlySprintEndState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 1)
end

function FlySprintEndState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function FlySprintEndState:OnLeave()
    PlayerActState.OnLeave(self)
end

return FlySprintEndState
