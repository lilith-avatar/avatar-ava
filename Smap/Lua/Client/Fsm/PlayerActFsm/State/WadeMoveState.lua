--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local WadeMoveState = class('WadeMoveState', PlayerActState)

-- 玩家原始移动速度
local prevMaxWallSpeed

function WadeMoveState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)

    prevMaxWallSpeed = localPlayer.MaxWalkSpeed

    local animsM = {
        {'anim_man_idle_01', 0.0, 1.0},
        {'anim_man_walkfront_01', 0.25, 1.0},
        {'anim_man_runfront_01', 0.5, 1.0},
        {'anim_man_sprint_01', 1, 1.0}
    }

    local animsW = {
        {'anim_woman_idle_01', 0.0, 1.0},
        {'anim_woman_walkfront_01', 0.25, 1.0},
        {'anim_woman_runfront_01', 0.5, 1.0},
        {'anim_woman_sprint_01', 1, 1.0}
    }
    PlayerAnimMgr:Create1DClipNode(animsM, 'speedXZ', _stateName, 1)
    PlayerAnimMgr:Create1DClipNode(animsW, 'speedXZ', _stateName, 2)
end
function WadeMoveState:InitData()
end

function WadeMoveState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
    localPlayer.MaxWalkSpeed = localPlayer.MaxWalkSpeed * 0.75
end

function WadeMoveState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:SpeedMonitor()
    self:Move(true)
    self:FallMonitor()
end
function WadeMoveState:OnLeave()
    PlayerActState.OnLeave(self)
    self.controller:GetStopInfo()
    localPlayer.MaxWalkSpeed = prevMaxWallSpeed
end

return WadeMoveState
