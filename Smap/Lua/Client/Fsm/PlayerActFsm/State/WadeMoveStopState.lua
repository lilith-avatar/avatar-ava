--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local WadeMoveStopState = class('WadeMoveStopState', PlayerActState)

function WadeMoveStopState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)

    self.animsM = {
        {'LW', 'anim_man_stop_l_05', 0.2, 1.0},
        {'LR1', 'anim_man_stop_l_03', 0.2, 1.0},
        {'LR2', 'anim_man_stop_l_07', 0.2, 1.0},
        {'LS', 'anim_man_stop_l_06', 0.2, 1.0},
        {'RW', 'anim_man_stop_r_05', 0.2, 1.0},
        {'RR1', 'anim_man_stop_r_03', 0.2, 1.0},
        {'RR2', 'anim_man_stop_r_07', 0.2, 1.0},
        {'RS', 'anim_man_stop_r_06', 0.2, 1.0}
    }
    self.animsW = {
        {'LW', 'anim_woman_stop_l_05', 0.2, 1.0},
        {'LR1', 'anim_woman_stop_l_03', 0.2, 1.0},
        {'LR2', 'anim_woman_stop_l_07', 0.2, 1.0},
        {'LS', 'anim_woman_stop_l_06', 0.2, 1.0},
        {'RW', 'anim_woman_stop_r_05', 0.2, 1.0},
        {'RR1', 'anim_woman_stop_r_03', 0.2, 1.0},
        {'RR2', 'anim_woman_stop_r_07', 0.2, 1.0},
        {'RS', 'anim_woman_stop_r_06', 0.2, 1.0}
    }
    for i, v in pairs(self.animsM) do
        PlayerAnimMgr:CreateSingleClipNode(v[2], v[4], _stateName .. i, 1)
    end
    for i, v in pairs(self.animsW) do
        PlayerAnimMgr:CreateSingleClipNode(v[2], v[4], _stateName .. i, 2)
    end
end
function WadeMoveStopState:InitData()
end

--确定该播放哪个停步动作
function WadeMoveStopState:GetStopIndex()
    local stopSSpeed = 0.9
    local stopRSpeed = 0.4
    local stopDisGap = 0.7
    local index = 1
    if math.clamp(self.controller.stopInfo.speed / localPlayer.MaxWalkSpeed, 0, 1) > stopSSpeed then
        index = 4
    elseif math.clamp(self.controller.stopInfo.speed / localPlayer.MaxWalkSpeed, 0, 1) > stopRSpeed then
        if self.controller.stopInfo.footDis > stopDisGap then
            index = 2
        else
            index = 3
        end
    end
    if self.controller.stopInfo.footIndex == 1 then
        index = index + 4
    end
    return index
end

function WadeMoveStopState:OnEnter()
    PlayerActState.OnEnter(self)
    local index = self:GetStopIndex()
    PlayerAnimMgr:Play(self.stateName .. index, 0, 1, 0.2, 0.2, true, false, 1)
end

function WadeMoveStopState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end
function WadeMoveStopState:OnLeave()
    PlayerActState.OnLeave(self)
end

return WadeMoveStopState
