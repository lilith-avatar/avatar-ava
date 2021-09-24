--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local PlayerActState = C.Fsm.PlayerActFsm.PlayerActState
local PlayerAnimMgr = C.Fsm.PlayerAnimMgr

---杠铃交互动画
---继承PlayerActState
local PickUpHeavyBeginState = class('PickUpHeavyBeginState', PlayerActState)

function PickUpHeavyBeginState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    ---动画名，动画播放速度
    PlayerAnimMgr:CreateSingleClipNode('PickUpHeavy', 0.6, _stateName)
end
function PickUpHeavyBeginState:InitData()
    ---可以从任意状态进入
    self:AddAnyState(
        ---要去哪个状态,后缀带State
        'ToPickUpHeavyBeginState',
        ---触发器进入
        -1,
        function()
            ---触发器实例化,后缀带State
            return self.controller.triggers['PickUpHeavyBeginState']
        end
    )

    self:AddTransition(
        ---要去哪个状态,后缀带State
        'ToPickUpHeavyState',
        ---后缀带State
        self.controller.states['PickUpHeavyState'],
        ---时间耗尽转移状态
        1
    )
end

function PickUpHeavyBeginState:OnEnter()
    PlayerActState.OnEnter(self)

    --localPlayer.FollowTarget = self.controller.seatObj
    ---上下半身动画设置，权重，进入动画过渡时间，退出动画过渡时间，是否可以打断，是否循环，动画播放速度
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 1.5)
end

function PickUpHeavyBeginState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function PickUpHeavyBeginState:OnLeave()
    PlayerActState.OnLeave(self)
end

return PickUpHeavyBeginState
