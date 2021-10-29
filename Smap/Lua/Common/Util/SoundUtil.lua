--- 音效播放模块
--- @module SoundUtil
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local SoundUtil = {}

function SoundUtil:Init()
    print('[SoundUtil] Init()')
    self.SoundPlaying = {}
    self.Table_Sound = Xls.Sound
end

---创建一个新音效并播放
---@param _ID number 音效的ID
---@param  _SoundSourceObj Object 音效的挂载物体,不填则为2D音效,挂载在主摄像机上
function SoundUtil:PlaySound(_ID, _SoundSourceObj)
    local Info, _Duration
    _SoundSourceObj = _SoundSourceObj or world.CurrentCamera
    Info = self.Table_Sound[_ID]
    Debug.Assert(Info ~= nil, '[SoundUtil] 表中不存在该ID的音效')
    _Duration = Info.Duration
    local sameSoundPlayingNum = 0
    for k, v in pairs(self.SoundPlaying) do
        if v[1] == _ID then
            sameSoundPlayingNum = sameSoundPlayingNum + 1
        end
    end
    if sameSoundPlayingNum > 0 and not Info.CoverPlay then
        print(string.format('[SoundUtil] %s音效CoverPlay字段为false，不能覆盖播放', _ID))
        return
    end

    local Audio = world:CreateObject('AudioSource', 'Audio_' .. Info.FileName, _SoundSourceObj)
    Audio.LocalPosition = Vector3.Zero
    Audio.SoundClip = ResourceManager.GetSoundClip('Audio/' .. Info.FileName)
    Audio.Volume = Info.Volume
    Audio.MaxDistance = 10
    Audio.MinDistance = 10
    Audio.Loop = Info.IsLoop
    Audio:Play()

    ----------------------------------------------------------------------
    --- 临时方案
    --- 在播放下一个bgm的时候，将之前的bgm销毁
    if string.sub(_ID, 1, 3) == 'Bgm' then
        for k, v in pairs(self.SoundPlaying) do
            if string.sub(v[1], 1, 3) == 'Bgm' then
                v[2]:Destroy()
                table.remove(self.SoundPlaying, k)
            end
        end
        Audio.PlayMode = 2
    end
    -----------------------------------------------------------------------
    table.insert(self.SoundPlaying, {_ID, Audio})

    --如果声音不循环，则在播放完成后及时删除
    if not Audio.Loop then
        _Duration = _Duration or 1
        invoke(
            function()
                if Audio then
                    Audio:Destroy()
                end
            end,
            _Duration
        )
        invoke(
            function()
                for k, v in pairs(self.SoundPlaying) do
                    if v[1] == _ID then
                        table.remove(self.SoundPlaying, k)
                    end
                end
            end,
            _Duration
        )
    end
end

---结束音效的播放
---@param _ID number 音效的ID
---@param  _SoundSourceObj Object 音效的挂载物体,不填则为2D音效,挂载在主摄像机上
function SoundUtil:StopSound(_ID, _SoundSourceObj)
    _SoundSourceObj = _SoundSourceObj or world.CurrentCamera
    ---可能会
    for k, v in pairs(self.SoundPlaying) do
        if v[1] == _ID and v[2].Parent == _SoundSourceObj then
            v[2]:Destroy()
            table.remove(self.SoundPlaying, k)
        end
    end
end

return SoundUtil
