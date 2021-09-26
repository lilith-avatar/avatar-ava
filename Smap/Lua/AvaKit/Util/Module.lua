--- 模块加载工具
--- @module Module utilities
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

local ModuleUtil = {}

-- Constants
local LOOP_MAX = 15 -- Manifest最多层级深度

--- 加载Manifest
--- @param _root 模块目录的节点
--- @param _manifest Mainifest中的节点
--- @param _res 资源路径
--- @param _list 模块清单
function ModuleUtil.LoadManifest(_root, _manifest, _res, _list)
    Debug.Assert(_root ~= nil, '[AvaKit][ModuleUtil] _root is WRONG')
    Debug.Assert(_manifest ~= nil and _manifest.Modules ~= nil, '[AvaKit][ModuleUtil] _manifest is WRONG')
    Debug.Assert(_res ~= nil, '[AvaKit][ModuleUtil] _res does NOT exist')

    local pathArr, tmpRoot, tmp
    for _, path in ipairs(_manifest.Modules) do
        Debug.Assert(type(path) == 'string', '[AvaKit][ModuleUtil] path is NOT a string')
        pathArr = string.split(path, '/')
        tmpRoot = _root
        for k, fn in ipairs(pathArr) do
            if k < #pathArr then
                tmpRoot[fn] = tmpRoot[fn] or {}
                tmpRoot = tmpRoot[fn]
            else
                tmpRoot[fn] = require(_res .. path)
                if _list then
                    table.insert(_list, tmpRoot[fn])
                end
            end
        end
    end
end

--- 将有包含特定方法的模块筛选出来，并放在一个table中
--- @param _modules module列表
--- @param @string _fn 方法名 function_name
--- @param @table _list 存放的table
function ModuleUtil.GetModuleListWithFunc(_modules, _fn, _list)
    Debug.Assert(_modules ~= nil, '[ModuleUtil] Node does NOT exist!')
    Debug.Assert(not string.isnilorempty(_fn), '[ModuleUtil] Function name is nil or empty!')
    Debug.Assert(_list ~= nil, '[ModuleUtil] List is NOT initialized!')
    for _, m in pairs(_modules) do
        if m[_fn] and type(m[_fn]) == 'function' then
            table.insert(_list, m)
        end
    end
end

--- 新建一个模块实例（ServerBase or ClientBase）
function ModuleUtil.New(_name, _baseClass)
    local t = class(_name, _baseClass)
    return t, t:GetSelf()
end

return ModuleUtil
