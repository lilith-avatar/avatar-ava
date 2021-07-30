--- @module LoadingUI 进入游戏前的loading界面的控制
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local LoadingUI, this = ModuleUtil.New('LoadingUI', ClientBase)

local StateEnum = {
    None = -1, ---未激活状态
    Choosing = 1, ---随机选择亮起中
    Success = 2, ---选择结束,目标闪亮
    Show = 3, ---目标展示状态
    Loading = 4 ---展示加载界面
}
local lightUpTime = 0.12
local flashingTime = 0.1
local flashingCounts = 5
local rotateSpeed = 10

--- 初始化
function LoadingUI:Init()
    self.root = world:CreateInstance('LoadGUI', 'LoadGUI', localPlayer.Local)
    self.root.Order = 870

    self.randomModeRoot = self.root.GameModePnl
    self.loadingRoot = self.root.IntroPnl
    self.imgChoose = self.randomModeRoot.ImgChoose

    self.m_state = StateEnum.None
    self.m_imageList = {}
    self.m_imageAnchorsXList = {}
    self.m_imageAnchorsYList = {}
    self.m_imageSizeList = {}
    for i = 1, 6 do
        self.m_imageList[i] = self.randomModeRoot['Mode' .. i]
        self.m_imageAnchorsXList[i] = self.m_imageList[i].AnchorsX
        self.m_imageAnchorsYList[i] = self.m_imageList[i].AnchorsY
        self.m_imageSizeList[i] = self.m_imageList[i].Size
    end
    self.m_lightUpTime = lightUpTime
    self.m_flashingTime = flashingTime
    self.m_loadingShowTime = Config.GlobalConfig.LoadingShowTime
    self.m_flashingCounts = 0
    self.m_curLightUpIndex = 1
    self.m_sceneId = -1
    self.root:SetActive(false)
    self.randomModeRoot:SetActive(false)
    self.loadingRoot:SetActive(false)
end

--- Update函数
--- @param dt number delta time 每帧时间
function LoadingUI:Update(dt, tt)
end

function LoadingUI:FixUpdate(_dt)
    if self.m_state == StateEnum.None then
        return
    elseif self.m_state == StateEnum.Choosing then
        self.m_lightUpTime = self.m_lightUpTime - _dt
        if self.m_lightUpTime <= 0 then
            local showIndex = self.m_showList[self.m_curLightUpIndex]
            if not showIndex then
                ---显示到最后一个了
                self.m_state = StateEnum.Success
                self.m_lightUpTime = lightUpTime
                self.m_curLightUpIndex = 1
                SoundUtil:PlaySound(107)
                return
            end
            self:LightUp(showIndex)
            self.m_curLightUpIndex = self.m_curLightUpIndex + 1
            self.m_lightUpTime = lightUpTime
        end
    elseif self.m_state == StateEnum.Success then
        ---选择结束,目标模式闪烁
        self.m_flashingTime = self.m_flashingTime - _dt
        if self.m_flashingTime <= 0 then
            self:LightDownOrUp(self.m_targetIndex)
            self.m_flashingTime = flashingTime
            self.m_flashingCounts = self.m_flashingCounts + 1
        end
        if self.m_flashingCounts > flashingCounts then
            ---超过最大闪烁次数,状态转移
            self.m_flashingTime = flashingTime
            self.m_flashingCounts = 0
            for i, v in pairs(self.m_imageList) do
                v:SetActive(false)
            end
            self.m_state = StateEnum.Show
            self.m_imageList[self.m_targetIndex]:SetActive(true)
            self.m_imageList[self.m_targetIndex].Cover:SetActive(false)
            self.imgChoose:SetActive(true)
            NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'ModeImage' .. self.m_targetIndex, false)
            NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'ImgChooseShow', false)
        end
    elseif self.m_state == StateEnum.Show then
        ---闪烁结束,展示目标模式
    elseif self.m_state == StateEnum.Loading then
        ---闪烁结束,展示目标模式
        self.m_loadingShowTime = self.m_loadingShowTime - _dt
        self.loadingRoot.IconLoad.Angle = self.loadingRoot.IconLoad.Angle + rotateSpeed
        if self.m_loadingShowTime <= 0 then
            ---加载界面结束
            self.m_loadingShowTime = Config.GlobalConfig.LoadingShowTime
            self.m_state = StateEnum.None
            self.root:SetActive(false)
            self:CompleteCall()
        end
    end
