--- CSV表格的定义，用于CSV表格载入
-- @module Csv Defines
-- @copyright Lilith Games, Avatar Team
local Config = {}

-- 服务器预加载CSV
-- csv: 对应的CSV表名
-- name: Config里面的lua table名称, 可自定义, 默认和csv相同
-- ids: 表格主键, 支持多主键
Config.ServerPreload = {
    {
        xls = 'Sound', --SoundUtil模块调用
        ids = {'ID'}
    },
    {
        xls = 'AllItem', -- 刷新物品配置表
        ids = {'ItemID'}
    },
    {
        xls = 'Bridge',
        ids = {'BridgeName'}
    },
    {
        xls = 'GlobalSetting',
        ids = {'Key'}
    },
    {
        xls = 'TimeEvent',
        ids = {'ID'}
    },
    {
        xls = 'Chest', -- 宝箱数据表
        ids = {'ID'}
    },
    {
        xls = 'ChestSpawn', -- 岛屿宝箱生成
        ids = {'PlaneID'}
    },
    {
        xls = 'IslandMap' -- 岛屿上，宝箱等实例生成点
    },
    {
        xls = 'ShieldItem',
        ids = {'ItemID'}
    }
}

-- 客户端预加载CSV
-- csv: 对应的CSV表名
-- name: Config里面的lua table名称, 可自定义, 默认和csv相同
-- ids: 表格主键, 支持多主键
Config.ClientPreload = {
    {
        xls = 'AllItem',
        ids = {'ItemID'}
    },
    {
        xls = 'DrugItem',
        ids = {'ItemID'}
    },
    {
        xls = 'GlobalSetting',
        ids = {'Key'}
    },
    {
        xls = 'TimeEvent',
        ids = {'ID'}
    },
    {
        xls = 'Notice',
        ids = {'NoticeID'}
    },
    {
        xls = 'ShieldItem',
        ids = {'ItemID'}
    }
}

return Config
