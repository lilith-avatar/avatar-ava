--- 游戏客户端主逻辑
-- @module Game Manager, Client-side
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
local Client = {
    isRun = false,
    dt = 0, -- delta time 每帧时间
    tt = 0 -- total time 游戏总时间
}

-- Localize global vars
local CsvUtil, XslUitl, ModuleUtil = CsvUtil, XslUitl, ModuleUtil

-- 含有InitDefault(),Init(),Update()的模块列表
local initDefaultList, initList, updateList = {}, {}, {}

--- 运行客户端
function Client:Run()
    self:InitClient()
    self:StartUpdate()
end

--- 初始化
function Client:InitClient()
    print('[Client] InitClient()')
    self:InitClientCustomEvents()
    self:PreloadCsv()
    self:PreloadXls()
    self:GenInitAndUpdateList()
    self:RunInitDefault()
    AnimationMain:Init()
    self:InitOtherModules()
end

--- 预加载所有的CSV表格
function Client:PreloadCsv()
    print('[Client] PreloadCsv()')
    CsvUtil.PreloadCsv(Config.ClientPreload, Csv, Config)
end

--- 预加载所有的Excel Lua Table
function Client:PreloadXls()
    print('[Client] PreloadXls()')
    XlsUtil.PreloadXls(Config.ClientPreload, Xls, Config)
end

--- 初始化客户端的CustomEvent
function Client:InitClientCustomEvents()
    if localPlayer.C_Event == nil then
        world:CreateObject('FolderObject', 'C_Event', localPlayer)
    end
    for _, evt in pairs(Events.ClientEvents) do
        world:CreateObject('CustomEvent', evt, localPlayer.C_Event)
    end
end

--- 生成需要Init和Update的模块列表
function Client:GenInitAndUpdateList()
    ModuleUtil.GetModuleListWithFunc(Module.C_Module, 'InitDefault', initDefaultList)
    ModuleUtil.GetModuleListWithFunc(Module.C_Module, 'Init', initList)
    ModuleUtil.GetModuleListWithFunc(Module.C_Module, 'Update', updateList)
end

--- 执行默认的Init方法
function Client:RunInitDefault()
    for _, m in ipairs(initDefaultList) do
        m:InitDefault(m)
    end
end

--- 初始化包含Init()方法的模块
function Client:InitOtherModules()
    for _, m in ipairs(initList) do
        m:Init()
    end
end

--- Update函数
-- @param dt delta time 每帧时间
function Client:UpdateClient(_dt, _tt)
    for _, m in ipairs(updateList) do
        m:Update(_dt, _tt)
    end
end

function Client:StartUpdate()
    assert(not self.isRun, '[Client] StartUpdate() 正在运行')

    self.isRun = true

    while (self.isRun) do
        self.dt = wait()
        self.tt = self.tt + self.dt
        self:UpdateClient(self.dt, self.tt)
    end
end

function Client:StopUpdate()
    print('[Client] StopUpdate()')
    self.isRun = false
end

return Client
