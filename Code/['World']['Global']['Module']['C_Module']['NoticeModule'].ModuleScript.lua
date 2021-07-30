--- @module Notice 界面上的提示信息控制模块
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma, An Dai, RopzTao
local Notice, this = ModuleUtil.New('Notice', ClientBase)

---初始化
function Notice:Init()
    self.root = world:CreateInstance('NoticeGUI', 'NoticeGUI', localPlayer.Local)
    self.root:SetActive(true)
    self.isShow = false
    self.message = {}
    self.config = Config.Message
    self.root.Order = 900
    self.msgCD = Config.GlobalConfig.NoticeMsgCD
    self.msgTime = Config.GlobalConfig.NoticeMsgTime
    ---提示信息展示的CD时间列表
    self.showCDList = {}

    self.popMsgUI = world:CreateInstance('PopMsg', 'PopMsg', self.root)
    self.popMsgUI.Size = Vector2(800, 40)
    self.popMsgUI.AnchorsY = Vector2(0.7, 0.7)
    self.popMsgUI.RaycastTarget = false
    self.popMsgUI.EnableCutting = false
    self.popMsgUI:SetActive(false)

    ---暂时创建10个UI用来显示积分
    self.scoreMsgUIList = {}
    for i = 1, 10 do
        local ui = world:CreateInstance('ScoreMsg', 'ScoreMsg', self.root)
        self.scoreMsgUIList[i] = ui
        ui.Size = Vector2(200, 40)
        ui.Offset = Vector2(-400, -200)
        ui.RaycastTarget = false
        ui.EnableCutting = false
        ui:SetActive(false)
    end
end

function Notice:Update(_dt)
    for i, v in pairs(self.showCDList) do
        self.showCDList[i] = v - _dt
        if v - _dt <= 0 then
            self.showCDList[i] = nil
        end
    end
end

---消息事件监听
---@param _msgID number 提示消息的ID
function Notice:NoticeEventHandler(_msgID)
    if self.showCDList[_msgID] then
        ---相同信息展示CD中
        return
    end
    self.showCDList[_msgID] = self.msgCD
    local msg = self.config[_msgID].Content
    self.popMsgUI.Content.Text = msg
    self.popMsgUI:SetActive(true)
    NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'PopMsg', false)
end

---积分变化监听
function Notice:ScoreChange(_score)
    local ui = self.scoreMsgUIList[1]
    for k, v in pairs(self.scoreMsgUIList) do
        if not v.ActiveSelf then
            ui = v
        end
    end
    ui.ScoreMsg.Content.Text = '+ ' .. tostring(_score)
    NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'ScoreMsg', false, {ui.ScoreMsg})
    ui:SetActive(true)
end

function Notice:AnimationStateEventHandler(_dataName, _state, _uiList)
    if _state == 'Complete' and _dataName == 'PopMsg' then
        self.popMsgUI:SetActive(false)
    end
    if _state == 'Complete' and _dataName == 'ScoreMsg' and _uiList then
        for i, v in pairs(_uiList) do
            v:SetActive(false)
        end
    end
end

return Notice
