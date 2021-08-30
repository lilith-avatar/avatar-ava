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
    assert(_root, '[AvaKit][ModuleUtil] _root is WRONG')
    assert(_manifest and _manifest.Modules, '[AvaKit][ModuleUtil] _manifest is WRONG')
    assert(_res, '[AvaKit][ModuleUtil] _res does NOT exist')

    -- 读取Manifest，并生成一个require array
    local node, subNode, mod = {rt = _root, man = _manifest, res = _res}
    local arr = {node}
    local deep, done = LOOP_MAX, false
    while not done and deep > 0 do
        deep = deep - 1
        done = true
        for i = 1, #arr do
            node = arr[i]
            if node.man ~= nil and node.man.Modules ~= nil then
                done = false
                table.remove(arr, i)
                local cnt = 0
                for j = 1, #node.man.Modules do
                    mod = node.man.Modules[j] -- Manifest.Modules.XXXX
                    if type(mod) == 'table' and mod.Modules ~= nil then
                        -- print(node, node.rt, mod.Name)
                        node.rt[mod.Name] = node.rt[mod.Name] or {}
                        subNode = {
                            rt = node.rt[mod.Name],
                            man = mod,
                            res = string.format('%s%s/', node.res, mod.Name)
                        }
                        cnt = cnt + 1
                        table.insert(arr, i + cnt - 1, subNode)
                    elseif type(mod) == 'string' then
                        subNode = {
                            rt = node.rt,
                            name = mod,
                            res = node.res .. mod
                        }
                        cnt = cnt + 1
                        table.insert(arr, i + cnt - 1, subNode)
                    end
                end
            end
        end
    end

    -- Require Module脚本
    for k, v in ipairs(arr) do
        --print(string.format('[AvaKit][Load][%02d] %s, %s', k, v.name, v.res))
        v.rt[v.name] = require(v.res)
        if _list then
            table.insert(_list, v.rt[v.name])
        end
        -- FIXME: 暂时为全局变量，向下兼容
        _G[v.name] = v.rt[v.name]
    end
end

--- 将有包含特定方法的模块筛选出来，并放在一个table中
--- @param _modules module列表
--- @param @string _fn 方法名 function_name
--- @param @table _list 存放的table
function ModuleUtil.GetModuleListWithFunc(_modules, _fn, _list)
    assert(_modules, '[ModuleUtil] Node does NOT exist!')
    assert(not string.isnilorempty(_fn), '[ModuleUtil] Function name is nil or empty!')
    assert(_list, '[ModuleUtil] List is NOT initialized!')
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
