--- @module Condition Node 行为树条件节点
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local ConditionNode = {}

function ConditionNode:Init()
    ----------------------Condition-------------------
    ---@class Condition : baseNode
    local condition = B3.Class('Condition', B3.BaseNode)
    B3.Condition = condition

    function condition:ctor(params)
        B3.BaseNode.ctor(self, params)
    end
end

return ConditionNode
