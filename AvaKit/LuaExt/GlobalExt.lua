--- 提供一组常用函数，以及对 Lua 标准库的扩展
--- @module Lua global function extension libraries
--- @copyright Lilith Games, Avatar Team

--- 检查并尝试转换为数值，如果无法转换则返回 0
--- @param mixed value 要检查的值
--- @param [integer base] 进制，默认为十进制
--- @return number
_G.checknumber = function(value, base)
    return tonumber(value, base) or 0
end

--- 检查是否是有效的number类型
--- @param number
_G.isValidNumber = function(num)
    return num ~= nil and num > 0
end

--- 检查并尝试转换为整数，如果无法转换则返回 0
--- @param mixed value 要检查的值
--- @return integer
_G.checkint = function(value)
    return math.floor(checknumber(value) + 0.5)
end

--- 检查并尝试转换为布尔值，除了 nil 和 false，其他任何值都会返回 true
--- @param mixed value 要检查的值
--- @return boolean
_G.checkbool = function(value)
    return (value ~= nil and value ~= false)
end

--- 检查值是否是一个表格，如果不是则返回一个空表格
--- @param mixed value 要检查的值
--- @return table
_G.checktable = function(value)
    if type(value) ~= 'table' then
        value = {}
    end
    return value
end

--- 处理对象
--- @param mixed obj Lua 对象
--- @param function method 对象方法
--- @return function
_G.handler = function(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

return 0
