--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

local SwimEndState = class('SwimEndState', PlayerActState)

local check = nil

function SwimEndState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_human_sit_swim_goashore', 1, _stateName)
end

function SwimEndState:InitData()
    self:AddTransition('ToIdleState', self.controller.states['IdleState'], 0.4)
end

function SwimEndState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, false, false, 1.75)
    invoke(
        function()
            localPlayer:StopMovementImmediately()
        end,
        0.3
    )
    --[[
    invoke(
        ,
        0.3
    )
    --]]
    --[[
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
    --]]
end

function SwimEndState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function SwimEndState:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer:SetSwimming(false)
    EmoActionMgr:HideDanceBtn(true)
    --[[
    if check then
        print('swimEnd......................................')
        check:Complete()
    end
    --]]
end

return SwimEndState
