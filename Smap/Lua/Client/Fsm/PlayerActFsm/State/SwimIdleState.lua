--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local SwimIdleState = class('SwimIdleState', PlayerActState)

local check = nil

function SwimIdleState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)

    local anims = {
        {'anim_human_swim_idle_01', 0.0, 1.0},
        {'anim_human_swimup_01', 0.2, 1.0},
        {'anim_human_swimdown_01', -0.2, 1.0}
    }
    PlayerAnimMgr:Create1DClipNode(anims, 'speedY', _stateName)
end

function SwimIdleState:InitData()
    self:AddTransition(
        'ToSwimmingStartState',
        self.controller.states['SwimmingStartState'],
        -1,
        function()
            return self:MoveMonitor()
        end
    )

    self:AddTransition(
        'ToSwimEndState',
        self.controller.states['SwimEndState'],
        -1,
        function()
            return not self:SwimMonitor()
        end
    )
end

function SwimIdleState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:StopMovementImmediately()

    --- 屏蔽舞蹈动作
    EmoActionMgr:HideDanceBtn(false)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
end

function SwimIdleState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:SpeedMonitor()
    self:UpAndDown()
    self:Swim()
    --print(self:IsWaterSuface(1.5))
end

function SwimIdleState:OnLeave()
    PlayerActState.OnLeave(self)
end

return SwimIdleState
