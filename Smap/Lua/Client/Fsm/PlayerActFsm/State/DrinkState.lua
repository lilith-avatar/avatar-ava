--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local DrinkState = class('DrinkState', PlayerActState)

function DrinkState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('HTDrinkwater', 1, _stateName)
end
function DrinkState:InitData()
    self:AddTransition(
        'ToIdleState',
        self.controller.states['IdleState'],
        -1,
        function()
            return self.controller.triggers['IdleState']
        end
    )
end

function DrinkState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 1)
end

function DrinkState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function DrinkState:OnLeave()
    PlayerActState.OnLeave(self)
end

return DrinkState
