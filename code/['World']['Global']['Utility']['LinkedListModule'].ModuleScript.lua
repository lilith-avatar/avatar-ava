--- C# 双向链表
-- @module C# doubly linked list implemented with lua
-- @copyright Lilith Games, Avatar Team
-- @author Bruce Chen
-- @see https://wiki.lilithgames.com/x/7yRZAg
-- @see https://github.com/BruceCheng1995/LuaLinkedList

local LinkedList = {}
local LinkedNode = {}
LinkedNode.__index = LinkedNode

local NativePrint = print
local EmptuFunc = function()
end
--是否开放内部日志
function LinkedList:EnableLog(_enable)
    if _enable then
        print = NativePrint
    else
        print = EmptuFunc
    end
end
LinkedList:EnableLog(false)
--新建节点
function LinkedNode:new(value, list)
    local o = {}
    setmetatable(o, self)
    o.List = list
    o.Next = nil
    o.Prev = nil
    o.Value = value
    return o
end
--克隆这个节点
function LinkedNode:Clone()
    return LinkedNode:new(self.Value, nil)
end
--节点失效
function LinkedNode:Invalidate()
    self.Next = nil
    self.Prev = nil
    self.List = nil
end
--打印
function LinkedNode:tostring()
    return tostring(self.Value)
end
LinkedNode.__tostring = LinkedNode.tostring

--验证新节点是否是自由节点
function LinkedList:ValidateNewNode(node)
    if not node then
        return false
    end
    --assert(LinkedNode:include(node),"instance of LinkedNode needed.")
    if node.List ~= nil then
        return false
    end
    return true
end

--验证该节点是否是属于该表
function LinkedList:ValidateNode(node)
    if not node then
        return false
    end
    --assert(LinkedNode:include(node),"instance of LinkedNode needed.")
    if node.List ~= self then
        return false
    end
    return true
end

--将节点插入到node节点之前(list:链表,node:插在这个节点前面,newnode:被插入的节点)
local function InternalInsertNodeBefore(list, node, newnode)
    newnode.Next = node
    newnode.Prev = node.Prev
    node.Prev.Next = newnode
    node.Prev = newnode
    list.Count = list.Count + 1
end

--将节点插入到一个空链表之前(list:链表,newnode:被插入的节点)
local function InternalInsertNodeToEmptyList(list, newnode)
    newnode.Next = newnode
    newnode.Prev = newnode
    list.First = newnode
    list.Count = list.Count + 1
end

--移除链表中的节点(list:链表,node:被删除的节点)
local function InternalRemoveNode(list, node)
    if node.Next == node then
        list.First = nil
    else
        node.Next.Prev = node.Prev
        node.Prev.Next = node.Next
        if list.First == node then
            list.First = node.Next
        end
    end
    node:Invalidate()
    list.Count = list.Count - 1
end

--新建双向链表
function LinkedList:new(tab)
    local o = {}
    setmetatable(o, self)
    o.Count = 0
    o.First = nil
    if type(tab) == 'table' then
        for _, v in pairs(tab) do
            o:AddLast(v)
        end
    end
    return o
end

--Add Value
--在尾部添加值(若传入值是表，则遍历表，并将所有值添加到尾部)
function LinkedList:Add(value)
    if type(value) == 'table' then
        for _, v in pairs(value) do
            self:AddLast(v)
        end
    else
        self:AddLast(value)
    end
end

--在尾部添加值
function LinkedList:AddLast(value)
    local newnode = LinkedNode:new(value, self)
    if not self.First then
        InternalInsertNodeToEmptyList(self, newnode)
    else
        InternalInsertNodeBefore(self, self.First, newnode)
    end
    return newnode
end

--在头部添加值
function LinkedList:AddFirst(value)
    local newnode = LinkedNode:new(value, self)
    if not self.First then
        InternalInsertNodeToEmptyList(self, newnode)
    else
        InternalInsertNodeBefore(self, self.First, newnode)
        self.First = newnode
    end
    return newnode
end

--在指定节点后面添加值(node:插入在这个节点后,value:被插入的值)
function LinkedList:AddAfter(node, value)
    if not self:ValidateNewNode(node) then
        return
    end
    local newnode = LinkedNode:new(value, self)
    InternalInsertNodeBefore(self, node.Next, newnode)
    return newnode
end

--在指定节点前面添加值(node:插入在这个节点前,value:被插入的值)
function LinkedList:AddBefore(node, value)
    if not self:ValidateNode(node) then
        return
    end
    local newnode = LinkedNode:new(value, self)
    InternalInsertNodeBefore(self, node, newnode)
    if node == self.First then
        self.First = newnode
    end
    return newnode
end

--Add Node
--在头部添加节点
function LinkedList:AddNodeFirst(node)
    if not self:ValidateNewNode(node) then
        return
    end
    if not self.First then
        InternalInsertNodeToEmptyList(self, node)
    else
        InternalInsertNodeBefore(self, self.First, node)
        self.First = node
    end
    node.List = self
end

--在尾部添加节点
function LinkedList:AddNodeLast(node)
    if not self:ValidateNewNode(node) then
        return
    end
    if not self.First then
        InternalInsertNodeToEmptyList(self, node)
    else
        InternalInsertNodeBefore(self, self.First, node)
    end
    node.List = self
end

--在指定节点后面添加值(node:插入在这个节点后,newnode:被插入的节点)
function LinkedList:AddNodeAfter(node, newnode)
    if not self:ValidateNode(node) and not self:ValidateNewNode(newnode) then
        return
    end
    InternalInsertNodeBefore(self, node.Next, newnode)
    newnode.List = self
