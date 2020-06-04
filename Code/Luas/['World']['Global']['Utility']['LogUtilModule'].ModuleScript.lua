--- Debug工具
-- @module Debug utilities
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
local LogUtil = {}

--- 日志级别枚举
LogUtil.LevelEnum = {
    -- 指出细粒度信息事件对调试应用程序是非常有帮助的 主要用于开发过程中打印一些运行信息
    DEBUG = 1,
    -- 消息在粗粒度级别上突出强调应用程序的运行过程
    -- 打印一些你感兴趣的或者重要的信息 这个可以用于生产环境中输出程序运行的一些重要信息
    -- 但是不能滥用 避免打印过多的日志
    INFO = 2,
    -- 表明会出现潜在错误的情形 有些信息不是错误信息 但是也要给程序员的一些提示
    WARN = 3,
    -- 指出虽然发生错误事件 但仍然不影响系统的继续运行
    -- 打印错误和异常信息 如果不想输出太多的日志 可以使用这个级别
    ERROR = 4
}

--- 日志级别
LogUtil.level = LogUtil.LevelEnum.DEBUG

--- 开关
LogUtil.debugMode = true

function LogUtil.Test(...)
    if LogUtil.debugMode and LogUtil.level <= LogUtil.LevelEnum.DEBUG then
        print('[TEST]', ...)
    end
end

function LogUtil.Debug(...)
    if LogUtil.debugMode and LogUtil.level <= LogUtil.LevelEnum.DEBUG then
        print('[DEBUG]', ...)
    end
end

function LogUtil.Info(...)
    if LogUtil.debugMode and LogUtil.level <= LogUtil.LevelEnum.INFO then
        print('[INFO]', ...)
    end
end

function LogUtil.Warn(...)
    if LogUtil.debugMode and LogUtil.level <= LogUtil.LevelEnum.WARN then
        print('[WARN]', ...)
    end
end

return LogUtil
