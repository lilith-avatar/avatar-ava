--- @module ReconnectGUI 客户端离线后的重连UI
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local ReconnectGUI, this = ModuleUtil.New('ReconnectGUI', ClientBase)

---重连的加载省略号变化时间
local pointTime = 0.5

--- 初始化
function ReconnectGUI:Init()
    self.root = world:CreateInstance('ReconnectGUI', 'ReconnectGUI', localPlayer.Local)
    self.root.Order = 930
    self.root:SetActive(false)
    self.waitTime = pointTime
    self.enable = false
    self.quitPnl = self.root.Quit
    self.rcImg = self.root.ReconnectImg
    self.quitPnl:SetActive(false)
    self.reconnectingTxt = self.root.ReconnectingTxt
    self.rcTxt = {}
    for i = 1, 6 do
        self.rcTxt[i] = self.rcTxt[i - 1] and self.rcTxt[i - 1] .. '.' or 'Reconnecting'
    end
    self.curIndex = 1

    self.quitBtn = ButtonBase:new(self.quitPnl.OKBtn, UIBase.AniTypeEnum.Scale)
    self.quitBtn:BindHandler('OnClick', self.QuitGame)
end

--- Update函数
--- @param _dt number delta time 每帧时间
function ReconnectGUI:Update(_dt, _tt)
end

--- FixUpdate函数
--- @param _dt number delta time 每帧时间
function ReconnectGUI:FixUpdate(_dt)
    if not self.enable then
        return
    end
    self.rcImg.Angle = self.rcImg.Angle + 10
    self.waitTime = self.waitTime - _dt
    if self.waitTime <= 0 then
        ---换下一个文字
        self.curIndex = self.curIndex + 1
        local str = self.rcTxt[self.curIndex]
        if not str then
            self.curIndex = 1
            str = self.rcTxt[self.curIndex]
        end
        self.reconnectingTxt.Text = str
        self.waitTime = pointTime
    end
end

--- 玩家断线
function ReconnectGUI:OnPlayerDisconnectEventHandler()
    self.enable = true
    self.root:SetActive(true)
    self.waitTime = pointTime
end

---玩家重连
function ReconnectGUI:OnPlayerReconnectEventHandler()
    self.enable = false
    self.root:SetActive(false)
    self.waitTime = pointTime
end

--- 玩家离开游戏
--- 第一种情况是客户端在运行,但是断网一定时间后
--- 第二种情况是自己切后台一定时间在切回来,服务端判定断线并发送消息,切回来后收到消息,执行退出逻辑
function ReconnectGUI:OnPlayerLeaveEventHandler()
    Client:Stop()
    self.root:SetActive(true)
    self.quitPnl:SetActive(true)
    invoke(
        function()
            wait(3)
            print('自动退出')
            Game.Quit()
        end
    )
end

--- 玩家点击按钮
function ReconnectGUI.QuitGame()
    Game.Quit()
end

return ReconnectGUI
