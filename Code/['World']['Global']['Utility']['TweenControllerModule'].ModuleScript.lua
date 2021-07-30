--- 控制某个变量随时间变化的协程类
--- @module TweenController
--- @copyright Lilith Games, Avatar Team
--- @author An Dai
local TweenController = class('TweenController')

---_name:类名，_sender：使用它的类，_getTotalTime:获得总时间的方法，_update _callback:回调函数 _isFix：是否在fixupdate中执行， _start: 开始函数
function TweenController:initialize(_name, _sender, _getTotalTime, _update, _callback, _isFix, _start)
    _start = _start or function()
            return
        end

    local updateStr = (_isFix and 'Fix' or '') .. 'Update'

    self.Start = function(self)
        _start()
        self.totalTime = _getTotalTime()
        self.time = 0
        _sender[updateStr .. 'Table'][_name] = self
    end

    self[updateStr] = function(self, _dt)
        self.time = self.time + _dt
        if (self.time > self.totalTime) then
            self:Stop()
            goto UpdateReturn
        end
        _update(self.time, self.totalTime, _dt)
        ::UpdateReturn::
    end

    self.Stop = function(self)
        _sender[updateStr .. 'Table'][_name] = nil
        _callback()
    end
end

return TweenController
