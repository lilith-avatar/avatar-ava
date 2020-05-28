--- 游戏表格预处理-服务器端
-- @module Csv Config Load - Server Side
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
local GameCsv = {
    -- TEST ONLY 需要预先加载为Lua Table的表格名称
    preLoad = {
        {
            name = 'Sound', --SoundUtil模块调用
            csv = 'Sound',
            id = 'ID',
            isPrimary = true
        },
        -- TEST:以下为测试内容，用后请删掉
        {
            name = 'Test01', -- Lua Table的名字，调用为GameCsv.Test01
            csv = 'TestCsv01', -- smap中CSV表格的名称(World/Global/Csv/)
            id = 'level_id', -- 索引的id
            isPrimary = true -- 索引id是否为主键
        },
        {
            name = 'Test02',
            csv = 'TestCsv02',
            id = 'enemy_id',
            isPrimary = false
        },
        {
            name = 'Test03',
            csv = 'TestCsv02',
            id = 'Type',
            isPrimary = true
        }
    }
}

--- 初始化:加载所有预加载表格
function GameCsv:Init()
    info('GameCsv:Init')
    self:PreloadCsv()
end

function GameCsv:PreloadCsv()
    info('GameCsv:PreloadCsv')
    for _, pl in pairs(self.preLoad) do
        if not string.isnilorempty(pl.csv) and not string.isnilorempty(pl.id) then
            self[pl.name] = CsvUtil.GetCsvInfo(Csv[pl.csv], pl.id, pl.isPrimary)
        end
    end
end

return GameCsv
