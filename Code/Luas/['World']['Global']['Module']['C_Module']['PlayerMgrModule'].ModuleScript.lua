--- 游戏客户端主逻辑
-- @module Game Manager, Client-side
-- @copyright Lilith Games, Avatar Team
-- @author XXX, XXXX
local PlayerMgr, this =
    {
        dt = 0,
        tt = 0,
        isRun = false
    },
    nil

--- 初始化
function PlayerMgr:Init()
    info('PlayerMgr:Init')
    this = self
    self:InitListeners()

    AnimationMain:Init()
    PlayerCsv:Init()

    -- TODO: 其他客户端模块初始化
    ExampleB:Init()
end

--- 初始化Game Manager自己的监听事件
function PlayerMgr:InitListeners()
    EventUtil.LinkConnects(localPlayer.C_Event, PlayerMgr, 'PlayerMgr', this)
end

--- Update函数
-- @param dt delta time 每帧时间
function PlayerMgr:Update(dt)
    -- TODO: 其他客户端模块Update
    ExampleB:Update(dt)
end

function PlayerMgr:StartUpdate()
    info('PlayerMgr:StartUpdate')
    if self.isRun then
        warn('PlayerMgr:StartUpdate 正在运行')
        return
    end

    self.isRun = true

    while (self.isRun) do
        self.dt = wait()
        self.tt = self.tt + self.dt
        self:Update(self.dt)
    end
end

function PlayerMgr:StopUpdate()
    info('PlayerMgr:StopUpdate')
    self.isRun = false
end

--- TEST ONLY 处理ClientExample01Event事件
-- 函数命名格式为 事件名 + 'Handler'
function PlayerMgr:ClientExample01EventHandler(arg1)
    test('收到ClientExample01Event, 参数:', arg1)
    test('PlayerCsv打印预加载的表格Example01,单一主键,主键为Type')
    table.dump(PlayerCsv.Test04)
    self:StartUpdate()
end

return PlayerMgr
