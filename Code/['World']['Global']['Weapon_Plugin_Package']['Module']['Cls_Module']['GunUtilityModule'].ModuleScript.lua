---@module GunUtility 枪械模块：枪械模块自身的工具函数
---@copyright Lilith Games, Avatar Team
---@author RopzTao
local GunUtility = class('GunUtility')

---初始化
function GunUtility:initialize()
    self.qualityConfig = {}
    for i, v in pairs(StringSplit(GunConfig.GlobalConfig.QualityConfig, '|')) do
        local value = StringSplit(v, ',', true)
        self.qualityConfig[i] = value
    end
end

---初始化枪械的配置
---@param _gun GunBase
function GunUtility:InitGunConfig(_gun)
    local id = _gun.gun_Id
    local config = GunConfig.GunConfig[id]
    ---枪械名字
    _gun.name = config.Name
    ---枪械描述
    _gun.des = config.Description
    ---枪械图标
    _gun.icon = config.Icon
    ---枪械选中图标
    _gun.selectedIcon = config.SelectedIcon
    ---枪械在附近列表中的优先级
    _gun.order = config.Order
    ---枪械的机械瞄准图片
    _gun.defaultAimImage = StringSplit(config.MechanicalAimImage, ':', false)
    ---腰射准心模式
    _gun.WaistAimMode = config.WaistAimMode
    ---枪械的后坐力配置
    _gun.recoilId = config.RecoilId
    ---枪械使用的动画的配置
    _gun.animationId = config.AnimationId
    ---枪械是否开启不可射击状态
    _gun.config_banShoot = config.BanShoot
    ---是否可以击中自己
    _gun.config_isHitSelf = config.IsHitSelf
    ---是否可以集中队友
    _gun.config_isHitFriend = config.IsHitFriend
    ---枪械可以装备的配件ID
    _gun.canBeEquipAccessory = StringSplit(config.CanBeEquipAccessory, ';', true)
    ---枪械伤害
    _gun.config_damage = config.Damage
    ---使用的弹夹ID
    _gun.magazineUsed = config.MagazineUsed
    ---枪械命中头部伤害倍率
    _gun.config_hitHeadDamageRate = config.HitHeadDamageRate
    ---枪械命中躯干伤害倍率
    _gun.config_hitBodyDamageRate = config.HitBodyDamageRate
    ---枪械命中四肢伤害倍率
    _gun.config_hitLimbDamageRate = config.HitLimbDamageRate
    ---射程
    _gun.config_distance = config.GunDistance
    ---枪械使用的类
    _gun.usedClass = config.UsedClass
    ---子弹实体的名字,在实体子弹的武器中会使用
    _gun.bulletName = config.BulletName
    ---子弹孔名字
    _gun.bulletHole = config.BulletHole
    ---子弹壳名称
    _gun.bulletShell = config.BulletShell
    ---是否自动装弹
    _gun.config_autoReload = config.AutoReload
    ---机瞄/开镜FOV,枪械默认的
    _gun.config_mechanicalAimFOV = config.MechanicalAimFOV
    ---腰间瞄准FOV
    _gun.config_waistAimFOV = config.WaistAimFOV
    ---射击速度,一秒钟可以发出多少子弹
    _gun.config_shootSpeed = config.ShootSpeed
    ---单次射击发射的弹片数量
    _gun.bulletPerShoot = config.BulletPerShoot
    ---每次射击是否只消耗一发子弹
    _gun.consumeSingleBulletPerShot = config.ConsumeSingleBulletPerShoot
    ---射击模式
    _gun.shootMode = StringSplit(config.ShootMode, ',', true)
    ---默认射击模式
    _gun.defaultShootMode = config.DefaultShootMode
    ---连发模式一的连发子弹数量
    _gun.rapidly_1 = config.Rapidly_1
    ---连发模式二的连发子弹数量
    _gun.rapidly_2 = config.Rapidly_2
    ---武器类型
    _gun.gunMode = config.GunMode
    ---是否开镜后无散射
    _gun.accurateAim = config.AccurateAim
    ---武器可以被装备到的位置
    _gun.canBeEquipPosition = config.CanBeEquipPosition
    ---从腰间瞄准切换到开镜瞄准需要的时间
    _gun.config_aimTime = config.AimTime
    ---退出瞄准需要的时间
    _gun.config_stopAimTime = config.StopAimTime
    local assistAimId = config.AssistAimId
    ---辅助瞄准的时间
    _gun.config_assistAimTime = GunConfig.AssistAim[assistAimId].Time
    ---腰射辅助瞄准距离
    _gun.config_assistAimDis0 = GunConfig.AssistAim[assistAimId].NoZoomDis
    ---开镜辅助瞄准距离
    _gun.config_assistAimDis1 = GunConfig.AssistAim[assistAimId].ZoomDis
    ---辅助瞄准拉枪比例
    _gun.config_assistAimRatio = GunConfig.AssistAim[assistAimId].Ratio
    ---一下上一整个弹夹的子弹还是一颗一颗
    _gun.reloadWithMagazines = config.ReloadWithMagazines
    ---上弹是否可打断
    _gun.canInterruptBulletLoad = config.CanInterruptBulletLoad
    ---着弹点特效
    _gun.hitEffect = config.HitEffect
    ---开火的枪口特效
    _gun.fireEffect = config.FireEffect
    ---子弹速度
    _gun.config_bulletSpeed = config.BulletSpeed
    ---伤害衰减,子弹飞行距离伤害衰减
    _gun.damageAttenuation = {}
    for k, v in pairs(StringSplit(config.DamageAttenuation, '|')) do
        local c = StringSplit(v, ';', true)
        table.insert(_gun.damageAttenuation, {Distance = c[1], Attenuation = c[2]})
    end
    ---报站伤害衰减,真实子弹爆炸后范围伤害衰减
    _gun.explosionDamageAttenuation = {}
    for k, v in pairs(StringSplit(config.ExplosionDamageAttenuation, '|')) do
        local c = StringSplit(v, ';', true)
        table.insert(_gun.explosionDamageAttenuation, {Distance = c[1], Attenuation = c[2]})
    end
    ---枪械装备在角色上,角色的动作状态
    _gun.characterAnimationMode = config.CharacterAnimationMode
    ---装入新弹匣或最后一枚子弹后，拉枪栓
    _gun.pumpAfterFinalLoad = config.PumpAfterFinalLoad
    ---开枪后是否应该拉枪栓
    _gun.pumpAfterFire = config.PumpAfterFire
    ---爆炸伤害每个骨骼节点的权重
    _gun.boneWeight = {}
    for k, v in pairs(StringSplit(config.BoneWeight, '|')) do
        local c = StringSplit(v, ':', false)
        _gun.boneWeight[c[1]] = tonumber(c[2])
    end
    ---命中角色将在多久后显示受击动画
    _gun.config_damageResponseWaitTime = config.DamageResponseWaitTime
    ---子弹是否受重力影响(只在真实子弹的枪上生效)
    _gun.config_gravityScale = config.GravityScale
    ---子弹爆炸半径
    _gun.config_explosionRange = config.ExplosionRange
    ---枪械的重量
    _gun.config_weight = config.EqWeight
