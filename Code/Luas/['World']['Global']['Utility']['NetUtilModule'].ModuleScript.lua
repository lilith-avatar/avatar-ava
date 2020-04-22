--- 网路工具/事件工具
-- @module Network utilities
-- @copyright Lilith Games, Avatar Team
-- @author Shang Ma, Yuancheng Zhang
local NetUtil = {}

--- 向指定的玩家发送消息
-- @param @string _eventName 事件的名字
-- @param _player 玩家对象
-- @param ... 事件参数
function NetUtil.Fire_C(_eventName, _player, ...)
    if _player == nil or _player.ClassName ~= 'PlayerInstance' then
        print(string.format('[错误] Fire_C 第二个参数需要是玩家对象'))
        return
    end
    if _player.C_Event[_eventName] == nil then
        print('[错误] 玩家身上不存在', _eventName, '事件')
        return
    end
    _player.C_Event[_eventName]:Fire(...)
    print('[信息] 客户端事件:', _eventName, ',玩家:', _player.Name, ',内容:', ...)
end

--- 向服务端发送消息
-- @param @string _eventName 事件的名字(严格对应)
-- @param ... 事件参数
function NetUtil.Fire_S(_eventName, ...)
    -- if _player == nil or _player.ClassName ~= 'PlayerInstance' then
    --     print('Fire_S第二个参数需要是玩家对象')
    --     return
    -- end
    if world.S_Event[_eventName] == nil then
        print('[错误] 服务端不存在', _eventName, '事件')
        return
    end
    world.S_Event[_eventName]:Fire(...)
    --print(...)
    print('[信息] 服务器事件:', _eventName, '内容', ...)
end

return NetUtil
