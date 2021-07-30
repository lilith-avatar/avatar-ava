---@module GunBase 枪械模块：所有枪支的基类
---@copyright Lilith Games, Avatar Team
---@author Sharif Ma
local GunBase = class('GunBase')
if localPlayer == nil then
---模块必须在客户端运行
---return
end

local accValueName = {
    [WeaponAccessoryTypeEnum.Muzzle] = 'muzzle',
    [WeaponAccessoryTypeEnum.Grip] = 'grip',
    [WeaponAccessoryTypeEnum.Magazine] = 'magazine',
    [WeaponAccessoryTypeEnum.Sight] = 'sight',
    [WeaponAccessoryTypeEnum.Butt] = 'butt'
}

---GunBase类的构造函数
---@param _character PlayerInstance 枪支持有的角色
---@param _root Object 枪支绑定的锚点
---@param _gun Accessory 枪械的配件实体对象
function GunBase:initialize(_character, _root, _gun, _overrideRayCast)
    self:EarlyInitialize()
    print('实例化枪械')
    ---枪械对象
    self.gun = _gun
    _gun.Player.Value = localPlayer
    ---枪械配置的id
    self.gun_Id = _gun.ID.Value
    ---枪械的基准锚点
    self.root = _root
    ---枪械的所属角色
    self.character = _character
    ---枪口的位置点
    self.muzzleObj = _gun.Module.Origin
    ---枪管方向
    self.dir = Vector3.Zero
    ---投弹口,子弹壳将会从这个点射出
    self.toss = _gun.Module.Toss

    ---枪械配置初始化
    GunBase.static.utility:InitGunConfig(self)

    --枪械自身的变量,非配置
    ---枪械是否装备在角色身上
    self.m_isDraw = false
    ---是否开镜
    self.m_isZoomIn = false
    ---当前连发模式下剩余的子弹数量
    self.m_rapidlyRemainingBullets = 1
    ---当前的射击模式
    self.m_curShootMode = self.defaultShootMode
    ---上一帧是否开火了
    self.m_hasJustFired = false
    ---等待开火时间,此时间内会一直开火
    self.m_fireWait = 0
    self.m_isGoingToFire = false
    ---下一帧是否要开火
    self.m_isFiringOnNextUpdate = false
    ---武器是否允许开火
    self.m_isAllowed = true
    self.m_wasAllowedAndFiring = false

    ---下一帧尝试换弹夹
    self.m_isGoingToReloadMagazine = false
    ---下一帧开始换弹夹
    self.m_isReloadOnNextUpdate = false
    ---换弹等待时间,此时间内需要玩家播放动作
    self.m_reloadWait = 0
    ---正在装填中
    self.m_onReload = false

    ---是否禁止击中自己
    self.m_isIgnoringSelf = true
    ---枪在任何情况下是否都可以开火
    self.m_hasFireCondition = true
    ---枪开火的目标
    self.m_fireConditionSide = 1

    ---下一帧是否要拉枪栓
    self.m_isGoingToPump = false
    ---下一帧开始拉枪栓
    self.m_isPumpNextUpdate = false
    ---拉枪栓等待时间
    self.m_pumpWait = 0
    ---正在拉枪栓中
    self.m_isPumping = false
    ---是否正在等待拉枪栓
    self.m_isWaitingPump = false
    --- 开镜状态下,尝试拉枪栓
    self.m_zoomInTryPump = false
    --- 是否正在掏枪
    self.m_isWithDrawing = false

    ---枪械上装备的配件列表
    self.m_weaponAccessoryList = {}
    ---枪口配件
    self.m_weaponAccessoryList.muzzle = nil
    ---握把配件
    self.m_weaponAccessoryList.grip = nil
    ---弹夹配件
    self.m_weaponAccessoryList.magazine = nil
    ---枪托配件
    self.m_weaponAccessoryList.butt = nil
    ---瞄准镜
    self.m_weaponAccessoryList.sight = nil

    ---覆盖,使用自定义的射线
    self.m_isUsingCustomRayCast = _overrideRayCast and true or false
    self.m_customRayCastOrigin = _overrideRayCast and _overrideRayCast.Origin()
    self.m_customRayCastTarget = function(dist)
        return _overrideRayCast.Target(dist)
    end

    --枪械的事件绑定
    ---拾取武器
    self.pickWeapon = EventMgr:new('PickWeapon', self)
    ---掏出武器
    self.drawWeapon = EventMgr:new('DrawWeapon', self)
    ---收回武器
    self.withDrawWeapon = EventMgr:new('WithDrawWeapon', self)
    ---开始装弹
    self.magazineLoadStarted = EventMgr:new('MagazineLoadStarted', self)
    ---装满子弹时的回调
    self.fullyLoaded = EventMgr:new('FullyLoaded', self)
    ---开始装弹时的回调
    self.bulletLoadStarted = EventMgr:new('BulletLoadStarted', self)
    ---每发子弹上弹完成的回调
    self.bulletLoaded = EventMgr:new('BulletLoaded', self)
    ---上弹完成时的回调
    self.reloadFinished = EventMgr:new('reloadFinished', self)
    ---拉枪栓的回调
    self.pumpStarted = EventMgr:new('PumpStarted', self)
    ---拉完枪栓的回调
    self.pumped = EventMgr:new('Pumped', self)
    ---开了一枪后的回调
    self.fired = EventMgr:new('Fired', self)
    ---放空枪时候的回调
    self.emptyFire = EventMgr:new('EmptyFire', self)
    ---开始开火回调
    self.fireStarted = EventMgr:new('FireStarted', self)
    ---开火结束的回调
    self.fireStopped = EventMgr:new('FireStopped', self)
    ---击中的回调
    self.successfullyHit = EventMgr:new('SuccessfullyHit', self)
    ---击中靶子的回调
    self.successfullyHitTarget = EventMgr:new('SuccessfullyHitTarget', self)
    ---开镜的回调
    self.aimIn = EventMgr:new('AimIn', self)
    ---关镜的回调
    self.aimOut = EventMgr:new('AimOut', self)

    self.m_bulletSpeedRateTable = {}
    self.m_bulletSpeedRateScale = 1

    self.m_cacheList_beingUsed = {}
    self.m_cacheList_canBeUsed = {}

    ---@type GunMagazine 枪械的弹夹
    self.m_magazine = GunMagazine:new(self)
    ---@type GunRecoil 枪械的后坐力
    self.m_recoil = GunRecoil:new(self)
    ---@type WeaponCamera 枪械的相机控制类
    self.m_cameraControl = WeaponCamera:new(self.m_recoil)
    ---@type WeaponGUI 枪械的GUI
    self.m_gui = WeaponGUI:new(self)
    ---@type GunAnimation 枪械的动画控制类
    self.m_animationControl = GunAnimation:new(self)
    ---@type GunSound 枪械的音效
    self.m_sound = GunSound:new(self, self.root, GunBase.static.utility)
    self:LaterInitialize()
    --枪械初始的一些操作
    self.pickWeapon:Trigger()
    self.gun:SetActive(false)
    self.gun.CollisionGroup = self.character.CollisionGroup
    --- 玩家死亡后触发
    local function CharacterDead()
        self.m_isFiringOnNextUpdate = false
        self.m_fireWait = 0
        self.m_isGoingToFire = false
    end
    --- 玩家重生后触发
    local function CharacterReborn()
        self.m_magazine:LoadMagazine()
        self.m_magazine.m_ammoInventory:SetCount(999)
        self.m_isFiringOnNextUpdate = false
        self.m_fireWait = 0
        self.m_isGoingToFire = false
    end
    self.characterDeadFunc = CharacterDead
    self.characterRebornFunc = CharacterReborn
    self.character.OnDead:Connect(CharacterDead)
    self.character.OnSpawn:Connect(CharacterReborn)

    self.autoFireAim = false
