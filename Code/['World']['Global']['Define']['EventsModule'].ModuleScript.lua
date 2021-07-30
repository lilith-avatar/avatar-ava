--- CustomEvent的定义，用于事件动态生成
--- @module Events Defines
--- @copyright Lilith Games, Avatar Team
local Events = {}

-- 服务器事件列表
Events.ServerEvents = {
    'PlayerTryChangeOccEvent',
    'PlayerStartMatchEvent',
    'PlayerStopMatchEvent',
    'PlayerReturnHallEvent',
    'PlayerTrySetBombEvent',
    'PlayerTryRemoveBombEvent',
    'PlayerDieEvent',
    'NpcCreateEvent',
    'NpcDestroyEvent',
    'CameraMoveEndEvent',
    'PlayerDoChangeOccEvent'
}

-- 客户端事件列表
Events.ClientEvents = {
    'ChangeOccEvent',
    'NewPlayerEvent',
    'NewPlayerBornEvent',
    'PlayerLeaveEvent',
    'NoticeEvent',
    'PointBeOccupiedEvent',
    'GradeChangeEvent',
    'TransferEvent',
    'GameTimeChangeEvent',
    'GameStartEvent',
    'MatchPlayerChangeEvent',
    'GameOverEvent',
    'StartAnimationEvent',
    'AnimationStateEvent',
    'BombStateChangeEvent',
    'TeamABombCountChangeEvent',
    'PlayerScoreAddEvent',
    'TeamKillNumChangeEvent',
    'ContinuousKillEvent',
    'WorldSoundEvent',
    'KillRankChangeEvent',
    'StopSoundEvent',
    'ResetHallEvent',
    'NpcCreateEvent',
    'NpcStateChangeEvent',
    'PlayerObjCreatedEvent'
}
return Events
