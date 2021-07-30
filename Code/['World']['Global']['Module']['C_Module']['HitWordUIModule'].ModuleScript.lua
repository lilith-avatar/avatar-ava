--- @module HitWordUI 伤害飘字模块
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local HitWordUI, this = ModuleUtil.New('HitWordUI', ClientBase)

local headColor = Color(255, 0, 0, 255)
local otherColor = Color(227, 213, 125, 255)
local showFlame = 40

--- 初始化
function HitWordUI:Init()
    self.root = world:CreateInstance('HitWordUI', 'HitWordUI', localPlayer.Local)
    self.root.Order = 400
    self.wordList = {}
    ---可使用的缓存
    self.usableList = {}
    ---使用中的缓存
    self.usingList = {}

    self:CreateCache()
end

--- Update函数
--- @param dt number delta time 每帧时间
function HitWordUI:Update(dt, tt)
end

--- 游戏开始
function HitWordUI:GameStartEventHandler()
    self.root:SetActive(true)
    for i, v in pairs(self.wordList) do
        if not v.UI:IsNull() then
            self:RecycleCache(v.UI)
        end
    end
    self.wordList = {}
end

--- 游戏结束
function HitWordUI:GameOverEventHandler()
    self.root:SetActive(false)
    for i, v in pairs(self.wordList) do
        if not v.UI:IsNull() then
            self:RecycleCache(v.UI)
        end
    end
    self.wordList = {}
end

function HitWordUI:FixUpdate(_dt)
    for i, v in pairs(self.wordList) do
        local index = v.Index
        local ui = v.UI
        local pos = v.Pos[index]
        local size = v.FontSize[index]
        ---更新动画
        ui.AnchorsX = Vector2(pos.x, pos.x)
        ui.AnchorsY = Vector2(pos.y, pos.y)
        ui.FontSize = size
        v.Index = index + 1
        if not v.Pos[index + 1] then
            ---到最后一帧的动画
            self:RecycleCache(v.UI)
            self.wordList[i] = nil
        end
    end
end

---在指定的位置显示伤害飘字
---@param _content number 飘字内容
---@param _pos Vector3 世界中的坐标
---@param _type number 命中类型
function HitWordUI:Show(_content, _pos, _type)
	--WorldToViewportPoint()世界坐标转视口坐标
    local screenPos = world.CurrentCamera:WorldToViewportPoint(_pos)
    if screenPos.z < 0 then
        return
    end
	--math.floor()向下取整
    _content = math.floor(_content)
	--飘字ui显示尺寸
    local startSize = 30
    local ui = self:UseCache()
	--飘字ui内容设置为向下取整的伤害值
    ui.Text = tostring(_content)
	--判定命中类型
    if _type == HitPartEnum.Head then
        ---爆头命中
		--ui修改为头部颜色，尺寸设置为40
        ui.Color = headColor
        startSize = 40
    else
        ---非爆头命中
        ui.Color = otherColor
        startSize = 30
    end
    local info = {}
    info.UI = ui
	--设置ui的位置等信息
    local pos = Vector2(screenPos.x, screenPos.y)
    local x = math.random() * 0.2 - 0.1
    local y = math.random() * 0.1 + 0.4
    info.Pos = self:GenerateCurve(pos, Vector2(x, y), showFlame)
    info.FontSize = self:CalculateSize(startSize, showFlame)
    info.Index = 1
    table.insert(self.wordList, info)
end

---创建若干飘字对象,缓存下来以备使用
function HitWordUI:CreateCache()
    for i = 1, showFlame do
        local cache = world:CreateInstance('HitWordContent', 'HitWordContent', self.root)
        self.usableList[i] = cache
        --cache:SetActive(false)
        cache.AnchorsX = Vector2.One * 10
        cache.AnchorsY = Vector2.One * 10
    end
end

---使用缓存中的飘字
function HitWordUI:UseCache()
    local cache = self.usableList[1]
    if not cache then
        ---可使用的缓存中么有了
        cache = world:CreateInstance('HitWordContent', 'HitWordContent', self.root)
    else
        ---可使用的缓存中有,需要移除
        table.remove(self.usableList, 1)
    end
    table.insert(self.usingList, cache)
    --cache:SetActive(true)
    return cache
end

---回收使用完毕的飘字
function HitWordUI:RecycleCache(_cache)
    --_cache:SetActive(false)
    _cache.AnchorsX = Vector2.One * 10
    _cache.AnchorsY = Vector2.One * 10
    table.removebyvalue(self.usingList, _cache)
    table.insert(self.usableList, _cache)
    table.unique(self.usableList)
end

function HitWordUI:GenerateCurve(_startPoint, _startVec, _length)
    local dt = 1 / 60
    local curve = {}
    local G = math.random() * 0.1 + 0.6
    for i = 1, _length do
        local x = _startPoint.x + _startVec.x * dt * i
        local y = _startVec.y * dt * i - 0.5 * G * (dt * i) * (dt * i) + _startPoint.y
        G = G * 0.99
        _startVec = Vector2(_startVec.x * 1.01, _startVec.y * 0.98)
        table.insert(curve, Vector2(x, y))
    end
    return curve
end

function HitWordUI:CalculateSize(_start, _length)
    local max = _start * 3
    local maxR = 0.3
    local maxIndex = math.floor(_length * maxR)
    local add = (max - _start) / maxIndex
    local reduce = (max - _start) / (_length - maxIndex)
    local res = {}
    res[1] = _start
    for i = 2, _length do
        if i < maxIndex then
            res[i] = res[i - 1] + add
        else
            res[i] = res[i - 1] - reduce
        end
    end
    for i, v in pairs(res) do
        res[i] = math.floor(v)
    end
    return res
end

return HitWordUI
