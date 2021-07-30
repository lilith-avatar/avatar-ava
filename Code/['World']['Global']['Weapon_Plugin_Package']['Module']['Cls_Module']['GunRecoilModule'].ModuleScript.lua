---@module GunRecoil 枪械模块：回弹基类
---@copyright Lilith Games, Avatar Team
---@author Sharif Ma, An Dai
local GunRecoil = class('GunRecoil')

---GunRecoil类的构造函数
---@param _gun GunBase
function GunRecoil:initialize(_gun)
    self.id = _gun.recoilId
    self.gun = _gun
    ---自身属性部分(大多时变量，通过安装配件可能会变化)
    self.m_verticalScale = 1 ---竖直缩放率
    self.m_horizontalScale = 1 ---水平缩放率
    self.m_minErrorScale = 1 ---散布缩放率
    self.m_maxErrorScale = 1 ---散布缩放率
    self.m_recoverRateScale = 1 ---散布缩放率
    self.m_selfSpinRangeRateScale = 1 ---散布缩放率

    self.unstability = 0 ---后坐力参数，从0-1取值,表现相关的量理论上是它的函数,目前仅控制散布，以及它决定的ui表现
    self.currentError = 0
    ---会受配件和姿势影响的数值的参数表
    self.m_horizontalRateTable = {}
    self.m_verticalRateTable = {}
    self.m_minErrorRateTable = {}
    self.m_maxErrorRateTable = {}
    self.m_recoverRateTable = {}
    self.m_selfSpinRangeRateTable = {}
    ---持有玩家位置，用以判定玩家是否移动
    self.m_lastPos = self.gun.character.Position
    ---初始化后坐力配置
    GunBase.static.utility:InitGunRecoilConfig(self)
    ---UI表现相关
    self.difFunction = function(_unstability)
        _unstability = _unstability or self.unstability
        if self.config_diffuseFunction == DiffuseFunctionEnum.Linear then
            ---线性函数
            return _unstability
        elseif self.config_diffuseFunction == DiffuseFunctionEnum.Sqrt then
            return math.sqrt(_unstability)
        elseif self.config_diffuseFunction == DiffuseFunctionEnum.Square then
            return _unstability * _unstability
        end
    end
end

---每帧行为
function GunRecoil:Update(_dt)
    ---减后坐力
    self.unstability = math.clamp(self.unstability - self.config_diffuseRecoverRate * _dt, 0, 1)

    ---重置各个影响因子
    self.m_horizontalRateTable = {}
    self.m_verticalRateTable = {}
    self.m_minErrorRateTable = {}
    self.m_maxErrorRateTable = {}
    self.m_recoverRateTable = {}
    self.m_selfSpinRangeRateTable = {}
    ---判断移动和跳跃
    local curPos = self.gun.character.Position
    if ((curPos - self.m_lastPos).Magnitude > 0.5 * _dt or not self.gun.character.IsOnGround) then
        ---<0.5m/s
        self.m_minErrorRateTable.move = self.config_jumpErrorScale
        self.m_maxErrorRateTable.move = self.config_jumpErrorScale
    else
        self.m_minErrorRateTable.move = nil
        self.m_maxErrorRateTable.move = nil
    end
    self.m_lastPos = curPos
    ---判断蹲下
    if (self.gun.character:IsCrouch()) then
        self.m_minErrorRateTable.crouch = self.config_crouchErrorScale
        self.m_maxErrorRateTable.crouch = self.config_crouchErrorScale
    else
        self.m_minErrorRateTable.crouch = nil
        self.m_maxErrorRateTable.crouch = nil
    end
    for k, v in pairs(self.gun.m_weaponAccessoryList) do
        self.m_horizontalRateTable[k] = v.horizontalJumpRangeRate
        self.m_verticalRateTable[k] = v.verticalJumpAngleRate
        self.m_minErrorRateTable[k] = v.minErrorRate
        self.m_maxErrorRateTable[k] = v.maxErrorRate
        self.m_recoverRateTable[k] = v.gunRecoverRate
        self.m_selfSpinRangeRateTable[k] = v.selfSpinRangeRate
    end

    ---结算误差
    self.gun.error = self:GetDiffuse(_dt)
    ---更新各个参数的影响因子大小
    self:RefreshScales()
end

---返回竖直方向的跳动
---如果需要加cs系列的固定模式或者随机性可以在这里操作
function GunRecoil:GetVertical()
    return (self.config_verticalJumpAngle + self.config_verticalJumpRange * GaussRandom()) * self.m_verticalScale
end

---返回水平方向的跳动
---如果需要加cs系列的固定模式可以在这里操作
function GunRecoil:GetHorizontal()
    return self.m_horizontalScale * self.config_horizontalJumpRange * GaussRandom()
end

---返回最小散射
function GunRecoil:GetMinError()
    return self.config_minError * self.m_minErrorScale
end

---返回最大散射
function GunRecoil:GetMaxError()
    return self.config_maxError * self.m_maxErrorScale
end

---返回回复时间
function GunRecoil:GetShakeTime()
    return self.config_gunRecoil / (self.config_gunRecoverRate * self.m_recoverRateScale)
end

---返回Z轴抖动
function GunRecoil:GetSelfSpinRange()
    return self.config_selfSpinRange * self.m_selfSpinRangeRateScale
end

---收到开火信号后的反应
function GunRecoil:Fire()
    self.unstability = math.min(1.0, self.unstability + self.config_gunRecoil)
end

---返回散射角
function GunRecoil:GetDiffuse(_dt)
    local tobe = self:GetMinError() + self.difFunction() * (self:GetMaxError() - self:GetMinError())
    self.currentError = self.currentError + _dt * 10 * (tobe - self.currentError)
    return self.currentError
end

function GunRecoil:GetShakeIntensity()
    return self.config_shakeIntensity
end

---更新后坐力相关的所有因子大小
function GunRecoil:RefreshScales()
    local factor = 1
    for k, v in pairs(self.m_horizontalRateTable) do
        factor = factor * v
    end
    self.m_horizontalScale = factor
    factor = 1
    for k, v in pairs(self.m_verticalRateTable) do
        factor = factor * v
    end
    self.m_verticalScale = factor
    factor = 1
    for k, v in pairs(self.m_minErrorRateTable) do
        factor = factor * v
    end
    self.m_minErrorScale = factor
    factor = 1
    for k, v in pairs(self.m_maxErrorRateTable) do
        factor = factor * v
    end
    self.m_maxErrorScale = factor
    factor = 1
    for k, v in pairs(self.m_recoverRateTable) do
        factor = factor * v
    end
    self.m_recoverRateScale = factor
    factor = 1
    for k, v in pairs(self.m_selfSpinRangeRateTable) do
        factor = factor * v
    end
    self.m_selfSpinRangeRateScale = factor
end

function GunRecoil:Destructor()
    ClearTable(self)
    self = nil
end

return GunRecoil
