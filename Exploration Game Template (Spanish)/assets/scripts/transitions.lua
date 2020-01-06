-- Some useful transitions
-- Omit arguments or pass nil to use the default values
-- For example: transitions.showFadeLeft(sprite, nil, true)

transitions = {}

-- Fade with movement to the left
transitions.showFadeLeft = function(object, x, block, offset, time)
	local objx, y = object:getPosition()

	local x = x or objx
	local block = block or false
	local offset = offset or 15
	local time = time or 0.3

	object:setPosition(x + offset, y)
	object:move(x, y, time, false, Interpolator.easeOut)
	object:show({type=Transition.fade, time=time, block=block})
end

-- Fade with movement to the left
transitions.hideFadeLeft = function(object, x, block, offset, time)
	local objx, y = object:getPosition()

	local x = x or objx
	local block = block or false
	local offset = offset or 15
	local time = time or 0.3

	object:move(x - offset, y, time, false, Interpolator.easeIn)
	object:hide({type=Transition.fade, time=time, block=block})
end

-- Fade with movement to the right
transitions.showFadeRight = function(object, x, block, offset, time)
	local objx, y = object:getPosition()

	local x = x or objx
	local offset = offset or 15

	transitions.showFadeLeft(object, x, block, -offset, time)
end

-- Fade with movement to the right
transitions.hideFadeRight = function(object, x, block, offset, time)
	local objx, y = object:getPosition()

	local x = x or objx
	local offset = offset or 15

	transitions.hideFadeLeft(object, x, block, -offset, time)
end

-- Fade with movement up
transitions.showFadeUp = function(object, y, block, offset, time)
	local x, objy = object:getPosition()

	local y = y or objy
	local block = block or false
	local offset = offset or 15
	local time = time or 0.3

	object:setPosition(x, y + offset)
	object:move(x, y, time, false, Interpolator.easeOut)
	object:show({type=Transition.fade, time=time, block=block})
end

-- Fade with movement up
transitions.hideFadeUp = function(object, y, block, offset, time)
	local x, objy = object:getPosition()

	local y = y or objy
	local block = block or false
	local offset = offset or 15
	local time = time or 0.3

	object:move(x, y - offset, time, false, Interpolator.easeIn)
	object:hide({type=Transition.fade, time=time, block=block})
end

-- Fade with movement down
transitions.showFadeDown = function(object, y, block, offset, time)
	local x, objy = object:getPosition()

	local y = y or objy
	local offset = offset or 15

	transitions.showFadeUp(object, y, block, -offset, time)
end

-- Fade with movement down
transitions.hideFadeDown = function(object, y, block, offset, time)
	local x, objy = object:getPosition()

	local y = y or objy
	local offset = offset or 15

	transitions.hideFadeUp(object, y, block, -offset, time)
end

-- Other useful transitions
transitions.blockFade = {type=Transition.fade, time=0.3, block=true}
transitions.swipeRight = {type=Transition.imageDissolve, image="fade right.png", time=0.5}