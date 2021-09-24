--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local FlySprintBeginState = class('FlySprintBeginState', PlayerActState)

function FlySprintBeginState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_hovertofly_01', 1.3, _stateName, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_hovertofly_01', 1, _stateName, 2)
    --[[self.animNode:AddAnimationEvent(0.5):Connect(
        function()
            if self:MoveMonitor() then
                localPlayer:AddImpulse(localPlayer.Forward * 500)
            end
        end
    )]]
end
function FlySprintBeginState:InitData()
    self:AddTransition('ToFlySprintState', self.controller.states['FlySprintState'], 0.6)
    self:AddTransition(
        'ToFlyEndState',
        self.controller.states['FlyEndState'],
        -1,
        function()
            return self:FloorMonitor(0.06)
        end
    )
end

function FlySprintBeginState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 0.8)
end

function FlySprintBeginState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function FlySprintBeginState:OnLeave()
    PlayerActState.OnLeave(self)
end

return FlySprintBeginState
