--- 音效播放模块
---@module SoundUtil
---@copyright Lilith Games, Avatar Team
---@author Sharif Ma
---@class SoundUtil
local SoundUtil = {}

function SoundUtil:Init()
    self.SoundPlaying = {}
    self.Table_Sound = GameCsv.Sound
end

---创建一个新音效并播放
---@param _ID number 音效的ID
---@param  _SoundSourceObj Object 音效的挂载物体,不填则为2D音效,挂载在主摄像机上
function SoundUtil:PlaySound(_ID, _SoundSourceObj)
    local Info, _Duration
    _SoundSourceObj = _SoundSourceObj or world.CurrentCamera
    Info = self.Table_Sound[_ID]
    if not Info then
        error('表中不存在该ID的音效')
        return
    end
    _Duration = Info.Duration
    local sameSoundPlayingNum = 0
    for k, v in pairs(self.SoundPlaying) do
        if v == _ID then
            sameSoundPlayingNum = sameSoundPlayingNum + 1
        end
    end
    if sameSoundPlayingNum > 0 and not Info.CoverPlay then
        info(_ID .. '音效CoverPlay字段为false，不能覆盖播放')
        return
    end

    local Audio = world:CreateObject('AudioSource', 'Audio_' .. Info.FileName, _SoundSourceObj)
    Audio.LocalPosition = Vector3.Zero
    Audio.SoundClip = ResourceManager.GetSoundClip('Audio/' .. Info.FileName)
    print('Audio.SoundClip', Audio.SoundClip)
    Audio.Volume = Info.Volume
    Audio.MaxDistance = 10
    Audio.MinDistance = 10
    Audio.Loop = Info.IsLoop
    Audio:Play()
    table.insert(self.SoundPlaying, _ID)
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
                if v == _ID then
                    table.remove(self.SoundPlaying, k)
                end
            end
        end,
        _Duration
    )
end

return SoundUtil
