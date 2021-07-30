--- 队友的血量UI,敌人的UI(受击后展示),死亡重生的UI
--- @module ShareUI 每个游戏模式都会用的ui控制模块
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local ShareUI, this = ModuleUtil.New('ShareUI', ClientBase)

local selfColor = Color(71, 81, 224, 180)
local enemyColor = Color(255, 0, 0, 150)
local deathColor = Color(120, 120, 120, 255)
local hitShowTime = 2

--- 初始化
function ShareUI:Init()
    self.root = world:CreateInstance('ShareUI', 'ShareUI', localPlayer.Local)
    self.root.Order = 600
    self.selfTeamNum = self.root.Background.BluePeople.Numbers
    self.enemyTeamNum = self.root.Background.RedPeople.Numbers
    self.killNumText = self.root.KillAndDeathPnl.KillNum
    self.deathNumText = self.root.KillAndDeathPnl.DeathNum
    self.timeLeftUI = self.root.Background.TimeLeftTxt
    self.timeFigure = self.root.Background.TimeFigure
    self.continusKill = self.root.ContinusKillPnl.AllContinusKill

    self.enemyHpShowTimeList = {}
    self.teamIconList = {}
    self.peopleFigureList = {}

    self.root:SetActive(false)
    --self.continusKill:SetActive(false)
    self.enable = false

    self.deathCount = 0
    self.killCount = 0
    ---玩家在这个玩法中死亡后的重生时间
    self.reviveWaitTime = {}
    ---玩家死亡本地计数
    self.selfDeathCount = 0
    self.restoreHp = 0
    self.restoreHpMax = 100
    self.pos1_A, self.pos2_A, self.pos1_B, self.pos2_B = Vector3.Zero, Vector3.Zero, Vector3.Zero, Vector3.Zero

    world.OnPlayerRemoved:Connect(
        function(_player)
            self:PlayerRemove(_player)
        end
    )
end

--- Update函数
--- @param dt number delta time 每帧时间
function ShareUI:Update(dt, tt)
    if not self.enable then
        return
    end
    for i, v in pairs(self.enemyHpShowTimeList) do
        if i:IsNull() then
            goto Continue
        end
        self.enemyHpShowTimeList[i] = v - dt
        if self.enemyHpShowTimeList[i] <= 0 then
            self.enemyHpShowTimeList[i] = 0
            self.teamIconList[i]:SetActive(false)
        end
        ::Continue::
    end
end

function ShareUI:GameStartEventHandler(_mode, _sceneId, _pointsList, _sceneObj)
    self:InitConfig(_sceneId)
end

---游戏开始的事件
function ShareUI:Start()
    self:CreateTeamIcon()
    self:SetStartValue()
end

function ShareUI:InitConfig(_sceneId)
    self.maxTime = math.floor(Config.Scenes[_sceneId].MaxTime)
    self.restoreHp = Config.Scenes[_sceneId].KillRestore
    self.restoreHpMax = Config.Scenes[_sceneId].KillRestoreMax
    ---双方死亡复活时间,1为A阵营,2为B阵营
    self.reviveWaitTime = Config.Scenes[_sceneId].ReviveWaitTime
    self.pos1_A = Config.Scenes[_sceneId].BornArea[1][1]
    self.pos2_A = Config.Scenes[_sceneId].BornArea[1][2]
    self.pos1_B = Config.Scenes[_sceneId].BornArea[2][1]
    self.pos2_B = Config.Scenes[_sceneId].BornArea[2][2]
end

