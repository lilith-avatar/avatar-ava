--- @module PlayerMgr 游戏客户端主逻辑
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local PlayerMgr, this = ModuleUtil.New('PlayerMgr', ClientBase)

--- 初始化
function PlayerMgr:Init()
    self.audioList = {}
    self.curSceneId = 0
    ---创建本地的背景音乐
    self:CreateBGM()
    ---隐藏枪械UI
    BottomGUI:SetActive(false)
    BattleGUI:SetActive(false)

    self:PlayHallBGM()
    self:ChangeSky(1011)

    localPlayer.OnStateChanged:Connect(
        function(_old, _new)
            self:PlayerStateChange(_old, _new)
        end
    )
end

--- Update函数
-- @param dt delta time 每帧时间
function PlayerMgr:Update(dt)
end

---物理更新函数
function PlayerMgr:FixUpdate(_dt)
end

---玩家传送到指定的位置
function PlayerMgr:TransferEventHandler(_pos, _rot)
    _rot = _rot or EulerDegree(0, 0, 0)
    localPlayer.Rotation = _rot
    localPlayer.Position = _pos
end

---玩家武器成功命中对面
function PlayerMgr:SuccessHitCallBack(_sender, _infoList)
    if _infoList.Player then
		--位置：ShareUIModule
        ShareUI:SuccessHitCallBack(_infoList)
    end
end

---游戏开始的事件
function PlayerMgr:GameStartEventHandler(_mode, _sceneId, _pointsList, _sceneObj)
    self.curMode = _mode
    self.curSceneId = _sceneId
    self:PlayGameBGM()
    ---先展示界面
    LoadingUI:Show(
        {
            CallBack = CamMgr.AnimationStart,
            Params = {_mode, _sceneId, _pointsList, _sceneObj},
            Self = CamMgr
        }
    )
    invoke(
        function()
            self:ChangeSky(_sceneId)
        end,
        1
    )
end

---游戏重置
function PlayerMgr:Reset()
    BottomGUI:SetActive(false)
    BattleGUI:SetActive(false)
    HallMgr:Start()
    if localPlayer.Health <= 0 then
        localPlayer:Reborn()
    end
    HallMgr:Show()
    if self.curMode == Const.GameModeEnum.OccupyMode then
        OccupyModeUI:Reset()
    elseif self.curMode == Const.GameModeEnum.BombMode then
        BombModeUI:Reset()
    elseif self.curMode == Const.GameModeEnum.DeathmatchMode then
        DeathmatchModeUI:Reset()
    end
    IndicatorUI:Reset()
    ShareUI:Reset()
    self:PlayHallBGM()
    ---重置玩家状态
    PlayerBehavior:InitsetOrReset()
    ---开火组件事件解绑
    --BattleGUI:FireComponentDestruct()
    ---天空盒子置为大厅
    self:ChangeSky(1011)
    ---玩家取消无敌
    PlayerOccLogic:Invincible(false)
end

function PlayerMgr:GameOverEventHandler(info, fakeNpcList)
    --PlayerOccLogic:RemoveCurOcc()
    if info.WinTeam == localPlayer.PlayerType.Value then
        SoundUtil:PlaySound(113)
    else
        SoundUtil:PlaySound(114)
    end
    -------NPC面向错误问题
    wait()
    for i, v in pairs(fakeNpcList) do
        local dir = Config.Scenes[self.curSceneId].GameOverCamPos - v.Position
        NotReplicate(
            function()
                v.Forward = dir
            end
        )
        wait()
        NotReplicate(
            function()
                v.Rotation = EulerDegree(0, v.Rotation.Y, 0)
            end
        )
    end
end

---世界下声音播放事件
---@param _fileName string 文件名全路径
function PlayerMgr:WorldSoundEventHandler(_fileName, _infoList)
    local _pos = _infoList.Position
    _pos = _pos or Vector3.Zero
    local parent = _pos and localPlayer.Local.Independent or world.CurrentCamera
    local audio = world:CreateObject('AudioSource', 'WorldSound_' .. _fileName, parent)
    audio.Position = _pos
    audio.PlayOnAwake = true
    for i, v in pairs(_infoList) do
        if audio[i] ~= nil then
            audio[i] = v
        end
    end
    ---之后要改成枚举
    if _pos == Vector3.Zero then
        audio.PlayMode = Enum.AudioSourcePlayMode.K2D
    else
        audio.PlayMode = Enum.AudioSourcePlayMode.K3D
    end
    audio.SoundClip = ResourceManager.GetSoundClip(_fileName)
    audio.OnComplete:Connect(
        function()
            if not audio:IsNull() then
                audio:Destroy()
                self.audioList[audio] = nil
            end
        end
    )
    self.audioList[audio] = _fileName
    audio:Play()
    invoke(
        function()
            if not audio:IsNull() then
                audio:Destroy()
                self.audioList[audio] = nil
            end
        end,
        10
    )
