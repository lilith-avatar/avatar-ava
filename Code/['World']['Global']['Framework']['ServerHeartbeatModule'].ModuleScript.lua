--- 游戏服务器心跳
--- @module Server Heartbeat, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local ServerHeartbeat = {}

-- Localize global vars
local Setting = FrameworkConfig.Server

-- 心跳包间隔时间，单位：秒
local HEARTBEAT_DELTA = Setting.HeartbeatDelta

local leaveEventList = {}

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
--这段代码就是先判断Setting.ShowHeartbeatLog这个配置项是否为真  
--若为真则PrintHb 为一个打印日志的函数  若为假则为一个空函数
local PrintHb = Setting.ShowHeartbeatLog and function(...)
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
    GenLeaveEventList()
end

--- 开始发出心跳
function ServerHeartbeat.Start()
    print('[Heartbeat][Server] Start()')
    running = true
    while (running) do
        Update()
		-- 每隔心跳包间隔时间，则检查一次每个加入的客户端心跳
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
	-- API-assert()
	--当第一个参数的值是false或者nil的时候展示一个错误，否则返回所有的参数值。
    assert(HEARTBEAT_DELTA >= 1, '[Heartbeat][Server] HEARTBEAT_DELTA 必须大于1秒')
    assert(HEARTBEAT_THRESHOLD_1 >= HEARTBEAT_DELTA, '[Heartbeat][Server] HEARTBEAT_THRESHOLD_1 >= HEARTBEAT_DELTA')
    assert(
        HEARTBEAT_THRESHOLD_2 >= HEARTBEAT_THRESHOLD_1,
        '[Heartbeat][Server] HEARTBEAT_THRESHOLD_2 >= HEARTBEAT_THRESHOLD_1'
    )
end

function GenLeaveEventList()
    ModuleUtil.GetModuleListWithFunc(Module.S_Module, 'OnPlayerLeaveEventHandler', leaveEventList)
end

--- 初始化事件和绑定Handler
function InitEventsAndListeners()
	--创建服务端事件节点
    if world.S_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', world)
    end
	--在world.S_Event下创建CustomEvent事件
    world:CreateObject('CustomEvent', 'HeartbeatC2SEvent', world.S_Event)
	--为CustomEvent事件绑定心跳事件Handler
	world.S_Event.HeartbeatC2SEvent:Connect(HeartbeatC2SEventHandler)

    -- OnAwakeEvent（玩家加入前初始化）
    -- OnPlayerJoinEvent（玩家第一次加入，类似现在的OnPlayerAdded）
    -- OnPlayerRejoinEvent（玩家离开房间后重新进入同一个房间）
    -- OnPlayerDisconnectEvent（未接收到玩家心跳等待重连，在服务器第二个阶段）
    -- OnPlayerReconnectEvent（玩家断线后重连）
    -- OnPlayerLeaveEvent（玩家彻底离开，退出房间）
	--在world下创建CustomEvent的相关事件
    world:CreateObject('CustomEvent', 'OnAwakeEvent', world.S_Event)
    world:CreateObject('CustomEvent', 'OnPlayerJoinEvent', world.S_Event)
    -- world:CreateObject('CustomEvent', 'OnPlayerRejoinEvent', world.S_Event)
    world:CreateObject('CustomEvent', 'OnPlayerDisconnectEvent', world.S_Event)
    world:CreateObject('CustomEvent', 'OnPlayerReconnectEvent', world.S_Event)
    world:CreateObject('CustomEvent', 'OnPlayerLeaveEvent', world.S_Event)

    -- 玩家退出，发出OnPlayerLeaveEvent
    world.OnPlayerRemoved:Connect(
        function(_player)
            --if cache[_player] then
            print('[Heartbeat][Server] OnPlayerLeaveEvent, 玩家主动离开游戏,', _player)
			-- 对leaveEventList表执行OnPlayerLeaveEventHandler
            for _, m in pairs(leaveEventList) do
                m:OnPlayerLeaveEventHandler(_player)
            end
            --end
        end
    )
end

