--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

---玩摇杆动画
local PlayRockerState = class('PlayRockerState', PlayerActState)

function PlayRockerState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('HTPlayRocker', 1, _stateName)
end
function PlayRockerState:InitData()
    self:AddAnyState(
        'ToPlayRockerState',
        -1,
        function()
            return self.controller.triggers['PlayRockerState']
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

function PlayRockerState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
end

function PlayRockerState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    --self:SpeedMonitor()
    --self:Move(true)
    --self:FallMonitor()
end

function PlayRockerState:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer.Avatar:StopBlendSpaceNode(0)
end

return PlayRockerState
