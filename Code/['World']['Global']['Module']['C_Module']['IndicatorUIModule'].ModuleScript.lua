--- @module IndicatorUI 界面飘字UI
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local IndicatorUI, this = ModuleUtil.New('IndicatorUI', ClientBase)

--- 初始化
function IndicatorUI:Init()
    self.root = world:CreateInstance('IndicatorUI', 'IndicatorUI', localPlayer.Local)
    self.root.Order = 1
    self.bindInsList = {}
end

--- 初始化IndicatorUI自己的监听事件
function IndicatorUI:InitListeners()
    EventUtil.LinkConnects(localPlayer.C_Event, IndicatorUI, 'IndicatorUI', this)
end

--- Update函数
--- @param dt number delta time 每帧时间
function IndicatorUI:Update(dt, tt)
end

---创建一个UI,并和场景中的对象绑定
function IndicatorUI:CreateUI(_name, _obj, _offset)
    local ui = world:CreateInstance(_name, _name, self.root)
    local ins = World2ScreenUI:new(ui, _obj, ui.Dir, ui.Content, _offset)
    table.insert(self.bindInsList, ins)
    return ui
end

---游戏重置时候调用,清空所有的UI
function IndicatorUI:Reset()
    for i, v in pairs(self.bindInsList) do
        v:Unbind()
    end
    self.bindInsList = {}
end

function IndicatorUI:GameStartEventHandler()
    self:SetActive(true)
end

function IndicatorUI:GameOverEventHandler()
    self:SetActive(false)
end

function IndicatorUI:SetActive(_active)
    self.root:SetActive(_active)
end

return IndicatorUI
