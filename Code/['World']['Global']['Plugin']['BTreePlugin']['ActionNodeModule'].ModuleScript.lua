--- @module Action Node 行为树行动节点
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local ActionNode = {}

function ActionNode:Init()
    -------------Action---------------------
    ---@class Action : BaseNode
    local action = B3.Class('Action', B3.BaseNode)
    B3.Action = action

    function action:ctor()
        B3.BaseNode.ctor(self)

        self.category = B3.ACTION
    end

    --Action=========Runner==========
    local runner = B3.Class('Runner', B3.Action)
    B3.Runner = runner

    function runner:ctor()
        B3.Action.ctor(self)

        self.name = 'Runner'
    end

    function runner:tick(tick)
        --print(self.title)
        --print(table.dump(self.properties))
        return B3.RUNNING
    end

    --Action========Error======
    local error = B3.Class('Error', B3.Action)
    B3.Error = error

    function error:ctor()
        B3.Action.ctor(self)

        self.name = 'Error'
    end

    function error:tick()
        return B3.ERROR
    end

    --Action========Failer======
    local failer = B3.Class('Failer', B3.Action)
    B3.Failer = failer

    function failer:ctor()
        B3.Action.ctor(self)

        self.name = 'Failer'
    end

    function failer:tick()
        return B3.FAILURE
    end

    --action=======Succeeder=====
    local succeeder = B3.Class('Succeeder', B3.Action)
    B3.Succeeder = succeeder

    function succeeder:ctor()
        B3.Action.ctor(self)

        self.name = 'Succeeder'
    end

    function succeeder:tick(tick)
        return B3.SUCCESS
    end

    --action=======Wait=====
    local mwait = B3.Class('Wait', B3.Action)
    B3.Wait = mwait

    function mwait:ctor()
        B3.Action.ctor(self)

        self.name = 'Wait'
    end

    function mwait:open(tick)
        local startTime = Timer.GetTimeMillisecond()
        self.endTime = self.properties.milliseconds
        tick.blackboard:set('startTime', startTime, tick.tree.id, self.id)
    end

    function mwait:tick(tick)
        local currTime = Timer.GetTimeMillisecond()
        local startTime = tick.blackboard:get('startTime', tick.tree.id, self.id)

        if not startTime or startTime == 0 then
            startTime = currTime
            tick.blackboard:set('startTime', currTime, tick.tree.id, self.id)
        end

        --print(self.endTime)
        if currTime - startTime > self.endTime then
            return B3.SUCCESS
        end

        return B3.RUNNING
    end
end

return ActionNode
