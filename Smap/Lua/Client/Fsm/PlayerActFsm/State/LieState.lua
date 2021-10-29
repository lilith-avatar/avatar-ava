--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

local LieState = class('LieState', PlayerActState)

function LieState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_human_pd_liedownloop_01', 1, _stateName)
end
function LieState:InitData()
    self:AddTransition(
        'ToLieEndState',
        self.controller.states['LieEndState'],
        -1,
        function()
            return self.controller.triggers['LieEndState']
        end
    )
end

function LieState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
end

function LieState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function LieState:OnLeave()
    PlayerActState.OnLeave(self)
end

return LieState
