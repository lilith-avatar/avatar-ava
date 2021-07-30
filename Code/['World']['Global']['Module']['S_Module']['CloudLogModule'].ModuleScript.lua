---@module CloudLog
---@copyright Lilith Games, Avatar Team
---@author RopzTao
local CloudLog, this = ModuleUtil.New('CloudLog', ServerBase)
local curSceneId = nil

---初始化函数
function CloudLog:Init()
    self.playersAddTime = {}
    self.playersRemoveTime = {}

    world.OnPlayerAdded:Connect(
        function(_player)
            self:PlayerAdd(_player)
        end
    )

    world.OnPlayerRemoved:Connect(
        function(_player)
            self:PlayerRemove(_player)
        end
    )
end

function CloudLog:PlayerAdd(_player)
    self.playersAddTime[_player.UserId] = Timer.GetTime()
end

function CloudLog:PlayerRemove(_player)
    self.playersRemoveTime[_player.UserId] = Timer.GetTime()

    local playerGameTime = self.playersRemoveTime[_player.UserId] - self.playersAddTime[_player.UserId]
    ---埋点需求001..单一玩家的连续游戏时长
    local mes1 = tostring(_player.UserId) .. '/' .. tostring(playerGameTime)
    CloudLogUtil.UploadLog('PlayerGameTime', mes1)

    if
        _player.PlayerState.Value == Const.PlayerStateEnum.OnHall_NoMatching or
            _player.PlayerState.Value == Const.PlayerStateEnum.OnHall_Matching
     then
        ---埋点需求002..情况2
        local mes2_2 = 'F' .. tostring(_player.UserId) .. '/' .. tostring(playerGameTime)
        CloudLogUtil.UploadLog('HallToGame', mes2_2)
    end

    ---埋点需求005..玩家有效游戏时间

    self.playersAddTime[_player.UserId] = nil
end

---埋点需求002 玩家在大厅准备的时长
---情况1，进入大厅，匹配成功，开始
---情况2，进入大厅，匹配失败，退出
function CloudLog:GameStart(_sceneId)
    curSceneId = _sceneId
    ---埋点需求002..情况1
    for k, v in pairs(self.playersAddTime) do
        local mes2_1 = 'S' .. tostring(k) .. '/' .. tostring(Timer.GetTime() - v)
        CloudLogUtil.UploadLog('HallToGame', mes2_1)
    end

    ---埋点需求006..单局游戏开始人数
    local mes6 = tostring(_sceneId) .. '/' .. tostring(#self.playersAddTime)
    CloudLogUtil.UploadLog('GameStartPlayerNum', mes6)
end

function CloudLog:GameOver()
    ---埋点需求007..单局游戏结束人数
    local mes7 = tostring(curSceneId) .. '/' .. tostring(#self.playersAddTime)
    CloudLogUtil.UploadLog('GameOver', mes7)
end

---埋点需求003..玩家枪械选取
function CloudLog:PlayerDoChangeOccEventHandler(_player, _occId)
    local mes3 = tostring(_player.UserId) .. '/' .. tostring(_occId)
    CloudLogUtil.UploadLog('Choose', mes3)
end

---埋点需求004..击杀信息
---@param _killer PlayerInstance 击杀者
---@param _killed PlayerInstance 被杀的人
---@param _weaponId number 伤害来源的枪械ID
---@param _hitPart number 击杀部位
function CloudLog:PlayerDieEventHandler(_killer, _killed, _weaponId, _hitPart)
    local mes4 =
        tostring(curSceneId) ..
        '/' ..
            tostring(_killer.Position) ..
                '/' .. tostring(_killed.Position) .. '/' .. tostring(_weaponId) .. '/' .. tostring(_hitPart)
    CloudLogUtil.UploadLog('KillInfo', mes4)
end

return CloudLog
