--[[

播放动画:
StartAnimationEvent:Fire(string _AnimationName,bool _isRunBack)
	_AnimationName:需要播放的动画名称
	 _isRunBack:是否倒放,true为倒放,缺省或false为倒放
监听动画状态:
AnimationStateEvent:Connect(function(_string AnimationName, _string Tag) end)
	_AnimationName:监听的动画名称 
	_Tag:动画状态.默认在设置完初始帧后返回'Start',在完成最后一帧后返回'Complete'.在设置有Tag的关键帧处返回Tag
	
配置表:
!!!!!!!!!!注:因为配置表不填会有默认数据,所以配置表中0与0,0被设置为了无效数据,需要零值的可以用0.01代替!!!!!!!

Type:默认字段
AnimationName:动画名,同一段动画可以设置多个UI控件的改变,作为StartAnimationEvent的参数传入
Count:总帧数,在每段动画的第一行填写,播放完该帧后则停止该段动画播放并传回'Complete'
UINode:动画所绑定的UI控件节点,目前仅支持Local下的动画节点,以Local.开头,否则无法找到动画节点.每个节点的动画帧独立设置
IsInit:是否为初始帧,每一个UI节点动画的第一行配置该节点的初始状态,将IsInit设置为true,KeyFrame设置为0.初始帧会在动画播放前设置完毕,然后传回'Start'
KeyFrame:关键帧,单位为"帧",必须按顺序设置,0帧为初始帧.如果乱序设置会出现未知的错误
Size..Alpha:各项UI属性
Tag:动画监听标签,在播放到该帧的时候会将Tag传回监听事件中
Type:速度变化方式,枚举值,目前仅有'Linear',缺省默认'Linear'

同一个界面同时的动画需要写在同一段动画中,目前不允许同时播放两段动画,避免意外的错误

--]]
