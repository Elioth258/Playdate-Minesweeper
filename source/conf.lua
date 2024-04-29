
screenWidth = 400
screenHeight = 240

smallFont    = playdate.graphics.font.new("fonts/Nontendo-Light")
bigFont      = playdate.graphics.font.new("fonts/Nontendo-Light-2x")
smallNumFont = playdate.graphics.font.new("fonts/Nontendo-Light-2x")

deltaTime = 0
totalTime = 0
muteMusic        = false
showDebugInfo    = true
directlyGoInGame = false

function Clamp(value, min, max)
	if value < min then
		value = min
	elseif value > max then
		value = max
	end
	return value
end

function Lerp(start, finish, t)
    t = math.max(0, math.min(1, t))
    return start + t * (finish - start)
end

function SmoothValue(smoothedValue, desiredValue, speed, deltaTime)
	local returnValue = smoothedValue + (desiredValue - smoothedValue) * speed * deltaTime
	if math.abs(desiredValue - smoothedValue) < 0.005 then returnValue = desiredValue end
	return returnValue
end

function Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end