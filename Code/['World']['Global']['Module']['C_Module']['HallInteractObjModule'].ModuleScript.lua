--- @module HallInteractObj
--- @copyright Lilith Games, Avatar Team
--- @author Yuchen Wang
local HallInteractObj, this = ModuleUtil.New('HallInteractObj', ClientBase)

--- 初始化
function HallInteractObj:Init()
    self.objs =
        world:CreateInstance(
        'HallObjs',
        'HallObjs',
        localPlayer.Local.Independent,
        Vector3(0, -300, 0),
        EulerDegree(0, 0, 0)
    )
    self:ReadObjs()
    --配置可交互物参数
    self.rangeAc = Config.Hall[1003].TargetAc
    self.maxVc = Config.Hall[1003].MaxVc
    self.targetDownAngle = Config.Hall[1003].TargetDownAngle
    self.targetDownTime = Config.Hall[1003].TargetDownTime
    self.targetStayTime = Config.Hall[1003].TargetStayTime
    self.rubberScale = Config.Hall[1004].RubberScale
    self.rubberScaleTime = Config.Hall[1004].RubberScaleTime
    self.rubberShakeTime = Config.Hall[1004].RubberShakeTime
    self.rubberShakeStrength = Config.Hall[1004].RubberShakeStrength
    self.rubberNewScale = Config.Hall[1005].RubberScale
    self.rubberNewScaleTime = Config.Hall[1005].RubberScaleTime
    self.rubberNewShakeTime = Config.Hall[1005].RubberShakeTime
    self.rubberNewShakeStrength = Config.Hall[1005].RubberShakeStrength
    --计时
    self.timer = 0
    self.arrowTime = Config.Hall[1006].ArrowChangeTime
    self.arrowTimer = self.arrowTime
    self.color = Config.Hall[1006].ArrowColor
    self.color = table.reverse(self.color)
    --{Color(255, 253, 45, 255), Color(166, 145, 5, 255), Color(157, 150, 150, 255), Color(60, 47, 47, 255)}
    self.arrowColor = 1
end

function HallInteractObj:ReadObjs()
    self.ranges = {}
    self.rubbers = {}
    self.rubbersNew = {}
    self.arrow = {}
    for i = 1, 4 do
        self.arrow[i] = {}
    end
    for _, v in pairs(self.objs:GetChildren()) do
        local type = string.split(v.Name, '_')
        if type[2] == 'Sphere' then
            self.ranges[tonumber(type[3])] = {
                obj = v,
                nowDir = -1,
                velocity = 0,
                health = 100,
                isChangeDir = false,
                state = false
            }
        elseif type[2] == 'Rubber' then
            self.rubbers[tonumber(type[3])] = false
        elseif type[2] == 'RubberNew' then
            self.rubbersNew[tonumber(type[3])] = false
        elseif type[2] == 'Arrow' then
            self.arrow[tonumber(type[3])] = v:GetChildren()
        end
    end
    for k, v in pairs(self.ranges) do
        if math.fmod(k, 2) == 1 then
            v.nowDir = 1
        else
            v.nowDir = -1
        end
        v.obj.LinearVelocity = v.obj.Left * v.nowDir * 2
    end
    self.isRun = true
end

function HallInteractObj:Update(_dt)
    if self.isRun then
        self:CheckPlayerNum(_dt)
        self:ChangeArrow(_dt)
        self:RangeMove(_dt)
    end
end

---靶场移动
function HallInteractObj:RangeMove(_dt)
    for _, v in pairs(self.ranges) do
        if not v.state then
            v.velocity = v.velocity + self.rangeAc > self.maxVc and self.maxVc or v.velocity + self.rangeAc
            v.obj.Position = v.obj.Position + v.nowDir * v.velocity * v.obj.Left * _dt
            if Vector3.Project(v.obj.Position, v.obj.Left).z < 18 and Vector3.Project(v.obj.Position, v.obj.Left).z > 9 then
                v.isChangeDir = false
            elseif not v.isChangeDir then
                v.isChangeDir = true
                v.velocity = 0
                v.nowDir = (-1) * v.nowDir
            end
        end
    end
end

---箭头变色
function HallInteractObj:ChangeArrow(_dt)
    self.arrowTimer = self.arrowTimer - _dt
    if self.arrowTimer < 0 then
        self.arrowTimer = self.arrowTime
        self.arrowColor = self.arrowColor > 3 and 1 or self.arrowColor + 1
        local curColor = self.arrowColor
        for i = 4, 1, -1 do
            for j = 1, 4 do
                self.arrow[j][i].Color = self.color[curColor]
            end
            curColor = curColor + 1 > 4 and 1 or curColor + 1
        end
    end