end

---枪械的更新函数
function GunBase:Update(_deltaTime)
    if self.m_isWithDrawing then
        return
    end
    if self.m_isGoingToFire then
        self.m_isFiringOnNextUpdate = true
    end
    ---自动装弹开启后进行装弹监测
    if self.config_autoReload then
        if
            self.m_magazine.m_isEmptyLoaded and self.m_magazine.m_canLoad and not self.m_onReload and
                not self.m_isPumping
         then
            self:LoadMagazine()
        end
    end
    ---上一帧开火了并且需要拉枪栓,并且当前没有在装子弹和正在拉枪栓的过程中
    if self.pumpAfterFire and self.m_hasJustFired and not self.m_onReload and not self.m_isPumping then
        if self.m_isZoomIn then
            self.m_isWaitingPump = true
        else
            self:PumpStart()
        end
    end
    if self.m_zoomInTryPump and self.m_isWaitingPump then
        self.m_zoomInTryPump = false
        self:PumpStart()
    end

    ---准备在下一帧进行换弹操作
    if self.m_isGoingToReloadMagazine then
        self.m_onReload = true
        self.m_isReloadOnNextUpdate = true
        self.m_isAllowed = false
        self.m_reloadWait = self.m_magazine:GetLoadTime()
    end

    ---准备在下一帧进行拉枪栓操作
    if self.m_isGoingToPump then
        self.m_pumpMakeShell = false
        self.m_isPumping = true
        self.m_isPumpNextUpdate = true
        self.m_isAllowed = false
        self.m_pumpWait = 1 / self.config_shootSpeed
    end

    local isAllowedAndFiring = self.m_isGoingToFire and self.m_isAllowed
    ---进行开始射击/停止射击/开始换子弹的事件触发
    if self.character then
        if isAllowedAndFiring and not self.m_wasAllowedAndFiring then
            self.fireStarted:Trigger()
        end

        if not isAllowedAndFiring and self.m_wasAllowedAndFiring then
            self.fireStopped:Trigger()
        end

        if self.m_isGoingToPump then
            ---当前正准备拉枪栓
            self.pumpStarted:Trigger()
            self.m_isGoingToPump = false
        end

        if self.m_isGoingToReloadMagazine then
            ---当前正准备换子弹
            if self.reloadWithMagazines then
                self.magazineLoadStarted:Trigger() ---触发开始换整个弹夹的事件
            else
                self.bulletLoadStarted:Trigger() ---触发开始上弹的事件
            end
            if self.m_isZoomIn then
                self:MechanicalAimStop()
            end
            self.m_isGoingToReloadMagazine = false
        end
    end
    self.m_wasAllowedAndFiring = isAllowedAndFiring

    self.m_fireWait = self.m_fireWait - _deltaTime
    self.m_reloadWait = self.m_reloadWait - _deltaTime
    self.m_pumpWait = self.m_pumpWait - _deltaTime
    if (self.m_pumpWait < 0.8 / self.config_shootSpeed and self.m_pumpWait > 0 and self.m_aimBeforePump) then
        self:MechanicalAimStop()
    end
    if
        (self.m_pumpWait < 0.6 / self.config_shootSpeed and self.m_pumpWait > 0 and self.m_isPumping and
            not self.m_pumpMakeShell)
     then
        self:MakeBulletShell()
        self.m_pumpMakeShell = true
    end

    ---检查当前换弹操作是否结束
    if self.m_hasJustFired and self.canInterruptBulletLoad then
        ---上一帧开火了,需要中断换弹操作
        self.m_reloadWait = 0
        self.m_isAllowed = true
        self.m_isReloadOnNextUpdate = false
        self.m_onReload = false
    else
        if self.m_isReloadOnNextUpdate and self.m_reloadWait < 0 then
            if self.reloadWithMagazines then
                ---当前是一下换整个弹夹
                self.m_isAllowed = true
                self.m_isReloadOnNextUpdate = false
                self.m_magazine:LoadMagazine()
                self.m_onReload = false
                self.reloadFinished:Trigger()
            else
                ---当前是一发一发子弹换弹
                self.m_magazine:LoadOneBullet()
                self.bulletLoaded:Trigger()
                ---换一发子弹完成
                if self.m_magazine:UpdateLoadPercentage() ~= 100 then
                    ---换完子弹后弹药没有满,需要继续换弹
                    if self.m_magazine:UpdateCanLoad() then
                        ---可以换弹
                        self.m_isAllowed = self.canInterruptBulletLoad
                        self.m_isReloadOnNextUpdate = true
                        self.m_onReload = true
                        self.m_reloadWait = self.m_magazine:GetLoadTime()
                    else
                        ---不能换弹了
                        self.m_isAllowed = true
                        self.m_isReloadOnNextUpdate = false
                        self.m_onReload = false
                        self.reloadFinished:Trigger()
                    end
                else
                    ---换完子弹后弹药已经满了
                    self.m_isAllowed = true
                    self.m_isReloadOnNextUpdate = false
                    self.m_onReload = false
                    self.reloadFinished:Trigger()
                end
            end
        end
    end

    ---检查当前拉强刷操作是否结束
    if self.m_isPumpNextUpdate and self.m_pumpWait < 0 then
        self.m_isAllowed = true
        self.m_isPumpNextUpdate = false
        self.m_isPumping = false
        self.m_isWaitingPump = false
        self.pumped:Trigger()
        if (self.m_aimBeforePump) and not self.autoFireAim then
            self.m_aimBeforePump = false
            self:MechanicalAimStart()
        end
    end
    self.m_hasJustFired = false
    ---检查开火状态
    if self.m_isFiringOnNextUpdate and self.m_isAllowed then
        ---允许开火
        local fireDelay = 1 / self.config_shootSpeed
        local delay = 0
        ---若一发子弹的时间小于一帧的时间,则一帧内需要开火多次
        local hasFired = false
        while self.m_fireWait < 0 do
            for i = 1, self.bulletPerShoot, 1 do
                if self.m_magazine.m_isEmptyLoaded then
                    ---弹夹内没有子弹,停止开火
                    break
                end
                ---发射多发弹片,需要调用多次Fire函数
                if self:Fire(delay, not self.consumeSingleBulletPerShot) then
                    self.m_rapidlyRemainingBullets = self.m_rapidlyRemainingBullets - 1
                    hasFired = true
                else
                    self.m_rapidlyRemainingBullets = 0
                end
            end
            ---若已经开了一枪了并且是只消耗一发子弹的,需要消耗一发子弹
            if hasFired and self.consumeSingleBulletPerShot then
                self:Consume()
            end
            if hasFired then
                if not self.pumpAfterFire then
                    self:MakeBulletShell()
                end
                self.fired:Trigger()
            else
                ---没有子弹
                self.emptyFire:Trigger()
            end
            delay = delay + fireDelay
            self.m_fireWait = self.m_fireWait + fireDelay
            self.m_isGoingToFire = false
        end
        if hasFired then
            ---已经发射子弹了
            self.m_recoil:Fire()
            self.m_cameraControl:InputRecoil(self.m_recoil)
        end
    end

    ---当前不允许开枪,则将枪中连发剩余子弹清零
    if not self.m_isAllowed then
        self.m_rapidlyRemainingBullets = 0
    end

    ---根据不同的开火模式进行数据重置
    if self.m_curShootMode ~= FireModeEnum.Auto then
        if self.m_rapidlyRemainingBullets <= 0 or self.m_magazine.m_isEmptyLoaded then
            self.m_rapidlyRemainingBullets = 0
            self.m_isGoingToFire = false
            self.m_isFiringOnNextUpdate = false
        end
        if self.m_curShootMode == FireModeEnum.Single then
            self.m_isGoingToFire = false
            self.m_isFiringOnNextUpdate = false
        end
    else
        self.m_rapidlyRemainingBullets = self.m_rapidlyRemainingBullets <= 0 and 0 or self.m_rapidlyRemainingBullets
        self.m_isGoingToFire = false
        self.m_isFiringOnNextUpdate = false
    end

    self.m_fireWait = self.m_fireWait < 0 and 0 or self.m_fireWait
    self.m_reloadWait = self.m_reloadWait < 0 and 0 or self.m_reloadWait
    self.m_pumpWait = self.m_pumpWait < 0 and 0 or self.m_pumpWait

    ---其他控制类的更新

    self.m_recoil:Update(_deltaTime)
    self.m_gui:Update(_deltaTime)
    self.m_animationControl:Update(_deltaTime)
    self.m_cameraControl:Update(_deltaTime)
    self.m_magazine:Update()

    self.m_bulletSpeedRateTable = {}
    for k, v in pairs(self.m_weaponAccessoryList) do
        self.m_bulletSpeedRateTable[k] = v.bulletSpeedRate
    end
    self:RefreshScales()
