--- @module BombModeUI 爆破模式客户端控制脚本
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local BombModeUI, this = ModuleUtil.New('BombModeUI', ClientBase)

local pairsByKeys = pairsByKeys
---炸弹未放置的颜色
local bombNoneColor = Color(255, 255, 255, 255)
---炸弹爆炸后的颜色
local bombExplodedColor = Color(255, 0, 0, 255)
---炸弹放置后的闪烁时间间隔
local flashingTime = 0.3

--- 初始化
function BombModeUI:Init()
    self.root = world:CreateInstance('BombModeUI', 'BombModeUI', localPlayer.Local)
    self.root.Order = 600

    self.root:SetActive(false)
    self.enable = false
    ---爆破模式中,每个点需要爆破的次数
    self.bombMode_ExplosionCount = Config.GlobalConfig.BombMode_ExplosionCount
    ---进攻方放置炸弹需要的时间
    self.setTime = Config.GlobalConfig.BombMode_SetTime
    ---防守方移除炸弹需要的时间
    self.removeTime = Config.GlobalConfig.BombMode_RemoveTime
    ---@type UiButtonObject 放置炸弹或者拆除炸弹的按钮
    self.setOrRemoveBtn = self.root.SetOrRemoveBombBtn
    self.bombsCountTxt = self.root.BombsCount
    self.progressUI = self.root.Progress
    self.progressUI:SetActive(false)
    self.m_curPointKey = ''
    self.m_progressTime = 0
    self.m_isReading = false
    self.setOrRemoveBtnStr = ''

    ---界面上面显示的要爆破的几个点的UI key -> pointKey, value -> (pointUI -> ui, bombsUI -> bombUIList)
    self.bombPointsUIList = {}
    ---界面跟随UI,指示用
    self.bombPointsMoveUIList = {}

    self.setOrRemoveBtn.OnClick:Connect(
        function()
            if self.m_isReading then
                self:StopReadLine()
            else
                self:StartReadLine()
            end
        end
    )
    localPlayer.OnDead:Connect(
        function()
            self:StopReadLine()
        end
    )
end

--- Update函数
--- @param dt number delta time 每帧时间
function BombModeUI:Update(dt, tt)
    if not self.enable then
        return
    end
end

function BombModeUI:FixUpdate(_dt)
    if not self.enable then
        return
    end
    for i, v in pairs(self.bombPointsUIList) do
        local bombsUI = v.bombsUI
        for i1, v1 in pairs(bombsUI) do
            if v1.State.Value == Const.BombStateEnum.BombFlashing then
                ---此炸弹在闪烁中
                local newTime = v1.FlashingTime.Value - _dt
                if newTime <= 0 then
                    if v1.Color == bombNoneColor then
                        v1.Color = bombExplodedColor
                    else
                        v1.Color = bombNoneColor
                    end
                    v1.FlashingTime.Value = flashingTime
                else
                    v1.FlashingTime.Value = newTime
                end
            end
        end
    end
    if self.m_isReading then
        ---当前正在读条
        self.progressUI.FillAmount = self.progressUI.FillAmount + _dt / self.m_progressTime
        if self.progressUI.FillAmount >= 1 then
            ---读完条了
            self.m_isReading = false
            self:CompleteReadCall()
        end
    end
end

function BombModeUI:Start(_mode, _sceneId, _pointsList, _sceneObj)
    if _mode ~= Const.GameModeEnum.BombMode then
        return
    end
    self:ConfigInit(_sceneId)
    self:SetStartValue(_pointsList, _sceneObj)
    self:CreateBombPointsUI(_pointsList)
    self:BindCollisionEvent(_pointsList)
end

