--- 游戏心跳
--- @module Client Heartbeat, Client-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local ClientHeartbeat = {}

-- Localize global vars
local FrameworkConfig = FrameworkConfig

-- 心跳包间隔时间，单位：秒
local HEARTBEAT_DELTA = FrameworkConfig.Client.HeartbeatDelta

-- 心跳阈值，单位：秒，范围定义如下：
--          0s -> threshold_1   : connected
-- threshold_1 -> threshold_2   : disconnected, weak network
-- threshold_2 -> longer        : disconnected, quit server
local HEARTBEAT_THRESHOLD_1 = FrameworkConfig.Client.HeartbeatThreshold1 * 1000 -- second => ms
local HEARTBEAT_THRESHOLD_2 = FrameworkConfig.Client.HeartbeatThreshold2 * 1000 -- second => ms

-- 玩家心跳连接状态
local HeartbeatEnum = {
    CONNECT = 1, -- 在线
    DISCONNECT = 2 -- 离线
}

-- 正在运行
local running = false

-- 上一次服务器发来的心跳时间戳缓存
local cache = {
    sTimestamp = nil,
    cTimestamp = nil
}

-- 临时变量
local diff  -- 时间戳插值
local sTmpTs, cTmpTs  -- 时间戳缓存

--- 打印心跳日志
--这段代码就是先判断Setting.ShowHeartbeatLog这个配置项是否为真  
--若为真则PrintHb 为一个打印日志的函数  若为假则为一个空函数
local PrintHb = FrameworkConfig.DebugMode and FrameworkConfig.Debug.ShowHeartbeatLog and function(...)
        print('[Heartbeat][Client]', ...)
    end or function()
    end

--! 外部接口

--- 初始化心跳包
function ClientHeartbeat.Init()
    print('[Heartbeat][Client] Init()')
	--校验心跳参数
    CheckSetting()
	--初始化事件和绑定Handler
    InitEventsAndListeners()
end

--- 开始发出心跳
function ClientHeartbeat.Start()
    print('[Heartbeat][Client] Start()')
    local cTimestamp
    running = true
    while (running) do
        Update()
		-- 每隔心跳包间隔时间，则检查一次心跳
        wait(HEARTBEAT_DELTA)
    end
end

-- 停止心跳
function ClientHeartbeat.Stop()
    print('[Heartbeat][Client] Stop()')
    running = false
end

--! 私有函数

-- 校验心跳参数
function CheckSetting()
	-- API-assert()
	--当第一个参数的值是false或者nil的时候展示一个错误，否则返回所有的参数值。
    assert(HEARTBEAT_DELTA >= 1, '[Heartbeat][Client] HEARTBEAT_DELTA 必须大于1秒')
    assert(HEARTBEAT_THRESHOLD_1 >= HEARTBEAT_DELTA, '[Heartbeat][Client] HEARTBEAT_THRESHOLD_1 >= HEARTBEAT_DELTA')
    assert(
        HEARTBEAT_THRESHOLD_2 >= HEARTBEAT_THRESHOLD_1,
        '[Heartbeat][Client] HEARTBEAT_THRESHOLD_2 >= HEARTBEAT_THRESHOLD_1'
    )
end

--- 初始化事件和绑定Handler
function InitEventsAndListeners()
	--创建客户端事件节点
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
	--在world下创建CustomEvent
    world:CreateObject('CustomEvent', 'OnPlayerJoinEvent', localPlayer.C_Event)
    -- world:CreateObject('CustomEvent', 'OnPlayerRejoinEvent', localPlayer.C_Event)
    world:CreateObject('CustomEvent', 'OnPlayerDisconnectEvent', localPlayer.C_Event)
    world:CreateObject('CustomEvent', 'OnPlayerReconnectEvent', localPlayer.C_Event)
    world:CreateObject('CustomEvent', 'OnPlayerLeaveEvent', localPlayer.C_Event)

    -- 掉线直接退出（默认，可选）
    localPlayer.C_Event.OnPlayerLeaveEvent:Connect(QuitGame)
end

