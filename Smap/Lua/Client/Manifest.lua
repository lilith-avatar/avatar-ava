--- 框架默认配置
--- @module Framework Global FrameworkConfig
--- @copyright Lilith Games, Avatar Team
local Manifest = {}

Manifest.ROOT_PATH = 'Lua/Client/'

Manifest.Events = {
    'NoticeEvent'
}

Manifest.Modules = {
    {
        Name = 'Fsm',
        Modules = {
            {
                Name = 'Base',
                Modules = {
                    'ControllerBase',
                    'StateBase',
                    'TransitonBase'
                }
            },
            {
                Name = 'PlayerActFsm',
                Modules = {
                    'PlayerActController',
                    'PlayerActState',
                    {
                        Name = 'State',
                        Modules = {
                            'ActBeginState',
                            'ActEndState',
                            'ActState',
                            'AttackPunch1State',
                            'AttackPunch2State',
                            'CrouchBeginState',
                            'CrouchEndState',
                            'CrouchIdleState',
                            'CrouchMoveState',
                            'DoubleJumpSprintState',
                            'DoubleJumpState',
                            'FallState',
                            'FlyBeginState',
                            'FlyEndState',
                            'FlyIdleState',
                            'FlyMoveState',
                            'FlySprintBeginState',
                            'FlySprintEndState',
                            'FlySprintState',
                            'IdleState',
                            'JumpBeginState',
                            'JumpHighestState',
                            'JumpRiseState',
                            'LandState',
                            'LieBeginState',
                            'LieEndState',
                            'LieState',
                            'MoveState',
                            'MoveStopState',
                            'OpenState',
                            'PickUpHeavyBeginState',
                            'PickUpHeavyEndState',
                            'PickUpHeavyState',
                            'PlayRockerState',
                            'PunchBeginState',
                            'PunchEndState',
                            'PunchState',
                            'RideState',
                            'RunOnMachineState',
                            'SitBeginState',
                            'SitEndState',
                            'SitState',
                            'SwimBeginState',
                            'SwimEndState',
                            'SwimIdleState',
                            'SwimmingEndState',
                            'SwimmingStartState',
                            'SwimmingState',
                            'ThrowBeginState',
                            'ThrowEndState',
                            'ThrowState',
                            'WadeMoveState',
                            'WadeMoveStopState',
                            'WadeState',
                            'DrinkBeginState',
                            'DrinkState',
                            'DanceState',
                            'WateringPlantBeginState',
                            'WateringPlantEndState',
                            'WateringPlantState'
                        }
                    }
                }
            },
            'FsmMgr',
            'PlayerAnimMgr',
            'PlayerActAnimeGui'
        }
    },
    {
        Name = 'Mgr',
        Modules = {
            'PlayerGuiDefault',
            'EmoActionMgr',
            'GuiControl',
            'PlayerCam',
            'PlayerCtrl'
        }
    }
}

return Manifest
