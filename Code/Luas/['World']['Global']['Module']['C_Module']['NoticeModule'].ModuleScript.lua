---@module Notice
local Notice = {}

---初始化
function Notice:Init()
    self.root = localPlayer.Local.NoticeGui
    self.isShow = false
    self.message = {}
    self:InitListeners()
    self.config = PlayerCsv.Message
end

---注册监听事件
function Notice:InitListeners()
    EventUtil.LinkConnects(localPlayer.C_Event, Notice, 'Notice', self)
end

---按队列显示消息
function Notice:Show()
    if self.isShow == true then
        return
    end
    invoke(function()
        self.root.Visible = true
        self.isShow = true
        for k, v in pairs(self.message) do
            self.root.BackgroundImg.NoticeTxt.Text = v
            table.remove(self.message, k)
            wait(2)
        end
        self.root.Visible = false
        self.isShow = false
    end, 0)
end

---消息事件监听
---@param _msgID number 提示消息的ID
function Notice:NoticeEventHandler(_msgID)
    local msg = self.config[_msgID].Content
    table.insert(self.message, msg)
    self:Show()
end

return Notice