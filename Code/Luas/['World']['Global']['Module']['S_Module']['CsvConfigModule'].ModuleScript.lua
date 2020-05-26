--- 游戏表格处理
-- @module Csv Config Load
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
local CsvConfig = {
    -- TEST ONLY 需要预先加载为Lua Table的表格名称
    preLoad = {
        {
            csv = 'Example01',
            id = 'level_id',
            isPrimary = true
        },
        {
            csv = 'Example02',
            id = 'enemy_id',
            isPrimary = false
        },
        {
            csv = 'Sound',
            id = 'ID',
            isPrimary = true
        }
    }
}

--- 初始化:加载所有预加载表格
function CsvConfig:Init()
    print('[信息] CsvConfig:Init')
    self:PreloadCsv()
end

function CsvConfig:PreloadCsv()
    print('[信息] CsvConfig:PreloadCsv')
    for _, pl in pairs(self.preLoad) do
        if not string.isnilorempty(pl.csv) and not string.isnilorempty(pl.id) then
            self[pl.csv] = CsvUtil.GetCsvInfo(Csv[pl.csv], pl.id, pl.isPrimary)
        end
    end
end

return CsvConfig
