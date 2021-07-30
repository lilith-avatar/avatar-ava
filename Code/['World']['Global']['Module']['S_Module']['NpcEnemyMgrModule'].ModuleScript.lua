--- @module NpcEnemyMgr 服务端敌人NPC管理模块
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local NpcEnemyMgr, this = ModuleUtil.New('NpcEnemyMgr', ServerBase)

--- 初始化
function NpcEnemyMgr:Init()
    self.npcList = {}
    self.npcFolder = world.Npc or world:CreateObject('FolderObject', 'Npc', world)
    self.teamMinNum = Config.GlobalConfig.TeamMinNum
    self.m_enable = false
    self.m_sceneId = -1

    world.OnPlayerRemoved:Connect(
        function(_player)
            --self:PlayerRemove(_player)
        end
    )
end

---游戏开始后调用
function NpcEnemyMgr:Start(_sceneId)
    self.m_sceneId = _sceneId
    self.pos1_A = Config.Scenes[_sceneId].BornArea[1][1]
    self.pos2_A = Config.Scenes[_sceneId].BornArea[1][2]
    self.pos1_B = Config.Scenes[_sceneId].BornArea[2][1]
    self.pos2_B = Config.Scenes[_sceneId].BornArea[2][2]
end

---游戏正式开始
function NpcEnemyMgr:StartGame()
    self.m_enable = true
    local teamA_num, teamB_num = 0, 0
    local teamA_npcNum, teamB_npcNum = 0, 0
    for i, v in pairs(FindAllPlayers()) do
        if v.PlayerType then
            if v.PlayerType.Value == Const.TeamEnum.Team_A then
                teamA_num = teamA_num + 1
            elseif v.PlayerType.Value == Const.TeamEnum.Team_B then
                teamB_num = teamB_num + 1
            end
        end
    end
    teamA_npcNum = self.teamMinNum - teamA_num
    teamB_npcNum = self.teamMinNum - teamB_num
    teamA_npcNum = teamA_npcNum <= 0 and 0 or teamA_npcNum
    teamB_npcNum = teamB_npcNum <= 0 and 0 or teamB_npcNum
    for i = 1, teamA_npcNum do
        self:CreateNpc(Const.TeamEnum.Team_A, self.m_sceneId)
    end
    for i = 1, teamB_npcNum do
        self:CreateNpc(Const.TeamEnum.Team_B, self.m_sceneId)
    end
end

--- Update函数
--- @param dt number delta time 每帧时间AS
function NpcEnemyMgr:Update(dt, tt)
    if not self.m_enable then
        return
    end
    for i, v in pairs(self.npcList) do
        v:Update(dt, tt)
    end
end

---创建NPC
function NpcEnemyMgr:CreateNpc(_team, _sceneId)
    local area = {}
    if _team == Const.TeamEnum.Team_A then
        area[1] = self.pos1_A
        area[2] = self.pos2_A
    else
        area[1] = self.pos1_B
        area[2] = self.pos2_B
    end
    ---@type NpcEnemyBase
    local npc = NpcEnemyBase:new(_team, area, self.npcFolder, _sceneId)
    self.npcList[npc.uuid] = npc
    npc:Born()
    NetUtil.Fire_S('NpcCreateEvent', npc.model)
    NetUtil.Broadcast('NpcCreateEvent', npc.model, npc.cloths, _team)
    return npc.uuid
end

---游戏状态重置为大厅状态时候调用
function NpcEnemyMgr:Reset()
    for i, v in pairs(self.npcList) do
        NetUtil.Fire_S('NpcDestroyEvent', v.model)
        invoke(
            function()
                wait()
                v:Destroy()
            end
        )
    end
    self.npcList = {}
end

---一局游戏结束后调用
function NpcEnemyMgr:GameOver()
    self.m_enable = false
end

--- 有玩家离开游戏,需要动态补齐NPC,游戏在进行中才会执行
---@param _player PlayerInstance 离开游戏的玩家
function NpcEnemyMgr:OnPlayerLeaveEventHandler(_player)
    if
        GameFlowMgr.gameFms.current ~= Const.GameStateEnum.OnGame and
            GameFlowMgr.gameFms.current ~= Const.GameStateEnum.OnReady
     then
        return
    end
    print('玩家退出游戏,补全机器人')
    local team = _player.PlayerType.Value
    self:CreateNpc(team, self.m_sceneId)
end

---玩家开场运镜完成,只要一个玩家完成运镜,NPC就创建
function NpcEnemyMgr:CameraMoveEndEventHandler(_player)
    if self.m_enable then
        return
    end
    if
        GameFlowMgr.gameFms.current ~= Const.GameStateEnum.OnGame and
            GameFlowMgr.gameFms.current ~= Const.GameStateEnum.OnReady
     then
        return
    end
    self:StartGame()
end

return NpcEnemyMgr
