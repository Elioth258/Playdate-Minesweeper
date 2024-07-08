import "conf"
import "audio"

local gfx <const> = playdate.graphics

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
local tileSize = 19

local cursorPos = {x = math.ceil(board.width / 2), y = math.ceil(board.height / 2)}

local mapIsInitialised = false

local dropletList = {}

function InitBoard(bannedPos)
    local function CreateTile()
        local newTile = {
            state  = "none", -- none -> flag -> question
            reveal = false,
            bombed = false,
            number = 0,
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

        if not board.tileMap[y][x].bombed and not (x == bannedPos.x and y == bannedPos.y) then
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
function UpdateBoard()
    local function SearchTile(x, y)
        if x < 1 or y < 1 or x > board.width or y > board.height or board.tileMap[y][x].reveal or board.tileMap[y][x].state == "flag" or board.tileMap[y][x].state == "question" then
            return
        end
        board.tileMap[y][x].reveal = true

        if board.tileMap[y][x].number == 0 then
            for i = -1, 1, 1 do
                for j = -1, 1, 1 do
                    SearchTile(x + i, y + j)
                end
            end
        end
    end

    if playdate.buttonJustPressed(playdate.kButtonA) then
        if not mapIsInitialised then
            mapIsInitialised = true
            InitBoard(cursorPos)
        end

        local tile = board.tileMap[cursorPos.y][cursorPos.x]
        if tile.reveal and tile.number > 0 and not (tile.state == "flag") and not (tile.state == "question") then

            local nbFlags = 0
            for i = Clamp(cursorPos.x -1, 1, board.width), Clamp(cursorPos.x + 1, 1, board.width), 1 do
                for j = Clamp(cursorPos.y -1, 1, board.height), Clamp(cursorPos.y + 1, 1, board.height), 1 do
                    if board.tileMap[j][i].state == "flag" then nbFlags += 1 end
                end
            end
            if nbFlags == tile.number then
                for i = -1, 1, 1 do
                    for j = -1, 1, 1 do
                        SearchTile(cursorPos.x + i, cursorPos.y + j)
                    end
                end
            end
        else
            SearchTile(cursorPos.x, cursorPos.y)
        end

        CreateDroplet(cursorPos.x, cursorPos.y, 1)
    end
    if playdate.buttonJustPressed(playdate.kButtonB) and mapIsInitialised then
        if board.tileMap[cursorPos.y][cursorPos.x].reveal == false then
            local txtState = board.tileMap[cursorPos.y][cursorPos.x].state

            if txtState == "none"     then board.tileMap[cursorPos.y][cursorPos.x].state = "flag"     end
            if txtState == "flag"     then board.tileMap[cursorPos.y][cursorPos.x].state = "question" end
            if txtState == "question" then board.tileMap[cursorPos.y][cursorPos.x].state = "none"     end
        end
    end

    if playdate.buttonJustPressed(playdate.kButtonUp) and cursorPos.y > 1 then
        cursorPos.y -= 1
    end
    if playdate.buttonJustPressed(playdate.kButtonDown) and cursorPos.y < board.height then
        cursorPos.y += 1
    end
    if playdate.buttonJustPressed(playdate.kButtonLeft) and cursorPos.x > 1 then
        cursorPos.x -= 1
    end
    if playdate.buttonJustPressed(playdate.kButtonRight) and cursorPos.x < board.width then
        cursorPos.x += 1
    end

    for i, drop in ipairs(dropletList) do
        drop.size += deltaTime * tileSize * 15
        if drop.size > 250 then
            table.remove(dropletList, i)
        end
    end
end
function DrawBoard()
    local function DeltaY(dx, dy)
        return 0
        -- return math.sin((totalTime * 5) + dx + dy) * 1.05
    end

    gfx.setFont(smallFont)

    local startX = (screenWidth - (board.width * tileSize)) / 2
    local startY = (screenHeight - (board.height * tileSize)) / 2

    for i = 1, board.height, 1 do
        for j = 1, board.width, 1 do
            local x = (startX + (j - 1) * tileSize)
            local y = (startY + (i - 1) * tileSize) + DeltaY(i, j)

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

                if board.tileMap[i][j].reveal then
                    if imgEmpty then imgEmpty:draw(x, y) end

                    if board.tileMap[i][j].bombed then
                        if imgBomb then imgBomb:draw(x, y) end
                    elseif board.tileMap[i][j].number > 0 then
                        gfx.drawTextAligned(board.tileMap[i][j].number, x + tileSize / 2, y + tileSize / 4, kTextAlignment.center)
                    end
                elseif board.tileMap[i][j].state == "flag" then
                    if imgFlag then imgFlag:draw(x, y) end
                elseif board.tileMap[i][j].state == "question" then
                    if imgQuestion then imgQuestion:draw(x, y) end
                else
                    if imgHidden then imgHidden:draw(x, y) end
                end
            end
        end
    end

    local cursorX = startX + (cursorPos.x - 1) * tileSize + 2
    local cursorY = startY + (cursorPos.y - 1) * tileSize + 2 + DeltaY(cursorPos.x, cursorPos.y)
    gfx.drawRect(cursorX, cursorY, tileSize - 3, tileSize - 3)
end

function CreateDroplet(x, y, power)
    local newDroplet = {
        pos   = {x = x, y = y},
        power = power,
        size  = 0,
    }

    dropletList[#dropletList + 1] = newDroplet
end