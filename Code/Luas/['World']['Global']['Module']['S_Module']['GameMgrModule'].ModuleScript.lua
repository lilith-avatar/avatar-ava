--- 游戏服务器主逻辑
-- @module Game Manager, Server-side
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
local GameMgr, this =
    {
        isRun = false,
        baseTime = 0, -- 游戏开始的时间戳
        dt = 0, -- delta time 每帧时间
        tt = 0 -- total time 游戏总时间
    },
    nil

local now = os.clock -- 用于lua优化

--- 初始化
function GameMgr:Init()
    info('GameMgr:Init')
    this = self
    self.baseTime = now()
    self:InitListeners()

    TimeMgr:Init()
    CsvConfig:Init()

    -- TODO: 其他服务器模块初始化
    ExampleA:Init()
end

--- 初始化Game Manager自己的监听事件
function GameMgr:InitListeners()
    EventUtil.LinkConnects(world.S_Event, GameMgr, 'GameMgr', this)
end

--- Update函数
-- @param dt delta time 每帧时间
function GameMgr:Update(dt, tt)
    -- TODO: 其他服务器模块Update
    ExampleA:Update(dt, tt)
end

--- 开始Update
function GameMgr:StartUpdate()
    info('GameMgr:StartUpdate')
    if self.isRun then
        warn('GameMgr:StartUpdate 正在运行')
        return
    end

    self.isRun = true

    local prevTime, nowTime = now(), nil -- two timestamps
    while (self.isRun and wait()) do
        nowTime = now()
        self.dt = nowTime - prevTime
        self.tt = nowTime - self.baseTime
        self:Update(self.dt, self.tt)
        prevTime = nowTime
    end
end

--- 停止Update
function GameMgr:StopUpdate()
    info('GameMgr:StopUpdate')
    self.isRun = false
end

--- TEST ONLY 处理Example01CustomEvent事件
-- 函数命名格式为 事件名 + 'Handler'
function GameMgr:Example01CustomEventHandler()
    debug('收到Example01CustomEvent')
    self:StartUpdate()
end

--- TEST ONLY 处理Example02CustomEvent事件
-- 函数命名格式为 事件名 + 'Handler'
function GameMgr:Example02CustomEventHandler()
    debug('收到Example02CustomEvent')
    debug('打印预加载的表格Example01,单一主键')
    table.dump(CsvConfig.Test01)
    debug('打印预加载的表格Example02,多主键')
    table.dump(CsvConfig.Test02)
    debug('打印预加载的表格Example02,单一主键,主键为Type')
    table.dump(CsvConfig.Test03)
end

--- TEST ONLY 处理Example02CustomEvent事件
-- 函数命名格式为 事件名 + 'Handler'
function GameMgr:Example03CustomEventHandler()
    debug('[信息] 收到Example03CustomEvent')
    self:StopUpdate()
end

return GameMgr