--- Update心跳
function Update()
	--遍历每个加入的客户端的cache(上一次客户端发来的心跳时间戳缓存)
    for p, v in pairs(cache) do
        if p and not p:IsNull() then
			--逻辑：	记录服务端的时间轴，并传入客户端进行比较获得diff，diff大小即代表客户端延迟的大小
			--		如果diff大于服务端设置的最大心跳阈值，则代表客户端断开了连接
			--获取从游戏开始到当前时刻所经历的时间，以毫秒为单位
			--sTmpTs：服务端的运行总时间
            sTmpTs = Timer.GetTimeMillisecond()
            cTmpTs = v.cTimestamp
            PrintHb(string.format('=> S = %s, C = %s, %s', sTmpTs, cTmpTs, p))
			--- 发包时，检查玩家是否掉线
            CheckPlayerStates(p, sTmpTs)
			-- 向指定的玩家的客户端发送消息：心跳消息
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
	--- 打印心跳日志
    PrintHb(string.format('<= S = %s, C = %s, %s', _sTimestamp, _cTimestamp, _player))
    --- 收包时，检查玩家是否加入或重连
	CheckPlayerJoin(_player)
	--更新指定的玩家客户端的时间数据
    cache[_player].cTimestamp = _cTimestamp
    cache[_player].sTimestamp = _sTimestamp
end

--- 收包时，检查玩家是否加入或重连
function CheckPlayerJoin(_player)
	--如果cache的_player位置存在空位，则可以加入玩家
    if not cache[_player] then
        --* 玩家新加入 OnPlayerJoinEvent
        print('[Heartbeat][Server] OnPlayerJoinEvent, 新玩家加入,', _player)
		-- 向服务器发送消息：新玩家加入消息
        NetUtil.Fire_S('OnPlayerJoinEvent', _player)
        cache[_player] = {
			--设置状态为：“在线”状态
            state = HeartbeatEnum.CONNECT
        }
	-- 如果cache的_player位置存在，并且玩家的状态是“离线”，则对玩家进行断线重连
    elseif cache[_player].state == HeartbeatEnum.DISCONNECT then
        --* 玩家断线重连 OnPlayerReconnectEvent
        print('[Heartbeat][Server] OnPlayerReconnectEvent, 玩家断线重连,', _player)
		-- 向服务器发送消息：老玩家断线重连消息
        NetUtil.Fire_S('OnPlayerReconnectEvent', _player)
		--设置状态为：“在线”状态
        cache[_player].state = HeartbeatEnum.CONNECT
    end
end

--- 发包时，检查玩家是否掉线
function CheckPlayerStates(_player, _sTimestam)
	-- 如果服务端的心跳时间戳缓存不存在，则返回
    if not cache[_player].sTimestamp then
        return
    end
	---diff 时间戳插值 = 当前服务端的时间值- 当前玩家客户端保存的服务端时间值
    diff = _sTimestam - cache[_player].sTimestamp
    PrintHb(string.format('==========================================> diff = %s, %s', diff * .001, _player))
	--如果diff大于心跳阈值1并且玩家客户端发来的心跳时间戳状态是“在线”状态
    if cache[_player].state == HeartbeatEnum.CONNECT and diff > HEARTBEAT_THRESHOLD_1 then
        --* 玩家断线 OnPlayerReconnectEvent
        print('[Heartbeat][Server] OnPlayerDisconnectEvent, 玩家离线, 等待断线重连,', _player)
		--- 向服务器发送消息：玩家连接失败消息
		--位置 NetUtilModule
        NetUtil.Fire_S('OnPlayerDisconnectEvent', _player)
		--设置玩家客户端发来的心跳时间戳状态是“离线”状态
        cache[_player].state = HeartbeatEnum.DISCONNECT
	--如果diff大于心跳阈值2并且玩家客户端发来的心跳时间戳状态是“离线”状态
    elseif cache[_player].state == HeartbeatEnum.DISCONNECT and diff > HEARTBEAT_THRESHOLD_2 then
        --* 玩家彻底断线，剔除玩家
        print('[Heartbeat][Server] OnPlayerLeaveEvent, 剔除离线玩家,', _player)
		-- 向服务器发送消息：玩家离开消息
        NetUtil.Fire_S('OnPlayerLeaveEvent', _player)
        print('[Heartbeat][Server] OnPlayerLeave, 发送客户端离线事件,', _player)
		-- 向指定的玩家的客户端发送消息：玩家离开消息
        NetUtil.Fire_C('OnPlayerLeaveEvent', _player)
		-- 将cache的该玩家数据删除
        cache[_player] = nil
    end
end

return ServerHeartbeat