end

---枪械的60帧更新函数,务必保证里面的逻辑较少并且不会修改upvalue和枪械类的变量
function GunBase:FixUpdate(_dt)
    self.m_cameraControl:FixUpdate(_dt)
    self.m_gui:FixUpdate(_dt)
    self.m_animationControl:FixUpdate(_dt)
end

---在实例化的前面执行
function GunBase:EarlyInitialize()
    ---创建世界缓存文件夹
    if not world.Cache then
        world:CreateObject('NodeObject', 'Cache', world)
    end
    ---创建自身缓存文件夹
    if not world.Cache[localPlayer.Name] then
        world:CreateObject('NodeObject', localPlayer.Name, world.Cache)
    end
    ---自身的缓存文件夹
    self.m_cache_folder = world.Cache[localPlayer.Name]
end

---在实例化的后面执行
function GunBase:LaterInitialize()
    self:CreateCacheObjects()
end

---在析构前面执行
function GunBase:EarlyDestructor()
    self:DestroyCacheObject()
end

---析构函数
function GunBase:Destructor()
    self:EarlyDestructor()
    self.gun.CollisionGroup = 3
    self.m_gui:SetVisible(false)
    self.m_magazine:RecordingBulletsLeft(true)
    self.gun:SetActive(true)
    ---将枪上的配件卸下
    for k, v in pairs(self.m_weaponAccessoryList) do
        v:UnEquipFromWeapon()
        self.m_weaponAccessoryList[k] = nil
    end
    ---析构枪上的自有类
    self.m_cameraControl:Destructor()
    self.m_magazine:Destructor()
    self.m_gui:Destructor()
    self.m_recoil:Destructor()
    self.m_animationControl:Destructor()
    self.m_sound:Destructor()
    ---清除枪械所有者
    self.gun.Player.Value = nil
    ---清除枪械绑定在别处的事件
    self.character.OnDead:Disconnect(self.characterDeadFunc)
    self.character.OnSpawn:Disconnect(self.characterRebornFunc)

    ClearTable(self, {'m_cacheList_beingUsed', 'm_cacheList_canBeUsed', 'm_cache_folder'})
    self = nil
