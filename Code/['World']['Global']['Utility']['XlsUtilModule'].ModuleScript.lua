--- 读表工具: 将导入成Lua Table，支持单一主键和多主键
-- @module XLS Utility
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
-- @see https://wiki.lilithgames.com/x/RGEMAg
local XlsUtil = {}

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
        return math.floor(tonumber(_raw))
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
    assert(parser[_type], string.format('[XlsUtil][GlobalSetting] "%s" Type字段的值不是目前所支持的数据类型', _type))
    return parser[_type](_stringValue)
end

--- 根据id转换lua table
function XlsUtil.GetXlsInfo(_xls, ...)
    local ids = {...}
    if #ids < 1 or (#ids == 1 and ids[1] == 'Type') then
        -- 默认用Type索引，直接返回
        return _xls
    end
    local rawTable = _xls
    local result = {}
    local tmp, key, id, idstr  -- 临时变量
    for _, v in pairs(rawTable) do
        tmp = result
        idstr = {}
        for i = 1, #ids do
            id = ids[i]
            key = v[id]
            idstr[i] = tostring(id) .. ','
            assert(
                not string.isnilorempty(key),
                string.format('[XlsUtil] Excel表格没有找到此id, Excel:%s, id: %s', _xls.Name, id)
            )
            if i == #ids then
                -- 最后的键，确定唯一性
                assert(
                    not tmp[key],
                    string.format('[XlsUtil] Excel数据重复, ids不是唯一的, Excel: %s, ids: %s', _xls.Name, table.concat(idstr))
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
function XlsUtil.GetGlobalXlsInfo(_xls)
    local rawTable = _xls
    if table.nums(rawTable) == 0 then
        return
    end
    assert(rawTable[1].Key, '[XlsUtil] 全局配置表的没有"Key"')
    assert(rawTable[1].Type, '[XlsUtil] 全局配置表的没有"Type"')
    assert(rawTable[1].Value, '[XlsUtil] 全局配置表的没有"Value"')
    local result = {}
    for _, v in pairs(rawTable) do
        result[v.Key] = GetValue(v['Type'], v['Value'])
        PrintGlobalKV(v.Key, v.Type, result[v.Key]) -- * 输出KV键值对
    end
    return result
end

--- 表格预加载，预加载配置模块：World.Global.Define.ConfigModule
function XlsUtil.PreloadXls(_preloadList, _xlsRoot, _config)
    -- todo: load xls lua talbe
    assert(_preloadList and #_preloadList > 0, 'ConfigModule中没有预加载表格')

    for _, pl in pairs(_preloadList) do
        if not string.isnilorempty(pl.xls) then
            pl.name = string.isnilorempty(pl.name) and pl.xls or pl.name
            pl.module = string.isnilorempty(pl.module) and pl.xls .. 'Xls' or pl.module
            PrintLog(string.format('[XlsUtil] Load: %s', pl.module))
            if pl.xls == 'GlobalSetting' and _xlsRoot[pl.module .. 'Module'] then
                _config[pl.name] = XlsUtil.GetGlobalXlsInfo(_G[pl.module])
            elseif not string.isnilorempty(pl.xls) and _G[pl.module] then
                pl.ids = pl.ids or {}
                _config[pl.name] = XlsUtil.GetXlsInfo(_G[pl.module], table.unpack(pl.ids))
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
            print(string.format('[XlsUtil][GlobalSetting] %s = %s%s ', _key, showTypes[_type], _value))
        else
            print(string.format('[XlsUtil][GlobalSetting] %s = %s ', _key, _value))
        end
    end or
    function()
    end

PrintLog = showLog and function(...)
        print(...)
    end or function()
    end

return XlsUtil
