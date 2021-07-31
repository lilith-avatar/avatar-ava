--- 音效播放模块
--- @module SoundUtil
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local SoundUtil = {}

--音频
local clipTable = nil

--音效对象池
local audioSourcePool = {
    SE3D = {}, --3D音效
    SE2D = {} --2D音效
}

--3D音效对象池上限
local SE3DMax = 8
--2D音效对象池上限
local SE2DMax = 3

--! Debug模式
local DebugMode = true

--- 打印日志
local PrintLog = DebugMode and function(...)
        print('[SoundUtil]', ...)
    end or function()
    end

--初始化音频表
local function InitClipTable(_data)
    clipTable[_data.ID] = {
        id = _data.ID,
        clip = ResourceManager.GetSoundClip(_data.Path),
        isLoop = _data.IsLoop,
        volume = _data.Volume,
        minDistance = _data.MinDistance,
        maxDistance = _data.MaxDistance
    }
    --PrintLog(table.dump(clipTable[_data.ID]))
end

--初始化一个2D播放器
local function Init2DAudioSource(_index, _uid)
    audioSourcePool.SE2D[_uid][_index] =
        world:CreateObject(
        'AudioSource',
        'AudioSource' .. _index,
        world:GetPlayerByUserId(_uid).Local.Independent.GameCam.SENode,
        world:GetPlayerByUserId(_uid).Local.Independent.GameCam.SENode.Position
    )
    return audioSourcePool.SE2D[_uid][_index]
end

--初始化一个3D播放器
local function Init3DAudioSource(_index)
    audioSourcePool.SE3D[_index] = world:CreateObject('AudioSource', 'AudioSource' .. _index, world.SENode)
    return audioSourcePool.SE3D[_index]
end

function SoundUtil.Init(_config)
    print('[SoundUtil] Init(_config)')
    if clipTable == nil then
        clipTable = {}
        for k, v in pairs(_config) do
            InitClipTable(v)
        end
    end
end

--初始化音效播放器对象池
function SoundUtil.InitAudioSource(_uid)
    if _uid then
        audioSourcePool.SE2D[_uid] = {}
        for i = 1, SE2DMax do
            Init2DAudioSource(i, _uid)
        end
    else
        for i = 1, SE3DMax do
            Init3DAudioSource(i)
        end
    end
end

--释放多余播放器
local function ReleaeseSource(_uid)
    local index = 0
    if _uid then
        index = SE2DMax + 1
        while table.nums(audioSourcePool.SE2D[_uid]) > index - 1 do
            if audioSourcePool.SE2D[_uid][index].State == Enum.AudioSourceState.Stopped then
                local ReleaesedSource = audioSourcePool.SE2D[_uid][index]
                table.remove(audioSourcePool.SE2D[_uid], index)
                ReleaesedSource:Destroy()
            else
                index = index + 1
            end
        end
    else
        index = SE3DMax + 1
        while table.nums(audioSourcePool.SE3D) > index - 1 do
            if audioSourcePool.SE3D[index].State == Enum.AudioSourceState.Stopped then
                local ReleaesedSource = audioSourcePool.SE3D[index]
                table.remove(audioSourcePool.SE3D, index)
                ReleaesedSource:Destroy()
            else
                index = index + 1
            end
        end
    end
end

--播放2D音频
function SoundUtil.Play2DSE(_uid, _SEID)
    local index = nil
    local source = nil
    for k, v in pairs(audioSourcePool.SE2D[_uid]) do
        if v.State == Enum.AudioSourceState.Stopped then
            index = k
            source = v
            break
        end
    end
    if source == nil then
        index = table.nums(audioSourcePool.SE2D[_uid]) + 1
        source = Init2DAudioSource(table.nums(audioSourcePool.SE2D[_uid]) + 1, _uid)
    end
    --PrintLog('播放2D音频', _SEID)
    source.MinDistance = clipTable[_SEID].minDistance
    source.MaxDistance = clipTable[_SEID].maxDistance
    source.Loop = clipTable[_SEID].isLoop
    source.Volume = clipTable[_SEID].volume
    source.SoundClip = clipTable[_SEID].clip
    source:Play()
    ReleaeseSource(_uid)
    return index
end

--播放3D音频
function SoundUtil.Play3DSE(_pos, _SEID)
    local index = nil
    local source = nil
    for k, v in pairs(audioSourcePool.SE3D) do
        if v.State == Enum.AudioSourceState.Stopped then
            index = k
            source = v
            break
        end
    end
    if source == nil then
        index = table.nums(audioSourcePool.SE3D) + 1
        source = Init3DAudioSource(table.nums(audioSourcePool.SE3D) + 1)
    end
    --PrintLog('播放3D音频', _SEID, table.dump(clipTable[_SEID]), _pos)
    source.Position = _pos
    source.MinDistance = clipTable[_SEID].minDistance
    source.MaxDistance = clipTable[_SEID].maxDistance
    source.Loop = clipTable[_SEID].isLoop
    source.Volume = clipTable[_SEID].volume
    source.SoundClip = clipTable[_SEID].clip
    source:Play()
    ReleaeseSource()
    return index
end

--停止播放2D音频
function SoundUtil.Stop2DSE(_uid, _index)
    audioSourcePool.SE2D[_uid][_index]:Stop()
    ReleaeseSource(_uid)
end

--停止播放3D音频
function SoundUtil.Stop3DSE(_index)
    audioSourcePool.SE3D[_index]:Stop()
    ReleaeseSource()
end

return SoundUtil
