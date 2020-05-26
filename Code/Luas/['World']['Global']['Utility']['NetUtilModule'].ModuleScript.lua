--- 网路工具/事件工具
-- @module Network utilities
-- @copyright Lilith Games, Avatar Team
-- @author Sharif Ma, Yuancheng Zhang, Yen Yuan
local NetUtil = {}

--- 向指定的玩家发送消息
-- @param @string _eventName 事件的名字
-- @param _player 玩家对象
-- @param ... 事件参数
function NetUtil.Fire_C(_eventName, _player, ...)
    if _player.Player == nil or _player.Player.ClassName ~= 'PlayerInstance' then
        error('Fire_C 第二个参数需要是玩家对象,错误事件为 ', _eventName)
        return
    end
    if _player.C_Event[_eventName] == nil then
        error(string.format('玩家身上不存在%s事件', _eventName))
        return
    end
    local args = {...}
    for k, v in pairs(args) do
        if type(v) == 'table' then
            args[k] = string.format('JSON%sJSON', LuaJson:encode(v))
        end
    end
    table.dump(args)
    _player.C_Event[_eventName]:Fire(table.unpack(args))
    debug(string.format('客户端事件: %s , 玩家: ', _eventName, _player.Name))
end

--- 向服务端发送消息
-- @param @string _eventName 事件的名字(严格对应)
-- @param ... 事件参数
function NetUtil.Fire_S(_eventName, ...)
    if world.S_Event[_eventName] == nil then
        error(string.format('服务端不存在%s事件', _eventName))
        return
    end
    local _msg = {...}
    for k, v in pairs(_msg) do
        if type(v) == 'table' then
            _msg[k] = string.format('JSON%sJSON', LuaJson:encode(v))
        end
    end
    world.S_Event[_eventName]:Fire(table.unpack(_msg))
    info(string.format('服务器事件: %s', _eventName))
end

--- 客户端广播
-- @param @string _eventName 事件的名字(严格对应)
-- @param ... 事件参数
function NetUtil.Broadcast(_eventName, ...)
    local _msg = {...}
    for k, v in pairs(_msg) do
        if type(v) == 'table' then
            _msg[k] = string.format('JSON%sJSON', LuaJson:encode(v))
        end
    end
    world.Players:BroadcastEvent(_eventName, table.unpack(_msg))
    info(string.format('[信息] 客户端广播事件: %s ,参数为：%s ', _eventName, table.unpack(_msg)))
end

return NetUtil
