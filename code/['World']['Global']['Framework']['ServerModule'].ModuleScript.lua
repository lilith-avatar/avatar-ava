--- 游戏服务器主逻辑
--- @module Game Server, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local Server = {}

-- Localize global vars
local CsvUtil, ModuleUtil = CsvUtil, ModuleUtil

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
function Stop()
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
    for _, evt in pairs(Events.ServerEvents) do
        world:CreateObject('CustomEvent', evt, world.S_Event)
    end
end

--- 初始化心跳包
function InitHeartbeat()
    assert(ServerHeartbeat, '[Server][Heartbeat] 找不到ServerHeartbeat,请联系张远程')
    ServerHeartbeat.Init()
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
    ModuleUtil.GetModuleListWithFunc(Module.S_Module, 'InitDefault', initDefaultList)
    ModuleUtil.GetModuleListWithFunc(Module.S_Module, 'Init', initList)
    ModuleUtil.GetModuleListWithFunc(Module.S_Module, 'Update', updateList)
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
    invoke(ServerHeartbeat.Start)

    local dt = 0 -- delta time 每帧时间
    local tt = 0 -- total time 游戏总时间

    while (running) do
        dt = wait()
        tt = tt + dt
        UpdateServer(dt, tt)
    end
end

--- Update函数
--- @param dt delta time 每帧时间
function UpdateServer(_dt, _tt)
    for _, m in ipairs(updateList) do
        m:Update(_dt, _tt)
    end
end

return Server
