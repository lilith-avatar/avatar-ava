--- 样例模块(看后删掉)
-- @module Module Example A
-- @copyright Lilith Games, Avatar Team
-- @author XXX, XXXX
local ExampleA, this = {}, nil

--- 初始化
function ExampleA:Init()
    print('[信息] ExampleA:Init')
    this = self
    self:InitListeners()
end

--- 初始化Game Manager自己的监听事件
function ExampleA:InitListeners()
    EventUtil.LinkConnects(world.S_Event, ExampleA, 'ExampleA', this)
end

--- Update函数
-- @param dt delta time 每帧时间
function ExampleA:Update(dt)
    --print(string.format('[测试] 模块:%s, deltaTime = %.4f', 'ExampleA', dt))
end

return ExampleA
