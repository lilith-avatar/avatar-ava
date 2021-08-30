--- 时间管理器模块
--- @module Module Time Manager
--- @copyright Lilith Games, Avatar Team
--- @author Bingyun Chen, Yuancheng Zhang
--- @see the functions defined by JavaScript syntax

local TimeUtil = {}

-- All registered events
local eventList = {}

-- Current active event list
local activeEvents = {}

local running = false

-- Set update delta time
local DELTA_TIME = .05

local tid = 0

--- Find all registered events to trigger
local function CheckEvents()
    -- now = os.time()
    local now = Timer.GetTime()
    for k, event in pairs(eventList) do
        if event.triggerTime <= now then
            activeEvents[event.id] = event
            table.insert(activeEvents, event)
            if event.loop then
                event.triggerTime = event.triggerTime + event.delay
            else
                eventList[k] = nil
            end
        end
    end
end

--- Trigger events
local function TriggerEvents()
    for k, event in pairs(activeEvents) do
        invoke(
            function()
                event.func()
            end
        )
        activeEvents[k] = nil
    end
    assert(next(activeEvents) == nil, string.format('[TimeUtil] 有未执行的事件%s个', table.nums(activeEvents)))
end

--- Update
local function StartUpdate()
    while running and wait(DELTA_TIME) do
        -- print(Timer.GetTime(), os.time())
        CheckEvents()
        TriggerEvents()
    end
end

--- Initialization
function TimeUtil.Init()
    TimeUtil.Start()
end

--- Run Update()
function TimeUtil.Start()
    if running then
        return
    end
    running = true
    invoke(StartUpdate)
end

--- Stop Update()
--- @param _clear bool clear remain events
function TimeUtil.Stop(_clear)
    running = false
    if _clear then
        eventList = {}
    end
end

--- Call a function after a specified number of milliseconds,
--- use ClearTimeout() method to prevent the function from running
--- @param _func execution function to call
--- @param _delayTime
--- @return timer id
--- @see https://www.w3schools.com/jsref/met_win_settimeout.asp
function TimeUtil.SetTimeout(_func, _seconds)
    assert(_func, '[TimeUtil] TimeUtil.SetTimeout() _func 不能为空')
    assert(type(_func) == 'function', '[TimeUtil] TimeUtil.SetTimeout() _func 类型不是function')
    assert(_seconds >= 0, '[TimeUtil] TimeUtil.SetTimeout() 延迟时间需大于等于0')
    if _seconds == 0 then
        print('[TimeUtil] TimeUtil.SetTimeout() 事件立即执行')
        invoke(_func)
        return
    end
    local timestamp = _seconds + Timer.GetTime()
    tid = tid + 1
    eventList[tid] = {
        id = tid,
        func = _func,
        delay = _seconds,
        triggerTime = timestamp
    }

    return tid
end

--- Call a function or evaluates an expression at specified intervals (in milliseconds),
--- the method will continue calling the function until ClearInterval() is called, or the game is over.
--- @param _func execution function to call
--- @param _delayTime
--- @return timer id
--- @see https://www.w3schools.com/jsref/met_win_setinterval.asp
function TimeUtil.SetInterval(_func, _seconds)
    assert(_func, '[TimeUtil] TimeUtil.SetInterval() _func 不能为空')
    assert(type(_func) == 'function', '[TimeUtil] TimeUtil.SetInterval() _func 类型不是function')
    assert(_seconds > 0, '[TimeUtil] TimeUtil.SetInterval() 延迟时间需大于0')
    local timestamp = _seconds + Timer.GetTime()
    tid = tid + 1
    eventList[tid] = {
        id = tid,
        func = _func,
        delay = _seconds,
        triggerTime = timestamp,
        loop = true
    }
    return tid
end

--- Clear a timer set with the SetTimeout() method
--- @param _tid timmer id
--- @see https://www.w3schools.com/jsref/met_win_cleartimeout.asp
function TimeUtil.ClearTimeout(_tid)
    eventList[_tid] = nil
end

--- Clear a timer set with the SetInterval() method, used as ClearTimeout()
--- @see https://www.w3schools.com/jsref/met_win_clearinterval.asp
TimeUtil.ClearInterval = TimeUtil.ClearTimeout

--! TEST ONLY blow

-- Get current timer id
TimeUtil.GetTimerId = function()
    return tid
end

--[[
    print(TimeUtil.GetTimerId())
]]
return TimeUtil
