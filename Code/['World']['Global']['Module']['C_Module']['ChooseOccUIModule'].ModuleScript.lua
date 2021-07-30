--- @module ChooseOccUI 选择枪械的UI控制
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local ChooseOccUI, this = ModuleUtil.New('ChooseOccUI', ClientBase)

local defaultId = 1001
local showPnlBtnRotateSpeed = 5
local selectColor = Color(93, 53, 35, 255)
local noSelectColor = Color(255, 255, 255, 255)
local selectImg = 'UI/Picture/Toggle_A'
local noSelectImg = 'UI/Picture/Toggle_N'

--- 初始化函数
function ChooseOccUI:Init()
    self.root = world:CreateInstance('ChooseOcc', 'ChooseOcc', localPlayer.Local)
    self.showPnlBtn = ButtonBase:new(self.root.ShowPnlBtn, UIBase.AniTypeEnum.Scale)
    self.chooseBtn = ButtonBase:new(self.root.OccPnl.DesPnl.ChooseBtn, UIBase.AniTypeEnum.Scale)
    self.closeBtn = ButtonBase:new(self.root.OccPnl.BtnClose, UIBase.AniTypeEnum.Scale)

    self.occPnl = self.root.OccPnl
    self.difficultyTxt = self.root.OccPnl.DesPnl.ImgDifficulty.DifficultyTxt
    self.gunTxt = self.root.OccPnl.DesPnl.GunNameTxt
    self.posTxt = self.root.OccPnl.DesPnl.ImgPosition.PosTxt
    self.posImg = self.root.OccPnl.DesPnl.ImgPosition.ImgPosType
    self.moveFill = self.root.OccPnl.DesPnl.ImgMoveInfo.MoveInfo.Fill
    self.fireFill = self.root.OccPnl.DesPnl.ImgFireInfo.FireInfo.Fill
    self.disFill = self.root.OccPnl.DesPnl.ImgDisInfo.DisInfo.Fill
    self.gunImg = self.root.OccPnl.DesPnl.ImgSample.ImgGunType

    self.chooseBtnList = {}
    self.root.Order = 750
    self.selectId = -1
    self.pos1_A, self.pos2_A, self.pos1_B, self.pos2_B = Vector3.Zero, Vector3.Zero, Vector3.Zero, Vector3.Zero
    self.sceneId = 0
    self.active = false
    self.frameCount = 0

    local curNum = 0
    local occConfig = {}
    for i, v in pairs(Config.Occupation) do
        table.insert(occConfig, v)
    end
    table.sort(
        occConfig,
        function(a, b)
            return a.Order > b.Order
        end
    )
    for i, v in pairs(occConfig) do
        local btn = ButtonBase:new('ChooseOccBtn', UIBase.AniTypeEnum.Scale, self.occPnl.BtnsPnl)
        local occId = v.Id
        btn:SetValue('AnchorsX', Vector2(0, 1))
        btn:SetValue('AnchorsY', Vector2(curNum * 0.2, curNum * 0.2 + 0.18))
        btn:SetValue('Size', Vector2.Zero)
        btn:SetValue('Text', v.Name)
        btn:BindHandler('OnClick', self.ShowOccInfo, occId)
        btn:SetSound('OnClick', 116)
        self.chooseBtnList[occId] = btn
        invoke(
            function()
                wait()
                btn:CallFunction('ToTop')
            end
        )
        curNum = curNum + 1
    end

    self.showPnlBtn:BindHandler('OnClick', self.ShowPnlBtnClick)
    self.showPnlBtn:SetSound('OnClick', 110)
    --print(self.showPnlBtn.m_startFinalSize, self.showPnlBtn.m_endFinalSize)

    self.chooseBtn:BindHandler('OnClick', self.ChooseOccBtnClick)
    self.chooseBtn:SetSound('OnClick', 112)

    self.closeBtn:BindHandler('OnClick', self.ShowPnlBtnClick)
    self.closeBtn:SetSound('OnClick', 110)

    self.ShowOccInfo(defaultId)
    self.occPnl:SetActive(false)
    self.showPnlBtn:CallFunction('SetActive', false)
    self.enable = false
end

--- Update
--- @param dt number delta time
function ChooseOccUI:Update(dt, tt)
    if not self.enable then
        return
    end
    if localPlayer.PlayerType then
        local team = localPlayer.PlayerType.Value
        if team == Const.TeamEnum.Team_A then
            ---检测是否在A队伍出生区域内
            if self:CheckInRange(localPlayer, self.pos1_A, self.pos2_A) then
                self:EnterBornArea()
            else
                self:LeaveBornArea()
            end
        elseif team == Const.TeamEnum.Team_B then
            ---检测是否在B队伍出生区域内
            if self:CheckInRange(localPlayer, self.pos1_B, self.pos2_B) then
                self:EnterBornArea()
            else
                self:LeaveBornArea()
            end
        end
    end
