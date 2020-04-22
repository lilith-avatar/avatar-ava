--- 该脚本为动画主要函数代码
-- @script UI Animation Main Functions
-- @copyright Lilith Games, Avatar Team
-- @author Xinwu Zhang

wait()
local DataModule = require(script.Parent.DataModule)
DataModule:Init()

local OnPlay = false

--为一个UI赋值
function InsertParameter(UIObj, ParaTable, DataName)
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
        script.Parent.Parent.AnimationStateEvent:Fire(DataName, ParaTable.Tag)
    end
end

function StartAnimation(DataName)
    --判断是否已经有动画正在播放中
    if OnPlay then
        print('不允许同时播放两段动画')
        return
    end

    OnPlay = true

    DataModule:Calculate(DataName)
    Data = DataModule.Data[DataName]
    if Data.count == nil or Data.count == 0 then
        print('配表错误,请填写动画数据的帧数')
        return
    end
    for k, v in pairs(Data) do
        if k ~= 'count' then
            InsertParameter(v.Obj, v.Init)
        end
    end
    script.Parent.Parent.AnimationStateEvent:Fire(DataName, 'Start')
    for i = 1, Data.count do
        wait(0.016)
        for k, v in pairs(Data) do
            if k ~= 'count' and v.PerFrame[i] then
                InsertParameter(v.Obj, v.PerFrame[i], DataName)
            end
        end
    end
    script.Parent.Parent.AnimationStateEvent:Fire(DataName, 'Complete')

    OnPlay = false
end

script.Parent.Parent.StartAnimationEvent:Connect(StartAnimation)
