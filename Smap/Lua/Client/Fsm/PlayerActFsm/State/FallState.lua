--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local FallState = class('FallState', PlayerActState)

function FallState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)

    local animsM = {
        {'anim_man_jump_falldownloop_01', 0.0, 1.0},
        {'anim_man_jumpforward_falldownloop_01', 0.5, 1.0}
    }
    local animsW = {
        {'anim_woman_jump_falldownloop_01', 0.0, 1.0},
        {'anim_woman_jumpforward_falldownloop_01', 0.5, 1.0}
    }
    PlayerAnimMgr:Create1DClipNode(animsM, 'speedXZ', _stateName, 1)
    PlayerAnimMgr:Create1DClipNode(animsW, 'speedXZ', _stateName, 2)
end
function FallState:InitData()
    self:AddTransition(
        'ToLandState',
        self.controller.states['LandState'],
        -1,
        function()
            return self:FloorMonitor(0.5)
        end
    )
    self:AddTransition(
        'ToDoubleJumpState',
        self.controller.states['DoubleJumpState'],
        -1,
        function()
            return self.controller.triggers['DoubleJumpState']
        end
    )
    self:AddTransition(
        'ToDoubleJumpSprintState',
        self.controller.states['DoubleJumpSprintState'],
        -1,
        function()
            return self.controller.triggers['DoubleJumpSprintState']
        end
    )
end

function FallState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.1, 0.1, true, true, 1)
end

function FallState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:Move()
    self:SpeedMonitor()

    --- 空中控制
    PlayerActState:JumpAirControlUpdate()
end

function FallState:OnLeave()
    PlayerActState.OnLeave(self)
end

return FallState
