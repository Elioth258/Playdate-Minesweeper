import "conf"
import "audio"

local gfx <const> = playdate.graphics

local imgBackground = gfx.image.new("images/Menu/Background")

local backgroundDeltaX = 0

function UpdateMainMenu()
    if deltaTime then backgroundDeltaX += deltaTime * 50 end
end
function DrawMainMenu()
    if imgBackground then imgBackground:draw((backgroundDeltaX % screenWidth), 0) end
    if imgBackground then imgBackground:draw((backgroundDeltaX % screenWidth) - screenWidth, 0) end
end