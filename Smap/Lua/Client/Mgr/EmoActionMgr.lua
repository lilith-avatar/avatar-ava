--- C端交互管理模块
--- @module  EmoActionMgr, Client-side
--- @copyright Lilith Games, Avatar Team
--- @author KeyHou
local EmoActionMgr, this = ModuleUtil.New('EmoActionMgr', ClientBase)

function EmoActionMgr:Init()
    print('[C_Module][EmoActionMgr:Init]')
    -------------------------------------------声明节点-------------------------------------------
    ---激活舞蹈面板的按钮
    self.DanceBtn = localPlayer.Local.DanceGui.DanceActiveBtn
    ---DanceGui
    self.Gui = localPlayer.Local.DanceGui
    ---舞蹈动作选择面板总节点
    self.Pnl = localPlayer.Local.DanceGui.Panel
    ---背板
    self.BackGround = localPlayer.Local.DanceGui.BackGround
    ---按下的joystick
    self.Jst = localPlayer.Local.DanceGui.DanceJst
    ---跳跃按钮
    self.JumpBtn = localPlayer.Local.ControlGui.JumpBtn
    ---移动遥感
    self.MoveJst = localPlayer.Local.ControlGui.Joystick

    ---分别给六个扇区声明
    for i = 1, 6 do
        ---未选中状态的动作扇区
        self['Img' .. i] = localPlayer.Local.DanceGui.Panel['ActImg' .. i]
        ---未选中的动作切图
        self['ActImg' .. i] = localPlayer.Local.DanceGui.Panel['ActImg' .. i].ActionImg
        ---选中状态的用来覆盖的扇区
        self['CheckedImg' .. i] = localPlayer.Local.DanceGui.Panel['CheckedImg' .. i]
        ---选中了的动作切图
        self['CheckedActImg' .. i] = localPlayer.Local.DanceGui.Panel['CheckedImg' .. i].ActionImg
    end

    -------------------------------------------绑定事件-------------------------------------------
    --[[
    ---触发舞蹈按钮
    self.DanceBtn.OnDown:Connect(function()
        self.Jst:SetActive(true)
        self.DanceBtn:SetActive(false)
    end) ]]
    Input.OnKeyDown:Connect(
        function()
            if Input.GetPressKeyData(Enum.KeyCode.K) == Enum.KeyState.KeyStatePress then
                FsmMgr.playerActCtrl:CallTrigger('LieBeginState')
            end
            if Input.GetPressKeyData(Enum.KeyCode.N) == Enum.KeyState.KeyStatePress then
                FsmMgr.playerActCtrl:CallTrigger('ThrowBeginState')
            end
            if Input.GetPressKeyData(Enum.KeyCode.M) == Enum.KeyState.KeyStatePress then
                FsmMgr.playerActCtrl:CallTrigger('ThrowEndState')
            end
        end
    )

    ---触发舞蹈摇杆
    self.Jst.OnDragBegin:Connect(
        function()
            self.DanceBtn:SetActive(false)
            self.BackGround:SetActive(true)
            self.Pnl:SetActive(true)
            --self.JumpBtn:SetActive(false)
            self:HideJst(true)
        end
    )

    ---拖拽舞蹈摇杆过程中(选择动作)
    self.Jst.OnDragStay:Connect(
        function()
            self:ShowACT()
        end
    )

    ---松开舞蹈遥感（播放动作或者退出）
    self.Jst.OnDragEnd:Connect(
        function()
            self.BackGround:SetActive(false)
            self.Pnl:SetActive(false)
            --self.MoveJst:SetActive(false)
            self.Jst:SetActive(false)
            self:HideJst(false)
            self:DoACT()
        end
    )
end

-------------------------------------------update-------------------------------------------
function EmoActionMgr:Update(_dt, _tt)
    --print("[C_Module][TriggerManager:Update]".._dt.."//".._tt);
end

-------------------------------------------功能方法-------------------------------------------
---选择动作
function EmoActionMgr:ShowACT()
    if self.Jst.DragAngle <= 0 and self.Jst.DragAngle > -30 then
        self:SetOnAllImage()
        self:SetOffAllChecked()
        self.Img1:SetActive(false)
        self.CheckedImg1:SetActive(true)
    elseif self.Jst.DragAngle <= -30 and self.Jst.DragAngle > -60 then
        self:SetOnAllImage()
        self:SetOffAllChecked()
        self.Img2:SetActive(false)
        self.CheckedImg2:SetActive(true)
    elseif self.Jst.DragAngle <= -60 and self.Jst.DragAngle > -90 then
        self:SetOnAllImage()
        self:SetOffAllChecked()
        self.Img3:SetActive(false)
        self.CheckedImg3:SetActive(true)
    elseif self.Jst.DragAngle <= -90 and self.Jst.DragAngle > -120 then
        self:SetOnAllImage()
        self:SetOffAllChecked()
        self.Img4:SetActive(false)
        self.CheckedImg4:SetActive(true)
    elseif self.Jst.DragAngle <= -120 and self.Jst.DragAngle > -150 then
        self:SetOnAllImage()
        self:SetOffAllChecked()
        self.Img5:SetActive(false)
        self.CheckedImg5:SetActive(true)
    elseif self.Jst.DragAngle <= -150 and self.Jst.DragAngle > -180 then
        self:SetOnAllImage()
        self:SetOffAllChecked()
        self.Img6:SetActive(false)
        self.CheckedImg6:SetActive(true)
    else
        self:SetOnAllImage()
        self:SetOffAllChecked()
    end