---创建爆破点UI(静态)
function BombModeUI:CreateBombPointsUI(_pointsList)
    local pointsNum = table.nums(_pointsList)
    local startX = 0.5 - (pointsNum - 1) * 0.075
    local function sortFunc(a, b)
        if tostring(a) < tostring(b) then
            return true
        end
    end
    for i, v in pairsByKeys(_pointsList, sortFunc) do
        local ui = world:CreateInstance('BombModePointUI', 'BombModePointUI', self.root.Background.PointInfo)
        ui.AnchorsX = Vector2(startX, startX)
        ui.NameTxt.Text = i
        local bombUIList = {}
        for i1 = 1, self.bombMode_ExplosionCount do
            local bombUI = world:CreateInstance('BombUI', 'BombUI', ui)
            bombUI.Size = Vector2(0, 10)
            bombUI.AnchorsX = Vector2(0, 1)
            bombUI.AnchorsY = Vector2((1 - i1) * 0.2, (1 - i1) * 0.2)
            bombUI.Color = bombNoneColor
            local stateValue = world:CreateObject('IntValueObject', 'State', bombUI)
            stateValue.Value = Const.BombStateEnum.NoBomb
            local flashingTimeValue = world:CreateObject('FloatValueObject', 'FlashingTime', bombUI)
            flashingTimeValue.Value = flashingTime
            bombUIList[i1] = bombUI
        end
        local info = {}
        info.pointUI = ui
        info.bombsUI = bombUIList
        self.bombPointsUIList[i] = info
        startX = startX + 0.15
    end
end

function BombModeUI:SetStartValue(_pointsList, _sceneObj)
    self.selfDeathCount = 0
    self.m_playerTeam = localPlayer.PlayerType.Value
    self.root:SetActive(true)
    self.setOrRemoveBtn:SetActive(false)
    self.enable = true
    if self.m_playerTeam == Const.TeamEnum.Team_A then
        ---进攻方
        self.setOrRemoveBtn.Text = '放置炸弹'
        self.setOrRemoveBtnStr = '放置炸弹'
        self.bombsCountTxt:SetActive(true)
        self.m_progressTime = self.setTime
    elseif self.m_playerTeam == Const.TeamEnum.Team_B then
        ---防守方
        self.setOrRemoveBtn.Text = '拆除炸弹'
        self.setOrRemoveBtnStr = '拆除炸弹'
        self.bombsCountTxt:SetActive(false)
        self.m_progressTime = self.removeTime
    end
    BottomGUI:SetActive(true)
    BattleGUI:SetActive(true)
end

---绑定碰撞事件
function BombModeUI:BindCollisionEvent(_pointsList)
    for i, v in pairs(_pointsList) do
        v.Range.OnCollisionBegin:Connect(
            function(_hitObj)
                if _hitObj == localPlayer then
                    self:PlayerEnter(i)
                end
            end
        )
        v.Range.OnCollisionEnd:Connect(
            function(_hitObj)
                if _hitObj == localPlayer then
                    self:PlayerLeave(i)
                end
            end
        )
    end
end

---场景配置初始化
function BombModeUI:ConfigInit(_sceneId)
    self.restoreHp = Config.Scenes[_sceneId].KillRestore
    self.restoreHpMax = Config.Scenes[_sceneId].KillRestoreMax
    ---ArmsPos 弹药库位置
    self.modeParams = Config.Scenes[_sceneId].ModeParams
    self.armsPos = self.modeParams.ArmsPos
    self.pos1_A = Config.Scenes[_sceneId].BornArea[1][1]
    self.pos2_A = Config.Scenes[_sceneId].BornArea[1][2]
    self.pos1_B = Config.Scenes[_sceneId].BornArea[2][1]
    self.pos2_B = Config.Scenes[_sceneId].BornArea[2][2]
end

function BombModeUI:Reset()
    for i, v in pairs(self.bombPointsUIList) do
        if not v.pointUI:IsNull() then
            v.pointUI:Destroy()
        end
    end
    self.bombPointsUIList = {}
    for i, v in pairs(self.bombPointsMoveUIList) do
        if not v:IsNull() then
            v:Destroy()
        end
    end
    self.bombPointsMoveUIList = {}
    self.selfDeathCount = 0
