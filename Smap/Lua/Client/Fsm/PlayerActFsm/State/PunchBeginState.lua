--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

---拳击交互动画
---继承PlayerActState
local PunchBeginState = class('PunchBeginState', PlayerActState)

function PunchBeginState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    ---动画名，动画播放速度
    PlayerAnimMgr:CreateSingleClipNode('PunchEquip', 0.6, _stateName)
end
function PunchBeginState:InitData()
    ---可以从任意状态进入
    self:AddAnyState(
        ---要去哪个状态,后缀带State
        'ToPunchBeginState',
        ---触发器进入
        -1,
        function()
            ---触发器实例化,后缀带State
            return self.controller.triggers['PunchBeginState']
        end
    )

    self:AddTransition(
        ---要去哪个状态,后缀带State
        'ToPunchState',
        ---后缀带State
        self.controller.states['PunchState'],
        ---时间耗尽转移状态
        0.6
    )
end

function PunchBeginState:OnEnter()
    PlayerActState.OnEnter(self)

    --localPlayer.FollowTarget = self.controller.seatObj
    ---上下半身动画设置，权重，进入动画过渡时间，退出动画过渡时间，是否可以打断，是否循环，动画播放速度
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 1.5)
end

function PunchBeginState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function PunchBeginState:OnLeave()
    PlayerActState.OnLeave(self)
end

return PunchBeginState
