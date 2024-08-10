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

local isSurprised = 0

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

    local function Lines(y)
        gfx.drawLine(8, y, uiWidth * tileSize + 8, y)
    end

    local baseY = height * tileSize / 2
    Lines(baseY - 35)
    Lines(baseY + 8)
    Lines(baseY + 50)

    gfx.popContext()
end

function UpdateUI()
    if isSurprised > 0 then
        if deltaTime then isSurprised -= deltaTime end
    end
end

function DrawUI(startX, stopwatch, gameState)
    startX -= 38
    if imgBorder then imgBorder:drawCentered(startX, screenHeight / 2) end

    if imgFlagIcon then imgFlagIcon:drawCentered(startX + 8, screenHeight / 2 + 13) end
    if imgFlagLeft then imgFlagLeft:drawCentered(startX - 7, screenHeight / 2 + 15) end

    local minutes = math.floor(stopwatch / 60)
    local seconds = math.floor(stopwatch % 60)
    local milliseconds = math.floor((stopwatch % 1) * 1000)

    local formatStopwatch = string.format("%02d:%02d:%03d", minutes, seconds, milliseconds)
    gfx.drawTextAligned(formatStopwatch, startX, screenHeight / 2 + 26, kTextAlignment.center)

    local imgFace = imgGuyNormal
    if     gameState == "win"  then imgFace = imgGuySunglasses
    elseif gameState == "lose" then imgFace = imgGuyDead
    elseif isSurprised > 0     then imgFace = imgGuySurprised end
    if imgFace then imgFace:drawCentered(startX, screenHeight / 2 - 20) end
end

function UpdateFlagLeftUI(flagLeft)
    gfx.setFont(smallFont)
    local width, height = gfx.getTextSize(tostring(flagleft))
    imgFlagLeft = gfx.image.new(width, height)

    gfx.pushContext(imgFlagLeft)
    gfx.drawTextAligned(flagLeft, width, 0, kTextAlignment.right)
    gfx.popContext()
end

function GetSurprised()
    isSurprised = 0.5
end