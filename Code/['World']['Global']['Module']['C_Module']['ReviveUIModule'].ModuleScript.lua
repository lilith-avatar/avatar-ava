--- @module ReviveUI 死亡后等待复活的界面
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local ReviveUI, this = ModuleUtil.New('ReviveUI', ClientBase)

--- 初始化
function ReviveUI:Init()
    self.root = world:CreateInstance('ReviveGUI', 'ReviveGUI', localPlayer.Local)
    self.waitTimeTxt = self.root.WaitTimeTxt
    self.m_isShown = false
    self.m_showTime = 0
    self.DieTime = 0
    self.root:SetActive(false)
end

--- Update函数
--- @param dt number delta time 每帧时间
function ReviveUI:Update(dt, tt)
    if not self.m_isShown then
        return
    end
    self.m_showTime = self.m_showTime - dt
    self.waitTimeTxt.Image.FillAmount = self.m_showTime / self.DieTime
    self.waitTimeTxt.Text = math.ceil(self.m_showTime)
    if self.m_showTime <= 0 then
        self.m_showTime = 0
        self:Hide()
    end
end

---展示死亡等待界面
---@param _time number 等待时间
---@param _killer PlayerInstance 击杀者
---@param _weaponId number 伤害来源的枪械ID
---@param _hitPart number 击杀部位
function ReviveUI:Show(_time, _killer, _weaponId, _hitPart)
    if not _time or type(_time) ~= 'number' or _time <= 0 then
        return
    end
    self:DieInfo(_killer, _weaponId)
    self.m_showTime = _time
    self.DieTime = _time
    self.waitTimeTxt.Image.FillAmount = 1
    self.m_isShown = true
    self.root:SetActive(true)
end

---死亡信息
---DieCameraMoveMgr
function ReviveUI:DieInfo(_killer, _weaponId)
    self.root.InfoBg.KillerNameTxt.Text = splitString(_killer.Name, Config.GlobalConfig.NameLengthShow)
    self.root.InfoBg.GunIcon.Texture =
        ResourceManager.GetTexture('WeaponPackage/UI/BattleGUI/' .. GunConfig.GunConfig[_weaponId].Icon)
end

---对局剩余时间监听
--@param _text 时间字符串
function ReviveUI:RemainTime(_text)
    self.root.InfoBg.GametimeTxt.Text = _text .. 's'
end

---隐藏
function ReviveUI:Hide()
    self.m_showTime = 0
    self.m_isShown = false
    self.root:SetActive(false)
end

return ReviveUI
