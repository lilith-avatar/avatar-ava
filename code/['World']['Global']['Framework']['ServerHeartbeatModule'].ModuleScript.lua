--- 游戏服务器心跳
--- @module Server Heartbeat, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local ServerHeartbeat = {}

-- Localize global vars
local Setting = FrameworkConfig.Server

-- 心跳包间隔时间，单位：秒
local HEARTBEAT_DELTA = Setting.HeartbeatDelta

-- 心跳阈值，单位：秒，范围定义如下：
--          0s -> threshold_1   : connected
-- threshold_1 -> threshold_2   : disconnected, but player can rejoin
-- threshold_2 -> longer        : disconnected, remove player
local HEARTBEAT_THRESHOLD_1 = Setting.HeartbeatThreshold1 * 1000 -- second => ms
local HEARTBEAT_THRESHOLD_2 = Setting.HeartbeatThreshold2 * 1000 -- second => ms

-- 玩家心跳连接状态
local HeartbeatEnum = {
    CONNECT = 1, -- 在线
    DISCONNECT = 2 -- 离线
}

-- 正在运行
local running = false

-- 上一次客户端发来的心跳时间戳缓存
local cache = {}

-- 临时变量
local diff  -- 时间戳插值
local sTmpTs, cTmpTs  -- 时间戳缓存

--- 打印心跳日志
local PrintHb = Setting.ShowHeartbeatLog and function(...)
        print('[Heartbeat][Server]', ...)
    end or function()
    end

--! 外部接口

--- 初始化心跳包
function ServerHeartbeat.Init()
    print('[Heartbeat][Server] Init()')
    CheckSetting()
    InitEventsAndListeners()
end

--- 开始发出心跳
function ServerHeartbeat.Start()
    print('[Heartbeat][Server] Start()')
    running = true
    while (running) do
        Update()
        wait(HEARTBEAT_DELTA)
    end
end

--- 停止心跳
function ServerHeartbeat.Stop()
    print('[Heartbeat][Server] Stop()')
    running = false
end

--! 私有函数

--- 校验心跳参数
function CheckSetting()
    assert(HEARTBEAT_DELTA >= 1, '[Heartbeat][Server] HEARTBEAT_DELTA 必须大于1秒')
    assert(HEARTBEAT_THRESHOLD_1 >= HEARTBEAT_DELTA, '[Heartbeat][Server] HEARTBEAT_THRESHOLD_1 >= HEARTBEAT_DELTA')
    assert(
        HEARTBEAT_THRESHOLD_2 >= HEARTBEAT_THRESHOLD_1,
        '[Heartbeat][Server] HEARTBEAT_THRESHOLD_2 >= HEARTBEAT_THRESHOLD_1'
    )
end

--- 初始化事件和绑定Handler
function InitEventsAndListeners()
    if world.S_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', world)
    end
    world:CreateObject('CustomEvent', 'HeartbeatC2SEvent', world.S_Event)
    world.S_Event.HeartbeatC2SEvent:Connect(HeartbeatC2SEventHandler)

    -- OnAwakeEvent（玩家加入前初始化）
    -- OnPlayerJoinEvent（玩家第一次加入，类似现在的OnPlayerAdded）
    -- OnPlayerRejoinEvent（玩家离开房间后重新进入同一个房间）
    -- OnPlayerDisconnectEvent（未接收到玩家心跳等待重连，在服务器第二个阶段）
    -- OnPlayerReconnectEvent（玩家断线后重连）
    -- OnPlayerLeaveEvent（玩家彻底离开，退出房间）
    world:CreateObject('CustomEvent', 'OnAwakeEvent', world.S_Event)
    world:CreateObject('CustomEvent', 'OnPlayerJoinEvent', world.S_Event)
    -- world:CreateObject('CustomEvent', 'OnPlayerRejoinEvent', world.S_Event)
    world:CreateObject('CustomEvent', 'OnPlayerDisconnectEvent', world.S_Event)
    world:CreateObject('CustomEvent', 'OnPlayerReconnectEvent', world.S_Event)
    world:CreateObject('CustomEvent', 'OnPlayerLeaveEvent', world.S_Event)

    -- 玩家退出，发出OnPlayerLeaveEvent
    world.OnPlayerRemoved:Connect(
        function(_player)
            if cache[_player] then
                print('[Heartbeat][Server] OnPlayerLeaveEvent, 玩家主动离开游戏,', _player)
                NetUtil.Fire_S('OnPlayerLeaveEvent', _player)
            end
        end
    )
