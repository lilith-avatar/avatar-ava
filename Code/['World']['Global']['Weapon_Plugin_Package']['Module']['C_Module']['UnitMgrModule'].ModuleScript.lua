--- @module UnitMgr 枪械模块：单元管理
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local UnitMgr, this = {}, nil

---模块初始化函数
function UnitMgr:Init()
    this = self
    self:InitListeners()
    self.pickJudge = world:CreateObject('Cylinder', 'PickJudge', localPlayer)
    self.pickJudge.Size = Vector3(GunConfig.GlobalConfig.Distance * 2, 2, GunConfig.GlobalConfig.Distance * 2)
    self.pickJudge.Block = false
    self.pickJudge.CollisionGroup = localPlayer.CollisionGroup
    self.pickJudge.Color = Color(0, 0, 0, 0)
    self.pickJudge.LocalPosition = Vector3(0, 0.92, 0)

    self.weaponUnitList = {}
    self.accUnitList = {}
    self.ammoUnitList = {}
end

function UnitMgr:InitListeners()
    LinkConnects(localPlayer.C_Event, UnitMgr, this)
end

---Update函数
---@param dt number delta time 每帧时间
---@param tt number total time 总时间
function UnitMgr:Update(dt, tt)
end

function UnitMgr:CreateAllUnitEventHandler(_weaponUnitList, _accUnitList, _ammoUnitList)
    for k, v in pairs(_weaponUnitList) do
        if not self.weaponUnitList[k] then
            self.weaponUnitList[k] = v
            v.PickRegion.OnCollisionBegin:Connect(
                function(_hitObj)
                    if _hitObj and _hitObj.Name == 'PickJudge' and _hitObj.Parent == localPlayer then
                        self:PlayerNearWeaponUnit(v)
                    end
                end
            )
            v.PickRegion.OnCollisionEnd:Connect(
                function(_hitObj)
                    if _hitObj and _hitObj.Name == 'PickJudge' and _hitObj.Parent == localPlayer then
                        self:PlayerAwayWeaponUnit(v)
                    end
                end
            )
        end
    end
    for k, v in pairs(_accUnitList) do
        if not self.accUnitList[k] then
            self.accUnitList[k] = v
            v.PickRegion.OnCollisionBegin:Connect(
                function(_hitObj)
                    if _hitObj and _hitObj.Name == 'PickJudge' and _hitObj.Parent == localPlayer then
                        self:PlayerNearAccUnit(v)
                    end
                end
            )
            v.PickRegion.OnCollisionEnd:Connect(
                function(_hitObj)
                    if _hitObj and _hitObj.Name == 'PickJudge' and _hitObj.Parent == localPlayer then
                        self:PlayerAwayAccUnit(v)
                    end
                end
            )
        end
    end
    for k, v in pairs(_ammoUnitList) do
        if not self.ammoUnitList[k] then
            self.ammoUnitList[k] = v
            v.PickRegion.OnCollisionBegin:Connect(
                function(_hitObj)
                    if _hitObj and _hitObj.Name == 'PickJudge' and _hitObj.Parent == localPlayer then
                        self:PlayerNearAmmoUnit(v)
                    end
                end
            )
            v.PickRegion.OnCollisionEnd:Connect(
                function(_hitObj)
                    if _hitObj and _hitObj.Name == 'PickJudge' and _hitObj.Parent == localPlayer then
                        self:PlayerAwayAmmoUnit(v)
                    end
                end
            )
        end
    end
end

---@param _unit Accessory 玩家靠近一个东西
function UnitMgr:PlayerNearWeaponUnit(_unit)
    localPlayer.C_Event.PlayerNearWeaponEvent:Fire(_unit)
end

function UnitMgr:PlayerAwayWeaponUnit(_unit)
    localPlayer.C_Event.PlayerFarWeaponEvent:Fire(_unit)
end

---@param _unit Accessory 玩家靠近一个东西
function UnitMgr:PlayerNearAccUnit(_unit)
    localPlayer.C_Event.PlayerNearWeaponAccessoryEvent:Fire(_unit)
end

function UnitMgr:PlayerAwayAccUnit(_unit)
    localPlayer.C_Event.PlayerFarWeaponAccessoryEvent:Fire(_unit)
end

---@param _unit Accessory 玩家靠近一个东西
function UnitMgr:PlayerNearAmmoUnit(_unit)
    localPlayer.C_Event.PlayerNearAmmoEvent:Fire(_unit)
end

function UnitMgr:PlayerAwayAmmoUnit(_unit)
    localPlayer.C_Event.PlayerFarAmmoEvent:Fire(_unit)
end

return UnitMgr
