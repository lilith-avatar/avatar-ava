--- @module OccupationLogic 服务端更改职业的逻辑
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local OccupationLogic, this = ModuleUtil.New('OccupationLogic', ServerBase)

function OccupationLogic:Init()
    --- key - player  value - occ
    self.playersList = {}

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
    self.allowChangeList = {}
end

--- Update
--- @param dt number delta time
function OccupationLogic:Update(dt, tt)
end

---@param _player PlayerInstance
---@param _occ number
function OccupationLogic:SetOccupation(_player, _occ)
    if not Config.Occupation[_occ] and _occ ~= Const.OccupationEnum.None then
        return
    end
    if self.playersList[_player] == Const.OccupationEnum.None then
        NetUtil.Fire_C('ChangeOcc', _player, _occ)
    else
        NetUtil.Fire_C('ChangeOcc', _player, _occ)
    end
    self.playersList[_player] = _occ
end

function OccupationLogic:PlayerAdd(_player)
    self.playersList[_player] = Const.OccupationEnum.None
    self.allowChangeList[_player] = true
end

function OccupationLogic:OnPlayerLeaveEventHandler(_player)
    self.playersList[_player] = nil
    self.allowChangeList[_player] = nil
end

---@param _player PlayerInstance
function OccupationLogic:OnPlayerJoinEventHandler(_player)
    print('OccupationLogic:OnPlayerJoinEventHandler', _player)
end

---玩家尝试更改职业,需要进行一定判断
function OccupationLogic:PlayerTryChangeOccEventHandler(_player, _id)
    if self.allowChangeList[_player] == nil then
        self.allowChangeList[_player] = true
    end
    local pos1, pos2
    if _player.PlayerType.Value == Const.TeamEnum.Team_A then
        pos1 = OccupyMode.pos1_A
        pos2 = OccupyMode.pos2_A
    elseif _player.PlayerType.Value == Const.TeamEnum.Team_B then
        pos1 = OccupyMode.pos1_B
        pos2 = OccupyMode.pos2_B
    end
    --[[
    if not self:CheckInRange(_player, pos1, pos2) then
        ---不在己方出生区域内
        NetUtil.Fire_C('NoticeEvent', _player, 1003)
        return
    end]]
    if not self.allowChangeList[_player] then
        ---在换职业的冷却中
        NetUtil.Fire_C('NoticeEvent', _player, 1001)
        return
    end
    NetUtil.Fire_C('ChangeOccEvent', _player, _id)
    NetUtil.Fire_S('PlayerDoChangeOccEvent', _player, _id)
    self.allowChangeList[_player] = false
    invoke(
        function()
            if not _player:IsNull() then
                self.allowChangeList[_player] = true
            end
        end,
        3
    )
end

---判断玩家是否在一个区域内
function OccupationLogic:CheckInRange(_player, _pos1, _pos2)
    local x1, x2 = _pos1.X, _pos2.X
    local z1, z2 = _pos1.Z, _pos2.Z
    local x, z = _player.Position.X, _player.Position.Z
    if x >= x1 and x <= x2 or x >= x2 and x <= x1 then
        if z >= z1 and z <= z2 or z >= z2 and z <= z1 then
            return true
        end
    end
    return false
end

return OccupationLogic
