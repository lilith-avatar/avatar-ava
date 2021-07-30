--- 框架配置
--- @module FrameworkConfig Global FrameworkConfig
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local FrameworkConfig = {
    -- 是否为调试模式,开启后方法中的报错不会输出在控制台上,会直接显示在屏幕上
    DebugMode = false,
    -- 启动心跳
    HeartbeatStart = true,
    Server = {
        -- 心跳包间隔时间，单位：秒
        HeartbeatDelta = 2,
        -- 心跳阈值，单位：秒，范围定义如下：
        --          0s -> threshold_1   : connected
        -- threshold_1 -> threshold_2   : disconnected, but player can reconnect
        -- threshold_2 -> longer        : disconnected, remove player
        HeartbeatThreshold1 = 7,
        HeartbeatThreshold2 = 15,
        -- 显示心跳日志
        ShowHeartbeatLog = false,
        -- 插件中需要使用声明周期的服务器模块目录
        PluginModules = {},
        -- 插件中服务器需要生成的CustomEvent, 模块中必须得有ServerEvents
        PluginEvents = {}
    },
    Client = {
        -- 心跳包间隔时间，单位：秒
        HeartbeatDelta = 2,
        -- 心跳阈值，单位：秒，范围定义如下：
        --          0s -> threshold_1   : connected
        -- threshold_1 -> threshold_2   : disconnected, weak network, can reconnect
        -- threshold_2 -> longer        : disconnected, quit server
        HeartbeatThreshold1 = 7,
        HeartbeatThreshold2 = 15,
        -- 显示心跳日志
        ShowHeartbeatLog = false,
        -- 插件中需要使用声明周期的客户端模块目录
        PluginModules = {},
        -- 插件中客户端需要生成的CustomEvent，模块中必须得有ClientEvents
        PluginEvents = {}
    }
}

return FrameworkConfig
