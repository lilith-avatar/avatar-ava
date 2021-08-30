--- Lua table 常用方法扩展
--- @module Lua table function extension libraries
--- @copyright Lilith Games, Avatar Team

--- 计算表格包含的字段数量
--- Lua table 的 "#" 操作只对依次排序的数值下标数组有效，
--- table.nums() 则计算 table 中所有不为 nil 的值的个数。
--- @param table
table.nums = function(t)
    if t == nil then
        return 0
    end
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

--- 返回指定表格中的所有键
--- @param k-v table
--- @return keys' table
--- @usage example
---      local hashtable = {a = 1, b = 2, c = 3}
---      local keys = table.keys(hashtable)
---      >> keys = {"a", "b", "c"}
table.keys = function(hashtable)
    local keys = {}
    for k, _ in pairs(hashtable) do
        table.insert(keys, k)
    end
    return keys
end

--- 返回指定表格中的所有值
--- @param k-v table
--- @return values' table
--- @usage example
---      local hashtable = {a = 1, b = 2, c = 3}
---      local values = table.values(hashtable)
---      >> values = {1, 2, 3}
table.values = function(hashtable)
    local values = {}
    local i = 1
    for k, v in pairs(hashtable) do
        values[i] = v
        i = i + 1
    end
    return values
end

