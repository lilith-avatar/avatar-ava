--- 全局常量的定义,全部定义在ConstDef这张表下面,用于定义全局常量参数或者枚举类型
-- @module Constant Defines
-- @copyright Lilith Games, Avatar Team
local ConstDef = {}

-- e.g. (need DELETE)
ConstDef.MAX_PLAYERS = 4

ConstDef.MonsterTypeEnum = {
    FOE = 0,
    VILLAGER = 1,
    BOSS = 2
}

-- TODO: other constant defines

return ConstDef
