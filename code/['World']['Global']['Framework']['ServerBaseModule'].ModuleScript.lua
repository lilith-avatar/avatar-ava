--- 服务器模块基础类, Server Module Base Class
-- @module ServerBase, Server-side
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
local ServerBase = class('ServerBase')

function ServerBase:GetSelf()
    return self
end

--- 加载的时候运行的代码
function ServerBase:InitDefault(_module)
    -- print(string.format('InitDefault:%s', self.name))
    -- 初始化默认监听事件
    EventUtil.LinkConnects(world.S_Event, _module, self)
end

return ServerBase
