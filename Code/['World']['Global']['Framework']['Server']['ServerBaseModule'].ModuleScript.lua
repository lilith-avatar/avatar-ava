--- 服务器模块基础类, Server Module Base Class
-- @module ServerBase, Server-side
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang, Dead Ratman
local ServerBase = class('ServerBase')

function ServerBase:GetSelf()
    return self
end

--- 加载的时候运行的代码
function ServerBase:InitDefault(_module)
    -- print(string.format('[ServerBase][%s] InitDefault()', self.name))
    -- 初始化默认监听事件
    EventUtil.LinkConnects(world.S_Event, _module, self)
end

--- Debug模式下打印日志
-- self.debug 针对模块本身的debug开关
-- FrameworkConfig.DebugMode 框架中的全局debug开关
function ServerBase:Log(...)
    if self.debug and FrameworkConfig.DebugMode then
        print(string.format('[%s]', self.name), ...)
    end
end

return ServerBase
