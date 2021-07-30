--- 游戏服务器主逻辑
--- @module Game Server, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local Server = {}

-- Localize global vars
local CsvUtil, ModuleUtil = CsvUtil, ModuleUtil
-- Config：框架配置的数据
local Config = FrameworkConfig.Server

-- 已经初始化，正在运行
local initialized, running = false, false

-- 含有InitDefault(),Init(),Update()的模块列表
local initDefaultList, initList, updateList = {}, {}, {}

--- 运行服务器
function Server:Run()
    print('[Server] Run()')
	--初始化服务器
    InitServer()
	--正式开始运行
    StartUpdate()
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
	---初始化插件模块
    InitPluginModules()
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

    -- 将插件中的CustomEvent放入Events.ClientEvents中
    for _, m in pairs(Config.PluginEvents) do
		--获取保存在_G表中服务端的事件表
        local evts = _G[m].ServerEvents
		--assert():当第一个参数的值是false或者nil的时候展示一个错误，否则返回所有的参数值。
        assert(evts, string.format('[Server] %s 中不存在ServerEvents，请检查模块，或从FrameworkConfig删除此配置', m))
        for __, evt in pairs(evts) do
			--可能是判定evt表中是否存在Events.ServerEvents，如果不存在则插入Events.ServerEvents
            if not table.exists(Events.ServerEvents, evt) then
                table.insert(Events.ServerEvents, evt)
            end
        end
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
	--位置 ModuleUtilModule
	--- 将有包含特定方法的模块筛选出来，并放在一个table中
    ModuleUtil.GetModuleListWithFunc(Module.S_Module, 'InitDefault', initDefaultList)
    ModuleUtil.GetModuleListWithFunc(Module.S_Module, 'Init', initList)
    ModuleUtil.GetModuleListWithFunc(Module.S_Module, 'Update', updateList)
	--遍历 插件中需要使用声明周期的服务器模块目录
    for _, m in pairs(FrameworkConfig.Server.PluginModules) do
        ModuleUtil.GetModuleListWithFunc(m, 'InitDefault', initDefaultList)
        ModuleUtil.GetModuleListWithFunc(m, 'Init', initList)
        ModuleUtil.GetModuleListWithFunc(m, 'Update', updateList)
    end
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
    for _, m in ipairs(initList) do
        m:Init()
    end
end

---初始化插件模块
function InitPluginModules()
	--位置 Weapon_Plugin_Package.Module.S_Module.WeaponMgrModule
    WeaponMgr:Init()
	--位置 SoundUtilModule
    SoundUtil:Init()
end

--- 开始Update
function StartUpdate()
    print('[Server] StartUpdate()')
    assert(not running, '[Server] StartUpdate() 正在运行')

    running = true

    -- 开启心跳
	--位置：Framework.ServerHeartbeatModule
    if FrameworkConfig.HeartbeatStart then
        invoke(ServerHeartbeat.Start)
    end

    local dt = 0 -- delta time 每帧时间
    local tt = 0 -- total time 游戏总时间
    local now = Timer.GetTimeMillisecond --时间函数缓存
    local prev, curr = now() / 1000, nil -- two timestamps
	--当运行状态
    while (running and wait()) do
		--每隔1000毫秒(1秒)运行一次UpdateServer()
        curr = now() / 1000
        dt = curr - prev
        tt = tt + dt
        prev = curr
        UpdateServer(dt, tt)
    end
end

--- Update函数
--- @param _dt number delta time 每帧时间
function UpdateServer(_dt, _tt)
    for _, m in ipairs(updateList) do
        m:Update(_dt, _tt)
    end
end

return Server
