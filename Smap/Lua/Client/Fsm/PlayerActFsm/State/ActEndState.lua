--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local ActEndState = class('ActEndState', PlayerActState)

function ActEndState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
end

function ActEndState:InitData()
end

function ActEndState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:CreateSingleClipNode(self.controller.actInfo.anim[3], 1, self.stateName)
    PlayerAnimMgr:Play(self.stateName, self.controller.actInfo.layer, 1, 0.2, 0.2, true, false, 1)
    self:AddTransition('ToIdleState', self.controller.states['IdleState'], self.controller.actInfo.dur[3])
end

function ActEndState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function ActEndState:OnLeave()
    PlayerActState.OnLeave(self)
    self.transitions = {}
    C.Mgr.EmoActionMgr:ActCallBack()
end

return ActEndState
