--- Lua常用数学库扩展
--- @module Lua math function extension libraries
--- @copyright Lilith Games, Avatar Team

--- 两点间距离
--- @author xuyue
--- @param _vec1 Vector3
--- @param _vec1 Vector3
math.Distance = function(_vec1, _vec2)
    return math.sqrt((_vec1.x - _vec2.x) ^ 2 + (_vec1.y - _vec2.y) ^ 2 + (_vec1.z - _vec2.z) ^ 2)
end

--- 四舍五入
--- @param a number
--- @return a round number
math.round = function(value)
    return math.floor(value + 0.5)
end

--- [0, 1]区间限定函数
--- @param a number
--- @return a clamped number
math.clamp01 = function(value)
    return math.min(1, math.max(0, value))
end

--- 高斯随机变量
--- @author DaiAn
math.GaussRandom = function()
    local u = math.random()
    local v = math.random()
    local z = math.sqrt(-2 * math.log(u)) * math.cos(2 * math.pi * v)
    z = (z + 3) / 6
    z = 2 * z - 1
    if (math.abs(z) > 1) then
        return math.GaussRandom()
    end
    return z
end

return 0
