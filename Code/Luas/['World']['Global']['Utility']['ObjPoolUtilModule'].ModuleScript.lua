---对象池工具模块
---@module ObjPoolUtil
-- @copyright Lilith Games, Avatar Team
-- @author Yen Yuan
---@class ObjPoolUtil
local ObjPoolUtil = class('ObjPoolUtil')

---创建某一个对象的对象池
---@param _folderName Object
---@param _obj string
---@param _maxCount number
---@return ObjPoolUtil
function ObjPoolUtil.static.Newpool(_folderName, _objName,_maxCount)
    local realPool = class(_objName..'Pool',ObjPoolUtil)
    realPool.static.obj = _objName
    realPool.static.folder = _folderName
    realPool.static.maxCount = _maxCount
    realPool.pool = {}
    debug('创建了一个',_objName,'的对象池，目录为',tostring(_folderName))
    return realPool
end

---从池中创建对象到世界下
---@param _instanceName string 想要在世界下创建的名称
---@param _position Vector3
---@param _rotation EulerDegree
function ObjPoolUtil:Create(_instanceName, _position, _rotation)
    if #self.pool == 0 then
        world:CreateInstance(self.obj, _instanceName, self.folder, _position,_rotation)
    else
        self.pool[1].Name = _instanceName
        self.pool[1].Position = _position
        self.pool[1].Rotation = _rotation
        self.pool[1]:SetActive(true)
        table.remove(self.pool,1)
    end
end

---从世界中销毁对象到池中
---@param _obj Object
function ObjPoolUtil:Destroy(_obj)
	print(_obj)
    if #self.pool > self.maxCount then
        warn(self.obj..'对象池已满，该对象会永久销毁')
        _obj:Destroy()
    else
        table.insert(self.pool,_obj)
        _obj:SetActive(false)
    end
end

return ObjPoolUtil