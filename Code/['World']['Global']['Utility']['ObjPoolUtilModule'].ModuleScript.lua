--- 对象池工具模块
--- @module ObjPoolUtil
--- @copyright Lilith Games, Avatar Team
--- @author Yen Yuan
local ObjPoolUtil = class('ObjPoolUtil')

---创建某一个对象的对象池
---@param _folderName Object 管理的目录
---@param _objName string 对象的Archetype名
---@param _maxCount number 对象池最大上限，不填则为100
---@return ObjPoolUtil
function ObjPoolUtil.static.Newpool(_folderName, _objName, _maxCount)
    if _folderName == nil or _objName == nil then
        error('[ObjPoolUtil] 管理目录或管理对象为空')
    end
    if _maxCount == nil then
        _maxCount = 100
    end
    local realPool = class(_objName .. 'Pool', ObjPoolUtil)
    realPool.static.obj = _objName
    realPool.static.folder = _folderName
    realPool.static.maxCount = _maxCount
    realPool.pool = {}
    print(string.format('[ObjPoolUtil] 创建了一个%s的对象池，目录为%s', _objName, _folderName))
    return realPool
end

---从池中创建对象到世界下
---@param _position Vector3
---@param _rotation EulerDegree
function ObjPoolUtil:Spawn(_position, _rotation)
    local realObj = nil
    if #self.pool == 0 then
        realObj = world:CreateInstance(self.obj, self.obj, self.folder, _position, _rotation)
        if realObj == nil then
            error(string.format('[ObjPoolUtil] Archetype下没有名为%s的对象', self.obj))
            return
        end
        return realObj
    else
        realObj = self.pool[1]
        self.pool[1].Position = _position
        self.pool[1].Rotation = _rotation
        self.pool[1]:SetActive(true)
        table.remove(self.pool, 1)
        return realObj
    end
end

---从世界中销毁对象到池中
---@param _obj Object
function ObjPoolUtil:Despawn(_obj)
    if _obj == nil then
        error('[ObjPoolUtil] 传入对象为空')
    elseif #self.pool > self.maxCount then
        error(string.format('[ObjPoolUtil] %s对象池已满，该对象会永久销毁', self.obj))
        _obj:Destroy()
    else
        table.insert(self.pool, _obj)
        _obj:SetActive(false)
    end
end

return ObjPoolUtil