end

---炸弹状态变换的事件
function BombModeUI:BombStateChangeEventHandler(_oldState, _newState, _pointKey, _key)
    local point = self.bombPointsUIList[_pointKey]
    if not point then
        return
    end
    local bombUI = point.bombsUI[_key]
    if not bombUI then
        return
    end
    bombUI.State.Value = _newState
    bombUI.FlashingTime.Value = flashingTime
    if _newState == Const.BombStateEnum.NoBomb then
        bombUI.Color = bombNoneColor
    elseif _newState == Const.BombStateEnum.BombFlashing then
    elseif _newState == Const.BombStateEnum.Exploded then
        bombUI.Color = bombExplodedColor
    end
end

---玩家进入炸弹放置范围
function BombModeUI:PlayerEnter(_pointKey)
    local point = self.bombPointsUIList[_pointKey]
    if not point then
        return
    end
    local removable, settable = false, false
    for i, v in pairs(point.bombsUI) do
        if v.State.Value == Const.BombStateEnum.BombFlashing then
            removable = true
        end
        if v.State.Value == Const.BombStateEnum.NoBomb then
            settable = true
        end
    end
    if localPlayer.PlayerType.Value == Const.TeamEnum.Team_A then
        if settable then
            self.m_curPointKey = _pointKey
            self.setOrRemoveBtn:SetActive(true)
        end
    elseif localPlayer.PlayerType.Value == Const.TeamEnum.Team_B then
        if removable then
            self.m_curPointKey = _pointKey
            self.setOrRemoveBtn:SetActive(true)
        end
    end
end

---玩家离开炸弹放置范围
function BombModeUI:PlayerLeave(_pointKey)
    self.setOrRemoveBtn:SetActive(false)
end

function BombModeUI:SetOrRemove()
    self.setOrRemoveBtn:SetActive(false)
    if not self.bombPointsUIList[self.m_curPointKey] then
        NetUtil.Fire_C('NoticeEvent', localPlayer, 1008)
        return
    end
    if self.m_playerTeam == Const.TeamEnum.Team_A then
        ---进攻方
        NetUtil.Fire_S('PlayerTrySetBombEvent', localPlayer, self.m_curPointKey)
    elseif self.m_playerTeam == Const.TeamEnum.Team_B then
        ---防守方
        NetUtil.Fire_S('PlayerTryRemoveBombEvent', localPlayer, self.m_curPointKey)
    end
end

function BombModeUI:GameOverEventHandler(_info)
    self.enable = false
    self.root:SetActive(false)
end

---玩家开启读条
function BombModeUI:StartReadLine()
    self.setOrRemoveBtn.Text = '取消'
    self.progressUI:SetActive(true)
    self.m_isReading = true
    self.progressUI.FillAmount = 0
    BottomGUI:SetActive(false)
    BattleGUI:SetActive(false)
end

---读条成功结束后调用
function BombModeUI:CompleteReadCall()
    self.setOrRemoveBtn.Text = self.setOrRemoveBtnStr
    self.progressUI:SetActive(false)
    self:SetOrRemove()
    BottomGUI:SetActive(true)
    BattleGUI:SetActive(true)
end

---读条中断
function BombModeUI:StopReadLine()
    if self.m_isReading then
        self.progressUI:SetActive(false)
        self.setOrRemoveBtn.Text = self.setOrRemoveBtnStr
        self.m_isReading = false
        self.progressUI.FillAmount = 0
        BottomGUI:SetActive(true)
        BattleGUI:SetActive(true)
    end
end

---玩家身上的炸弹数量发生变化
function BombModeUI:TeamABombCountChangeEventHandler(_num)
    self.bombsCountTxt.Text = tostring(_num)
    if _num == 0 then
        self.bombsCountTxt.Color = Color(255, 0, 0, 255)
    else
        self.bombsCountTxt.Color = Color(0, 0, 0, 255)
    end
end

return BombModeUI
