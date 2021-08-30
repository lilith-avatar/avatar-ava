--- 服务器/客户端文件路径配置
--- @module Manifest, Both-side
--- @copyright Lilith Games, Avatar Team
local Manifest = {}

Manifest.ROOT_PATH = 'Lua/Common/'

Manifest.Modules = {
    {
        Name = 'Define',
        Modules = {
            'Const'
        }
    },
    {
        Name = 'Xls',
        Modules = {
            'ActAnim',
            'Example',
            'GlobalSetting'
        }
    },
    {
        Name = 'Util',
        Modules = {
            'Uuid',
            'SoundUtil',
            'CloudLogUtil',
            'TimeUtil'
        }
    }
}

return Manifest
