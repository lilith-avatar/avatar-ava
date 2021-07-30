--- CSV表格的定义，用于CSV表格载入
--- @module Config Defines
--- @copyright Lilith Games, Avatar Team
local Config = {}

-- 服务器预加载CSV
-- csv: 对应的CSV表名
-- name: Config里面的lua table名称, 可自定义, 默认和csv相同
-- ids: 表格主键, 支持多主键
Config.ServerPreload = {}

-- 客户端预加载CSV
-- csv: 对应的CSV表名
-- name: Config里面的lua table名称, 可自定义, 默认和csv相同
-- ids: 表格主键, 支持多主键
Config.ClientPreload = {}

return Config
