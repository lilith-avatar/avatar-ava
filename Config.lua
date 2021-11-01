--- 框架默认配置
--- @module Framework Global FrameworkConfig
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local FrameworkConfig = {
    --! Debug模式
    DebugMode = true,
    -- 启动心跳
    HeartbeatStart = true,
    -- 启动数据同步
    DataSyncStart = true,
    -- DataSyncStart = false,
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
        HeartbeatThreshold2 = 10
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
        HeartbeatThreshold2 = 10
    },
    --! Debug相关
    Debug = {
        -- 显示心跳日志
        ShowHeartbeatLog = false,
        -- 显示数据同步日志
        ShowDataSyncLog = true
    }
}

return FrameworkConfig
