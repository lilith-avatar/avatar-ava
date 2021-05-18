--- CustomEvent的定义，用于事件动态生成
-- @module Event Defines
-- @copyright Lilith Games, Avatar Team
local Events = {}

-- 服务器事件列表
Events.ServerEvents = {}

-- 客户端事件列表
Events.ClientEvents = {
    --通知事件
    'NoticeEvent'
}
return Events
