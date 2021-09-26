---游戏同步数据基类
---@module Sync Data Base, Both-side
---@copyright Lilith Games, Avatar Team
---@author Yuancheng Zhang
local MetaData = {}

---Localize global vars
local Config = Ava.Config

--* 开关：Debug模式，开启后会打印日志
local debugMode = false
--* 开关：数据校验
local valid = true

---enum
MetaData.Enum = {}
---数据类型：全局 or 玩家
MetaData.Enum.GLOBAL = 'Global'
MetaData.Enum.PLAYER = 'Player'

-- 是否进行同步，数据初始化之后在开启同步
MetaData.ServerSync = false
MetaData.ClientSync = false

--! 说明：两种双向同步机制
--* 1. Data.Global
--  a. 客户端和服务器持有相同的数据类型 Data.Global
--  b. C=>S，某一客户端更新，自动发送给服务器，服务器更新，然后再同步给全部客户端
--  c. S=>C，服务器更新，广播给所有客户端，客户端各自更新
--* 2. Data.Player
--  a. 客户端只持有自己的 Data.Player
--  b. 服务器持有全部玩家的 Data.Players
--  c. C=>S，客户端更新，自动发送给服务器，服务器更新对应玩家数据
--  d. S=>C，服务器更新，自动发送给对应客户端，客户端更新玩家数据

--! 私有方法

---新建一个MetaData的proxy，用于数据同步
---@param _data 真实数据
---@param _path 当前节点索引路径
---@param _uid UserId
---@return proxy 代理table，没有data，元表内包含方法和path
function NewData(_data, _path, _uid)
    local proxy = {}
    local mt = {
        _data = _data,
        _path = _path,
        _uid = _uid,
        __index = function(_t, _k)
            local mt = getmetatable(_t)
            local newpath = mt._path .. '.' .. _k
            PrintLog('__index,', '_k = ', _k, ', _path = ', mt._path, ', newpath = ', newpath)
            return _data[newpath]
        end,
        __newindex = function(_t, _k, _v)
            local mt = getmetatable(_t)
            local newpath = mt._path .. '.' .. _k
            PrintLog('__newindex,', '_k =', _k, ', _v =', _v, ', _path = ', mt._path, ', newpath = ', newpath)
            SetData(_data, newpath, _v, _uid, true)
        end,
        __pairs = function()
            -- pairs()需要返回三个参数：next, _t, nil
            -- https://www.lua.org/pil/7.3.html
            -- 得到rd(raw data)，从rd中进行遍历
            local rd = GetData(_data, _path)
            return next, rd, nil
        end
    }
    setmetatable(proxy, mt)
    return proxy
end

---获得原始数据
---@param _data 真实数据的存储位置
---@param _path 当前节点索引路径
---@return rawData 纯数据table，不包含元表
function GetData(_data, _path)
    local rawData = {}
    GetDataAux(_data, _path, rawData)
    return rawData
end

