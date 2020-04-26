--- 样例模块(看后删掉)
-- @module Module Example A
-- @copyright Lilith Games, Avatar Team
-- @author XXX, XXXX
local ExampleB, this = {}, nil

--- 初始化
function ExampleB:Init()
    print('[信息] ExampleB:Init')
    this = self
    self:InitListeners()
end

--- 初始化Game Manager自己的监听事件
function ExampleB:InitListeners()
    EventUtil.LinkConnects(localPlayer.C_Event, ExampleB, 'ExampleB', this)
end

--- Update函数
-- @param dt delta time 每帧时间
function ExampleB:Update(dt)
    --print(string.format('[测试] 模块:%s, deltaTime = %.4f', 'ExampleB', dt))
end

--- TEST ONLY 处理Example02CustomEvent事件
-- 函数命名格式为 事件名 + 'Handler'
function ExampleB:Example02CustomEventHandler(arg1)
    print('[信息] 收到Example02CustomEvent, 参数:', arg1)
    localPlayer.Local.FUNC_UIAnimation.StartAnimationEvent:Fire('TestAnimation')
end

return ExampleB
