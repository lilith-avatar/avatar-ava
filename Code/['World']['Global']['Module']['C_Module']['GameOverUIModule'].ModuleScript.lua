--- @module GameOverUI 游戏结束的UI控制
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local GameOverUI, this = ModuleUtil.New('GameOverUI', ClientBase)

local StateEnum = {
    None = -1, ---未展示
    GameResult = 1, ---展示比赛结果
    MVPShow = 2, ---展示最强的几个人
    InfoShow = 3 ---展示最终的队伍详细信息
}
local gameResultTime = 5
local showMVPTime = 5
local infoShowTime = 15
local mineImgColor = Color(255, 128, 0, 255)
local mineTxtColor = Color(255, 255, 255, 255)
local winTxt = 'VICTORY'
local loseTxt = 'DEFEAT'

--- 初始化
function GameOverUI:Init()
    self.root = world:CreateInstance('GameOverUI', 'GameOverUI', localPlayer.Local)
    self.root:SetActive(false)
    self.root.GameResult:SetActive(false)
    self.root.GameInfo:SetActive(false)
    self.root.Order = 850

    self.cam = world:CreateObject('Camera', 'GameOverCam', localPlayer.Local.Independent)
    self.cam.CameraMode = Enum.CameraMode.Custom
    self.gameCam = nil

    self.winImg = self.root.GameResult.WinPnl
    self.loseImg = self.root.GameResult.LosePnl
    self.txtWin_Lose = self.root.GameInfo.ImgBG.TxtWin_Lose

    self.redPnl = self.root.GameInfo.ImgBG.ImgBG2.RedPnl
    self.bluePnl = self.root.GameInfo.ImgBG.ImgBG2.BluePnl
    self.blueKillTxt = self.root.GameInfo.ImgBG.ImgBG2.TxtBlueScore
    self.redKillTxt = self.root.GameInfo.ImgBG.ImgBG2.TxtRedScore

    self.returnBtn = ButtonBase:new(self.root.GameInfo.ImgBG.BtnBack, UIBase.AniTypeEnum.Scale)

    self.celebrationAni = Config.GlobalConfig.CelebrationAni
    self.returnWaitTime = Config.GlobalConfig.GameOverWaitTime
    self.enable = false
    self.m_state = StateEnum.None
    self.m_curStateLeftTime = 0
    self.m_playersInfoUI_blue = {}
    self.m_playersInfoUI_red = {}

    self.returnBtn:BindHandler('OnClick', self.ReturnHallBtnClick)
    self.returnBtn:SetSound('OnClick', 109)
end

---展示游戏结束界面
---@param _info table 要展示的信息表
function GameOverUI:Show(_info, _mvpPlayers)
    self.enable = true
    local winTeam = _info.WinTeam
    --- Player Kill Death Score
    local teamAInfo = _info.PlayersInfo[Const.TeamEnum.Team_A]
    local teamBInfo = _info.PlayersInfo[Const.TeamEnum.Team_B]

    self:CreatePlayersInfo(teamAInfo, teamBInfo, _mvpPlayers)
    if localPlayer.PlayerType.Value == winTeam then
        local uiList = {
            self.winImg.ImgWinRight,
            self.winImg.ImgWinLeft,
            self.winImg.ImgWin.ImgWin1,
            self.winImg.ImgWin.ImgWin2,
            self.winImg.TxtWin_Lose1,
            self.winImg.TxtWin_Lose2
        }
        self.winImg:SetActive(true)
        self.loseImg:SetActive(false)
        self.txtWin_Lose.Text = winTxt
        NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'GameResult', false, uiList)
    else
        local uiList = {
            self.loseImg.ImgLoseRight,
            self.loseImg.ImgLoseLeft,
            self.loseImg.ImgLose.ImgLose1,
            self.loseImg.ImgLose.ImgLose2,
            self.loseImg.TxtWin_Lose1,
            self.loseImg.TxtWin_Lose2
        }
        self.winImg:SetActive(false)
        self.loseImg:SetActive(true)
        self.txtWin_Lose.Text = loseTxt
        NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'GameResult', false, uiList)
    end
    self.root:SetActive(true)
    self.root.GameResult:SetActive(true)
    self.m_state = StateEnum.GameResult
    self.m_curStateLeftTime = gameResultTime
    BottomGUI:SetActive(false)
    BattleGUI:SetActive(false)
    if PlayerGunMgr.curGun then
        PlayerGunMgr.curGun.m_gui:SetVisible(false)
    end
