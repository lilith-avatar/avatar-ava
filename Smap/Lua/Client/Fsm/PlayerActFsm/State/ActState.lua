--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local ActState = class('ActState', PlayerActState)

function ActState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_human_sit_loop', 1, _stateName)
end
function ActState:InitData()
end

function ActState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:CreateSingleClipNode(self.controller.actInfo.anim[2], self.controller.actInfo.speed, self.stateName)
    PlayerAnimMgr:Play(
        self.stateName,
        self.controller.actInfo.layer,
        1,
        self.controller.actInfo.transIn,
        self.controller.actInfo.transOut,
        self.controller.actInfo.isInterrupt,
        self.controller.actInfo.isLoop,
        self.controller.actInfo.speedScale
    )
    self:AddTransition(
        'ToActEndState',
        self.controller.states['ActEndState'],
        self.controller.actInfo.dur[2],
        function()
            return self:MoveMonitor() or self.controller.triggers['JumpBeginState']
        end
    )
end

function ActState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function ActState:OnLeave()
    PlayerActState.OnLeave(self)
    self.transitions = {}
end

return ActState
