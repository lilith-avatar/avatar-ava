--- 全局默认定义：用于定义数据，节点属性等
--- @module Data Default
--- @copyright Lilith Games, Avatar Team
local Default = {}

--! 说明：这个module当作脚本使用

--* Data.Global和Data.Player中的默认值，用于框架初始化

Data.Default = Data.Default or {}

-- 全局变量定义
Data.Default.Global = {}

-- 玩家数据，初始化定义
Data.Default.Player = {
    -- 玩家ID, 框架默认
    uid = '',
    -- 玩家属性
    attr = {},
    -- 背包
    bag = {},
    -- 统计数据
    stats = {}
}

return Default
