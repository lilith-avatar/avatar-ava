# Avatar Ava
Avatar Ava is a intergated framework that is designed to support the development on Avatar engine.

[Explore Github Wiki>>](https://github.com/lilith-avatar/avatar-ava/wiki)

## Table of contents

* [Who is Ava](#who-is-ava?)
* [Ava Structure](#ava-structure)
* [Quick Start](#quick-start)


## Who is Ava? 
![ava logo](https://i.pinimg.com/564x/f1/af/3d/f1af3d3db9c5711dda1d29a585c3bf03.jpg "ava: blessed, beautiful")

## Branches
* [master](https://github.com/lilith-avatar/avatar-ava) trunk branch for debug after development finish, and documents 
* [dev](https://github.com/lilith-avatar/avatar-ava/tree/dev) development branch for new feature, debug and new issue
* [release](https://github.com/lilith-avatar/avatar-ava/tree/release) release new version, can't change until next version release
* [example](https://github.com/lilith-avatar/avatar-ava/tree/example) release version with test cases and examples

## Ava Structure
### World Hierarchy
* Global
  * AutoAssignTeamScript
  * LuaFunctionScript
  * ModuleRequireScript
  * Utility
    * NetUtilModule
    * CsvUtilModule
    * EventUtilModule
  * Plugin
    * FUNC_UIAnimation
  * Define
    * GlobalDefModule
    * ConstDefModule
  * Module
    * S_Module
      * GameMgrModule
      * CsvConfigModule
      * ExampleAModule
    * C_Module
      * PlayerMgrModule
      * ExampleBModule
  * Csv
    * UIAnimation
    * Example01
    * Example02
* S_Event
  * Example01CustomEvent
  * Example02CustomEvent
  * Example03CustomEvent
* S_Code
  * ServerMain
* BaseFloor
* SpawnLocations
* BGM
* Sky
* Players
* Terrain
### Player Hierarchy
* C_Event
  * ClientExample01Event
  * ClientExample02Event
  * ClientExample03Event
* Avatar
* NameGUI
* HealthGUI
* Local
  * ScreenGUI
  * ConstrainFree
  * C_Code
    * PlayerControlScript
    * PlayerMain

## Quick Start
Several quick start options are available:

 * [Download the latest release](https://github.com/lilith-avatar/avatar-ava/releases)
 * Clone the repo: `git clone https://github.com/lilith-avatar/avatar-ava.git`

