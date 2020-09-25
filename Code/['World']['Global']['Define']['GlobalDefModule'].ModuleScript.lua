--- 全局变量的定义,全部定义在GlobalDef这张表下面,用于全局可修改的参数
-- @module Global Defines
-- @copyright Lilith Games, Avatar Team
local GlobalDef = {}

-- e.g. (need DELETE)
GlobalDef.a = 123

GlobalDef.b = {
    tom = '1231',
    bob = '23423'
}

-- TODO: other constant defines

return GlobalDef
