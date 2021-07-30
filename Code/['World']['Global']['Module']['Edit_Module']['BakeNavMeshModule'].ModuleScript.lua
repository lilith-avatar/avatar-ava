--- @module BakeNavMesh 寻路mesh
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local NavMeshCreate = {}
--local navMeshValue = NavMeshValue or world:CreateObject('StringValueObject', 'NavMeshValue', world.Global)
local astar = require(world.Global.Plugin.AStar.AStarModule)
local LuaJsonUtil = require(Utility.LuaJsonUtilModule)
local sceneConfig = {
    [1001] = {ArchetypeName = 'NukeTown', SceneId = 1001},
    [1002] = {ArchetypeName = 'Flash', SceneId = 1002},
    [1003] = {ArchetypeName = 'Flash', SceneId = 1003},
    [1004] = {ArchetypeName = 'Tojimap1', SceneId = 1004},
    [1005] = {ArchetypeName = 'Tojimap2', SceneId = 1005},
    [1006] = {ArchetypeName = 'NukeTown', SceneId = 1006},
    [1007] = {ArchetypeName = 'Yard', SceneId = 1007},
    [1008] = {ArchetypeName = 'Factory', SceneId = 1008}
}

--- 返回一个方向向量的欧拉角
local function LookRotation(fromDir)
    local eulerAngles = EulerDegree(0, 0, 0)
    eulerAngles.x =
        math.deg(
        math.acos(
            math.sqrt(
                (fromDir.x * fromDir.x + fromDir.z * fromDir.z) /
                    (fromDir.x * fromDir.x + fromDir.y * fromDir.y + fromDir.z * fromDir.z)
            )
        )
    )
    if fromDir.y >= 0 then
        eulerAngles.x = 360 - eulerAngles.x
    end
    eulerAngles.y = math.deg(math.atan(fromDir.x / fromDir.z))
    if eulerAngles.y <= 0 then
        eulerAngles.y = 180 + eulerAngles.y
    end
    if fromDir.x <= 0 then
        eulerAngles.y = 180 + eulerAngles.y
    end
    eulerAngles.z = 0
    return eulerAngles
end

--- 在一个起始点和一个终点之间创建一个圆柱体
---@type fun(_startPos: any, _endPos: any, _name: string)
---@return any
local function CreateLineBetween2Points(_startPos, _endPos, _name)
    local pos = _startPos + _endPos
    pos = pos / 2
    local dir = _endPos - _startPos
    local dis = dir.Magnitude
    local rot = LookRotation(dir)
    local laser = world:CreateInstance(_name, _name, world, pos, rot)
    laser.Laser.Size = Vector3(laser.Laser.Size.x, dis, laser.Laser.Size.z)
    return laser
end

local function keepDecimal(num, n)
    if type(num) ~= 'number' then
        return num
    end
    n = n or 2
    if num < 0 then
        return -(math.abs(num) - math.abs(num) % 0.1 ^ n)
    else
        return num - num % 0.1 ^ n
    end
end

local function keepVectorDecimal(_pos, _num)
    local x = keepDecimal(_pos.x, _num)
    local y = keepDecimal(_pos.y, _num)
    local z = keepDecimal(_pos.z, _num)
    return tostring(x) .. '|' .. tostring(y) .. '|' .. tostring(z)
end
---将数组倒序,不改变原数据
local function table_reverse(_table)
    if type(_table) ~= 'table' then
        return
    end
    local count = #_table
    if count == 0 then
        return
    end
    local res = {}
    for i = 1, count do
        res[i] = _table[count - i + 1]
    end
    return res
end

