---@module CamMgr 游戏中的运镜控制
---@copyright Lilith Games, Avatar Team
---@author RopzTao
local CamMgr, this = ModuleUtil.New('GameOverUI', ClientBase)
local T1 = Vector3(0, 21, 0)

---初始化函数
function CamMgr:Init()
    self.animationOverCallbackParams = {}
    ---self.camera = world.CurrentCamera
    self.camera = world:CreateObject('Camera', 'GameStartCam', localPlayer.Local.Independent)
    self.camera.CameraMode = Enum.CameraMode.Custom

    self.FixUpdateTable = {}
    self:InitTwnCls()
end

function CamMgr:InitTwnCls()
    self.GameStart =
        TweenController:new(
        'GameStart',
        self,
        function()
            return 3
        end,
        function(_t1, _t2, _dt)
            local t = (_t1 / _t2) * (_t1 / _t2)
            self.GameStart.camera.Position = self.GameStart.Valuator(t)
            if (self.GameStart.lastPosition) then
                self.GameStart.camera.Forward =
                    (self.GameStart.camera.Position - self.GameStart.lastPosition).Normalized
            end
            self.GameStart.lastPosition = self.GameStart.camera.Position
        end,
        function()
            world.CurrentCamera = localPlayer.Local.Independent.CamGame
            ---self.camera.CameraMode = Enum.CameraMode.Tpp
            ---self.camera.EnableMouseDrag = true
            ---wait()
            ---动画完成后的回调
            self:AnimationOverCallback()
        end,
        true,
        function()
            world.CurrentCamera = self.camera
            ---self.camera.EnableMouseDrag = false
            ---self.camera.CameraMode = Enum.CameraMode.Custom
            ---wait()
            local offset = Vector3(0.3, 2, 0)
            local dir = ((localPlayer.Forward.Normalized + Vector3(0, -1, 0)) / 2).Normalized
            local dis = self.camera.Distance
            local T3 = localPlayer.Position + offset:Rotate(Vector3.Up, localPlayer.Rotation.y) - dis * dir
            local deltaPosition = T3 - T1
            local Distance = deltaPosition.Magnitude

            ---调整曲率
            local T0 = T1 - 0.5 * Distance * deltaPosition.Normalized
            local T2 = T3 - dir * Distance * 0.4
            ---生成插值器
            self.GameStart.Valuator = function(t)
                local r = 1 - t
                return t * t * t * T3 + 3 * t * t * r * T2 + 3 * t * r * r * T1 + r * r * r * T0
            end
            --相机设定
            self.GameStart.camera = world.CurrentCamera
            self.GameStart.camera.Position = T0
            self.GameStart.camera.Forward = (T1 - T0).Normalized
            self.GameStart.lastPosition = nil
        end
    )
end

function CamMgr:FixUpdate(_dt)
    ---动画运行
    local Todo = {}
    for k, v in pairs(self.FixUpdateTable) do
        Todo[#Todo + 1] = v
    end
    for i, v in ipairs(Todo) do
        v:FixUpdate(_dt)
    end
end

---相机动画开始
function CamMgr:AnimationStart(...)
    ---防止180度
    local badPos = Vector3(T1.x - localPlayer.Position.x, 0, T1.z - localPlayer.Position.z)
    local angle = Vector3.Angle(badPos, localPlayer.Forward)
    if (angle < 40) then
        localPlayer:Rotate(0, 180, 0)
    end
    self.animationOverCallbackParams = {...}
    self.GameStart:Start()
    BattleGUI:SetActive(false)
    BottomGUI:SetActive(false)
    if PlayerGunMgr.curGun then
        PlayerGunMgr.curGun.m_gui:SetVisible(false)
    end
end

---相机动画结束后调用
function CamMgr:AnimationOverCallback()
    ---相机动画结束后, _mode, _sceneId, _pointsList, _sceneObj
    local _mode, _sceneId, _pointsList, _sceneObj = table.unpack(self.animationOverCallbackParams)
    if _mode == Const.GameModeEnum.OccupyMode then
        OccupyModeUI:Start(_mode, _sceneId, _pointsList, _sceneObj)
    elseif _mode == Const.GameModeEnum.BombMode then
        BombModeUI:Start(_mode, _sceneId, _pointsList, _sceneObj)
    elseif _mode == Const.GameModeEnum.DeathmatchMode then
        DeathmatchModeUI:Start(_mode, _sceneId, _pointsList, _sceneObj)
    end
    ShareUI:Start(_mode, _sceneId, _pointsList, _sceneObj)
    ChooseOccUI:GameStart(_mode, _sceneId, _pointsList, _sceneObj)
    BottomGUI:SetActive(true)
    BattleGUI:SetActive(true)
    if PlayerGunMgr.curGun then
        PlayerGunMgr.curGun.m_gui:SetVisible(true)
    end
    NetUtil.Fire_S('CameraMoveEndEvent', localPlayer)
end

return CamMgr