end

---在界面上创建玩家的信息列表
function GameOverUI:CreatePlayersInfo(_teamAInfo, _teamBInfo, _mvpPlayers)
    local mvp
    for i, v in pairs(_mvpPlayers) do
        if v.IsMvp then
            mvp = v.Player
        end
    end
    local blue, red
    local blueTotalKill, redTotalKill = 0, 0
    if localPlayer.PlayerType.Value == Const.TeamEnum.Team_A then
        blue, red = _teamAInfo, _teamBInfo
    else
        blue, red = _teamBInfo, _teamAInfo
    end
    print('MVP是', mvp)
    for i, v in pairs(blue) do
        local ui = world:CreateInstance('BlueInfo', 'BlueInfo', self.bluePnl)
        self.m_playersInfoUI_blue[i] = ui
        ui.TxtName.Text = splitString(v.Player.Name, Config.GlobalConfig.NameLengthShow)
        ui.TxtKill.Text = v.Kill
        ui.TxtDeath.Text = v.Death
        ui.TxtScore.Text = v.Score
        ui.AnchorsY = Vector2(1 - i * 0.2, 1.2 - i * 0.2)
        ui.AnchorsX = Vector2(-2, -1)
        if v.Player == mvp then
            ui.IconTitle:SetActive(true)
        end
        blueTotalKill = blueTotalKill + v.Kill
        if v.Player == localPlayer then
            ui.TxtName.Color = mineTxtColor
            ui.TxtDeath.Color = mineTxtColor
            ui.TxtKill.Color = mineTxtColor
            ui.TxtScore.Color = mineTxtColor
            ui.ImgBG.Color = mineImgColor
        end
    end
    for i, v in pairs(red) do
        local ui = world:CreateInstance('RedInfo', 'RedInfo', self.redPnl)
        self.m_playersInfoUI_red[i] = ui
        ui.TxtName.Text = splitString(v.Player.Name, Config.GlobalConfig.NameLengthShow)
        ui.TxtKill.Text = v.Kill
        ui.TxtDeath.Text = v.Death
        ui.TxtScore.Text = v.Score
        ui.AnchorsY = Vector2(1 - i * 0.2, 1.2 - i * 0.2)
        ui.AnchorsX = Vector2(2, 3)
        if v.Player == mvp then
            ui.IconTitle:SetActive(true)
        end
        redTotalKill = redTotalKill + v.Kill
    end

    self.blueKillTxt.Text = tostring(blueTotalKill)
    self.redKillTxt.Text = tostring(redTotalKill)
end

--- Update函数
--- @param dt number delta time 每帧时间
function GameOverUI:Update(dt, tt)
    if not self.enable then
        return
    end
    if self.m_state == StateEnum.None then
        ---未显示
        return
    elseif self.m_state == StateEnum.GameResult then
        ---在展示比赛的结果
        self.m_curStateLeftTime = self.m_curStateLeftTime - dt
        if self.m_curStateLeftTime <= 0 then
            ---状态切换到最佳玩家展示
            self.m_curStateLeftTime = showMVPTime
            self.m_state = StateEnum.MVPShow
            self.root.GameResult:SetActive(false)
            world.CurrentCamera = self.cam
            SoundUtil:PlaySound(115)
            return
        end
    elseif self.m_state == StateEnum.MVPShow then
        ---最佳玩家展示
        self.m_curStateLeftTime = self.m_curStateLeftTime - dt
        if self.m_curStateLeftTime <= 0 then
            ---状态切换到最终的详细信息展示
            self.m_curStateLeftTime = infoShowTime
            self.m_state = StateEnum.InfoShow
            self.root.GameInfo:SetActive(true)
            self:ShowTwoTeamInfo()
            return
        end
    elseif self.m_state == StateEnum.InfoShow then
        ---最终的详细信息展示
        self.m_curStateLeftTime = self.m_curStateLeftTime - dt
        self.returnBtn:SetValue('TxtTime.Text', tostring(math.ceil(self.m_curStateLeftTime)))
        if self.m_curStateLeftTime <= 0 then
            ---倒计时结束,返回大厅
            self.ReturnHallBtnClick()
        end
    end
