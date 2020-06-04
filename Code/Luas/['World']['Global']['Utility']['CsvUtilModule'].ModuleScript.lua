--- 读表工具: 讲CSV导入成Lua Table，支持单一主键和多主键
-- @module CSV Utility
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
-- @see https://wiki.lilithgames.com/x/RGEMAg
local CsvUtil = {}

--- 读取配置表,会根据id生成lua表
-- @param _csv 表格
-- @parma ... 表格的主键ids,可以为单一主键或多主键(多主键的id顺序决定lua table的结构)
-- @usage exmaple #1 如果, 单一键值为主键
-- Level.csv 表格内容为:
-- ----------------------------------
-- | String   | String     | Int    |
-- | level_id | level_name | reward |
-- | easy_01  | Level 01   | 100    |
-- | easy_02  | Level 02   | 140    |
-- | hard_01  | Level 03   | 280    |
-- | hard_02  | Level 04   | 320    |
-- ----------------------------------
-- 调用函数 local levelCsv = CsvUtil.GetCsvInfo(Level, 'level_id') 导入的lua表格结果为:
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
-- @usage exmaple #2 如果, 多键值为主键
-- Enemy.csv 表格内容为:
-- ----------------------------------
-- | String   | String     | Int    |
-- | enemy_id | difficulty | hp     |
-- | foe_01   | easy       | 100    |
-- | foe_01   | hard       | 150    |
-- | foe_02   | easy       | 300    |
-- | foe_02   | hard       | 400    |
-- ----------------------------------
-- 调用函数 local enemyCsv = CsvUtil.GetCsvInfo(Enemy, 'enemy_id', 'difficulty') 导入的lua表格结果为:
-- enemyCsv = {
--     foe_01 = {
--         easy = {
--             enemy_id = 'foe_01',
--             difficulty = 'easy',
--             hp = 100
--         },
--         hard = {
--             enemy_id = 'foe_02',
--             difficulty = 'hard',
--             hp = 150
--         }
--     },
--     foe_02 = {
--         esay = {
--             enemy_id = 'foe_02',
--             difficulty = 'easy',
--             hp = 300
--         },
--         hard = {
--             enemy_id = 'foe_02',
--             difficulty = 'hard',
--             hp = 400
--         }
--     }
-- }
-- 使用lua table中的数据方法:
-- health = enemyCsv.foe_01.hard.hp 或 health = enemyCsv['foe_01']['hard']['hp']
-- health的值为150
function CsvUtil.GetCsvInfo(_csv, ...)
    local rawTable = _csv:GetRows()
    local ids = {...}
    if #ids < 1 or (#ids == 1 and ids[1] == 'Type') then
        -- 直接返回
        return rawTable
    end
    local result = {}
    local tmp = result
    local key, id
    for _, v in pairs(rawTable) do
        tmp = result
        for i = 1, #ids do
            id = ids[i]
            key = v[id]
            if string.isnilorempty(key) then
                error(string.format('CSV表格没有找到此id, CSV:%s, id: %s', _csv.Name, id))
            end
            if i == #ids then
                -- 最后的键，确定唯一性
                if tmp[key] ~= nil then
                    table.dump(v)
                    error(string.format('CSV数据重复, ids不是唯一的, CSV: %s, ids: %s', _csv.Name, tostring(...)))
                else
                    tmp[key] = v
                end
            else
                -- 多键，之后还有
                if tmp[key] == nil then
                    tmp[key] = {}
                end
                tmp = tmp[key]
            end
        end
    end
    return result
end

return CsvUtil