end

--在指定节点后面添加值(node:插入在这个节点前,newnode:被插入的节点)
function LinkedList:AddNodeBefore(node, newnode)
    if not self:ValidateNode(node) and not self:ValidateNewNode(newnode) then
        return
    end
    InternalInsertNodeBefore(self, node, newnode)
    newnode.List = self
    if node ~= self.First then
        return
    end
    self.First = newnode
end

--Remove
--找到表中的第一个指定值，并删除，返回是否命中
function LinkedList:Remove(value)
    local node = self:Find(value)
    if not node then
        return false
    end
    InternalRemoveNode(self, node)
    return true
end

--找到表中的第一个指定节点，并删除，返回是否命中
function LinkedList:RemoveNode(node)
    if not self:ValidateNode(node) then
        return
    end
    InternalRemoveNode(self, node)
end

--移除头部节点
function LinkedList:RemoveFirst()
    if self.First == nil then
        print('[LinkedList] list is empty.')
    else
        InternalRemoveNode(self, self.First)
    end
end

--移除尾部节点
function LinkedList:RemoveLast()
    if self.First == nil then
        print('[LinkedList] list is empty.')
    else
        InternalRemoveNode(self, self.First.Prev)
    end
end

--Find
--尝试找到表中的第一个指定值，若有则返回这个节点
function LinkedList:Find(value)
    local ptrnode = self.First
    if value ~= nil then
        while ptrnode.Value ~= value do
            ptrnode = ptrnode.Next
            if ptrnode == self.First then
                goto close1
            end
        end
        return ptrnode
    else
        while ptrnode.Value ~= nil do
            ptrnode = ptrnode.Next
            if ptrnode == self.First then
                goto close1
            end
        end
        return ptrnode
    end
    ::close1::
    return
end

--尝试反向找到表中第一个指定值，若有则返回这个节点
function LinkedList:FindLast(value)
    if self.First == nil then
        return
    end
    local prev = self.First.Prev
    local ptrnode = prev
    if value ~= nil then
        while ptrnode.Value ~= value do
            ptrnode = ptrnode.Prev
            if ptrnode == Prev then
                goto close2
            end
        end
        return ptrnode
    else
        while ptrnode.Value ~= nil do
            ptrnode = ptrnode.Prev
            if ptrnode == prev then
                goto close2
            end
        end
        return ptrnode
    end
    ::close2::
    return
end

--Other
--清空链表
function LinkedList:Clear()
    local ptrnode = self.First
    while ptrnode ~= nil do
        local lastnode = ptrnode
        ptrnode = ptrnode.Next
        lastnode:Invalidate()
    end
    self.First = nil
    self.Count = 0
end

--向给定table的指定位置插入数值(tab:被插入表,index:序号)
function LinkedList:CopyTo(tab, index)
    if type(tab) ~= 'table' then
        error('[LinkedList] bad argument "table"')
        return
    end
    if index < 1 then
        error('[LinkedList] Index out of range')
        return
    end
    local ptrnode = self.First
    if ptrnode == nil then
        return
    end
    repeat
        table.insert(tab, index, ptrnode.Value)
        ptrnode = ptrnode.Next
        index = index + 1
    until (ptrnode == self.First)
end

--将链表中的数据拷贝到新表中，并将这个表输出
function LinkedList:ToTable()
    local tab = {}
    self:CopyTo(tab, 1)
    return tab
end

--克隆当前链表，并返回
function LinkedList:Clone()
    local newlist = LinkedList:new()
    local ptrnode = self.First
    repeat
        local clnode = ptrnode:Clone()
        newlist:AddNodeLast(clnode)
        ptrnode = ptrnode.Next
    until (ptrnode == self.First)
    return newlist
end

--检查链表中是否包含指定值
function LinkedList:Contains(value)
    return self:Find(value) and true or false
end

--将链表反向
function LinkedList:Reverse()
    local tmp
    if not self.First then
        print('[LinkedList] list is empty')
        return
    end
    self.First = self.First.Prev
    for item in self:ipairer() do
        tmp = item.Next
        item.Next = item.Prev
        item.Prev = tmp
    end
end

--返回头部节点
function LinkedList:GetFirst()
    return self.First
end

--返回尾部节点
function LinkedList:GetLast()
    return self.First ~= nil and self.First.Prev or nil
end

--返回第index个节点
function LinkedList:GetNode(index)
    if index < 1 or index > self.Count then
        print('[LinkedList] Index out of range')
        return
    end
    local ptrnode = self.First.Prev
    while index > 0 do
        ptrnode = ptrnode.Next
        index = index - 1
    end
    return ptrnode
end

--返回链表长度
function LinkedList:Len()
    return self.Count
end

--返回迭代器
function LinkedList:ipairer()
    local ptrnode = self:GetLast()
    local passFirst = false
    return function()
        if ptrnode then
            if ptrnode ~= self:GetLast() or not passFirst then
                passFirst = true
                ptrnode = ptrnode.Next
                return ptrnode
            end
        end
    end
end

--以文本方式表示此表
function LinkedList:tostring()
    local t = {}
    for item in self:ipairer() do
        table.insert(t, tostring(item))
    end
    return 'LinkedList:{' .. table.concat(t, ',') .. '}'
end

LinkedList.__index = LinkedList
LinkedList.__tostring = LinkedList.tostring

return {
    list = setmetatable(LinkedList, {__call = LinkedList.new}),
    node = setmetatable(LinkedNode, {__call = LinkedNode.new})
}