function ShareUI:SetStartValue()
    local selfNum, enemyNum = 0, 0
    for i, v in pairs(FindAllPlayers()) do
        if v.PlayerType.Value == localPlayer.PlayerType.Value and v.PlayerType.Value ~= Const.TeamEnum.None then
            selfNum = selfNum + 1
        elseif v.PlayerType.Value ~= localPlayer.PlayerType.Value and v.PlayerType.Value ~= Const.TeamEnum.None then
            enemyNum = enemyNum + 1
        end
    end
    self.selfTeamNum.Text = selfNum
    self.enemyTeamNum.Text = enemyNum
    self.killNumText.Text = '0'
    self.deathNumText.Text = '0'
    --self.timeLeftUI.Text = tostring(self.maxTime)
    self.root:SetActive(true)
    self.root.Background:SetActive(true)
    self.selfDeathCount = 0
    self.deathCount = 0
    self.killCount = 0
    self.enable = true
end

---游戏重置
function ShareUI:Reset()
    for i, v in pairs(self.teamIconList) do
        if not v:IsNull() then
            v:Destroy()
        end
    end
    self.teamIconList = {}
    for i, v in pairs(self.peopleFigureList) do
        if not v:IsNull() then
            v:Destroy()
        end
    end
    self.peopleFigureList = {}
    self.enemyHpShowTimeList = {}
end

---游戏时间更改事件
function ShareUI:GameTimeChangeEventHandler(_time)
    if not self.enable then
    --return
    end
    if not self.maxTime then
        return
    end
    self.timeLeftUI.Text = self.maxTime - _time <= 0 and 0 or self.maxTime - _time
    ReviveUI:RemainTime(self.timeLeftUI.Text)
end

function ShareUI:PlayerRemove(_player)
    if not self.enable then
        return
    end
    if _player.PlayerType.Value == localPlayer.PlayerType.Value then
        local selfNum = tonumber(self.selfTeamNum.Text)
        selfNum = selfNum - 1
        selfNum = selfNum <= 0 and 0 or selfNum
        self.selfTeamNum.Text = selfNum
    else
        local enemyNum = tonumber(self.enemyTeamNum.Text)
        enemyNum = enemyNum - 1
        enemyNum = enemyNum <= 0 and 0 or enemyNum
        self.enemyTeamNum.Text = enemyNum
    end
    if self.teamIconList[_player] and not self.teamIconList[_player]:IsNull() then
        self.teamIconList[_player]:Destroy()
        self.teamIconList[_player] = nil
    end
    if self.peopleFigureList[_player] and not self.peopleFigureList[_player]:IsNull() then
        self.peopleFigureList[_player]:Destroy()
        self.peopleFigureList[_player] = nil
    end
    self.enemyHpShowTimeList[_player] = nil
end

---游戏结束的事件
function ShareUI:GameOverEventHandler(_info)
    self.enable = false
    self.root:SetActive(false)
    self.selfDeathCount = 0
end

---@param _killer PlayerInstance 击杀者
---@param _killed PlayerInstance 被杀的人
---@param _weaponId number 伤害来源的枪械ID
---@param _hitPart number 击杀部位
function ShareUI:PlayerDieEventHandler(_killer, _killed, _weaponId, _hitPart)
    if _killed == localPlayer then
        ---死亡的是自己,则给自己增加死亡计数
        self.deathCount = self.deathCount + 1
        self:OwnDeath(_killer, _weaponId, _hitPart)
    end
    if _killer == localPlayer then
        ---击杀者是自己,则给自己增加杀人数量
        self.killCount = self.killCount + 1
        self:RestoreLife()
    end
    self.killNumText.Text = self.killCount
    self.deathNumText.Text = self.deathCount
end

--成功命中
function ShareUI:SuccessHitCallBack(_infoList)
    local ui = self.teamIconList[_infoList.Player]
    if not ui or ui:IsNull() then
        return
    end
	--显示UI
    ui:SetActive(true)
    self.enemyHpShowTimeList[_infoList.Player] = hitShowTime
	--如果存在伤害值，并且玩家的生命值>0
    if _infoList.Damage and _infoList.Player.Health > 0 then
		--显示击中的UI-伤害值
		--位置 HitWordUIModule
        HitWordUI:Show(_infoList.Damage, _infoList.Player.Avatar.Bone_Head.HangPoint.Position, _infoList.HitPart)
    end
