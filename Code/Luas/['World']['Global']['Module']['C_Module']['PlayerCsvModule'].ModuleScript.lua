--- 游戏表格预处理-客户端端
-- @module Csv Config Load - Client Side
-- @copyright Lilith Games, Avatar Team
-- @author Yuancheng Zhang
local PlayerCsv = {
    -- TEST ONLY 需要预先加载为Lua Table的表格名称
    preLoad = {
        {
            name = 'Test04', -- Lua Table的名字，调用为PlayerCsv.Test04
            csv = 'TestCsv01', -- smap中CSV表格的名称(World/Global/Csv/)
            ids = {'Type'} -- 索引的id,可以是单一主键,或多主键(多主键先后顺序决定lua table结构)
        }
    }
}

--- 初始化:加载所有预加载表格
function PlayerCsv:Init()
    info('PlayerCsv:Init')
    self:PreloadCsv()
end

function PlayerCsv:PreloadCsv()
    info('PlayerCsv:PreloadCsv')
    for _, pl in pairs(self.preLoad) do
        if not string.isnilorempty(pl.csv) and #pl.ids > 0 then
            self[pl.name] = CsvUtil.GetCsvInfo(Csv[pl.csv], table.unpack(pl.ids))
        end
    end
end

return PlayerCsv