end

function PlayerMgr:StopSoundEventHandler(_fileName)
    for i, v in pairs(self.audioList) do
        if v == _fileName and not i:IsNull() then
            i:Stop()
        end
    end
end

---创建本地的背景音乐
function PlayerMgr:CreateBGM()
    self.hallBGM = world:CreateObject('AudioSource', 'BGM_Hall', world.CurrentCamera)
    self.gameBGM = world:CreateObject('AudioSource', 'BGM_Game', world.CurrentCamera)
    self.runSound = world:CreateObject('AudioSource', 'RunSound', world.CurrentCamera)
    self.hallBGM.SoundClip = ResourceManager.GetSoundClip('Audio/HallBGM')
    self.gameBGM.SoundClip = ResourceManager.GetSoundClip('Audio/GameBGM')
    self.runSound.SoundClip = ResourceManager.GetSoundClip('Audio/Run1')
    self.hallBGM.Loop = true
    self.hallBGM.PlayMode = Enum.AudioSourcePlayMode.K2D
    self.gameBGM.Loop = true
    self.gameBGM.PlayMode = Enum.AudioSourcePlayMode.K2D
    self.runSound.Loop = true
    self.runSound.PlayMode = Enum.AudioSourcePlayMode.K2D
    self.runSound.PlayOnAwake = true
    self.runSound:SetActive(false)
    NetUtil.Broadcast(
        'PlayerObjCreatedEvent',
        self.runSound,
        {
            SoundClip = self.runSound.SoundClip,
            Loop = true,
            PlayMode = Enum.AudioSourcePlayMode.K2D,
            PlayOnAwake = true
        }
    )
end

---播放大厅音乐
function PlayerMgr:PlayHallBGM()
    self.hallBGM:Play()
    self.gameBGM:Stop()
end

---播放游戏背景音乐
function PlayerMgr:PlayGameBGM()
    self.hallBGM:Stop()
    self.gameBGM:Play()
end

---NPC创建成功,本地在设置一次衣服
function PlayerMgr:NpcCreateEventHandler(_npcModel, _cloths)
    wait()
    if _npcModel:IsNull() then
        return
    end
    NotReplicate(
        function()
            for i, v in pairs(_cloths) do
                if _npcModel.Avatar[i] ~= nil then
                    _npcModel.Avatar[i] = v
                end
            end
        end
    )
    local deadAniEvent = _npcModel.Avatar:AddAnimationEvent('Dead', 1)
    deadAniEvent:Connect(
        function()
            if _npcModel then
                _npcModel.Avatar:PlayAnimation('DeadKeep', 3, 1, 0, true, true, 1)
            end
        end
    )
    _npcModel:Aim(0, 2)
end

---NPC状态变化事件
function PlayerMgr:NpcStateChangeEventHandler(_model, _old, _new)
    if _new ~= Const.NpcStateEnum.OnReload then
        _model:Aim(0, 2)
    end
end

---根据场景ID更改天空盒子
function PlayerMgr:ChangeSky(_sceneId)
    local config = Config.Sky[_sceneId]
    local function Change()
        for i, v in pairs(config) do
            if i ~= 'SceneId' and i ~= 'Des' then
                if i == 'Front' or i == 'Back' or i == 'Left' or i == 'Right' or i == 'Up' or i == 'Down' then
                    ---是天空贴图
                    world.Sky[i] = ResourceManager.GetTexture('Sky/' .. v)
                else
                    ---非天空贴图
                    world.Sky[i] = v
                end
            end
        end
    end
    NotReplicate(Change)
end

---其他玩家创建一个对象,需要本地同时赋值
function PlayerMgr:PlayerObjCreatedEventHandler(_obj, _info)
    if not _obj or _obj:IsNull() then
        return
    end
    for i, v in pairs(_info) do
        _obj[i] = v
    end
end

---玩家自身的状态发生变化
function PlayerMgr:PlayerStateChange(_old, _new)
    if _new == Enum.CharacterState.Walk then
        ---状态更改为移动,播放走路音效
        self.runSound:SetActive(true)
    elseif _new ~= Enum.CharacterState.Walk then
        ---状态不是移动,停止播放
        self.runSound:SetActive(false)
    end
end

return PlayerMgr
