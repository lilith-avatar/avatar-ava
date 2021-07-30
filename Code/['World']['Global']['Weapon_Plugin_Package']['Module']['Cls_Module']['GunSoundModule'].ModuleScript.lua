---@module GunSound 枪械模块：枪声基类
---@copyright Lilith Games, Avatar Team
---@author RopzTao
local GunSound = class('GunSound')

---GunSound类的构造函数
---@param _gun GunBase
function GunSound:initialize(_gun, _root)
    self.gun = _gun
    self.root = _root
    ---这个枪的音效配置
    self.table_Sound = GunConfig.Sound[_gun.gun_Id] or {}
    self.soundPlaying = {}

    self.localCacheFolder =
        world:CreateObject('NodeObject', 'LocalSoundCache_' .. self.gun.name, self.gun.character.Local)
    local worldCache = world.WorldSoundCache
    if not worldCache then
        worldCache = world:CreateObject('FolderObject', 'WorldSoundCache', world)
    end
    self.worldCacheFolder =
        world:CreateObject('NodeObject', self.gun.character.Name .. self.gun.name .. '_Cache', worldCache)

    ---可使用的音频缓存
    self.m_canUsedCache = {}
    self.m_canUsedCache.Local = {} ---本地播放的音频
    self.m_canUsedCache.World = {} ---世界播放的音频

    ---正在被使用的枪械缓存
    self.m_beUsingCache = {}
    self.m_beUsingCache.Local = {} ---本地播放的音频
    self.m_beUsingCache.World = {} ---世界播放的音频

    for i, v in pairs(self.table_Sound) do
        self.m_beUsingCache.Local[i] = {}
        self.m_canUsedCache.Local[i] = {}
        self.m_beUsingCache.World[i] = {}
        self.m_canUsedCache.World[i] = {}
    end

    ---将枪械的事件和音效播放进行绑定
    for i, v in pairs(self.table_Sound) do
        local function PlaySound(_sender, _infoList)
            if not self or not self.gun then
                return
            end
            local muzzle = self.gun.m_weaponAccessoryList.muzzle
            local isSilencer = false
            if muzzle and muzzle.isSilencer then
                isSilencer = muzzle.isSilencer
            end
            if v.GunEvent == 'successfullyHit' and _infoList and _infoList.HitPart ~= HitPartEnum.Head then
                ---命中音效,但是不是爆头命中,直接返回不播放
                return
            end
            local pos = _infoList and _infoList.Position or Vector3.Zero
            if v.IsLocal then
                self:UseSoundCache(i, self.gun.character.Local, isSilencer, pos)
            else
                self:UseSoundCache(i, self.gun.character, isSilencer, pos)
            end
        end
        if self.gun[i] then
            self.gun[i]:Bind(PlaySound)
        end
    end
    ---销毁所有的音效
    local function StopAllSound()
    end
    self.gun.withDrawWeapon:Bind(StopAllSound)
end

function GunSound:UseSoundCache(_eventName, _parent, _isSilencer, _pos)
    --[[local pos = Vector3.Zero
    if _pos and type(_pos) == 'userdata' and _pos:IsA('Vector3') then
        pos = _pos
    end]]
    local localFolder = _parent.Name == 'Local' and _parent or _parent:FindNearestAncestor('Local')
    local audio
    if localFolder then
        ---本地播放,从local下取缓存进行播放
        audio = self.m_canUsedCache.Local[_eventName][1]
        if audio and not audio:IsNull() then
            ---有可用的音频,并且没有被销毁
            table.remove(self.m_canUsedCache.Local[_eventName], 1)
        else
            if audio then
                ---有可用的,但是音频被销毁了
                table.remove(self.m_canUsedCache.Local[_eventName], 1)
            else
                ---没有可用的音频
            end
            audio = self:CreateSound(_eventName, _parent, _isSilencer)
            if not audio then
                return
            end
        end
        table.insert(self.m_beUsingCache.Local[_eventName], audio)
    else
        ---非本地播放,从world下取缓存进行播放
        audio = self.m_canUsedCache.World[_eventName][1]
        if audio and not audio:IsNull() then
            ---有可用的音频,并且没有被销毁
            table.remove(self.m_canUsedCache.World[_eventName], 1)
            if _parent ~= audio.Parent then
                print('audio:SetParentTo')
                audio:SetParentTo(_parent, Vector3.Zero, EulerDegree(0, 0, 0))
            end
        else
            if audio then
                ---有可用的,但是音频被销毁了
                table.remove(self.m_canUsedCache.World[_eventName], 1)
            else
                ---没有可用的音频
            end
            audio = self:CreateSound(_eventName, _parent, _isSilencer)
            if not audio then
                return
            end
        end
        table.insert(self.m_beUsingCache.World[_eventName], audio)
    end
    if localFolder then
        --audio:SetActive(true)
        audio:Play()
    else
        for i, v in pairs(world:FindPlayers()) do
            if v ~= localPlayer then
                NetUtil.Fire_C('WeaponObjActiveChangeEvent', v, audio, true, ObjectTypeEnum.Sound, audio.Volume)
            else
                NotReplicate(
                    function()
                        --audio:SetActive(true)
                        audio:Play()
                    end
                )
            end
        end
    end
    invoke(
        function()
            if self.table_Sound and not audio:IsNull() then
                while audio:GetAudioState() == Enum.AudioSourceState.Playing do
                    wait()
                    if audio:IsNull() then
                        return
                    end
                end
                self:RecycleCache(_eventName, audio)
            end
        end
    )
