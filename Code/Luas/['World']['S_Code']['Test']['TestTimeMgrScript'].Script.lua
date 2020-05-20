local c = 0

print('Test InitDone')
function Test01(_param)
    print(string.format('Test01: %s', _param))
end

function Test02(_param)
    print(string.format('Test02: %s', _param))
end

function Test03(a, b, c)
    print(string.format('Test03: %s, %s, %s', a, b, c))
end

print(
    TimeMgr:SetTimeout(
        1,
        function()
            Test01(1)
        end
    )
) --第2秒打印 Test01:1

print(
    TimeMgr:SetInterval(
        2,
        function()
            Test02(2)
        end
    )
) --第2秒打印Test02:2

print(
    TimeMgr:SetInterval(
        2,
        function()
            Test03(3, 3, 3)
        end
    )
) --第2秒打印Test03:3,3,3

invoke(
    function()
        TimeMgr:CancelEvent(2)
    end,
    5
)

--TimeMgr:CancelEvent(4)
TimeMgr:StartUpdate()
wait(5)
print('1')
TimeMgr:StopUpdate(true)
wait(5)
TimeMgr:StartUpdate()
print('2')
