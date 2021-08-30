--- 埋点数据工具
--- @module CloudLogUtil
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local CloudLogUtil = {}

---埋点工具初始化
---@param _gameId string 游戏的唯一ID,和服务端定好后不可以更改的,游戏开始前执行
function CloudLogUtil.Init(_gameId)
    CloudLogUtil.gameId = _gameId
end

---触发埋点相应的事件调用
---@param _key string 埋点的键
function CloudLogUtil.UploadLog(_key, _table, _PlayerId)
    local arg = JSON:encode(_table)
    if localPlayer then
        TrackService.CloudLogFromClient({_key, CloudLogUtil.gameId, arg, _PlayerId})
    else
        TrackService.CloudLogFromServer({_key, CloudLogUtil.gameId, arg, _PlayerId})
    end
end

return CloudLogUtil
