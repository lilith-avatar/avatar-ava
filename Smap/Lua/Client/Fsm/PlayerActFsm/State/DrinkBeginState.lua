--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local DrinkBeginState = class('DrinkBeginState', PlayerActState)

function DrinkBeginState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('HTPickUp', 1, _stateName)
end
function DrinkBeginState:InitData()
    self:AddAnyState(
        'ToDrinkBeginState',
        -1,
        function()
            return self.controller.triggers['DrinkBeginState']
        end
    )

    self:AddTransition('ToDrinkState', self.controller.states['DrinkState'], 1)
end

function DrinkBeginState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
end

function DrinkBeginState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function DrinkBeginState:OnLeave()
    PlayerActState.OnLeave(self)
end

return DrinkBeginState