end

---创建枪械的缓存对象
function GunBase:CreateCacheObjects()
    local nameList = {
        FireEffect = self.fireEffect,
        HitEffect = self.hitEffect,
        BulletHole = self.bulletHole,
        BulletShell = self.bulletShell,
        BulletName = self.bulletName
    }
    GunBase.static.utility:CreateGunCacheObjects(self, nameList)
end

---销毁枪械的缓存对象
function GunBase:DestroyCacheObject()
    GunBase.static.utility:DestroyCacheObject(self)
end

---枪械上装备一个配件
---@param _accessory WeaponAccessoryBase
---@return boolean 真表示装备成功,假表示装备失败
function GunBase:EquipAccessory(_accessory)
    local accessoryId = _accessory.id
    local canBeEquip = false
    for k, v in pairs(self.canBeEquipAccessory) do
        if v == accessoryId then
            canBeEquip = true
        end
    end
    if not canBeEquip then
        return false
    end

    local origin = self.m_weaponAccessoryList[accValueName[_accessory.location]]
    self.m_weaponAccessoryList[accValueName[_accessory.location]] = _accessory
    _accessory:EquipToWeapon(self)
    return true, origin
end

---枪械上卸载一个配件
---@param _locationOrCls any 要卸载的位置或者指定的配件对象
function GunBase:UnEquipAccessory(_locationOrCls)
    if type(_locationOrCls) == 'number' then
        self.m_weaponAccessoryList[accValueName[_locationOrCls]]:UnEquipFromWeapon()
        self.m_weaponAccessoryList[accValueName[_locationOrCls]] = nil
    elseif type(_locationOrCls) == 'table' then
        for k, v in pairs(self.m_weaponAccessoryList) do
            if v == _locationOrCls then
                self.m_weaponAccessoryList[k]:UnEquipFromWeapon()
                self.m_weaponAccessoryList[k] = nil
            end
        end
    end
