--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local CrouchBeginState = class('CrouchBeginState', PlayerActState)

function CrouchBeginState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_standtocrouch_01', 1, _stateName, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_standtocrouch_01', 1, _stateName, 2)
end
function CrouchBeginState:InitData()
    self:AddTransition('ToCrouchIdleState', self.controller.states['CrouchIdleState'], 0.2)
end

function CrouchBeginState:OnEnter()
    PlayerActState.OnEnter(self)
    --localPlayer:StopMovementImmediately()
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.1, 0.1, true, false, 1)
end

function CrouchBeginState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function CrouchBeginState:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer:Crouch()
end

return CrouchBeginState
