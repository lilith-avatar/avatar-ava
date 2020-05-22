--- 将Global.Module目录下每一个用到模块提前require,定义为全局变量
-- @script Module Defines
-- @copyright Lilith Games, Avatar Team

-- Log utility
local LogUtil = require(Utility.LogUtilModule)
-- 封装四个全局接口
debug = LogUtil.Debug
info = LogUtil.Info
warn = LogUtil.Warn
error = LogUtil.Error

-- 定义日志等级、开关
LogUtil.level = LogUtil.LevelEnum.DEBUG
LogUtil.debugMode = true

-- Utilities
NetUtil = require(Utility.NetUtilModule)
CsvUtil = require(Utility.CsvUtilModule)
EventUtil = require(Utility.EventUitlModule)
CamUtil = require(Utility.CamUtilModule)
SoundUtil = require(Utility.SoundUtilModule)
LuaJson = require(Utility.LuaJsonUtilModule)

-- Defines
GlobalDef = require(Define.GlobalDefModule)
ConstDef = require(Define.ConstDefModule)

-- Server Modules
GameMgr = require(Module.S_Module.GameMgrModule)
TimeMgr = require(Module.S_Module.TimeMgrModule)
CsvConfig = require(Module.S_Module.CsvConfigModule)
ExampleA = require(Module.S_Module.ExampleAModule)

-- Client Modules
PlayerMgr = require(Module.C_Module.PlayerMgrModule)
ExampleB = require(Module.C_Module.ExampleBModule)
