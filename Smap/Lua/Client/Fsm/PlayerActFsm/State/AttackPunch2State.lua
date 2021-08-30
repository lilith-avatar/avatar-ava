--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

---出拳交互动画
local AttackPunch2State = class('AttackPunch2State', PlayerActState)

function AttackPunch2State:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('AttackPunch2', 1, _stateName .. 1)
end

function AttackPunch2State:InitData()
    --self:AddTransition('ToIdleState', self.controller.states['IdleState'], 0.5)
    self:AddTransition('ToAttackPunch1State', self.controller.states['AttackPunch1State'], 2.2)
    self:AddTransition(
        'ToPunchEndState',
        self.controller.states['PunchEndState'],
        -1,
        function()
            return self.controller.triggers['PunchEndState']
        end
    )
end

function AttackPunch2State:OnEnter()
    PlayerActState.OnEnter(self)
    --localPlayer.FollowTarget = nil
    PlayerAnimMgr:Play(self.stateName .. 1, 0, 1, 0.3, 0.3, true, true, 1)
end

function AttackPunch2State:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function AttackPunch2State:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer.Avatar:StopBlendSpaceNode(0)
end

return AttackPunch2State
