--- 提供一组常用函数，以及对 Lua 标准库的扩展
-- @script Lua function extension libraries
-- @author Lilith Games, Avatar Team
-- @see https://wiki.lilithgames.com/x/tSkMAg

--- 检查并尝试转换为数值，如果无法转换则返回 0
-- @param mixed value 要检查的值
-- @param [integer base] 进制，默认为十进制
-- @return number
function checknumber(value, base)
    return tonumber(value, base) or 0
end

--- 检查是否是有效的number类型
-- @param number
function isValidNumber(num)
    return num ~= nil and num > 0
end

--- 检查并尝试转换为整数，如果无法转换则返回 0
-- @param mixed value 要检查的值
-- @return integer
function checkint(value)
    return math.round(checknumber(value))
end

--- 检查并尝试转换为布尔值，除了 nil 和 false，其他任何值都会返回 true
-- @param mixed value 要检查的值
-- @return boolean
function checkbool(value)
    return (value ~= nil and value ~= false)
end

--- 检查值是否是一个表格，如果不是则返回一个空表格
-- @param mixed value 要检查的值
-- @return table
function checktable(value)
    if type(value) ~= 'table' then
        value = {}
    end
    return value
end

--- 处理对象
-- @param mixed obj Lua 对象
-- @param function method 对象方法
-- @return function
function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

--- 计算表格包含的字段数量
-- Lua table 的 "#" 操作只对依次排序的数值下标数组有效，table.nums() 则计算 table 中所有不为 nil 的值的个数。
-- @param table
function table.nums(t)
    if t == nil then
        return 0
    end
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

--- 返回指定表格中的所有键
-- @param k-v table
-- @return keys' table
-- @usage example
-- local hashtable = {a = 1, b = 2, c = 3}
-- local keys = table.keys(hashtable)
-- >> keys = {"a", "b", "c"}
function table.keys(hashtable)
    local keys = {}
    for k, _ in pairs(hashtable) do
        table.insert(keys, k)
    end
    return keys
end

--- 返回指定表格中的所有值
-- @param k-v table
-- @return values' table
-- @usage example
-- local hashtable = {a = 1, b = 2, c = 3}
-- local values = table.values(hashtable)
-- >> values = {1, 2, 3}
function table.values(hashtable)
    local values = {}
    local i = 1
    for k, v in pairs(hashtable) do
        values[i] = v
        i = i + 1
    end
    return values
end

--- 将来源表格中所有键及其值复制到目标表格对象中，如果存在同名键，则覆盖其值
-- @param target table
-- @param source table
-- @usage example
-- local dest = {a = 1, b = 2}
-- local src  = {c = 3, d = 4}
-- table.merge(dest, src)
-- >> dest = {a = 1, b = 2, c = 3, d = 4}
function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

--- 在目标表格的指定位置插入来源表格，如果没有指定位置则连接两个表格
-- @param target table
-- @param source table
-- @param start index
-- @usage example #1
-- local dest = {1, 2, 3}
-- local src  = {4, 5, 6}
-- table.insertto(dest, src)
-- >> dest = {1, 2, 3, 4, 5, 6}
-- @usage example #2
-- local dest = {1, 2, 3}
-- local src  = {4, 5, 6}
-- table.insertto(dest, src, 5)
-- >> dest = {1, 2, 3, nil, 4, 5, 6}
function table.insertto(dest, src, begin)
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
-- @param array table
-- @param target value
-- @param start index
-- @return index or false
-- @usage example
-- local array = {"a", "b", "c"}
-- print(table.indexof(array, "b"))
-- >> 2
function table.indexof(array, value, begin)
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
-- @param array table
-- @param target value
-- @return @boolean
function table.exists(array, value)
    return table.indexof(array, value) > 0
end

--- 清空数组表格
-- @param array table
function table.cleararray(array)
    if array ~= nil then
        local count = #array
        while count > 0 do
            table.remove(array, count)
            count = #array
        end
    end
end

--- 清空k-v表格
-- @param k-v table
function table.clearhashtable(hashtable)
    if hashtable ~= nil then
        for k, v in pairs(hashtable) do
            hashtable[k] = nil
        end
    end
end

