--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local SwimmingStartState = class('SwimmingStartState', PlayerActState)

function SwimmingStartState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)

    PlayerAnimMgr:CreateSingleClipNode('anim_human_idletofreestyle_01', 1, _stateName .. 'Freestyle')
    PlayerAnimMgr:CreateSingleClipNode('anim_human_idletobreaststroke_01', 1, _stateName .. 'Breaststroke')
end

function SwimmingStartState:InitData()
    self:AddTransition('ToSwimmingState', self.controller.states['SwimmingState'], 1)
    self:AddTransition(
        'ToSwimEndState',
        self.controller.states['SwimEndState'],
        -1,
        function()
            return not self:SwimMonitor()
        end
    )
    self:AddTransition(
        'ToSwimIdleState',
        self.controller.states['SwimIdleState'],
        -1,
        function()
            return not self:MoveMonitor()
        end
    )
end

function SwimmingStartState:OnEnter()
    PlayerActState.OnEnter(self)
    if self:IsWaterSuface() then
        --print('Freestyle')
        PlayerAnimMgr:Play(self.stateName .. 'Freestyle', 0, 1, 0.2, 0.2, true, true, 1)
    else
        PlayerAnimMgr:Play(self.stateName .. 'Breaststroke', 0, 1, 0.2, 0.2, true, true, 1.5)
    end
end

function SwimmingStartState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:Swim()
end

function SwimmingStartState:OnLeave()
    PlayerActState.OnLeave(self)
    if self:MoveMonitor() then
        local dir = localPlayer.Forward
        dir.y = 0
        localPlayer:AddImpulse(localPlayer.Forward * 400)
    end
end

return SwimmingStartState
