--- 游戏服务器主逻辑
--- @module Game Server, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local Server = {}

-- Localize global vars
local CsvUtil, ModuleUtil = CsvUtil, ModuleUtil
local Config = FrameworkConfig.Server

-- 已经初始化，正在运行
local initialized, running = false, false

-- 含有InitDefault(),Init(),Update()的模块列表
local initDefaultList, initList, updateList = {}, {}, {}

--- 运行服务器
function Server:Run()
    print('[Server] Run()')
    InitServer()
    StartUpdate()
end

--- 停止Update
function Server:Stop()
    print('[Server] Stop()')
    running = false
    ServerHeartbeat.Stop()
end

--- 初始化
function InitServer()
    if initialized then
        return
    end
    print('[Server] InitServer()')
    InitRandomSeed()
    InitHeartbeat()
    InitDataSync()
    InitServerCustomEvents()
    InitCsvAndXls()
    GenInitAndUpdateList()
    RunInitDefault()
    InitOtherModules()
    initialized = true
end

--- 初始化服务器的CustomEvent
function InitServerCustomEvents()
    print('[Server] InitServerCustomEvents()')
    if world.S_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', world)
    end

    -- 将插件中的CustomEvent放入Events.ClientEvents中
    for _, m in pairs(Config.PluginEvents) do
        local evts = _G[m].ServerEvents
        assert(evts, string.format('[Server] %s 中不存在ServerEvents，请检查模块，或从FrameworkConfig删除此配置', m))
        for __, evt in pairs(evts) do
            if not table.exists(Events.ServerEvents, evt) then
                table.insert(Events.ServerEvents, evt)
            end
        end
    end

    -- 生成CustomEvent节点
    for _, evt in pairs(Events.ServerEvents) do
        if world.S_Event[evt] == nil then
            world:CreateObject('CustomEvent', evt, world.S_Event)
        end
    end
end

--- 初始化心跳包
function InitHeartbeat()
    assert(ServerHeartbeat, '[Server][Heartbeat] 找不到ServerHeartbeat,请联系张远程')
    ServerHeartbeat.Init()
end

--- 初始化数据同步
function InitDataSync()
    assert(ServerDataSync, '[Server][DataSync] 找不到ServerDataSync,请联系张远程')
    ServerDataSync.Init()
end

--- 生成框架需要的节点
function InitCsvAndXls()
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
    ModuleUtil.GetModuleListWithFunc(Module.S_Module, 'InitDefault', initDefaultList)
    -- Init
    ModuleUtil.GetModuleListWithFunc(Define, 'Init', initList)
    ModuleUtil.GetModuleListWithFunc(Module.S_Module, 'Init', initList)
    -- Update
    ModuleUtil.GetModuleListWithFunc(Module.S_Module, 'Update', updateList)
    -- Plugin
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

--- 开始Update
function StartUpdate()
    print('[Server] StartUpdate()')
    assert(not running, '[Server] StartUpdate() 正在运行')

    running = true

    -- 开启心跳
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
        curr = now() / 1000
        dt = curr - prev
        tt = tt + dt
        prev = curr
        UpdateServer(dt, tt)
        --[[xpcall(
            function()
                --local a = 10 / nil
               
            end,
            function(err)
                ErrorShow(err)
                error(err)
            end
        )]]
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

return Server
