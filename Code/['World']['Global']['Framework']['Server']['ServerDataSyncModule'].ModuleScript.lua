--- 游戏服务器数据同步
--- @module Server Sync Data, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local ServerDataSync = {}

-- Localize global vars
local FrameworkConfig, MetaData, DataStore = FrameworkConfig, MetaData, DataStore

-- 服务器端私有数据
local rawDataGlobal = {}
local rawDataPlayers = {}

-- 玩家数据定时保存时间间隔（秒）
local AUTO_SAVE_TIME = FrameworkConfig.DatabaseAutoSaveTime
-- 重新读取游戏数据时间间隔（秒）
local RELOAD_TIME = 1

-- 玩家数据表格
local sheet

--- 打印数据同步日志
local PrintLog = FrameworkConfig.DebugMode and FrameworkConfig.Debug.ShowDataSyncLog and function(...)
        --print('[DataSync][Server]', ...)
    end or function()
    end

--! 初始化

--- 数据初始化
function ServerDataSync.Init()
    --print('[DataSync][Server] Init()')
    InitEventsAndListeners()
    InitDefines()
    sheet = DataStore:GetSheet('PlayerData')
end

--- 初始化事件和绑定Handler
function InitEventsAndListeners()
    if world.S_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', world)
    end

    -- 数据同步事件
    world:CreateObject('CustomEvent', 'DataSyncC2SEvent', world.S_Event)
    world.S_Event.DataSyncC2SEvent:Connect(DataSyncC2SEventHandler)

    -- 玩家加入事件
    local onPlayerJoinEvent = world.S_Event.OnPlayerJoinEvent
    assert(onPlayerJoinEvent, '[DataSync][Server] 不存在 OnPlayerJoinEvent')
    onPlayerJoinEvent:Connect(OnPlayerJoinEventHandler)

    -- 玩家离开事件
    local onPlayerLeaveEvent = world.S_Event.OnPlayerLeaveEvent
    assert(onPlayerLeaveEvent, '[DataSync][Server] 不存在 OnPlayerLeaveEvent')
    onPlayerLeaveEvent:Connect(OnPlayerLeaveEventHandler)

    -- 长期存储成功事件
    if not world.S_Event.LoadPlayerDataSuccessEvent then
        world:CreateObject('CustomEvent', 'LoadPlayerDataSuccessEvent', world.S_Event)
    end
end

--- 校验数据定义
function InitDefines()
    --* 服务器全局数据
    InitDataGlobal()

    --* 服务器玩家数据, key是uid
    Data.Players = {}
end

--- 初始化Data.Global
function InitDataGlobal()
    --* 服务器全局数据
    Data.Global = Data.Global or MetaData.New(rawDataGlobal, MetaData.Enum.GLOBAL, nil)
    -- 默认赋值
    for k, v in pairs(Data.Default.Global) do
        Data.Global[k] = v
    end
end

--- 初始化Data.Players中对应玩家数据
function InitDataPlayer(_uid)
    assert(not string.isnilorempty(_uid))
    --* 服务器端创建Data.Player
    local path = MetaData.Enum.PLAYER .. _uid
    rawDataPlayers[_uid] = {}
    Data.Players[_uid] = MetaData.New(rawDataPlayers[_uid], path, _uid)

    -- 默认赋值
    for k, v in pairs(Data.Default.Player) do
        Data.Players[_uid][k] = v
    end

    -- 设置uid
    Data.Players[_uid].uid = _uid
end

--- 开始同步
function ServerDataSync.Start()
    --print('[DataSync][Server] 服务器数据同步开启')
    MetaData.ServerSync = true

    -- 启动定时器
    TimeUtil.SetInterval(SaveAllGameDataAsync, AUTO_SAVE_TIME)
end

--! 长期存储：读取

--- 下载玩家的游戏数据
--- @param _uid string 玩家ID
function LoadGameDataAsync(_uid)
    sheet = DataStore:GetSheet('PlayerData')
    assert(sheet, '[DataSync][Server] DataPlayers的sheet不存在')
    sheet:GetValue(
        _uid,
        function(_val, _msg)
            LoadGameDataAsyncCb(_val, _msg, _uid)
        end
    )
end

--- 下载玩家的游戏数据回调
--- @param _val table 数据
--- @param _msg int 消息码
--- @param _uid string 玩家ID
function LoadGameDataAsyncCb(_val, _msg, _uid)
    local player = world:GetPlayerByUserId(_uid)
    assert(player, string.format('[DataSync][Server] 玩家不存在, uid = %s', _uid))
    if _msg == 0 or _msg == 101 then
        --print('[DataSync][Server] 获取玩家数据成功', player.Name)
        local hasData = _val ~= nil
        if hasData then
            --print('[DataSync][Server] 玩家数据，存在', player.Name)
            --若以前的数据存在，更新
            -- TODO: 数据兼容的处理
            local data = _val
            assert(data.uid == _uid, string.format('[DataSync][Server] uid校验不通过, uid = %s', _uid))
            --若已在此服务器的数据总表存在，则更新数据
            for k, v in pairs(data) do
                Data.Players[_uid][k] = data[k]
            end
        else
            -- 不存在数据，用之前生成的默认数据
            --print('[DataSync][Server] 玩家数据，不存在', player.Name)
        end
        NetUtil.Fire_S('LoadPlayerDataSuccessEvent', player, hasData)
        NetUtil.Fire_C('LoadPlayerDataSuccessEvent', player, hasData)
        return
    end
    print(
        string.format(
            '[DataSync][Server] 获取玩家数据失败，%s秒后重试, uid = %s, player = %s, msg = %s',
            RELOAD_TIME,
            _uid,
            player.Name,
            _msg
        )
    )
    --若失败，则1秒后重新再读取一次
    invoke(
        function()
            LoadGameDataAsync(_uid)
        end,
        RELOAD_TIME
    )