end

---换弹夹,换弹夹的的时候不能拉枪栓
function GunBase:LoadMagazine()
    if self.m_isDraw and not self.m_isPumping and self.m_magazine.m_canLoad and not self.m_onReload then
        self.m_isGoingToReloadMagazine = true
    end
end

---拉枪栓,拉枪栓的时候不能换子弹
function GunBase:PumpStart()
    if self.m_isDraw and not self.m_onReload then
        self.m_isGoingToPump = true
        self.m_aimBeforePump = self.m_isZoomIn
    end
end

---开枪后的弹壳抛射
function GunBase:MakeBulletShell()
    if self.toss == nil then
        return
    end
    local temp = EulerDegree(180 * math.random(), 0, 180 * math.random())
    local shell =
        GunBase.static.utility:UseCacheObject(
        self,
        self.bulletShell,
        true,
        {
            Position = self.toss.Position,
            Forward = self.toss.Forward,
            LinearVelocity = 2 * math.random() * RandomRotate(self.toss.Right, 30) +
                Vector3(localPlayer.LinearVelocity.x, 0, localPlayer.LinearVelocity.z),
            Block = false,
            Rotation = temp
        },
        nil,
        ObjectTypeEnum.Shell
    )
end

---开枪后的枪口火光
function GunBase:MakeFireEffect()
    GunBase.static.utility:UseCacheObject(
        self,
        self.fireEffect,
        true,
        {Position = self.muzzleObj.Position},
        self.muzzleObj,
        ObjectTypeEnum.FireEff
    )
