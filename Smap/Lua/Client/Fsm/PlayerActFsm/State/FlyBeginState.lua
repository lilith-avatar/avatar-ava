--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local FlyBeginState = class('FlyBeginState', PlayerActState)

function FlyBeginState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_jumptohover_01', 1, _stateName, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_jumptohover_01', 1, _stateName, 2)
end
function FlyBeginState:InitData()
    self:AddTransition('ToFlyIdleState', self.controller.states['FlyIdleState'], 0.4)
end

function FlyBeginState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:StopMovementImmediately()
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.1, 0.1, true, false, 1)
end

function FlyBeginState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function FlyBeginState:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer:AddImpulse(localPlayer.Up * 500)
    wait()
end

return FlyBeginState
