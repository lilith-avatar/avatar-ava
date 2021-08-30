--- 游戏服务器心跳
--- @module Server Heartbeat, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local ServerHeartbeat = {}

--- Localize global vars
local Config = Ava.Config

--- 心跳包间隔时间，单位：秒
local HEARTBEAT_DELTA = Config.Server.HeartbeatDelta

--- 心跳阈值，单位：秒，范围定义如下：
---            0s -> threshold_1   : connected
---   threshold_1 -> threshold_2   : disconnected, but player can rejoin
---   threshold_2 -> longer        : disconnected, remove player
local HEARTBEAT_THRESHOLD_1 = Config.Server.HeartbeatThreshold1 * 1000 -- second => ms
local HEARTBEAT_THRESHOLD_2 = Config.Server.HeartbeatThreshold2 * 1000 -- second => ms

--- 玩家心跳连接状态
local HeartbeatEnum = {
    CONNECT = 1, -- 在线
    DISCONNECT = 2 -- 离线
}

--- 正在运行
local running = false

--- 上一次客户端发来的心跳时间戳缓存
local cache = {}

--- 临时变量
local diff  -- 时间戳插值
local sTmpTs, cTmpTs  -- 时间戳缓存

--- 打印心跳日志
--- 这段代码就是先判断Setting.ShowHeartbeatLog这个配置项是否为真
--- 若为真则PrintHb 为一个打印日志的函数  若为假则为一个空函数
local PrintHb = Config.DebugMode and Config.Debug.ShowHeartbeatLog and function(...)
        print('[Heartbeat][Server]', ...)
    end or function()
    end

--! 外部接口

--- 初始化心跳包
function ServerHeartbeat.Init()
    print('[Heartbeat][Server] Init()')
    --校验心跳参数
    CheckSetting()
    --初始化事件和绑定Handler
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
    --创建服务端事件节点
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
            local player = _player
            local uid = player.UserId
            if cache[player] then
                print('[Heartbeat][Server] OnPlayerLeaveEvent, 玩家主动离开游戏,', player, uid)
                Ava.Util.Net.Fire_S('OnPlayerLeaveEvent', player, uid)
                cache[player] = nil
            end
        end
    )
end

--- Update心跳
function Update()
    --遍历每个加入的客户端的cache(上一次客户端发来的心跳时间戳缓存)
    for p, v in pairs(cache) do
        if p and not p:IsNull() then
            sTmpTs = Timer.GetTimeMillisecond()
            cTmpTs = v.cTimestamp
            PrintHb(string.format('=> S = %s, C = %s, %s', sTmpTs, cTmpTs, p))
            CheckPlayerStates(p, sTmpTs)
            Ava.Util.Net.Fire_C('HeartbeatS2CEvent', p, sTmpTs, cTmpTs)
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
    --- 打印心跳日志
    PrintHb(string.format('<= S = %s, C = %s, %s', _sTimestamp, _cTimestamp, _player))
    --- 收包时，检查玩家是否加入或重连
    CheckPlayerJoin(_player)
    -- 更新指定的玩家客户端的时间数据
    cache[_player].cTimestamp = _cTimestamp
    cache[_player].sTimestamp = _sTimestamp
end

--- 收包时，检查玩家是否加入或重连
function CheckPlayerJoin(_player)
    --如果cache的_player位置存在空位，则可以加入玩家
    if not cache[_player] then
        --* 玩家新加入 OnPlayerJoinEvent
        print('[Heartbeat][Server] OnPlayerJoinEvent, 新玩家加入,', _player)
        Ava.Util.Net.Fire_S('OnPlayerJoinEvent', _player, _player.UserId)
        cache[_player] = {
            state = HeartbeatEnum.CONNECT
        }
    elseif cache[_player].state == HeartbeatEnum.DISCONNECT then
        --* 玩家断线重连 OnPlayerReconnectEvent
        print('[Heartbeat][Server] OnPlayerReconnectEvent, 玩家断线重连,', _player)
        Ava.Util.Net.Fire_S('OnPlayerReconnectEvent', _player, _player.UserId)
        cache[_player].state = HeartbeatEnum.CONNECT
    end
end

--- 发包时，检查玩家是否掉线
function CheckPlayerStates(_player, _sTimestam)
    -- 如果服务端的心跳时间戳缓存不存在，则返回
    if not cache[_player].sTimestamp then
        return
    end
    -- diff 时间戳插值 = 当前服务端的时间值- 当前玩家客户端保存的服务端时间值
    diff = _sTimestam - cache[_player].sTimestamp
    PrintHb(string.format('==========================================> diff = %s, %s', diff * .001, _player))
    -- 如果 diff < 心跳阈值1
    if diff < HEARTBEAT_THRESHOLD_1 then
        --* 玩家在线
        cache[_player].state = HeartbeatEnum.CONNECT
    elseif cache[_player].state == HeartbeatEnum.CONNECT and diff >= HEARTBEAT_THRESHOLD_1 then
        --* 玩家断线 OnPlayerDisconnectEvent
        print('[Heartbeat][Server] OnPlayerDisconnectEvent, 玩家离线, 等待断线重连,', _player, _player.UserId)
        Ava.Util.Net.Fire_S('OnPlayerDisconnectEvent', _player, _player.UserId)
        cache[_player].state = HeartbeatEnum.DISCONNECT
    elseif cache[_player].state == HeartbeatEnum.DISCONNECT and diff >= HEARTBEAT_THRESHOLD_2 then
        --* 玩家彻底断线，剔除玩家
        local player = _player
        local uid = player.UserId
        print('[Heartbeat][Server] OnPlayerLeaveEvent, 剔除离线玩家,', player, uid)
        Ava.Util.Net.Fire_S('OnPlayerLeaveEvent', player, uid)
        print('[Heartbeat][Server] OnPlayerLeaveEvent, 发送客户端离线事件,', player, uid)
        Ava.Util.Net.Fire_C('OnPlayerLeaveEvent', player, uid)
        -- 将cache的该玩家数据删除
        cache[player] = nil
    end
end

return ServerHeartbeat
