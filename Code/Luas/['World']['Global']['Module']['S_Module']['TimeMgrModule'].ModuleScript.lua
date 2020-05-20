--- 时间管理器模块
-- @module Module Time Manager
-- @copyright Lilith Games, Avatar Team
-- @author Bingyun Chen
local TimeMgr, this =
    {
        isRun = false,
        baseTime = 0
    },
    nil

local eventList = {}
local activeEvents = math.huge
local clock = os.clock -- 缓存，用于lua优化
local id = 0
local now
local run = false
local updateTime = 1 --每1秒更新一次

--- 初始化
function TimeMgr:Init()
    info('TimeMgr:Init')
    self.baseTime = clock()
    this = self
end

function TimeMgr:SetTimeout(_seconds, _func)
    return RegisterEvent(false, _seconds, _func)
end

function TimeMgr:SetInterval(_seconds, _func)
    return RegisterEvent(true, _seconds, _func)
end

--- Update函数
-- @param dt delta time 每帧时间
function TimeMgr:Update(dt)
    now = clock()
    if activeEvents < now then --如果最小的ctiveEvents(触发时间)小于当前时间,则触发事件.
        TriggerEvents()
        FindNextEvent()
    end
end

--- CancelEvent删除需要触发的事件
-- @param Int _id 需要取消的事件id
function TimeMgr:CancelEvent(_id)
    for i, v in pairs(eventList) do
        for j = #v, 1, -1 do
            if v[j].eid == _id then
                --print(string.format('删除了eid为: %s 的事件',v[j].eid))
                table.remove(v, j)
            end
        end
    end
end

--- StartUpdate 运行TimeMgr
function TimeMgr:StartUpdate()
    run = true
    local update = function()
        while run and wait(updateTime) do
            TimeMgr:Update()
        end
    end
    invoke(update)
end

--- StopUpdate 停止TimeMgr更新
-- @param bool Cleareventlist true为删除eventlist里的所有事件
function TimeMgr:StopUpdate(_Cleareventlist)
    if _Cleareventlist then
        for i, v in pairs(eventList) do
            for j = #v, 1, -1 do
                table.remove(v, j)
            end
        end
    end
    run = false
end

-----------------------------------------------------主要函数-----------------

--- RegisterEvent函数 将事件插入时间线队列中,并返回该事件的id
-- @param bool  _IsLoop 是否循环触发 true就会根据当前时间 每_dlyt秒触发一次
-- @param float	_seconds 延迟时间 单位s
-- @param _function 需要触发的函数
function RegisterEvent(_IsLoop, _seconds, _func)
    now = clock()
    if _func == nil then
        print('[错误] TimeMgr.SetTimeout() _func 不能为空')
        return
    elseif _seconds < 1 then
        print('[错误] TimeMgr.SetTimeout() _seconds 最小时间单位是1s')
        return
    end
    local actt = nil --重置主键
    actt = now + _seconds --该事件的主键
    id = id + 1
    AddtoEventList(actt)[#eventList[actt] + 1] = {Isl = _IsLoop, delay = _seconds, func = _func, eid = id} --将事件插到eventList里面
    return id --返回该事件的id
end

--- ActiveEvent 函数 触发队列最前的事件
function TriggerEvents()
    local curEvent = eventList[activeEvents]
    for i, v in ipairs(curEvent) do --触发该时间内所有队列中的事件
        invoke(curEvent[i].func)
        if curEvent[i].Isl then --循环事件会在触发后移动到新主键位置
            local nextRound = activeEvents + curEvent[i].delay
            AddtoEventList(nextRound)[#eventList[nextRound] + 1] = curEvent[i]
        end
    end
    eventList[activeEvents] = nil --将已触发的时间段的整个队列删除
end

--- FindNextEvent 函数 寻找触发时间最小的表
function FindNextEvent()
    activeEvents = math.huge
    for i, v in pairs(eventList) do --寻找下一个最近发生的事件队列
        if i < activeEvents then
            activeEvents = i
        end
    end
end

--- 在eventlist里面生成对应的主键
function AddtoEventList(_actt)
    if eventList[_actt] == nil then --如果该时间没有需要触发的事件序列,则创建一个
        eventList[_actt] = {}
        if activeEvents > _actt then --如果距离该事件发生的时间是最快的,则将最快发生时间更新
            activeEvents = _actt
        end
    end
    return eventList[_actt]
end

--------------------------------------------------------------

return TimeMgr
