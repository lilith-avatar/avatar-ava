--- UI动画插件-表现相关
-- @module UI Animation Plugin - Animation Main
-- @copyright Lilith Games, Avatar Team
-- @author Xinwu Zhang, Yuancheng Zhang
-- @see https://github.com/lilith-avatar/avatar-ava/wiki/Plugins#func_uianimation
local AnimationMain = {}

function AnimationMain:Init()
    info('AnimationMain:Init')
    self.onPlay = false
    self:InitListeners()
    self.DataModule = require(world.Global.Plugin.FUNC_UIAnimation.Code.DataModule)
    self.DataModule:Init()
end

function AnimationMain:InitListeners()
    EventUtil.LinkConnects(localPlayer.C_Event, AnimationMain, 'AnimationMain', self)
end

function AnimationMain:StartAnimationEventHandler(_dataName, _isBackRun)
    --判断是否已经有动画正在播放中
    if self.onPlay then
        warn('不允许同时播放两段动画')
        return
    end

    self.onPlay = true

    self.DataModule:Calculate(_dataName)
    local Data = self.DataModule.Data[_dataName]
    if Data.count == nil or Data.count == 0 then
        error('配表错误,请填写动画数据的帧数')
        return
    end
    if _isBackRun == nil or _isBackRun == false then
        for k, v in pairs(Data) do
            if k ~= 'count' then
                self:InsertParameter(v.Obj, v.Init)
            end
        end
        localPlayer.C_Event.AnimationStateEvent:Fire(_dataName, 'Start')
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
    localPlayer.C_Event.AnimationStateEvent:Fire(_dataName, 'Complete')
    self.onPlay = false
end

function AnimationMain:InsertParameter(UIObj, ParaTable, DataName)
    if ParaTable.Size then
        UIObj.Size = ParaTable.Size
    end
    if ParaTable.AnchorsX then
        UIObj.AnchorsX = ParaTable.AnchorsX
    end
    if ParaTable.AnchorsY then
        UIObj.AnchorsY = ParaTable.AnchorsY
    end
    if ParaTable.Angle then
        UIObj.Angle = ParaTable.Angle
    end
    if ParaTable.Offset then
        UIObj.Offset = ParaTable.Offset
    end
    if ParaTable.Alpha then
        UIObj.Alpha = ParaTable.Alpha
        for k, v in pairs(UIObj:GetChildren()) do
            if v.Alpha then
                v.Alpha = ParaTable.Alpha
            end
            for k2, v2 in pairs(v:GetChildren()) do
                if v2.Alpha then
                    v2.Alpha = ParaTable.Alpha
                end
            end
        end
    end
    if ParaTable.Tag then
        localPlayer.C_Event.AnimationStateEvent:Fire(DataName, ParaTable.Tag)
    end
end

return AnimationMain
