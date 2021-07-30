--- 均衡画面质量的逻辑
--- @module QualityBalance
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local QualityBalance = {}

---帧率更新时间间隔
local updateFrameDelay = 0.2
---逻辑帧缓存队列长度
local logicListLength = 50
---渲染帧缓存队列长度
local renderListLength = 50
---画质枚举
QualityBalance.QualityEnum = {
    Low = 1,
    Middle = 2,
    High = 3
}

--- 初始化
function QualityBalance.Init()
	--在world创建FrameGUI节点，并设置父节点为localPlayer.Local
    QualityBalance.root = world:CreateInstance('FrameGUI', 'FrameGUI', localPlayer.Local)
    QualityBalance.logicFrameTxt = QualityBalance.root.LogicFrame
    QualityBalance.renderFrameTxt = QualityBalance.root.RenderFrame
    QualityBalance.curQualityTxt = QualityBalance.root.CurQuality
    QualityBalance.m_logicDelay = updateFrameDelay
    QualityBalance.m_renderDelay = updateFrameDelay
    updateFrameDelay = Config.GlobalConfig.FrameUpdateDelay
    logicListLength = Config.GlobalConfig.LogicListLength
    renderListLength = Config.GlobalConfig.RenderListLength
    ---画质帧率阈值
    QualityBalance.QualityFrame = Config.GlobalConfig.QualityFrame
    ---默认画质帧率
    QualityBalance.FrameMax = Enum.FPSQuality[Config.GlobalConfig.DefaultFPS]
    ---逻辑帧帧率缓存队列
    QualityBalance.logicFrameList = {}
    ---渲染帧帧率缓存队列
    QualityBalance.renderFrameList = {}
    QualityBalance.update = false
    ---默认设置编辑器中画质,即45帧上限
    QualityBalance.FPSQuality = Enum.FPSQuality.Middle
    ---当前工具检测出的画质,默认为高画质
    QualityBalance.curQuality = QualityBalance.QualityEnum.High
    ---逻辑帧缓存队列中帧数总和
    QualityBalance.logicListSum = 0
    ---渲染帧缓存队列中帧数总和
    QualityBalance.renderListSum = 0
    ---渲染帧队列中平均帧率
    QualityBalance.renderAverageFrame = 60
    InitEvent()
    SetQuality()
    if not FrameworkConfig.DebugMode then
        ---调试模式未打开
        QualityBalance.root:SetActive(false)
    end
end

--- Update函数
--- @param _dt number delta time 每帧时间
function QualityBalance.Update(_dt)
    QualityBalance.m_logicDelay = QualityBalance.m_logicDelay - _dt
    if QualityBalance.m_logicDelay <= 0 then
        local frame = keepDecimal(1 / _dt, 2)
        QualityBalance.logicFrameTxt.Text = tostring(frame)
        QualityBalance.m_logicDelay = updateFrameDelay
        table.insert(QualityBalance.logicFrameList, frame)
        if #QualityBalance.logicFrameList > logicListLength then
            table.remove(QualityBalance.logicFrameList, 1)
        end
    end
end

--- FixUpdate函数
--- @param _dt number delta time 每帧时间
function QualityBalance.FixUpdate(_dt)
    QualityBalance.m_renderDelay = QualityBalance.m_renderDelay - _dt
    if QualityBalance.m_renderDelay <= 0 then
        local frame = keepDecimal(1 / _dt, 2)
        QualityBalance.renderFrameTxt.Text = tostring(frame)
        QualityBalance.curQualityTxt.Text = tostring(QualityBalance.curQuality)
        QualityBalance.m_renderDelay = updateFrameDelay
        table.insert(QualityBalance.renderFrameList, frame)
        QualityBalance.renderListSum = QualityBalance.renderListSum + frame
        local removedFrame = RemoveJag(QualityBalance.renderFrameList)
        if removedFrame then
            ---有锯齿
            QualityBalance.renderListSum = QualityBalance.renderListSum - removedFrame
        end
        if #QualityBalance.renderFrameList > renderListLength then
            ---已经满了
            QualityBalance.renderListSum = QualityBalance.renderListSum - QualityBalance.renderFrameList[1]
            table.remove(QualityBalance.renderFrameList, 1)
            ---更新渲染帧平均帧率
            local curAverageFrame = QualityBalance.renderListSum / renderListLength
            local curQuality = CheckFPS(curAverageFrame)
            if curQuality ~= CheckFPS(QualityBalance.renderAverageFrame) and QualityBalance.renderAverageFrame ~= 0 then
                ---print('平均帧率发生较大变化', curAverageFrame, QualityBalance.renderAverageFrame)
                QualityChange(QualityBalance.curQuality, CheckFPS(curAverageFrame))
            end
            QualityBalance.curQuality = curQuality
            QualityBalance.renderAverageFrame = curAverageFrame
        end
    end
end

function QualityBalance.StartUpdate()
    if QualityBalance.update then
        return
    end
    world.OnRenderStepped:Connect(QualityBalance.FixUpdate)
    invoke(
        function()
            while true do
                if not QualityBalance.update then
                    return
                end
                local dt = wait()
                QualityBalance.Update(dt)
            end
        end
    )
    QualityBalance.update = true
end

function QualityBalance.StopUpdate()
    world.OnRenderStepped:Disconnect(QualityBalance.FixUpdate)
    QualityBalance.update = false
end

---初始化事件
function InitEvent()
    QualityBalance.event_qualityChange = world:CreateObject('CustomEvent', 'QualityChangeEvent', localPlayer.C_Event)
end

---设置画质上限
function SetQuality()
    if world:GetDevicePlatform() ~= Enum.Platform.Windows then
        Game.SetFPSQuality(QualityBalance.FPSQuality)
    end
end

---画质更换
---@param _old number 旧的画质
---@param _new number 新的画质
function QualityChange(_old, _new)
    ---print('新的画质', _new)
    QualityBalance.event_qualityChange:Fire(_new)
    PlayerGunMgr:QualityChange(_new)
    if _old > _new then
    ---画质降低了
    --NetUtil.Fire_C('NoticeEvent', localPlayer, 2000)
    end
end

---检测当前平均帧率
function CheckFPS(_frame)
    if _frame > QualityBalance.QualityFrame.Middle2High then
        return QualityBalance.QualityEnum.High
    elseif _frame <= QualityBalance.QualityFrame.Middle2High and _frame > QualityBalance.QualityFrame.Low2Middle then
        return QualityBalance.QualityEnum.Middle
    else
        return QualityBalance.QualityEnum.Low
    end
end

---剔除低谷/高峰锯齿,若执行剔除,则为倒数第二
function RemoveJag(_list)
    local count = #_list
    if count < 3 then
        ---帧率队列长度小于3
        return
    end
    ---倒数第一帧的帧率
    local lastOne = _list[count]
    ---倒数第二帧的帧率
    local secondLast = _list[count - 1]
    ---倒数第三帧的帧率
    local thirdLast = _list[count - 2]
    if CheckFPS(lastOne) == CheckFPS(thirdLast) and CheckFPS(secondLast) ~= CheckFPS(thirdLast) then
        ---倒数第二帧出现突变,移除此帧数据
        table.remove(_list, count - 1)
        return secondLast
    end
end

return QualityBalance
