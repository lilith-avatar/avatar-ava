local DataModule = {Data = {}}

--初始化函数,读取动画表
function DataModule:Init()
    local InfoTable = world.Global.Csv.UIAnimation
    local RowNum = InfoTable:GetRowNum()
    for i = 1, RowNum do
        local AnimationName = InfoTable:GetCell('AnimationName', i)
        --如果该数据的动画名为新增,则在数据表中新插入一段空的动画数据
        if self.Data[AnimationName] == nil then
            self.Data[AnimationName] = {}
            self.Data[AnimationName].count = InfoTable:GetCell('Count', i)
        end

        --解析UI节点路径,获取UI节点
        local PathStr = InfoTable:GetCell('UINode', i)
        local UiPath = string.split(InfoTable:GetCell('UINode', i), '.')
        local UiNode
        if UiPath[1] == 'Local' then
            UiNode = localPlayer
            for k, v in pairs(UiPath) do
                if UiNode[v] then
                    UiNode = UiNode[v]
                else
                    print('AnimationName = ', AnimationName, 'The Path NotFind:', v, 'in', UiPath)
                    return
                end
            end
        else
            print('暂时不支持Local以外的UI节点动画')
            return
        end

        --判断初始帧,并执行初始帧逻辑
        if InfoTable:GetCell('IsInit', i) == true then
            --记录初始帧
            self.Data[AnimationName][PathStr] = {}
            local NowData = self.Data[AnimationName][PathStr]
            NowData.Obj = UiNode
            NowData.KeyFrame = {}
            NowData.Init = {}
            NowData.PerFrame = {}
            if InfoTable:GetCell('Size', i) ~= Vector2(0, 0) then
                NowData.Init.Size = InfoTable:GetCell('Size', i)
            end
            if InfoTable:GetCell('AnchorsX', i) ~= Vector2(0, 0) then
                NowData.Init.AnchorsX = InfoTable:GetCell('AnchorsX', i)
            end
            if InfoTable:GetCell('AnchorsY', i) ~= Vector2(0, 0) then
                NowData.Init.AnchorsY = InfoTable:GetCell('AnchorsY', i)
            end
            if InfoTable:GetCell('Angle', i) ~= 0 then
                NowData.Init.Angle = InfoTable:GetCell('Angle', i)
            end
            if InfoTable:GetCell('Offset', i) ~= Vector2(0, 0) then
                NowData.Init.Offset = InfoTable:GetCell('Offset', i)
            end
            if InfoTable:GetCell('Alpha', i) ~= 0 then
                NowData.Init.Alpha = InfoTable:GetCell('Alpha', i)
            end
        else
            --配置表初始帧配置校验
            if self.Data[AnimationName][PathStr] == nil then
                print(AnimationName, '未配置初始帧,配表错误')
                return
            end
            local tFrame, tSize, tAnchorsX, tAnchorsY, tAngle, tOffset, tAlpha, tTag
            --记录关键帧数据
            tType = InfoTable:GetCell('Type', i)
            if tType == '' then
                tType = 'Linear'
            end
            if InfoTable:GetCell('KeyFrame', i) ~= Vector2(0, 0) then
                tFrame = InfoTable:GetCell('KeyFrame', i)
            end
            if InfoTable:GetCell('Size', i) ~= Vector2(0, 0) then
                tSize = InfoTable:GetCell('Size', i)
            end
            if InfoTable:GetCell('AnchorsX', i) ~= Vector2(0, 0) then
                tAnchorsX = InfoTable:GetCell('AnchorsX', i)
            end
            if InfoTable:GetCell('AnchorsY', i) ~= Vector2(0, 0) then
                tAnchorsY = InfoTable:GetCell('AnchorsY', i)
            end
            if InfoTable:GetCell('Angle', i) ~= 0 then
                tAngle = InfoTable:GetCell('Angle', i)
            end
            if InfoTable:GetCell('Offset', i) ~= Vector2(0, 0) then
                tOffset = InfoTable:GetCell('Offset', i)
            end
            if InfoTable:GetCell('Alpha', i) ~= 0 then
                tAlpha = InfoTable:GetCell('Alpha', i)
            end
            if InfoTable:GetCell('Tag', i) ~= '' then
                tTag = InfoTable:GetCell('Tag', i)
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
    end
end

function DataModule:Calculate(DataName)
    for k, v in pairs(self.Data[DataName]) do
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
