--- 样例模块(看后删掉)
-- @module Module Example B
-- @copyright Lilith Games, Avatar Team
-- @author XXX, XXXX
local ExampleB, this = {}, nil

--- 初始化
function ExampleB:Init()
    debug('ExampleB:Init')
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
    --debug(string.format('[测试] 模块:%s, deltaTime = %.4f', 'ExampleB', dt))
end

--- TEST ONLY 处理Test02ServerEvent事件
-- 函数命名格式为 事件名 + 'Handler'
function ExampleB:Test02ClientEventHandler(_animName)
    debug('收到Test02ClientEvent, 参数:', _animName)
    if type(_animName) == 'string' then
        localPlayer.C_Event.StartAnimationEvent:Fire(_animName)
    end
end

return ExampleB
