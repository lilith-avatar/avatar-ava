--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local DoubleJumpState = class('DoubleJumpState', PlayerActState)

function DoubleJumpState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_doublejump_01', 1, _stateName, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_doublejump_01', 1, _stateName, 2)
end
function DoubleJumpState:InitData()
    self:AddTransition('ToFallState', self.controller.states['FallState'], 0.4)
end

function DoubleJumpState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 1)
    self.controller.jumpCount = self.controller.jumpCount - 1
    localPlayer:AddImpulse(Vector3(0, 1200, 0))
end

function DoubleJumpState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:Move()
end

function DoubleJumpState:OnLeave()
    PlayerActState.OnLeave(self)
end

return DoubleJumpState
