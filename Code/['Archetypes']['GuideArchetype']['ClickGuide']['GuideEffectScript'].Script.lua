---引导系统-客户端表现
---@script Guide effect
---@copyright Lilith Games, Avatar Team
---@author Sid Zhang

local root = script.Parent
local tweenerHand = Tween:TweenProperty(root.ImgDot.ImgHand, {Pivot = Vector2(0.35, 1)}, 0.5, Enum.EaseCurve.Linear)
local tweenerCircle =
    Tween:TweenProperty(root.ImgDot.ImgCircle, {Size = Vector2(276, 276), Alpha = 0}, 0.5, Enum.EaseCurve.Linear)

::Repeat::
--重置UI位置与状态
root.ImgDot.ImgHand.Pivot = Vector2(0.35, 1.5)
root.ImgDot.ImgCircle.Size = Vector2(48, 48)
root.ImgDot.ImgCircle.Alpha = 1
tweenerHand:Play()
tweenerHand:WaitForComplete()
tweenerCircle:Play()
tweenerCircle:WaitForComplete()
goto Repeat
