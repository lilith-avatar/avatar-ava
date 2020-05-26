--- 游戏表格处理
-- @module Csv Config Load
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
local CsvConfig = {
    -- TEST ONLY 需要预先加载为Lua Table的表格名称
    preLoad = {
        {
            name = 'Test01', -- Lua Table的名字，调用为CsvConfig.Test01
            csv = 'Example01', -- smap中CSV表格的名称(World/Global/Csv/)
            id = 'level_id', -- 索引的id
            isPrimary = true -- 索引id是否为主键
        },
        {
            name = 'Test02',
            csv = 'Example02',
            id = 'enemy_id',
            isPrimary = false
        },
        {
            name = 'Test03',
            csv = 'Example02',
            id = 'Type',
            isPrimary = true
        }
    }
}

--- 初始化:加载所有预加载表格
function CsvConfig:Init()
    info('CsvConfig:Init')
    self:PreloadCsv()
end

function CsvConfig:PreloadCsv()
    info('CsvConfig:PreloadCsv')
    for _, pl in pairs(self.preLoad) do
        if not string.isnilorempty(pl.csv) and not string.isnilorempty(pl.id) then
            self[pl.name] = CsvUtil.GetCsvInfo(Csv[pl.csv], pl.id, pl.isPrimary)
        end
    end
end

return CsvConfig
