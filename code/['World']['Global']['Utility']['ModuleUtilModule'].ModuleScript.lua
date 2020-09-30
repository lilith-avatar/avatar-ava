--- 模块工具
-- @module Module utilities
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang

local ModuleUtil = {}

--- 加载模块目录
-- @param _root 模块目录的节点
function ModuleUtil.LoadModules(_root)
    if _root == nil then
        error('[ModuleUtil] Node does NOT exist!')
    end
    local tmp, name = _root:GetChildren()
    for _, v in pairs(tmp) do
        name = (v.Name):gsub('Module', '')
        print('[ModuleUtil] Load: ' .. name)
        _G[name] = require(v)
    end
end

--- 加载多个模块目录
function ModuleUtil.LoadAllModules(...)
    local args = table.pack(...)
    for i = 1, args.n do
        if args[i] then
            ModuleUtil.LoadModules(args[i])
        end
    end
end

--- 将有包含特定方法的模块筛选出来，并放在一个table中
-- @param _root 模块目录的节点
-- @param @string _fn 方法名 function_name
-- @param @table _list 存放的table
function ModuleUtil.GetModuleListWithFunc(_root, _fn, _list)
    if _root == nil then
        error('[ModuleUtil] Node does NOT exist!')
    end
    if string.isnilorempty(_fn) then
        error('[ModuleUtil] Function name is nil or empty!')
    end
    if _list == nil then
        error('[ModuleUtil] List is NOT initialized!')
    end
    local tmp, name = _root:GetChildren()
    for _, v in pairs(tmp) do
        name = (v.Name):gsub('Module', '')
        if _G[name] and _G[name][_fn] and type(_G[name][_fn]) == 'function' then
            table.insert(_list, _G[name])
        end
    end
end

function ModuleUtil.New(_name, _baseClass)
    local t = class(_name, _baseClass)
    return t, t:GetSelf()
end

return ModuleUtil
