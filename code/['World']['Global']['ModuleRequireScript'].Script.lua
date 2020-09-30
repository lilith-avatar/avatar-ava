--- 将Global.Module目录下每一个用到模块提前require,定义为全局变量
-- @script Module Defines
-- @copyright Lilith Games, Avatar Team

-- Log utility
local LogUtil = require(Utility.LogUtilModule)
-- 封装四个全局接口
test = LogUtil.Test
debug = LogUtil.Debug
info = LogUtil.Info
warn = LogUtil.Warn

-- 定义日志等级、开关
LogUtil.level = LogUtil.LevelEnum.DEBUG
LogUtil.debugMode = true

-- Utilities
NetUtil = require(Utility.NetUtilModule)
CsvUtil = require(Utility.CsvUtilModule)
EventUtil = require(Utility.EventUitlModule)
UUID = require(Utility.UuidModule)
LinkedList = Utility.LinkedListModule
LuaJsonUtil = require(Utility.LuaJsonUtilModule)
-- Defines
GlobalDef = require(Define.GlobalDefModule)
ConstDef = require(Define.ConstDefModule)

-- Server Modules
GameMgr = require(Module.S_Module.GameMgrModule)
TimeMgr = require(Module.S_Module.TimeMgrModule)
GameCsv = require(Module.S_Module.GameCsvModule)
ExampleA = require(Module.S_Module.ExampleAModule)

-- Client Modules
PlayerMgr = require(Module.C_Module.PlayerMgrModule)
PlayerCsv = require(Module.C_Module.PlayerCsvModule)
ExampleB = require(Module.C_Module.ExampleBModule)
Notice = require(Module.C_Module.NoticeModule)

-- Plugin Modules
AnimationMain = require(world.Global.Plugin.FUNC_UIAnimation.Code.AnimationMainModule)
GuideSystem = require(world.Global.Plugin.FUNC_Guide.GuideSystemModule)