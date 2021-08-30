--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local WateringPlantEndState = class('WateringPlantEndState', PlayerActState)

function WateringPlantEndState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('HTWateringEnd', 1, _stateName)
end
function WateringPlantEndState:InitData()
    self:AddTransition('ToIdleState', self.controller.states['IdleState'], 1)
end

function WateringPlantEndState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 1)
end

function WateringPlantEndState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function WateringPlantEndState:OnLeave()
    PlayerActState.OnLeave(self)
end

return WateringPlantEndState
