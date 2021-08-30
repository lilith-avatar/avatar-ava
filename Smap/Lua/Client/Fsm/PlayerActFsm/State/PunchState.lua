--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

---拳击交互动画
local PunchState = class('PunchState', PlayerActState)

function PunchState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('PunchIdle', 1, _stateName)
end
function PunchState:InitData()
    self:AddTransition('ToAttackPunch1State', self.controller.states['AttackPunch1State'], 0.05)

    self:AddTransition(
        'ToAttackPunch2State',
        self.controller.states['AttackPunch2State'],
        -1,
        function()
            return self.controller.triggers['AttackPunch2State']
        end
    )

    self:AddTransition(
        'ToPunchEndState',
        self.controller.states['PunchEndState'],
        -1,
        function()
            return self.controller.triggers['PunchEndState']
        end
    )
end

function PunchState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
end

function PunchState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    --self:SpeedMonitor()
    --self:Move(true)
    --self:FallMonitor()
end

function PunchState:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer.Avatar:StopBlendSpaceNode(0)
end

return PunchState
