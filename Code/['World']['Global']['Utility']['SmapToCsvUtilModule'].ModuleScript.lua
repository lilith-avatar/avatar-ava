--- 节点属性导出工具
--- @module ValueChangeUtil Module
--- @copyright Lilith Games, Avatar Team
--- @author Changoo Wu
local SmapToCsvUtil,this = {},nil

function SmapToCsvUtil:Init()
	filePath = "F:/output.csv"
	file= io.open(filePath,"w")
	local data
	io.output(file)
	io.write("ID,Name,Position,Rotation,Scale,Stretch/Size,\n")
	for k,v in pairs(Editor.Selections) do 
		if pcall(function() print(v.Scale) end) then
			data = tostring(k)..","..v.Name..",".."\""..tostring(v.Position).."\""..",".."\""..tostring(v.Rotation).."\""..","..tostring(v.Scale)..",".."\""..tostring(v.Stretch).."\"".."\n"
		else
			data = tostring(k)..","..v.Name..",".."\""..tostring(v.Position).."\""..",".."\""..tostring(v.Rotation).."\""..",".."nil"..",".."\""..tostring(v.Size).."\"".."\n"
		end
		io.write(data)
	end
	io.close(file)
	print('文件已保存至'..filePath)
end

return SmapToCsvUtil

--- 使用方式：在编辑模式下，用鼠标框选world Hierarchy下节点，复制粘贴以下代码至output命令行运行，即可在函数设定的目录得到记录所选节点属性的csv文件
--- require(world.Global.Utility.SmapToCsvUtilModule):Init()

--- PS:输出文件需关闭。
--- PS2：基础包含ID,Name,Position,Rotation,Scale,Stretch属性，按需魔改
--- PS3：魔改后需要Play后Stop再执行，或重启客户端，或直接粘贴函数体。