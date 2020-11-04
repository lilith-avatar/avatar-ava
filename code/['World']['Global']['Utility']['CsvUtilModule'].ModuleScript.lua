--- 读表工具: 将CSV导入成Lua Table，支持单一主键和多主键
-- @module CSV Utility
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
-- @see https://wiki.lilithgames.com/x/RGEMAg
local CsvUtil = {}

--! 打印事件日志, true:开启打印
local showLog, PrintGlobalKV, PrintLog = true

--- 将表中的字符串改为数字
-- @param _t input table
local function StrToNum(_t)
    for k, v in pairs(_t) do
        _t[k] = tonumber(v)
    end
    return _t
end

--- 类型解析配置表
local parser = {
    int = function(_raw)
        return tonumber(_raw)
    end,
    float = function(_raw)
        return tonumber(_raw)
    end,
    string = function(_raw)
        return _raw
    end,
    boolean = function(_raw)
        return string.lower(_raw) == 'true'
    end,
    vector2 = function(_raw)
        return Vector2(table.unpack(StrToNum(string.split(_raw, ','))))
    end,
    vector3 = function(_raw)
        return Vector3(table.unpack(StrToNum(string.split(_raw, ','))))
    end,
    euler = function(_raw)
        return EulerDegree(table.unpack(StrToNum(string.split(_raw, ','))))
    end,
    color = function(_raw)
        return Color(table.unpack(StrToNum(string.split(_raw, ','))))
    end
}

--- 读取配置表,会根据id生成lua表
-- @param _type String 数据类型
-- @parm _stringValue String 数据
-- @return value 解析出来的数值
local function GetValue(_type, _stringValue)
    _type = string.lower(_type)
    assert(parser[_type], string.format('[CsvUtil][GlobalSetting] "%s" Type字段的值不是目前所支持的数据类型', _type))
    return parser[_type](_stringValue)
end

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
        -- 默认用Type索引，直接返回
        return rawTable
    end
    local result = {}
    local tmp, key, id, idstr  -- 临时变量
    for _, v in pairs(rawTable) do
        tmp = result
        idstr = {}
        for i = 1, #ids do
            id = ids[i]
            key = v[id]
            idstr[i] = tostring(id) .. ','
            assert(not string.isnilorempty(key), string.format('[CsvUtil] CSV表格没有找到此id, CSV:%s, id: %s', _csv.Name, id))
            if i == #ids then
                -- 最后的键，确定唯一性
                assert(
                    not tmp[key],
                    string.format('[CsvUtil] CSV数据重复, ids不是唯一的, CSV: %s, ids: %s', _csv.Name, table.concat(idstr))
                )
                tmp[key] = v
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

--- 读取Config全局配置表
-- GlobleSetting.csv 表格内容为:
-- ---------------------------------------------------------
-- | String      | String  | String        | String        |
-- | Key         | Type    | Value         | Des           |
-- ---------------------------------------------------------
-- | CubeMax     | Int     | 200           | 最大Cube数     |
-- | BattleTime  | Float   | 5.45          | 战斗时间       |
-- | GameTitle   | String  | Boom Party    | 游戏标题       |
-- | IsFree      | Boolean | true          | 是否免费       |
-- | UiMapOrigin | Vector2 | 3,4           | UI地图原点位置 |
-- | TreePos     | Vector3 | 12,3,-3       | 树的位置       |
-- | TreeRot     | Euler   | 45,90,0       | 树的旋转       |
-- | TreeColor   | Color   | 255,255,255,0 | 树的颜色       |
function CsvUtil.GetGlobalCsvInfo(_csv)
    local rawTable = _csv:GetRows()
    if table.nums(rawTable) == 0 then
        return
    end
    assert(rawTable['1'].Key, '[CsvUtil] 全局配置表的没有"Key"')
    assert(rawTable['1'].Type, '[CsvUtil] 全局配置表的没有"Type"')
    assert(rawTable['1'].Value, '[CsvUtil] 全局配置表的没有"Value"')
    local result = {}
    for _, v in pairs(rawTable) do
        result[v.Key] = GetValue(v['Type'], v['Value'])
        PrintGlobalKV(v.Key, v.Type, result[v.Key]) -- * 输出KV键值对
    end
    return result
end

--- 表格预加载，预加载配置模块：World.Global.Define.ConfigModule
function CsvUtil.PreloadCsv(_preloadList, _csvRoot, _config)
    assert(_preloadList, '[CsvUtil] _preloadList不存在')
    if #_preloadList == 0 then
        print('[CsvUtil] ConfigModule中没有预加载表格')
        return
    end
    for _, pl in pairs(_preloadList) do
        if not string.isnilorempty(pl.csv) then
            pl.name = string.isnilorempty(pl.name) and pl.csv or pl.name
            PrintLog(string.format('[CsvUtil] Load: %s.csv', pl.csv))
            if pl.csv == 'GlobalSetting' and _csvRoot[pl.csv] then
                _config[pl.name] = CsvUtil.GetGlobalCsvInfo(_csvRoot[pl.csv])
            elseif not string.isnilorempty(pl.csv) and _csvRoot[pl.csv] then
                pl.ids = pl.ids or {}
                _config[pl.name] = CsvUtil.GetCsvInfo(_csvRoot[pl.csv], table.unpack(pl.ids))
            end
        end
    end
end

--! 辅助功能

--- 输出全局变量键值对
PrintGlobalKV =
    showLog and
    function(_key, _type, _value)
        _type = string.lower(_type)
        local showTypes = {
            vector2 = 'Vector2',
            vector3 = 'Vector3',
            euler = 'EulerDegree',
            color = 'Color'
        }
        if showTypes[_type] then
            print(string.format('[CsvUtil][GlobalSetting] %s = %s%s ', _key, showTypes[_type], _value))
        else
            print(string.format('[CsvUtil][GlobalSetting] %s = %s ', _key, _value))
        end
    end or
    function()
    end

PrintLog = showLog and function(...)
        print(...)
    end or function()
    end

return CsvUtil
