--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

---杠铃交互动画
local PickUpHeavyState = class('PickUpHeavyState', PlayerActState)

function PickUpHeavyState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('HoldOn', 1, _stateName)
end
function PickUpHeavyState:InitData()
    self:AddTransition(
        'ToPickUpHeavyEndState',
        self.controller.states['PickUpHeavyEndState'],
        -1,
        function()
            return self.controller.triggers['PickUpHeavyEndState']
        end
    )
end

function PickUpHeavyState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 2, 1, 0.2, 0.2, true, true, 1)
end

function PickUpHeavyState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    --self:SpeedMonitor()
    --self:Move(true)
    --self:FallMonitor()
end

function PickUpHeavyState:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer.Avatar:StopBlendSpaceNode(2)
end

return PickUpHeavyState
