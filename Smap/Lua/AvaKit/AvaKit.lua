--- 将Global.Module目录下每一个用到模块提前require,定义为全局变量
--- @module Module Defines
--- @copyright Lilith Games, Avatar Team

local AvaKit = {}
local PATH_ROOT = 'Lua/'
local PATH_AVAKIT = 'Lua/AvaKit/'
local PATH_LUA_EXT = PATH_AVAKIT .. 'LuaExt/'
local PATH_UTIL = PATH_AVAKIT .. 'Util/'
local PATH_FRAMEWORK = PATH_AVAKIT .. 'Framework/'
local PATH_CLIENT = PATH_AVAKIT .. 'Framework/Client/'
local PATH_SERVER = PATH_AVAKIT .. 'Framework/Server/'

local started = false

--- 初始化Lua扩展库
function InitLuaExt()
    require(PATH_LUA_EXT .. 'GlobalExt')
    require(PATH_LUA_EXT .. 'StringExt')
    require(PATH_LUA_EXT .. 'TableExt')
    require(PATH_LUA_EXT .. 'MathExt')
    _G.Queue = require(PATH_LUA_EXT .. 'Queue')
    _G.Stack = require(PATH_LUA_EXT .. 'Stack')
end

--- 初始化AvaKit
function InitAvaKit()
    InitGlobal()
    RequireConfig()
    RequireUtils()
    RequireFramework()
    RequireManifest()
    InitCommonModules()
end

--- 初始化Global
function InitGlobal()
    _G.Ava = {}
    _G.Data = Data or {}
    _G.Data.Global = Data.Global or {}
    _G.Data.Player = Data.Player or {}
    _G.Data.Players = Data.Players or {}
end

--- 预初始化Client
function PreInitClient()
    _G.C = {}
end

--- 预初始化Server
function PreInitServer()
    _G.S = {}
end

--- 引用工具模块
function RequireConfig()
    Ava.Config = require(PATH_AVAKIT .. 'Config')
end

--- 引用工具模块
function RequireUtils()
    Ava.Util = {}

    -- Require Utils
    Ava.Util.Mod = require(PATH_UTIL .. 'Module')
    Ava.Util.LuaJson = require(PATH_UTIL .. 'LuaJson')
    Ava.Util.Net = require(PATH_UTIL .. 'Net')
    Ava.Util.Event = require(PATH_UTIL .. 'Event')
    Ava.Util.Time = require(PATH_UTIL .. 'Time')

    -- Init Utils
    Ava.Util.Time.Init()

    --FIXME: 为了向下兼容
    _G.JSON = Ava.Util.LuaJson
    _G.NetUtil = Ava.Util.Net
end

--- 引用框架
function RequireFramework()
    -- Framework
    Ava.Framework = {}
    Ava.Framework.MetaData = require(PATH_FRAMEWORK .. 'MetaData')

    -- Client
    Ava.Framework.Client = {}
    Ava.Framework.Client.Base = require(PATH_CLIENT .. 'ClientBase')
    Ava.Framework.Client.DataSync = require(PATH_CLIENT .. 'ClientDataSync')
    Ava.Framework.Client.Heartbeat = require(PATH_CLIENT .. 'ClientHeartbeat')
    Ava.Framework.Client.Main = require(PATH_CLIENT .. 'ClientMain')

    -- Server
    Ava.Framework.Server = {}
    Ava.Framework.Server.Base = require(PATH_SERVER .. 'ServerBase')
    Ava.Framework.Server.DataSync = require(PATH_SERVER .. 'ServerDataSync')
    Ava.Framework.Server.Heartbeat = require(PATH_SERVER .. 'ServerHeartbeat')
    Ava.Framework.Server.Main = require(PATH_SERVER .. 'ServerMain')

    --FIXME: 向下兼容
    _G.ClientBase = Ava.Framework.Client.Base
    _G.ServerBase = Ava.Framework.Server.Base
    _G.MetaData = Ava.Framework.MetaData
end

--- 引用Manifest
function RequireManifest()
    Ava.Manifest = {}
    Ava.Manifest.Common = require(PATH_ROOT .. 'Common/Manifest')
    Ava.Manifest.Client = require(PATH_ROOT .. 'Client/Manifest')
    Ava.Manifest.Server = require(PATH_ROOT .. 'Server/Manifest')
end

--- 加载Common脚本
function InitCommonModules()
    Ava.Util.Mod.LoadManifest(_G, Ava.Manifest.Common, Ava.Manifest.Common.ROOT_PATH)
end

--- 开始AvaKit
function AvaKit.Start()
    if started then
        return
    end
    Debug.Log('[AvaKit] Start()')
    InitLuaExt()
    InitAvaKit()
end

--- 启动客户端
function AvaKit.StartClient()
    PreInitClient()
    AvaKit.Start()
    Debug.Log('Ava.Framework.Client.Main:Run()')
    Ava.Framework.Client.Main:Run()
end

--- 启动服务器
function AvaKit.StartServer()
    PreInitServer()
    AvaKit.Start()
    Debug.Log('Ava.Framework.Server.Main:Run()')
    Ava.Framework.Server.Main:Run()
end

return AvaKit
