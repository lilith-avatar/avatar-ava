---@module FortBase 枪械模块：炮台控制类
---@copyright Lilith Games, Avatar Team
---@author Sharif Ma
local FortBase = class('FortBase')

---@param _fortId number 炮台配置ID
---@param _fortObj Object 炮台对象
---@param _owner PlayerInstance 所属玩家
---@param _gun GunBase 炮台所属枪械
function FortBase:initialize(_fortId, _fortObj, _owner, _gun)
    self.id = _fortId
    self.fort = _fortObj
    self.owner = _owner
    self.gun = _gun
    self.playerValue = world:CreateObject('ObjRefValueObject', 'Owner', _fortObj)

    self.shootSpeed = Config.FortConfig[_fortId].ShootSpeed
    self.damage = Config.FortConfig[_fortId].Damage
    self.distance = Config.FortConfig[_fortId].Distance
    self.maxHp = Config.FortConfig[_fortId].MaxHp

    self.m_beHitEvent = EventMgr:new('FortBeHitEvent', self)
    self.m_onDestroyEvent = EventMgr:new('FortDestroyEvent', self)

    self.m_hp = self.maxHp
    self.m_waitFireTime = 1 / self.shootSpeed

    self.playerValue.Value = _owner
end

function FortBase:StartUpdate()
    invoke(
        function()
            while true do
                local dt = wait()
                if self and self.m_waitFireTime then
                    self:Update(dt)
                else
                    break
                end
            end
        end
    )
end

function FortBase:Update(_dt)
    self.m_waitFireTime = self.m_waitFireTime - _dt
    if self.m_waitFireTime <= 0 then
        self.m_waitFireTime = 1 / self.shootSpeed
        self:Fire()
    end
end

function FortBase:Fire()
    local info = self:GetTarget()[1]
    if info and info.Player and not info.Player:IsNull() then
        local rayCastRes = Physics:RaycastAll(self.fort.Origin.Position, info.Player.Position, false)
        local canBeAttack = true
        for i, v in pairs(rayCastRes.HitObjectAll) do
            if v.Block and not ParentPlayer(v) and v ~= self.fort then
                canBeAttack = false
            end
        end
        if canBeAttack then
            local dir = info.Player.Position - self.fort.Origin.Position
            local laser =
                CreateLineBetween2Points(info.Player.Avatar.Bone_Pelvis.Position, self.fort.Origin.Position, 'Laser')
            invoke(
                function()
                    laser:Destroy()
                end,
                0.1
            )
            self.fort:FaceDirection(Vector3(dir.X, 0, dir.Z), Vector3.Up)
            self:Damage(info.Player)
        end
    end
end

function FortBase:GetTarget()
    local playersInRange = {}
    local ownerTeam = self.playerValue.Value.PlayerType.Value
    for i, v in pairs(world:FindPlayers()) do
        local dis = (v.Position - self.fort.Position).Magnitude
        ---测试用,暂时可以攻击主人
        if dis < self.distance and v.PlayerType.Value ~= ownerTeam then
            local info = {Player = v, Distance = dis}
            table.insert(playersInRange, info)
        end
    end
    table.sort(
        playersInRange,
        function(a, b)
            return a.Distance < b.Distance
        end
    )
    return playersInRange
end

function FortBase:Damage(_player)
    if self.gun and self.gun.successfullyHit then
        self.gun.successfullyHit:Trigger({Player = _player})
    end
    PlayerGunMgr:FireGunDamage(self.owner, _player, self.id, self.damage, HitPartEnum.None)
end

---炮台收到攻击
function FortBase:BitHit(_player, _weaponId, _damage)
    if self.m_hp <= 0 then
        return
    end
    self.m_beHitEvent:Trigger(_player, _damage)
    self.m_hp = self.m_hp - _damage
    print('炮台剩余血量为', self.m_hp)
    if self.m_hp <= 0 then
        ---被击毁
        self:Destroy(_player)
    end
end

function FortBase:Destroy(_player)
    self.m_onDestroyEvent:Trigger(_player)
    if self.fort and not self.fort:IsNull() then
        self.fort:Destroy()
    end
    ClearTable(self)
    self = nil
end

return FortBase
