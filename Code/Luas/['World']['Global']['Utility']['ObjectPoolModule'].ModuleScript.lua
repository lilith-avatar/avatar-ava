---通用对象池
---@module ObjectPool
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local ObjectPool = class('ObjectPool')

---创建一个对象池
---@param _folder Object
---@param _obj string
---@param _maxCount number
---@return ObjectPool
function ObjectPool:New(_folder,_obj, _maxCount)
    if _obj == nil or _maxCount == nil then
        error('对象池创建参数不能为空')
        return
    end
    info('创建一个 %s 对象池' , _obj)
    self.table = {}
    self.static.obj = tostring(_obj)
    self.static.MAXCOUNT = _maxCount
    self.static.Folder = _folder
    return self
end

---将对象加入到对象池中
---@param _obj Object
---@return boolean
function ObjectPool:Push(_obj)
    if _obj.ClassName ~= self.obj.ClassName then
        error('[消息] 不是管理该类型对象的对象池')
    elseif #self.table < self.MAXCOUNT then
        table.insert(self.table,_obj)
        return true
    else
        error(self.obj..'对象池超过上限了')
        return false
    end
end

---从对象池中取出一个对象
---@return Object
function ObjectPool:Pop()
    if #self.table > 0 then
        local obj = self.table[1]
        table.remove(self.table,1)
        return obj
    else
        return self.obj
    end
end

---请在服务端使用，从对象池在world下创建一个对象
---@param _position Vector3
---@param _rotation EulerDegree
function ObjectPool:Create(_position, _rotation)
    if _position == nil then
        error(self.obj..'坐标不能为空')
        return
    elseif _rotation == nil then
        error(self.obj..'角度不能为空')
    else
        local _obj = self:Pop()
        if type(_obj) == 'string' then
            world:CreateInstance(_obj, _obj, self.Folder,_position,_rotation)
        elseif type(_obj) == 'userdata' then
            _obj.Position = _position
            _obj.Rotation = _rotation
            _obj:SetActive(true)
        end
    end
end

---请在服务端使用，从世界中摧毁一个对象，放入到对象池中
---@param _obj Object
function ObjectPool:Destroy(_obj)
    if _obj == nil then
        error('收到空对象')
        return
    elseif _obj:IsA('userdata') then
        local result = self:Push(_obj)
        if result then
            _obj:SetActive(false)
            return
        else
            _obj:Destroy()
            return
        end
    end
end

---清除对象池
function ObjectPool:ClearAll()
    table.cleartable(self.table)
end

---打印对象池字符串
function ObjectPool:__tostring()
    info('['..self.obj..'] 对象池中目前有'..#self.table..'个对象 ，对象池上限为： '..self.MAXCOUNT)
end

return ObjectPool