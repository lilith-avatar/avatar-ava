--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local SitBeginState = class('SitBeginState', PlayerActState)

function SitBeginState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_human_sit_begin', 1, _stateName)
end
function SitBeginState:InitData()
    self:AddAnyState(
        'ToSitBeginState',
        -1,
        function()
            return self.controller.triggers['SitBeginState']
        end
    )
    self:AddTransition('ToSitState', self.controller.states['SitState'], 1)
end

function SitBeginState:OnEnter()
    PlayerActState.OnEnter(self)
    --[[localPlayer.Position =
        self.controller.seatObj.Positive + self.controller.seatObj.Forward * self.controller.seatObj.Size.z / 2
    localPlayer.Rotation = self.controller.seatObj.Rotation]]
    --localPlayer.FollowTarget = self.controller.seatObj
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 1)
end

function SitBeginState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function SitBeginState:OnLeave()
    PlayerActState.OnLeave(self)
end

return SitBeginState
