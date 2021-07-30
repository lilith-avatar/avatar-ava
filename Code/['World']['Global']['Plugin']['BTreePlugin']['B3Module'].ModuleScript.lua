--- @module B3
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
B3 = {
    VERSION = '0.2.0',
    --Returning status
    SUCCESS = 1,
    FAILURE = 2,
    RUNNING = 3,
    ERROR = 4,
    --Node categories
    COMPOSITE = 'composite',
    DECORATOR = 'decorator',
    ACTION = 'action',
    CONDITION = 'condition'
}

B3.createUUID = function()
    local seed = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'}
    local tb = {}
    for i = 1, 32 do
        table.insert(tb, seed[math.random(1, 16)])
    end
    return table.concat(tb)
end

B3.Class = function(classname, super)
    local superType = type(super)
    local cls

    --如果父类既不是函数也不是table则说明父类为空
    if superType ~= 'function' and superType ~= 'table' then
        superType = nil
        super = nil
    end

    --如果父类的类型是函数或者是C对象
    if superType == 'function' or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        --如果父类是表则复制成员并且设置这个类的继承信息
        --如果是函数类型则设置构造方法并且设置ctor函数
        if superType == 'table' then
            -- copy fields from super
            for k, v in pairs(super) do
                cls[k] = v
            end
            cls.__create = super.__create
            cls.super = super
        else
            cls.__create = super
            cls.ctor = function()
            end
        end

        --设置类型的名称
        cls.__cname = classname
        cls.__ctype = 1

        --定义该类型的创建实例的函数为基类的构造函数后复制到子类实例
        --并且调用子数的ctor方法
        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k, v in pairs(cls) do
                instance[k] = v
            end
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    else
        --如果是继承自普通的lua表,则设置一下原型，并且构造实例后也会调用ctor方法
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, {__index = super})
            cls.super = super
        else
            cls = {
                ctor = function()
                end
            }
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

B3.decodeJson = function(str)
    return JSON:decode(str)
end

----------------Tick--------------------------
---@class tick
local tick = B3.Class('Tick')
B3.Tick = tick

function tick:ctor()
    self.tree = nil
    self.debug = nil
    self.target = nil
    self.blackboard = nil

    self._openNodes = {}
    self._nodeCount = 0
end

function tick:_enterNode(node)
    self._nodeCount = self._nodeCount + 1
    table.insert(self._openNodes, node)
end

function tick:_openNode(node)
end

function tick:_tickNode(node)
end

function tick:_closeNode(node)
end

function tick:_exitNode(node)
end

----------------BaseNode----------------------
---@class BaseNode
local baseNode = B3.Class('BaseNode')
B3.BaseNode = baseNode

function baseNode:ctor(params)
    self.id = B3.createUUID()
    self.name = ''
    self.title = self.title or self.name
    self.description = ''
    self.parameters = {}
    self.properties = {}
end

function baseNode:_execute(tick)
    --ENTER
    self:_enter(tick)

    --OPEN
    if not (tick.blackboard:get('isOpen', tick.tree.id, self.id)) then
        self:_open(tick)
    end

    --TICK
    local status = self:_tick(tick)

    --CLOSE
    if status ~= B3.RUNNING then
        self:_close(tick)
    end

    --EXIT
    self:_exit(tick)

    return status
end

function baseNode:_enter(tick)
    tick:_enterNode(self)
    self:enter(tick)
end

function baseNode:_open(tick)
    tick:_openNode(self)
    tick.blackboard:set('isOpen', true, tick.tree.id, self.id)
    self:open(tick)
end

function baseNode:_tick(tick)
    tick:_tickNode(self)
    return self:tick(tick)
end

function baseNode:_close(tick)
    tick:_closeNode(self)
    tick.blackboard:set('isOpen', false, tick.tree.id, self.id)
    self:close(tick)
end

function baseNode:_exit(tick)
    tick:_exitNode(self)
    self:exit(tick)
end

function baseNode:enter(tick)
end

function baseNode:open(tick)
end

function baseNode:tick(tick)
end

function baseNode:close(tick)
end

function baseNode:exit(tick)
end

------------------Blackboard------------------------
---@class Blackboard
local blackboard = B3.Class('Blackboard')
B3.Blackboard = blackboard

function blackboard:ctor()
    self._baseMemory = {}
    self._treeMemory = {}
end

