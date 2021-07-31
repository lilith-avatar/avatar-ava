--- 游戏服务器主逻辑
--- @module Game Server, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local Server = {}

-- Localize global vars
local CsvUtil, ModuleUtil = CsvUtil, ModuleUtil
-- Config：框架配置的数据
local Config = FrameworkConfig.Server
local this

-- 已经初始化，正在运行
local initialized, running = false, false

-- 含有InitDefault(),Init(),Update()的模块列表
local initDefaultList, awakeList, startList, updateList, lateUpdateList, fixedUpdateList = {}, {}, {}, {}, {}, {}

--- 运行服务器
function Server:Run()
    print('[Server] Run()')
    this = self
	--初始化服务器
    InitServer()
	--正式开始运行
    invoke(StartUpdate)
    invoke(StartFixedUpdate)
end

--- 停止Update
function Server:Stop()
    print('[Server] Stop()')
    running = false
	-- 游戏服务器心跳停止
	-- 位置：ServerHeartbeatModule
    ServerHeartbeat.Stop()
end

--- 初始化
function InitServer()
	--如果初始化过了，则不再初始化
    if initialized then
        return
    end
    print('[Server] InitServer()')
	--- 初始化服务器随机种子
    InitRandomSeed()
	--- 初始化心跳包
    InitHeartbeat()
	--- 初始化数据同步
	InitDataSync()
	--- 初始化服务器的CustomEvent
    InitServerCustomEvents()
	--- 生成框架需要的节点
    InitCsvAndXls()
	--- 生成需要Init和Update的模块列表
    GenInitAndUpdateList()
	--- 执行默认的Init方法
    RunInitDefault()
	--- 初始化包含Init()方法的模块
    InitOtherModules()
	--初始化完成
    initialized = true
end

--- 初始化服务器的CustomEvent
function InitServerCustomEvents()
    print('[Server] InitServerCustomEvents()')
	--如果服务端World目录下缺少S_Event节点则创建
    if world.S_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', world)
    end

    -- 生成CustomEvent节点
    for _, evt in pairs(Events.ServerEvents) do
		--如果服务的World.S_Event不存在该节点则创建
        if world.S_Event[evt] == nil then
            world:CreateObject('CustomEvent', evt, world.S_Event)
        end
    end
end

--- 初始化心跳包
--说明：判定客户端是否与服务端处于连接状态
function InitHeartbeat()
    assert(ServerHeartbeat, '[Server][Heartbeat] 找不到ServerHeartbeat,请联系张远程')
    -- 位置：ServerHeartbeatModule
	ServerHeartbeat.Init()
end

--- 初始化数据同步
function InitDataSync()
    assert(ServerDataSync, '[Server][DataSync] 找不到ServerDataSync,请联系张远程')
    ServerDataSync.Init()
end

--- 生成框架需要的节点
function InitCsvAndXls()
	--在world.Global下创建节点
    if not world.Global.Csv then
        world:CreateObject('FolderObject', 'Csv', world.Global)
    end
    if not world.Global.Xls then
        world:CreateObject('FolderObject', 'Xls', world.Global)
    end
end

--- 生成需要Init和Update的模块列表
function GenInitAndUpdateList()
    -- TODO: 改成在FrameworkConfig中配置
    -- Init Default
	--位置 ModuleUtilModule
	--- 将有包含特定方法的模块筛选出来，并放在一个table中
    ModuleUtil.GetModuleListWithFunc(world.Server.Module, 'InitDefault', initDefaultList, this)
    -- Awake
    ModuleUtil.GetModuleListWithFunc(Define, 'Awake', awakeList)
    ModuleUtil.GetModuleListWithFunc(world.Server.Module, 'Awake', awakeList, this)
    -- Start
    ModuleUtil.GetModuleListWithFunc(Define, 'Start', startList)
    ModuleUtil.GetModuleListWithFunc(world.Server.Module, 'Start', startList, this)
    -- Update
    ModuleUtil.GetModuleListWithFunc(world.Server.Module, 'Update', updateList, this)
    -- LateUpdate
    ModuleUtil.GetModuleListWithFunc(world.Server.Module, 'LateUpdate', lateUpdateList, this)
    -- FixedUpdate
    ModuleUtil.GetModuleListWithFunc(world.Server.Module, 'FixedUpdate', fixedUpdateList, this)
end

--- 执行默认的Init方法
function RunInitDefault()
    for _, m in ipairs(initDefaultList) do
        m:InitDefault(m)
    end
end

--- 初始化服务器随机种子
function InitRandomSeed()
    math.randomseed(os.time())
end

--- 初始化包含Init()方法的模块
function InitOtherModules()
    for _, m in ipairs(awakeList) do
        m:Awake()
    end
    for _, m in ipairs(startList) do
        m:Start()
    end
end

--- 开始Update
function StartUpdate()
    print('[Server] StartUpdate()')
    assert(not running, '[Server] StartUpdate() 正在运行')

    running = true

    -- 开启心跳
	-- 位置：Framework.ServerHeartbeatModule
    if FrameworkConfig.HeartbeatStart then
        invoke(ServerHeartbeat.Start)
    end

    -- 开启数据同步
    ServerDataSync.Start()

    local dt = 0 -- delta time 每帧时间
    local tt = 0 -- total time 游戏总时间
    local now = Timer.GetTimeMillisecond --时间函数缓存
    local prev, curr = now() / 1000, nil -- two timestamps

    while (running and wait()) do
		-- 每隔1000毫秒(1秒)运行一次UpdateServer()
        curr = now() / 1000
        dt = curr - prev
        tt = tt + dt
        prev = curr
        UpdateServer(dt, tt)
        LateUpdateServer(dt, tt)
    end
end

--- 开始FixedUpdate
function StartFixedUpdate()
    for _, m in ipairs(fixedUpdateList) do
        invoke(
            function()
                while running do
                    m:FixedUpdate()
                    wait(m.fixedUpdateInterval)
                end
            end
        )
    end
end

function ErrorShow(err)
    world.Global.ErrorGUI:SetActive(true)
    world.Global.ErrorGUI.Error.Text = err
end

--- Update函数
--- @param dt delta time 每帧时间
function UpdateServer(_dt, _tt)
    for _, m in ipairs(updateList) do
        m:Update(_dt, _tt)
    end
end

--- LateUpdate函数
-- @param dt delta time 每帧时间
function LateUpdateServer(_dt, _tt)
    for _, m in ipairs(lateUpdateList) do
        m:LateUpdate(_dt, _tt)
    end
end

return Server
