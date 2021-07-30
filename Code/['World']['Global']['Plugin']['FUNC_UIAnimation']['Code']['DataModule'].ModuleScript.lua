--- UI动画插件-数据相关
--- @module DataModule Animation Plugin - DataModule
--- @copyright Lilith Games, Avatar Team
--- @author Xinwu Zhang
--- @see https://github.com/lilith-avatar/avatar-ava/wiki/Plugins#func_uianimation
local DataModule = {Data = {}}

--初始化函数,读取动画表
function DataModule:Init()
    if localPlayer == nil then
        print('禁止在服务端使用UI动效模块,Init无效')
        return
    end
    local InfoTable = Config.UIAnimation
    if InfoTable == nil then
        print('未找到UI动效的配置表,请检查Global/Csv/UIAnimation是否存在')
    end
    local RowNum = table.nums(InfoTable)
    for i = 1, RowNum do
        local AnimationName = InfoTable[i].AnimationName
        --如果该数据的动画名为新增,则在数据表中新插入一段空的动画数据
        if self.Data[AnimationName] == nil then
            self.Data[AnimationName] = {}
            if InfoTable[i].Count == 0 then
                print(AnimationName .. '动画未配置总帧数,配表错误,请检查配置表' .. i .. '行')
                goto Continue
            end
            self.Data[AnimationName].count = InfoTable[i].Count
        end

        --解析UI节点路径,获取UI节点
        local PathStr = InfoTable[i].UINode
        local UiPath = string.split(PathStr, '.')
        local UiNode
        if InfoTable[i].IsStatic == true then
            ---UI节点为静态,直接读表获得
            if UiPath[1] == 'Local' then
                UiNode = localPlayer
                for k, v in pairs(UiPath) do
                    if UiNode[v] then
                        UiNode = UiNode[v]
                    else
                        print('第' .. i .. '行节点路径未找到:', v, 'in', UiPath)
                        goto Continue
                    end
                end
            else
                print('暂时不支持Local以外的UI节点动画,请检查配置表第' .. i .. '行数据')
                goto Continue
            end
        else
            ---UI节点为动态
            PathStr = tonumber(PathStr)
        end

        --判断初始帧,并执行初始帧逻辑
        if InfoTable[i].IsInit == true then
            --记录初始帧
            self.Data[AnimationName][PathStr] = {}
            local NowData = self.Data[AnimationName][PathStr]
            NowData.Obj = UiNode
            NowData.KeyFrame = {}
            NowData.Init = {}
            NowData.PerFrame = {}
            if InfoTable[i].Size ~= Vector2(0, 0) then
                NowData.Init.Size = InfoTable[i].Size
            end
            if InfoTable[i].AnchorsX ~= Vector2(0, 0) then
                NowData.Init.AnchorsX = InfoTable[i].AnchorsX
            end
            if InfoTable[i].AnchorsY ~= Vector2(0, 0) then
                NowData.Init.AnchorsY = InfoTable[i].AnchorsY
            end
            if InfoTable[i].Angle ~= 0 then
                NowData.Init.Angle = InfoTable[i].Angle
            end
            if InfoTable[i].Offset ~= Vector2(0, 0) then
                NowData.Init.Offset = InfoTable[i].Offset
            end
            if InfoTable[i].Alpha ~= 0 then
                NowData.Init.Alpha = InfoTable[i].Alpha
            end
        else
            --配置表初始帧配置校验
            if self.Data[AnimationName][PathStr] == nil then
                print(AnimationName, PathStr, '未配置初始帧,配表错误')
                goto Continue
            end
            local tFrame, tSize, tAnchorsX, tAnchorsY, tAngle, tOffset, tAlpha, tTag
            --记录关键帧数据
            tType = InfoTable[i].Type
            if tType == '' then
                tType = 'Linear'
            end
            if InfoTable[i].KeyFrame ~= Vector2(0, 0) then
                tFrame = InfoTable[i].KeyFrame
            end
            if InfoTable[i].Size ~= Vector2(0, 0) then
                tSize = InfoTable[i].Size
            end
            if InfoTable[i].AnchorsX ~= Vector2(0, 0) then
                tAnchorsX = InfoTable[i].AnchorsX
            end
            if InfoTable[i].AnchorsY ~= Vector2(0, 0) then
                tAnchorsY = InfoTable[i].AnchorsY
            end
            if InfoTable[i].Angle ~= 0 then
                tAngle = InfoTable[i].Angle
            end
            if InfoTable[i].Offset ~= Vector2(0, 0) then
                tOffset = InfoTable[i].Offset
            end
            if InfoTable[i].Alpha ~= 0 then
                tAlpha = InfoTable[i].Alpha
            end
            if InfoTable[i].Tag ~= '' then
                tTag = InfoTable[i].Tag
            end

            OneFrame = {
                Frame = tFrame,
                Size = tSize,
                AnchorsX = tAnchorsX,
                AnchorsY = tAnchorsY,
                Angle = tAngle,
                Offset = tOffset,
                Alpha = tAlpha,
                Tag = tTag,
                Type = tType
            }
            table.insert(self.Data[AnimationName][PathStr].KeyFrame, OneFrame)
        end
        ::Continue::
    end
