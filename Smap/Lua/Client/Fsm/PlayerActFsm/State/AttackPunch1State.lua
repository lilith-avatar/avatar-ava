--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

---出拳交互动画
local AttackPunch1State = class('AttackPunch1State', PlayerActState)

function AttackPunch1State:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('AttackPunch1', 1, _stateName .. 1)
end

function AttackPunch1State:InitData()
    --self:AddTransition('ToIdleState', self.controller.states['IdleState'], 0.5)
    self:AddTransition('ToAttackPunch2State', self.controller.states['AttackPunch2State'], 2.4)
    self:AddTransition(
        'ToPunchEndState',
        self.controller.states['PunchEndState'],
        -1,
        function()
            return self.controller.triggers['PunchEndState']
        end
    )
end

function AttackPunch1State:OnEnter()
    PlayerActState.OnEnter(self)
    --localPlayer.FollowTarget = nil
    PlayerAnimMgr:Play(self.stateName .. 1, 0, 1, 0.3, 0.3, true, true, 1)
end

function AttackPunch1State:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function AttackPunch1State:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer.Avatar:StopBlendSpaceNode(0)
end

return AttackPunch1State