end

---初始化弹夹的配置
---@param _gunMagazine GunMagazine
function GunUtility:InitGunMagazineConfig(_gunMagazine)
    local id = _gunMagazine.id
    local config = GunConfig.MagazineConfig[id]
    _gunMagazine.matchAmmo = config.MatchAmmo
    _gunMagazine.name = config.Name
    _gunMagazine.maxNum = config.MagazineMaxNum
    _gunMagazine.loadTime = config.LoadTime
    config = GunConfig.AmmoConfig[_gunMagazine.matchAmmo]
    _gunMagazine.ammoName = config.Name
    _gunMagazine.ammoDes = config.Des
    _gunMagazine.ammoIcon = config.Icon
    _gunMagazine.ammoHitTexture = config.HitTexture
    _gunMagazine.ammoModel = config.Model
end

---初始化后坐力的配置
---@param _gunRecoil GunRecoil
function GunUtility:InitGunRecoilConfig(_gunRecoil)
    local id = _gunRecoil.id
    local config = GunConfig.GunRecoilConfig[id]
    _gunRecoil.config_minError = config.MinError
    _gunRecoil.config_maxError = config.MaxError
    _gunRecoil.config_gunRecoil = config.GunRecoil
    _gunRecoil.config_gunRecoverRate = config.GunRecoverRate
    _gunRecoil.config_diffuseRecoverRate = config.DiffuseRecoverRate
    _gunRecoil.config_verticalJumpAngle = config.VerticalJumpAngle
    _gunRecoil.config_backTotal = config.BackTotal
    _gunRecoil.config_horizontalJumpRange = config.HorizontalJumpRange
    _gunRecoil.config_verticalJumpRange = config.VerticalJumpRange
    _gunRecoil.config_selfSpinRange = config.SelfSpinRange
    _gunRecoil.config_selfSpinMax = config.SelfSpinMax / 180 * math.pi
    --ui部分
    _gunRecoil.config_uiJumpAmpl = config.UIJumpAmpl
    _gunRecoil.config_uiJumpMax = config.UIJumpMax
    _gunRecoil.config_uiJumpDump = config.UIJumpDump
    _gunRecoil.config_uiJumpOmega = config.UIJumpOmega
    _gunRecoil.config_uiJumpAngle = config.UIJumpAngle
    --end
    _gunRecoil.config_shakeIntensity = config.ShakeIntensity
    _gunRecoil.config_diffuseFunction = config.DiffuseFunction
    _gunRecoil.config_jumpErrorScale = config.JumpErrorScale
    _gunRecoil.config_crouchErrorScale = config.CrouchErrorScale
