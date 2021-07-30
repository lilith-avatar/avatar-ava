--- @module Decorator Node 行为树装饰节点
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local DecoratorNode = {}

function DecoratorNode:Init()
    ------------------Decorator----------------------
    ---@class Decorator:BaseNode
    local decorator = B3.Class('Decorator', B3.BaseNode)
    B3.Decorator = decorator

    function decorator:ctor(params)
        B3.BaseNode.ctor(self, params)

        if not params then
            params = {}
        end

        self.child = params.child or nil
    end

    ---------Repeater
    local repeater = B3.Class('Repeater', B3.Decorator)
    B3.Repeater = repeater

    function repeater:ctor(params)
        B3.Decorator.ctor(self)

        if not params then
            params = {}
        end

        self.name = 'Repeater'
        self.title = 'Repeater <maxLoop>x'
        self.parameters = {maxLoop = -1}

        self.maxLoop = params.maxLoop or -1
    end

    function repeater:open(tick)
        tick.blackboard:set('i', 0, tick.tree.id, self.id)
        --print(table.dump(self.properties.maxLoop))
        self.maxLoop = self.properties.maxLoop
    end

    function repeater:tick(tick)
        if not self.child then
            return B3.ERROR
        end

        local i = tick.blackboard:get('i', tick.tree.id, self.id)
        local status = B3.SUCCESS

        while (self.maxLoop < 0 or i < self.maxLoop) do
            --print(i)
            local status = self.child:_execute(tick)
            if status == B3.SUCCESS or status == B3.FAILURE then
                i = i + 1
                wait()
            else
                break
            end
        end

        tick.blackboard:set('i', i, tick.tree.id, self.id)
        return status
    end

    ---------------RepeatUntilSuccess
    local repeatUntilSuccess = B3.Class('RepeatUntilSuccess', B3.Decorator)
    B3.RepeatUntilSuccess = repeatUntilSuccess

    function repeatUntilSuccess:ctor(params)
        B3.Decorator.ctor(self)

        if not params then
            params = {}
        end

        self.name = 'RepeatUntilSuccess'
        self.title = 'Repeat Until Success'
        self.parameters = {maxLoop = -1}

        self.maxLoop = params.maxLoop or -1
    end

    function repeatUntilSuccess:open(tick)
        tick.blackboard.set('i', 0, tick.tree.id, self.id)
        self.maxLoop = self.properties.maxLoop
    end

    function repeatUntilSuccess:tick(tick)
        if not self.child then
            return B3.ERROR
        end

        local i = tick.blackboard.get('i', tick.tree.id, self.id)
        local status = B3.ERROR

        while (self.maxLoop < 0 or i < self.maxLoop) do
            local status = self.child:_execute(tick)

            if status == B3.FAILURE then
                i = i + 1
            else
                break
            end
        end

        i = tick.blackboard.set('i', i, tick.tree.id, self.id)
        return status
    end

    ------------------RepeatUntilFailure
    local repeatUntilFailure = B3.Class('RepeatUntilFailure', B3.Decorator)
    B3.RepeatUntilFailure = repeatUntilFailure

    function repeatUntilFailure:ctor(params)
        B3.Decorator.ctor(self)

        if not params then
            params = {}
        end

        self.name = 'RepeatUntilFailure'
        self.title = 'Repeat Until Failure'
        self.parameters = {maxLoop = -1}

        self.maxLoop = params.maxLoop or -1
    end

    function repeatUntilFailure:open(tick)
        tick.blackboard.set('i', 0, tick.tree.id, self.id)
        self.maxLoop = self.properties.maxLoop
    end

    function repeatUntilFailure:tick(tick)
        if not self.child then
            return B3.ERROR
        end

        local i = tick.blackboard.get('i', tick.tree.id, self.id)
        local status = B3.ERROR

        while (self.maxLoop < 0 or i < self.maxLoop) do
            local status = self.child:_execute(tick)

            if status == B3.SUCCESS then
                i = i + 1
            else
                break
            end
        end

        i = tick.blackboard.set('i', i, tick.tree.id, self.id)
        return status
    end

    ---------------------Inverter
    local inverter = B3.Class('Inverter', B3.Decorator)
    B3.Inverter = inverter

    function inverter:ctor()
        B3.Inverter.ctor(self)

        self.name = 'Inverter'
    end

    function inverter:tick(tick)
        if not self.child then
            return B3.ERROR
        end

        local status = self.child:_execute(tick)

        if status == B3.SUCCESS then
            status = B3.FAILURE
        elseif status == B3.FAILURE then
            status = B3.SUCCESS
        end

        return status
    end

    -------------
    local maxTime = B3.Class('MaxTime', B3.Decorator)
    B3.MaxTime = maxTime

    function maxTime:ctor(params)
        B3.MaxTime.ctor(self)

        self.name = 'MaxTime'
        self.title = 'Max <maxTime>ms'
        self.parameters = {maxTime = 0}

        if not params or not params.maxTime then
            print('maxTime parameter in MaxTime decorator is an obligatory parameter')
            return
        end

        self.maxTime = params.maxTime
    end

    function maxTime:open(tick)
        local startTime = Timer.GetTimeMillisecond()
        self.maxTime = self.properties.maxTime
        tick.blackboard:set('startTime', startTime, tick.tree.id, self.id)
    end

    function maxTime:tick(tick)
        if not self.child then
            return B3.ERROR
        end

        local currTime = Timer.GetTimeMillisecond()
        local startTime = tick.blackboard.get('startTime', tick.tree.id, self.id)

        local status = self.child:_execute(tick)
        if currTime - startTime > self.maxTime then
            return B3.FAILURE
        end

        return status
    end

    -------------Limiter
    ---@class Limiter:Decorator
    local limiter = B3.Class('Limiter', B3.Decorator)
    B3.Limiter = limiter

    function limiter:ctor()
        B3.Decorator.ctor(self)

        self.name = 'Limiter'
        self.title = 'Limit <maxLoop> Activations'
        self.parameters = {maxLoop = 1}
    end

    function limiter:open(tick)
        tick.blackboard.set('i', 0, tick.tree.id, self.id)
        self.maxLoop = self.properties.maxLoop
    end

    function limiter:tick(tick)
        if not self.child then
            return B3.ERROR
        end

        local i = tick.blackboard:get('i', tick.tree.id, self.id)

        if i < self.maxLoop then
            local status = self.child:_execute(tick)

            if status == B3.SUCCESS or status == B3.FAILURE then
                tick.blackboard:set('i', i + 1, tick.tree.id, self.id)
            end

            return status
        end

        return B3.FAILURE
    end
end

return DecoratorNode
