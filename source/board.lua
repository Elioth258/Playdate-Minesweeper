import "conf"
import "audio"

local gfx <const> = playdate.graphics

local imgCursor = gfx.image.new("images/Cursor")

local imgBorderHorizontal = gfx.image.new("images/Board/Horizontal")
local imgBorderCorner     = gfx.image.new("images/Board/Corner")

local imgQuestion = gfx.image.new("images/Tiles/Question")
local imgHidden   = gfx.image.new("images/Tiles/Hidden")
local imgEmpty    = gfx.image.new("images/Tiles/Empty")
local imgFlag     = gfx.image.new("images/Tiles/Flag")
local imgBomb     = gfx.image.new("images/Tiles/Bomb")

local board = {
    width  = 15,
    height = 10,

    maxBomb = 15,
    tileMap = {},
}
local tileSize = 20

local cursorPosCur   = {x = math.ceil(board.width / 2), y = math.ceil(board.height / 2)}
local cursorPosDelta = {x = cursorPosCur.x, y = cursorPosCur.y}
local cursorSpeed    = 20

local tileLeftToWin = 0
local gameState = "none" -- none / win / lose

local mapIsInitialised = false
local mapBorder = nil

local dropletList = {}

function InitBorder()
    local horizontalBorder = gfx.image.new(board.width * tileSize, 8)
    gfx.pushContext(horizontalBorder)
    for i = 0, board.width, 1 do
        if imgBorderHorizontal then imgBorderHorizontal:draw(tileSize * i, 0) end
    end
    gfx.popContext()

    local verticalBorder = gfx.image.new(board.height * tileSize, 8)
    gfx.pushContext(verticalBorder)
    for i = 0, board.height, 1 do
        if imgBorderHorizontal then imgBorderHorizontal:draw(tileSize * i, 0) end
    end
    gfx.popContext()

    mapBorder = gfx.image.new(board.width * tileSize + 16, board.height * tileSize + 16)
    gfx.pushContext(mapBorder)
    if horizontalBorder then horizontalBorder:drawRotated(board.width * tileSize / 2 + 8, 4, 0) end
    if horizontalBorder then horizontalBorder:drawRotated(board.width * tileSize / 2 + 8, board.height * tileSize + 12, 180) end
    if verticalBorder then verticalBorder:drawRotated(4, board.height * tileSize / 2 + 8, 270) end
    if verticalBorder then verticalBorder:drawRotated(board.width * tileSize + 12, board.height * tileSize / 2 + 8, 90) end

    if imgBorderCorner then imgBorderCorner:drawRotated(4, 4, 0) end
    if imgBorderCorner then imgBorderCorner:drawRotated(board.width * tileSize + 12, 4, 90) end
    if imgBorderCorner then imgBorderCorner:drawRotated(4, board.height * tileSize + 12, 270) end
    if imgBorderCorner then imgBorderCorner:drawRotated(board.width * tileSize + 12, board.height * tileSize + 12, 180) end
    gfx.popContext()
end
function InitBoard(bannedPos)
    local function CreateTile()
        local newTile = {
            state  = "none", -- none -> flag -> question
            reveal = false,
            bombed = false,
            number = 0,
            image  = imgHidden
        }
        return newTile
    end

    for i = 1, board.height, 1 do
        board.tileMap[i] = {}
        for j = 1, board.width, 1 do
            board.tileMap[i][j] = CreateTile()
        end
    end

    local curBomb = 0
    while curBomb < board.maxBomb do
        local x = math.random(1, board.width)
        local y = math.random(1, board.height)
        local forbidenPos = (x >= bannedPos.x - 1) and (x <= bannedPos.x + 1) and (y >= bannedPos.y - 1) and (y <= bannedPos.y + 1)

        if not board.tileMap[y][x].bombed and not forbidenPos then
            board.tileMap[y][x].bombed = true
            curBomb = curBomb + 1

            for dy = Clamp(y - 1, 1, board.height), Clamp(y + 1, 1, board.height), 1 do
                for dx = Clamp(x - 1, 1, board.width), Clamp(x + 1, 1, board.width), 1 do
                    board.tileMap[dy][dx].number += 1
                end
            end
        end
    end
end

function StartGameBoard(width, height, maxBomb)
    board.width    = width
    board.height   = height
    board.maxBomb  = maxBomb
    board.tileMap  = {}

    tileLeftToWin = width * height - maxBomb
    gameState = "none"

    cursorPosCur   = {x = math.ceil(width / 2), y = math.ceil(height / 2)}
    cursorPosDelta = {x = cursorPosCur.x, y = cursorPosCur.y}

    mapIsInitialised = false
    mapBorder = nil
	InitBorder()
