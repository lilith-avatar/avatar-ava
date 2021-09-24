--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local SitEndState = class('SitEndState', PlayerActState)

function SitEndState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_human_sit_end', 1, _stateName)
end
function SitEndState:InitData()
    self:AddTransition('ToIdleState', self.controller.states['IdleState'], 1)
end

function SitEndState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.FollowTarget = nil
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 1)
end

function SitEndState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function SitEndState:OnLeave()
    PlayerActState.OnLeave(self)
end

return SitEndState
