---@module LeadingSystem
---@copyright Lilith Games, Avatar Team
---@author Sid Zhang

local LeadingSystem = {}

--- 显示强引导Ui
---@param _type Int 1:点击
---@param _position Vector2 生成引导UI在屏幕的位置,Anchors值
---@param _area Vector2 响应范围,Size
---@param _content String 文本介绍,nil则不显示文本
function LeadingSystem:ShowLeading(_type,_position,_area,_content,_callBack,...)
	local args = {...}
	if _type == 1 then
		local leadingNode = world:CreateInstance('ClickLeading','ClickLeading',localPlayer.Local)
		if _position then
			leadingNode.Dot.AnchorsX = Vector2(_position.X,_position.X)
			leadingNode.Dot.AnchorsY = Vector2(_position.Y,_position.Y)
		end
		if _content then
			leadingNode.Dot.TextBox.Content.Text = _content
		else
			leadingNode.Dot.TextBox.Visible = false
		end
		if _area then leadingNode.Dot.Close.Size = _area end
		leadingNode.Dot.Close.OnClick:Connect(function()
			if _callBack and type(_callBack) == 'function' then
				_callBack(table.unpack(args))
			end
			leadingNode:Destroy()
		end)
	else
		warn("param #1 :_type error")
	end
end

return LeadingSystem