import "conf"

local gfx <const> = playdate.graphics

local imgBorderHorizontal = gfx.image.new("images/Board/Horizontal")
local imgBorderCorner     = gfx.image.new("images/Board/Corner")

local imgFlagIcon = gfx.image.new("images/UI/Flag")
local imgFlagLeft = gfx.image.new("images/UI/Flag")

local UIBorder = nil

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

    UIBorder = gfx.image.new(uiWidth * tileSize + 16, height * tileSize + 16)
    gfx.pushContext(UIBorder)
    if horizontalBorder then horizontalBorder:drawRotated(uiWidth * tileSize / 2 + 8, 4, 0) end
    if horizontalBorder then horizontalBorder:drawRotated(uiWidth * tileSize / 2 + 8, height * tileSize + 12, 180) end
    if verticalBorder   then verticalBorder:drawRotated(4, height * tileSize / 2 + 8, 270) end

    if imgBorderCorner then imgBorderCorner:drawRotated(4, 4, 0) end
    if imgBorderCorner then imgBorderCorner:drawRotated(4, height * tileSize + 12, 270) end
    gfx.popContext()
end

function UpdateUI()

end

function DrawUI(startX)
    startX -= 40
    if UIBorder then UIBorder:drawCentered(startX, screenHeight / 2) end

    if imgFlagIcon then imgFlagIcon:drawCentered(startX + 10, screenHeight / 2 + 20) end
    if imgFlagLeft then imgFlagLeft:drawCentered(startX - 5,  screenHeight / 2 + 22) end
end

function UpdateFlagLeftUI(flagLeft)
    gfx.setFont(smallFont)
    local width, height = gfx.getTextSize(tostring(flagleft))
    imgFlagLeft = gfx.image.new(width, height)

    gfx.pushContext(imgFlagLeft)
    gfx.drawTextAligned(flagLeft, width, 0, kTextAlignment.right)
    gfx.popContext()
end