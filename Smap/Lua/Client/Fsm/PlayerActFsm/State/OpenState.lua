--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

---开启动画
local OpenState = class('OpenState', PlayerActState)

function OpenState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('OpenDoor', 1, _stateName)
end
function OpenState:InitData()
    self:AddAnyState(
        'ToOpenState',
        -1,
        function()
            return self.controller.triggers['OpenState']
        end
    )

    self:AddTransition(
        ---要去哪个状态
        'ToIdleState',
        self.controller.states['IdleState'],
        ---时间耗尽转移状态
        1
    )
end

function OpenState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 1)
end

function OpenState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    --self:SpeedMonitor()
    --self:Move(true)
    --self:FallMonitor()
end

function OpenState:OnLeave()
    PlayerActState.OnLeave(self)
    --localPlayer.Avatar:StopBlendSpaceNode(0)
end

return OpenState
