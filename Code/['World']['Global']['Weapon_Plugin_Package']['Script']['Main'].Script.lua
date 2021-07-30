--- @script 枪械模块全局脚本
--- @see 用于枪械模块自身的属性的初始化

---插件的根节点
_G.PluginRoot = world.Global.Weapon_Plugin_Package
_G.WeaponMgr = require(PluginRoot.Module.S_Module.WeaponMgrModule)
_G.PlayerGunMgr = require(PluginRoot.Module.C_Module.PlayerGunMgrModule)
_G.WeaponUUID = require(PluginRoot.Module.Tools_Module.WeaponUUIDModule)
_G.TweenController = require(PluginRoot.Module.Tools_Module.TweenControllerModule)
_G.LinkConnects = function(_eventFolder, _module, _this)
    local events = _eventFolder:GetChildren()
    local total = 0
    for _, ent in pairs(events) do
        if ent.Name:sub(-5) == 'Event' then
            local handler = _module[ent.Name .. 'Handler']
            if handler ~= nil then
                ent:Connect(
                    function(...)
                        handler(_this, ...)
                    end
                )
                total = total + 1
            end
        end
    end
end
_G.GunConfig = {}
local preLoad = {
    {
        name = 'Sound', ---音效播放
        csv = 'Sound',
        ids = {'GunId', 'GunEvent'}
    },
    {
        name = 'GunConfig',
        csv = 'GunConfigTable',
        ids = {'Id'}
    },
    {
        name = 'MagazineConfig',
        csv = 'MagazineTable',
        ids = {'Id'}
    },
    {
        name = 'GunRecoilConfig',
        csv = 'GunRecoilTable',
        ids = {'Id'}
    },
    {
        name = 'AmmoConfig',
        csv = 'AmmoTable',
        ids = {'Id'}
    },
    {
        name = 'GunAnimationConfig',
        csv = 'GunAnimationTable',
        ids = {'GunId', 'GunEvent'}
    },
    {
        name = 'WeaponAccessoryConfig',
        csv = 'WeaponAccessoryTable',
        ids = {'Id'}
    },
    {
        name = 'SpawnConfig',
        csv = 'SpawnTable',
        ids = {'Id'}
    },
    {
        name = 'AssistAim',
        csv = 'AssistAim',
        ids = {'Id'}
    },
    {
        name = 'GunCacheConfig',
        csv = 'GunCacheConfig',
        ids = {'GunId'}
    }
}
---字符串切割函数
function _G.StringSplit(input, delimiter, isNumber)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if delimiter == '' or input == '' then
        return {}
    end
    local pos, arr = 0, {}
    -- for each divider found
    for st, sp in function()
        return string.find(input, delimiter, pos, true)
    end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    if isNumber == true then
        for k, v in pairs(arr) do
            arr[k] = tonumber(v)
        end
    end
    return arr
end

---最小数值和最大数值指定返回值的范围。
function _G.Clamp(v, minValue, maxValue)
    if v < minValue then
        return minValue
    end
    if (v > maxValue) then
        return maxValue
    end
    return v
end

---输出三倍标准差为1 的分布在（-1， 1）之间的正态分布
---@param _isSeeded是否具有最新的随机种子
function _G.GaussRandom(_isSeeded)
    if (not _isSeeded) then
        math.randomseed(Timer.GetTime() * 10000)
    end
    local u = math.random()
    local v = math.random()
    local z = math.sqrt(-2 * math.log(u)) * math.cos(2 * math.pi * v)
    z = (z + 3) / 6
    z = 2 * z - 1
    if (math.abs(z) > 1) then
        return GaussRandom(true)
    end
    return z
end

---窗函数，在小于A时保持原值，在大于A时逐渐趋近于1
function _G.Asymptote(x, A)
    A = A or 0.4
    if (A <= 0 or A >= 1) then
        error('A should be in good range')
    end
    if (x < 0) then
        error('x should be positive')
    end
    if (x <= A) then
        return x
    end
    return 1 + (3 * A * A - 2 * A) / x + (A * A - 2 * A * A * A) / x / x
end

