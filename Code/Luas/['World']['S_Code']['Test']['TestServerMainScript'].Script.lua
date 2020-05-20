--- 以下内容仅为测试用，请删掉；TEST ONLY BELOW
-- @script Server Main Function
-- @copyright Lilith Games, Avatar Team

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
