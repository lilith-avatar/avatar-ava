--- @module DeathmatchModeUI 死斗模式玩家端控制模块
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local DeathmatchModeUI, this = ModuleUtil.New('DeathmatchModeUI', ClientBase)

--- 初始化
function DeathmatchModeUI:Init()
    self.root = world:CreateInstance('DeathmatchGUI', 'DeathmatchGUI', localPlayer.Local)
    self.root.Order = 600
    self.root:SetActive(false)

    self.blueKillTxt = self.root.ImgBG.BlueKill
    self.redKillTxt = self.root.ImgBG.RedKill
    self.maxKillTxt = self.root.ImgBG.MaxKillNum
    self.mostKill_Blue = self.root.ImgBG.MostkillBlue
    self.mostKill_Red = self.root.ImgBG.MostkillRed

    self.maxKillNum = 0
    self.enable = false
end

--- Update函数
--- @param dt number delta time 每帧时间
function DeathmatchModeUI:Update(dt, tt)
    if not self.enable then
        return
    end
end

---死斗模式开始
function DeathmatchModeUI:Start(_mode, _sceneId, _pointsList, _sceneObj)
    if _mode ~= Const.GameModeEnum.DeathmatchMode then
        return
    end
    self:ConfigInit(_sceneId)
    self:SetStartValue()
end

---默认数据设置
function DeathmatchModeUI:SetStartValue()
    self.blueKillTxt.Text = '0'
    self.redKillTxt.Text = '0'
    self.mostKill_Blue.TxtName.Text = ''
    self.mostKill_Red.TxtName.Text = ''
    self.maxKillTxt.Text = tostring(self.maxKillNum)
    self.enable = true
    self.root:SetActive(true)
    BottomGUI:SetActive(true)
    BattleGUI:SetActive(true)
end

---配置读取
function DeathmatchModeUI:ConfigInit(_sceneId)
    self.modeParams = Config.Scenes[_sceneId].ModeParams
    self.maxKillNum = self.modeParams.MaxKillNum
    self.killAdd = self.modeParams.KillAdd
end

function DeathmatchModeUI:Reset()
end

function DeathmatchModeUI:GameOverEventHandler(_info)
    self.enable = false
    self.root:SetActive(false)
end

---双方玩家击杀数更新
---@param _team number 变动的一方
---@param _killNum number 新的击杀数
function DeathmatchModeUI:TeamKillNumChangeEventHandler(_team, _killNum)
    if _team == localPlayer.PlayerType.Value then
        self.blueKillTxt.Text = tostring(_killNum)
    else
        self.redKillTxt.Text = tostring(_killNum)
    end
end

function DeathmatchModeUI:Show()
    self.root:SetActive(true)
end

function DeathmatchModeUI:Hide()
    self.root:SetActive(false)
end

---击杀排行榜变化事件
function DeathmatchModeUI:KillRankChangeEventHandler(_rank)
    local teamA_mvp, teamB_mvp
    local teamA_max, teamB_max = -1, -1
    for i, v in pairs(_rank) do
        if i.PlayerType.Value == Const.TeamEnum.Team_A then
            if v > teamA_max and v > 0 then
                teamA_max = v
                teamA_mvp = i
            end
        elseif i.PlayerType.Value == Const.TeamEnum.Team_B then
            if v > teamB_max and v > 0 then
                teamB_max = v
                teamB_mvp = i
            end
        end
    end
    if localPlayer.PlayerType.Value == Const.TeamEnum.Team_A then
        if teamA_mvp then
            self.mostKill_Blue.TxtName.Text = splitString(teamA_mvp.Name, Config.GlobalConfig.NameLengthShow)
        end
        if teamB_mvp then
            self.mostKill_Red.TxtName.Text = splitString(teamB_mvp.Name, Config.GlobalConfig.NameLengthShow)
        end
    else
        if teamB_mvp then
            self.mostKill_Blue.TxtName.Text = splitString(teamB_mvp.Name, Config.GlobalConfig.NameLengthShow)
        end
        if teamA_mvp then
            self.mostKill_Red.TxtName.Text = splitString(teamA_mvp.Name, Config.GlobalConfig.NameLengthShow)
        end
    end
end

return DeathmatchModeUI