end

---开枪后创建子弹,默认为直接在命中点创建一个弹孔,若命中的是玩家,则不会创建
function GunBase:MakeBullet(_endObj, _endPos, _endNorm)
    if not _endObj or _endObj:IsNull() then
        ---未命中任何物体
        return
    end
    if ParentPlayer(_endObj) then
        ---命中的是玩家
        return
    end
    GunBase.static.utility:UseCacheObject(
        self,
        self.bulletHole,
        true,
        {Position = _endPos, Up = _endNorm, Size = Vector3(0.07, 0.07, 0.07)},
        nil,
        ObjectTypeEnum.Hole
    )
end

---子弹落地调用,创建爆炸特效
function GunBase:MakeHitEffect(_endPos)
    GunBase.static.utility:UseCacheObject(self, self.hitEffect, true, {Position = _endPos}, nil, ObjectTypeEnum.HitEff)
end

---禁止击中自己
---@param _ignore boolean 是否禁止击中自己
function GunBase:IgnoreSelf(_ignore)
    self.m_isIgnoringSelf = _ignore
end

---若瞄准是自己阵营的玩家则不允许开火
function GunBase:SetFireCondition(_side)
    self.m_hasFireCondition = true
    self.m_fireConditionSide = _side
end

---使枪在任何情况下均能开火
function GunBase:CancelFireCondition()
    self.m_hasFireCondition = false
end

---鼠标按下后尝试开一枪就停止
function GunBase:TryFireOneBullet()
    if self.m_isDraw then
        self.m_isGoingToFire = true
        if self.m_curShootMode == FireModeEnum.Single then
            ---单点模式
            self.m_rapidlyRemainingBullets = 1
        elseif self.m_curShootMode == FireModeEnum.Rapidly_1 then
            ---连发模式1
            self.m_rapidlyRemainingBullets = self.rapidly_1
        elseif self.m_curShootMode == FireModeEnum.Rapidly_2 then
            ---连发模式2
            self.m_rapidlyRemainingBullets = self.rapidly_2
        end
    end
end

---鼠标按住后尝试一直开枪
function GunBase:TryKeepFire()
    ---只有全自动模式的枪才会响应
    if self.m_isDraw and self.m_curShootMode == FireModeEnum.Auto then
        self.m_isGoingToFire = true
    end
end

---鼠标抬起后尝试拉栓(开镜模式,且配置了拉栓)
function GunBase:TryPump(_bool)
    if self.pumpAfterFire and self.m_isZoomIn and not self.m_isPumping then
        ---开枪后要拉栓并且现在是开镜状态
        self.m_zoomInTryPump = true
    end

    if _bool == nil then
        return
    end
    self.autoFireAim = _bool
end

---开始机械瞄准/开镜瞄准
function GunBase:MechanicalAimStart()
    if self.m_isZoomIn or not self.m_isDraw then
        return
    end
    if not self.character.IsOnGround or self.m_isPumping or self.m_onReload then
        return
    end
    self.m_isZoomIn = true
    self.m_cameraControl:MechanicalAimStart()
    self.m_gui:MechanicalAimStart()
    self.aimIn:Trigger()
end

---停止机械瞄准/开镜瞄准
function GunBase:MechanicalAimStop()
    if not (self.m_isZoomIn and self.m_isDraw) then
        return
    end
    self.m_isZoomIn = false
    self.m_gui:MechanicalAimStop()
    self.m_cameraControl:MechanicalAimStop()
    self.aimOut:Trigger()