end

---玩家点击按钮主动返回大厅
function GameOverUI.ReturnHallBtnClick()
    local self = GameOverUI
    SoundUtil:StopSound(115, true)
    self.enable = false
    world.CurrentCamera = self.gameCam
    self.root:SetActive(false)
    self.root.GameResult:SetActive(false)
    self.root.GameInfo:SetActive(false)
    NetUtil.Fire_S('PlayerReturnHallEvent', localPlayer)
    for i, v in pairs(self.m_playersInfoUI_blue) do
        if v.Destroy then
            v:Destroy()
        end
    end
    for i, v in pairs(self.m_playersInfoUI_red) do
        if v.Destroy then
            v:Destroy()
        end
    end
    self.m_playersInfoUI_blue = {}
    self.m_playersInfoUI_red = {}
    PlayerMgr:Reset()
end

function GameOverUI:GameOverEventHandler(_info, _fakeNpcList, _mvpPlayers)
    print('游戏结束')
    self:Show(_info, _mvpPlayers)
    wait()
    NotReplicate(
        function()
            for i, v in pairs(_fakeNpcList) do
                if v:IsNull() then
                    return
                end
                local playerType = _mvpPlayers[i].Player.PlayerType.Value
                if playerType == localPlayer.PlayerType.Value then
                    v.SurfaceGUI.Panel.ImgBlue:SetActive(true)
                    v.SurfaceGUI.Panel.ImgRed:SetActive(false)
                else
                    v.SurfaceGUI.Panel.ImgRed:SetActive(true)
                    v.SurfaceGUI.Panel.ImgBlue:SetActive(false)
                end
                v.NpcAvatar:PlayAnimation(self.celebrationAni[i], 2, 1, 0, true, true, 1)
                if v.PlayerRef.Value and not v.PlayerRef.Value:IsNull() then
                    copyAvatar(v.PlayerRef.Value.Avatar, v.Avatar)
                end
            end
        end
    )
end

function GameOverUI:ShowTwoTeamInfo()
    for i, v in pairs(self.m_playersInfoUI_red) do
        invoke(
            function()
                NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'GameOverShowRed' .. i, false, {v})
            end,
            (i - 1) * 0.2
        )
    end
    for i, v in pairs(self.m_playersInfoUI_blue) do
        invoke(
            function()
                NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'GameOverShowBlue' .. i, false, {v})
            end,
            (i - 1) * 0.2
        )
    end
end

function GameOverUI:GameStartEventHandler(_mode, _sceneId, _pointsList, _sceneObj)
    local sceneConfig = Config.Scenes[_sceneId]
    self.gameOverCamPos = sceneConfig.GameOverCamPos
    self.gameOverCamRot = sceneConfig.GameOverCamRot
    self.cam.Position = self.gameOverCamPos
    self.cam.Rotation = self.gameOverCamRot
    self.winImg.ImgWinRight.AnchorsX = Vector2(1, 2)
    self.winImg.ImgWinLeft.AnchorsX = Vector2(-1, 0)
    self.winImg.ImgWin.ImgWin1.AnchorsY = Vector2(-50, -50)
    self.winImg.ImgWin.ImgWin2.AnchorsY = Vector2(55, 55)
    self.winImg.TxtWin_Lose1.AnchorsY = Vector2(0, 0)
    self.winImg.TxtWin_Lose2.AnchorsY = Vector2(1, 1)

    self.loseImg.ImgLoseRight.AnchorsX = Vector2(1, 2)
    self.loseImg.ImgLoseLeft.AnchorsX = Vector2(-1, 0)
    self.loseImg.ImgLose.ImgLose1.AnchorsY = Vector2(-50, -50)
    self.loseImg.ImgLose.ImgLose2.AnchorsY = Vector2(55, 55)
    self.loseImg.TxtWin_Lose1.AnchorsY = Vector2(0, 0)
    self.loseImg.TxtWin_Lose2.AnchorsY = Vector2(1, 1)

    self.gameCam = world.CurrentCamera
end

return GameOverUI
