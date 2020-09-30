---
---@script: Description
---@module: Module Script
---Date: 2020-05-28 20:00:12
---LastEditors: OBKoro1
---LastEditTime: 2020-06-24 16:59:54
---FilePath: \Code\Luas\['World']['Global']['Utility']['CamUtilModule'].ModuleScript.lua
---
---摄像机工具类
---@module Cam Utility
---@copyright Lilith Games, Avatar Team
---@author Sharif Ma
---@class CamUtil
local CamUtil = {}

---将摄像机在水平面上转动到和角色朝向一致的角度
---@param _player PlayerInstance 摄像机看向的物体
---@param _cam Camera 转动的摄像机
---@param _time number 转动过程的事件，不填则瞬间转动
function CamUtil.ToRoleForward(_player, _cam, _time)
    _time = _time or 0
    local dir = _player.Position - _cam.Position
    local forward = _player.Forward
    local alpha = Vector2.Angle(Vector2(dir.x, dir.z), Vector2(forward.x, forward.z))
    local left = _player.Left
    if Vector3.Angle(left, dir) > 90 then
        alpha = 360 - alpha
    end
    if _time == 0 then
        _cam:CameraMoveInDegree(Vector2(alpha, 0))
        return
    end
    invoke(
        function()
            local curTime = 0
            while true do
                local dt = wait()
                local dtDe = alpha * dt / _time
                _cam:CameraMoveInDegree(Vector2(dtDe, 0))
                curTime = curTime + dt
                if curTime >= _time then
                    return
                end
            end
        end
    )
end

return CamUtil