end

function ChooseOccUI:FixUpdate(_dt)
    if not self.showPnlBtn:GetValue('ActiveSelf') then
        return
    end
    local sizeX = math.sin(self.frameCount / math.pi / 2) * 10
    self.showPnlBtn:SetValue('Ico.Size', Vector2.One * sizeX)
    local curAngle = self.showPnlBtn:GetValue('RotateIco.Angle')
    self.showPnlBtn:SetValue('RotateIco.Angle', curAngle - showPnlBtnRotateSpeed)
    self.frameCount = self.frameCount + 1
end

function ChooseOccUI:ShowPnlBtnClick()
    local self = ChooseOccUI
    if self.active then
        NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'ShowOccPnl', true)
        self.active = false
    else
        self.occPnl:SetActive(true)
        NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'ShowOccPnl', false)
        self.active = true
    end
end

function ChooseOccUI:ChooseOccBtnClick()
    local self = ChooseOccUI
    if not Config.Occupation[self.selectId] then
        return
    end
    NetUtil.Fire_S('PlayerTryChangeOccEvent', localPlayer, self.selectId)
end

function ChooseOccUI.ShowOccInfo(_id)
    local self = ChooseOccUI
    if self.selectId == _id then
        return
    end
    self.difficultyTxt.Text = Config.Occupation[_id].Difficulty
    self.gunTxt.Text = Config.Occupation[_id].Gun
    self.posTxt.Text = Config.Occupation[_id].Pos
    self.moveFill.FillAmount = Config.Occupation[_id].Move
    self.fireFill.FillAmount = Config.Occupation[_id].Fire
    self.disFill.FillAmount = Config.Occupation[_id].Dis
    self.gunImg.Texture = ResourceManager.GetTexture('UI/Icon/' .. Config.Occupation[_id].GunImg)
    self.posImg.Texture = ResourceManager.GetTexture('UI/Icon/' .. Config.Occupation[_id].PosImg)
    self.chooseBtnList[_id]:SetValue('TextColor', selectColor)
    self.chooseBtnList[_id]:SetValue('Image', ResourceManager.GetTexture(selectImg))
    if self.chooseBtnList[self.selectId] then
        self.chooseBtnList[self.selectId]:SetValue('TextColor', noSelectColor)
        self.chooseBtnList[self.selectId]:SetValue('Image', ResourceManager.GetTexture(noSelectImg))
    end
    self.selectId = _id
end

---更改职业成功后隐藏UI
function ChooseOccUI:ChangeOccEventHandler()
    --self.occPnl:SetActive(false)
    if self.active then
        NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'ShowOccPnl', true)
        self.active = false
    end
end

function ChooseOccUI:AnimationStateEventHandler(_dataName, _state)
    if _state == 'Complete' and _dataName == 'ShowOccPnl' then
        if not self.active then
            self.occPnl:SetActive(false)
        end
    end
end

function ChooseOccUI:SetActive(_active)
    --self.occPnl:SetActive(_active)
    if _active == self.active then
        return
    end
    if _active then
        self.occPnl:SetActive(true)
    end
    self.active = _active
    NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'ShowOccPnl', not _active)
end

---游戏开始后的事件,显示选择职业的按钮和界面
function ChooseOccUI:GameStart(_mode, _sceneId, _pointsList, _sceneObj)
    self.sceneId = _sceneId
    self.showPnlBtn:CallFunction('SetActive', true)
    self.pos1_A = Config.Scenes[_sceneId].BornArea[1][1]
    self.pos2_A = Config.Scenes[_sceneId].BornArea[1][2]
    self.pos1_B = Config.Scenes[_sceneId].BornArea[2][1]
    self.pos2_B = Config.Scenes[_sceneId].BornArea[2][2]
    self.enable = true
end

function ChooseOccUI:GameStartEventHandler()
    self:SetActive(false)
    self.showPnlBtn:CallFunction('SetActive', false)
end

---判断玩家是否在一个区域内
function ChooseOccUI:CheckInRange(_player, _pos1, _pos2)
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

---进入己方出生区域内
function ChooseOccUI:EnterBornArea()
    self.showPnlBtn:CallFunction('SetActive', true)
    PlayerOccLogic:Invincible(true)
end

---离开己方出生区域
function ChooseOccUI:LeaveBornArea()
    self.showPnlBtn:CallFunction('SetActive', false)
    PlayerOccLogic:Invincible(false)
end

function ChooseOccUI:GameOverEventHandler()
    self:SetActive(false)
    self.showPnlBtn:CallFunction('SetActive', false)
end

return ChooseOccUI