end
function UpdateBoard()
    local function SearchTile(x, y)
        if x < 1 or y < 1 or x > board.width or y > board.height or board.tileMap[y][x].reveal or board.tileMap[y][x].state == "flag" or board.tileMap[y][x].state == "question" then
            return
        end

        board.tileMap[y][x].reveal = true
        UpdateTileImage(board.tileMap[y][x])
        if board.tileMap[y][x].bombed then
            gameState = "lose"
        else
            tileLeftToWin -= 1
            if tileLeftToWin == 0 then
                gameState = "win"
            end
        end

        if board.tileMap[y][x].number == 0 then
            for i = -1, 1, 1 do
                for j = -1, 1, 1 do
                    SearchTile(x + i, y + j)
                end
            end
        end
    end

    if gameState == "none" then
        if playdate.buttonJustPressed(playdate.kButtonA)  then
            if not mapIsInitialised then
                mapIsInitialised = true
                InitBoard(cursorPosCur)
            end
    
            local tile = board.tileMap[cursorPosCur.y][cursorPosCur.x]
            if tile.reveal and tile.number > 0 and not (tile.state == "flag") and not (tile.state == "question") then
    
                local nbFlags = 0
                for i = Clamp(cursorPosCur.x -1, 1, board.width), Clamp(cursorPosCur.x + 1, 1, board.width), 1 do
                    for j = Clamp(cursorPosCur.y -1, 1, board.height), Clamp(cursorPosCur.y + 1, 1, board.height), 1 do
                        if board.tileMap[j][i].state == "flag" then nbFlags += 1 end
                    end
                end
                if nbFlags == tile.number then
                    for i = -1, 1, 1 do
                        for j = -1, 1, 1 do
                            SearchTile(cursorPosCur.x + i, cursorPosCur.y + j)
                        end
                    end
                end
            else
                SearchTile(cursorPosCur.x, cursorPosCur.y)
            end
    
            CreateDroplet(cursorPosCur.x, cursorPosCur.y, 1)
    
            if gameState == "win" then
                
            elseif gameState == "lose" then
                
            end
        end
        if playdate.buttonJustPressed(playdate.kButtonB) and mapIsInitialised then
            if board.tileMap[cursorPosCur.y][cursorPosCur.x].reveal == false then
                local txtState = board.tileMap[cursorPosCur.y][cursorPosCur.x].state
    
                if txtState == "none"     then board.tileMap[cursorPosCur.y][cursorPosCur.x].state = "flag"     end
                if txtState == "flag"     then board.tileMap[cursorPosCur.y][cursorPosCur.x].state = "question" end
                if txtState == "question" then board.tileMap[cursorPosCur.y][cursorPosCur.x].state = "none"     end
    
                UpdateTileImage(board.tileMap[cursorPosCur.y][cursorPosCur.x])
            end
        end
    
        if playdate.buttonJustPressed(playdate.kButtonUp) and cursorPosCur.y > 1 then
            cursorPosCur.y -= 1
        end
        if playdate.buttonJustPressed(playdate.kButtonDown) and cursorPosCur.y < board.height then
            cursorPosCur.y += 1
        end
        if playdate.buttonJustPressed(playdate.kButtonLeft) and cursorPosCur.x > 1 then
            cursorPosCur.x -= 1
        end
        if playdate.buttonJustPressed(playdate.kButtonRight) and cursorPosCur.x < board.width then
            cursorPosCur.x += 1
        end

        cursorPosDelta.x = SmoothValue(cursorPosDelta.x, cursorPosCur.x, cursorSpeed)
        cursorPosDelta.y = SmoothValue(cursorPosDelta.y, cursorPosCur.y, cursorSpeed)
    end

    for i, drop in ipairs(dropletList) do
        drop.size += deltaTime * tileSize * 15
        if drop.size > 300 then
            table.remove(dropletList, i)
        end
    end
end
function DrawBoard()
    local startX = (screenWidth - (board.width * tileSize)) / 2
    local startY = (screenHeight - (board.height * tileSize)) / 2

    if mapBorder then mapBorder:draw(startX - 8, startY - 8) end

    for i = 1, board.height, 1 do
        for j = 1, board.width, 1 do
            local x = startX + (j - 1) * tileSize
            local y = startY + (i - 1) * tileSize

            for k, drop in ipairs(dropletList) do
                local dist = Distance(drop.pos.x, drop.pos.y, j, i) - drop.size / tileSize
                if math.abs(dist) < 1 then
                    local dir = Direction(drop.pos.x, drop.pos.y, j, i)

                    x += dir.dx * dist * drop.power
                    y += dir.dy * dist * drop.power
                end
            end

            if not mapIsInitialised then
                if imgHidden then imgHidden:draw(x, y) end
            else
                board.tileMap[i][j].image:draw(x, y)
            end
        end
    end

    if gameState == "none" then
        local cursorX = startX + (cursorPosDelta.x - 1) * tileSize + 12
        local cursorY = startY + (cursorPosDelta.y - 1) * tileSize + 10
        if imgCursor then imgCursor:draw(cursorX, cursorY) end
    end
end

function CreateDroplet(x, y, power)
    local newDroplet = {
        pos   = {x = x, y = y},
        power = power,
        size  = 0,
    }

    dropletList[#dropletList + 1] = newDroplet
end
function UpdateTileImage(tile)
    gfx.setFont(smallFont)
    tile.image  = gfx.image.new(tileSize + 1, tileSize + 1)

    gfx.pushContext(tile.image)

    if tile.reveal then
        if imgEmpty then imgEmpty:draw(0, 0) end
        if tile.bombed then
            if imgBomb then imgBomb:draw(0, 0) end
        elseif tile.number > 0 then
            gfx.drawTextAligned(tile.number, tileSize / 2, tileSize / 4, kTextAlignment.center)
        end
    else
        if imgHidden then imgHidden:draw(0, 0) end
        if tile.state == "flag" then
            if imgFlag then imgFlag:draw(0, 0) end
        elseif tile.state == "question" then
            if imgQuestion then imgQuestion:draw(0, 0) end
        end
    end

    gfx.popContext()
end