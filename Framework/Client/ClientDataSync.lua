--- 游戏客户端数据同步
--- @module Client Sync Data, Client-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local ClientDataSync = {}

--- Localize global vars
local Config, MetaData = Ava.Config, Ava.Framework.MetaData

--- 客户端私有数据
local rawDataGlobal = {}
local rawDataPlayer = {}

--- 打印数据同步日志
local PrintLog = Config.DebugMode and Config.Debug.ShowDataSyncLog and function(...)
        print('[AvaKit][DataSync][Client]', ...)
    end or function()
    end

--! 初始化

--- 数据初始化
function ClientDataSync.Init()
    print('[AvaKit][DataSync][Client] Init()')
    InitEventsAndListeners()
    InitDataDefines()
end

--- 初始化事件和绑定Handler
function InitEventsAndListeners()
    if localPlayer.C_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', localPlayer)
    end

    -- 数据同步事件
    world:CreateObject('CustomEvent', 'DataSyncS2CEvent', localPlayer.C_Event)
    localPlayer.C_Event.DataSyncS2CEvent:Connect(DataSyncS2CEventHandler)

    -- 长期存储成功事件
    if not localPlayer.C_Event.LoadPlayerDataSuccessEvent then
        world:CreateObject('CustomEvent', 'LoadPlayerDataSuccessEvent', localPlayer.C_Event)
    end
end

--- 校验数据定义
function InitDataDefines()
    --* 客户端全局数据
    if Ava.Manifest.Server.Exist then
        -- 同虚拟机，不同步
        Data.Global = Data.Global or Data.Default.Global
    else
        -- 不同虚拟，同步
        -- Data.Global = Data.Global or MetaData.New(rawDataGlobal, MetaData.Enum.GLOBAL, MetaData.Enum.CLIENT)
        Data.Global = MetaData.New(rawDataGlobal, MetaData.Enum.GLOBAL, MetaData.Enum.CLIENT)
        -- 默认赋值
        for k, v in pairs(Data.Default.Global) do
            Data.Global[k] = v
        end
    end

    --* 客户端玩家数据
    local uid = localPlayer.UserId
    local path = MetaData.Enum.PLAYER .. uid
    -- Data.Player = Data.Player or MetaData.New(rawDataPlayer, path, uid)
    Data.Player = MetaData.New(rawDataPlayer, path, uid)
    -- 默认赋值
    for k, v in pairs(Data.Default.Player) do
        Data.Player[k] = v
    end
end

--- 开始同步
function ClientDataSync.Start()
    print('[AvaKit][DataSync][Client] 客户端数据同步开启')
    MetaData.ClientSync = true
end

--! Event handler

--- 数据同步事件Handler
function DataSyncS2CEventHandler(_path, _value)
    if not MetaData.ClientSync then
        return
    end

    PrintLog(string.format('收到 _path = %s, _value = %s', _path, table.dump(_value)))

    local uid = localPlayer.UserId

    --* 收到服务器数据
    if string.startswith(_path, MetaData.Enum.GLOBAL) then
        --* Data.Global 全局数据
        MetaData.Set(rawDataGlobal, _path, _value, uid, false)
    elseif string.startswith(_path, MetaData.Enum.PLAYER .. uid) then
        --* Data.Player 玩家数据
        MetaData.Set(rawDataPlayer, _path, _value, uid, false)
    else
        error(
            string.format(
                '[AvaKit][DataSync][Client] _path错误 _player = %s, _path = %s, _value = %s',
                localPlayer,
                _path,
                table.dump(_value)
            )
        )
    end
end

return ClientDataSync
