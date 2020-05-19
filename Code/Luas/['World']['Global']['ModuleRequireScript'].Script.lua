--- 将Global.Module目录下每一个用到模块提前require,定义为全局变量
-- @script Module Defines
-- @copyright Lilith Games, Avatar Team

-- Log utility
local LogUtil = require(Utility.LogUtilModule)
debug = LogUtil.Debug
info = LogUtil.Info
warn = LogUtil.Warn
error = LogUtil.Error

-- 定义日志等级
LogUtil.level = LogUtil.LevelEnum.DEBUG

-- Utilities
NetUtil = require(Utility.NetUtilModule)
CsvUtil = require(Utility.CsvUtilModule)
EventUtil = require(Utility.EventUitlModule)

-- Defines
GlobalDef = require(Define.GlobalDefModule)
ConstDef = require(Define.ConstDefModule)

-- Server Modules
GameMgr = require(Module.S_Module.GameMgrModule)
CsvConfig = require(Module.S_Module.CsvConfigModule)
ExampleA = require(Module.S_Module.ExampleAModule)

-- Client Modules
PlayerMgr = require(Module.C_Module.PlayerMgrModule)
ExampleB = require(Module.C_Module.ExampleBModule)
