--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local ThrowBeginState = class('ThrowBeginState', PlayerActState)

function ThrowBeginState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('PickUpLight', 0.6, _stateName)
end
function ThrowBeginState:InitData()
    self:AddAnyState(
        'ToThrowBeginState',
        -1,
        function()
            return self.controller.triggers['ThrowBeginState']
        end
    )
    self:AddTransition('ToThrowState', self.controller.states['ThrowState'], 1)
end

function ThrowBeginState:OnEnter()
    PlayerActState.OnEnter(self)

    --localPlayer.FollowTarget = self.controller.seatObj
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 1.5)
    EmoActionMgr:HideDanceBtn(false)
    C_TakePhoto:OpenCamBtnCtrl(false)
end

function ThrowBeginState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function ThrowBeginState:OnLeave()
    PlayerActState.OnLeave(self)
end

return ThrowBeginState
