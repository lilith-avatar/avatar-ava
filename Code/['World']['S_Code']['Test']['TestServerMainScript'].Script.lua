--- TEST:框架服务端测试脚本(用后删)；
-- @script Test Server Scirpt
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang

wait(1)
invoke(
    function()
        NetUtil.Fire_S('Test01ServerEvent')
    end
)

wait(1)
invoke(
    function()
        for _, p in pairs(world:FindPlayers()) do
            NetUtil.Fire_C('Test01ClientEvent', p, p.Name)
            NetUtil.Fire_C('Test02ClientEvent', p, 'TestAnimation')
        end
    end
)

wait(1)
invoke(
    function()
        NetUtil.Fire_S('Test02ServerEvent')
    end
)

wait(1)
invoke(
    function()
        NetUtil.Fire_S('Test03ServerEvent')
    end
)
