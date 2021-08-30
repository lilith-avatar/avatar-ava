--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local SwimmingEndState = class('SwimmingEndState', PlayerActState)

function SwimmingEndState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)

    PlayerAnimMgr:CreateSingleClipNode('anim_human_freestyletoidle_01', 1, _stateName .. 'Freestyle')
    PlayerAnimMgr:CreateSingleClipNode('anim_human_breaststroketoidle_01', 1, _stateName .. 'Breaststroke')
end

function SwimmingEndState:InitData()
    self:AddTransition('ToSwimIdleState', self.controller.states['SwimIdleState'], 0.5)
    self:AddTransition(
        'ToSwimEndState',
        self.controller.states['SwimEndState'],
        -1,
        function()
            return not self:SwimMonitor()
        end
    )
end

function SwimmingEndState:OnEnter()
    PlayerActState.OnEnter(self)
    if self:IsWaterSuface() then
        PlayerAnimMgr:Play(self.stateName .. 'Freestyle', 0, 1, 0.1, 0.1, true, false, 1)
    else
        PlayerAnimMgr:Play(self.stateName .. 'Breaststroke', 0, 1, 0.1, 0.1, true, false, 1)
    end
end

function SwimmingEndState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:Swim()
end

function SwimmingEndState:OnLeave()
    PlayerActState.OnLeave(self)
end

return SwimmingEndState
