--- @module OccupyModeUI 占点模式的UI控制模块
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local OccupyModeUI, this = ModuleUtil.New('OccupyModeUI', ClientBase)

local progressStart, progressEnd = 0, 4
local selfColor = Color(71, 81, 224, 180)
local enemyColor = Color(255, 0, 0, 150)
local deathColor = Color(120, 120, 120, 255)
local pairsByKeys = pairsByKeys

--- 初始化
function OccupyModeUI:Init()
    self.root = world:CreateInstance('PointScoringPanel', 'PointScoringPanel', localPlayer.Local)
    self.root.Order = 600
    self.pointsUIList = {}
    self.pointsMoveUIList = {}
    self.maxGrade = 0
    self.pointsObjList = {}

    self.selfTeamGrade = self.root.Background.BlueFigure.Grade
    self.enemyTeamGrade = self.root.Background.RedFigure.Grade
    self.selfGradeFill = self.root.Background.BlueFigure.BG.Blue
    self.enemyGradeFill = self.root.Background.RedFigure.BG.Red

    self.root:SetActive(false)
    self.enable = false
end

--- 占点模式开始
function OccupyModeUI:Start(_mode, _sceneId, _pointsList, _sceneObj)
    if _mode ~= Const.GameModeEnum.OccupyMode then
        return
    end
    self:ConfigInit(_sceneId)
    self:CreateHangPointUI1(_pointsList)
    self:CreateHangPointUI2(_pointsList)
    self:SetStartValue(_pointsList, _sceneObj)
end

function OccupyModeUI:SetStartValue(_pointsList, _sceneObj)
    local selfTeam = localPlayer.PlayerType.Value
    NotReplicate(
        function()
            for i, v in pairs(_pointsList) do
                if selfTeam == Const.TeamEnum.Team_A then
                    v.Flag.Progress.ProgressTeamA.Color = selfColor
                    v.Flag.Progress.ProgressTeamB.Color = enemyColor
                elseif selfTeam == Const.TeamEnum.Team_B then
                    v.Flag.Progress.ProgressTeamA.Color = enemyColor
                    v.Flag.Progress.ProgressTeamB.Color = selfColor
                end
            end
            if localPlayer.PlayerType.Value == Const.TeamEnum.Team_A then
                _sceneObj.Team_B_Boundary.Boundary.Cube.Color = enemyColor
                _sceneObj.Team_A_Boundary.Boundary.Cube.Color = selfColor
            elseif localPlayer.PlayerType.Value == Const.TeamEnum.Team_B then
                _sceneObj.Team_B_Boundary.Boundary.Cube.Color = selfColor
                _sceneObj.Team_A_Boundary.Boundary.Cube.Color = enemyColor
            end
        end
    )
    self.pointsObjList = _pointsList
    self.selfTeamGrade.Text = '0'
    self.enemyTeamGrade.Text = '0'
    self.selfGradeFill.FillAmount = 0
    self.enemyGradeFill.FillAmount = 0
    self.root:SetActive(true)
    self.enable = true
    BottomGUI:SetActive(true)
    BattleGUI:SetActive(true)
end

---创建静态UI上的占点UI
function OccupyModeUI:CreateHangPointUI1(_pointsList)
    local pointsNum = table.nums(_pointsList)
    local startX = 0.5 - (pointsNum - 1) * 0.075
    local function sortFunc(a, b)
        if tostring(a) < tostring(b) then
            return true
        end
    end
    for i, v in pairsByKeys(_pointsList, sortFunc) do
        local ui = world:CreateInstance('OccupyCircle', 'OccupyCircle', self.root.Background.PointInfo)
        ui.AnchorsX = Vector2(startX, startX)
        ui.NameTxt.Text = i
        self.pointsUIList[i] = ui
        startX = startX + 0.15
    end
end

---创建动态UI
function OccupyModeUI:CreateHangPointUI2(_pointsList)
    for i, v in pairs(_pointsList) do
        local moveUi = IndicatorUI:CreateUI('OccupyCircleMove', v, Vector3.Up * 3)
        moveUi.AnchorsX = Vector2.Zero
        moveUi.AnchorsY = Vector2.Zero
        moveUi.NameTxt.Text = i
        self.pointsMoveUIList[i] = moveUi
    end
