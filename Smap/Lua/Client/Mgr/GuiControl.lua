--- 玩家控制UI模块
--- @module Player GuiControll, client-side
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local GuiControl, this = Ava.Util.Mod.New('GuiControl', ClientBase)

-- 手机端交互UI
local gui

function GuiControl:Init()
    --print('[GuiControl] Init()')
    self:InitGui()
    self:InitListener()
end

function GuiControl:InitGui()
    gui = localPlayer.Local.ControlGui
    this.joystick = gui.Joystick
    this.touchScreen = gui.TouchFig
    this.jumpBtn = gui.JumpBtn
end

function GuiControl:InitListener()
    -- GUI
    this.touchScreen.OnTouched:Connect(
        function(touchInfo)
            PlayerCam:CameraMove(touchInfo)
        end
    )
    this.touchScreen.OnPinchStay:Connect(
        function(pos1, pos2, deltaSize, pinchSpeed)
            PlayerCam:CameraZoom(pos1, pos2, deltaSize, pinchSpeed)
        end
    )
    this.jumpBtn.OnDown:Connect(
        function()
            C.Mgr.PlayerCtrl:PlayerJump()
        end
    )
end

return GuiControl