-- Update心跳
function Update()
	--获取客户端运行时间
    cTmpTs = Timer.GetTimeMillisecond()
	--sTmpTs获取上一次服务器发来的服务端心跳时间戳缓存
    sTmpTs = cache.sTimestamp
    PrintHb(string.format('=> C = %s, S = %s, %s', cTmpTs, sTmpTs, localPlayer))
	--根据心跳时间戳检查玩家状态
	--发包时，检查玩家是否连接服务器
    CheckPlayerState(p, cTmpTs)
	--向服务端发送 心跳事件
    NetUtil.Fire_S('HeartbeatC2SEvent', localPlayer, cTmpTs, sTmpTs)
end

--- 心跳事件Handler
function HeartbeatS2CEventHandler(_stimestamp, _cTimestamp)
    if not running then
        return
    end
	--- 打印心跳日志
    PrintHb(string.format('<= C = %s, S = %s, %s', _cTimestamp, _stimestamp, localPlayer))
	--- 收包时，检查玩家是否连接服务器，或者重新连接服务器
    CheckPlayerJoin(_player, _sTimestamp)
	--更新上一次服务器发来的服务端心跳时间戳缓存的时间数据
    cache.sTimestamp = _stimestamp
    cache.cTimestamp = _cTimestamp
end

--- 收包时，检查玩家是否连接服务器，或者重新连接服务器
function CheckPlayerJoin(_player, _sTimestamp)
	--如果cache的sTimestamp不存在，则可以加入玩家
    if not cache.sTimestamp then
        --* 玩家新加入 OnPlayerJoinEvent
        print('[Heartbeat][Client] OnPlayerJoinEvent, 新玩家加入,', localPlayer, localPlayer.UserId)
		--如果本地玩家的OnPlayerJoinEvent事件存在，则向客户端发送新玩家加入事件消息
        NetUtil.Fire_C('OnPlayerJoinEvent', localPlayer, localPlayer.UserId)
		--设置状态为“在线”
        cache.state = HeartbeatEnum.CONNECT
	--如果状态为“离线”
    elseif cache.state == HeartbeatEnum.DISCONNECT then
        --* 玩家断线重连 OnPlayerReconnectEvent
        print('[Heartbeat][Client] OnPlayerReconnectEvent, 玩家断线重连,', localPlayer, localPlayer.UserId)
		--向客户端发送新玩家重连事件消息
        NetUtil.Fire_C('OnPlayerReconnectEvent', localPlayer, localPlayer.UserId)
		--设置状态为“在线”
        cache.state = HeartbeatEnum.CONNECT
    end
end

--- 发包时，检查玩家是否连接服务器
function CheckPlayerState(_player, _cTimestamp)
	-- 如果客户端的心跳时间戳缓存不存在，则返回
    if not cache.cTimestamp then
        return
    end
	--diff 时间戳插值 = 当前客户端的时间值- 服务端保存的客户端时间值
    diff = _cTimestamp - cache.cTimestamp
    PrintHb(string.format('==========================================> diff = %s, %s', diff * .001, localPlayer))
      --如果diff<心跳阈值1
	if diff < HEARTBEAT_THRESHOLD_1 then
        --* 玩家在线
		--设置服务端的心跳时间戳状态是“在线”状态
        cache.state = HeartbeatEnum.CONNECT
	--如果diff>=心跳阈值1并且服务端发来的心跳时间戳状态是“在线”状态
    elseif cache.state == HeartbeatEnum.CONNECT and diff >= HEARTBEAT_THRESHOLD_1 then
        --* 玩家断线，弱网环境
        print('[Heartbeat][Client] OnPlayerDisconnectEvent, 玩家离线, 弱网环境,', localPlayer)
		--向客户端发出玩家断线的事件消息
        NetUtil.Fire_C('OnPlayerDisconnectEvent', localPlayer, localPlayer.UserId)
		--设置服务端的心跳时间戳状态是“离线”状态
        cache.state = HeartbeatEnum.DISCONNECT
	--如果diff>=心跳阈值2并且玩家客户端发来的心跳时间戳状态是“离线”状态
    elseif cache.state == HeartbeatEnum.DISCONNECT and diff >= HEARTBEAT_THRESHOLD_2 then
        --* 玩家断线, 退出游戏
        -- QuitGame()
		--向客户端发出玩家离开的事件消息
        NetUtil.Fire_C('OnPlayerLeaveEvent', localPlayer, localPlayer.UserId)
    end
end

--- 退出游戏
function QuitGame()
    print('[Heartbeat][Client] Game.Quit(), 玩家退出游戏', localPlayer, localPlayer.UserId)
	--关闭游戏
    Game.Quit()
end

return ClientHeartbeat
