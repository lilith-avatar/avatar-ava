--- 框架配置
--- @module Framework Global FrameworkConfig
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local FrameworkConfig = {
    --! Debug模式
    DebugMode = true,
    -- 启动心跳
    HeartbeatStart = true,
    -- 长期存储：玩家数据定时保存时间间隔（秒）
    DatabaseAutoSaveTime = 30,
    -- 长期存储：重新读取游戏数据时间间隔（秒）
    DatabaseReloadTimeAfterFailed = 1,
    -- 服务器配置
    Server = {
        -- 心跳包间隔时间，单位：秒
        HeartbeatDelta = 1,
        -- 心跳阈值，单位：秒，范围定义如下：
        --          0s -> threshold_1   : connected
        -- threshold_1 -> threshold_2   : disconnected, but player can reconnect
        -- threshold_2 -> longer        : disconnected, remove player
        HeartbeatThreshold1 = 5,
        HeartbeatThreshold2 = 10,
        -- 插件中需要使用声明周期的服务器模块目录
        PluginModules = {},
        -- 插件中服务器需要生成的CustomEvent, 模块中必须得有ServerEvents
        PluginEvents = {}
    },
    -- 客户端配置
    Client = {
        -- 心跳包间隔时间，单位：秒
        HeartbeatDelta = 1,
        -- 心跳阈值，单位：秒，范围定义如下：
        --          0s -> threshold_1   : connected
        -- threshold_1 -> threshold_2   : disconnected, weak network, can reconnect
        -- threshold_2 -> longer        : disconnected, quit server
        HeartbeatThreshold1 = 5,
        HeartbeatThreshold2 = 10,
        -- 插件中需要使用声明周期的客户端模块目录
        PluginModules = {},
        -- 插件中客户端需要生成的CustomEvent，模块中必须得有ClientEvents
        PluginEvents = {}
    },
    --! Debug相关
    Debug = {
        -- 显示心跳日志
        ShowHeartbeatLog = false,
        -- 显示数据同步日志
        ShowDataSyncLog = false
    }
}

return FrameworkConfig
