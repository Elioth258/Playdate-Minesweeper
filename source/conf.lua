
screenWidth = 400
screenHeight = 240

smallFont = playdate.graphics.font.new("fonts/Nontendo-Light")
bigFont   = playdate.graphics.font.new("fonts/Nontendo-Light-2x")

deltaTime = 0
muteMusic        = false
showDebugInfo    = false
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

function SmoothValue(smoothedValue, desiredValue, speed)
	return smoothedValue + (desiredValue - smoothedValue) * speed * deltaTime
end

function Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end