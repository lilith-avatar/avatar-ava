--- @module GameFlowMgr 游戏流程控制单例
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local GameFlowMgr, this = ModuleUtil.New('GameFlowMgr', ServerBase)

--- 初始化
function GameFlowMgr:Init()
    self.scenesFolder = world.Scenes or world:CreateObject('FolderObject', 'Scenes', world)
    ---游戏结算时候大厅准备区域的阻挡
    self.readyBlock = world.HallStaticObj.ReadyBlock
    local fms =
        StateMachineUtil.create(
        {
            initial = Const.GameStateEnum.OnHall,
            events = {
                {name = 'ReturnToHall', from = Const.GameStateEnum.OnOver, to = Const.GameStateEnum.OnHall},
                {name = 'StartReady', from = Const.GameStateEnum.OnHall, to = Const.GameStateEnum.OnReady},
                {name = 'StartGame', from = Const.GameStateEnum.OnReady, to = Const.GameStateEnum.OnGame},
                {name = 'GameOver', from = Const.GameStateEnum.OnGame, to = Const.GameStateEnum.OnOver}
            }
        }
    )
    function fms:onOnHall(event, from, to, msg)
        msg = msg or ''
        print('游戏状态更改为大厅状态 ' .. msg, event, from, to)
        GameFlowMgr:OpenRoom()
        GameFlowMgr:OnReset()
    end
    function fms:onOnReady(event, from, to, msg)
        msg = msg or ''
        print('游戏开始,双方进入准备阶段 ' .. msg, event, from, to)
        GameFlowMgr:CloseRoom()
        GameFlowMgr:ModeStart()
        ScoreMgr:Start(GameFlowMgr.curMode)
        NpcEnemyMgr:Start(GameFlowMgr.curSceneId)
        CloudLog:GameStart(GameFlowMgr.curSceneId)
    end
    function fms:onOnGame(event, from, to, msg)
        msg = msg or ''
        print('准备阶段结束,游戏正式开始 ' .. msg)
        --world.HallStaticObj:SetActive(false)
    end
    function fms:onOnOver(event, from, to, msg)
        msg = msg or ''
        print('游戏结束,结算界面展示 ' .. msg)
        CloudLog:GameOver()
        --world.HallStaticObj:SetActive(true)
    end
    ---游戏要求的玩家数量,达到这个数量的玩家准备(点击匹配按钮)才会开始游戏
    self.playersNumRequire = Config.GlobalConfig.PlayerNum
    self.gameFms = fms
    ---@type Object 当前使用的场景
    self.sceneObj = nil
    ---当前的游戏模式
    self.curMode = 0
    ---当前游戏的场景ID
    self.curSceneId = 0
    ---当前在匹配状态中的玩家
    self.inMatchingPlayersList = {}
    ---当前不在匹配状态中的玩家
    self.notInMatchingPlayersList = {}
    ---结算状态的假玩家
    self.fakeNpcList = {}
    ---关房间的倒计时,会在游戏进行中重复执行关房间操作
    self.closeRoomCD = 11
    ---开房间的倒计时
    self.openRoomCD = 11

    ---玩家在模式中的信息
    self.playersInfoList = {}
    self.playersInfoList.PlayersInfo = {}
    self.playersInfoList.PlayersInfo[Const.TeamEnum.Team_A] = {}
    self.playersInfoList.PlayersInfo[Const.TeamEnum.Team_B] = {}
    self.playersInfoList.MVPPlayers = {}

    self.hall2GameWaitTime = Config.GlobalConfig.Hall2GameWait
    self.gameReadyWait = Config.GlobalConfig.GameReadyWait

    world.OnPlayerAdded:Connect(
        function(_player)
            self:PlayerAdd(_player)
        end
    )

    self:OpenRoom()
end

--- Update函数
--- @param dt number delta time 每帧时间
function GameFlowMgr:Update(dt, tt)
    if self.gameFms.current ~= Const.GameStateEnum.OnHall then
        self.closeRoomCD = self.closeRoomCD - dt
        if self.closeRoomCD <= 0 then
            ---再次执行关房间操作
            self:CloseRoom()
            self.closeRoomCD = 11
        end
    else
        self.openRoomCD = self.openRoomCD - dt
        if self.openRoomCD <= 0 then
            ---再次执开房间操作
            self:OpenRoom()
            self.openRoomCD = 11
        end
    end
end

---游戏模式开始
function GameFlowMgr:ModeStart()
    self:RandomScene()
    self:SetTeam()
    self:InitConfig(self.curSceneId)
    if self.curMode == Const.GameModeEnum.OccupyMode then
        ---占点模式
        OccupyMode:ModeStart(self.curSceneId, self.sceneObj)
    elseif self.curMode == Const.GameModeEnum.BombMode then
        ---爆破模式
        BombMode:ModeStart(self.curSceneId, self.sceneObj)
    elseif self.curMode == Const.GameModeEnum.DeathmatchMode then
        ---死斗模式
        DeathmatchMode:ModeStart(self.curSceneId, self.sceneObj)
    end
