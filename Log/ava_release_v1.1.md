# Ava v1.1 Release Log
**Time**: 2020/05/28

## New Features

### Utilities

* `LinkedListModule`, C#双向链表, by 程智
* `UuidModule`, UUID生成, by 马尚
* `SoundUtilModule`, 音频播放模块, by 马尚, 袁晨曦
* `CamUtilModule`, 相机控制模块, by 马尚, 袁晨曦
* `LuaJsonUtilModule`, Lua table和Json模块互转, 用于发送table作为事件参数, by 马尚, 袁晨曦
* `ObjPoolUtilModule`, 通用对象池, by 袁晨曦
* `LogUtilModule`, 日志打印模块, by 张远程

### Modules

* `S_Module/TimeMgrModule`, 时间管理模块, by 陈炳云
* `C_Module/PlayerCsvModule`, 客户端CSV初始化, by 张远程

### Plugin
* `Plugin/FUNC_Guide`, 界面UI强引导, by 张心悟

## Improvement

* smap支持波尔版本 
* 整理玩家客户端节点结构, by 张心悟
* 按照代码规范整理框架 
* 将测试脚本整理
* 优化UI动画插件
* 优化CSV表中以Type为索引id的载入
* 优化PlayerControl相关脚本

## Dev Process

1. GitHub Issue 添加默认模板(`Debug`, `New Feature`), by 张远程
2. GitHub的分支管理

## Other
* `v1.1`版本的debug和文档工作将在`v1.1.1`中陆续完成。