--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local LandState = class('LandState', PlayerActState)

function LandState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)

    PlayerAnimMgr:CreateSingleClipNode('anim_man_jumptoidle_01', 1, _stateName .. 1, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_jumptoidle_01', 1, _stateName .. 1, 2)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_jumpforwardtorun_01', 1, _stateName .. 2, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_jumpforwardtorun_01', 1, _stateName .. 2, 2)
end
function LandState:InitData()
    self:AddTransition(
        'ToFlyBeginState',
        self.controller.states['FlyBeginState'],
        -1,
        function()
            return self.controller.triggers['FlyBeginState']
        end
    )
    self:AddTransition(
        'ToJumpBeginState',
        self.controller.states['JumpBeginState'],
        -1,
        function()
            return self.controller.triggers['JumpBeginState']
        end
    )
end

function LandState:OnEnter()
    PlayerActState.OnEnter(self)
    local dir = C.Mgr.PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        self:AddTransition('ToMoveState', self.controller.states['MoveState'], 0.01)
        PlayerAnimMgr:Play(self.stateName .. 2, 0, 1, 0.1, 0.1, true, false, 0.8)
    else
        self:AddTransition('ToIdleState', self.controller.states['IdleState'], 0.3)
        self:AddTransition(
            'ToMoveState',
            self.controller.states['MoveState'],
            -1,
            function()
                return self:MoveMonitor()
            end
        )
        PlayerAnimMgr:Play(self.stateName .. 1, 0, 1, 0.1, 0.1, true, false, 1)
    end
    self.controller.jumpCount = localPlayer.JumpMaxCount
end

function LandState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:Move()
end

function LandState:OnLeave()
    PlayerActState.OnLeave(self)
    self.transitions = {}
end

return LandState
