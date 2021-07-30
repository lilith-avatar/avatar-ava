--- 游戏客户端主逻辑
--- @module Client Manager, Client-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local Client = {}

-- Localize global vars
local CsvUtil, XslUitl, ModuleUtil = CsvUtil, XslUitl, ModuleUtil
local Config = FrameworkConfig.Client

-- 已经初始化，正在运行
local initialized, running = false, false

-- 含有InitDefault(),Init(),Update()的模块列表
local initDefaultList, initList, updateList, fixUpdateList = {}, {}, {}, {}

--- 运行客户端
function Client:Run()
    print('[Client] Run()')
	--初始化客户端
    InitClient()
	--开启客户端的FixUpdate
    StartFixUpdate()
	--开启客户端的Update
    StartUpdate()
end

--- 停止Update
function Client:Stop()
    print('[Client] Stop()')
    running = false
	-- 客户端心跳停止
	-- 位置：ClientHeartbeatModule
    ClientHeartbeat.Stop()
	-- 位置：QualityBalanceModule
    QualityBalance.StopUpdate()
end

--- 初始化
function InitClient()
    if initialized then
        return
    end
    print('[Client] InitClient()')
	---初始化调试UI
    InitDebugUI()
	---初始化相机
    InitCamera()
	--- 初始化客户端随机种子
    InitRandomSeed()
	--- 初始化心跳包
    InitHeartbeat()
	---初始化插件
    InitPlugin()
	--- 初始化心跳包
    InitClientCustomEvents()
	--- 预加载所有的CSV表格
    PreloadCsv()
	--- 生成需要Init和Update的模块列表
    GenInitAndUpdateList()
	--- 执行默认的Init方法
    RunInitDefault()
	--- 初始化包含Init()方法的模块
    InitOtherModules()
	---初始化画质控制
    InitQualityBalance()
	--完成初始化
    initialized = true
end

---初始化调试UI
function InitDebugUI()
	--位置：Framework.DebugModeLogicModule
    DebugModeLogic.InitClient()
end

---初始化画质控制
function InitQualityBalance()
	--位置：Framework.QualityBalanceModule
    QualityBalance.Init()
end

---初始化相机
function InitCamera()
	--将客户端的当前摄像机设置为本地玩家的CamGame
    world.CurrentCamera = localPlayer.Local.Independent.CamGame
end

---初始化插件
function InitPlugin()
	--位置：Module.C_Module.PlayerGunMgrModule
    PlayerGunMgr:Init()
end

--- 初始化心跳包
function InitHeartbeat()
    assert(ClientHeartbeat, '[Client][Heartbeat] 找不到ClientHeartbeat,请联系张远程')
	--位置：Framework.ClientHeartbeatModule
    ClientHeartbeat.Init()
end

--- 初始化客户端的CustomEvent
function InitClientCustomEvents()
    if localPlayer.C_Event == nil then
        world:CreateObject('FolderObject', 'C_Event', localPlayer)
    end

    -- 将插件中的CustomEvent放入Events.ClientEvents中
    for _, m in pairs(Config.PluginEvents) do
        local evts = _G[m].ClientEvents
        assert(evts, string.format('[Client] %s 中不存在ClientEvents，请检查模块，或从FrameworkConfig删除此配置', m))
        for __, evt in pairs(evts) do
            if not table.exists(Events.ClientEvents, evt) then
                table.insert(Events.ClientEvents, evt)
            end
        end
    end

    -- 生成CustomEvent节点
    for _, evt in pairs(Events.ClientEvents) do
        if localPlayer.C_Event[evt] == nil then
            world:CreateObject('CustomEvent', evt, localPlayer.C_Event)
        end
    end
end

--- 生成需要Init和Update的模块列表
function GenInitAndUpdateList()
	--- 将有包含特定方法的模块筛选出来，并放在一个table中
	--位置：ModuleUtilModule
    ModuleUtil.GetModuleListWithFunc(Module.C_Module, 'InitDefault', initDefaultList)
    ModuleUtil.GetModuleListWithFunc(Module.C_Module, 'Init', initList)
    ModuleUtil.GetModuleListWithFunc(Module.C_Module, 'Update', updateList)
    ModuleUtil.GetModuleListWithFunc(Module.C_Module, 'FixUpdate', fixUpdateList)
    for _, m in pairs(Config.PluginModules) do
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

--- 初始化客户端随机种子
function InitRandomSeed()
    math.randomseed(os.time())
end

--- 预加载所有的CSV表格
function PreloadCsv()
    print('[Client] PreloadCsv()')
    if Config.ClientPreload and #Config.ClientPreload > 0 then
		--- 表格预加载，预加载配置模块：World.Global.Define.ConfigModule
		--位置：Utility.CsvUtilModule
        CsvUtil.PreloadCsv(Config.ClientPreload, Csv, Config)
    end
end

--- 初始化包含Init()方法的模块
function InitOtherModules()
    SoundUtil:Init()
    for _, m in ipairs(initList) do
        m:Init()
    end
	--位置：Plugin.FUNC_UIAnimation.Code.AnimationMainModule
	----- UI动画插件-表现相关初始化
    AnimationMain:Init()
end

function StartFixUpdate()
	--world连接客户端的FixUpdateClient()
    world.OnRenderStepped:Connect(Client.FixUpdateClient)
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

	--位置：Framework.QualityBalanceModule
	--开始均衡画面质量
    QualityBalance.StartUpdate()

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
    end
end

--- Update函数
-- @param dt delta time 每帧时间
function UpdateClient(_dt, _tt)
    for _, m in ipairs(updateList) do
        m:Update(_dt, _tt)
    end
end

---FixUpdate函数
function Client.FixUpdateClient(_dt)
	--执行保存的fixUpdateList以及uiList
    AnimationMain:FixUpdate(_dt)
    for _, m in ipairs(fixUpdateList) do
        m:FixUpdate(_dt)
    end
    for i, v in pairs(UIBase.uiList) do
        if v.Update then
            v:Update(_dt)
        end
    end
end

return Client
