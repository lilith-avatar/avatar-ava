--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local SitState = class('SitState', PlayerActState)

function SitState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_human_sit_loop', 1, _stateName)
end
function SitState:InitData()
    self:AddTransition(
        'ToSitEndState',
        self.controller.states['SitEndState'],
        -1,
        function()
            return self.controller.triggers['SitEndState']
        end
    )
end

function SitState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
end

function SitState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function SitState:OnLeave()
    PlayerActState.OnLeave(self)
end

return SitState