end

---游戏匹配成功后显示这个界面
---@param _callBack function 展示结束后的回调
function LoadingUI:Show(_callBack)
    self.m_state = StateEnum.Choosing
    self.m_sceneId = _callBack.Params[2]
    self.imgChoose:SetActive(false)
    self.imgChoose.Size = Vector2.Zero
    self.root:SetActive(true)
    self.loadingRoot:SetActive(true)
    self.randomModeRoot:SetActive(true)
    self.m_targetIndex = math.random(1, 6)
    self.loadingRoot.AnchorsX = Vector2(-1, 0)
    self.randomModeRoot.AnchorsX = Vector2(0, 1)
    local sceneShow = {}
    for i, v in pairs(Config.Scenes) do
        if v.SceneType == 1 then
            table.insert(sceneShow, v)
        end
    end
    sceneShow = Shuffle(sceneShow)
    local tmp = sceneShow[self.m_targetIndex]
    for i, v in pairs(sceneShow) do
        if v.SceneId == self.m_sceneId then
            sceneShow[i] = tmp
            sceneShow[self.m_targetIndex] = v
        end
    end
    for i, v in pairs(sceneShow) do
        if self.m_imageList[i] then
            self.m_imageList[i].ModeTxt.Text = Config.Scenes[v.SceneId].Name
            self.m_imageList[i].ImgMode.Texture =
                ResourceManager.GetTexture('UI/Picture/' .. Config.Scenes[v.SceneId].Image)
        end
    end

    for i, v in pairs(self.m_imageList) do
        v:SetActive(true)
        v.Cover:SetActive(true)
        v.AnchorsX = self.m_imageAnchorsXList[i]
        v.AnchorsY = self.m_imageAnchorsYList[i]
        v.Size = self.m_imageSizeList[i]
    end
    self.loadingRoot.TxtName.Text = Config.Scenes[self.m_sceneId].Name
    self.loadingRoot.TxtIntro.Text = Config.Scenes[self.m_sceneId].Des
    self.loadingRoot.ImgMode.Texture = ResourceManager.GetTexture('UI/Picture/' .. Config.Scenes[self.m_sceneId].Image)
    self.m_callBack = _callBack.CallBack
    self.m_callBackParams = _callBack.Params
    self.m_callBackSelf = _callBack.Self

    self.m_showList = self:CreateRandomList()
end

---加载界面结束
function LoadingUI:CompleteCall()
    if self.m_callBack then
        self.m_callBack(self.m_callBackSelf, table.unpack(self.m_callBackParams))
    end
end

---生成随机闪亮的顺序
function LoadingUI:CreateRandomList()
    local list = {}
    local index = 1
    for i = 1, 12 do
        list[i] = index
        index = index + 1
        if index > 6 then
            index = 1
        end
    end
    for i = 1, self.m_targetIndex do
        table.insert(list, i)
    end
    return list
end

---点亮一个图片,隐藏其他
function LoadingUI:LightUp(_index)
    SoundUtil:PlaySound(106)
    for i, v in pairs(self.m_imageList) do
        if _index == i then
            v.Cover:SetActive(false)
        else
            v.Cover:SetActive(true)
        end
    end
end

---隐藏一个图片
function LoadingUI:LightDownOrUp(_index)
    if self.m_imageList[_index].Cover.ActiveSelf then
        self.m_imageList[_index].Cover:SetActive(false)
    else
        self.m_imageList[_index].Cover:SetActive(true)
    end
end

function LoadingUI:AnimationStateEventHandler(_dataName, _state)
    if _state == 'Complete' and string.startswith(_dataName, 'ModeImage') then
        NetUtil.Fire_C('StartAnimationEvent', localPlayer, 'Random2Loading', false)
    end
    if _state == 'Complete' and _dataName == 'Random2Loading' then
        self.m_state = StateEnum.Loading
    end
end

return LoadingUI