end

---随机生成场景
function GameFlowMgr:RandomScene()
    local usableScenes = {}
    for i, v in pairs(Config.Scenes) do
        if v.Usable then
            usableScenes[i] = v
        end
    end
    local sceneConfig = table.readRandomValueInTable(usableScenes)
    self.curSceneId = sceneConfig.SceneId
    self.curMode = sceneConfig.ModeType
    self.sceneObj = world:CreateInstance(sceneConfig.ArchetypeName, sceneConfig.ArchetypeName, self.scenesFolder)
end

---给游戏中的玩家分配阵营
function GameFlowMgr:SetTeam()
    local playerList = world:FindPlayers()
    local playersNum = #playerList
    playerList = Shuffle(playerList)
    if playersNum % 2 ~= 0 then
        for i = 1, (playersNum + 1) / 2 do
            playerList[i].PlayerType.Value = Const.TeamEnum.Team_A
        end
        for i = (playersNum + 1) / 2, playersNum do
            playerList[i].PlayerType.Value = Const.TeamEnum.Team_B
        end
    else
        for i = 1, playersNum / 2 do
            playerList[i].PlayerType.Value = Const.TeamEnum.Team_A
        end
        for i = playersNum / 2 + 1, playersNum do
            playerList[i].PlayerType.Value = Const.TeamEnum.Team_B
        end
    end
end

function GameFlowMgr:InitConfig(_sceneId)
    local sceneConfig = Config.Scenes[_sceneId]
    ---根据配置创建结算界面展示用的假玩家
    self.fakeNpcPos = sceneConfig.FakeNpcPos
    ---初始化游戏信息数据表
    for i, v in pairs(world:FindPlayers()) do
        if v.PlayerType and v.PlayerType.Value ~= Const.TeamEnum.None then
            local onePlayerInfo = {}
            onePlayerInfo.Kill = 0
            onePlayerInfo.Death = 0
            onePlayerInfo.Score = 0
            onePlayerInfo.Player = v
            table.insert(self.playersInfoList.PlayersInfo[v.PlayerType.Value], onePlayerInfo)
        end
    end
    self.inMatchingPlayersList = {}
    self.notInMatchingPlayersList = world:FindPlayers()
end

---游戏返回大厅后数据清理
function GameFlowMgr:OnReset()
    if self.sceneObj and not self.sceneObj:IsNull() then
        self.sceneObj:Destroy()
    end
    for i, v in pairs(FindAllPlayers()) do
        v.PlayerState.Value = Const.PlayerStateEnum.OnHall_NoMatching
    end
    self.inMatchingPlayersList = {}
    self.notInMatchingPlayersList = world:FindPlayers()

    self.playersInfoList = {}
    self.playersInfoList.PlayersInfo = {}
    self.playersInfoList.PlayersInfo[Const.TeamEnum.Team_A] = {}
    self.playersInfoList.PlayersInfo[Const.TeamEnum.Team_B] = {}
    self.playersInfoList.MVPPlayers = {}

    if self.curMode == Const.GameModeEnum.OccupyMode then
        OccupyMode:Reset()
    elseif self.curMode == Const.GameModeEnum.BombMode then
        BombMode:Reset()
    elseif self.curMode == Const.GameModeEnum.DeathmatchMode then
        DeathmatchMode:Reset()
    end
    NpcEnemyMgr:Reset()
    ScoreMgr:Reset()
    self:DestroyFakeNpc()
end

---开房间
function GameFlowMgr:OpenRoom()
    Game.SetRoomEntrance(true)
    self.readyBlock:SetActive(false)
end

---关房间
function GameFlowMgr:CloseRoom()
    Game.SetRoomEntrance(false)
    self.readyBlock:SetActive(true)
end

function GameFlowMgr:Hall2Ready()
    self.gameFms:StartReady()
    for i, v in pairs(FindAllPlayers()) do
        v.PlayerState.Value = Const.PlayerStateEnum.OnGame
    end
end

function GameFlowMgr:Ready2Start()
    self.gameFms:StartGame()
end

function GameFlowMgr:GameOver(info)
    self.gameFms:GameOver('获胜队伍为' .. info.WinTeam)
    NpcEnemyMgr:GameOver()
    ScoreMgr:GameOver(info)
    self:GameOverInfo(info)
    for i, v in pairs(FindAllPlayers()) do
        v.PlayerState.Value = Const.PlayerStateEnum.OnOver
    end
    ---创建结算展示用的NPC
    self:CreateFakeNpc(info)
    NetUtil.Broadcast('GameOverEvent', info, self.fakeNpcList, info.MVPPlayers)
