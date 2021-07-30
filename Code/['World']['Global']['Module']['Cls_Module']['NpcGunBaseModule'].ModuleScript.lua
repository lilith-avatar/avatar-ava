--- @module NpcGunBase 服务端使用的NPC枪械控制类
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local NpcGunBase = class('NpcGunBase')

local GunState = Const.NpcStateEnum

--- 初始化
---@param _npc NpcEnemyBase
function NpcGunBase:initialize(_npc)
    self.gunId = _npc.gunId
    self.npcModel = _npc.model
    self.gunConfig = GunCsv.GunConfig.GunConfig[_npc.gunId]
    self.magazineConfig = GunCsv.GunConfig.Magazine[self.gunConfig.MagazineUsed]
    self.animationConfig = GunCsv.GunConfig.GunAnimation[self.gunConfig.AnimationId]
    self.soundConfig = GunCsv.GunConfig.Sound[self.gunId]

    self.maxAmmo = self.magazineConfig.MagazineMaxNum
    self.loadTime = self.magazineConfig.LoadTime
    self.modelName = self.gunConfig.Name
    self.damage = _npc.damageRate * self.gunConfig.Damage
    self.shootSpeed = _npc.shootSpeedRate * self.gunConfig.ShootSpeed
    self.characterAnimationMode = self.gunConfig.CharacterAnimationMode
    self.attackAni = self.animationConfig.fired.AnimationName
    self.reloadAni = self.animationConfig.magazineLoadStarted.AnimationName
    self.attackSound = self.soundConfig.fired.FileName
    self.reloadSound = self.soundConfig.magazineLoadStarted.FileName
    self.fireEff = self.gunConfig.FireEffect

    self.m_leftAmmo = self.maxAmmo
    self.m_leftLoadTime = self.loadTime
    self.m_shootWait = 1 / self.shootSpeed
    self.m_state = GunState.AllowFire
    self.m_soundCacheList = {}
    self.m_fireEffCacheList = {}
    self.m_lastState = self.m_state

    self.model = world:CreateInstance(self.modelName, self.modelName, _npc.model)
    self.model.Block = false
    self.model.IsStatic = true
    self.model:SetParentTo(_npc.model.Avatar[self.model.Bone], self.model.AttachPos, self.model.AttachRot)
    self.npcModel.AnimationMode = self.characterAnimationMode
    print('NPC动作模式为', self.npcModel.AnimationMode, self.npcModel.Name)
    self.npcModel:Aim(0, 2)
    self.npcModel.Avatar:SetBlendSubtree(Enum.BodyPart.UpperBody, 2)

    self:PreloadEff({self.fireEff})
    self:PreloadSound({self.attackSound, self.reloadSound})
end

--- Update函数
--- @param dt number delta time 每帧时间
function NpcGunBase:Update(dt, tt)
    if self.m_state == GunState.AllowFire then
        ---当前状态为允许射击
        self.npcModel:Aim(0, 2)
    elseif self.m_state == GunState.FireWaiting then
        ---当前状态为开火后的等待阶段
        self.m_shootWait = self.m_shootWait - dt
        self.npcModel:Aim(0, 2)
        if self.m_shootWait <= 0 then
            ---射击等待时间结束
            self.m_state = GunState.AllowFire
            self.m_shootWait = 1 / self.shootSpeed
        end
    elseif self.m_state == GunState.NoAmmo then
        ---当前状态为没有子弹的状态
        self.npcModel:Aim(0, 2)
    elseif self.m_state == GunState.OnReload then
        ---当前状态为装弹中
        self.m_leftLoadTime = self.m_leftLoadTime - dt

        if self.m_leftLoadTime <= 0 then
            ---换弹等待时间结束,换弹成功
            self.m_leftAmmo = self.maxAmmo
            self.m_state = GunState.AllowFire
            self.m_leftLoadTime = self.loadTime
        end
    end
    if self.m_lastState ~= self.m_state then
        ---枪械状态发生变化
        NetUtil.Broadcast('NpcStateChangeEvent', self.npcModel, self.m_lastState, self.m_state)
        self.m_lastState = self.m_state
    end
end

