--- Lua数据结构：Queue（队列）
-- @module Lua data structure: queue
-- @copyright Lilith Games, Avatar Team
-- @author Chengzhi

--- 数据结构 队列
-- @usage queue example
-- local myQueue = Queue:New()
-- myQueue:Enqueue('a')
-- myQueue:Enqueue('b')
-- myQueue:Enqueue('c')
-- myQueue:PrintElement()
-- print(myQueue:Dequeue())
-- myQueue:PrintElement()
-- myQueue:Clear()
-- myQueue:PrintElement()
local Queue = {}

function Queue:New()
    local inst = {
        _first = -1,
        _last = -1,
        _size = 0,
        _queue = {}
    }
    setmetatable(inst, {__index = self})
    return inst
end

function Queue:IsEmpty()
    if self._size == 0 then
        return true
    end
    return false
end

function Queue:Enqueue(inElement)
    if self._size == 0 then
        self._first = 0
        self._last = 1
        self._size = 1
        self._queue[self._last] = inElement
    else
        self._last = self._last + 1
        self._queue[self._last] = inElement
        self._size = self._size + 1
    end
end

function Queue:Dequeue()
    if self:IsEmpty() then
        print('Error: the queue is empty')
        return
    end
    self._size = self._size - 1
    self._first = self._first + 1
    local value = self._queue[self._first]
    return value
end

function Queue:Clear()
    self._queue = nil
    self._queue = {}
    self._size = 0
    self._first = -1
    self._last = -1
end

function Queue:Size()
    return self._size or 0
end

function Queue:PrintElement()
    if self._size == 0 then
        print('{}')
    else
        local f = self._first + 1
        local l = self._last
        local str
        local flag = true
        while f ~= l do
            if flag == true then
                str = '{' .. tostring(self._queue[f])
                f = f + 1
                flag = false
            else
                str = str .. ',' .. tostring(self._queue[f])
                f = f + 1
            end
        end
        str = str .. ',' .. tostring(self._queue[l]) .. '}'
        print(str)
    end
end

function Queue:GetValue(index)
    if self:IsEmpty() or index == nil or index == 0 then
        print('Error: Get Value Failure!')
        return
    end
    if index > 0 then
        return self._queue[self._first + index]
    else
        return self._queue[self._last + index + 1]
    end
end

function Queue:GetValues()
    if self:IsEmpty() then
        return
    end
    local data = {}
    for i = self._first + 1, self._last, 1 do
        data[#data + 1] = self._queue[i]
    end
    return data
end

return Queue
