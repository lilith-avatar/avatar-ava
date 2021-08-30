--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

---杠铃交互动画
local PickUpHeavyEndState = class('PickUpHeavyEndState', PlayerActState)

function PickUpHeavyEndState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('Drop', 1, _stateName .. 1)
end

function PickUpHeavyEndState:InitData()
    self:AddTransition('ToIdleState', self.controller.states['IdleState'], 0.5)
end

function PickUpHeavyEndState:OnEnter()
    PlayerActState.OnEnter(self)
    --localPlayer.FollowTarget = nil
    PlayerAnimMgr:Play(self.stateName .. 1, 0, 1, 0.2, 0.2, true, false, 1)
end

function PickUpHeavyEndState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function PickUpHeavyEndState:OnLeave()
    PlayerActState.OnLeave(self)
end

return PickUpHeavyEndState
