local gfx <const> = playdate.graphics

screenWidth  = 400
screenHeight = 240

smallFont = gfx.font.new("fonts/Nontendo-Light")
bigFont   = gfx.font.new("fonts/Nontendo-Light-2x")

deltaTime = 0
totalTime = 0
muteMusic        = false
showDebugInfo    = true
directlyGoInGame = true

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
	local returnValue = smoothedValue + (desiredValue - smoothedValue) * speed * deltaTime
	if math.abs(desiredValue - smoothedValue) < 0.005 then returnValue = desiredValue end
	return returnValue
end

function Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function Direction(x1, y1, x2, y2)
    local dir = {dx = x2 - x1, dy = y2 - y1}
    -- Normalize the vector (optional step)
    local length = math.sqrt(dir.dx^2 + dir.dy^2)
    if length ~= 0 then
        dir.dx = dir.dx / length
        dir.dy = dir.dy / length
    end
    return dir
end

function OutlinedRectangle(width, height, lineWidth)
    local image = gfx.image.new(width, height)

    gfx.pushContext(image)
    gfx.setLineWidth(lineWidth)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, width, height)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(0, 0, width, height)
    gfx.popContext()

    return image
end

function OutlinedText(rawText, font)
    gfx.setFont(font)
    local width, height = gfx.getTextSize(rawText)
    local text = gfx.image.new(width + 3, height + 3)

    gfx.pushContext(text)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    for i = 0, 2, 1 do
        for j = 0, 2, 1 do
            gfx.drawText(rawText, i, j)
        end
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.drawText(rawText, 1, 1)
    gfx.popContext()

    return text
end