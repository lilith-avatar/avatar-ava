--- 游戏心跳
--- @module Client Heartbeat, Client-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local ClientHeartbeat = {}

-- 心跳包间隔时间，单位：秒
local HEARTBEAT_DELTA = Ava.Config.Client.HeartbeatDelta

-- 心跳阈值，单位：秒，范围定义如下：
--          0s -> threshold_1   : connected
-- threshold_1 -> threshold_2   : disconnected, weak network
-- threshold_2 -> longer        : disconnected, quit server
local HEARTBEAT_THRESHOLD_1 = Ava.Config.Client.HeartbeatThreshold1 * 1000 -- second => ms
local HEARTBEAT_THRESHOLD_2 = Ava.Config.Client.HeartbeatThreshold2 * 1000 -- second => ms

--- 玩家心跳连接状态
local HeartbeatEnum = {
    CONNECT = 1, -- 在线
    DISCONNECT = 2 -- 离线
}

--- 正在运行
local running = false

--- 上一次服务器发来的心跳时间戳缓存
local cache = {
    sTimestamp = nil,
    cTimestamp = nil
}

--- 临时变量
local diff  -- 时间戳插值
local sTmpTs, cTmpTs  -- 时间戳缓存

--- 打印心跳日志
local PrintHb = Ava.DebugMode and Ava.Config.Debug.ShowHeartbeatLog and function(...)
        Debug.Log('[AvaKit][Heartbeat][Client]', ...)
    end or function()
    end

--! 外部接口

--- 初始化心跳包
function ClientHeartbeat.Init()
    Debug.Log('[AvaKit][Heartbeat][Client] Init()')
    CheckConfig()
    InitEventsAndListeners()
end

--- 开始发出心跳
function ClientHeartbeat.Start()
    Debug.Log('[AvaKit][Heartbeat][Client] Start()')
    local cTimestamp
    running = true
    while (running) do
        Update()
        wait(HEARTBEAT_DELTA)
    end
end

-- 停止心跳
function ClientHeartbeat.Stop()
    Debug.Log('[AvaKit][Heartbeat][Client] Stop()')
    running = false
end

--! 私有函数

--- 校验心跳参数
function CheckConfig()
    assert(HEARTBEAT_DELTA >= 1, '[AvaKit][Heartbeat][Client] HEARTBEAT_DELTA 必须大于1秒')
    assert(
        HEARTBEAT_THRESHOLD_1 >= HEARTBEAT_DELTA,
        '[AvaKit][Heartbeat][Client] HEARTBEAT_THRESHOLD_1 >= HEARTBEAT_DELTA'
    )
    assert(
        HEARTBEAT_THRESHOLD_2 >= HEARTBEAT_THRESHOLD_1,
        '[AvaKit][Heartbeat][Client] HEARTBEAT_THRESHOLD_2 >= HEARTBEAT_THRESHOLD_1'
    )
end

--- 初始化事件和绑定Handler
function InitEventsAndListeners()
    if localPlayer.C_Event == nil then
        world:CreateObject('FolderObject', 'C_Event', localPlayer)
    end
    world:CreateObject('CustomEvent', 'HeartbeatS2CEvent', localPlayer.C_Event)
    localPlayer.C_Event.HeartbeatS2CEvent:Connect(HeartbeatS2CEventHandler)

    -- OnPlayerJoinEvent（玩家第一次加入，类似现在的OnPlayerAdded）
    -- OnPlayerRejoinEvent（玩家离线后重新进入同一个房间）
    -- OnPlayerDisconnectEvent（未接收到服务器心跳，在客户端第二个阶段，玩家离线可重连，弱网，转菊花）
    -- OnPlayerReconnectEvent（玩家断线后重连）
    -- OnPlayerLeaveEvent（玩家彻底离开，退出房间）
    world:CreateObject('CustomEvent', 'OnPlayerJoinEvent', localPlayer.C_Event)
    -- world:CreateObject('CustomEvent', 'OnPlayerRejoinEvent', localPlayer.C_Event)
    world:CreateObject('CustomEvent', 'OnPlayerDisconnectEvent', localPlayer.C_Event)
    world:CreateObject('CustomEvent', 'OnPlayerReconnectEvent', localPlayer.C_Event)
    world:CreateObject('CustomEvent', 'OnPlayerLeaveEvent', localPlayer.C_Event)

    -- 掉线直接退出（默认，可选）
    -- localPlayer.C_Event.OnPlayerLeaveEvent:Connect(QuitGame)
end

--- Update心跳
function Update()
    cTmpTs = Timer.GetTimeMillisecond()
    sTmpTs = cache.sTimestamp
    PrintHb(string.format('=> C = %s, S = %s, %s', cTmpTs, sTmpTs, localPlayer))
    CheckPlayerState(p, cTmpTs)
    Ava.Util.Net.Fire_S('HeartbeatC2SEvent', localPlayer, cTmpTs, sTmpTs)
end

--- 心跳事件Handler
function HeartbeatS2CEventHandler(_stimestamp, _cTimestamp)
    if not running then
        return
    end
    PrintHb(string.format('<= C = %s, S = %s, %s', _cTimestamp, _stimestamp, localPlayer))
    CheckPlayerJoin(_player, _sTimestamp)
    cache.sTimestamp = _stimestamp
    cache.cTimestamp = _cTimestamp
end

--- 收包时，检查玩家是否连接服务器，或者重新连接服务器
function CheckPlayerJoin(_player, _sTimestamp)
    if not cache.sTimestamp then
        --* 玩家新加入 OnPlayerJoinEvent
        Debug.Log('[AvaKit][Heartbeat][Client] OnPlayerJoinEvent, 新玩家加入,', localPlayer)
        Ava.Util.Net.Fire_C('OnPlayerJoinEvent', localPlayer)
        cache.state = HeartbeatEnum.CONNECT
    elseif cache.state == HeartbeatEnum.DISCONNECT then
        --* 玩家断线重连 OnPlayerReconnectEvent
        Debug.Log('[AvaKit][Heartbeat][Client] OnPlayerReconnectEvent, 玩家断线重连,', localPlayer)
        Ava.Util.Net.Fire_C('OnPlayerReconnectEvent', localPlayer)
        cache.state = HeartbeatEnum.CONNECT
    end
end

--- 发包时，检查玩家是否连接服务器
function CheckPlayerState(_player, _cTimestamp)
    if not cache.cTimestamp then
        return
    end
    diff = _cTimestamp - cache.cTimestamp
    PrintHb(string.format('==========================================> diff = %s, %s', diff * .001, localPlayer))
    if cache.state == HeartbeatEnum.CONNECT and diff > HEARTBEAT_THRESHOLD_1 then
        --* 玩家断线，弱网环境
        Debug.Log('[AvaKit][Heartbeat][Client] OnPlayerDisconnectEvent, 玩家离线, 弱网环境,', localPlayer)
        Ava.Util.Net.Fire_C('OnPlayerDisconnectEvent', localPlayer)
        cache.state = HeartbeatEnum.DISCONNECT
    elseif cache.state == HeartbeatEnum.DISCONNECT and diff > HEARTBEAT_THRESHOLD_2 then
        --* 玩家断线, 退出游戏
        -- QuitGame()
        Ava.Util.Net.Fire_C('OnPlayerLeaveEvent', localPlayer)
    end
end

--- 退出游戏
function QuitGame()
    Debug.Log('[AvaKit][Heartbeat][Client] Game.Quit(), 玩家退出游戏')
    Game.Quit()
end

return ClientHeartbeat
