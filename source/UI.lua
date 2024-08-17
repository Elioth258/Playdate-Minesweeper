import "board"
import "localization"
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

local imgMainBorder = nil
local imgEndScreen  = nil

local isSurprised = 0
local endScreenYCurrent = 0
local endScreenXCurrent = 0

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

    imgMainBorder = gfx.image.new(uiWidth * tileSize + 16, height * tileSize + 16)
    gfx.pushContext(imgMainBorder)
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

    endScreenYCurrent = SmoothValue(endScreenYCurrent, screenHeight / 2, 10)
    endScreenXCurrent = SmoothValue(endScreenXCurrent, screenWidth / 2, 10)
end

function DrawUI(startX, stopwatch, gameState)
    startX -= 38
    if imgMainBorder then imgMainBorder:drawCentered(startX, screenHeight / 2) end

    if imgFlagIcon then imgFlagIcon:drawCentered(startX + 8, screenHeight / 2 + 13) end
    if imgFlagLeft then imgFlagLeft:drawCentered(startX - 7, screenHeight / 2 + 15) end

    gfx.drawTextAligned(GetFormatedStopwatch(stopwatch), startX, screenHeight / 2 + 26, kTextAlignment.center)

    local imgFace = imgGuyNormal
    if     gameState == "win"  then imgFace = imgGuySunglasses
    elseif gameState == "lose" then imgFace = imgGuyDead
    elseif isSurprised > 0     then imgFace = imgGuySurprised end
    if imgFace then imgFace:drawCentered(startX, screenHeight / 2 - 20) end
end
function DrawUIOver(gameState)
    if not (gameState == "none") then
        if imgEndScreen then imgEndScreen:drawCentered(endScreenXCurrent, endScreenYCurrent) end
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

function GetFormatedStopwatch(stopwatch)
    local minutes = math.floor(stopwatch / 60)
    local seconds = math.floor(stopwatch % 60)
    local milliseconds = math.floor((stopwatch % 1) * 1000)

    local formatStopwatch = string.format("%02d:%02d:%03d", minutes, seconds, milliseconds)

    return formatStopwatch
end
function GetSurprised()
    isSurprised = 0.5
end

function GenerateEndScreen(gameState, stopwatch)
    local width  = 200
    local height = 100

    imgEndScreen = gfx.image.new(width, height)
    gfx.pushContext(imgEndScreen)

    OutlinedRectangle(width, height, 2):draw(0, 0)

    gfx.setFont(bigFont)
    if gameState == "win" then
        gfx.drawTextAligned(allLoc.boardWon[locID], width / 2, 10, kTextAlignment.center)

        gfx.setFont(smallFont)
        gfx.drawTextAligned(GetFormatedStopwatch(stopwatch), width / 2, height - 15, kTextAlignment.center)
    elseif gameState == "lose" then
        gfx.drawTextAligned(allLoc.boardLose[locID], width / 2, 10, kTextAlignment.center)
    end

    gfx.popContext()


    endScreenYCurrent = screenHeight / 2
    endScreenXCurrent = screenWidth / 2

    local rand = math.random(4)
    print(rand)
    if rand == 1 then endScreenYCurrent = screenHeight + height / 2 end
    if rand == 2 then endScreenXCurrent = screenWidth + width / 2 end
    if rand == 3 then endScreenYCurrent = -height / 2 end
    if rand == 4 then endScreenXCurrent = -width / 2 end
end