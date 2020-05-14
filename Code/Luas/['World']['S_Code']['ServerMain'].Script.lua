--- 服务器代码入口
-- @script Server Main Function
-- @copyright Lilith Games, Avatar Team
-- @author XXX, XXX

GameMgr:Init()

-- TEST ONLY BELOW
-- 以下内容仅为测试用，请删掉
wait(1)
invoke(
    function()
        NetUtil.Fire_S('Example01CustomEvent')
    end
)

wait(1)
invoke(
    function()
        for _, p in pairs(world:FindPlayers()) do
            NetUtil.Fire_C('ClientExample01Event', p, p.Name)
            NetUtil.Fire_C('ClientExample02Event', p)
        end
    end
)

wait(1)
invoke(
    function()
        NetUtil.Fire_S('Example02CustomEvent')
    end
)

wait(1)
invoke(
    function()
        NetUtil.Fire_S('Example03CustomEvent')
    end
)