end

---收枪
function GunBase:WithdrawGun()
    if not self.m_isDraw then
        return
    end
    self.m_aimBeforePump = false
    if self.m_isZoomIn then
        print('开镜状态下收枪')
        self:MechanicalAimStop()
    end
    self.m_cameraControl:OnUnEquipWeapon(true)
    self.character.AnimationMode = 0
    self.m_gui:SetVisible(false)
    self.gun:SetActive(false)
    self.character.Avatar.RightHandTarget = nil
    if self.m_onReload then
        ---收枪时候当前在换弹,需要触发换弹结束
        self.m_reloadWait = 0
        self.m_isReloadOnNextUpdate = false
        self.m_onReload = false
        self.m_isAllowed = true
        self.reloadFinished:Trigger()
    end
    self.m_isDraw = false
    self.withDrawWeapon:Trigger()
end

---掏枪,接受一些初始化参数（用于不同枪之间的数据交换）
function GunBase:DrawGun(info)
    if self.m_isDraw then
        return
    end
    self.m_isWithDrawing = true
    info = info or {}
    self.m_isDraw = true
    self.m_aimBeforePump = false
    self.character.AnimationMode = self.characterAnimationMode
    self.m_gui:SetVisible(true)

    self.m_cameraControl:OnEquipWeapon(self, info)
    self.gun:SetActive(true)
    self.character.Avatar.RightHandTarget = self.gun
    if self.m_isWaitingPump then
        self:PumpStart()
    end
    self.drawWeapon:Trigger()
    invoke(
        function()
            self.m_isWithDrawing = false
        end,
        1
    )
end

---消耗子弹
function GunBase:Consume()
    self.m_magazine:Consume()()
end

---切换射击模式
function GunBase:ChangeShootMode()
    if self.m_isDraw and self.m_isAllowed then
        if #self.shootMode > 0 then
            ---有多种射击模式
            local nextIndex
            for k, v in pairs(self.shootMode) do
                if v == self.m_curShootMode then
                    nextIndex = k + 1
                    break
                end
            end
            if self.shootMode[nextIndex] == nil then
                nextIndex = 1
            end
            self.m_curShootMode = self.shootMode[nextIndex]
        end
        return self.m_curShootMode
    end
end

---枪口位置
function GunBase:RayCastOrigin()
    return self.m_isUsingCustomRayCast and self.m_customRayCastOrigin or
        localPlayer.Position + 0.5 * localPlayer.Forward + (localPlayer.CharacterHeight - 0.1) * Vector3.Up
end

---子弹的目标位置
function GunBase:RayCastTarget()
    local info, isTarget = self.m_cameraControl:GetTarget()
    if (isTarget) then
        return info
    else
        return info * self.config_distance + self.muzzleObj.Position
    end
end

---向指定方向做射线检测
function GunBase:OverloadRayCast(_dir)
    local target = self:RayCastOrigin() + _dir * self.config_distance
    local info = Physics:RaycastAll(self:RayCastOrigin(), target, false)
    local result = {}
    result.HitPoint = target
    if not info:HasHit() then
        return result
    end

    ---判定命中靶子或者障碍物
    for i, v in pairs(info.HitObjectAll) do
        if ParentPlayer(v) and ParentPlayer(v) ~= localPlayer then
            break
        end
        ---对象Block打开,且不为空气墙也不是玩家
        if v.Block and v.CollisionGroup ~= 10 and not v:FindNearestAncestorOfType('Independent') then
            result.HitPoint = info.HitPointAll[i]
            result.HitObject = v
            result.HitNormal = info.HitNormalAll[i]
            if string.startswith(v.Name, 'Target_') then
                ---碰撞是靶子
                result.IsTarget = true
            ---print('碰撞是靶子')
            end
            return result
        end
    end

    ---判定命中玩家的部位,判定成功后直接返回
    for i, v in pairs(info.HitObjectAll) do
        local player = ParentPlayer(v)
        if player and (v.Name == 'HeadPoint' or v.Name == 'BodyPoint' or v.Name == 'LimbPoint') then
            ---玩家是否初始化成功判断
            if not player.PlayerType then
                goto Continue
            end
            ---玩家是否死亡判断
            if player.Health <= 0 then
                goto Continue
            end
            ---判断是否需要击中自身
            if not self.config_isHitSelf and player == localPlayer then
                goto Continue
            end
            ---判断是否有友军伤害
            if not self.config_isHitFriend and player.PlayerType.Value == self.character.PlayerType.Value then
                goto Continue
            end
            ---命中了玩家
            result.HitPoint = info.HitPointAll[i]
            result.HitObject = player
            result.HitNormal = info.HitNormalAll[i]
            if v.Name == 'HeadPoint' then
                ---命中头部
                result.HitPart = HitPartEnum.Head
            elseif v.Name == 'BodyPoint' then
                ---命中躯干
                result.HitPart = HitPartEnum.Body
            elseif v.Name == 'LimbPoint' then
                ---命中四肢
                result.HitPart = HitPartEnum.Limb
            end
            return result
        end
        ::Continue::
    end
    --table.dump(info.HitObjectAll)
    ---未命中任何对象,返回空表
    return result
