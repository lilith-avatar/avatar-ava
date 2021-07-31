--- 游戏客户端主逻辑
-- @module Game Manager, Client-side
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
local Client = {}

-- Localize global vars
local CsvUtil, XslUitl, ModuleUtil = CsvUtil, XslUitl, ModuleUtil
-- Config：框架配置的客户端数据
local Config = FrameworkConfig.Client
local this

-- 已经初始化，正在运行
local initialized, running = false, false

-- 含有InitDefault(),Init(),Update()的模块列表
local initDefaultList, awakeList, startList, onPreRenderList, updateList, lateUpdateList, fixedUpdateList = {},
    {},
    {},
    {},
    {},
    {},
    {}

--- 运行客户端
function Client:Run()
    print('[Client] Run()')
    this = self
	--初始化客户端
    InitClient()
	--开启客户端的Update
    invoke(StartUpdate)
	--开启客户端的FixUpdate
    invoke(StartFixedUpdate)
end

--- 停止Update
function Client:Stop()
    print('[Client] Stop()')
    running = false
	-- 客户端心跳停止
	-- 位置：ClientHeartbeatModule
    ClientHeartbeat.Stop()
end

--- 初始化
function InitClient()
    if initialized then
        return
    end
    print('[Client] InitClient()')
	--- 初始化客户端随机种子
    InitRandomSeed()
	--- 初始化心跳包
    InitHeartbeat()
	--- 初始化数据同步
    InitDataSync()
	--- 初始化客户端的CustomEvent
    InitClientCustomEvents()
	--- 生成需要Init和Update的模块列表
    GenInitAndUpdateList()
	--- 执行默认的Init方法
    RunInitDefault()
	--- 初始化包含Awake()和Start()方法的模块
    InitOtherModules()
    initialized = true
end

--- 初始化心跳包
function InitHeartbeat()
    assert(ClientHeartbeat, '[Client][Heartbeat] 找不到ClientHeartbeat,请联系张远程')
	--位置：Framework.Client.ClientHeartbeatModule
    ClientHeartbeat.Init()
end

--- 初始化数据同步
function InitDataSync()
    assert(ClientDataSync, '[Server][DataSync] 找不到ClientDataSync,请联系张远程')
    ClientDataSync.Init()
end

--- 初始化客户端的CustomEvent
function InitClientCustomEvents()
	--如果localPlayer目录下缺少C_Event节点则创建
    if localPlayer.C_Event == nil then
        world:CreateObject('FolderObject', 'C_Event', localPlayer)
    end

    -- 生成CustomEvent节点
    for _, evt in pairs(Events.ClientEvents) do
		--如果localPlayer.C_Event不存在该节点则创建
        if localPlayer.C_Event[evt] == nil then
            world:CreateObject('CustomEvent', evt, localPlayer.C_Event)
        end
    end
end

--- 生成需要Init和Update的模块列表
function GenInitAndUpdateList()
    -- TODO: 改成在FrameworkConfig中配置
    -- Init Default
	--位置 ModuleUtilModule
	--- 将有包含特定方法的模块筛选出来，并放在一个table中
    ModuleUtil.GetModuleListWithFunc(world.Client.Module, 'InitDefault', initDefaultList, this)
    -- Awake
    ModuleUtil.GetModuleListWithFunc(Define, 'Awake', awakeList)
    ModuleUtil.GetModuleListWithFunc(world.Client.Module, 'Awake', awakeList, this)
    -- Start
    ModuleUtil.GetModuleListWithFunc(Define, 'Start', startList)
    ModuleUtil.GetModuleListWithFunc(world.Client.Module, 'Start', startList, this)
    -- OnPreRender
    ModuleUtil.GetModuleListWithFunc(world.Client.Module, 'OnPreRender', onPreRenderList, this)
    -- Update
    ModuleUtil.GetModuleListWithFunc(world.Client.Module, 'Update', updateList, this)
    -- LateUpdate
    ModuleUtil.GetModuleListWithFunc(world.Client.Module, 'LateUpdate', lateUpdateList, this)
    -- FixedUpdate
    ModuleUtil.GetModuleListWithFunc(world.Client.Module, 'FixedUpdate', fixedUpdateList, this)
end

--- 执行默认的Init方法
function RunInitDefault()
    for _, m in ipairs(initDefaultList) do
        m:InitDefault(m)
    end
end

--- 初始化客户端随机种子
function InitRandomSeed()
    math.randomseed(os.time())
end

--- 初始化包含Awake()和Start()方法的模块
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
    print('[Client] StartUpdate()')
    assert(not running, '[Client] StartUpdate() 正在运行')

    running = true

    -- 开启心跳
    if FrameworkConfig.HeartbeatStart then
        invoke(ClientHeartbeat.Start)
    end

    -- 开启数据同步
    ClientDataSync.Start()

    local dt = 0 -- delta time 每帧时间
    local tt = 0 -- total time 游戏总时间
	--GetTimeMillisecond()获取客户端游戏进行的总时间
    local now = Timer.GetTimeMillisecond --时间函数缓存
    local prev, curr = now() / 1000, nil -- two timestamps

    while (running and wait()) do
		--每1秒执行一次Update函数
        curr = now() / 1000
        dt = curr - prev
        tt = tt + dt
        prev = curr
        UpdateClient(dt, tt)
        LateUpdateClient(dt, tt)
    end
end

world.OnRenderStepped:Connect(
    function(dt)
        OnPreRenderClient(dt)
    end
)

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

--- OnPreRender函数
-- @param dt delta time 每帧时间
function OnPreRenderClient(_dt)
    for _, m in ipairs(onPreRenderList) do
        m:OnPreRender(_dt)
    end
end

--- Update函数
-- @param dt delta time 每帧时间
function UpdateClient(_dt, _tt)
    for _, m in ipairs(updateList) do
        m:Update(_dt, _tt)
    end
end

--- LateUpdate函数
-- @param dt delta time 每帧时间
function LateUpdateClient(_dt, _tt)
    for _, m in ipairs(lateUpdateList) do
        m:LateUpdate(_dt, _tt)
    end
end

return Client
