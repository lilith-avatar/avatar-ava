--- 读表工具: 讲CSV导入成Lua Table，支持单一主键和多主键
-- @module CSV Utility
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
-- @see https://wiki.lilithgames.com/x/RGEMAg
local CsvUtil = {}

--- 读取配置表,会根据id生成lua表
-- @param _csv 表格
-- @parma _id 表格的
-- @parma _isPrimaryKey 是否为主键,默认值为true
-- @usage exmaple #1 如果 _isPrimaryKey == true, 单一键值为主键
-- Level.csv 表格内容为:
-- ----------------------------------
-- | String   | String     | Int    |
-- | level_id | level_name | reward |
-- | easy_01  | Level 01   | 100    |
-- | easy_02  | Level 02   | 140    |
-- | hard_01  | Level 03   | 280    |
-- | hard_02  | Level 04   | 320    |
-- ----------------------------------
-- 调用函数 local levelCsv = CsvUtil.GetCsvInfo(Level, 'level_id', true) 导入的lua表格结果为:
-- levelCsv = {
--     easy_01 = {
--         level_id = 'easy_01',
--         level_name = 'Level 01',
--         reward = 100
--     },
--     easy_02 = {
--         level_id = 'easy_02',
--         level_name = 'Level 02',
--         reward = 140
--     },
--     hard_01 = {
--         level_id = 'hard_01',
--         level_name = 'Level 03',
--         reward = 280
--     },
--     hard_02 = {
--         level_id = 'hard_02',
--         level_name = 'Level 04',
--         reward = 320
--     }
-- }
-- @usage exmaple #2 如果 _isPrimaryKey == false, 多键值为主键
-- Enemy.csv 表格内容为:
-- ----------------------------------
-- | String   | String     | Int    |
-- | enemy_id | difficulty | hp     |
-- | foe_01   | easy       | 100    |
-- | foe_01   | hard       | 150    |
-- | foe_02   | easy       | 300    |
-- | foe_02   | hard       | 400    |
-- ----------------------------------
-- 调用函数 local enemyCsv = CsvUtil.GetCsvInfo(Enemy, 'enemy_id', false) 导入的lua表格结果为:
-- enemyCsv = {
--     foe_01 = {
--         [1] = {
--             enemy_id = 'foe_01',
--             difficulty = 'easy',
--             hp = 100
--         },
--         [2] = {
--             enemy_id = 'foe_02',
--             difficulty = 'hard',
--             hp = 150
--         }
--     },
--     foe_02 = {
--         [1] = {
--             enemy_id = 'foe_02',
--             difficulty = 'easy',
--             hp = 300
--         },
--         [2] = {
--             enemy_id = 'foe_02',
--             difficulty = 'hard',
--             hp = 400
--         }
--     }
-- }
function CsvUtil.GetCsvInfo(_csv, _id, _isPrimaryKey)
    _isPrimaryKey = _isPrimaryKey or _isPrimaryKey == nil -- default is true
    local tmp = _csv:GetRows()
    local result = {}
    if _id == 'Type' or _id == 'type' then
        for _, v in pairs(tmp) do
            table.insert(result, v)
        end
    else
        for k, v in pairs(tmp) do
            if v[_id] == nil then
                print(string.format('CSV缺少参数：csv:%s, _id:%s', _csv.Name, _id))
                return
            end
            if _isPrimaryKey then
                -- id是唯一主键
                if result[v[_id]] ~= nil then
                    print(string.format('CSV数据覆盖：csv:%s, _id:%s', _csv.Name, _id))
                end
                result[v[_id]] = v
                v.Type = tonumber(k)
            else
                -- id不是主键,合并同id的数据
                if result[v[_id]] == nil then
                    result[v[_id]] = {}
                end
                table.insert(result[v[_id]], v)
            end
        end
    end
    print(string.format('CSV数据载入: _csv:%s', _csv.Name))
    return result
end

return CsvUtil
