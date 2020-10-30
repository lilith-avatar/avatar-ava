--- 框架配置
--- @module Framework Global FrameworkConfig
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local FrameworkConfig = {
    Server = {
        -- 心跳包间隔时间，单位：秒
        HeartbeatDelta = 1,
        -- 心跳阈值，单位：秒，范围定义如下：
        --          0s -> threshold_1   : connected
        -- threshold_1 -> threshold_2   : disconnected, but player can rejoin
        -- threshold_2 -> longer        : disconnected, remove player
        HeartbeatThreshold1 = 5,
        HeartbeatThreshold2 = 15,
        -- 显示心跳日志
        ShowHeartbeatLog = true
    },
    Client = {
        -- 心跳包间隔时间，单位：秒
        HeartbeatDelta = 1,
        -- 心跳阈值，单位：秒，范围定义如下：
        --          0s -> threshold_1   : connected
        -- threshold_1 -> threshold_2   : disconnected, weak network
        -- threshold_2 -> longer        : disconnected, quit server
        HeartbeatThreshold1 = 5,
        HeartbeatThreshold2 = 15,
        -- 显示心跳日志
        ShowHeartbeatLog = true
    }
}

return FrameworkConfig