end

---轮询房间人数
function HallInteractObj:CheckPlayerNum(_dt)
    self.timer = self.timer + _dt
    if self.timer > 1 then
        self.objs.TotalNumTV.SurfaceGUI.Image.Text.Text = table.nums(world:FindPlayers())
        self.timer = 0
    end
end

---重设物体
function HallInteractObj:ResetObjs()
    self.isRun = false
    ---销毁原物体
    self.objs:Destroy()
    self.objs =
        world:CreateInstance(
        'HallObjs',
        'HallObjs',
        localPlayer.Local.Independent,
        Vector3(0, -300, 0),
        EulerDegree(0, 0, 0)
    )
end

--击中目标
function HallInteractObj:HitTargetCallback(_infoList)
    local type = string.split(_infoList.HitObject.Name, '_')
    if type[2] == 'Light' then
        if _infoList.HitObject.PointLight.Enabled then
            _infoList.HitObject.PointLight.Enabled = false
        else
            _infoList.HitObject.PointLight.Enabled = true
        end
    elseif type[2] == 'SpotLight' then
        if _infoList.HitObject.SpotLight.Enabled then
            _infoList.HitObject.SpotLight.Enabled = false
        else
            _infoList.HitObject.SpotLight.Enabled = true
        end
    elseif type[2] == 'Range' and not self.ranges[tonumber(type[3])].state then
        self.ranges[tonumber(type[3])].health = self.ranges[tonumber(type[3])].health - _infoList.Damage
        if self.ranges[tonumber(type[3])].health < 0 then
            self.ranges[tonumber(type[3])].state = true
            self.ranges[tonumber(type[3])].obj.IsStatic = true
            local RangeTweener =
                Tween:TweenProperty(
                self.ranges[tonumber(type[3])].obj,
                {Rotation = self.targetDownAngle},
                self.targetDownTime,
                Enum.EaseCurve.Linear
            )
            RangeTweener:Play()
            invoke(
                function()
                    RangeTweener:Reverse()
                    RangeTweener.OnComplete:Connect(
                        function()
                            RangeTweener:Destroy()
                            self.ranges[tonumber(type[3])].velocity = 0
                            self.ranges[tonumber(type[3])].health = 100
                            self.ranges[tonumber(type[3])].state = false
                            self.ranges[tonumber(type[3])].obj.IsStatic = false
                        end
                    )
                end,
                self.targetStayTime
            )
        end
    elseif type[2] == 'Rubber' and not self.rubbers[tonumber(type[3])] then
        self.rubbers[tonumber(type[3])] = true
        local RubberScale =
            Tween:TweenProperty(
            _infoList.HitObject,
            {Stretch = self.rubberScale},
            self.rubberScaleTime,
            Enum.EaseCurve.SinInOut
        )
        local RubberShake =
            Tween:ShakeProperty(_infoList.HitObject, {'Rotation'}, self.rubberShakeTime, self.rubberShakeStrength)
        RubberShake:Play()
        RubberScale:Play()
        invoke(
            function()
                RubberScale:Reverse()
                RubberScale.OnComplete:Connect(
                    function()
                        RubberScale:Destroy()
                        RubberShake:Destroy()
                        self.rubbers[tonumber(type[3])] = false
                    end
                )
            end,
            self.rubberShakeTime + 0.2
        )
    elseif type[2] == 'RubberNew' and not self.rubbersNew[tonumber(type[3])] then
        self.rubbersNew[tonumber(type[3])] = true
        local RubberNewScale =
            Tween:TweenProperty(
            _infoList.HitObject,
            {Stretch = self.rubberNewScale},
            self.rubberNewScaleTime,
            Enum.EaseCurve.SinInOut
        )
        local RubberNewShake =
            Tween:ShakeProperty(_infoList.HitObject, {'Rotation'}, self.rubberNewShakeTime, self.rubberNewShakeStrength)
        RubberNewShake:Play()
        RubberNewScale:Play()
        invoke(
            function()
                RubberNewScale:Reverse()
                RubberNewScale.OnComplete:Connect(
                    function()
                        RubberNewScale:Destroy()
                        RubberNewShake:Destroy()
                        self.rubbersNew[tonumber(type[3])] = false
                    end
                )
            end,
            self.rubberNewShakeTime + 0.2
        )
    end
end

return HallInteractObj
