--- 将Global.Module目录下每一个用到模块提前require,定义为全局变量
-- @script Module Defines
-- @copyright Lilith Games, Avatar Team

-- Utilities
ModuleUtil = require(Utility.ModuleUtilModule)
LuaJsonUtil = require(Utility.LuaJsonUtilModule)
NetUtil = require(Utility.NetUtilModule)
CsvUtil = require(Utility.CsvUtilModule)
XlsUtil = require(Utility.XlsUtilModule)
EventUtil = require(Utility.EventUtilModule)
UUID = require(Utility.UuidModule)
LinkedList = Utility.LinkedListModule
TimeUtil = require(Utility.TimeUtilModule)
TimeUtil.Init()

-- Framework
ModuleUtil.LoadModules(Framework)

-- Globle Defines, Server and Clinet Modules
ModuleUtil.LoadModules(Define)
ModuleUtil.LoadXlsModules(Xls, Config)
ModuleUtil.LoadModules(Module.S_Module)
ModuleUtil.LoadModules(Module.C_Module)

-- Plugin Modules
GuideSystem = require(world.Global.Plugin.FUNC_Guide.GuideSystemModule)