---销毁NPC前调用,销毁枪械
function NpcGunBase:Destroy()
    if self.model and not self.model:IsNull() then
        self.model:Destroy()
    end
    for i, v in pairs(self.m_fireEffCacheList) do
        for i1, v1 in pairs(v) do
            if not v1:IsNull() then
                v1:Destroy()
            end
        end
    end
    for i, v in pairs(self.m_soundCacheList) do
        for i1, v1 in pairs(v) do
            if not v1:IsNull() then
                v1:Destroy()
            end
        end
    end
    table.cleartable(self)
    self = nil
end

---开火方法
---@param _target PlayerInstance 目标玩家
function NpcGunBase:Fire(_target)
    if self.m_state == GunState.AllowFire and _target then
        self:Damage(_target)
        self.m_leftAmmo = self.m_leftAmmo - 1
        self.npcModel.Avatar:PlayAnimation(self.attackAni, 2, 1, 0, true, false, 1)
        self:PlayEff(self.fireEff)
        self:PlayAudio(self.attackSound)
        if self.m_leftAmmo <= 0 then
            ---没子弹了,自动换弹
            self:Reload()
        else
            ---还有子弹
            self.m_state = GunState.FireWaiting
        end
        self.m_shootWait = 1 / self.shootSpeed
        return true
    else
        return false
    end
end

---装弹方法
function NpcGunBase:Reload()
    if self.m_state ~= GunState.OnReload then
        self.m_state = GunState.OnReload
        self.m_leftLoadTime = self.loadTime
        self:PlayAudio(self.reloadSound)
        self.npcModel.Avatar:PlayAnimation(self.reloadAni, 2, 1, 0, true, false, 1)
    end
end

---给予目标伤害
---@param _target PlayerInstance
function NpcGunBase:Damage(_target)
    ---暂时固定击中玩家的躯干
    NetUtil.Fire_C('PlayerBeHitEvent', _target, {{self.npcModel, self.gunId, self.damage, HitPartEnum.Body}})
end

---创建NPC使用的音频
function NpcGunBase:PreloadSound(_infoList)
    for i, v in pairs(_infoList) do
        self.m_soundCacheList[v] = {}
        for index = 1, 10 do
            local audio = world:CreateObject('AudioSource', 'Audio_' .. v, self.npcModel)
            if audio then
                self.m_soundCacheList[v][index] = audio
                audio.SoundClip = ResourceManager.GetSoundClip('WeaponPackage/Audio/' .. v)
                audio:SetActive(false)
                audio.PlayOnAwake = true
                ---给音频添加播放完成后置灰
                audio.OnComplete:Connect(
                    function()
                        audio:SetActive(false)
                    end
                )
            end
        end
    end
end

---创建NPC使用的特效
function NpcGunBase:PreloadEff(_infoList)
    for i, v in pairs(_infoList) do
        self.m_fireEffCacheList[v] = {}
        for index = 1, 10 do
            local eff = world:CreateInstance(v, v, self.model.Module.Origin)
            if eff then
                eff:SetActive(false)
                self.m_fireEffCacheList[v][index] = eff
                eff.LocalPosition = Vector3.Zero
            end
        end
    end
end

---播放声音
function NpcGunBase:PlayAudio(_fileName)
    if _fileName == '' or _fileName == nil then
        return
    end
    NetUtil.Broadcast(
        'WorldSoundEvent',
        'WeaponPackage/Audio/' .. _fileName,
        {Position = self.model.Position, Volume = 15}
    )
    --[[
    local res = self.m_soundCacheList[_fileName][1]
    for i, v in pairs(self.m_soundCacheList[_fileName]) do
        if v.ActiveSelf == false then
            res = v
        end
    end
    res:SetActive]]
end

---播放特效
function NpcGunBase:PlayEff(_effName)
    local res = self.m_fireEffCacheList[_effName][1]
    if not res or res:IsNull() then
        return
    end
    for i, v in pairs(self.m_fireEffCacheList[_effName]) do
        if not v.ActiveSelf then
            res = v
        end
    end
    res:SetActive(false)
    res:SetActive(true)
    invoke(
        function()
            if not res:IsNull() then
                res:SetActive(false)
            end
        end,
        2
    )
end

return NpcGunBase