---双边可用的窗函数(普通窗函数的奇延拓)
function _G.AsymtoteBi(x, A)
    A = A or 0.4
    if (A <= 0 or A >= 1) then
        error('A should be in good range')
    end
    if (x >= 0) then
        return Asymptote(x, A)
    end
    return -Asymptote(-x, A)
end

---输入一个方向和一个最大扩散角，
---输出以该方向为中心轴，角度为半顶角的圆锥的底面上的一个点（高斯分布）
function _G.RandomRotate(_dir, _difAngle)
    local axis1 = Vector3.Cross(_dir, Vector3(1, 1, 1)).Normalized
    ---由于中心对称，第一根轴随意取
    local axis2 = Vector3.Cross(_dir, axis1)
    ---现在有 _dir = axis1 × axis2
    return (_dir:Rotate(axis1, _difAngle * GaussRandom(true))):Rotate(axis2, _difAngle * GaussRandom(true))
end

---输入一个物体，输出它所属的玩家，可用于判断碰撞
---如果是玩家的一部分则输出玩家实例，否则输出nil
function _G.ParentPlayer(_obj)
    --[[if _obj.Parent.Name == 'StaticSpace' or _obj.Parent.Parent.Name == 'StaticSpace' or _obj.Parent.Parent.Parent.Name == 'StaticSpace' then
        return
    end]]
    if checkStaticSpace(_obj) then
        return
    end
    if _obj.ClassName == 'PlayerInstance' then
        return _obj
    end
    return _obj:FindNearestAncestorOfType('PlayerInstance')
end

function _G.ClearTable(_table, _notDestroyKey)
    if type(_table) ~= 'table' then
        return
    end
    _notDestroyKey = _notDestroyKey and _notDestroyKey or {}
    for k, v in pairs(_table) do
        local notDestroy = false
        for k1, v1 in pairs(_notDestroyKey) do
            if v1 == k then
                notDestroy = true
            end
        end
        if not notDestroy then
            _table[k] = nil
        end
    end
end

function _G.BlendColor(_color1, _color2)
    local blender = function(_x, _y)
        return _x * _y / 255
    end
    return Color(
        blender(_color1.r, _color2.r),
        blender(_color1.g, _color2.g),
        blender(_color1.b, _color2.b),
        blender(_color1.a, _color2.a)
    )
end

---用于加速滑动
function _G.AccelerateScalar(x, _linearRange, _maxScale)
    if (_maxScale <= 1 or _linearRange <= 0) then
        error('最大比例必须大于1, 线性范围必须大于0')
    end
    if (x < 0) then
        error('使用双边的函数以支持负值')
    end
    if (x <= _linearRange) then
        return 1
    elseif (x >= _maxScale * _linearRange) then
        return _maxScale
    else
        return 1 / _linearRange * x
    end
end

---支持负值的加速滑动
function _G.BiAccelerateScalar(x, _linearRange, _maxScale)
    local sign = x >= 0 and 1 or -1
    return AccelerateScalar(sign * x, _linearRange, _maxScale)
end

function _G.MergeTables(...)
    local tabs = {...}
    if not tabs then
        return {}
    end
    local origin = {}
    for k, v in pairs(tabs[1]) do
        origin[k] = v
    end
    for i = 2, #tabs do
        if origin then
            if tabs[i] then
                for k, v in pairs(tabs[i]) do
                    table.insert(origin, v)
                end
            end
        else
            origin = tabs[i]
        end
    end
    return origin
end

function _G.RandomNum(n, m)
    math.randomseed(os.time())
    return math.random(n, m)
end

