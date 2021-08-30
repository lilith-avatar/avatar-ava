--- 游戏客户端主逻辑
--- @module Game Manager, Client-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local Client = {}

-- 缓存全局变量
local Ava = Ava
local Heartbeat = Ava.Framework.Client.Heartbeat
local DataSync = Ava.Framework.Client.DataSync

-- 已经初始化，正在运行
local initialized, running = false, false

-- 含有InitDefault(),Init(),Update()的模块列表
local list = {}
local initDefaultList, initList, updateList = {}, {}, {}

--! Public

--- 运行客户端
function Client:Run()
    print('[AvaKit][Client] Run()')
    InitClient()
    StartUpdate()
end

--- 停止Update
function Client:Stop()
    print('[AvaKit][Client] Stop()')
    running = false
    Heartbeat.Stop()
end

--! Private

--- 初始化
function InitClient()
    if initialized then
        return
    end
    print('[AvaKit][Client] InitClient()')
    RequireClientModules()
    InitRandomSeed()
    InitHeartbeat()
    InitDataSync()
    InitClientCustomEvents()
    GenInitAndUpdateList()
    RunInitDefault()
    InitOtherModules()
    initialized = true
end

--- 加载客户端模块
function RequireClientModules()
    print('[AvaKit][Client] RequireClientModules()')
    _G.C.Events = Ava.Manifest.Client.Events
    Ava.Util.Mod.LoadManifest(_G.C, Ava.Manifest.Client, Ava.Manifest.Client.ROOT_PATH, list)
end

--- 初始化心跳包
function InitHeartbeat()
    assert(Heartbeat, '[AvaKit][Client][Heartbeat] 找不到Ava.Framework.Client.Heartbeat,请联系endaye')
    Heartbeat.Init()
end

--- 初始化数据同步
function InitDataSync()
    if not Ava.Config.DataSyncStart then
        return
    end
    assert(DataSync, '[AvaKit][Server][DataSync] 找不到ServerDataSync,请联系endaye')
    DataSync.Init()
end

--- 初始化客户端的CustomEvent
function InitClientCustomEvents()
    if localPlayer.C_Event == nil then
        world:CreateObject('FolderObject', 'C_Event', localPlayer)
    end

    -- 生成CustomEvent节点
    for _, evt in pairs(C.Events) do
        if localPlayer.C_Event[evt] == nil then
            world:CreateObject('CustomEvent', evt, localPlayer.C_Event)
        end
    end
end

--- 生成需要Init和Update的模块列表
function GenInitAndUpdateList()
    -- print(table.dump(list))
    Ava.Util.Mod.GetModuleListWithFunc(list, 'InitDefault', initDefaultList)
    Ava.Util.Mod.GetModuleListWithFunc(list, 'Init', initList)
    Ava.Util.Mod.GetModuleListWithFunc(list, 'Update', updateList)
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

--- 初始化包含Init()方法的模块
function InitOtherModules()
    for _, m in ipairs(initList) do
        m:Init()
    end
end

--- 开始Update
function StartUpdate()
    print('[AvaKit][Client] StartUpdate()')
    assert(not running, '[AvaKit][Client] StartUpdate() 正在运行')

    running = true

    -- 开启心跳
    if Ava.Config.HeartbeatStart then
        invoke(Heartbeat.Start)
    end

    local dt = 0 -- delta time 每帧时间
    local tt = 0 -- total time 游戏总时间
    local now = Timer.GetTimeMillisecond --时间函数缓存
    local prev, curr = now() / 1000, nil -- two timestamps

    while (running and wait()) do
        curr = now() / 1000
        dt = curr - prev
        tt = tt + dt
        prev = curr
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