---根据配置表中配置的导航网格生成,然后保存到指定的节点中
local function CreateNavDataById(_sceneId)
    local sceneObj =
        world:CreateInstance(sceneConfig[_sceneId].ArchetypeName, 'Temp' .. sceneConfig[_sceneId].ArchetypeName, world)
    wait(1)
    if not sceneObj then
        print(sceneConfig[_sceneId].ArchetypeName, '该场景原型不存在')
        return
    end
    if not sceneObj.Navigation then
        print('该场景未配置导航网格', _sceneId)
        sceneObj:Destroy()
        return
    end
    local gridPoints = sceneObj.Navigation.Grid:GetChildren()
    if #gridPoints == 0 then
        print('该场景配置的导航点数量为0', _sceneId)
        sceneObj:Destroy()
        return
    end
    local next = {}
    for i, v in pairs(gridPoints) do
        local disList = {}
        for i1, v1 in pairs(gridPoints) do
            if v1 ~= v then
                local dis = (v1.Position - v.Position).Magnitude
                table.insert(disList, {Obj = v1, Dis = dis})
            end
        end
        table.sort(
            disList,
            function(a, b)
                return a.Dis < b.Dis
            end
        )
        next[v] = {
            disList[1].Obj,
            disList[2].Obj,
            disList[3].Obj,
            disList[4].Obj,
            disList[5].Obj,
            disList[6].Obj,
            disList[7].Obj,
            disList[8].Obj
        }
    end

    local function CheckBlock(_pos1, _pos2)
        if _pos1 == _pos2 then
            return false
        end
        local hitResult = Physics:RaycastAll(_pos1, _pos2, false)
        for i, v in pairs(hitResult.HitObjectAll) do
            if v.Name ~= 'Node' and v.Block and v.Parent and v.Parent.Name ~= 'Door' then
                return true
            end
        end
        return false
    end

    for i, v in pairs(next) do
        for i1, v1 in pairs(v) do
            if CheckBlock(i.Position, v1.Position) then
                next[i][i1] = nil
            else
                if i.Position ~= v1.Position then
                    CreateLineBetween2Points(i.Position, v1.Position, 'Laser').Parent = sceneObj
                end
            end
        end
        wait()
    end
    ---场景导航点的邻接表
    local sceneNavMesh = {}
    for i, v in pairs(next) do
        local info = {
            obj = i,
            canCross = true,
            neighbor = {},
            pos = i.Position,
            x = i.Position.x,
            y = i.Position.z
        }
        sceneNavMesh[i] = info
    end
    for i, v in pairs(sceneNavMesh) do
        for i1, v1 in pairs(next[i]) do
            if v.pos ~= sceneNavMesh[v1].pos then
                table.insert(v.neighbor, sceneNavMesh[v1])
            end
        end
        if v.neighbor == {} then
            sceneNavMesh[i] = nil
        end
    end

    local navCache = {}
    for i, v in pairs(sceneNavMesh) do
        local key1 = keepVectorDecimal(v.pos, 2)
        navCache[key1] = {}
        for i1, v1 in pairs(sceneNavMesh) do
            local key2 = keepVectorDecimal(v1.pos, 2)
            if key2 ~= key1 then
                if navCache[key2] and navCache[key2][key1] then
                    ---已经生成过此路径的逆路径
                    navCache[key1][key2] = table_reverse(navCache[key2][key1])
                else
                    local a_path = astar.path(v, v1, sceneNavMesh, true)
                    local path = {}
                    a_path = a_path or {}
                    for k, p in pairs(a_path) do
                        local posStr = keepVectorDecimal(p.pos, 2)
                        path[k] = posStr
                    end
                    navCache[key1][key2] = path
                end
            end
        end
    end

    local safePointsList = {}
    local safePoint = sceneObj.Navigation.SafePoint
    if safePoint then
        for i, v in pairs(safePoint:GetChildren()) do
            table.insert(safePointsList, keepVectorDecimal(v.Position, 2))
        end
    end

    local info = {}
    info.SceneId = _sceneId
    info.NavMeshData = navCache
    info.SafePoints = safePointsList
    sceneObj:Destroy()
    print('生成数据成功', _sceneId, sceneConfig[_sceneId].ArchetypeName)
    return info
end
-- require(Module.Edit_Module.BakeNavMeshModule).CreateData()
---生成导航网格
function NavMeshCreate.CreateData()
    local navMeshValue = world:CreateObject('StringValueObject', 'NavMeshValue', world)
    local data = {}
    for i, v in pairs(sceneConfig) do
        if v.ArchetypeName ~= '' then
            local info = CreateNavDataById(v.SceneId)
            if info ~= {} then
                table.insert(data, info)
            end
        end
    end
    navMeshValue.Value = LuaJsonUtil:encode(data)
end

return NavMeshCreate
