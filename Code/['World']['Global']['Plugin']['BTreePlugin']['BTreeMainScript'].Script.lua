--- @script Behavior tree start script 行为树启动脚本
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
_G.JSON = require(Plugin.BTreePlugin.JsonModule)
_G.B3 = require(Plugin.BTreePlugin.B3Module)
_G.ActionNode = require(Plugin.BTreePlugin.ActionNodeModule)
_G.CompositeNode = require(Plugin.BTreePlugin.CompositeNodeModule)
_G.ConditionNode = require(Plugin.BTreePlugin.ConditionNodeModule)
_G.DecoratorNode = require(Plugin.BTreePlugin.DecoratorNodeModule)
_G.CustomNode = require(Plugin.BTreePlugin.CustomNodeModule)

ActionNode:Init()
CompositeNode:Init()
ConditionNode:Init()
DecoratorNode:Init()
CustomNode:Init()
