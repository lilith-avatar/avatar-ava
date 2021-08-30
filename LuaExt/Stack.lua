--- Lua数据结构：Stack（栈）
-- @module Lua data structure: stack
-- @copyright Lilith Games, Avatar Team
-- @author Chengzhi

--- 数据结构 栈
-- @usage example
-- local myStack = Stack:New()
-- myStack:Push("a")
-- myStack:Push("b")
-- myStack:Push("c")
-- myStack:PrintElement()
-- print(myStack:Pop())
-- myStack:PrintElement()
-- myStack:Clear()
-- myStack:PrintElement()
local Stack = {}

function Stack:New()
    local inst = {
        _last = 0,
        _stack = {}
    }
    setmetatable(inst, {__index = self})

    return inst
end

function Stack:IsEmpty()
    if self._last == 0 then
        return true
    end
    return false
end

function Stack:Push(inElement)
    self._last = self._last + 1
    self._stack[self._last] = inElement
end

function Stack:Pop()
    if self:IsEmpty() then
        --print("Error: the stack is empty")
        return
    end
    local value = self._stack[self._last]
    self._stack[self._last] = nil
    self._last = self._last - 1
    return value
end

function Stack:Exists(element, compairFunc)
    if compairFunc == nil then
        compairFunc = function(a, b)
            return a == b
        end
    end
    for i = self._last, 1, -1 do
        if compairFunc(element, self._stack[i]) then
            return i
        end
    end
    return -1
end

function Stack:RemoveAt(index)
    if index < 1 or index > self._last then
        return
    end
    table.remove(self._stack, index)
    self._last = self._last - 1
end

function Stack:Clear()
    self._stack = nil
    self._stack = {}
    self._last = 0
end

function Stack:Size()
    return self._last
end

function Stack:PrintElement()
    local str = '{'
    for i = self._last, 1, -1 do
        str = str .. tostring(self._stack[i]) .. ','
    end
    str = str .. '}'
    print(str)
end

return Stack
