--- 服务器代码入口
-- @script Server Main Function
-- @copyright Lilith Games, Avatar Team
-- @author XXX, XXX

GameMgr:Init()
-- invoke(
--     function()
--         GameMgr:StartUpdate()
--     end
-- )

-- TEST ONLY BELOW
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
