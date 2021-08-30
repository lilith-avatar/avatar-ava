--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local LieEndState = class('LieEndState', PlayerActState)

function LieEndState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_human_pd_lieup_01', 1, _stateName .. 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_human_pd_liestand_01', 1, _stateName .. 2)
end
function LieEndState:InitData()
    self:AddTransition('ToIdleState', self.controller.states['IdleState'], 1)
end

function LieEndState:OnEnter()
    PlayerActState.OnEnter(self)
    --localPlayer.FollowTarget = nil
    PlayerAnimMgr:Play(self.stateName .. 1, 0, 1, 0.2, 0.2, true, false, 1)

    local CallBack1 = localPlayer.Avatar:AddAnimationEvent('anim_human_pd_lieup_01', 0.99)
    CallBack1:Connect(
        function()
            PlayerAnimMgr:Play(self.stateName .. 2, 0, 1, 0.2, 0.2, true, false, 1)
        end
    )
end

function LieEndState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function LieEndState:OnLeave()
    PlayerActState.OnLeave(self)
end

return LieEndState