end

--- Update心跳
function Update()
    for p, v in pairs(cache) do
        if p and not p:IsNull() then
            sTmpTs = Timer.GetTimeMillisecond()
            cTmpTs = v.cTimestamp
            PrintHb(string.format('=> S = %s, C = %s, %s', sTmpTs, cTmpTs, p))
            CheckPlayerStates(p, sTmpTs)
            NetUtil.Fire_C('HeartbeatS2CEvent', p, sTmpTs, cTmpTs)
        else
            --* remove nil key from cache
            cache[p] = nil
        end
    end
end

--- 心跳事件Handler
function HeartbeatC2SEventHandler(_player, _cTimestamp, _sTimestamp)
    if not running then
        return
    end
    PrintHb(string.format('<= S = %s, C = %s, %s', _sTimestamp, _cTimestamp, _player))
    CheckPlayerJoin(_player)
    cache[_player].cTimestamp = _cTimestamp
    cache[_player].sTimestamp = _sTimestamp
end

--- 收包时，检查玩家是否加入或重连
function CheckPlayerJoin(_player)
    if not cache[_player] then
        --* 玩家新加入 OnPlayerJoinEvent
        print('[Heartbeat][Server] OnPlayerJoinEvent, 新玩家加入,', _player)
        NetUtil.Fire_S('OnPlayerJoinEvent', _player)
        cache[_player] = {
            state = HeartbeatEnum.CONNECT
        }
    elseif cache[_player].state == HeartbeatEnum.DISCONNECT then
        --* 玩家断线重连 OnPlayerReconnectEvent
        print('[Heartbeat][Server] OnPlayerReconnectEvent, 玩家断线重连,', _player)
        NetUtil.Fire_S('OnPlayerReconnectEvent', _player)
        cache[_player].state = HeartbeatEnum.CONNECT
    end
end

--- 发包时，检查玩家是否掉线
function CheckPlayerStates(_player, _sTimestam)
    if not cache[_player].sTimestamp then
        return
    end
    diff = _sTimestam - cache[_player].sTimestamp
    PrintHb(string.format('==========================================> diff = %s, %s', diff * .001, _player))
    if diff < HEARTBEAT_THRESHOLD_1 then
        --* 玩家在线
        cache[_player].state = HeartbeatEnum.CONNECT
    elseif cache[_player].state == HeartbeatEnum.CONNECT and diff > HEARTBEAT_THRESHOLD_1 then
        --* 玩家断线 OnPlayerDisconnectEvent
        print('[Heartbeat][Server] OnPlayerDisconnectEvent, 玩家离线, 等待断线重连,', _player)
        NetUtil.Fire_S('OnPlayerDisconnectEvent', _player)
        cache[_player].state = HeartbeatEnum.DISCONNECT
    elseif cache[_player].state == HeartbeatEnum.DISCONNECT and diff > HEARTBEAT_THRESHOLD_2 then
        --* 玩家彻底断线，剔除玩家 OnPlayerLeaveEvent
        print('[Heartbeat][Server] OnPlayerLeaveEvent, 剔除离线玩家,', _player)
        NetUtil.Fire_S('OnPlayerLeaveEvent', _player)
        print('[Heartbeat][Server] OnPlayerLeave, 发送客户端离线事件,', _player)
        NetUtil.Fire_C('OnPlayerLeaveEvent', _player)
        cache[_player] = nil
    end
end

return ServerHeartbeat
