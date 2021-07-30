--- @module CacheDestroyMgr 枪械模块：缓存管理
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local CacheDestroyMgr = {}

--- 初始化
function CacheDestroyMgr:Init()
    this = self
    self:InitListeners()
    self.allCacheList = {}
    world.OnPlayerRemoved:Connect(
        function(_player)
            self:PlayerRemoved(_player)
        end
    )
end

--- 初始化CacheDestroyMgr自己的监听事件
function CacheDestroyMgr:InitListeners()
    LinkConnects(world.S_Event, CacheDestroyMgr, this)
end

function CacheDestroyMgr:WeaponObjCreatedEventHandler(_player, _obj)
    self.allCacheList[_player] = self.allCacheList[_player] or {}
    table.insert(self.allCacheList[_player], _obj)
end

function CacheDestroyMgr:PlayerRemoved(_player)
    if self.allCacheList[_player] then
        for key, v in pairs(self.allCacheList[_player]) do
            if not v:IsNull() then
                v:Destroy()
            end
        end
    end
    self.allCacheList[_player] = nil
end

return CacheDestroyMgr