end

---游戏结束后的信息计算
function GameFlowMgr:GameOverInfo(info)
    ---玩家积分更新
    for i, v in pairs(self.playersInfoList.PlayersInfo[Const.TeamEnum.Team_A]) do
        self.playersInfoList.PlayersInfo[Const.TeamEnum.Team_A][i].Score = ScoreMgr.scoreList[v.Player]
    end
    for i, v in pairs(self.playersInfoList.PlayersInfo[Const.TeamEnum.Team_B]) do
        self.playersInfoList.PlayersInfo[Const.TeamEnum.Team_B][i].Score = ScoreMgr.scoreList[v.Player]
    end
    info.PlayersInfo = self.playersInfoList.PlayersInfo
    local addTable = {}
    local a_num, b_num = #info.PlayersInfo[Const.TeamEnum.Team_A], #info.PlayersInfo[Const.TeamEnum.Team_B]
    for i = 1, a_num do
        addTable[i] = info.PlayersInfo[Const.TeamEnum.Team_A][i]
    end
    for i = a_num + 1, a_num + b_num do
        addTable[i] = info.PlayersInfo[Const.TeamEnum.Team_B][i - a_num]
    end
    table.sort(
        addTable,
        function(a, b)
            return a.Score > b.Score
        end
    )
    local mvpPlayers = {}
    for i = 1, 3 do
        if not addTable[i] then
            break
        end
        mvpPlayers[i] = {
            Player = addTable[i].Player,
            Kill = addTable[i].Kill,
            IsMvp = false
        }
    end
    mvpPlayers[1].IsMvp = true
    table.sort(
        mvpPlayers,
        function(a, b)
            return a.Kill > b.Kill
        end
    )
    for i, v in pairs(mvpPlayers) do
        mvpPlayers[i].Title = Const.TitleEnum[i]
    end
    info.MVPPlayers = mvpPlayers
end

function GameFlowMgr:PlayerAdd(_player)
    table.insert(self.notInMatchingPlayersList, _player)
    table.unique(self.notInMatchingPlayersList)
    _player.PlayerState.Value = Const.PlayerStateEnum.OnHall_NoMatching
end

function GameFlowMgr:PlayerRemove(_player)
end

---NPC创建成功事件
function GameFlowMgr:NpcCreateEventHandler(_npc)
    local onePlayerInfo = {}
    onePlayerInfo.Kill = 0
    onePlayerInfo.Death = 0
    onePlayerInfo.Score = 0
    onePlayerInfo.Player = _npc
    table.insert(self.playersInfoList.PlayersInfo[_npc.PlayerType.Value], onePlayerInfo)
end

---NPC销毁事件
function GameFlowMgr:NpcDestroyEventHandler(_npc)
end

---玩家开始匹配
function GameFlowMgr:PlayerStartMatchEventHandler(_player)
    print('玩家开始匹配', 'PlayerStartMatchEventHandler')
    if self.gameFms.current ~= Const.GameStateEnum.OnHall then
        ---游戏状态不在大厅不响应玩家准备状态
        return
    end
    table.removebyvalue(self.notInMatchingPlayersList, _player)
    table.insert(self.inMatchingPlayersList, _player)
    table.unique(self.inMatchingPlayersList)
    _player.PlayerState.Value = Const.PlayerStateEnum.OnHall_Matching
    local curMatchingNum = #self.inMatchingPlayersList
    NetUtil.Broadcast('MatchPlayerChangeEvent', curMatchingNum)
    if curMatchingNum >= self.playersNumRequire then
        ---在匹配中的玩家数量达到要求
        invoke(
            function()
                self:Hall2Ready()
            end,
            self.hall2GameWaitTime
        )
        invoke(
            function()
                self:Ready2Start()
            end,
            self.hall2GameWaitTime + self.gameReadyWait
        )
    end
end

---玩家停止匹配
function GameFlowMgr:PlayerStopMatchEventHandler(_player)
    if self.gameFms.current ~= Const.GameStateEnum.OnHall then
        ---游戏状态不在大厅不响应玩家取消准备状态
        return
    end
    table.removebyvalue(self.inMatchingPlayersList, _player)
    table.insert(self.notInMatchingPlayersList, _player)
    table.unique(self.notInMatchingPlayersList)
    _player.PlayerState.Value = Const.PlayerStateEnum.OnHall_NoMatching
    local curMatchingNum = #self.inMatchingPlayersList
    NetUtil.Broadcast('MatchPlayerChangeEvent', curMatchingNum)
end

