--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local ThrowState = class('ThrowState', PlayerActState)

local moveAnim = 'MoveState'

function ThrowState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('ThrowIdle', 1, _stateName)
end
function ThrowState:InitData()
    self:AddTransition(
        'ToThrowEndState',
        self.controller.states['ThrowEndState'],
        -1,
        function()
            return self.controller.triggers['ThrowEndState']
        end
    )
end

function ThrowState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 2, 1, 0.2, 0.2, true, true, 0.01)
    PlayerAnimMgr:Play(moveAnim, 0, 1, 0.2, 0.2, true, true, 1)
end

function ThrowState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:SpeedMonitor()
    self:Move(true)
    self:FallMonitor()
end

function ThrowState:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer.Avatar:StopBlendSpaceNode(2)
end

return ThrowState

--[[local ThrowState = class('ThrowState', PlayerActState)

function ThrowState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('ThrowIdle', 1, _stateName)
end
function ThrowState:InitData()
    self:AddTransition(
        'ToThrowEndState',
        self.controller.states['ThrowEndState'],
        -1,
        function()
            return self.controller.triggers['ThrowEndState']
        end
    )
end

function ThrowState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
end

function ThrowState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function ThrowState:OnLeave()
    PlayerActState.OnLeave(self)
end

return ThrowState
]]
