--- 角色动画管理模块
--- @module PlayerAnim Mgr, client-side
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local PlayerAnimMgr, this = ModuleUtil.New('PlayerAnimMgr', ClientBase)
local clipNodes = {
    [0] = {},
    [1] = {},
    [2] = {}
}
--- 初始化
function PlayerAnimMgr:Init()
    print('PlayerAnimMgr:Init')
    this:NodeRef()
    this:DataInit()
    this:EventBind()

    this:SetBlendSubtree()
end

--- 节点引用
function PlayerAnimMgr:NodeRef()
end

--- 数据变量初始化
function PlayerAnimMgr:DataInit()
end

--- 节点事件绑定
function PlayerAnimMgr:EventBind()
end

--导入动画资源
function PlayerAnimMgr:ImportAnimation(_anims, _path)
    for _, animaName in pairs(_anims) do
        ResourceManager.GetAnimation(_path .. animaName)
    end
end

--创建一个包含单个动作的混合空间节点,并设置动作速率
function PlayerAnimMgr:CreateSingleClipNode(_animName, _speed, _nodeName, _gender)
    _gender = _gender or 0
    --print(_gender, table.dump(clipNodes))
    local node = localPlayer.Avatar:AddBlendSpaceSingleNode(false)
    node:AddClipSingle(_animName, _speed or 1)
    if _nodeName then
        clipNodes[_gender][_nodeName] = node
    end
    return node
end

--创建一个一维混合空间节点并附带一个参数
--[[anims = 
		{
			{"anim_woman_idle_01", 0.0, 1.0},
			{"anim_woman_walkfront_01", 0.25, 1.0}
		}
]]
function PlayerAnimMgr:Create1DClipNode(_anims, _param, _nodeName, _gender)
    _gender = _gender or 0
    local node = localPlayer.Avatar:AddBlendSpace1DNode(_param)
    for _, v in pairs(_anims) do
        node:AddClip1D(v[1], v[2], v[3] or 1)
    end
    if _nodeName then
        clipNodes[_gender][_nodeName] = node
    end
    return node
end

function PlayerAnimMgr:Create2DClipNode(_anims, _param1, _param2, _nodeName, _gender)
    _gender = _gender or 0
    local node = localPlayer.Avatar:AddBlendSpace2DNode(_param1, _param2)
    for _, v in pairs(_anims) do
        node:AddClip2D(v[1], v[2], v[3], v[4] or 1)
    end
    if _nodeName then
        clipNodes[_gender][_nodeName] = node
    end
    return node
end

function PlayerAnimMgr:Play(_animNode, _layer, _weight, _transIn, _transOut, _isInterrupt, _isLoop, _speedScale)
    local node = nil
    if type(_animNode) == 'string' then
        node = clipNodes[localPlayer.Avatar.Gender][_animNode] or clipNodes[0][_animNode]
    else
        node = _animNode
    end
    localPlayer.Avatar:PlayBlendSpaceNode(
        node,
        _layer,
        _weight or 1,
        _transIn or 0,
        _transOut or 0,
        _isInterrupt or true,
        _isLoop or false,
        _speedScale or 1
    )
end

function PlayerAnimMgr:Update(dt)
end

---设置avatar人物动画播放部位以及优先级
function PlayerAnimMgr:SetBlendSubtree()
    --localPlayer.Avatar:SetBoneBlendMask(2, Enum.BodyPart.UpperBody, true)

    ---上半身
    localPlayer.Avatar:SetBlendSubtree(Enum.BodyPart.UpperBody, 2)
    ---上半身 （同一个部位一个layer，数字越大优先级越大）
    localPlayer.Avatar:SetBlendSubtree(Enum.BodyPart.LowerBody, 3)
end

return PlayerAnimMgr
