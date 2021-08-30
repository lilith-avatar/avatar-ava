--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local JumpRiseState = class('JumpRiseState', PlayerActState)

function JumpRiseState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)

    local animsM = {
        {'anim_man_jump_riseuploop_01', 0.0, 1.0},
        {'anim_man_jumpforward_riseuploop_02', 0.5, 1.0}
    }
    local animsW = {
        {'anim_woman_jump_riseuploop_01', 0.0, 1.0},
        {'anim_woman_jumpforward_riseuploop_02', 0.5, 1.0}
    }
    PlayerAnimMgr:Create1DClipNode(animsM, 'speedXZ', _stateName, 1)
    PlayerAnimMgr:Create1DClipNode(animsW, 'speedXZ', _stateName, 2)
end
function JumpRiseState:InitData()
    self:AddTransition('ToJumpHighestState', self.controller.states['JumpHighestState'], 0.05)
end

function JumpRiseState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.1, 0.1, true, true, 1)
    self.controller.jumpCount = self.controller.jumpCount - 1
end

function JumpRiseState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:FallMonitor()
    self:Move()
    self:SpeedMonitor()

    --- 空中控制
    PlayerActState:JumpAirControlUpdate()
end

function JumpRiseState:OnLeave()
    PlayerActState.OnLeave(self)
end

return JumpRiseState