end

function DataModule:Calculate(_dataName)
    if self.Data[_dataName] == nil then
        print('找不到动画数据' .. _dataName)
        return false
    end
    for k, v in pairs(self.Data[_dataName]) do
        local NowKeyFrame = 0
        local NextKeyFrame = 0
        if k ~= 'count' then
            --Tag
            for i = 1, #v.KeyFrame do
                if v.KeyFrame[i].Tag then
                    if v.PerFrame[v.KeyFrame[i].Frame] == nil then
                        v.PerFrame[v.KeyFrame[i].Frame] = {}
                    end
                    v.PerFrame[v.KeyFrame[i].Frame].Tag = v.KeyFrame[i].Tag
                end
            end

            --Alpha
            for i = 1, #v.KeyFrame do
                if v.KeyFrame[i].Alpha then
                    NowKeyFrame = i
                    NextKeyFrame = i
                    break
                end
            end
            if NowKeyFrame ~= 0 then
                while next(v.KeyFrame, NextKeyFrame) do
                    local _, temp = next(v.KeyFrame, NextKeyFrame)
                    NextKeyFrame = next(v.KeyFrame, NextKeyFrame)
                    if temp.Alpha then
                        local n = v.KeyFrame[NowKeyFrame].Frame
                        local Count = v.KeyFrame[NextKeyFrame].Frame - v.KeyFrame[NowKeyFrame].Frame
                        local PerFrame =
                            DataModule:Interpolation(
                            v.KeyFrame[NowKeyFrame].Alpha,
                            v.KeyFrame[NowKeyFrame].Type,
                            v.KeyFrame[NextKeyFrame].Alpha,
                            v.KeyFrame[NextKeyFrame].Type,
                            Count
                        )
                        for i = n + 1, n + Count do
                            if v.PerFrame[i] == nil then
                                v.PerFrame[i] = {}
                            end
                            v.PerFrame[i].Alpha = PerFrame[i - n]
                        end
                        NowKeyFrame = NextKeyFrame
                    end
                end
            end

            --Offset
            NowKeyFrame = 0
            for i = 1, #v.KeyFrame do
                if v.KeyFrame[i].Offset then
                    NowKeyFrame = i
                    NextKeyFrame = i
                    break
                end
            end
            if NowKeyFrame ~= 0 then
                while next(v.KeyFrame, NextKeyFrame) do
                    local _, temp = next(v.KeyFrame, NextKeyFrame)
                    NextKeyFrame = next(v.KeyFrame, NextKeyFrame)
                    if temp.Offset then
                        local n = v.KeyFrame[NowKeyFrame].Frame
                        local Count = v.KeyFrame[NextKeyFrame].Frame - v.KeyFrame[NowKeyFrame].Frame
                        local PerFrame =
                            DataModule:Interpolation(
                            v.KeyFrame[NowKeyFrame].Offset,
                            v.KeyFrame[NowKeyFrame].Type,
                            v.KeyFrame[NextKeyFrame].Offset,
                            v.KeyFrame[NextKeyFrame].Type,
                            Count
                        )
                        for i = n + 1, n + Count do
                            if v.PerFrame[i] == nil then
                                v.PerFrame[i] = {}
                            end
                            v.PerFrame[i].Offset = PerFrame[i - n]
                        end
                        NowKeyFrame = NextKeyFrame
                    end
                end
            end

            --Size
            NowKeyFrame = 0
            for i = 1, #v.KeyFrame do
                if v.KeyFrame[i].Size then
                    NowKeyFrame = i
                    NextKeyFrame = i
                    break
                end
            end
            if NowKeyFrame ~= 0 then
                while next(v.KeyFrame, NextKeyFrame) do
                    local _, temp = next(v.KeyFrame, NextKeyFrame)
                    NextKeyFrame = next(v.KeyFrame, NextKeyFrame)
                    if temp.Size then
                        local n = v.KeyFrame[NowKeyFrame].Frame
                        local Count = v.KeyFrame[NextKeyFrame].Frame - v.KeyFrame[NowKeyFrame].Frame
                        local PerFrame =
                            DataModule:Interpolation(
                            v.KeyFrame[NowKeyFrame].Size,
                            v.KeyFrame[NowKeyFrame].Type,
                            v.KeyFrame[NextKeyFrame].Size,
                            v.KeyFrame[NextKeyFrame].Type,
                            Count
                        )
                        for i = n + 1, n + Count do
                            if v.PerFrame[i] == nil then
                                v.PerFrame[i] = {}
                            end
                            v.PerFrame[i].Size = PerFrame[i - n]
                        end
                        NowKeyFrame = NextKeyFrame
                    end
                end
            end

            --AnchorsX
            NowKeyFrame = 0
            for i = 1, #v.KeyFrame do
                if v.KeyFrame[i].AnchorsX then
                    NowKeyFrame = i
                    NextKeyFrame = i
                    break
                end
            end
            if NowKeyFrame ~= 0 then
                while next(v.KeyFrame, NextKeyFrame) do
                    local _, temp = next(v.KeyFrame, NextKeyFrame)
                    NextKeyFrame = next(v.KeyFrame, NextKeyFrame)
                    if temp.AnchorsX then
                        local n = v.KeyFrame[NowKeyFrame].Frame
                        local Count = v.KeyFrame[NextKeyFrame].Frame - v.KeyFrame[NowKeyFrame].Frame
                        local PerFrame =
                            DataModule:Interpolation(
                            v.KeyFrame[NowKeyFrame].AnchorsX,
                            v.KeyFrame[NowKeyFrame].Type,
                            v.KeyFrame[NextKeyFrame].AnchorsX,
                            v.KeyFrame[NextKeyFrame].Type,
                            Count
                        )
                        for i = n + 1, n + Count do
                            if v.PerFrame[i] == nil then
                                v.PerFrame[i] = {}
                            end
                            v.PerFrame[i].AnchorsX = PerFrame[i - n]
                        end
                        NowKeyFrame = NextKeyFrame
                    end
                end
            end

            --AnchorsY
            NowKeyFrame = 0
            for i = 1, #v.KeyFrame do
                if v.KeyFrame[i].AnchorsY then
                    NowKeyFrame = i
                    NextKeyFrame = i
                    break
                end
            end
            if NowKeyFrame ~= 0 then
                while next(v.KeyFrame, NextKeyFrame) do
                    local _, temp = next(v.KeyFrame, NextKeyFrame)
                    NextKeyFrame = next(v.KeyFrame, NextKeyFrame)
                    if temp.AnchorsY then
                        local n = v.KeyFrame[NowKeyFrame].Frame
                        local Count = v.KeyFrame[NextKeyFrame].Frame - v.KeyFrame[NowKeyFrame].Frame
                        local PerFrame =
                            DataModule:Interpolation(
                            v.KeyFrame[NowKeyFrame].AnchorsY,
                            v.KeyFrame[NowKeyFrame].Type,
                            v.KeyFrame[NextKeyFrame].AnchorsY,
                            v.KeyFrame[NextKeyFrame].Type,
                            Count
                        )
                        for i = n + 1, n + Count do
                            if v.PerFrame[i] == nil then
                                v.PerFrame[i] = {}
                            end
                            v.PerFrame[i].AnchorsY = PerFrame[i - n]
                        end
                        NowKeyFrame = NextKeyFrame
                    end
                end
            end

            --Angle
            NowKeyFrame = 0
            for i = 1, #v.KeyFrame do
                if v.KeyFrame[i].Angle then
                    NowKeyFrame = i
                    NextKeyFrame = i
                    break
                end
            end
            if NowKeyFrame ~= 0 then
                while next(v.KeyFrame, NextKeyFrame) do
                    local _, temp = next(v.KeyFrame, NextKeyFrame)
                    NextKeyFrame = next(v.KeyFrame, NextKeyFrame)
                    if temp.Angle then
                        local n = v.KeyFrame[NowKeyFrame].Frame
                        local Count = v.KeyFrame[NextKeyFrame].Frame - v.KeyFrame[NowKeyFrame].Frame
                        local PerFrame =
                            DataModule:Interpolation(
                            v.KeyFrame[NowKeyFrame].Angle,
                            v.KeyFrame[NowKeyFrame].Type,
                            v.KeyFrame[NextKeyFrame].Angle,
                            v.KeyFrame[NextKeyFrame].Type,
                            Count
                        )
                        for i = n + 1, n + Count do
                            if v.PerFrame[i] == nil then
                                v.PerFrame[i] = {}
                            end
                            v.PerFrame[i].Angle = PerFrame[i - n]
                        end
                        NowKeyFrame = NextKeyFrame
                    end
                end
            end
        end
    end
    return true
end

function DataModule:Interpolation(_ParaOne, _TypeOne, _ParaTwo, _TypeTwo, _Count)
    local Result = {}
    if _TypeOne == 'Linear' and _TypeTwo == 'Linear' then
        for i = 1, _Count do
            local Frame = _ParaOne * (_Count - i) / _Count + _ParaTwo * i / _Count
            table.insert(Result, Frame)
        end
    end
    return Result
end

return DataModule
