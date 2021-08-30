--- Lua string 常用方法扩展
--- @module Lua string function extension libraries
--- @copyright Lilith Games, Avatar Team

--- 用指定字符或字符串分割输入字符串，返回包含分割结果的数组
--- @param @string input 输入的字符串
--- @param @string delimiter 分隔符
--- @return array
--- @usage example #1
---      local input = "Hello,World"
---      local res = string.split(input, ",")
---      >> res = {"Hello", "World"}
--- @usage example #2
---      local input = "Hello-+-World-+-Quick"
---      local res = string.split(input, "-+-")
---      >> res = {"Hello", "World", "Quick"}
string.split = function(input, delimiter)
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
--- @param @string 输入的字符串
string.isnilorempty = function(inputStr)
    return inputStr == nil or inputStr == ''
end

--- 去除输入字符串头部的空白字符，返回结果
--- @param @string input
--- @return @string
--- @usage example
---      local input = "  ABC"
---      print(string.ltrim(input))
---      >> 输出 ABC，输入字符串前面的两个空格被去掉了
---      空白字符包括：
---          空格
---          制表符 \t
---          换行符 \n
---          回到行首符 \r
string.ltrim = function(input)
    return string.gsub(input, '^[ \t\n\r]+', '')
end

--- 去除输入字符串尾部的空白字符，返回结果
--- @param @string input
--- @return @string
--- @usage example
---      local input = "ABC  "
---      print(string.rtrim(input))
---      >> 输出 ABC，输入字符串最后的两个空格被去掉了
string.rtrim = function(input)
    return string.gsub(input, '[ \t\n\r]+$', '')
end

--- 去掉字符串首尾的空白字符，返回结果
--- @param @string input
--- @return @string
string.trim = function(input)
    input = string.gsub(input, '^[ \t\n\r]+', '')
    return string.gsub(input, '[ \t\n\r]+$', '')
end

--- 将字符串的第一个字符转为大写，返回结果
--- @param @string input
--- @return @string
--- @usage example
---      local input = "hello"
---      print(string.ucfirst(input))
---      >> 输出 Hello
string.ucfirst = function(input)
    return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

string.firstToUpper = function(str)
    return (str:gsub('^%l', string.upper))
end

--- 计算 UTF8 字符串的长度，每一个中文算一个字符
--- @param @string input
--- @return @number cnt
--- @usage example
---      local input = "你好World"
---      print(string.utf8len(input))
---      >> 输出 7
string.utf8len = function(input)
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
--- @param @string input
--- @param @number start index
--- @param new context
--- @return a new string
string.replace = function(str, index, char)
    return table.concat {str:sub(1, index - 1), char, str:sub(index + 1)}
end

--- 检查字符串是否为指定字符串开头
--- @param @string target
--- @param @string start
--- @return @boolean
string.startswith = function(str, start)
    return str:sub(1, #start) == start
end

--- 检查字符串是否以指定字符串结尾
--- @param @string target
--- @param @string start
--- @return @boolean
string.endswith = function(str, ending)
    return ending == '' or str:sub(-(#ending)) == ending
end

return 0
