--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local DanceState = class('DanceState', PlayerActState)

function DanceState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('Exhibition06', 1, _stateName)
end
function DanceState:InitData()
    self:AddAnyState(
        'ToDanceState',
        -1,
        function()
            return self.controller.triggers['DanceState']
        end
    )

    self:AddTransition(
        'ToIdleState',
        self.controller.states['IdleState'],
        -1,
        function()
            return self.controller.triggers['IdleState']
        end
    )
end

function DanceState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
end

function DanceState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function DanceState:OnLeave()
    PlayerActState.OnLeave(self)
end

return DanceState