end

---播放动作
function EmoActionMgr:DoACT()
    if self.Jst.DragAngle <= 0 and self.Jst.DragAngle > -30 then
        local CallBack = localPlayer.Avatar:AddAnimationEvent('SocialBow', 0.99)
        CallBack:Connect(
            function()
                self:ActCallBack()
            end
        )
        --localPlayer.Avatar:PlayAnimation('SocialBow',2,1,0,true,false,1)
        PlayerActAnimeGui:PlayActAnim(1)
    elseif self.Jst.DragAngle <= -30 and self.Jst.DragAngle > -60 then
        local CallBack = localPlayer.Avatar:AddAnimationEvent('Exhibition12', 0.99)
        CallBack:Connect(
            function()
                self:ActCallBack()
            end
        )
        --localPlayer.Avatar:PlayAnimation('Exhibition12',2,1,0,true,false,1)
        PlayerActAnimeGui:PlayActAnim(2)
    elseif self.Jst.DragAngle <= -60 and self.Jst.DragAngle > -90 then
        local CallBack = localPlayer.Avatar:AddAnimationEvent('Exhibition04', 0.99)
        CallBack:Connect(
            function()
                self:ActCallBack()
            end
        )
        --localPlayer.Avatar:PlayAnimation('Exhibition04',2,1,0,true,false,1)
        PlayerActAnimeGui:PlayActAnim(3)
    elseif self.Jst.DragAngle <= -90 and self.Jst.DragAngle > -120 then
        local CallBack = localPlayer.Avatar:AddAnimationEvent('SocialLaughing', 0.99)
        CallBack:Connect(
            function()
                self:ActCallBack()
            end
        )
        --localPlayer.Avatar:PlayAnimation('SocialLaughing',2,1,0,true,false,1)
        PlayerActAnimeGui:PlayActAnim(4)
    elseif self.Jst.DragAngle <= -120 and self.Jst.DragAngle > -150 then
        local CallBack = localPlayer.Avatar:AddAnimationEvent('SocialComeOn', 0.99)
        CallBack:Connect(
            function()
                self:ActCallBack()
            end
        )
        --localPlayer.Avatar:PlayAnimation('SocialComeOn',2,1,0,true,false,1)
        PlayerActAnimeGui:PlayActAnim(5)
    elseif self.Jst.DragAngle <= -150 and self.Jst.DragAngle > -180 then
        local CallBack = localPlayer.Avatar:AddAnimationEvent('SocialAnger', 0.99)
        CallBack:Connect(
            function()
                self:ActCallBack()
            end
        )
        --localPlayer.Avatar:PlayAnimation('SocialAnger',2,1,0,true,false,1)
        PlayerActAnimeGui:PlayActAnim(6)
    else
        self.DanceBtn:SetActive(true)
        self:HideJst(false)
        self.Jst:SetActive(true)
        self:ActCallBack()
    end
end

---关闭所有选中状态扇形
function EmoActionMgr:SetOffAllChecked()
    --print('!!!!!!!!!!!!!!!')
    self.CheckedImg1:SetActive(false)
    self.CheckedImg2:SetActive(false)
    self.CheckedImg3:SetActive(false)
    self.CheckedImg4:SetActive(false)
    self.CheckedImg5:SetActive(false)
    self.CheckedImg6:SetActive(false)
end

---打开所有未选中的扇形
function EmoActionMgr:SetOnAllImage()
    self.Img1:SetActive(true)
    self.Img2:SetActive(true)
    self.Img3:SetActive(true)
    self.Img4:SetActive(true)
    self.Img5:SetActive(true)
    self.Img6:SetActive(true)
end

---控制透明化舞蹈触发遥感
---@param _switch bool 是否显示遥感(true显示，false隐藏)
function EmoActionMgr:HideJst(_switch)
    if _switch then
        self.Jst.BackGround = ResourceManager.GetTexture('UI/Dance_Icon/PoseWheel_Handle_Bg_245x245')
        self.Jst.Handle = ResourceManager.GetTexture('UI/Dance_Icon/PoseWheel_Handle_Joystick')
    else
        if self.Jst.BackGround == 'Transparent' and self.Jst.Handle == 'Transparent' then
            print('!!!!!!!!!!!!!!!!!!!!!!')
        else
            self.Jst.BackGround = ResourceManager.GetTexture('UI/Dance_Icon/Transparent')
            self.Jst.Handle = ResourceManager.GetTexture('UI/Dance_Icon/Transparent')
        end
    end
end

---播放完动作后的回调
function EmoActionMgr:ActCallBack()
    self.JumpBtn:SetActive(true)
    self.MoveJst:SetActive(true)
    self.DanceBtn:SetActive(true)
    self.Jst:SetActive(true)
    -- C_GameTriggerManager:MatchTrigger()
end

---关闭打开舞蹈触发按钮（外部用）
---@param _switch bool 是否显示(true显示，false隐藏)
function EmoActionMgr:HideDanceBtn(_switch)
    if _switch then
        self.DanceBtn:SetActive(true)
        self.Jst:SetActive(true)
    else
        self.DanceBtn:SetActive(false)
        self.Jst:SetActive(false)
    end
end

return EmoActionMgr
