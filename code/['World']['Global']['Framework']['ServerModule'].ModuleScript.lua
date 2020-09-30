--- 游戏服务器主逻辑
--- @module Game Manager, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local Server = {
    isRun = false,
    dt = 0, -- delta time 每帧时间
    tt = 0 -- total time 游戏总时间
}

-- Localize global vars
local CsvUtil, ModuleUtil = CsvUtil, ModuleUtil

-- 含有InitDefault(),Init(),Update()的模块列表
local initDefaultList, initList, updateList = {}, {}, {}

--- 运行服务器
function Server:Run()
    self:InitServer()
    self:StartUpdate()
end

--- 初始化
function Server:InitServer()
    print('[Server] InitServer()')
    self:InitServerCustomEvents()
    self:InitCsvAndXls()
    self:PreloadCsv()
    self:PreloadXls()
    self:GenInitAndUpdateList()
    self:RunInitDefault()
    self:InitOtherModules()
end

--- 初始化服务器的CustomEvent
function Server:InitServerCustomEvents()
    print('[Server] InitServerCustomEvents()')
    if world.S_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', world)
    end
    for _, evt in pairs(Events.ServerEvents) do
        world:CreateObject('CustomEvent', evt, world.S_Event)
    end
end

--- 生成框架需要的节点
function Server:InitCsvAndXls()
    if not world.Global.Csv then
        world:CreateObject('FolderObject', 'Csv', world.Global)
    end
    if not world.Global.Xls then
        world:CreateObject('FolderObject', 'Xls', world.Global)
    end
end

--- 预加载所有的CSV表格
function Server:PreloadCsv()
    print('[Client] PreloadCsv()')
    CsvUtil.PreloadCsv(Config.ServerPreload, Csv, Config)
end

--- 预加载所有的Excel Lua Table
function Server:PreloadXls()
    print('[Server] PreloadXls()')
    XlsUtil.PreloadXls(Config.ServerPreload, Xls, Config)
end

--- 生成需要Init和Update的模块列表
function Server:GenInitAndUpdateList()
    ModuleUtil.GetModuleListWithFunc(Module.S_Module, 'InitDefault', initDefaultList)
    ModuleUtil.GetModuleListWithFunc(Module.S_Module, 'Init', initList)
    ModuleUtil.GetModuleListWithFunc(Module.S_Module, 'Update', updateList)
end

--- 执行默认的Init方法
function Server:RunInitDefault()
    for _, m in ipairs(initDefaultList) do
        m:InitDefault(m)
    end
end

--- 初始化包含Init()方法的模块
function Server:InitOtherModules()
    for _, m in ipairs(initList) do
        m:Init()
    end
end

--- Update函数
--- @param dt delta time 每帧时间
function Server:UpdateServer(_dt, _tt)
    for _, m in ipairs(updateList) do
        m:Update(_dt, _tt)
    end
end

--- 开始Update
function Server:StartUpdate()
    print('[Server] StartUpdate()')
    assert(not self.isRun, '[Server] StartUpdate() 正在运行')

    self.isRun = true

    while (self.isRun) do
        self.dt = wait()
        self.tt = self.tt + self.dt
        self:UpdateServer(self.dt, self.tt)
    end
end

--- 停止Update
function Server:StopUpdate()
    print('[Server] StopUpdate()')
    self.isRun = false
end

return Server
