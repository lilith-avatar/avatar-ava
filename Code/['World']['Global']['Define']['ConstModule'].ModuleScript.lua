--- 全局常量的定义,全部定义在Const这张表下面,用于定义全局常量参数或者枚举类型
--- @module Const Defines
--- @copyright Lilith Games, Avatar Team
local Const = {}

--语言枚举
Const.LanguageEnum = {
    CHS = 'CHS', -- 简体中文
    CHT = 'CHT', -- 繁体中文
    EN = 'EN', -- 英文
    JP = 'JP' -- 日文
}

---展示报错信息用的报错位置枚举
Const.ErrorLocationEnum = {
    Client = 1, ---客户端
    Server = 2 ---服务端
}

Const.OccupationEnum = {
    None = -1, ---无职业
    Scout = 1001, ---侦察兵
    RocketSoldier = 1002, ---火箭兵
    FireMan = 1003, ---火焰兵
    Threat = 1004, ---威胁者
    Gunner = 1005, ---重机枪手
    Medic = 1006, ---医疗兵
    Sniper = 1007 ---狙击手
}

Const.TeamEnum = {
    None = -1, ---未分配
    Team_A = 1, ---A阵营
    Team_B = 2 ---B阵营
}

---MVP玩家的称号枚举
Const.MVPEnum = {
    KillerKing = 'KillerKing',
    PointKing = 'PointKing',
    ScoreKing = 'ScoreKing'
}

Const.TitleEnum = {
    'Most efforts',
    '2nd most efforts',
    '3rd most efforts'
}

---游戏状态枚举
Const.GameStateEnum = {
    OnHall = 'OnHall',
    OnReady = 'OnReady',
    OnGame = 'OnGame',
    OnOver = 'OnOver'
}

---玩家状态枚举
Const.PlayerStateEnum = {
    OnHall_NoMatching = 1, ---大厅中,未在匹配状态
    OnHall_Matching = 2, ---大厅中,在匹配状态中
    OnGame = 3, ---在对局中
    OnOver = 4 ---对局结束,在结算界面
}

---游戏模式枚举
Const.GameModeEnum = {
    OccupyMode = 1, ---占点模式
    BombMode = 2, ---爆破模式
    DeathmatchMode = 3 ---死斗模式
}

---炸弹状态枚举
Const.BombStateEnum = {
    NoBomb = 1, ---没有炸弹放置
    BombFlashing = 2, ---炸弹放置上在闪烁
    Exploded = 3 ---已经爆炸了
}

---NPC状态枚举
Const.NpcStateEnum = {
    OnReload = 1,
    AllowFire = 2,
    FireWaiting = 3,
    NoAmmo = 4
}

return Const
