--- 角色社交动作UI模块
--- @module Player Cam Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman

-- local cache
local FsmMgr = C.Fsm.FsmMgr

local PlayerActAnimeGui, this = ModuleUtil.New('PlayerActAnimeGui', ClientBase)

local actBtn, childActBtnList
local actAnimTable = {}

--- 初始化
function PlayerActAnimeGui:Init()
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function PlayerActAnimeGui:NodeRef()
    actBtn = localPlayer.Local.ControlGui.ActBtn
    childActBtnList = actBtn.Panel:GetChildren()
end

--- 数据变量初始化
function PlayerActAnimeGui:DataInit()
end

--- 节点事件绑定
function PlayerActAnimeGui:EventBind()
    actBtn.OnClick:Connect(
        function()
            actBtn.Panel:SetActive(not actBtn.Panel.ActiveSelf)
            if actBtn.Panel.ActiveSelf then
                self:ActiveChildActBtn()
            end
        end
    )
end

---激活子按钮
function PlayerActAnimeGui:ActiveChildActBtn()
    actAnimTable = {}
    for _, v in pairs(Xls.ActAnim) do
        if v.Mode == FsmMgr.playerActCtrl.actAnimMode then
            table.insert(actAnimTable, v)
        end
    end
    if #actAnimTable == 0 then
        actBtn.Panel:SetActive(false)
        return
    end
    for i = 1, #childActBtnList do
        childActBtnList[i]:SetActive(false)
        childActBtnList[i].OnClick:Clear()
        if i <= #actAnimTable then
            --childActBtnList[i].ActAnimNameText.Text = Xls.ActAnim[actAnimTable[i].ID].ShowName
            childActBtnList[i]:SetActive(true)
            childActBtnList[i].OnClick:Connect(
                function()
                    this:PlayActAnim(actAnimTable[i].ID)
                end
            )
        end
    end
    return
end

function PlayerActAnimeGui:PlayActAnim(_id)
    FsmMgr.playerActCtrl:GetActInfo(Xls.ActAnim[_id])
    FsmMgr.playerActCtrl:CallTrigger('ActBeginState')
end

return PlayerActAnimeGui
