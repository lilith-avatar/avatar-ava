--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local WateringPlantState = class('WateringPlantState', PlayerActState)

function WateringPlantState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('HTWateringLoop', 1, _stateName)
end
function WateringPlantState:InitData()
    self:AddTransition('ToWateringPlantEndState', self.controller.states['WateringPlantEndState'], 1)
end

function WateringPlantState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 1)
end

function WateringPlantState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function WateringPlantState:OnLeave()
    PlayerActState.OnLeave(self)
end

return WateringPlantState