--- 将来源表格中所有键及其值复制到目标表格对象中，如果存在同名键，则覆盖其值
--- @param target table
--- @param source table
--- @usage example
---      local dest = {a = 1, b = 2}
---      local src  = {c = 3, d = 4}
---      table.merge(dest, src)
---      >> dest = {a = 1, b = 2, c = 3, d = 4}
table.merge = function(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

--- 深度将来源表格中所有键及其值复制到目标表格对象中，如果存在同名键，则覆盖其值；
--- 如果存在子表,则遍历子表进行复制
--- @param dest 目标表格
--- @param src 被合入的表格
table.deepMerge = function(dest, src)
    for k, v in pairs(src) do
        if type(v) == 'table' then
            if dest[k] == nil then
                dest[k] = {}
            end
            table.deepMerge(dest[k], v)
        else
            dest[k] = v
        end
    end
end

--- 将来源表格中所有键及其值复制到目标表格对象中，如果存在同名键，则覆盖其值
--- @param ... 多个表，第一个是目标表格
--- @return 返回一个新表
--- @author Sharif Ma
table.MergeTables = function(...)
    local tabs = {...}
    if not tabs or #tabs == 0 then
        return {}
    end
    local origin = {}
    for k, v in pairs(tabs[1]) do
        origin[k] = v
    end
    for i = 2, #tabs do
        if origin then
            if tabs[i] then
                for _, v in pairs(tabs[i]) do
                    table.insert(origin, v)
                end
            end
        else
            origin = tabs[i]
        end
    end
    return origin
end

--- 在目标表格的指定位置插入来源表格，如果没有指定位置则连接两个表格
--- @param target table
--- @param source table
--- @param start index
--- @usage example #1
---      local dest = {1, 2, 3}
---      local src  = {4, 5, 6}
---      table.insertto(dest, src)
---      >> dest = {1, 2, 3, 4, 5, 6}
--- @usage example #2
---      local dest = {1, 2, 3}
---      local src  = {4, 5, 6}
---      table.insertto(dest, src, 5)
---      >> dest = {1, 2, 3, nil, 4, 5, 6}
table.insertto = function(dest, src, begin)
    if begin == nil then
        begin = #dest + 1
    else
        begin = checkint(begin)
        if begin <= 0 then
            begin = #dest + 1
        end
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

--- 从表格中查找指定值，返回其索引，如果没找到返回 false
--- @param array table
--- @param target value
--- @param start index
--- @return index or false
--- @usage example
---      local array = {"a", "b", "c"}
---      print(table.indexof(array, "b"))
---      >> 2
table.indexof = function(array, value, begin)
    if array ~= nil then
        for i = begin or 1, #array do
            if array[i] == value then
                return i
            end
        end
    end
    return 0
end

--- 检查表格中是否存在指定值
--- @param array table
--- @param target value
--- @return @boolean
table.exists = function(array, value)
    return table.indexof(array, value) > 0
end

--- 清空数组表格
--- @param array table
table.cleararray = function(array)
    if array ~= nil then
        local count = #array
        while count > 0 do
            table.remove(array, count)
            count = #array
        end
    end
end

--- 清空k-v表格
--- @param k-v table
table.clearhashtable = function(hashtable)
    if hashtable ~= nil then
        for k, v in pairs(hashtable) do
            hashtable[k] = nil
        end
    end
end

--- 清空表格
--- @param table
--- @see table.clearhashtable
table.cleartable = function(t)
    table.clearhashtable(t)
end

--- 截取Array其中一段，startIndex从1开始 return截取后的新数组
--- @param table array table
--- @param @number start index
--- @param @number length
--- @return @table array table
--- @usage example
---      local array = {"a", "b", "c", "d"}
---      print(table.subArray(array, 2, 2))
---      >> {"b", "c"}
table.subArray = function(array, startIndex, length)
    if array ~= nil then
        local count = table.nums(array)
        local tempArray = array
        array = {}
        if startIndex <= count then
            local maxlength = count - startIndex + 1
            length = length > maxlength and maxlength or length
            local endIndex = startIndex + length - 1
            for i = startIndex, endIndex do
                table.insert(array, tempArray[i])
            end
        end
    end
    return array
end

--- 截取Array的后半段，startIndex从1开始 return截取后的新数组
--- @param table array table
--- @param @number start index
--- @return @table array table
table.subArrayByStartIndex = function(array, startIndex)
    if array ~= nil then
        local count = table.nums(array)
        local length = count - startIndex + 1
        return table.subArray(array, startIndex, length)
    end
    return array
end

--- 从表格中查找指定值，返回其 key，如果没找到返回 nil
--- @param table hash table
--- @param any value
--- @return key of value
--- @usage
---      local hashtable = {name = "dualface", comp = "chukong"}
---      print(table.keyof(hashtable, "chukong"))
---      >> comp
table.keyof = function(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then
            return k
        end
    end
    return nil
end

--- 从表格中删除指定值，返回删除的值的个数
--- @usage
---      local array = {"a", "b", "c", "c"}
---      print(table.removebyvalue(array, "c", true))
---      >> 输出 2
table.removebyvalue = function(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then
                break
            end
        end
        i = i + 1
    end
    return c
end

--- 数组混淆
--- @param array 数组table
--- @return 混淆后的同一数组table
--- @author Yuancheng Zhang
table.shuffle = function(_tbl)
    local j
    for i = #_tbl, 2, -1 do
        j = math.random(i)
        _tbl[i], _tbl[j] = _tbl[j], _tbl[i]
    end
    return _tbl
end

--- 对表格中每一个值执行一次指定的函数，并用函数返回值更新表格内容
--- @param table
--- @param function fn 参数指定的函数具有两个参数，并且返回一个值。原型如下：
---      function map_function(value, key)
---          return value
---      end
--- @usage
---      local t = {name = "dualface", comp = "chukong"}
---      table.map(t, function(v, k)
---         --在每一个值前后添加括号
---         return "[" .. v .. "]"
---      end)
---      输出修改后的表格内容
---      for k, v in pairs(t) do
---          print(k, v)
---      end
---      >> 输出
---      name [dualface]
---      comp [chukong]
table.map = function(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(v, k)
    end
end

--- 对表格中每一个值执行一次指定的函数，但不改变表格内容
--- @param table
--- @param function fn 参数指定的函数具有两个参数，没有返回值。原型如下：
---      function map_function(value, key)
---          --- no return here
---      end
--- @usage
---      local t = {name = "dualface", comp = "chukong"}
---      table.walk(t, function(v, k)
---          --- 输出每一个值
---          print(v)
---      end)
table.walk = function(t, fn)
    for k, v in pairs(t) do
        fn(v, k)
    end
end

--- 对表格中每一个值执行一次指定的函数，如果该函数返回 false，则对应的值会从表格中删除
--- @param table
--- @param function fn 参数指定的函数具有两个参数，并且返回一个 boolean 值。原型如下：
--- !该方法有局限性，执行后会修改原表格t中值
---      function map_function(value, key)
---          return true or false
---      end
--- @usage
---      local t = {name = "dualface", comp = "chukong"}
---      table.filter(t, function(v, k)
---          return v ~= "dualface" -- 当值等于 dualface 时过滤掉该值
---      end)
---  输出修改后的表格内容
---      for k, v in pairs(t) do
---          print(k, v)
---      end
---      >> 输出 comp chukong
table.filter = function(t, fn)
    for k, v in pairs(t) do
        if not fn(v, k) then
            t[k] = nil
        end
    end
end

--- 找到表格中每个符合matchFunc的条目
--- @param array table
--- @param match function, return T/F
--- @return all elements matched, default is {}
table.findAll = function(array, matchFunc)
    local ret, idx = {}, 1
    for i = 1, #array do
        if matchFunc(array[i]) then
            ret[idx] = array[i]
            idx = idx + 1
        end
    end
    return ret
end

--- 找到表格中每个符合matchFunc的条目，并执行walkFunc
--- @param array table
--- @param match function, return T/F
--- @param walk function
table.findAllAndWalk = function(array, matchFunc, walkFunc)
    for i = 1, #array do
        if matchFunc(array[i]) then
            walkFunc(array[i])
        end
    end
end

--- 在表格中插入一个新值
--- @param array table
--- @param new element
table.insert_once = function(T, elem)
    for _, v in ipairs(T) do
        if v == elem then
            return
        end
    end
    table.insert(T, elem)
end

--- 遍历表格，确保其中的值唯一
--- @function [parent=#table] unique
--- @param table t 表格
--- @param boolean bArray t是否是数组,是数组,t中重复的项被移除后,后续的项会前移
--- @return table#table  包含所有唯一值的新表格
--- @usage
--- 遍历表格，确保其中的值唯一
---      local t = {"a", "a", "b", "c"} -- 重复的 a 会被过滤掉
---      local n = table.unique(t)
---      for k, v in pairs(n) do
---          print(v)
---      end
---      >> 输出 a b c
table.unique = function(t, bArray)
    local check = {}
    local n = {}
    local idx = 1
    for k, v in pairs(t) do
        if not check[v] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[v] = true
        end
    end
    return n
end

--- table 深度复制
--- @param table
--- @return a net table with same data
table.deepcopy = function(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= 'table' then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--- table 浅度复制(不处理metatable)
--- @param table
--- @return a net table with same data
function table.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.shallowcopy(orig_key)] = table.shallowcopy(orig_value)
        end
    else
        copy = orig
    end
    return copy
end

--- 获取or创建一个子表
table.need = function(tb, key)
    if type(tb) == 'table' then
        local subTb = tb[key]
        if subTb == nil then
            subTb = {}
            tb[key] = subTb
        end
        return subTb
    end
end

--- 打印table中的所有内容
--- @param data table
--- @param @boolean showMetatable 是否显示元表
table.dump = function(data, showMetatable)
    local result, tab = {}, '    '
    local function _dump(data, showMetatable, lastCount)
        if type(data) ~= 'table' then
            if type(data) == 'string' then
                table.insert(result, '"')
                table.insert(result, data)
                table.insert(result, '"')
            else
                table.insert(result, tostring(data))
            end
        else
            --Format
            local count = lastCount or 0
            count = count + 1
            table.insert(result, '{\n')
            --Metatable
            if showMetatable then
                for i = 1, count do
                    table.insert(result, tab)
                end
                local mt = getmetatable(data)
                table.insert(result, '"__metatable" = ')
                _dump(mt, showMetatable, count)
                table.insert(result, ',\n')
            end
            --Key
            for key, value in pairs(data) do
                for i = 1, count do
                    table.insert(result, tab)
                end
                if type(key) == 'string' then
                    table.insert(result, '"')
                    table.insert(result, key)
                    table.insert(result, '" = ')
                elseif type(key) == 'number' then
                    table.insert(result, '[')
                    table.insert(result, key)
                    table.insert(result, '] = ')
                else
                    table.insert(result, tostring(key))
                end
                _dump(value, showMetatable, count)
                table.insert(result, ',\n')
            end
            --Format
            for i = 1, lastCount or 0 do
                table.insert(result, tab)
            end
            table.insert(result, '}')
        end
        --Format
        if not lastCount then
            table.insert(result, '\n')
        end
    end
    _dump(data, showMetatable, 0)

    --- print('dump: \n' .. table.concat(result))
    return 'dump: \n' .. table.concat(result)
end

--- 两个表是否相同(元素数量，值相同)
--- @param _tableA table
--- @param _tableB table
--- @author xuyue
table.equal = function(_tableA, _tableB)
    for k, v in pairs(_tableA) do
        if _tableB[k] == nil then --元素数量不匹配
            return false
        end

        if type(v) ~= 'table' then
            if v ~= _tableB[k] then
                return false
            end
        else
            if not table.equal(v, _tableB[k]) then
                return false
            end
        end
    end
    return true
end

return 0
