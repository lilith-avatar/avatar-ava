--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

--- 玩家处于涉水状态
local WadeState = class('WadeState', PlayerActState)

local check = nil
function WadeState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
end

function WadeState:InitData()
end

function WadeState:OnEnter()
    PlayerActState.OnEnter(self)
    --localPlayer.Avatar.LocalPosition = Vector3.Zero
    --[[
    if localPlayer.Avatar.LocalPosition.Magnitude ~= 0 then
        --* 动画偏移修正
        local checkT =
            Tween:TweenProperty(localPlayer.Avatar, {LocalPosition = Vector3.Zero}, 0.2, Enum.EaseCurve.Linear)
        checkT.OnComplete:Connect(
            function()
                checkT:Destroy()
            end
        )
        check = checkT
        checkT:Play()
    end
    --]]
    --- 跳水后恢复跳跃
    self.controller.jumpCount = localPlayer.JumpMaxCount
end

function WadeState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    --- 限制最大速度
    self:SpeedMonitor(localPlayer.MaxWalkSpeed * 0.67)
    --- 允许移动
    self:Move()
end

function WadeState:OnLeave()
    PlayerActState.OnLeave(self)
end

return WadeState
