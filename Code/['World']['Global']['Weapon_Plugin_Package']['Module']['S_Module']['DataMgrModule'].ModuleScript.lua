--- @module DataMgr 枪械模块：数据管理
--- @copyright Lilith Games, Avatar Team
--- @author RopzTao
local DataMgr, this =
    {
        --- @type table 玩家初始默认数据
        defaultPlayerData = {},
        --- @type table 本服务器的所有玩家数据总表
        --- 结构为{UserId = "", Data = {}}
        allPlayersData = {}
    },
    nil

--- 初始化
function DataMgr:Init()
    this = self
    --- 设定玩家的默认数据
    self:SetDefaultPlayerData()
    self:InitListeners()
end

--- 初始化Game Manager自己的监听事件
function DataMgr:InitListeners()
    LinkConnects(world.S_Event, DataMgr, this)
end

--- Update函数
--- @param dt delta time 每帧时间
function DataMgr:Update(dt)
end

--- 设置默认的玩家数据
function DataMgr:SetDefaultPlayerData()
    self.defaultPlayerData = {
        AssAim = true,
        defaultSens = 5
    }
end

--- 下载玩家的游戏数据
--- @param _userId string 玩家ID
function DataMgr:LoadGameDataAsync(_userId)
    local player = world:GetPlayerByUserId(_userId)

    if not player then
        return
    end

    local sheet = DataStore:GetSheet('PlayerData')
    sheet:GetValue(
        _userId,
        function(val, msg)
            if msg == 0 or msg == 101 then
                --- 成功下载玩家数据后，通知客户端可以正式开始游戏
                --- NetUtil.Fire_C('EndLoadDataEvent', player)
                print('获取玩家数据成功', player.Name)
                --- 若以前的数据为空，则让数据等于默认值
                local sheetValue = {}
                if val then
                    self:TableMerge(sheetValue, val)
                else
                    self:TableMerge(sheetValue, self.defaultPlayerData)
                end

                --- 若已在此服务器的数据总表存在，则更新数据
                if self:GetDataByUserId(_userId) then
                    --- 若未在此服务器的数据总表存在，则加入总表
                    self:SetAllDataByUserId(_userId, sheetValue)
                else
                    table.insert(self.allPlayersData, {UserId = _userId, Data = sheetValue})
                end

                --- 同步玩家数据到客户端
                self:SyncDataToClient(_userId)
            else
                print('获取玩家数据失败，1秒后重试', player.Name, msg)
                --- 若失败，则1秒后重新再读取一次
                invoke(
                    function()
                        self:LoadGameDataAsync(_userId)
                    end,
                    1
                )
            end
        end
    )
end

--- 上传玩家的游戏数据
--- @param _userId string 玩家ID
function DataMgr:SaveGameDataAsync(_userId)
    local sheet = DataStore:GetSheet('PlayerData')
    local newValue = self:GetDataByUserId(_userId)

    if newValue then
        sheet:SetValue(
            _userId,
            newValue,
            function(val, msg)
                if msg == 0 then
                    print('保存玩家数据成功', _userId)
                else
                    print('保存玩家数据失败，1秒后重试', _userId, msg)
                    --- 若失败，则1秒后重新再读取一次
                    invoke(
                        function()
                            self:SaveGameDataAsync(_userId)
                        end,
                        1
                    )
                end
            end
        )
    else
        print('没有在服务器数据总表找到该玩家的数据', _userId)
    end
end

--- 获取指定玩家ID的数据的指定键值
--- 不输入键名则返回整个数据表，不存在则返回nil
--- @param _userId string 玩家ID
--- @param _key string 键名
function DataMgr:GetDataByUserId(_userId, _key)
    for i, v in pairs(self.allPlayersData) do
        if v.UserId == _userId then
            if _key then
                return (v.Data)[_key]
            else
                return v.Data
            end
        end
    end
    return nil
end

--- 设定指定玩家ID的全部数据
--- @param _userId string 玩家ID
--- @param _value 修改的目标值
function DataMgr:SetAllDataByUserId(_userId, _value)
    for i, v in pairs(self.allPlayersData) do
        if v.UserId == _userId then
            self:TableMerge(v.Data, _value)
            return true
        end
    end
    return print('没有找到指定的玩家')
end

--- 设定指定玩家ID的数据的指定键值
--- @param _userId string 玩家ID
--- @param _key string 键名
--- @param _value 修改的目标值
function DataMgr:SetDataByUserId(_userId, _key, _value)
    for i, v in pairs(self.allPlayersData) do
        if v.UserId == _userId then
            if v.Data and (v.Data)[_key] then
                if type((v.Data)[_key]) == 'table' then
                    if _value == {} then
                        (v.Data)[_key] = _value
                    else
                        self:TableMerge((v.Data)[_key], _value)
                    end
                else
                    (v.Data)[_key] = _value
                end
                return true
            else
                return print('没有找到可以修改的键', _key)
            end
        end
    end
    return print('没有找到指定的玩家')
end

--- 玩家数据修改后同步到服务端
function DataMgr:PlayerDataModifiEventHandler(_player, _key, _value)
    self:SetDataByUserId(_player.UserId, _key, _value)
end

--- 将玩家数据同步到客户端
--- @param _userId string 玩家ID
function DataMgr:SyncDataToClient(_userId)
    local player = world:GetPlayerByUserId(_userId)
    if not player then
        return
    end
    local thisPlayerData = self:GetDataByUserId(_userId)
    player.C_Event.SyncDataEvent:Fire(thisPlayerData)
end

--- 同步和保存
function DataMgr:SyncAndSaveEventHandler(_player)
    --- 同步数据更改
    self:SyncDataToClient(_player.UserId)
    --- 保存数据
    self:SaveGameDataAsync(_player.UserId)
    print('保存并且退出')
end

--- 将来源表格中所有键及其值复制到目标表格对象中，如果存在同名键，则覆盖其值
--- @param dest table
--- @param src table
function DataMgr:TableMerge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

return DataMgr
