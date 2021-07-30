--- @module HallMgr
--- @copyright Lilith Games, Avatar Team
--- @author Yuchen Wang
local HallMgr, this = ModuleUtil.New('HallMgr', ClientBase)

---范围检测的高度限制
local RANGE_HIGH = 10

---初始化
function HallMgr:Init()
    self.requireNum = Config.GlobalConfig.PlayerNum
    self.root = world:CreateInstance('HallGUI', 'HallGUI', localPlayer.Local)
    self.root.Order = 650
    self.matchTimeTxt = self.root.ImgBG.Time
    self.timeLeftTxt = self.root.MatchPnl.ImgSuccess.TimeTxt
    self.circle = self.root.ImgBG.ImgLoad
    self.goReadyUI = self.root.ImgNotice
    self.root.MatchPnl:SetActive(false)
    self.isMatching = false
    self.m_isSuccess = false
    ---匹配已用时间
    self.waitTime = 0
    self.matchTimeTxt.Text = self.waitTime
    self.hall2GameWait = Config.GlobalConfig.Hall2GameWait
    self.timeLeftTxt.Text = tostring(self.hall2GameWait)
    self.second = 1
    self.curNum = 0
    self:Reset()
    self:Start()
end

---Update函数
function HallMgr:Update(dt)
    if self.isRun then
        if not self.isMatching and self:CheckInRange(localPlayer, Vector3(-9.7, -300, 15.5), Vector3(-28, -300, 4.7)) then
            self:HitReady()
        end
        if self.isMatching and not self:CheckInRange(localPlayer, Vector3(-9.7, -300, 15.5), Vector3(-28, -300, 4.7)) then
            self:CancelReady()
        end

        if self.isMatching and self.curNum < self.requireNum then
            self.second = self.second - dt
            if self.second <= 0 then
                self.second = 1
                SoundUtil:PlaySound(117)
                self.waitTime = self.waitTime + 1
                self.matchTimeTxt.Text = self.waitTime
            end
        end
    end
end

function HallMgr:FixUpdate(_dt)
    self.circle.Angle = self.circle.Angle + 8
end

---大厅开始运行
function HallMgr:Start()
    self.root.MatchPnl.ImgSuccess:SetActive(false)
    self.root.MatchPnl.ImgSuccess.ImgSuccessRight.AnchorsX = Vector2(1.3, 1.3)
    self.root.MatchPnl.ImgSuccess.ImgSuccessLeft.AnchorsX = Vector2(-0.3, -0.3)
    localPlayer.PlayerType.Value = Const.TeamEnum.Team_A
    ---显示选枪UI
    ChooseOccUI:GameStart(0, 1011, 0, 0)
    BattleGUI:SetActive(true)
    if PlayerGunMgr.curGun then
        PlayerGunMgr.curGun.m_gui:SetVisible(true)
    end
    ---大厅动态物体释放
    self.isRun = true
    HallInteractObj:ReadObjs()
end

---大厅重置
function HallMgr:Reset()
    self.isRun = false
    self.isMatching = false

    ---将大厅所有可交互物重置
    HallInteractObj:ResetObjs()
    self.root.MatchPnl.ImgSuccess:SetActive(false)
    self.root.MatchPnl.ImgSuccess.ImgSuccessRight.AnchorsX = Vector2(1.3, 1.3)
    self.root.MatchPnl.ImgSuccess.ImgSuccessLeft.AnchorsX = Vector2(-0.3, -0.3)
    self.root.ImgBG.AnchorsY = Vector2(1.2, 1.2)
end

---进入游戏
function HallMgr:GameStartEventHandler()
    self:Reset()
    self.root:SetActive(false)
    self.root.MatchPnl:SetActive(false)
    self.isMatching = false
    self.waitTime = 0
    self.matchTimeTxt.Text = self.waitTime
    self.root.MatchPnl.ImgSuccess:SetActive(false)
    self.goReadyUI:SetActive(false)
    --[[
    ---去掉玩家枪
    local gun
    if PlayerGunMgr.mainGun then
        gun = PlayerGunMgr.mainGun.gun
        PlayerGunMgr:OnUnEquipWeaponEvent(PlayerGunMgr.mainGun)
        gun:Destroy()
    end
    BattleGUI:SetActive(false)
    ]]
end

---匹配的玩家数量发生变化的事件
function HallMgr:MatchPlayerChangeEventHandler(_num)
    if self.m_isSuccess then
        return
    end
    if not self.isMatching and _num > 0 then
        ---给不在准备中的玩家提示
        self.goReadyUI:SetActive(true)
    end
    if _num >= self.requireNum then
        ---匹配完成,游戏即将开始
        self.root.MatchPnl:SetActive(true)
        self.root.MatchPnl.ImgSuccess:SetActive(true)
        SoundUtil:PlaySound(118)
        NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'MatchSuccess')
        self.m_isSuccess = true
        self.root.ImgBG:SetActive(false)
        self.goReadyUI:SetActive(false)
        NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'StartMatch', true)
        invoke(
            function()
                while true do
                    self.timeLeftTxt.Text = tostring(math.floor(self.hall2GameWait))
                    self.hall2GameWait = self.hall2GameWait - 1
                    self.hall2GameWait = self.hall2GameWait < 0 and 0 or self.hall2GameWait
                    if not self.m_isSuccess then
                        return
                    end
                    wait(1)
                end
            end
        )
    end
    self.curNum = _num
    localPlayer.Local.Independent.HallObjs.CurNumTV.SurfaceGUI.Image.Text.Text = tostring(_num)
end

---判断玩家是否在一个区域内
function HallMgr:CheckInRange(_player, _pos1, _pos2)
    local y = _pos1.Y + _pos2.Y
    y = y * 0.5
    if math.abs(y - _player.Position.Y) > RANGE_HIGH then
        return false
    end
    local x1, x2 = _pos1.X, _pos2.X
    local z1, z2 = _pos1.Z, _pos2.Z
    local x, z = _player.Position.X, _player.Position.Z
    if x >= x1 and x <= x2 or x >= x2 and x <= x1 then
        if z >= z1 and z <= z2 or z >= z2 and z <= z1 then
            return true
        end
    end
    return false
end

---玩家准备
function HallMgr:HitReady()
    self.goReadyUI:SetActive(false)
    if self.m_isSuccess then
        return
    end
    SoundUtil:PlaySound(117)
    self.root.ImgBG:SetActive(true)
    self.isMatching = true
    self.waitTime = 0
    self.matchTimeTxt.Text = self.waitTime
    NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'StartMatch', false)
    NetUtil.Fire_S('PlayerStartMatchEvent', localPlayer)
end

---玩家取消准备
function HallMgr:CancelReady()
    if self.m_isSuccess then
        return
    end
    SoundUtil:PlaySound(117)
    self.root.ImgBG:SetActive(false)
    self.isMatching = false
    self.waitTime = 0
    self.matchTimeTxt.Text = self.waitTime
    NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'StartMatch', true)
    NetUtil.Fire_S('PlayerStopMatchEvent', localPlayer)
end

function HallMgr:Show()
    self.root:SetActive(true)
end

function HallMgr:GameOverEventHandler()
    self.m_isSuccess = false
    self.hall2GameWait = Config.GlobalConfig.Hall2GameWait
end

return HallMgr