end

---自己死亡的事件
---@param _killer PlayerInstance 击杀者
---@param _weaponId number 伤害来源的枪械ID
---@param _hitPart number 击杀部位
function ShareUI:OwnDeath(_killer, _weaponId, _hitPart)
    self.selfDeathCount = self.selfDeathCount + 1
    local time = 5
    if localPlayer.PlayerType.Value == Const.TeamEnum.Team_A then
        time = self.reviveWaitTime[1][self.selfDeathCount] or self.reviveWaitTime[1][#self.reviveWaitTime[1]]
    elseif localPlayer.PlayerType.Value == Const.TeamEnum.Team_B then
        time = self.reviveWaitTime[2][self.selfDeathCount] or self.reviveWaitTime[2][#self.reviveWaitTime[2]]
    end
    DieCameraMoveMgr:SetTime(time)
    ReviveUI:Show(time, _killer, _weaponId, _hitPart)
    DeathmatchModeUI:Hide()
    self.root.Background:SetActive(false)
    invoke(
        function()
            if self.enable then
                localPlayer.Position = self:RandPos()
                self.root.Background:SetActive(true)
                DeathmatchModeUI:Show()
                wait()
                if localPlayer.Health <= 0 then
                    localPlayer:Reborn()
                end
            end
        end,
        time
    )
end

---在己方的出生区域内随机一个点
---@return Vector3 随机的点
function ShareUI:RandPos()
    local pos1, pos2, x, y, z
    if localPlayer.PlayerType.Value == Const.TeamEnum.Team_A then
        pos1 = self.pos1_A
        pos2 = self.pos2_A
    elseif localPlayer.PlayerType.Value == Const.TeamEnum.Team_B then
        pos1 = self.pos1_B
        pos2 = self.pos2_B
    end
    x = Random_X2Y(pos1.X, pos2.X)
    z = Random_X2Y(pos1.Z, pos2.Z)
    y = self.pos1_A.Y
    return Vector3(x, y, z)
end

---自己击杀敌人后的回血
function ShareUI:RestoreLife()
    if localPlayer.Health <= 0 or localPlayer.Health > 75 then
        return
    end
    localPlayer.Health = localPlayer.Health + self.restoreHp
    localPlayer.Health =
        localPlayer.Health > self.restoreHpMax * 0.01 * localPlayer.MaxHealth and
        self.restoreHpMax * 0.01 * localPlayer.MaxHealth or
        localPlayer.Health
end

---创建队友和敌人头上的图标
function ShareUI:CreateTeamIcon()
    local players = world:FindPlayers()
    ---创建头顶UI
    for i, v in pairs(players) do
        self:CreateHeadIcon(v)
    end
    --[[
    local blueNum, redNum = 0, 0
    for i, v in pairs(players) do
        local figure
        if v.PlayerType and v.PlayerType.Value == localPlayer.PlayerType.Value then
            figure = world:CreateInstance('BluePeopleFigure', 'BluePeopleFigure', self.root.Background.BluePeople)
            figure.AnchorsX = Vector2(blueNum * 0.15 + 0.1, blueNum * 0.15 + 0.1)
            blueNum = blueNum + 1
        elseif v.PlayerType and v.PlayerType.Value ~= localPlayer.PlayerType.Value then
            figure = world:CreateInstance('RedPeopleFigure', 'RedPeopleFigure', self.root.Background.RedPeople)
            figure.AnchorsX = Vector2(0.85 - redNum * 0.15, 0.85 - redNum * 0.15)
            redNum = redNum + 1
        end
        if figure then
            self.peopleFigureList[v] = figure
            local OnHealthChange = function(_old, _new)
                if _old > 0 and _new <= 0 then
                    figure.Death:SetActive(true)
                    figure.Alive:SetActive(false)
                end
                if _old <= 0 and _new >= 0 then
                    figure.Death:SetActive(false)
                    figure.Alive:SetActive(true)
                end
            end
            v.OnHealthChange:Connect(OnHealthChange)
            figure.OnDestroyed:Connect(
                function()
                    if v.OnHealthChange then
                        v.OnHealthChange:Disconnect(OnHealthChange)
                    end
                end
            )
        end
    end]]
end

---NPC创建成功,本地创建NPC头顶UI
function ShareUI:NpcCreateEventHandler(_npcModel, _, _team)
    _npcModel.PlayerType.Value = _team
    self:CreateHeadIcon(_npcModel)
end

---创建一个玩家头顶的UI
---@param _player PlayerInstance 玩家实例
function ShareUI:CreateHeadIcon(_player)
    if not _player.PlayerType or _player == localPlayer then
        return
    end
    local ui = IndicatorUI:CreateUI('HeadName', _player, Vector3.Up * 2)
    ui.Content.Text = splitString(_player.Name, Config.GlobalConfig.NameLengthShow)
    if _player.PlayerType.Value == localPlayer.PlayerType.Value then
        ---己方玩家血条始终显示,并且为己方颜色
        ui:SetActive(true)
        ui.Content.HpFill.Fill.Color = selfColor
        ui.Content.Dir.Color = selfColor
        ui.Dir.Dir.Color = selfColor
        ui.Content.Color = selfColor
        local OnHealthChange = function(_old, _new)
            ui.Content.HpFill.Fill.FillAmount = _new / _player.MaxHealth
            if _old > 0 and _new <= 0 then
                ui.Dir.Dir.Color = deathColor
                ui.Content.Dir.Color = deathColor
            end
            if _old <= 0 and _new >= 0 then
                ui.Dir.Dir.Color = selfColor
                ui.Content.Dir.Color = selfColor
            end
        end
        _player.OnHealthChange:Connect(OnHealthChange)
        ui.OnDestroyed:Connect(
            function()
                if _player.OnHealthChange then
                    _player.OnHealthChange:Disconnect(OnHealthChange)
                end
            end
        )
    else
        ---敌方玩家血条只有在被自己打中后才消失,为红色
        ui:SetActive(false)
        ui.Content.HpFill.Fill.Color = enemyColor
        ui.Content.Dir.Color = enemyColor
        ui.Dir.Dir.Color = enemyColor
        ui.Content.Color = enemyColor
        local OnHealthChange = function(_old, _new)
            ui.Content.HpFill.Fill.FillAmount = _new / _player.MaxHealth
            if _new <= 0 then
                ui:SetActive(false)
            end
        end
        _player.OnHealthChange:Connect(OnHealthChange)
        ui.OnDestroyed:Connect(
            function()
                if _player.OnHealthChange then
                    _player.OnHealthChange:Disconnect(OnHealthChange)
                end
            end
        )
        self.enemyHpShowTimeList[_player] = hitShowTime
    end
    self.teamIconList[_player] = ui
end

---玩家积分变化的事件
function ShareUI:PlayerScoreAddEventHandler(_score)
    ---print('玩家积分增加', _score)
    Notice:ScoreChange(_score)
end

---连杀
---@param _player PlayerInstance 造成连杀的玩家
---@param _num number 连杀数量
function ShareUI:ContinuousKillEventHandler(_player, _num)
    ---print('玩家', _player, '连杀', _num, '人')
    local config = Config.GlobalConfig.ContinuousKill[_num]
    if not config then
        return
    end

    local img = config.Img
    local content = config.Content
    local sound = config.Sound
    self.continusKill.IconKillNum.Texture = ResourceManager.GetTexture('UI/Picture/' .. img)
    self.continusKill.NameTxt.Text = splitString(_player.Name, Config.GlobalConfig.NameLengthShow)
    self.continusKill.KillTxt.Text = content
    --self.continusKill:SetActive(true)
    ---SoundUtil:PlaySound(sound)
    NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'ContinusKill', false)
end

return ShareUI
