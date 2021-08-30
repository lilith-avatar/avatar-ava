--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local ThrowEndState = class('ThrowEndState', PlayerActState)

function ThrowEndState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('ThrowHighAttack', 1, _stateName .. 1)
end
function ThrowEndState:InitData()
    self:AddTransition('ToIdleState', self.controller.states['IdleState'], 0.5)
end

function ThrowEndState:OnEnter()
    PlayerActState.OnEnter(self)
    --localPlayer.FollowTarget = nil
    PlayerAnimMgr:Play(self.stateName .. 1, 0, 1, 0.2, 0.2, true, false, 1)
end

function ThrowEndState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function ThrowEndState:OnLeave()
    PlayerActState.OnLeave(self)
    EmoActionMgr:HideDanceBtn(true)
    C_TakePhoto:OpenCamBtnCtrl(true)
end

return ThrowEndState
