# Avatar Ava
Avatar Ava is a intergated framework that is designed to support the development on Avatar engine.

## Who is Ava? 
![ava logo](https://i.pinimg.com/564x/f1/af/3d/f1af3d3db9c5711dda1d29a585c3bf03.jpg "ava: blessed, beautiful")

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