--- 遍历表格，确保其中的值唯一
--- @function [parent=#table] unique
--- @param t table 表格
--- @param bArray boolean t是否是数组,是数组,t中重复的项被移除后,后续的项会前移
--- @return table #table  包含所有唯一值的新表格
function _G.TableUnique(t, bArray)
    local check = {}
    local n = {}
    local idx = 1
    for k, v in pairs(t) do
        if not check[v] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[v] = true
        end
    end
    return n
end

--- 镜头抖动
--- @param _strength number 抖动幅度
--- @param _time number 持续时间
function _G.CameraShake(_strength, _time)
    CameraControl:CameraShake(_strength, _time)
end

---用的tween的函数
function _G.Shake(_strength)
    return _strength * (math.random() - 0.5)
end

--- 保留n位小数
function _G.keepDecimal(num, n)
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

---计算抛物线
---@param _startPoint Vector3 发射的初始点
---@param _startVec Vector3 发射的初始速度
---@param _length number 抛物线上的点的个数
---@param _dt number 相邻点的距离
function _G.GenerateCurve(_startPoint, _startVec, _length, _dt, _gravity)
    _gravity = _gravity or 1
    local curve = {}
    for i = 1, _length do
        local PosX = Vector2(_startPoint.x, _startPoint.z) + Vector2(_startVec.x, _startVec.z) * _dt * i
        local PosY = _startVec.y * _dt * i - 0.5 * 9.8 * _gravity * (_dt * i) * (_dt * i) + _startPoint.y
        table.insert(curve, Vector3(PosX.x, PosY, PosX.y))
    end
    return curve
end

local function GetCsvInfo(_csv, ...)
    local rawTable = _csv:GetRows()
    local ids = {...}
    if #ids < 1 or (#ids == 1 and ids[1] == 'Type') then
        return rawTable
    end
    local result = {}
    local tmp = result
    local key, id
    for _, v in pairs(rawTable) do
        tmp = result
        for i = 1, #ids do
            id = ids[i]
            key = v[id]
            if key == nil or key == '' then
                error(string.format('CSV表格没有找到此id, CSV:%s, id: %s', _csv.Name, id))
            end
            if i == #ids then
                -- 最后的键，确定唯一性
                if tmp[key] ~= nil then
                    error(string.format('CSV数据重复, ids不是唯一的, CSV: %s, ids: %s', _csv.Name, tostring(...)))
                else
                    tmp[key] = v
                end
            else
                -- 多键，之后还有
                if tmp[key] == nil then
                    tmp[key] = {}
                end
                tmp = tmp[key]
            end
        end
    end
    return result
end

---读取枪械的全局配置
local function GetGlobalCsvInfo()
    local tmpList = PluginRoot.Csv.GlobalConfig:GetRows()
    local result = {}
    for i, v in pairs(tmpList) do
        if v.Key == '' or v.Type == '' then
            goto Continue
        end
        if v.Type == 'Int' then
            result[v.Key] = tonumber(v.Value)
        elseif v.Type == 'Boolean' then
            if v.Value == 'TRUE' then
                result[v.Key] = true
            elseif v.Value == 'FALSE' then
                result[v.Key] = false
            else
                print('请检查全局配置表中键为', v.Key, '的配置项')
            end
        elseif v.Type == 'Float' then
            result[v.Key] = tonumber(v.Value)
        elseif v.Type == 'String' then
            result[v.Key] = v.Value
        elseif v.Type == 'Vector2' then
            result[v.Key] = Vector2(tonumber(StringSplit(v.Value, ',')[1]), tonumber(StringSplit(v.Value, ',')[2]))
        elseif v.Type == 'Vector3' then
            result[v.Key] =
                Vector3(
                tonumber(StringSplit(v.Value, ',')[1]),
                tonumber(StringSplit(v.Value, ',')[2]),
                tonumber(StringSplit(v.Value, ',')[3])
            )
        elseif v.Type == 'Euler' then
            result[v.Key] =
                EulerDegree(
                tonumber(StringSplit(v.Value, ',')[1]),
                tonumber(StringSplit(v.Value, ',')[2]),
                tonumber(StringSplit(v.Value, ',')[3])
            )
        elseif v.Type == 'Color' then
            result[v.Key] =
                Color(
                tonumber(StringSplit(v.Value, ',')[1]),
                tonumber(StringSplit(v.Value, ',')[2]),
                tonumber(StringSplit(v.Value, ',')[3]),
                tonumber(StringSplit(v.Value, ',')[4])
            )
        else
            print('请检查全局配置表中键为', v.Key, '的配置项')
        end
        ::Continue::
    end
    return result
end

---读表工具
local function PreloadCsv()
    for _, pl in pairs(preLoad) do
        if pl.csv ~= '' and pl.csv ~= nil and #pl.ids > 0 then
            GunConfig[pl.name] = GetCsvInfo(PluginRoot.Csv[pl.csv], table.unpack(pl.ids))
        end
    end
    GunConfig.GlobalConfig = GetGlobalCsvInfo()
end

PreloadCsv()

---枪械类
_G.GunModeEnum = {
    SniperRifle = 1, ---狙击枪
    AssaultRifle = 2, ---突击步枪
    SubMachineGun = 3, ---冲锋枪
    ShotGun = 4, ---霰弹枪
    Pistol = 5, ---手枪
    MeleeWeapon = 6, ---近战武器
    ThrownWeapon = 7, ---投掷武器
    RocketLauncher = 8, ---火箭筒
    Other = 9, ---其他武器
    TrailingGun = 10 --追踪武器
}

---枪械击中玩家的部位枚举
_G.HitPartEnum = {
    None = 0, ---无特殊命中(一般为爆炸)
    Head = 1, ---命中头部
    Body = 2, ---命中躯干
    Limb = 3, ---命中四肢
    Fort = 4 ---命中炮台
}

---枪械开火模式
_G.FireModeEnum = {
    Auto = 1, ---全自动
    Rapidly_1 = 2, ---连发模式1
    Rapidly_2 = 3, ---连发模式2
    Single = 4 ---单发
}

---枪械的散射函数
_G.DiffuseFunctionEnum = {
    Linear = 1, ---线性函数
    Sqrt = 2, ---0.5次方
    Square = 3 ---2次方
}

---枪械可被装备的位置
_G.CanBeEquipPositionEnum = {
    MainOrDeputy = 1, ---主枪或者副枪
    Mini = 2, ---手枪
    Prop = 3 ---道具
}

---枪械配件类型
_G.WeaponAccessoryTypeEnum = {
    Muzzle = 1, ---枪口
    Grip = 2, ---握把
    Magazine = 3, ---弹夹
    Butt = 4, ---枪托
    Sight = 5 ---瞄准镜
}

---刷新的对象的类型
_G.UnitTypeEnum = {
    Weapon = 1,
    Accessory = 2,
    Ammo = 3
}

---激活的对象类型
_G.ObjectTypeEnum = {
    Hole = 1,
    FireEff = 2,
    HitEff = 3,
    Shell = 4,
    Sound = 5
}

---图片资源大小
_G.ImgSize = {
    Img_Crosshair_1x_RPG = Vector2(230, 230),
    Img_Notch_Wide = Vector2(8001, 3126) / 5,
    Img_Scope_4x = Vector2(880, 840),
    Img_Scope_De = Vector2(2000, 1870),
    Img_Notch_Narrow = Vector2(5559, 3125) / 5,
    Img_Scope_1x = Vector2(1546 / 1.1, 1460),
    Img_RedDot = Vector2(550, 550),
    Img_Panel_4x = Vector2(450, 450),
    Img_Crosshair_2x = Vector2(560, 560),
    Img_Crosshair_4x = Vector2(560, 560),
    Img_Crosshair_4x_ak = Vector2(560, 560),
    Img_Crosshair_3x = Vector2(560, 560),
    Img_Crosshair_6x = Vector2(560, 560),
    Img_Crosshair_8x = Vector2(560, 560),
    Img_Crosshair_15x = Vector2(560, 560),
    Img_Transparent = Vector2(560, 560),
    Img_Transparent2 = Vector2(560, 560) / 1.5,
    Img_Holograph = Vector2(550, 550),
    Img_Holograph_Red = Vector2(550, 550)
}

---玩家当前动作模式
_G.PlayerActionModeEnum = {
    Run = 1, ---正常跑
    QuicklyRun = 2, ---快跑
    AimRun = 3, ---开镜移动
    CrouchRun = 4, ---下蹲正常跑
    QuicklyCrouchRun = 5, ---下蹲快跑
    AimCrouchRun = 6 ---开镜蹲移动
}
