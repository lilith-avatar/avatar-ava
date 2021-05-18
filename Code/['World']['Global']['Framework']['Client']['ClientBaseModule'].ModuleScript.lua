--- 客户端模块基础类, Client Module Base Class
-- @module ClientBase, Client-side
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
local ClientBase = class('ClientBase')

function ClientBase:GetSelf()
    return self
end

--- 加载的时候运行的代码
function ClientBase:InitDefault(_module)
    -- --print(string.format('[ClientBase][%s] InitDefault()', self.name))
    -- 初始化默认监听事件
    EventUtil.LinkConnects(localPlayer.C_Event, _module, self)
end

--- Debug模式下打印日志
-- self.debug 针对模块本身的debug开关
-- FrameworkConfig.DebugMode 框架中的全局debug开关
function ClientBase:Log(...)
    if self.debug and FrameworkConfig.DebugMode then
        --print(string.format('[%s]', self.name), ...)
    end
end

return ClientBase
