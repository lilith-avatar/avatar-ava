--- 游戏客户端主逻辑
-- @module Game Manager, Client-side
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
local Client = {}

-- Localize global vars
local CsvUtil, XslUitl, ModuleUtil = CsvUtil, XslUitl, ModuleUtil

-- 已经初始化，正在运行
local initialized, running = false, false

-- 含有InitDefault(),Init(),Update()的模块列表
local initDefaultList, initList, updateList = {}, {}, {}

--- 运行客户端
function Client:Run()
    print('[Client] Run()')
    InitClient()
    StartUpdate()
end

--- 停止Update
function Client:Stop()
    print('[Client] Stop()')
    running = false
    ClientHeartbeat.Stop()
end

--- 初始化
function InitClient()
    if initialized then
        return
    end
    print('[Client] InitClient()')
    InitRandomSeed()
    InitHeartbeat()
    InitClientCustomEvents()
    PreloadCsv()
    GenInitAndUpdateList()
    RunInitDefault()
    InitOtherModules()
    initialized = true
end

--- 初始化心跳包
function InitHeartbeat()
    assert(ClientHeartbeat, '[Client][Heartbeat] 找不到ClientHeartbeat,请联系张远程')
    ClientHeartbeat.Init()
end

--- 初始化客户端的CustomEvent
function InitClientCustomEvents()
    if localPlayer.C_Event == nil then
        world:CreateObject('FolderObject', 'C_Event', localPlayer)
    end
    for _, evt in pairs(Events.ClientEvents) do
        world:CreateObject('CustomEvent', evt, localPlayer.C_Event)
    end
end

--- 生成需要Init和Update的模块列表
function GenInitAndUpdateList()
    ModuleUtil.GetModuleListWithFunc(Module.C_Module, 'InitDefault', initDefaultList)
    ModuleUtil.GetModuleListWithFunc(Module.C_Module, 'Init', initList)
    ModuleUtil.GetModuleListWithFunc(Module.C_Module, 'Update', updateList)
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

--- 预加载所有的CSV表格
function PreloadCsv()
    print('[Client] PreloadCsv()')
    CsvUtil.PreloadCsv(Config.ClientPreload, Csv, Config)
end

--- 初始化包含Init()方法的模块
function InitOtherModules()
    for _, m in ipairs(initList) do
        m:Init()
    end
end

--- 开始Update
function StartUpdate()
    print('[Client] StartUpdate()')
    assert(not running, '[Client] StartUpdate() 正在运行')

    running = true

    -- 开启心跳
    invoke(ClientHeartbeat.Start)

    local dt = 0 -- delta time 每帧时间
    local tt = 0 -- total time 游戏总时间

    while (running) do
        dt = wait()
        tt = tt + dt
        UpdateClient(dt, tt)
    end
end

--- Update函数
-- @param dt delta time 每帧时间
function UpdateClient(_dt, _tt)
    for _, m in ipairs(updateList) do
        m:Update(_dt, _tt)
    end
end

return Client
