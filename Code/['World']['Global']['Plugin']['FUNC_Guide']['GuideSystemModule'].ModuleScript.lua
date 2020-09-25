---引导系统
---@module GuideSystem
---@copyright Lilith Games, Avatar Team
---@author Sid Zhang, Yuancheng Zhang

local GuideSystem = {}

--- 引导的枚举类型
GuideSystem.Enum = {
	ClickGuide = 'ClickGuide'
}

--- 显示强引导Ui
---@param _type Int 1:点击
---@param _position Vector2 生成引导UI在屏幕的位置,Anchors值
---@param _area Vector2 响应范围,Size
---@param _content string 文本介绍,nil则不显示文本
---@param _isForce boolean 是否强制引导
function GuideSystem:ShowGuide(_type, _position, _area, _content, _isForce, _callBack, ...)
	local args = {...}
	if _type == GuideSystem.Enum.ClickGuide then
		local GuideNode = world:CreateInstance('ClickGuide', 'ClickGuide', localPlayer.Local)
		if _isForce == false then
			GuideNode.FigBackground.Visible = false
		end
		if _position then
			GuideNode.ImgDot.AnchorsX = Vector2(_position.X, _position.X)
			GuideNode.ImgDot.AnchorsY = Vector2(_position.Y, _position.Y)
		end
		if _content then
			GuideNode.ImgDot.FigTextBox.TxtContent.Text = _content
		else
			GuideNode.ImgDot.FigTextBox.Visible = false
		end
		if _area then
			GuideNode.ImgDot.BtnClose.Size = _area
		end
		GuideNode.ImgDot.BtnClose.OnClick:Connect(
			function()
				if _callBack and type(_callBack) == 'function' then
					_callBack(table.unpack(args))
				end
				GuideNode:Destroy()
			end
		)
	else
		warn('param #1 :_type error')
	end
end

return GuideSystem
