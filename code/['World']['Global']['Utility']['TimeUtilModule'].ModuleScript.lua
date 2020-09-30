--- 时间管理器模块
-- @module Module Time Manager
-- @copyright Lilith Games, Avatar Team
-- @author Bingyun Chen, Yuancheng Zhang
-- @see the functions defined by JavaScript syntax

local TimeUtil = {}

-- All registered events
local eventList = {}

-- Current active event list
local activeEvents = {}

local running = false

-- Set update delta time
local DELTA_TIME = .05

--- Find all registered events to trigger
local function CheckEvents()
    -- now = os.time()
    local now = Timer.GetTimeMillisecond()
    local i, event = 1
    while i <= #eventList do
        event = eventList[i]
        if event.triggerTime <= now then
            table.insert(activeEvents, event)
            if event.loop then
                event.triggerTime = event.triggerTime + event.delay
                i = i + 1
            else
                table.remove(eventList, i)
            end
        else
            i = i + 1
        end
    end
end

--- Trigger events
local function TriggerEvents()
    local i = 1
    while i <= #activeEvents do
        event = activeEvents[i]
        invoke(event.func)
        table.remove(activeEvents, i)
    end
end

--- Update
local function Update()
    while running do
        -- print(os.time())
        CheckEvents()
        TriggerEvents()
        wait(DELTA_TIME)
    end
end

--- Initialization
function TimeUtil.Init()
    TimeUtil.Start()
end

--- Run Update()
function TimeUtil.Start()
    running = true
    invoke(Update)
end

--- Stop Update()
function TimeUtil.Stop()
    running = false
end

--- Call a function after a specified number of milliseconds,
-- use ClearTimeout() method to prevent the function from running
-- @param _func execution function to call
-- @param _delayTime
-- @return timer id
-- @see https://www.w3schools.com/jsref/met_win_settimeout.asp
function TimeUtil.SetTimeout(_func, _seconds)
    if _func == nil then
        error('TimeUtil.SetTimeout() _func 不能为空')
        return
    elseif _seconds < 0 then
        error('TimeUtil.SetTimeout() 延迟时间需大于等于0')
        return
    elseif _seconds == 0 then
        print('TimeUtil.SetTimeout() 事件立即执行')
        invoke(_func)
        return
    end
    local id = #eventList + 1
    -- convert to milliseconds
    local ms = math.floor(_seconds * 1000)
    local timestamp = ms + Timer.GetTimeMillisecond()
    table.insert(
        eventList,
        {
            id = id,
            func = _func,
            delay = ms,
            triggerTime = timestamp
        }
    )
    return id
end

--- Call a function or evaluates an expression at specified intervals (in milliseconds),
-- the method will continue calling the function until ClearInterval() is called, or the game is over.
-- @param _func execution function to call
-- @param _delayTime
-- @return timer id
-- @see https://www.w3schools.com/jsref/met_win_setinterval.asp
function TimeUtil.SetInterval(_func, _seconds)
    if _func == nil then
        error('TimeUtil.SetInterval() _func 不能为空')
        return
    elseif _seconds <= 0 then
        error('TimeUtil.SetInterval() 延迟时间需大于0')
        return
    end
    local id = #eventList + 1
    -- convert to milliseconds
    local ms = math.floor(_seconds * 1000)
    local timestamp = ms + Timer.GetTimeMillisecond()
    table.insert(
        eventList,
        {
            id = id,
            func = _func,
            delay = ms,
            triggerTime = timestamp,
            loop = true
        }
    )
    return id
end

--- Clear a timer set with the SetTimeout() method
-- @param _id timmer id
-- @see https://www.w3schools.com/jsref/met_win_cleartimeout.asp
function TimeUtil.ClearTimeout(_id)
    for k, e in pairs(eventList) do
        if e.id == _id then
            table.remove(eventList, k)
            break
        end
    end
end

--- Clear a timer set with the SetInterval() method, used as ClearTimeout()
-- @see https://www.w3schools.com/jsref/met_win_clearinterval.asp
TimeUtil.ClearInterval = TimeUtil.ClearTimeout

return TimeUtil