---玩家请求返回大厅
function GameFlowMgr:PlayerReturnHallEventHandler(_player)
    _player.PlayerState.Value = Const.PlayerStateEnum.OnHall_NoMatching
    NetUtil.Fire_C('TransferEvent', _player, world.SpawnLocations.StartPortal.Position)
    ---所有玩家全部返回大厅后修改状态
    local noHallNum = 0
    for i, v in pairs(world:FindPlayers()) do
        if
            v.PlayerState.Value ~= Const.PlayerStateEnum.OnHall_NoMatching and
                v.PlayerState.Value ~= Const.PlayerStateEnum.OnHall_Matching
         then
            noHallNum = noHallNum + 1
        end
    end
    if noHallNum == 0 then
        self.gameFms:ReturnToHall()
    end
end

function GameFlowMgr:CreateFakeNpc(info)
    local mvpPlayers = info.MVPPlayers
    for i, v in pairs(mvpPlayers) do
        if v.Player then
            local npc = world:CreateInstance('MVPPlayer', 'MVPPlayer', world, self.fakeNpcPos[i])
            local dir = Config.Scenes[self.curSceneId].GameOverCamPos - self.fakeNpcPos[i]
            npc.Forward = dir
            npc.Rotation = EulerDegree(0, npc.Rotation.Y, 0)
            print(npc, npc.Rotation)
            local playerType = world:CreateObject('IntValueObject', 'PlayerType', npc)
            playerType.Value = v.Player.PlayerType.Value
            local playerValue = world:CreateObject('ObjRefValueObject', 'PlayerRef', npc)
            playerValue.Value = v.Player
            self.fakeNpcList[i] = npc
            npc.SurfaceGUI.Panel.TxtPlayerName.Text = splitString(v.Player.Name, Config.GlobalConfig.NameLengthShow)
            npc.SurfaceGUI.Panel.TxtTitle.Text = v.Title
            copyAvatar(v.Player.Avatar, npc.NpcAvatar)
            if v.IsMvp then
                npc.SurfaceGUI.Panel.MVPIcon:SetActive(true)
            else
                npc.SurfaceGUI.Panel.MVPIcon:SetActive(false)
            end
        end
    end
end

function GameFlowMgr:DestroyFakeNpc()
    for i, v in pairs(self.fakeNpcList) do
        if not v:IsNull() then
            v:Destroy()
        end
    end
    self.fakeNpcList = {}
end

---@param _killer PlayerInstance 击杀者
---@param _killed PlayerInstance 被杀的人
---@param _weaponId number 伤害来源的枪械ID
---@param _hitPart number 击杀部位
function GameFlowMgr:PlayerDieEventHandler(_killer, _killed, _weaponId, _hitPart)
    ---对双方死亡和击杀数进行更新
    local killInfoList = {}
    for i, v in pairs(self.playersInfoList.PlayersInfo[Const.TeamEnum.Team_A]) do
        if v.Player == _killer then
            self.playersInfoList.PlayersInfo[Const.TeamEnum.Team_A][i].Kill = v.Kill + 1
        end
        if v.Player == _killed then
            self.playersInfoList.PlayersInfo[Const.TeamEnum.Team_A][i].Death = v.Death + 1
        end
        killInfoList[v.Player] = v.Kill
    end
    for i, v in pairs(self.playersInfoList.PlayersInfo[Const.TeamEnum.Team_B]) do
        if v.Player == _killer then
            self.playersInfoList.PlayersInfo[Const.TeamEnum.Team_B][i].Kill = v.Kill + 1
        end
        if v.Player == _killed then
            self.playersInfoList.PlayersInfo[Const.TeamEnum.Team_B][i].Death = v.Death + 1
        end
        killInfoList[v.Player] = v.Kill
    end
    NetUtil.Broadcast('KillRankChangeEvent', killInfoList)
end

function GameFlowMgr:OnPlayerLeaveEventHandler(_player)
    self:PlayerStopMatchEventHandler(_player)
    table.removebyvalue(self.notInMatchingPlayersList, _player)
    ---将玩家从信息表中移除
    if self.gameFms.current == Const.GameStateEnum.OnGame or self.gameFms.current == Const.GameStateEnum.OnReady then
        local team = _player.PlayerType.Value
        for i, v in pairs(self.playersInfoList.PlayersInfo[team]) do
            if v.Player == _player then
                table.remove(self.playersInfoList.PlayersInfo[team], i)
            end
        end
    end
end

function GameFlowMgr:OnPlayerJoinEventHandler(_player)
    ---玩家成功加入游戏,判断当前游戏状态是否为大厅状态
    if self.gameFms.current ~= Const.GameStateEnum.OnHall then
        ---当前不是在大厅状态,通知玩家显示提示框
        invoke(
            function()
                while wait() do
                    if _player.C_Event and _player.C_Event.StillInGameEvent then
                        NetUtil.Fire_C('StillInGameEvent', _player)
                        return
                    end
                end
            end
        )
    end
end

return GameFlowMgr
