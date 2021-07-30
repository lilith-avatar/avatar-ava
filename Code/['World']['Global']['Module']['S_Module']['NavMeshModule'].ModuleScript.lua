--- @module NavMesh 服务端导航网格生成工具,会在玩法开始时候生成对应场景的导航网格
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local NavMesh, this = ModuleUtil.New('NavMesh', ServerBase)

--- 初始化
function NavMesh:Init()
    ---场景导航网格列表,Key - 场景ID, value - { key1:起始点坐标,key2:目标点坐标, value: 路径坐标列表}
    self.navMeshList = {}
    self:CreateNavMesh()
end

--- Update函数
--- @param dt number delta time 每帧时间
function NavMesh:Update(dt, tt)
end

---根据Json字符串生成table
function NavMesh:CreateNavMesh()
    print('根据Json字符串生成table')
    local jsonTable = LuaJsonUtil:decode(NavMeshValue.Value)
    print('Json转化完成')
    if type(jsonTable) ~= 'table' then
        return
    end
    for i, v in pairs(jsonTable) do
        --[[local navMeshData = {}
        ---将表中的字符串数据转为坐标
        for i1, v1 in pairs(v.NavMeshData) do
            for i2, v2 in pairs(v1) do
                table.map(v2, self.ConvertStr2Pos)
            end
        end
        for i1, v1 in pairs(v.NavMeshData) do
            local info = {}
            for i2, v2 in pairs(v1) do
                info[self.ConvertStr2Pos(i2)] = v2
            end
            navMeshData[self.ConvertStr2Pos(i1)] = info
        end
        table.map(v.SafePoints, self.ConvertStr2Pos)
        v.NavMeshData = navMeshData]]
        self.navMeshList[v.SceneId] = v
    end
    for i, v in pairs(self.navMeshList) do
        --printTable(v.SafePoints)
    end
end

---检查两个点之间是否可以通过
function NavMesh:CheckBlock(_pos1, _pos2)
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

---将字符串转为坐标
function NavMesh.ConvertStr2Pos(_str)
    local tmp = string.split(_str, '|', true)
    return Vector3(tmp[1], tmp[2], tmp[3])
end

---将坐标转为字符串,保留两位小数,用 | 隔开
function NavMesh.ConvertPos2Str(_pos)
    local x = keepDecimal(_pos.x, _num)
    local y = keepDecimal(_pos.y, _num)
    local z = keepDecimal(_pos.z, _num)
    return tostring(x) .. '|' .. tostring(y) .. '|' .. tostring(z)
end

return NavMesh
