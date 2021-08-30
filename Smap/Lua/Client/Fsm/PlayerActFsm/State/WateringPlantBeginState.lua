--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local WateringPlantBeginState = class('WateringPlantBeginState', PlayerActState)

function WateringPlantBeginState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('HTWateringStart', 1, _stateName)
end
function WateringPlantBeginState:InitData()
    self:AddAnyState(
        'ToWateringPlantBeginState',
        -1,
        function()
            return self.controller.triggers['WateringPlantBeginState']
        end
    )
    self:AddTransition('ToWateringPlantState', self.controller.states['WateringPlantState'], 1)
end

function WateringPlantBeginState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 0.5)
end

function WateringPlantBeginState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function WateringPlantBeginState:OnLeave()
    PlayerActState.OnLeave(self)
end

return WateringPlantBeginState