---GetData的辅助函数
---@param _data 真实数据的存储位置
---@param _path 当前节点索引路径
---@param _rawData 纯数据table，不包含元表
function GetDataAux(_data, _path, _rawData)
    local key, i
    local q, elem = Queue:New(), {}
    elem.path = _path
    elem.rd = _rawData
    q:Enqueue(elem)
    while not q:IsEmpty() do
        elem = q:Dequeue()
        for k, v in pairs(_data) do
            i = string.find(k, elem.path .. '.')
            -- 筛选出当前直接层级的path，剪裁后作为rawData的key
            if i == 1 and #elem.path < #k then
                key = string.sub(k, #elem.path + 2, #k)
                if not string.find(key, '%.') then
                    key = tonumber(key) or key
                    if type(v) == 'table' then
                        elem.rd[key] = {}
                        q:Enqueue(
                            {
                                path = k,
                                rd = elem.rd[key]
                            }
                        )
                    else
                        elem.rd[key] = v
                    end
                end
            end
        end
    end
end

---设置原始数据
---@param _data 真实数据的存储位置
---@param _path 当前节点索引路径
---@param _value 传入的数据
---@param _uid UserId
---@param _sync true:同步数据
function SetData(_data, _path, _value, _uid, _sync)
    --* 数据同步:赋值的时候只要同步一次就可以的，存下newpath和_v，对方收到后赋值即可
    if _sync and (MetaData.ServerSync or MetaData.ClientSync) then
        SyncData(_path, _value, _uid)
    end

    local args, newpath = {}

    local q = Queue:New()
    q:Enqueue({_data, _path, _value, _uid, _sync})

    while not q:IsEmpty() do
        _data, _path, _value, _uid, _sync = table.unpack(q:Dequeue())

        --* 数据校验
        Validators(SetData)(_data, _path, _value, _uid, _sync)

        --* 检查现有数据
        if type(_data[_path]) == 'table' then
            -- TODO: 这里可以优化，不必要每次都删除
            -- 如果现有数据是个table,删除所有子数据
            for k, _ in pairs(_data[_path]) do
                -- 同等于 _data[_path][k] = nil，但是不同步
                newpath = _path .. '.' .. k
                q:Enqueue({_data, newpath, nil, _uid, false})
            end
        end

        --* 检查新数据
        if type(_value) == 'table' then
            -- 若新数据是table，建立一个mt
            _data[_path] = NewData(_data, _path, _uid)
            for k, v in pairs(_value) do
                -- 同等于 _data[_path][k] = v，但是不同步
                newpath = _path .. '.' .. k
                q:Enqueue({_data, newpath, v, _uid, false})
            end
        else
            -- 一般数据，直接赋值
            _data[_path] = _value
        end
    end
end

---数据同步
---@param _path 当前节点索引路径
---@param _value 传入的数据
---@param _uid UserId
function SyncData(_path, _value, _uid)
    if MetaData.ServerSync and MetaData.ClientSync and localPlayer and not string.isnilorempty(_uid) then
        --* 服务器/客户端（同虚拟机）
        --  Player 玩家数据同步
        local player = localPlayer
        -- local player = world:GetPlayerByUserId(_uid)
        -- Debug.Assert(player == localPlayer, string.format('[MetaData] 玩家不存在 uid = %s', _uid))
        PrintLog(
            string.format('[AvaKit][Server] 发出 player = %s, _path = %s, _value = %s', player, _path, table.dump(_value))
        )
        Ava.Util.Net.Fire_C('DataSyncS2CEvent', player, _path, _value)
        Ava.Util.Net.Fire_S('DataSyncC2SEvent', localPlayer, _path, _value)
    elseif localPlayer == nil and string.isnilorempty(_uid) and MetaData.ServerSync then
        --* 服务器 => 客户端（多端），单向同步
        --  Global 全局数据
        Ava.Util.Net.Broadcast('DataSyncS2CEvent', _path, _value)
    elseif localPlayer == nil and MetaData.ServerSync then
        --* 服务器 => 客户端（多端），单向同步
        --  Player 玩家数据同步
        local player = world:GetPlayerByUserId(_uid)
        Debug.Assert(player ~= nil, string.format('[AvaKit][MetaData] 玩家不存在 uid = %s', _uid))
        PrintLog(
            string.format('[AvaKit][Server] 发出 player = %s, _path = %s, _value = %s', player, _path, table.dump(_value))
        )
        Ava.Util.Net.Fire_C('DataSyncS2CEvent', player, _path, _value)
    elseif localPlayer and MetaData.ClientSync then
        --* 客户端 => 服务器（多端），单项同步
        --  Global/Player 两种数据
        PrintLog(
            string.format(
                '[AvaKit][Client] 发出 player = %s, _path = %s, _value = %s',
                localPlayer,
                _path,
                table.dump(_value)
            )
        )
        Ava.Util.Net.Fire_S('DataSyncC2SEvent', localPlayer, _path, _value)
    end
end

--! 公开API

---新建数据
MetaData.New = NewData

---设置数据
MetaData.Set = SetData

---从proxy中生成一个纯数据表格
MetaData.Get = function(_proxy)
    local mt = getmetatable(_proxy)
    Debug.Assert(mt ~= nil, string.format('[AvaKit][MetaData] metatable为空，proxy = %s', table.dump(_proxy)))
    return GetData(mt._data, mt._path)
end

--! 辅助方法

---打印数据同步日志
PrintLog = Config.DebugMode and debugMode and function(...)
        Debug.Log('[AvaKit][MetaData]', ...)
    end or function()
    end

---数据校验
function Validators(func)
    if not valid then
        return function()
        end
    end

    if func == SetData then
        return function(_data, _path, _value, _uid, _sync)
            Debug.Assert(
                _data ~= nil,
                string.format(
                    '[AvaKit][MetaData] data为空 data = %s, path = %s, uid = %s, sync = %s, value = %s',
                    _data,
                    _path,
                    _uid,
                    _sync,
                    table.dump(_value)
                )
            )
            Debug.Assert(
                not string.isnilorempty(_path),
                string.format(
                    '[AvaKit][MetaData] path为空 data = %s, path = %s, uid = %s, sync = %s, value = %s',
                    _data,
                    _path,
                    _uid,
                    _sync,
                    table.dump(_value)
                )
            )
        end
    end
end

return MetaData

--! Command Test only
--[[
Data.Global.a = 11
Data.Global.b = {22, 33}
Data.Global.c = {c1 = {44, 55}, c2 = 66}
Data.Global.c.c3 = {c4 = 77}
Data.Global.d = {'88', Vector3(9,9,9)}
print(table.dump(Data.Global))
print(table.dump(MetaData.Get(Data.Global)))

print(table.dump(Data.Player))

print(table.dump(Data.Players))

print(table.dump(Data.Players['pid:local_1']))
]]
