--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local CrouchIdleState = class('CrouchIdleState', PlayerActState)

function CrouchIdleState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_crouch_idle_02', 1, _stateName .. 'Right', 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_crouch_idle_01', 1, _stateName .. 'Left', 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_crouch_idle_02', 1, _stateName .. 'Right', 2)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_crouch_idle_01', 1, _stateName .. 'Left', 2)
end
function CrouchIdleState:InitData()
    self:AddTransition(
        'ToCrouchMoveState',
        self.controller.states['CrouchMoveState'],
        -1,
        function()
            return self:MoveMonitor()
        end
    )
    self:AddTransition(
        'ToCrouchEndState',
        self.controller.states['CrouchEndState'],
        -1,
        function()
            return not self.controller.isCrouch
        end
    )
    self:AddTransition(
        'ToFlyBeginState',
        self.controller.states['FlyBeginState'],
        -1,
        function()
            return self.controller.triggers['FlyBeginState']
        end
    )
end

function CrouchIdleState:OnEnter()
    PlayerActState.OnEnter(self)
    if self.controller.stopInfo.footIndex == 1 then
        PlayerAnimMgr:Play(self.stateName .. 'Right', 0, 1, 0.2, 0.2, true, true, 1)
    else
        PlayerAnimMgr:Play(self.stateName .. 'Left', 0, 1, 0.2, 0.2, true, true, 1)
    end
end

function CrouchIdleState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function CrouchIdleState:OnLeave()
    PlayerActState.OnLeave(self)
end

return CrouchIdleState