end

---计算从原点到目标的方向，这个结果考虑了枪口误差
function GunBase:CalculateRayCastDirection()
    local direction = (self:RayCastTarget() - self:RayCastOrigin()).Normalized
    if self.m_animationControl.noShootingState then
        ---当前为不可射击状态
        direction = self.muzzleObj.Forward
    end
    if (self.m_isZoomIn and self.accurateAim) then
        return direction
    end
    return RandomRotate(direction, self.m_recoil.currentError)
end

---使用射线发射子弹（延迟，消耗一颗子弹）
function GunBase:Fire(delay, consume)
    local isFriend = false
    local direction = self:CalculateRayCastDirection()
    local hit = self:OverloadRayCast(direction)
    --table.dump(hit)
    if not isFriend and hit then
        local endPos = hit.HitPoint
        local endNorm = hit.HitNormal
        local endObj = hit.HitObject

        if consume then
            self:Consume()
        end

        if not hit.HitObject or hit.HitObject:IsNull() then
            endPos = self:RayCastOrigin() + self.config_distance * direction
        end

        --self:MakeFireEffect()
        self:MakeBullet(endObj, endPos, endNorm)
        --self:MakeHitEffect(endPos)

        if hit.HitPart then
            ---命中了玩家或者玩家的炮台
            self:Damage(hit)
        end

        if hit.IsTarget then
            ---命中靶子
            hit.Damage = self.config_damage
            self.successfullyHitTarget:Trigger(hit)
        end

        self.m_hasJustFired = true
        return true
    else
        self.m_hasJustFired = true
        return false
    end
end

---给予命中的玩家一定的伤害,基类会计算子弹距离伤害衰减
function GunBase:Damage(_hit)
    local hitPos = _hit.HitPoint
    local attenuation
    if not hitPos then
        ---未传命中点,默认没有伤害衰减
        attenuation = 0
    else
        local dis = (hitPos - self.character.Position).Magnitude
        attenuation = GunBase.static.utility:GetAttenuationByGunId(1, self, dis)
    end
    local damage = self.config_damage + attenuation
    damage = damage <= 0 and 0 or damage
    if _hit.HitPart == HitPartEnum.Limb then
        damage = damage * self.config_hitLimbDamageRate
    elseif _hit.HitPart == HitPartEnum.Body then
        damage = damage * self.config_hitBodyDamageRate
    elseif _hit.HitPart == HitPartEnum.Head then
        damage = damage * self.config_hitHeadDamageRate
    end
    if damage > 0 then
        local targetPlayer = _hit.HitObject.Owner and _hit.HitObject.Owner.Value or _hit.HitObject
        self.successfullyHit:Trigger(
            {Position = hitPos, Player = targetPlayer, Damage = damage, HitPart = _hit.HitPart}
        )
        PlayerGunMgr:FireGunDamage(localPlayer, targetPlayer, self.gun_Id, damage, _hit.HitPart)
    end
end

---刷新参数影响的属性
function GunBase:RefreshScales()
    local factor = 1
    factor = 1
    for k, v in pairs(self.m_bulletSpeedRateTable) do
        factor = factor * v
    end
    self.m_bulletSpeedRateScale = factor
end

---获取子弹速度
function GunBase:GetBulletSpeed()
    return self.config_bulletSpeed * self.m_bulletSpeedRateScale
end

return GunBase
