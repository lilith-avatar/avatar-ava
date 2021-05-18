--- 全局函数的定义
--- @module GlobalFunc Defines
--- @copyright Lilith Games, Avatar Team
--- @author Sid Zhang, Yuancheng Zhang
local GlobalFunc = {}

--- 埋点上传日志
--- @param _tableName string 表名
function GlobalFunc.UploadLogs(_tableName, ...)
    local args = {...}
    if localPlayer then
        pcall(
            function()
                TrackService.CloudLogFromClient({_tableName, table.unpack(args)})
            end
        )
    else
        pcall(
            function()
                TrackService.CloudLogFromServer({_tableName, table.unpack(args)})
            end
        )
    end
end

-- 检查碰撞对象是否为NPC
-- Server-side 一般用于服务器端
function GlobalFunc.CheckHitObjIsPlayer(_hitObj)
    return _hitObj and _hitObj.ClassName == 'PlayerInstance' and _hitObj.Avatar and
        _hitObj.Avatar.ClassName == 'PlayerAvatarInstance'
end

return GlobalFunc
