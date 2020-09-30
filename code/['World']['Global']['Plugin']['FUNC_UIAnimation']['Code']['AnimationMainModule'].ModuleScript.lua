--- UI动画插件-表现相关
-- @module UI Animation Plugin - Animation Main
-- @copyright Lilith Games, Avatar Team
-- @author Xinwu Zhang, Yuancheng Zhang
-- @see https://github.com/lilith-avatar/avatar-ava/wiki/Plugins#func_uianimation
local AnimationMain = {}

function AnimationMain:Init()
    if localPlayer == nil then warn('禁止在服务端使用UI动效模块,Init无效') return end

    self.DataModule = require(world.Global.Plugin.FUNC_UIAnimation.Code.DataModule)
    self.DataModule:Init()

    --事件及事件文件夹的创建
    if localPlayer.C_Event == nil then world:CreateObject('FolderObject','C_Event',localPlayer) end
    self.startEvent = world:CreateObject('CustomEvent','StartAnimationEvent',localPlayer.C_Event)
    self.stateEvent = world:CreateObject('CustomEvent','AnimationStateEvent',localPlayer.C_Event)
    self.startEvent:Connect(function(_dataName,_isBackRun)
        self:StartAnimation(_dataName,_isBackRun)
    end)

    info('AnimationMain:Init   Success')
end

function AnimationMain:StartAnimation(_dataName, _isBackRun)
    if self.DataModule:Calculate(_dataName) == false then
        warn('计算数据出错,检查log查看错误原因')
        return
    end
    local Data = self.DataModule.Data[_dataName]
    if Data.count == nil or Data.count == 0 then
        warn('配表错误,请填写动画数据的帧数')
        return
    end
    if _isBackRun == nil or _isBackRun == false then
        for k, v in pairs(Data) do
            if k ~= 'count' then
                self:InsertParameter(v.Obj, v.Init)
            end
        end
        self.stateEvent:Fire(_dataName, 'Start')
        for i = 1, Data.count do
            wait(0.016)
            for k, v in pairs(Data) do
                if k ~= 'count' and v.PerFrame[i] then
                    self:InsertParameter(v.Obj, v.PerFrame[i], _dataName)
                end
            end
        end
    elseif _isBackRun == true then
        for k, v in pairs(Data) do
            if k ~= 'count' then
                self:InsertParameter(v.Obj, v.PerFrame[#v.PerFrame])
            end
        end
        localPlayer.C_Event.AnimationStateEvent:Fire(_dataName, 'Start')
        for i = 1, Data.count do
            wait(0.016)
            for k, v in pairs(Data) do
                if k ~= 'count' and v.PerFrame[Data.count - i + 1] then
                    self:InsertParameter(v.Obj, v.PerFrame[Data.count - i + 1], _dataName)
                end
            end
        end
    end
    self.stateEvent:Fire(_dataName, 'Complete')
    self.onPlay = false
end

function AnimationMain:InsertParameter(_uiObj, _paraTable, _dataName)
    if _uiObj == nil then
        warn('找不到Ui动画的节点',_dataName,'检查配置表与查看log寻找原因')
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
        self.stateEvent:Fire(_dataName, _paraTable.Tag)
    end
end

return AnimationMain
