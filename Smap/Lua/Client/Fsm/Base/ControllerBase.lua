--- 状态机控制器基类
--- @module ControllerBase
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local ControllerBase = class('ControllerBase')

function ControllerBase:initialize(_stateMachineNode, _folder)
    self.machine = _stateMachineNode
    self.states = {}
    self.statesInMachine = {}
    self.lastState = nil
    self.curState = nil
    self:ConnectStates(self, _folder)
end

--绑定所有状态
function ControllerBase:ConnectStates(_controller, _folder)
    for _, module in pairs(_folder) do
        local tempStateClass = module
        local stateModule = tempStateClass:new(_controller, module.name)
        local stateInMachine = self.machine:CreateState(module.name)
        self.statesInMachine[module.name] = stateInMachine
        self.states[module.name] = stateModule
        stateInMachine.OnEnter:Connect(
            function()
                stateModule:OnEnter()
            end
        )
        stateInMachine.OnUpdate:Connect(
            function()
                stateModule:OnUpdate()
            end
        )
        stateInMachine.OnExit:Connect(
            function()
                stateModule:OnLeave()
            end
        )
    end
    for _, state in pairs(self.states) do
        state:InitData()
    end
end

--初始化默认状态
function ControllerBase:SetDefState(_stateName)
    self.machine:SetDefaultState(self.statesInMachine[_stateName])
    self.curState = self.states[_stateName]
    self.machine:Play()
end

--切换状态
function ControllerBase:Switch(_state)
    if _state and self.curState ~= _state then
        self.lastState = self.curState
        self.curState = _state
        print(self.curState.stateName)
        self.machine:GotoState(self.statesInMachine[_state.stateName])
    end
end

function ControllerBase:Update(dt)
    if self.curState then
        self:Switch(self.curState:TransUpdate(dt))
        for _, v in pairs(self.states) do
            self:Switch(v:AnyStateCheck())
        end
    end
end

return ControllerBase