end

---初始化枪械相机相关的配置
---@param _gunCamera WeaponCamera
function GunUtility:InitGunCameraConfig(_gunCamera)
    local id = _gunCamera.gunRecoil.id
    local config = GunConfig.GunRecoilConfig[id]
    ---振动阻尼
    _gunCamera.config_vibrationDump = config.VibrationDump
    ---振动频率（弧度）
    _gunCamera.config_vibrationOmega = config.VibrationOmega
    ---跳动时间
    _gunCamera.config_jumpTime = config.JumpTime
    ---FOV变化量
    _gunCamera.config_jumpFOV = config.JumpFOV
end

---初始化枪械配件相关的配置
---@param _gunAccessory WeaponAccessoryBase
function GunUtility:InitGunAccessoryConfig(_gunAccessory)
    local id = _gunAccessory.id
    local config = GunConfig.WeaponAccessoryConfig[id]
    _gunAccessory.name = config.Name
    _gunAccessory.icon = config.Icon
    _gunAccessory.location = config.Location
    if (_gunAccessory.location == 5) then
        _gunAccessory.sightImage = {}
        for k, v in pairs(StringSplit(config.SightImage, '|')) do
            local sightImageConfig = StringSplit(v, ':', false)
            _gunAccessory.sightImage[tonumber(sightImageConfig[1])] = {
                table.unpack(sightImageConfig, 2, #sightImageConfig)
            }
        end
    end
    ---配件在附近列表中的优先级
    _gunAccessory.order = config.Order
    _gunAccessory.model = config.Model
    _gunAccessory.isSilencer = config.IsSilencer
    _gunAccessory.des = config.Des

    _gunAccessory.aimFovRate = config.AimFovRate
    --瞄准的FOV,枪械自身的属性
    _gunAccessory.minErrorRate = config.MinErrorRate
    --
    _gunAccessory.maxErrorRate = config.MaxErrorRate
    --
    _gunAccessory.gunRecoverRate = config.GunRecoverRate
    --
    _gunAccessory.verticalJumpAngleRate = config.VerticalJumpAngleRate
    --
    _gunAccessory.horizontalJumpRangeRate = config.HorizontalJumpRangeRate
    --
    _gunAccessory.selfSpinRangeRate = config.SelfSpinRangeRate
    --
    _gunAccessory.jumpFovRate = config.JumpFovRate
    --
    _gunAccessory.bulletSpeedRate = config.BulletSpeedRate
    --子弹速度,枪械自身的属性
    _gunAccessory.magazineLoadTimeRate = config.MagazineLoadTimeRate
    --装弹速度,枪械弹夹的属性
    _gunAccessory.maxAmmoRate = {}
    --弹夹子弹上限,枪械弹夹的属性
    for k, v in pairs(StringSplit(config.MaxAmmoRate, '|')) do
        local maxAmmoConfig = StringSplit(v, ':', true)
        _gunAccessory.maxAmmoRate[maxAmmoConfig[1]] = maxAmmoConfig[2]
    end
    _gunAccessory.aimTimeRate = config.AimTimeRate
    --开镜速度,枪械自身的属性
    _gunAccessory.pickSound = config.PickSound
end

---创建枪械的缓存对象
---@param _gun GunBase
function GunUtility:CreateGunCacheObjects(_gun, _objNameList)
    local cacheConfig = GunConfig.GunCacheConfig[_gun.gun_Id]
    cacheConfig =
        cacheConfig or
        {FireEffect = '10;1', HitEffect = '10;1', BulletHole = '10;1', BulletShell = '10;1', BulletName = '5;1'}
    for i, v in pairs(cacheConfig) do
        local info = StringSplit(v, ';', true)
        if #info == 2 then
            cacheConfig[i] = {CacheNum = info[1], RecycleTime = info[2]}
        end
    end
    local objNameInfoList = {}
    for i, v in pairs(_objNameList) do
        _gun.m_cacheList_beingUsed[v] = {}
        _gun.m_cacheList_canBeUsed[v] = {}
        table.insert(
            objNameInfoList,
            {
                Name = v,
                CacheNum = cacheConfig[i].CacheNum,
                RecycleTime = cacheConfig[i].RecycleTime
            }
        )
    end
    invoke(
        function()
            local num = 0
            for k, v in pairs(objNameInfoList) do
                local cacheNum = v.CacheNum < 1 and 1 or v.CacheNum
                for i = 1, cacheNum do
                    local cacheObj = world:CreateInstance(v.Name, v.Name .. '_Cache', _gun.m_cache_folder)
                    if cacheObj then
                        cacheObj:SetActive(false)
                        local recycleTimeValue = world:CreateObject('FloatValueObject', 'RecycleTime', cacheObj)
                        recycleTimeValue.Value = v.RecycleTime
                        world.S_Event.WeaponObjCreatedEvent:Fire(_gun.character, cacheObj)
                        if _gun.m_cacheList_canBeUsed[v.Name][i] then
                            table.insert(_gun.m_cacheList_canBeUsed[v.Name], cacheObj)
                        else
                            _gun.m_cacheList_canBeUsed[v.Name][i] = cacheObj
                        end
                    end
                    num = num + 1
                    if num % 3 == 0 then
                        wait()
                    end
                    if not _gun.character then
                        return
                    end
                end
            end
        end
    )
end

---使用枪械的缓存对象,缓存对象在世界下,所有玩家都可看到
---@param _gun GunBase
function GunUtility:UseCacheObject(_gun, _objName, _autoRecycle, _attributeList, _parent, _type)
    local beUsedObj = _gun.m_cacheList_canBeUsed[_objName][1]
    if not beUsedObj or beUsedObj:IsNull() then
        if beUsedObj and beUsedObj:IsNull() then
            table.remove(_gun.m_cacheList_canBeUsed[_objName], 1)
        end
        beUsedObj = world:CreateInstance(_objName, _objName .. '_Cache', _gun.m_cache_folder)
        if not beUsedObj then
            ---尝试使用一个不存在的东西并且原型空间中也不存在
            return
        end
        local recycleTimeValue = world:CreateObject('FloatValueObject', 'RecycleTime', beUsedObj)
        recycleTimeValue.Value = 1
        world.S_Event.WeaponObjCreatedEvent:Fire(_gun.character, beUsedObj)
    else
        table.remove(_gun.m_cacheList_canBeUsed[_objName], 1)
    end
    table.insert(_gun.m_cacheList_beingUsed[_objName], beUsedObj)
    ---属性赋值
    if _parent then
        beUsedObj:SetParentTo(_parent, Vector3.Zero, EulerDegree(0, 0, 0))
    end
    for k, v in pairs(_attributeList) do
        beUsedObj[k] = v
    end
    ---将目标物体激活,invoke绕行特效播放位置不正确的问题
    --beUsedObj:SetActive(true)
    world.Players:BroadcastEvent('WeaponObjActiveChangeEvent', beUsedObj, true, _type, beUsedObj.Position)
    --[[invoke(function()
        wait()
        if beUsedObj and not beUsedObj:IsNull() then
            beUsedObj:SetActive(true)
        end
    end)]]
    ---若时间大于零则指定时间后回收,否则需要自行进行回收操作
    local recycleTime = beUsedObj.RecycleTime.Value
    if recycleTime > 0 and _autoRecycle then
        invoke(
            function()
                self:Recycle(_gun, _objName, beUsedObj)
            end,
            recycleTime
        )
    end
    return beUsedObj
end

---回收枪械的缓存对象
function GunUtility:Recycle(_gun, _objName, _usedObj)
    if not _usedObj or _usedObj:IsNull() then
        return
    end
    if not _usedObj:IsA('DecalObject') then
        _usedObj.Parent = _gun.m_cache_folder
        _usedObj:SetParentTo(_gun.m_cache_folder, Vector3.Zero, EulerDegree(0, 0, 0))
    end
    world.Players:BroadcastEvent('WeaponObjActiveChangeEvent', _usedObj, false)
    --_usedObj:SetActive(false)
    table.insert(_gun.m_cacheList_canBeUsed[_objName], _usedObj)
    TableUnique(_gun.m_cacheList_canBeUsed[_objName])
    for k, v in pairs(_gun.m_cacheList_beingUsed[_objName]) do
        if v == _usedObj then
            table.remove(_gun.m_cacheList_beingUsed[_objName], k)
        end
    end
end

---销毁枪械的缓存对象
---@param _gun GunBase
function GunUtility:DestroyCacheObject(_gun)
    local m_cacheList_beingUsed = _gun.m_cacheList_beingUsed
    local m_cacheList_canBeUsed = _gun.m_cacheList_canBeUsed

    if not m_cacheList_beingUsed or not m_cacheList_canBeUsed then
        return
    end
    --[[
    local num1, num2 = 0, 0
    for i, v in pairs(m_cacheList_beingUsed) do
        for i1, v1 in pairs(v) do
            num1 = num1 + 1
        end
    end
    for i, v in pairs(m_cacheList_canBeUsed) do
        for i1, v1 in pairs(v) do
            num2 = num2 + 1
        end
    end
    print(_gun.name, '一共需要销毁的缓存数量为', num1 + num2)]]
    local destroyObj = {}
    for k, v in pairs(m_cacheList_canBeUsed) do
        destroyObj[k] = MergeTables(m_cacheList_canBeUsed[k], m_cacheList_beingUsed[k])
    end
    invoke(
        function()
            local num = 0
            for k, v in pairs(destroyObj) do
                for k1, v1 in pairs(v) do
                    num = num + 1
                    if num % 5 == 0 then
                        wait()
                    end
                    if not v1:IsNull() then
                        v1:Destroy()
                    end
                end
            end
        end
    )
end

---判断一个武器是否可以装备一个配件
function GunUtility:CheckAcc2Weapon(_accId, _weaponId)
    local canBeEquipAccessoryList = StringSplit(GunConfig.GunConfig[_weaponId].CanBeEquipAccessory, ';', true)
    local res = false
    for k, v in pairs(canBeEquipAccessoryList) do
        if v == _accId then
            res = true
        end
    end
    return res
end

---获取一个武器的可装备的配件的所有位置
function GunUtility:GetWeaponAccLocations(_weaponId)
    local canBeEquipAccessoryList = StringSplit(GunConfig.GunConfig[_weaponId].CanBeEquipAccessory, ';', true)
    local locations_key = {}
    for k, v in pairs(canBeEquipAccessoryList) do
        local accConfig = GunConfig.WeaponAccessoryConfig[v]
        if accConfig then
            locations_key[accConfig.Location] = true
        end
    end
    local res = {}
    for k, v in pairs(locations_key) do
        table.insert(res, k)
    end
    return res
end

---获取一个武器使用的子弹的ID
function GunUtility:GetWeaponAmmoId(_weaponId)
    local matchMagazine = GunConfig.GunConfig[_weaponId].MagazineUsed
    local ammoId = GunConfig.MagazineConfig[matchMagazine].MatchAmmo
    return ammoId
end

---根据一把枪的ID和距离获取伤害衰减数值
---@param _type number 1为子弹飞行距离伤害衰减 2为爆炸后范围伤害衰减
---@param _gun GunBase 枪械
---@return number 伤害衰减的具体数值
function GunUtility:GetAttenuationByGunId(_type, _gun, _dis)
    if _type == 1 then
        ---获取子弹飞行距离伤害衰减
        local disAttenuation = _gun.damageAttenuation
        local len = #disAttenuation
        if len == 0 then
            return 0
        end
        for i = len, 1, -1 do
            if disAttenuation[i].Distance <= _dis then
                return disAttenuation[i].Attenuation
            end
        end
        return 0
    elseif _type == 2 then
        ---获取爆炸范围伤害衰减
        local explosionAttenuation = _gun.explosionDamageAttenuation
        local len = #explosionAttenuation
        if len == 0 then
            return 0
        end
        for i = len, 1, -1 do
            if explosionAttenuation[i].Distance <= _dis then
                return explosionAttenuation[i].Attenuation
            end
        end
        return 0
    end
end

---获取指定范围/角度内的可攻击单位
---@param _self PlayerInstance 自己的实体
---@param _isHitSelf boolean 是否可以击中自己
---@param _isHitFriend boolean 是否可以击中队友
---@param _angle number 范围角度
function GunUtility:GetEnemyByRange(_self, _isHitSelf, _isHitFriend, _dis, _angle, _pos)
    local resPlayers, resForts = {}, {}
    for i, v in pairs(FindAllPlayers()) do
        if not _isHitSelf and v == _self then
            goto Continue
        end
        if not v.PlayerType then
            goto Continue
        end
        if not _isHitFriend and v.PlayerType.Value == _self.PlayerType.Value and v ~= _self then
            goto Continue
        end
        local dis = (v.Position - _pos).Magnitude
        if dis > _dis then
            goto Continue
        end
        local dir = (v.Position - _self.Position).Normalized
        if _angle < 90 then
            if Vector3.Angle(_self.Forward, dir) > _angle then
                goto Continue
            end
        else
            if Vector3.Angle(Vector3.Zero - _self.Forward, dir) < 180 - _angle then
                goto Continue
            end
        end
        table.insert(resPlayers, v)
        ::Continue::
    end
    if world.FortFolder then
        for i, v in pairs(world.FortFolder:GetChildren()) do
            if not _isHitSelf and v.Owner.Value == _self then
                goto Continue
            end
            if not v.Owner.Value.PlayerType then
                goto Continue
            end
            if not _isHitFriend and v.Owner.Value.PlayerType.Value == _self.PlayerType.Value then
                goto Continue
            end
            local dis = (v.Position - _pos).Magnitude
            if dis > _dis then
                goto Continue
            end
            local dir = (v.Position - _self.Position).Normalized
            if _angle < 90 then
                if Vector3.Angle(_self.Forward, dir) > _angle then
                    goto Continue
                end
            else
                if Vector3.Angle(-_self.Forward, dir) < _angle then
                    goto Continue
                end
            end
            table.insert(resForts, v)
            ::Continue::
        end
    end
    return resPlayers, resForts
end

---获取一个对象是否可以在指定的画质下显示
---@param _type number 对象类型
---@param _quality number 画质枚举值
---@return boolean 真值为可以显示,假值为不可以显示
function GunUtility:GetActiveByQuality(_type, _quality)
    local config = self.qualityConfig[_quality]
    if not config then
        return false
    end
    for i, v in pairs(config) do
        if v == _type then
            return true
        end
    end
    return false
end

return GunUtility
