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
function CloudLogUtil.UploadLog(_key, ...)
    local tableName = CloudLogUtil.gameId .. '_' .. _key
    local args = { ... }
    if localPlayer then
        TrackService.CloudLogFromClient({ tableName, CloudLogUtil.gameId, table.unpack(args) })
    else
        TrackService.CloudLogFromServer({ tableName, CloudLogUtil.gameId, table.unpack(args) })
    end
end

return CloudLogUtil