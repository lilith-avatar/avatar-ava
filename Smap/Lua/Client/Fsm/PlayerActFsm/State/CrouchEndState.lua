--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local CrouchEndState = class('CrouchEndState', PlayerActState)

function CrouchEndState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_crouchtostand_02', 1, _stateName, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_crouchtostand_02', 1, _stateName, 2)
end
function CrouchEndState:InitData()
    self:AddTransition('ToIdleState', self.controller.states['IdleState'], 0.1)
    self:AddTransition(
        'ToFlyBeginState',
        self.controller.states['FlyBeginState'],
        -1,
        function()
            return self.controller.triggers['FlyBeginState']
        end
    )
end

function CrouchEndState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.1, 0.1, true, false, 1)
end

function CrouchEndState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function CrouchEndState:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer:UnCrouch()
end

return CrouchEndState
