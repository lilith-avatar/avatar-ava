--- 服务器代码入口
-- @script Server Awake Function
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang, Dead Ratman
_G.S = Server
ModuleUtil.LoadModules(world.Server.Module, S)
S:Run()


