--- C# 双向链表-测试脚本
-- @script Test: C# doubly linked list implemented with lua
-- @copyright Lilith Games, Avatar Team
-- @author Bruce Chen
-- @see https://wiki.lilithgames.com/x/7yRZAg
-- @see https://github.com/BruceCheng1995/LuaLinkedList

local linkedList = require(LinkedList).list
local LinkedNode = require(LinkedList).node

--linkedList:EnableLog(true)

test('--------------initiulize-----------------')
local test1 = linkedList({1, 2, 3, nil, 'vale1', 'vale2'})
test(test1, 'lenth: ', test1:Len())

test('--------------add value-----------------')
test1:Add('addValue')
test(test1, 'lenth: ', test1:Len())
test1:Add({'addtable', 6, 7})
test(test1, 'lenth: ', test1:Len())
test1:AddFirst('first')
test(test1, 'lenth: ', test1:Len())
test1:AddLast('last')
test(test1, 'lenth: ', test1:Len())
test('--------------add node-----------------')
local test2 = linkedList({1, 2, 3})
local node1 = LinkedNode('head')
local node2 = LinkedNode('node1')
local node3 = LinkedNode('node2')
local node4 = LinkedNode('rail')
test2:AddNodeFirst(node1)
test2:AddNodeLast(node4)
test(test2, 'lenth: ', test2:Len())
test2:AddNodeAfter(node1, node2)
test2:AddNodeBefore(node4, node3)
test(test2, 'lenth: ', test2:Len())
test('--------------remove-----------------')
local test3 = linkedList({'head', 2, 3, 4, 5, 6, 7, 'last'})
test3:Remove(3)
test(test3, 'lenth: ', test3:Len())
local val1 = test3:GetNode(4)
test(val1, test3:GetNode(7))
test(test3, 'lenth: ', test3:Len())
test3:RemoveNode(val1)
test(test3, 'lenth: ', test3:Len())
test3:RemoveFirst()
test(test3, 'lenth: ', test3:Len())
test3:RemoveLast()
test(test3, 'lenth: ', test3:Len())
test('--------------other-----------------')
local test4 = linkedList({1, 2, 3, 4, 5, 6, 6, 7})
test(test4:Find(5))
test(test4:Find(20))
test(test4:FindLast(6).Prev)
test(test4, 'lenth: ', test4:Len())
test4:Clear()
test(test4, 'lenth: ', test4:Len())
test('--------------other-----------------')
local test5 = linkedList({1, 2, 3, 4, 5})
local tab = {'head', 'tail'}
test(table.unpack(tab))
test5:CopyTo(tab, 2)
test(table.unpack(tab))
local copy = test5:ToTable()
test(copy, #copy)
test(table.unpack(copy))
local clone = test5:Clone()
test(test5, 'lenth: ', test5:Len())
test(test5:Contains(5), test5:Contains(8))
test5:Reverse()
test(test5, 'lenth: ', test5:Len())
local index = 1
for item in test5:ipairer() do
    test('key: ' .. index .. ': ', 'value: ' .. tostring(item))
    index = index + 1
end
