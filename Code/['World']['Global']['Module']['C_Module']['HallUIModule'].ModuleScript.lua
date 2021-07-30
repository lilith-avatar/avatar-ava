--- @module HallUI 游戏的大厅界面控制逻辑
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma

local HallUI, this = ModuleUtil.New('HallUI', ClientBase)

local startIcon = 'Btn_Hall_Game_Start'
local cancelIcon = 'Btn_Hall_Game_Cancel'

--- 初始化
function HallUI:Init()
    --[[
    self.root = world:CreateInstance('HallGUI', 'HallGUI', localPlayer.Local)
    self.root.Order = 650

    self.startMatchBtn = self.root.StartMatchBtn
    self.startMatchBtn.OnClick:Connect(function()
        self:StartMatchBtnClick()
    end)

    self.matchTimeTxt = self.root.MatchPnl.ImgBG.Time
    self.curNumTxt = self.root.MatchPnl.ImgBG.CurNum
    self.circle = self.root.MatchPnl.ImgBG.ImgLoad

    self.root.MatchPnl:SetActive(false)
    self.isMatching = false
    self.requireNum = Config.GlobalConfig.PlayerNum
    ---匹配已用时间
    self.waitTime = 0
    self.matchTimeTxt.Text = self.waitTime
    self.curNumTxt.Text = '0 / ' .. self.requireNum
    self.second = 1
    self.curNum = 0
    ]]
end

--- Update函数
--- @param dt number delta time 每帧时间
function HallUI:Update(dt, tt)
    --[[
    if self.isMatching and self.curNum < self.requireNum then
        self.second = self.second - dt
        if self.second <= 0 then
            self.second = 1
            SoundUtil:PlaySound(117)
            self.waitTime = self.waitTime + 1
            self.matchTimeTxt.Text = self.waitTime
        end
    end
    --]]
end

function HallUI:FixUpdate(_dt)
    --self.circle.Angle = self.circle.Angle + 8
end

--[[
function HallUI:StartMatchBtnClick()
    ---NetUtil.Fire_C('NoticeEvent', localPlayer, 1001)
    SoundUtil:PlaySound(117)
    if not self.isMatching then
        self.root.MatchPnl:SetActive(true)
        self.isMatching = true
        self.waitTime = 0
        self.matchTimeTxt.Text = self.waitTime
        self.curNumTxt.Text = '0 / ' .. self.requireNum
        self.startMatchBtn.Image = ResourceManager.GetTexture('UI/Button/' .. cancelIcon)
        NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'StartMatch', false)
        NetUtil.Fire_S('PlayerStartMatchEvent', localPlayer)
    else
        self.root.MatchPnl:SetActive(false)
        self.isMatching = false
        self.waitTime = 0
        self.matchTimeTxt.Text = self.waitTime
        self.curNumTxt.Text = '0 / ' .. self.requireNum
        self.startMatchBtn.Image = ResourceManager.GetTexture('UI/Button/' .. startIcon)
        NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'StartMatch', true)
        NetUtil.Fire_S('PlayerStopMatchEvent', localPlayer)
    end
end
]]
---匹配的玩家数量发生变化的事件
function HallUI:MatchPlayerChangeEventHandler(_num)
    --[[
    if _num >= self.requireNum then
        self.root.MatchPnl.ImgSuccess:SetActive(true)
        SoundUtil:PlaySound(118)
    end
    self.curNumTxt.Text = _num .. ' / ' .. self.requireNum
    self.curNum = _num
    ]]
end

function HallUI:GameStartEventHandler()
    --[[
    self.root:SetActive(false)
    self.root.MatchPnl:SetActive(false)
    self.isMatching = false
    self.waitTime = 0
    self.matchTimeTxt.Text = self.waitTime
    self.curNumTxt.Text = '0 / ' .. self.requireNum
    self.root.MatchPnl.ImgSuccess:SetActive(false)
    self.startMatchBtn.Image = ResourceManager.GetTexture('UI/Button/' .. startIcon)
    --]]
end

function HallUI:Show()
    --self.root:SetActive(true)
end

return HallUI
