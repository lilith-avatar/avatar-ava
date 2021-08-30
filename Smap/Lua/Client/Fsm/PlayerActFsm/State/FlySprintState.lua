--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local FlySprintState = class('FlySprintState', PlayerActState)

function FlySprintState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    local animsM = {
        {'anim_man_flyforward_01', 0.0, 0.0, 1.0},
        {'anim_man_flyturnleft_01', -1.0, 0.0, 1.0},
        {'anim_man_flyturnright_01', 1.0, 0.0, 1.0},
        {'anim_man_flyup_01', 0.0, 1.0, 1.0},
        {'anim_man_flydown_01', 0.0, -1.0, 1.0}
    }
    local animsW = {
        {'anim_woman_flyforward_01', 0.0, 0.0, 1.0},
        {'anim_woman_flyturnleft_01', -1.0, 0.0, 1.0},
        {'anim_woman_flyturnright_01', 1.0, 0.0, 1.0},
        {'anim_woman_flyup_01', 0.0, 1.0, 1.0},
        {'anim_woman_flydown_01', 0.0, -1.0, 1.0}
    }
    PlayerAnimMgr:Create2DClipNode(animsM, 'speedX', 'speedY', _stateName, 1)
    PlayerAnimMgr:Create2DClipNode(animsW, 'speedX', 'speedY', _stateName, 2)
end
function FlySprintState:InitData()
    self:AddTransition(
        'ToFlySprintEndState',
        self.controller.states['FlySprintEndState'],
        -1,
        function()
            return not C.Mgr.PlayerCtrl.isSprint
        end
    )
    self:AddTransition(
        'ToFlyEndState',
        self.controller.states['FlyEndState'],
        -1,
        function()
            return self:FloorMonitor(0.07)
        end
    )
end

function FlySprintState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
end

function FlySprintState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:SpeedMonitor(localPlayer.MaxFlySpeed)
    self:Fly()
end
function FlySprintState:OnLeave()
    PlayerActState.OnLeave(self)
end

return FlySprintState
