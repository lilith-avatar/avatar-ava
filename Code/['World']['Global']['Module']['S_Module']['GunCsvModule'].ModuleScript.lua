--- 服务端枪械配置处理
--- @module Config Config Load - Server Side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local GunCsv, this = ModuleUtil.New('GunCsv', ServerBase)

local gunConfig = {
    {
        name = 'GunConfig',
        csv = 'GunConfigTable',
        ids = {'Id'}
    },
    {
        name = 'Magazine',
        csv = 'MagazineTable',
        ids = {'Id'}
    },
    {
        name = 'GunAnimation',
        csv = 'GunAnimationTable',
        ids = {'GunId', 'GunEvent'}
    },
    {
        name = 'Sound',
        csv = 'Sound',
        ids = {'GunId', 'GunEvent'}
    }
}

--- 初始化:加载所有预加载表格
function GunCsv:Init()
    self:PreloadGunCsv()
end

function GunCsv:PreloadGunCsv()
    ---枪械插件服务端使用的表,用于机器人的配置读取
    self.GunConfig = {}
    for _, pl in pairs(gunConfig) do
        if not string.isnilorempty(pl.csv) and #pl.ids > 0 then
            self.GunConfig[pl.name] = CsvUtil.GetCsvInfo(Weapon_Plugin_Package.Csv[pl.csv], table.unpack(pl.ids))
        end
    end
    self.GunConfig.GlobalConfig = CsvUtil.GetGlobalCsvInfo(Weapon_Plugin_Package.Csv.GlobalConfig)
end

return GunCsv
