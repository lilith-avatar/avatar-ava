--- 客户端代码入口
-- @script Client Awake Function
-- @copyright Lilith Games, Avatar Team, Dead Ratman
-- @author Dead Ratman
_G.C = Client
ModuleUtil.LoadModules(world.Client.Module, C)
C:Run()
