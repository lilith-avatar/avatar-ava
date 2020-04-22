--- 事件绑定工具
-- @module Event Connects Handler
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
local EventUtil = {}

--- 遍历所有的events,找到module中对应名称的handler,建立Connect
-- @param _eventFolder 事件所在的节点folder
-- @param _module 模块
-- @param _moduleName module的名字,用于打印日志
-- @param _this module的self指针,用于闭包
function EventUtil.LinkConnects(_eventFolder, _module, _moduleName, _this)
    local events = _eventFolder:GetChildren()
    local total = 0
    for _, ent in pairs(events) do
        if string.endswith(ent.Name, 'Event') then
            local handler = _module[ent.Name .. 'Handler']
            if handler ~= nil then
                ent:Connect(
                    function(...)
                        handler(_this, ...)
                    end
                )
                print(string.format('[信息] %s/%s 事件绑定%s成功', _eventFolder.Name, ent.Name, _moduleName))
                total = total + 1
            end
        else
            print(string.format('[警告] S_Event/%s 命名没有以Event结尾', ent.Name))
        end
    end
    print(string.format('[信息] %s共绑定%s个事件', _moduleName, total))
end

return EventUtil