end

--! 长期存储：保存

--- 上传玩家的游戏数据
--- @param _userId string 玩家ID
--- @param _delete string 保存成功后是否删除缓存数据
function SaveGameDataAsync(_uid, _delete)
    sheet = DataStore:GetSheet('PlayerData')
    assert(sheet, '[DataSync][Server] DataPlayers的sheet不存在')
    assert(not string.isnilorempty(_uid), '[DataSync][Server] uid不存在或为空')
    assert(Data.Players[_uid], string.format('[DataSync][Server] Data.Players[_uid]不存在 uid = %s', _uid))
    local newData = MetaData.Get(Data.Players[_uid])
    assert(newData, string.format('[DataSync][Server] 玩家数据不存在, uid = %s', _uid))
    assert(newData.uid == _uid, string.format('[DataSync][Server] uid校验不通过, uid = %s', _uid))
    sheet:SetValue(
        _uid,
        newData,
        function(_val, _msg)
            SaveGameDataAsyncCb(_val, _msg, _uid, _delete)
        end
    )
end

--- 上传玩家的游戏数据回调
--- @param _val table 数据
--- @param _msg int 消息码
--- @param _uid string 玩家ID
function SaveGameDataAsyncCb(_val, _msg, _uid, _delete)
    -- 保存成功
    if _msg == 0 then
        --print('[DataSync][Server] 保存玩家数据，成功', _uid)
        if _delete == true then
            --print('[DataSync][Server] 删除服务器玩家数据', _uid)
            rawDataPlayers[_uid] = nil
            --* 删除玩家端数据
            Data.Players[_uid] = nil
        end
        return
    end

    -- 保存失败
    --print(string.format('[DataSync][Server] 保存玩家数据失败，%s秒后重试, uid = %s, msg = %s', RELOAD_TIME, _uid, _msg))
    --若失败，则1秒后重新再读取一次
    invoke(
        function()
            SaveGameDataAsync(_uid, _delete)
        end,
        RELOAD_TIME
    )
end

--- 存储全部玩家数据
function SaveAllGameDataAsync()
    if not MetaData.ServerSync then
        --print('[DataSync][Server] ServerSync未开始')
        return
    end
    --print('[DataSync][Server] 尝试保存全部玩家数据……')
    for uid, data in pairs(Data.Players) do
        if not string.isnilorempty(uid) and data then
            SaveGameDataAsync(uid, false)
        end
    end
end

--! Event handler

--- 数据同步事件Handler
function DataSyncC2SEventHandler(_player, _path, _value)
    if not MetaData.ServerSync then
        return
    end

    PrintLog(string.format('收到 player = %s, _path = %s, _value = %s', _player, _path, table.dump(_value)))

    local uid = _player.UserId

    if string.startswith(_path, MetaData.Enum.GLOBAL) then
        --* Data.Global：收到客户端改变数据的时候需要同步给其他玩家
        MetaData.Set(rawDataGlobal, _path, _value, nil, true)
    elseif string.startswith(_path, MetaData.Enum.PLAYER .. uid) then
        --* Data.Players
        MetaData.Set(rawDataPlayers[uid], _path, _value, uid, false)
    else
        error(
            string.format(
                '[DataSync][Server] _path错误 _player = %s, _path = %s, _value = %s',
                _player,
                _path,
                table.dump(_data)
            )
        )
    end
end

--- 新玩家加入事件Handler
function OnPlayerJoinEventHandler(_player)
    --print('[DataSync][Server] OnPlayerJoinEventHandler', _player, _player.UserId)
    --* 向客户端同步Data.Global
    NetUtil.Fire_C('DataSyncS2CEvent', _player, MetaData.Enum.GLOBAL, MetaData.Get(Data.Global))

    local uid = _player.UserId
    InitDataPlayer(uid)

    --* 获取长期存储,成功后向客户端同步
    LoadGameDataAsync(uid)
end

--- 玩家离开事件Handler
function OnPlayerLeaveEventHandler(_player, _uid)
    --print('[DataSync][Server] OnPlayerLeaveEventHandler', _player, _uid)
    assert(not string.isnilorempty(_uid), '[ServerDataSync] OnPlayerLeaveEventHandler() uid不存在')
    --* 保存长期存储：rawDataPlayers[_uid] 保存成功后删掉
    SaveGameDataAsync(_uid, true)
end

return ServerDataSync
