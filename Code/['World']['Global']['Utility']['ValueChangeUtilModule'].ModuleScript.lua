--- 值改变及值改变事件
--- @module ValueChangeUtil Module
--- @copyright Lilith Games, Avatar Team
--- @author Xin Tan
local ValueChangeUtil = {}

--- 数据变化事件
--- @param _table table 事件表
--- @param _index string 索引
--- @param _oldValue mixed 旧值
--- @param _newValue mixed 新值
--- @param _targetPlayer PlayerInstance 这条数据对应的玩家实例
function ValueChangeUtil.DataChangeEvent(_table, _index, _oldValue, _newValue)
    if not _table[_index] or type(_table[_index]) ~= 'function' then
        return
    end
    _table[_index](_oldValue, _newValue)
end

--- 将目标表（或其中某个值）改为新值
--- @param _table table 目标表
--- @param _index string 目标索引（改整个目标表时填nil）
--- @param _value mixed  新值
--- @param _eventTable table 数值改变事件表（不响应时不传）
function ValueChangeUtil.ChangeValue(_table, _index, _value, _eventTable)
    if type(_table) ~= 'table' then
        print('[error]传入的目标表类型错误')
        return
    end

    local tmp = _table
    local eventtmp = _eventTable or false

    -- 参数含索引时
    if _index then
        local idx = {}
        if type(_index) == 'string' then
            -- 将索引通过'.'拆开
            idx = string.split(_index, '.')
        elseif type(_index) == 'table' then
            idx = _index
        end
        -- 一层层向下索引
        for i = 1, #idx - 1 do
            -- 若目标表没有对应的索引则建立空表
            if type(tmp[idx[i]]) ~= 'table' then
                tmp[idx[i]] = {}
            end
            tmp = tmp[idx[i]]
            if eventtmp then
                if type(eventtmp[idx[i]]) ~= 'table' then
                    eventtmp[idx[i]] = {}
                end
                eventtmp = eventtmp[idx[i]]
            end
        end

        -- 若目标值不是table，则直接赋值
        if type(_value) ~= 'table' then
            local oldValue = table.shallowcopy(tmp[idx[#idx]])
            tmp[idx[#idx]] = _value
            if eventtmp then
                ValueChangeUtil.DataChangeEvent(eventtmp, idx[#idx], oldValue, _value)
            end
            return
        else
            -- 目标值是table
            -- 若目标索引不是table，则创建table
            if type(tmp[idx[#idx]]) ~= 'table' then
                tmp[idx[#idx]] = {}
                if eventtmp and type(eventtmp[idx[#idx]]) ~= 'table' then
                    eventtmp[idx[#idx]] = {}
                end
            end
            tmp = tmp[idx[#idx]]
            if eventtmp then
                eventtmp = eventtmp[idx[#idx]]
            end
        end
    else
        -- 参数无索引时，从目标表根目录开始同步
        if type(_value) ~= 'table' then
            print('[error]传入的新值类型错误')
            return
        end
    end

    -- 清除目标索引表与新值的差集
    for k, v in pairs(tmp) do
        if not _value[k] then
            local oldValue = tmp[k]
            tmp[k] = nil
            if eventtmp then
                ValueChangeUtil.DataChangeEvent(eventtmp, k, oldValue, nil)
            end
        end
    end

    -- 逐层覆盖数据
    for k, v in pairs(_value) do
        -- 如果值为table则向下递归
        if type(v) == 'table' then
            ValueChangeUtil.ChangeValue(tmp, k, v, eventtmp)
        else
            -- 若值不是table，则直接赋值
            local oldValue = tmp[k]
            tmp[k] = v
            if eventtmp then
                ValueChangeUtil.DataChangeEvent(eventtmp, k, oldValue, v)
            end
        end
    end
    if eventtmp then
        ValueChangeUtil.DataChangeEvent(eventtmp, 'parentTableEvent')
    end
end

--- 进行数据验证，将对照表中存在而目标表中不存在键补充至目标表中
--- @param _table table 目标表
--- @param _contrast table 对照表
function ValueChangeUtil.VerifyTable(_table, _contrast)
    for k, v in pairs(_contrast) do
        -- 如果值为table则向下递归
        if type(v) == 'table' then
            if not _table[k] then
                _table[k] = table.shallowcopy(v)
            else
                ValueChangeUtil.VerifyTable(_table[k], v)
            end
        else
            -- 若值不是table，则直接校对
            if not _table[k] then
                _table[k] = v
            end
        end
    end
end

return ValueChangeUtil
