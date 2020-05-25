local root = script.Parent
local tweenerHand = Tween:TweenProperty(root.Dot.Hand,{Pivot = Vector2(0.35,1)},0.5,Enum.EaseCurve.Linear)
local tweenerCircle  = Tween:TweenProperty(root.Dot.Circle,{Size = Vector2(276,276),Alpha = 0},0.5,Enum.EaseCurve.Linear)
::Repeat::
--重置UI位置与状态
root.Dot.Hand.Pivot = Vector2(0.35,1.5)
root.Dot.Circle.Size =Vector2(48,48)
root.Dot.Circle.Alpha = 1
tweenerHand:Play()
tweenerHand:WaitForComplete()
tweenerCircle:Play()
tweenerCircle:WaitForComplete()
goto Repeat