--- 全局Debug模块
--- @module DebugModeLogic
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local DebugModeLogic = {}

--- 初始化Hook
function DebugModeLogic.InitHook()
    HookFunc()
end

--- 初始化客户端
function DebugModeLogic.InitClient()
    InitClientLogic()
end

--- 显示报错信息
--- @param _location number 报错位置
--- @param _content string 报错信息
function ErrorShow(_location, _content)
    local self = DebugModeLogic
    if self.root.Bg.ActiveSelf then
        return
    end
    local locationStr = ''
    if _location == Const.ErrorLocationEnum.Client then
        locationStr = 'Client'
    elseif _location == Const.ErrorLocationEnum.Server then
        locationStr = 'Server'
    end
    self.locationTxt.Text = locationStr
    self.contentTxt.Text = _content
    self.root.Bg:SetActive(true)
end

--- 显示当前游戏未结束
function StillInGameShow()
    local self = DebugModeLogic
    self.stillInGameRoot:SetActive(true)
end

--- 初始化相关事件
function InitEvent()
	--如果localPlayer.C_Event不存在，则创建该节点
    if localPlayer.C_Event == nil then
        world:CreateObject('FolderObject', 'C_Event', localPlayer)
    end
	--为localPlayer.C_Event节点创建ErrorShowEvent事件
    local event = world:CreateObject('CustomEvent', 'ErrorShowEvent', localPlayer.C_Event)
	--为ErrorShowEvent事件连接ErrorShow()
    event:Connect(ErrorShow)
	--为localPlayer.C_Event节点创建StillInGameEvent事件
    event = world:CreateObject('CustomEvent', 'StillInGameEvent', localPlayer.C_Event)
	--为StillInGameEvent事件连接StillInGameShow()
    event:Connect(StillInGameShow)
end

--- 初始化UI
function InitUI()
    local self = DebugModeLogic
	--为localPlayer.Local节点创建ErrorGUI
    self.root = world:CreateInstance('ErrorGUI', 'ErrorGUI', localPlayer.Local)
    self.root.Order = 950
    self.stillInGameRoot = world:CreateInstance('SetRoomGUI', 'SetRoomGUI', localPlayer.Local)
    self.stillInGameRoot.Order = 950
    self.contentTxt = self.root.Bg.Content
    self.locationTxt = self.root.Bg.Location
    self.okBtn = self.root.Bg.OK

    self.root.Bg:SetActive(false)
    self.stillInGameRoot:SetActive(false)

    self.okBtn.OnClick:Connect(
        function()
            self.root.Bg:SetActive(false)
        end
    )
    self.root.BakeBtn.OnClick:Connect(
        function()
			--- 创建寻路数据
            BakeNav()
        end
    )
    ---仍在游戏中的提示框
    self.stillInGameRoot.Bg.WAIT.OnClick:Connect(
        function()
            self.stillInGameRoot:SetActive(false)
        end
    )
    self.stillInGameRoot.Bg.QUIT.OnClick:Connect(
        function()
            Game.Quit()
        end
    )
end

--- Hook的执行函数
function HookFunc()
	--位置：FrameworkConfigModule
	--如果开启调整模式
    if FrameworkConfig.DebugMode then
        for _, module in pairs(_G) do
            if type(module) == 'table' then
                local funcTable = {}
                if module.__declaredMethods then
                    ---类模块
                    funcTable = module.__declaredMethods
                else
                    ---正常模块
                    funcTable = module
                end
                for funcName, func in pairs(funcTable) do
                    if type(func) == 'function' and funcName ~= 'Update' and funcName ~= 'FixUpdate' then
                        local hookedFunc = function(...)
                            local res = {pcall(func, ...)}
                            local success = res[1]
                            table.remove(res, 1)
                            if success then
                                return table.unpack(res)
                            else
                                if localPlayer then
                                    ---客户端报错
                                    NetUtil.Fire_C(
                                        'ErrorShowEvent',
                                        localPlayer,
                                        Const.ErrorLocationEnum.Client,
                                        res[1]
                                    )
                                else
                                    ---服务端报错
                                    NetUtil.Broadcast('ErrorShowEvent', Const.ErrorLocationEnum.Server, res[1])
                                end
                            end
                        end
                        module[funcName] = hookedFunc
                    end
                end
            end
        end
    end
end

--- 初始化客户端逻辑
function InitClientLogic()
	--初始化事件
    InitEvent()
	--初始化UI
    InitUI()
	--- 初始化烘培寻路
    InitBakeNav()
end

--- 初始化烘培寻路
function InitBakeNav()
    local self = DebugModeLogic
	--位置：FrameworkConfigModule
	--如果开启调整模式
    if FrameworkConfig.DebugMode then
        Input.OnKeyDown:Connect(
            function()
				--按下F1
                if Input.GetPressKeyData(Enum.KeyCode.F1) == Enum.KeyState.KeyStatePress then
					--如果激活则隐藏，如果隐藏则激活
                    if self.root.BakeBtn.ActiveSelf then
                        self.root.BakeBtn:SetActive(false)
                    else
                        self.root.BakeBtn:SetActive(true)
                    end
                end
            end
        )
    end
end

--- 创建寻路数据
function BakeNav()
	---生成导航网格
	--位置：Module.Edit_Module.BakeNavMeshModule
    BakeNavMesh.CreateData()
end

return DebugModeLogic
