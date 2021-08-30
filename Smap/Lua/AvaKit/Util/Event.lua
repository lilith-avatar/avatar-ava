--- 事件绑定工具
--- @module Event Connects Handler
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang, Yen Yuan
local EventUtil = {}

--- 检查是否为Json化的字符串
--- @param _str @string 输入的字符串
--- @return @boolean true: json table string
local function IsJsonTable(_str)
    return type(_str) == 'string' and string.endswith(_str, 'JSON') and string.startswith(_str, 'JSON')
end

--- 处理Handler的传入参数
--- @param variable args
--- @return variable args
local function ArgsAux(...)
    local _s = {...}
    for k, v in pairs(_s) do
        if IsJsonTable(v) then
            local json = string.sub(v, 5, -5)
            _s[k] = JSON:decode(json)
        end
    end
    return table.unpack(_s)
end

--- 遍历所有的events,找到module中对应名称的handler,建立Connect
--- @param _eventFolder 事件所在的节点folder
--- @param _module 模块
--- @param _this module的self指针,用于闭包
function EventUtil.LinkConnects(_eventFolder, _module, _this)
    assert(
        _eventFolder and _module and _this,
        string.format('[EventUtil] 参数有空值: %s, %s, %s', _eventFolder, _module, _this)
    )
    local events = _eventFolder:GetChildren()
    for _, evt in pairs(events) do
        if string.endswith(evt.Name, 'Event') then
            local handler = _module[evt.Name .. 'Handler']
            if handler ~= nil then
                -- print('[EventUtil]', _eventFolder, _module, evt)
                evt:Connect(
                    function(...)
                        handler(_this, ArgsAux(...))
                    end
                )
            end
        end
    end
end

return EventUtil
