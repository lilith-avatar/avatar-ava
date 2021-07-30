--- 音效播放模块
--- @module SoundUtil
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local SoundUtil = {}

function SoundUtil:Init()
    print('[SoundUtil] Init()')
	--播放表：所有需要播放的音效都临时存放在该表中
    self.SoundPlaying = {}
    self.Table_Sound = Config.Sound
end

---创建一个新音效并播放
---@param _ID number 音效的ID
---@param  _SoundSourceObj Object 音效的挂载物体,不填则为2D音效,挂载在主摄像机上,填写则为世界音效
function SoundUtil:PlaySound(_ID, _SoundSourceObj)
    local Info, _Duration
	--如果参数_SoundSourceObj存在，则获取Position坐标数据，负责置为nil
    local pos = _SoundSourceObj and _SoundSourceObj.Position or nil
	--如果参数_SoundSourceObj存在，则获取所有玩家的对象，负责置为本地玩家对象
    local targetPlayer = _SoundSourceObj and world:FindPlayers() or {localPlayer}
    --_SoundSourceObj = _SoundSourceObj or world.CurrentCamera
    Info = self.Table_Sound[_ID]
    assert(Info, '[SoundUtil] 表中不存在该ID的音效')
	--_Duration：音效持续时间
    _Duration = Info.Duration
    local sameSoundPlayingNum = 0
    for k, v in pairs(self.SoundPlaying) do
        if v == _ID then
            sameSoundPlayingNum = sameSoundPlayingNum + 1
        end
    end
    if sameSoundPlayingNum > 0 and not Info.CoverPlay then
        print(string.format('[SoundUtil] %s音效CoverPlay字段为false，不能覆盖播放', _ID))
        return
    end
    local filePath = 'Audio/' .. Info.FileName
    for i, v in pairs(targetPlayer) do
		--- 向指定的玩家发送消息
        NetUtil.Fire_C('WorldSoundEvent', v, filePath, {Position = pos, Volume = Info.Volume, Loop = Info.IsLoop})
    end

    --[[
    local Audio = world:CreateObject('AudioSource', 'Audio_' .. Info.FileName, _SoundSourceObj)
    Audio.LocalPosition = Vector3.Zero
    Audio.SoundClip = ResourceManager.GetSoundClip('Audio/' .. Info.FileName)
    print('[SoundUtil] Audio.SoundClip', Audio.SoundClip)
    Audio.Volume = Info.Volume
    Audio.MaxDistance = 10
    Audio.MinDistance = 10
    Audio.Loop = Info.IsLoop
    Audio:Play()
    table.insert(self.SoundPlaying, _ID)
    _Duration = _Duration or 1]]
	--音效播放结束后将该音效移除播放表
    invoke(
        function()
            for k, v in pairs(self.SoundPlaying) do
                if v == _ID then
					--移除该音效
                    table.remove(self.SoundPlaying, k)
                end
            end
        end,
        _Duration
    )
end

---停止一个音效的播放
function SoundUtil:StopSound(_ID, _isLocal)
    local Info = self.Table_Sound[_ID]
    assert(Info, '[SoundUtil] 表中不存在该ID的音效')
    local filePath = 'Audio/' .. Info.FileName
	--如果参数_isLocal存在则设置目标为本地玩家，负责设置为全体玩家
    local targetPlayer = _isLocal and {localPlayer} or world:FindPlayers()
    for i, v in pairs(targetPlayer) do
		--想目标玩家发出客户端指令消息StopSoundEvent
        NetUtil.Fire_C('StopSoundEvent', v, filePath)
    end
end

return SoundUtil
