--- 模块工具
-- @module Module utilities
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang

local ModuleUtil = {}

--- 加载模块目录
-- @param _root 模块目录的节点
-- @param _scope 载入后脚本的作用域
function ModuleUtil.LoadModules(_root, _scope)
    _scope = _scope or _G
    assert(_root, '[ModuleUtil] Node does NOT exist!')
    local tmp, name = _root:GetChildren()
    for _, v in pairs(tmp) do
        if v.ClassName == 'ModuleScriptObject' then
            name = (v.Name):gsub('Module', '')
            print('[ModuleUtil] Load Module: ', name)
            _scope[name] = require(v)
        end
    end
end

--- 加载插件模块目录
-- @author Xinwu Zhang
-- @param _root 插件文件夹节点
-- @param _scope 载入后脚本的作用域
function ModuleUtil.LoadPlugin(_root, _scope)
    _scope = _scope or _G
    assert(_root, '[ModuleUtil] Plugin Node does NOT exist!')
    _scope[_root.Name] = {}
    local tmp, name = _root:GetChildren()
    for _, v in pairs(tmp) do
        for _, j in pairs(v:GetChildren()) do
            if j.ClassName == 'ModuleScriptObject' then
                name = (j.Name):gsub('Module', '')
                print('[ModuleUtil] Load Module: ', _root.Name, name)
                _scope[_root.Name][name] = require(j)
            end
        end
    end
end

--- 加载XLS表格目录
-- @param _root 模块目录的节点
-- @param _config 所有Excel生成Lua文件的所在table，不允许是_G
function ModuleUtil.LoadXlsModules(_root, _config)
    assert(_root, '[ModuleUtil] Node does NOT exist!')
    assert(_config, '[ModuleUtil] Config does NOT exist!')
    local tmp, name = _root:GetChildren()
    for _, v in pairs(tmp) do
        name = (v.Name):gsub('XlsModule', '')
        print('[ModuleUtil] Load XLS: ', name)
        _config[name] = require(v)
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
-- @param _scope 该脚本的作用域
function ModuleUtil.GetModuleListWithFunc(_root, _fn, _list, _scope)
    assert(_root, '[ModuleUtil] Node does NOT exist!')
    assert(not string.isnilorempty(_fn), '[ModuleUtil] Function name is nil or empty!')
    assert(_list, '[ModuleUtil] List is NOT initialized!')
    _scope = _scope or _G
    local tmp, name = _root:GetChildren()
    for _, v in pairs(tmp) do
        name = (v.Name):gsub('Module', '')
        print(name, _fn)
        print(_scope[name] and 1 or 0)
        if _scope[name] and _scope[name][_fn] and type(_scope[name][_fn]) == 'function' then
            table.insert(_list, _scope[name])
        end
    end
end

--- 新建一个模块实例（ServerBase or ClientBase）
function ModuleUtil.New(_name, _baseClass)
    local t = class(_name, _baseClass)
    return t, t:GetSelf()
end

return ModuleUtil
