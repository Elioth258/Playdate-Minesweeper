import "board"
import "conf"

local gfx <const> = playdate.graphics

local imgBorderHorizontal = gfx.image.new("images/Board/Horizontal")
local imgBorderCorner     = gfx.image.new("images/Board/Corner")

local imgFlagIcon = gfx.image.new("images/UI/Flag")
local imgFlagLeft = gfx.image.new("images/UI/Flag")

local imgGuyNormal     = gfx.image.new("images/Guy/Normal")
local imgGuySurprised  = gfx.image.new("images/Guy/Surprised")
local imgGuySunglasses = gfx.image.new("images/Guy/Sunglasses")
local imgGuyDead       = gfx.image.new("images/Guy/Dead")

local imgBorder = nil

function InitUIBorder(height, tileSize)
    local uiWidth = 3

    local horizontalBorder = gfx.image.new(uiWidth * tileSize, 8)
    gfx.pushContext(horizontalBorder)
    for i = 0, uiWidth, 1 do
        if imgBorderHorizontal then imgBorderHorizontal:draw(tileSize * i, 0) end
    end
    gfx.popContext()

    local verticalBorder = gfx.image.new(height * tileSize, 8)
    gfx.pushContext(verticalBorder)
    for i = 0, height, 1 do
        if imgBorderHorizontal then imgBorderHorizontal:draw(tileSize * i, 0) end
    end
    gfx.popContext()

    imgBorder = gfx.image.new(uiWidth * tileSize + 16, height * tileSize + 16)
    gfx.pushContext(imgBorder)
    if horizontalBorder then horizontalBorder:drawRotated(uiWidth * tileSize / 2 + 8, 4, 0) end
    if horizontalBorder then horizontalBorder:drawRotated(uiWidth * tileSize / 2 + 8, height * tileSize + 12, 180) end
    if verticalBorder   then verticalBorder:drawRotated(4, height * tileSize / 2 + 8, 270) end

    if imgBorderCorner then imgBorderCorner:drawRotated(4, 4, 0) end
    if imgBorderCorner then imgBorderCorner:drawRotated(4, height * tileSize + 12, 270) end

    local y = height * tileSize / 2 + 8
    gfx.drawLine(8, y, uiWidth * tileSize + 8, y)
    y = height * tileSize / 2 + 50
    gfx.drawLine(8, y, uiWidth * tileSize + 8, y)
    y = height * tileSize / 2 - 35
    gfx.drawLine(8, y, uiWidth * tileSize + 8, y)

    gfx.popContext()
end

function UpdateUI()

end

function DrawUI(startX, stopwatch)
    startX -= 38
    if imgBorder then imgBorder:drawCentered(startX, screenHeight / 2) end

    if imgFlagIcon then imgFlagIcon:drawCentered(startX + 8, screenHeight / 2 + 13) end
    if imgFlagLeft then imgFlagLeft:drawCentered(startX - 7, screenHeight / 2 + 15) end

    local minutes = math.floor(stopwatch / 60)
    local seconds = math.floor(stopwatch % 60)
    local milliseconds = math.floor((stopwatch % 1) * 1000)

    local formatStopwatch = string.format("%02d:%02d:%03d", minutes, seconds, milliseconds)
    gfx.drawTextAligned(formatStopwatch, startX, screenHeight / 2 + 26, kTextAlignment.center)

    if playdate.buttonIsPressed(playdate.kButtonUp) then
        if imgGuyNormal then imgGuyNormal:drawCentered(startX, screenHeight / 2 - 20) end
    end
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        if imgGuySurprised then imgGuySurprised:drawCentered(startX, screenHeight / 2 - 20) end
    end
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        if imgGuySunglasses then imgGuySunglasses:drawCentered(startX, screenHeight / 2 - 20) end
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        if imgGuyDead then imgGuyDead:drawCentered(startX, screenHeight / 2 - 20) end
    end
end

function UpdateFlagLeftUI(flagLeft)
    gfx.setFont(smallFont)
    local width, height = gfx.getTextSize(tostring(flagleft))
    imgFlagLeft = gfx.image.new(width, height)

    gfx.pushContext(imgFlagLeft)
    gfx.drawTextAligned(flagLeft, width, 0, kTextAlignment.right)
    gfx.popContext()
end