--- 清空表格
-- @param table
-- @see table.clearhashtable
function table.cleartable(t)
    table.clearhashtable(t)
end

--- 截取Array其中一段，startIndex从1开始 return截取后的新数组
-- @param table array table
-- @param @number start index
-- @param @number length
-- @return @table array table
-- @usage example
-- local array = {"a", "b", "c", "d"}
-- print(table.subArray(array, 2, 2))
-- >> {"b", "c"}
function table.subArray(array, startIndex, length)
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
-- @param table array table
-- @param @number start index
-- @return @table array table
function table.subArrayByStartIndex(array, startIndex)
    if array ~= nil then
        local count = table.nums(array)
        local length = count - startIndex + 1
        return table.subArray(array, startIndex, length)
    end
    return array
end

--- 从表格中查找指定值，返回其 key，如果没找到返回 nil
-- @param table hash table
-- @param any value
-- @return key of value
-- @usage
-- local hashtable = {name = "dualface", comp = "chukong"}
-- print(table.keyof(hashtable, "chukong"))
-- >> comp
function table.keyof(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then
            return k
        end
    end
    return nil
end

--- 从表格中删除指定值，返回删除的值的个数
-- @usage
-- local array = {"a", "b", "c", "c"}
-- print(table.removebyvalue(array, "c", true))
-- >> 输出 2
function table.removebyvalue(array, value, removeall)
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

--- 对表格中每一个值执行一次指定的函数，并用函数返回值更新表格内容
-- @param table
-- @param function fn 参数指定的函数具有两个参数，并且返回一个值。原型如下：
-- function map_function(value, key)
--     return value
-- end
-- @usage
-- local t = {name = "dualface", comp = "chukong"}
-- table.map(t, function(v, k)
--    -- 在每一个值前后添加括号
--    return "[" .. v .. "]"
-- end)
-- 输出修改后的表格内容
-- for k, v in pairs(t) do
--     print(k, v)
-- end
-- >> 输出
-- name [dualface]
-- comp [chukong]
function table.map(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(v, k)
    end
end

--- 对表格中每一个值执行一次指定的函数，但不改变表格内容
-- @param table
-- @param function fn 参数指定的函数具有两个参数，没有返回值。原型如下：
-- function map_function(value, key)
--     -- no return here
-- end
-- @usage
-- local t = {name = "dualface", comp = "chukong"}
-- table.walk(t, function(v, k)
--     -- 输出每一个值
--     print(v)
-- end)
function table.walk(t, fn)
    for k, v in pairs(t) do
        fn(v, k)
    end
end

--- 对表格中每一个值执行一次指定的函数，如果该函数返回 false，则对应的值会从表格中删除
-- @param table
-- @param function fn 参数指定的函数具有两个参数，并且返回一个 boolean 值。原型如下：
-- !!!!该方法有局限性，执行后会修改原表格t中值
-- function map_function(value, key)
--     return true or false
-- end
-- @usage
-- local t = {name = "dualface", comp = "chukong"}
-- table.filter(t, function(v, k)
--     return v ~= "dualface" -- 当值等于 dualface 时过滤掉该值
-- end)
-- 输出修改后的表格内容
-- for k, v in pairs(t) do
--     print(k, v)
-- end
-- >> 输出 comp chukong
function table.filter(t, fn)
    for k, v in pairs(t) do
        if not fn(v, k) then
            t[k] = nil
        end
    end
end

--- 找到表格中每个符合matchFunc的条目
-- @param array table
-- @param match function, return T/F
-- @return all elements matched, default is {}
function table.findAll(array, matchFunc)
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
-- @param array table
-- @param match function, return T/F
-- @param walk function
function table.findAllAndWalk(array, matchFunc, walkFunc)
    for i = 1, #array do
        if matchFunc(array[i]) then
            walkFunc(array[i])
        end
    end
end

--- 在表格中插入一个新值
-- @param array table
-- @param new element
function table.insert_once(T, elem)
    for _, v in ipairs(T) do
        if v == elem then
            return
        end
    end
    table.insert(T, elem)
end

--- 遍历表格，确保其中的值唯一
-- @function [parent=#table] unique
-- @param table t 表格
-- @param boolean bArray t是否是数组,是数组,t中重复的项被移除后,后续的项会前移
-- @return table#table  包含所有唯一值的新表格
-- @usage
-- 遍历表格，确保其中的值唯一
-- local t = {"a", "a", "b", "c"} -- 重复的 a 会被过滤掉
-- local n = table.unique(t)
-- for k, v in pairs(n) do
--     print(v)
-- end
-- >> 输出 a b c
function table.unique(t, bArray)
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
-- @param table
-- @return a net table with same data
function table.deepcopy(object)
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
function table.need(tb, key)
    if type(tb) == 'table' then
        local subTb = tb[key]
        if subTb == nil then
            subTb = {}
            tb[key] = subTb
        end
        return subTb
    end
    return
end

--- 打印table中的所有内容
-- @param data table
-- @param @boolean showMetatable 是否显示元表
function table.dump(data, showMetatable)
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

    print('dump from: \n' .. table.concat(result))
end

--- 用指定字符或字符串分割输入字符串，返回包含分割结果的数组
-- @param @string input 输入的字符串
-- @param @string delimiter 分隔符
-- @return array
-- @usage example #1
-- local input = "Hello,World"
-- local res = string.split(input, ",")
-- >> res = {"Hello", "World"}
-- @usage example #2
-- local input = "Hello-+-World-+-Quick"
-- local res = string.split(input, "-+-")
-- >> res = {"Hello", "World", "Quick"}
function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == '') then
        return false
    end
    local pos, arr = 0, {}
    -- for each divider found
    for st, sp in function()
        return string.find(input, delimiter, pos, true)
    end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

--- 判断字符串是否为空或者长度为零
-- @param @string 输入的字符串
function string.isnilorempty(inputStr)
    return inputStr == nil or inputStr == ''
end

--- 去除输入字符串头部的空白字符，返回结果
-- @param @string input
-- @return @string
-- @usage example
-- local input = "  ABC"
-- print(string.ltrim(input))
-- >> 输出 ABC，输入字符串前面的两个空格被去掉了
-- 空白字符包括：
-- -   空格
-- -   制表符 \t
-- -   换行符 \n
-- -   回到行首符 \r
function string.ltrim(input)
    return string.gsub(input, '^[ \t\n\r]+', '')
end

--- 去除输入字符串尾部的空白字符，返回结果
-- @param @string input
-- @return @string
-- @usage example
-- local input = "ABC  "
-- print(string.rtrim(input))
-- >> 输出 ABC，输入字符串最后的两个空格被去掉了
function string.rtrim(input)
    return string.gsub(input, '[ \t\n\r]+$', '')
end

--- 去掉字符串首尾的空白字符，返回结果
-- @param @string input
-- @return @string
function string.trim(input)
    input = string.gsub(input, '^[ \t\n\r]+', '')
    return string.gsub(input, '[ \t\n\r]+$', '')
end

--- 将字符串的第一个字符转为大写，返回结果
-- @param @string input
-- @return @string
-- @usage example
-- local input = "hello"
-- print(string.ucfirst(input))
-- >> 输出 Hello
function string.ucfirst(input)
    return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

function string.firstToUpper(str)
    return (str:gsub('^%l', string.upper))
end

--- 计算 UTF8 字符串的长度，每一个中文算一个字符
-- @param @string input
-- @return @number cnt
-- @usage example
-- local input = "你好World"
-- print(string.utf8len(input))
-- >> 输出 7
function string.utf8len(input)
    local len = string.len(input)
    local left = len
    local cnt = 0
    local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

--- 替换字符串内容
-- @param @string input
-- @param @number start index
-- @param new context
-- @return a new string
function string.replace(str, index, char)
    return table.concat {str:sub(1, index - 1), char, str:sub(index + 1)}
end

--- 检查字符串是否为指定字符串开头
-- @param @string target
-- @param @string start
-- @return @boolean
function string.startswith(str, start)
    return str:sub(1, #start) == start
end

--- 检查字符串是否以指定字符串结尾
-- @param @string target
-- @param @string start
-- @return @boolean
function string.endswith(str, ending)
    return ending == '' or str:sub(-(#ending)) == ending
end

--- 四舍五入
-- @param a number
-- @return a round number
function math.round(value)
    return math.floor(value + 0.5)
end

--- [0, 1]区间限定函数
-- @param a number or
-- @return a clamped number
function math.clamp01(value)
    return math.min(1, math.max(0, value))
end

--- 数据结构 队列
-- @usage queue example
-- local myQueue = Queue:New()
-- myQueue:Enqueue('a')
-- myQueue:Enqueue('b')
-- myQueue:Enqueue('c')
-- myQueue:PrintElement()
-- print(myQueue:Dequeue())
-- myQueue:PrintElement()
-- myQueue:Clear()
-- myQueue:PrintElement()
Queue = {}
function Queue:New()
    local inst = {
        _first = -1,
        _last = -1,
        _size = 0,
        _queue = {}
    }
    setmetatable(inst, {__index = self})
    return inst
end

function Queue:IsEmpty()
    if self._size == 0 then
        return true
    end
    return false
end

function Queue:Enqueue(inElement)
    if self._size == 0 then
        self._first = 0
        self._last = 1
        self._size = 1
        self._queue[self._last] = inElement
    else
        self._last = self._last + 1
        self._queue[self._last] = inElement
        self._size = self._size + 1
    end
end

function Queue:Dequeue()
    if self:IsEmpty() then
        print('Error: the queue is empty')
        return
    end
    self._size = self._size - 1
    self._first = self._first + 1
    local value = self._queue[self._first]
    return value
end

function Queue:Clear()
    self._queue = nil
    self._queue = {}
    self._size = 0
    self._first = -1
    self._last = -1
end

function Queue:Size()
    return self._size or 0
end

function Queue:PrintElement()
    if self._size == 0 then
        print('{}')
    else
        local f = self._first + 1
        local l = self._last
        local str
        local flag = true
        while f ~= l do
            if flag == true then
                str = '{' .. tostring(self._queue[f])
                f = f + 1
                flag = false
            else
                str = str .. ',' .. tostring(self._queue[f])
                f = f + 1
            end
        end
        str = str .. ',' .. tostring(self._queue[l]) .. '}'
        print(str)
    end
end

function Queue:GetValue(index)
    if self:IsEmpty() or index == nil or index == 0 then
        print('Error: Get Value Failure!')
        return
    end
    if index > 0 then
        return self._queue[self._first + index]
    else
        return self._queue[self._last + index + 1]
    end
end

function Queue:GetValues()
    if self:IsEmpty() then
        return
    end
    local data = {}
    for i = self._first + 1, self._last, 1 do
        data[#data + 1] = self._queue[i]
    end
    return data
end

--- 数据结构 栈
-- @usage example
-- local myStack = Stack:New()
-- myStack:Push("a")
-- myStack:Push("b")
-- myStack:Push("c")
-- myStack:PrintElement()
-- print(myStack:Pop())
-- myStack:PrintElement()
-- myStack:Clear()
-- myStack:PrintElement()
Stack = {}
function Stack:New()
    local inst = {
        _last = 0,
        _stack = {}
    }
    setmetatable(inst, {__index = self})

    return inst
end

function Stack:IsEmpty()
    if self._last == 0 then
        return true
    end
    return false
end

function Stack:Push(inElement)
    self._last = self._last + 1
    self._stack[self._last] = inElement
end

function Stack:Pop()
    if self:IsEmpty() then
        --print("Error: the stack is empty")
        return
    end
    local value = self._stack[self._last]
    self._stack[self._last] = nil
    self._last = self._last - 1
    return value
end

function Stack:Exists(element, compairFunc)
    if compairFunc == nil then
        compairFunc = function(a, b)
            return a == b
        end
    end
    for i = self._last, 1, -1 do
        if compairFunc(element, self._stack[i]) then
            return i
        end
    end
    return -1
end

function Stack:RemoveAt(index)
    if index < 1 or index > self._last then
        return
    end
    table.remove(self._stack, index)
    self._last = self._last - 1
end

function Stack:Clear()
    self._stack = nil
    self._stack = {}
    self._last = 0
end

function Stack:Size()
    return self._last
end

function Stack:PrintElement()
    local str = '{'
    for i = self._last, 1, -1 do
        str = str .. tostring(self._stack[i]) .. ','
    end
    str = str .. '}'
    print(str)
end
