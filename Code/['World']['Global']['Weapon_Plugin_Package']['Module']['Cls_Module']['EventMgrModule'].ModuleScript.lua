--- @module EventMgr 枪械模块：事件管理
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local EventMgr = class('EventMgr')

---EventMgr类的构造函数
function EventMgr:initialize(_name, _sender)
    self.name = _name
    self.sender = _sender
    self.receivers = {}
end

---事件绑定
function EventMgr:Bind(_receiver)
    if _receiver then
        assert(
            type(_receiver) == 'function',
            'attempt to bind ' .. type(_receiver) .. " into receivers(require 'function')"
        )
        table.insert(self.receivers, _receiver)
    end
end

function EventMgr:Trigger(...)
    local param = table.pack(...)
    for _, _receiver in ipairs(self.receivers) do
        invoke(
            function()
                _receiver(self.sender, table.unpack(param))
            end
        )
    end
end

function EventMgr:Clear()
    self.receivers = {}
end

return EventMgr
