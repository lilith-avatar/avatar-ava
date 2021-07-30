--- 将Global.Module目录下每一个用到模块提前require,定义为全局变量
--- @script Module Defines
--- @copyright Lilith Games, Avatar Team

-- Utilities
ModuleUtil = require(Utility.ModuleUtilModule)
LuaJsonUtil = require(Utility.LuaJsonUtilModule)
NetUtil = require(Utility.NetUtilModule)
SoundUtil = require(Utility.SoundUtilModule)
CsvUtil = require(Utility.CsvUtilModule)
XlsUtil = require(Utility.XlsUtilModule)
EventUtil = require(Utility.EventUtilModule)
UUID = require(Utility.UuidModule)
StateMachineUtil = require(Utility.StateMachineModule)
TweenController = require(Utility.TweenControllerModule)
GlobalFunc = require(Utility.GlobalFuncModule)
LinkedList = Utility.LinkedListModule
ValueChangeUtil = require(Utility.ValueChangeUtilModule)
TimeUtil = require(Utility.TimeUtilModule)
TimeUtil.Init()
CloudLogUtil = require(Utility.CloudLogUtilModule)
---填写游戏唯一ID
CloudLogUtil.Init('A1002')

-- Plugin Modules
AnimationMain = require(world.Global.Plugin.FUNC_UIAnimation.Code.AnimationMainModule)
GuideSystem = require(world.Global.Plugin.FUNC_Guide.GuideSystemModule)
AStar = require(world.Global.Plugin.AStar.AStarModule)

-- Framework
ModuleUtil.LoadModules(Framework)

-- Globle Defines, Server and Clinet Modules, Pretreatment
ModuleUtil.LoadModules(Define)
ModuleUtil.LoadXlsModules(Xls, Config)
ModuleUtil.LoadModules(Module.S_Module)
ModuleUtil.LoadModules(Module.C_Module)
ModuleUtil.LoadModules(Module.Cls_Module)
ModuleUtil.LoadModules(Module.Edit_Module)

-- DebugMode
DebugModeLogic.InitHook()
