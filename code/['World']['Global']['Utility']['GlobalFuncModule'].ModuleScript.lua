--- 全局函数的定义
--- @module GlobalFunc Defines
--- @copyright Lilith Games, Avatar Team
--- @author Sid Zhang
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

return GlobalFunc
