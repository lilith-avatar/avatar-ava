--- TEST:时间管理器测试脚本(用后删)
-- @module Test Time Manager
-- @copyright Lilith Games, Avatar Team
-- @author Bingyun Chen, Yuancheng Zhang

TimeMgr.Init()

function Test01(_param)
    print(string.format('Test01: %s', _param))
end

function Test02(_param)
    print(string.format('Test02: %s', _param))
end

function Test03(a, b, c)
    print(string.format('Test03: %s, %s, %s', a, b, c))
end

-- 第2秒打印 Test01
TimeMgr.SetTimeout(
    function()
        Test01(1)
    end,
    2
)

-- 每2秒打印 Test02
TimeMgr.SetInterval(
    function()
        Test02(2)
    end,
    2
)

-- 每3秒打印 Test03
local timerId =
    TimeMgr.SetInterval(
    function()
        Test03(12, 23, 34)
    end,
    3
)

print(string.format('timerId = %s', timerId))

-- 10秒后取消循环打印 Test03
wait(10)
TimeMgr.ClearInterval(timerId)
