--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local JumpBeginState = class('JumpBeginState', PlayerActState)

function JumpBeginState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)

    PlayerAnimMgr:CreateSingleClipNode('anim_man_jump_begin_01', 1, _stateName, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_jump_begin_01', 1, _stateName, 2)
end
function JumpBeginState:InitData()
    self:AddTransition('ToJumpRiseState', self.controller.states['JumpRiseState'], 0.05)
end

function JumpBeginState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0, 0, true, false, 1.1)
end

function JumpBeginState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)

    --- 空中控制
    PlayerActState:JumpAirControlUpdate()
end

function JumpBeginState:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer:Jump()
    --[[
    if self:MoveMonitor() then
        localPlayer:AddImpulse(C.Mgr.PlayerCtrl.finalDir * 500)
    end
    --]]
end

return JumpBeginState
