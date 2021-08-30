--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local SwimmingState = class('SwimmingState', PlayerActState)

local isSufaceWater = true

function SwimmingState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)

    PlayerAnimMgr:CreateSingleClipNode('anim_human_swim_freestyle_01', 1, _stateName .. 'Freestyle')
    PlayerAnimMgr:CreateSingleClipNode('anim_human_swim_breaststroke_01', 1, _stateName .. 'Breaststroke')
end

function SwimmingState:InitData()
    self:AddTransition(
        'ToSwimmingEndState',
        self.controller.states['SwimmingEndState'],
        -1,
        function()
            return not self:MoveMonitor()
        end
    )
    self:AddTransition(
        'ToSwimEndState',
        self.controller.states['SwimEndState'],
        -1,
        function()
            return not self:SwimMonitor()
        end
    )
end

function SwimmingState:OnEnter()
    PlayerActState.OnEnter(self)
    isSufaceWater = self:IsWaterSuface(0.5)
    if isSufaceWater then
        PlayerAnimMgr:Play(self.stateName .. 'Freestyle', 0, 1, 0.2, 0.2, true, true, 1)
    else
        PlayerAnimMgr:Play(self.stateName .. 'Breaststroke', 0, 1, 0.2, 0.2, true, true, 1)
    end
end

function SwimmingState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:Swim()
    if isSufaceWater ~= self:IsWaterSuface(0.5) then
        self:OnEnter()
    end
end

function SwimmingState:OnLeave()
    PlayerActState.OnLeave(self)
end

return SwimmingState