end

---占点的配置读取
function OccupyModeUI:ConfigInit(_sceneId)
    self.modeParams = Config.Scenes[_sceneId].ModeParams
    self.maxGrade = self.modeParams.MaxGrade
end

function OccupyModeUI:Reset()
    for i, v in pairs(self.pointsUIList) do
        if not v:IsNull() then
            v:Destroy()
        end
    end
    self.pointsUIList = {}
    for i, v in pairs(self.pointsMoveUIList) do
        if not v:IsNull() then
            v:Destroy()
        end
    end
    self.pointsMoveUIList = {}
end

--- Update函数
--- @param dt number delta time 每帧时间
function OccupyModeUI:Update(dt, tt)
    if not self.enable then
        return
    end
end

--- FixUpdate函数
--- @param dt number delta time 每帧时间
function OccupyModeUI:FixUpdate(dt, tt)
    if not self.enable then
        return
    end
    self:UpdateProgress()
end

---站点进度更新在UI上
function OccupyModeUI:UpdateProgress()
    local selfType = localPlayer.PlayerType.Value
    for i, v in pairs(self.pointsObjList) do
        local teamA_Y = v.Flag.Progress.ProgressTeamA.LocalPosition.Y
        local teamB_Y = v.Flag.Progress.ProgressTeamB.LocalPosition.Y
        local progressUI1 = self.pointsMoveUIList[i].Progress
        local progressUI2 = self.pointsUIList[i].Progress
        if teamA_Y <= progressStart and teamB_Y <= progressStart then
            ---这个点两方都没进入过
            progressUI1.FillAmount = 0
            progressUI2.FillAmount = 0
        elseif teamA_Y <= progressStart and teamB_Y > progressStart then
            ---这个点B阵营在占领中
            progressUI1.FillAmount = teamB_Y / progressEnd
            progressUI2.FillAmount = teamB_Y / progressEnd
            if selfType == Const.TeamEnum.Team_A then
                progressUI1.Color = enemyColor
                progressUI2.Color = enemyColor
            elseif selfType == Const.TeamEnum.Team_B then
                progressUI1.Color = selfColor
                progressUI2.Color = selfColor
            end
        elseif teamA_Y > progressStart and teamB_Y <= progressStart then
            ---这个点A阵营在占领中
            progressUI1.FillAmount = teamA_Y / progressEnd
            progressUI2.FillAmount = teamA_Y / progressEnd
            if selfType == Const.TeamEnum.Team_A then
                progressUI1.Color = selfColor
                progressUI2.Color = selfColor
            elseif selfType == Const.TeamEnum.Team_B then
                progressUI1.Color = enemyColor
                progressUI2.Color = enemyColor
            end
        end
    end
end

---点被占领的事件
function OccupyModeUI:PointBeOccupiedEventHandler(_pointKey, _team)
    if not self.enable then
        return
    end
    local ui = self.pointsUIList[_pointKey]
    local ui1 = self.pointsMoveUIList[_pointKey]
    if _team == localPlayer.PlayerType.Value then
        ui.Blue:SetActive(true)
        ui.Red:SetActive(false)
        ui1.Blue:SetActive(true)
        ui1.Red:SetActive(false)
    elseif _team ~= Const.TeamEnum.None then
        ui.Blue:SetActive(false)
        ui.Red:SetActive(true)
        ui1.Blue:SetActive(true)
        ui1.Red:SetActive(false)
    else
        ui.Blue:SetActive(false)
        ui.Red:SetActive(false)
        ui1.Blue:SetActive(true)
        ui1.Red:SetActive(false)
    end
end

---双方分数变动事件
function OccupyModeUI:GradeChangeEventHandler(_team, _grade)
    if not self.enable then
        return
    end
    if _team == localPlayer.PlayerType.Value then
        self.selfTeamGrade.Text = _grade
        self.selfGradeFill.FillAmount = _grade / self.maxGrade
    else
        self.enemyTeamGrade.Text = _grade
        self.enemyGradeFill.FillAmount = _grade / self.maxGrade
    end
end

function OccupyModeUI:GameOverEventHandler(_info)
    self.enable = false
    self.root:SetActive(false)
end

return OccupyModeUI
