--- 角色动作状态机模块
--- @module Fsm Mgr, client-side
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local FsmMgr, this = ModuleUtil.New('FsmMgr', ClientBase)

--- 初始化
function FsmMgr:Init()
    print('FsmMgr:Init')
    this:DataInit()
end

--- 数据变量初始化
function FsmMgr:DataInit()
    -- 玩家动作状态机控制器
    this.playerActCtrl = PlayerActController:new(localPlayer.StateMachine, C.Fsm.PlayerActFsm.State)
    this.playerActCtrl:SetDefState('IdleState')

    world.OnRenderStepped:Connect(
        function(dt)
            this.playerActCtrl:Update(dt)
        end
    )
end

return FsmMgr
