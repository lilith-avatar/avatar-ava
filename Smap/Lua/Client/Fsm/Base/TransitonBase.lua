--- 状态机过渡基类
--- @module TransitonBase
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local TransitonBase = class('TransitonBase')

function TransitonBase:initialize(_transitonName, _nextState, _dur)
    --print(_transitonName, 'initialize()')
    self.transitonName = _transitonName
    self.nextState = _nextState
    self.dur = _dur or -1
    self.curTime = 0
    self.conditions = {}
end

--初始化条件
function TransitonBase:InitConditions(...)
    for k, v in pairs({...}) do
        table.insert(self.conditions, v)
    end
end

--变化更新
function TransitonBase:GetTransState(dt)
    if self.dur ~= -1 then
        if self.curTime < self.dur then
            self.curTime = self.curTime + dt
        else
            self.curTime = 0
            return self.nextState
        end
    end
    for k, v in pairs(self.conditions) do
        if v() then
            self.curTime = 0
            return self.nextState
        end
    end
    return nil
end

--重置
function TransitonBase:Reset()
    self.curTime = 0
end

return TransitonBase