function blackboard:_getTreeMemory(treeScope)
    if not self._treeMemory[treeScope] then
        self._treeMemory[treeScope] = {nodeMemory = {}, openNodes = {}, traversalDepth = 0, traversalCycle = 0}
    end
    return self._treeMemory[treeScope]
end

function blackboard:_getNodeMemory(treeMemory, nodeScope)
    local memory = treeMemory.nodeMemory

    if not memory then
        memory = {}
    end

    if memory and not memory[nodeScope] then
        memory[nodeScope] = {}
    end

    return memory[nodeScope]
end

function blackboard:_getMemory(treeScope, nodeScope)
    local memory = self._baseMemory

    if treeScope then
        memory = self:_getTreeMemory(treeScope)

        if nodeScope then
            memory = self:_getNodeMemory(memory, nodeScope)
        end
    end

    return memory
end

function blackboard:set(key, value, treeScope, nodeScope)
    local memory = self:_getMemory(treeScope, nodeScope)
    memory[key] = value
end

function blackboard:get(key, treeScope, nodeScope)
    local memory = self:_getMemory(treeScope, nodeScope)
    if memory then
        return memory[key]
    end
    return {}
end

------------BehaviorTree-----------------------------
---@class BehaviorTree
local behaviorTree = B3.Class('BehaviorTree')
B3.BehaviorTree = behaviorTree

function behaviorTree:ctor()
    self.id = B3.createUUID()
    self.title = 'The behavior tree'
    self.description = 'Default description'
    self.properties = {}
    self.root = nil
    self.debug = nil
end

function behaviorTree:load(jsonData, names)
    names = names or {}
    local data = JSON:decode(jsonData)

    self.title = data.title or self.title
    self.description = data.description or self.description
    self.properties = data.properties or self.properties

    local nodes = {}
    local id, spec, node

    for i, v in pairs(data.nodes) do
        id = i
        spec = v
        local Cls

        if names[spec.name] then
            Cls = names[spec.name]
        elseif B3[spec.name] then
            Cls = B3[spec.name]
        else
            print('Error : BehaviorTree.load : Invalid node name + ' .. spec.name .. '.')
        end
        --node = Cls.new(spec.properties)
        node = Cls.new()
        node.id = spec.id or node.id
        node.title = spec.title or node.title
        node.description = spec.description or node.description
        node.properties = spec.properties or node.proerties
        nodes[id] = node
    end

    for i, v in pairs(data.nodes) do
        id = i
        spec = v
        node = nodes[id]
        --print(i,v)
        if v.child then
            node.child = nodes[v.child]
        end

        if v.children then
            for i = 1, #v.children do
                local cid = spec.children[i]
                --print("{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{")
                --print(spec.children[i],nodes[cid])
                table.insert(node.children, nodes[cid])
            end
        end
    end

    self.root = nodes[data.root]
end

function behaviorTree:dump()
    local data = {}
    local customNames = {}

    data.title = self.title
    data.description = self.description
    if self.root then
        data.root = self.root.id
    else
        data.root = nil
    end
    data.properties = self.properties
    data.nodes = {}
    data.custom_nodes = {}

    if self.root then
        return data
    end

    --TODO:
end

function behaviorTree:tick(target, blackboard)
    if not blackboard then
        print('The blackboard parameter is obligatory and must be an instance of B3.Blackboard')
    end
    if not self.root then
        return
    end
    local tick = B3.Tick.new()
    tick.debug = self.debug
    tick.target = target
    tick.blackboard = blackboard
    tick.tree = self

    --TICK NODE
    local state = self.root:_execute(tick)

    --CLOSE NODES FROM LAST TICK, IF NEEDED
    local lastOpenNodes = blackboard:get('openNodes', self.id)
    local currOpenNodes = tick._openNodes[0]
    if not lastOpenNodes then
        lastOpenNodes = {}
    end

    if not currOpenNodes then
        currOpenNodes = {}
    end

    local start = 0
    local i
    for i = 0, math.min(#lastOpenNodes, #currOpenNodes) do
        start = i + 1
        if lastOpenNodes[i] ~= currOpenNodes[i] then
            break
        end
    end

    for i = #lastOpenNodes, 0, -1 do
        if lastOpenNodes[i] then
            lastOpenNodes[i]:_close(tick)
        end
    end

    blackboard:set('openNodes', currOpenNodes, self.id)
    blackboard:set('nodeCount', tick._nodeCount, self.id)
end

return B3
