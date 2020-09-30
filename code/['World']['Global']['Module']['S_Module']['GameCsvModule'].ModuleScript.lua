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
            ids = {'ID'}
        },
        -- TEST:以下为测试内容，用后请删掉
        {
            name = 'Test01', -- Lua Table的名字，调用为GameCsv.Test01
            csv = 'TestCsv01', -- smap中CSV表格的名称(World/Global/Csv/)
            ids = {'level_id'} -- 索引的id,可以是单一主键,或多主键(多主键先后顺序决定lua table结构)
        },
        {
            name = 'Test02',
            csv = 'TestCsv02',
            ids = {'enemy_id', 'difficulty'}
        },
        {
            name = 'Test03',
            csv = 'TestCsv02',
            ids = {'difficulty', 'enemy_id'}
        },
		{
            name = 'Message',
            csv = 'Message',
            ids = {'MsgId'}
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
        if not string.isnilorempty(pl.csv) and #pl.ids > 0 then
            self[pl.name] = CsvUtil.GetCsvInfo(Csv[pl.csv], table.unpack(pl.ids))
        end
    end
end

return GameCsv
