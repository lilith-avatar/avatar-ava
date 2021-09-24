--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

---拳击交互动画
local PunchEndState = class('PunchEndState', PlayerActState)

function PunchEndState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('PunchUnEquip', 1, _stateName .. 1)
end

function PunchEndState:InitData()
    self:AddTransition('ToIdleState', self.controller.states['IdleState'], 0.5)
end

function PunchEndState:OnEnter()
    PlayerActState.OnEnter(self)
    --localPlayer.FollowTarget = nil
    PlayerAnimMgr:Play(self.stateName .. 1, 0, 1, 0.2, 0.2, true, false, 1)
end

function PunchEndState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function PunchEndState:OnLeave()
    PlayerActState.OnLeave(self)
end

return PunchEndState
