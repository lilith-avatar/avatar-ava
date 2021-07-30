--- @module Custom Node 行为树自定义节点
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma

local CustomNode = {}
function CustomNode:Init()
    local statusCheck = B3.Class('StatusCheck', B3.Condition)
    B3.StatusCheck = statusCheck

    function statusCheck:ctor()
        B3.Condition.ctor(self)
        self.name = 'StatusCheck'
    end

    function statusCheck:tick(tick)
        return tick.target:StatusCheck(B3, self)
    end

    local heroAction = B3.Class('HeroAction', B3.Action)
    B3.HeroAction = heroAction

    function heroAction:ctor()
        B3.Action.ctor(self)
        self.name = 'HeroAction'
    end

    function heroAction:tick(tick)
        --print(type(tick))
        return tick.target:HeroAction(B3, self)
    end
end

return CustomNode
