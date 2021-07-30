--- @module ScoreMgr 游戏中玩家的积分和连杀的管理模块
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local ScoreMgr, this = ModuleUtil.New('ScoreMgr', ServerBase)

--- 初始化
function ScoreMgr:Init()
    ---玩家连杀数量
    self.continuousKillNumList = {}
    ---玩家积分
    self.scoreList = {}
    ---玩家在点中的时间长度
    self.playerInPointTimeList = {}
    ---玩家在点中加分的倒计时
    self.occScoreCDList = {}
    self.m_enable = false
    ---玩家连杀通知数量
    self.continuousKillConfig = Config.GlobalConfig.ContinuousKill

    world.OnPlayerAdded:Connect(
        function(_player)
            self:PlayerAdd(_player)
        end
    )
    world.OnPlayerRemoved:Connect(
        function(_player)
            --self:PlayerRemove(_player)
        end
    )
end

--- Update函数
--- @param dt number delta time 每帧时间
function ScoreMgr:Update(dt, tt)
    if not self.m_enable then
        return
    end
    if GameFlowMgr.curMode == Const.GameModeEnum.OccupyMode then
        for i, v in pairs(OccupyMode.holdPointsList) do
            if v.teamValue[Const.TeamEnum.Team_A] < 100 and v.teamValue[Const.TeamEnum.Team_B] < 100 then
                for i1, v1 in pairs(v.players[Const.TeamEnum.Team_A]) do
                    self.playerInPointTimeList[v1] = self.playerInPointTimeList[v1] + dt
                    self.occScoreCDList[v1] = self.occScoreCDList[v1] - dt
                end
                for i1, v1 in pairs(v.players[Const.TeamEnum.Team_B]) do
                    self.playerInPointTimeList[v1] = self.playerInPointTimeList[v1] + dt
                    self.occScoreCDList[v1] = self.occScoreCDList[v1] - dt
                end
            end
        end
        for i, v in pairs(self.occScoreCDList) do
            if v <= 0 then
                ---这个玩家在点中时间到了指定时长,需要给玩家加分
                self.occScoreCDList[i] = self.captureScore[1]
                self:AddScore(i, self.captureScore[2])
            end
        end
    end
end

---游戏开始,初始化模式的配置
function ScoreMgr:Start(_mode)
    local config = Config.Mode[_mode]
    if not config then
        return
    end
    self.winScore = config.WinScore
    self.killScore = config.KillScore
    self.customParams = config.CustomParams
    if _mode == Const.GameModeEnum.OccupyMode then
        self.captureScore = self.customParams.CaptureScore
        self.attackKillScore = self.customParams.AttackKillScore
        self.protectKillScore = self.customParams.ProtectKillScore
        for i, v in pairs(self.occScoreCDList) do
            self.occScoreCDList[i] = self.captureScore[1]
        end
    elseif _mode == Const.GameModeEnum.BombMode then
        self.setTNT = self.customParams.SetTNT
        self.removeTNT = self.customParams.RemoveTNT
    end
    self.m_enable = true
    for i, v in pairs(self.continuousKillNumList) do
        self.continuousKillNumList[i] = 0
    end
end

---重置游戏数据
function ScoreMgr:Reset()
    for i, v in pairs(self.continuousKillNumList) do
        self.continuousKillNumList[i] = 0
    end
    for i, v in pairs(self.scoreList) do
        self.scoreList[i] = 0
    end
    for i, v in pairs(self.playerInPointTimeList) do
        self.playerInPointTimeList[i] = 0
    end
    for i, v in pairs(self.occScoreCDList) do
        self.occScoreCDList[i] = 0
    end
end

function ScoreMgr:PlayerAdd(_player)
    self.continuousKillNumList[_player] = 0
    self.scoreList[_player] = 0
    self.playerInPointTimeList[_player] = 0
    self.occScoreCDList[_player] = 0
end

function ScoreMgr:OnPlayerLeaveEventHandler(_player)
    self.continuousKillNumList[_player] = nil
    self.scoreList[_player] = nil
    self.playerInPointTimeList[_player] = nil
    self.occScoreCDList[_player] = nil
end

---NPC创建成功事件
function ScoreMgr:NpcCreateEventHandler(_npc)
    self.continuousKillNumList[_npc] = 0
    self.scoreList[_npc] = 0
    self.playerInPointTimeList[_npc] = 0
    self.occScoreCDList[_npc] = 0
end

---NPC销毁事件
function ScoreMgr:NpcDestroyEventHandler(_npc)
    self.continuousKillNumList[_npc] = nil
    self.scoreList[_npc] = nil
    self.playerInPointTimeList[_npc] = nil
    self.occScoreCDList[_npc] = nil
end

---玩家死亡事件
---@param _killer PlayerInstance 击杀者
---@param _killed PlayerInstance 被杀的人
---@param _weaponId number 伤害来源的枪械ID
---@param _hitPart number 击杀部位
function ScoreMgr:PlayerDieEventHandler(_killer, _killed, _weaponId, _hitPart)
    self:CalculateContinuousKill(_killer, _killed)
    if GameFlowMgr.curMode == Const.GameModeEnum.OccupyMode then
        self:OccupyModeKill(_killer)
    end
end

---计算连杀数量并根据连杀数量进行广播和积分的计算
function ScoreMgr:CalculateContinuousKill(_killer, _killed)
    if _killed == _killer then
        return
    end
    self.continuousKillNumList[_killer] = self.continuousKillNumList[_killer] or 0
    self.continuousKillNumList[_killer] = self.continuousKillNumList[_killer] + 1
    self.continuousKillNumList[_killed] = 0
    ---计算连杀积分
    local curKillNum = self.continuousKillNumList[_killer]
    local addScore = self.killScore[curKillNum] or self.killScore[#self.killScore]
    self:BroadcastKill(_killer, curKillNum)
    self:AddScore(_killer, addScore)
end

---占点模式的击杀积分计算
function ScoreMgr:OccupyModeKill(_killer)
    local key, teamA, teamB = OccupyMode:CheckPlayerInOccPoint(_killer)
    if not key then
        return
    end
    if teamB == 0 and teamA == 0 or teamB >= 100 or teamA >= 100 then
        return
    end
    if _killer.PlayerType.Value == Const.TeamEnum.Team_A then
        if teamA > 0 then
            ---防守击杀
            self:AddScore(_killer, self.protectKillScore)
        elseif teamB > 0 then
            ---进攻击杀
            self:AddScore(_killer, self.attackKillScore)
        end
    elseif _killer.PlayerType.Value == Const.TeamEnum.Team_B then
        if teamA > 0 then
            ---进攻击杀
            self:AddScore(_killer, self.attackKillScore)
        elseif teamB > 0 then
            ---防守击杀
            self:AddScore(_killer, self.protectKillScore)
        end
    end
end

function ScoreMgr:GameOver(info)
    local winTeam = info.WinTeam
    for i, v in pairs(GameFlowMgr.playersInfoList.PlayersInfo[winTeam]) do
        local player = v.Player
        self:AddScore(player, self.winScore)
    end
end

---玩家积分增加调用
function ScoreMgr:AddScore(_player, _score)
    self.scoreList[_player] = self.scoreList[_player] or 0
    self.scoreList[_player] = self.scoreList[_player] + _score
    NetUtil.Fire_C('PlayerScoreAddEvent', _player, _score)
end

---广播连杀数量
function ScoreMgr:BroadcastKill(_player, _num)
    if self.continuousKillConfig[_num] then
        ---配置中存在这个连杀数量
        NetUtil.Broadcast('ContinuousKillEvent', _player, _num)
    end
end

return ScoreMgr
