--- 网路工具/事件工具
-- @module Network utilities
-- @copyright Lilith Games, Avatar Team
-- @author Shang Ma, Yuancheng Zhang
local NetUtil = class('NetUtil')

--- 向指定的玩家发送消息
-- @param @string _eventName 事件的名字
-- @param _player 玩家对象
-- @param ... 事件参数
function NetUtil.static.Fire_C(_eventName, _player, ...)
    if _player.Player == nil or _player.Player.ClassName ~= 'PlayerInstance' then
        print('[错误] Fire_C 第二个参数需要是玩家对象,错误事件为 ',_eventName)
        return
    end
    if _player.C_Event[_eventName] == nil then
        print(string.format('[错误] 玩家身上不存在%s事件', _eventName))
        return
    end
    _player.C_Event[_eventName]:Fire(...)
end

--- 向服务端发送消息
-- @param @string _eventName 事件的名字(严格对应)
-- @param ... 事件参数
function NetUtil.static.Fire_S(_eventName, ...)
    if world.S_Event[_eventName] == nil then
        print(string.format('[错误] 服务端不存在%s事件', _eventName))
        return
    end
    world.S_Event[_eventName]:Fire(...)
end

--- 客户端广播
-- @param @string _eventName 事件的名字(严格对应)
-- @param ... 事件参数
function NetUtil.Broadcast(_eventName, ...)
	world.Players:BroadcastEvent(_eventName, ...)
end

--- 向指定的玩家发送消息,并显示事件信息
-- @param @string _eventName 事件的名字
-- @param _player 玩家对象
-- @param ... 事件参数
function NetUtil.static.Fire_C_Show(_eventName, _player,  ...)
    NetUtil.Fire_C(_eventName,_player, ...)
    print(string.format('[信息] 客户端事件: %s , 玩家: ', _eventName, _player.Name))
end

---向服务端发送消息,并显示事件信息
---@param _eventName string
---@paran ... 事件参数
function NetUtil.static.Fire_S_Show(_eventName, ...)
    NetUtil.Fire_S(_eventName, ...)
    print(string.format('[信息] 服务器事件: %s', _eventName))
end

--- 客户端广播，并显示事件信息
-- @param @string _eventName 事件的名字(严格对应)
-- @param ... 事件参数
function NetUtil.Broadcast_Show(_eventName, ...)
    NetUtil.Broadcast(_eventName, ...)
    print(string.format('[信息] 客户端广播事件: %s ,参数为：%s ', _eventName, ...))
end

return NetUtil