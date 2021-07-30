--- @module Composite Node 行为树复合节点
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local CompositeNode = {}

function CompositeNode:Init()
    --------------------Composite---------------------
    local composite = B3.Class('Composite', B3.BaseNode)
    B3.Composite = composite

    function composite:ctor(params)
        self.children = (params and params.children) or {}
    end

    --Composite==========Sequence=================
    local sequence = B3.Class('Sequence', B3.Composite)
    B3.Sequence = sequence

    function sequence:ctor()
        B3.Composite.ctor(self)

        self.name = 'Sequence'
    end

    function sequence:tick(tick)
        for i = 1, #self.children do
            local v = self.children[i]
            local status = v:_execute(tick)
            --------print(i,v)
            if status ~= B3.SUCCESS then
                return status
            end
        end
        return B3.SUCCESS
    end

    --Composite==========MemSequence=================
    local memSequence = B3.Class('MemSequence', B3.Composite)
    B3.MemSequence = memSequence

    function memSequence:ctor()
        B3.Composite.ctor(self)

        self.name = 'MemSequence'
    end

    function memSequence:open(tick)
        tick.blackboard:set('runningChild', 1, tick.tree.id, self.id)
    end

    function memSequence:tick(tick)
        local child = tick.blackboard:get('runningChild', tick.tree.id, self.id)
        for i = child, #self.children do
            local v = self.children[i]
            local status = v:_execute(tick)

            if status ~= B3.SUCCESS then
                if status == B3.RUNNING then
                    tick.blackboard:set('runningChild', i, tick.tree.id, self.id)
                end

                return status
            end
        end

        return B3.SUCCESS
    end

    --Composite==========Priority=================
    local priority = B3.Class('Priority', B3.Composite)
    B3.Priority = priority

    function priority:ctor()
        B3.Composite.ctor(self)

        self.name = 'Priority'
    end

    function priority:tick(tick)
        for i, v in pairs(self.children) do
            local status = v:_execute(tick)

            if status ~= B3.FAILURE then
                return status
            end
        end

        return B3.FAILURE
    end

    --Composite==========MemPriority=================
    local memPriority = B3.Class('MemPriority', B3.Composite)
    B3.MemPriority = memPriority

    function memPriority:ctor()
        B3.Composite.ctor(self)

        self.name = 'MemPriority'
    end

    function memPriority:open(tick)
        tick.blackboard:set('runningChild', 1, tick.tree.id, self.id)
    end

    function memPriority:tick(tick)
        local child = tick.blackboard:get('runningChild', tick.tree.id, self.id)
        for i = child, #self.children do
            local v = self.children[i]
            local status = v:_execute(tick)

            if status ~= B3.FAILURE then
                if status == B3.RUNNING then
                    tick.blackboard:set('runningChild', i, tick.tree.id, self.id)
                end

                return status
            end
        end

        return B3.FAILURE
    end
end
return CompositeNode