end

function GunSound:RecycleCache(_eventName, _audio)
    if not _audio or _audio:IsNull() then
        return
    end
    local localFolder = _audio:FindNearestAncestor('Local')
    if localFolder then
        ---回收到本地
        --_audio:SetParentTo(self.localCacheFolder, Vector3.Zero, EulerDegree(0, 0, 0))
        table.removebyvalue(self.m_beUsingCache.Local[_eventName], _audio)
        table.insert(self.m_canUsedCache.Local[_eventName], _audio)
    else
        ---回收到世界下
        --_audio:SetParentTo(self.worldCacheFolder, Vector3.Zero, EulerDegree(0, 0, 0))
        table.removebyvalue(self.m_beUsingCache.World[_eventName], _audio)
        table.insert(self.m_canUsedCache.World[_eventName], _audio)
    end
    if localFolder then
        --_audio:SetActive(false)
        _audio:Stop()
    else
        for i, v in pairs(world:FindPlayers()) do
            if v ~= localPlayer then
                NetUtil.Fire_C('WeaponObjActiveChangeEvent', v, _audio, false, ObjectTypeEnum.Sound)
            else
                NotReplicate(
                    function()
                        --audio:SetActive(false)
                        _audio:Stop()
                    end
                )
            end
        end
    end
end

---根据事件名称,取对应的配置中的音频配置创建声音节点
function GunSound:CreateSound(_eventName, _parent, _isSilencer)
    local config = self.table_Sound[_eventName]
    if not config then
        return
    end
    local fileName
    if config.GunEvent == 'fired' then
        local splitName = StringSplit(config.FileName, ',', false)
        fileName = splitName[1]
        if #splitName > 1 and _isSilencer then
            fileName = splitName[2] or splitName[1]
        end
    else
        fileName = config.FileName
    end
    if not fileName then
        return
    end
    local audioClip = ResourceManager.GetSoundClip('WeaponPackage/Audio/' .. fileName)
    if not audioClip then
        return
    end
    local audio = world:CreateObject('AudioSource', 'Audio_' .. fileName, _parent)
    audio.LocalPosition = Vector3.Zero
    audio.SoundClip = audioClip
    audio.Volume = config.Volume
    audio.MaxDistance = 50
    audio.MinDistance = 5
    audio.Loop = config.IsLoop
    audio.Doppler = 0
    audio.PlayOnAwake = false --
    --audio:SetActive(false)
    world.S_Event.WeaponObjCreatedEvent:Fire(self.gun.character, audio)
    invoke(
        function()
            if audio and not audio:IsNull() then
                world.Players:BroadcastEvent(
                    'WeaponObjCreatedEvent',
                    audio,
                    {
                        SoundClip = audioClip,
                        PlayOnAwake = false,
                        Volume = config.Volume,
                        Loop = config.IsLoop,
                        MaxDistance = 50,
                        MinDistance = 5,
                        Doppler = 0
                    }
                )
            end
        end,
        1
    )
    return audio
end

function GunSound:Destructor()
    for i, v in pairs(self.m_canUsedCache.World) do
        for i1, v1 in pairs(v) do
            if not v1:IsNull() then
                v1:Destroy()
            end
        end
    end
    for i, v in pairs(self.m_canUsedCache.Local) do
        for i1, v1 in pairs(v) do
            if not v1:IsNull() then
                v1:Destroy()
            end
        end
    end
    for i, v in pairs(self.m_beUsingCache.World) do
        for i1, v1 in pairs(v) do
            if not v1:IsNull() then
                v1:Destroy()
            end
        end
    end
    for i, v in pairs(self.m_beUsingCache.Local) do
        for i1, v1 in pairs(v) do
            if not v1:IsNull() then
                v1:Destroy()
            end
        end
    end
    self.worldCacheFolder:Destroy()
    self.localCacheFolder:Destroy()
    ClearTable(self)
    self = nil
end

return GunSound
