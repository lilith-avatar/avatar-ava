--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local LieBeginState = class('LieBeginState', PlayerActState)

function LieBeginState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_human_pd_sitdown_01', 1, _stateName .. 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_human_pd_liedown_01', 1, _stateName .. 1)
end
function LieBeginState:InitData()
    self:AddAnyState(
        'ToLieBeginState',
        -1,
        function()
            return self.controller.triggers['LieBeginState']
        end
    )
    self:AddTransition('ToLieState', self.controller.states['LieState'], 1)
end

function LieBeginState:OnEnter()
    PlayerActState.OnEnter(self)

    --localPlayer.FollowTarget = self.controller.seatObj
    PlayerAnimMgr:Play(self.stateName .. 1, 0, 1, 0.2, 0.2, true, false, 1)
    local CallBack1 = localPlayer.Avatar:AddAnimationEvent('anim_human_pd_sitdown_01', 0.99)
    CallBack1:Connect(
        function()
            PlayerAnimMgr:Play(self.stateName .. 2, 0, 1, 0.2, 0.2, true, false, 1)
        end
    )
end

function LieBeginState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function LieBeginState:OnLeave()
    PlayerActState.OnLeave(self)
end

return LieBeginState
