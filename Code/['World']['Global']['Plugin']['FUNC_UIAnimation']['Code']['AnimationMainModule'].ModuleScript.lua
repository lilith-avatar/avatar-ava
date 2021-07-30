--- UI动画插件-表现相关
--- @module AnimationMain Animation Plugin - Animation Main
--- @copyright Lilith Games, Avatar Team
--- @author Xinwu Zhang, Yuancheng Zhang
--- @see https://github.com/lilith-avatar/avatar-ava/wiki/Plugins#func_uianimation
local AnimationMain = {}

---配置中默认的每秒帧数
local DEFAULT_FPS = 60

function AnimationMain:Init()
    if localPlayer == nil then
        print('禁止在服务端使用UI动效模块,Init无效')
        return
    end

    self.DataModule = require(script.Parent.DataModule)
    self.DataModule:Init()

    self.startEvent = localPlayer.C_Event.StartAnimationEvent
    self.stateEvent = localPlayer.C_Event.AnimationStateEvent
    self.startEvent:Connect(
        function(_dataName, _isBackRun, _uiList)
            self:StartAnimation(_dataName, _isBackRun, _uiList)
        end
    )
    self.funcList = {}
    self.timeInterval = 1 / DEFAULT_FPS
    self.timeDiff = 0
end

---开始播放动画
---@param _dataName string 在表中配置的动画的名字
---@param _isBackRun boolean 是否倒放
---@param _uiList table 若为自定义UI节点,使用的节点列表
function AnimationMain:StartAnimation(_dataName, _isBackRun, _uiList)
    if self.DataModule:Calculate(_dataName) == false then
        print('计算数据出错,检查log查看错误原因')
        return
    end
    local Data = self.DataModule.Data[_dataName]
    if Data.count == nil or Data.count == 0 then
        print('配表错误,请填写动画数据的帧数')
        return
    end
    local count = Data.count
    local index = 1
    self.stateEvent:Fire(_dataName, 'Start', _uiList)
    ---传入自定义UI节点列表
    if _uiList then
        for i, v in pairs(_uiList) do
            Data[i].Obj = v
        end
    end
    if _isBackRun == nil or _isBackRun == false then
        for k, v in pairs(Data) do
            if k ~= 'count' and v.Obj and not v.Obj:IsNull() then
                --[[if not v.Obj or v.Obj:IsNull() then
                    table.removebyvalue(self.funcList, update)
                    self.stateEvent:Fire(_dataName, 'Complete', _uiList)
                    return
                end]]
                self:InsertParameter(v.Obj, v.Init, _uiList)
            end
        end
    else
        for k, v in pairs(Data) do
            if k ~= 'count' and v.Obj and not v.Obj:IsNull() then
                --[[ if not v.Obj or v.Obj:IsNull() then
                    table.removebyvalue(self.funcList, update)
                    self.stateEvent:Fire(_dataName, 'Complete', _uiList)
                    return
                end]]
                self:InsertParameter(v.Obj, v.PerFrame[#v.PerFrame], _uiList)
            end
        end
    end
    local function update()
        if _isBackRun == nil or _isBackRun == false then
            for k, v in pairs(Data) do
                if k ~= 'count' and v.PerFrame[index] then
                    ---若UI销毁则移除
                    if not v.Obj or v.Obj:IsNull() then
                        table.removebyvalue(self.funcList, update)
                        self.stateEvent:Fire(_dataName, 'Complete', _uiList)
                        return
                    end
                    self:InsertParameter(v.Obj, v.PerFrame[index], _dataName, _uiList)
                end
            end
        else
            for k, v in pairs(Data) do
                if k ~= 'count' and v.PerFrame[Data.count - index + 1] then
                    ---若UI销毁则移除
                    if not v.Obj or v.Obj:IsNull() then
                        table.removebyvalue(self.funcList, update)
                        self.stateEvent:Fire(_dataName, 'Complete', _uiList)
                        return
                    end
                    self:InsertParameter(v.Obj, v.PerFrame[count - index + 1], _dataName, _uiList)
                end
            end
        end
        index = index + 1
        if index > count then
            ---播放完成
            table.removebyvalue(self.funcList, update)
            self.stateEvent:Fire(_dataName, 'Complete', _uiList)
        end
    end
    table.insert(self.funcList, update)
end

function AnimationMain:InsertParameter(_uiObj, _paraTable, _dataName, _uiList)
    if _uiObj == nil then
        print('找不到Ui动画的节点', _dataName, '检查配置表与查看log寻找原因')
        return
    end
    if _paraTable.Size then
        _uiObj.Size = _paraTable.Size
    end
    if _paraTable.AnchorsX then
        _uiObj.AnchorsX = _paraTable.AnchorsX
    end
    if _paraTable.AnchorsY then
        _uiObj.AnchorsY = _paraTable.AnchorsY
    end
    if _paraTable.Angle then
        _uiObj.Angle = _paraTable.Angle
    end
    if _paraTable.Offset then
        _uiObj.Offset = _paraTable.Offset
    end
    if _paraTable.Alpha then
        _uiObj.Alpha = _paraTable.Alpha
        for k, v in pairs(_uiObj:GetChildren()) do
            if v.Alpha then
                v.Alpha = _paraTable.Alpha
            end
            for k2, v2 in pairs(v:GetChildren()) do
                if v2.Alpha then
                    v2.Alpha = _paraTable.Alpha
                end
            end
        end
    end
    if _paraTable.Tag then
        self.stateEvent:Fire(_dataName, _paraTable.Tag, _uiList)
    end
end

---更新所有的动画
---@param _dt number 此帧的时间
function AnimationMain:RefreshList(_dt)
    local refreshTimes = 1
    if _dt > self.timeInterval then
        ---当前帧数小于设定的刷新帧率,需要进行时间累加
        self.timeDiff = self.timeDiff + _dt - self.timeInterval
    end
    local mod = self.timeDiff / self.timeInterval
    mod = math.floor(mod)
    if mod > 0 then
        ---此帧需要进行1次以上的动画刷新
        refreshTimes = refreshTimes + mod
        self.timeDiff = self.timeDiff - mod * self.timeInterval
    end
    for i = 1, refreshTimes do
        for _, func in pairs(self.funcList) do
            func()
        end
    end
end

---外部调用,渲染帧更新函数
function AnimationMain:FixUpdate(_dt)
    self:RefreshList(_dt)
end

return AnimationMain
