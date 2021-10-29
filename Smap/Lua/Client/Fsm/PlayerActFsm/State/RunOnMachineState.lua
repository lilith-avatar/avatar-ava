--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

---在跑步机上奔跑动画
local RunOnMachineState = class('RunOnMachineState', PlayerActState)

function RunOnMachineState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('RunFront', 1, _stateName)
end
function RunOnMachineState:InitData()
    self:AddAnyState(
        'ToRunOnMachineState',
        -1,
        function()
            return self.controller.triggers['RunOnMachineState']
        end
    )

    self:AddTransition(
        'ToIdleState',
        self.controller.states['IdleState'],
        -1,
        function()
            return self.controller.triggers['IdleState']
        end
    )
end

function RunOnMachineState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
end

function RunOnMachineState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    --self:SpeedMonitor()
    --self:Move(true)
    --self:FallMonitor()
end

function RunOnMachineState:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer.Avatar:StopBlendSpaceNode(0)
end

return RunOnMachineState
