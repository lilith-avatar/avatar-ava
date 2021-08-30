--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local DoubleJumpSprintState = class('DoubleJumpSprintState', PlayerActState)

function DoubleJumpSprintState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_doublejump_02', 1, _stateName, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_doublejump_02', 1, _stateName, 2)
end
function DoubleJumpSprintState:InitData()
    self:AddTransition('ToFallState', self.controller.states['FallState'], 0.6)
end

function DoubleJumpSprintState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.1, 0.1, true, false, 1)
    self.controller.jumpCount = self.controller.jumpCount - 1
    localPlayer:LaunchCharacter(Vector3(0, 10, 0) + localPlayer.Forward * 5, false, false)
end

function DoubleJumpSprintState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function DoubleJumpSprintState:OnLeave()
    PlayerActState.OnLeave(self)
end

return DoubleJumpSprintState
