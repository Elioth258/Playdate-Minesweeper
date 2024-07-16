import "transition"
import "conf"
import "audio"

local gfx <const> = playdate.graphics

local imgBackground = gfx.image.new("images/Menu/Background")
local imgMenuBoxes = {}
local imgSelection = nil

local backgroundDeltaX = 0

local menuMainI       = 1
local menuMainSmoothI = 1

local subState = "menu" -- menu / rules / credits

function ChangeLanguage()
    locID = locID + 1
    if locID > #locISO then locID = 1 end
    InitMenuBoxes()
end
function InitMenuBoxes()
    local boxLoc = {allLoc.mainPlay, allLoc.mainLanguage, allLoc.mainRules, allLoc.mainCredits}

    for i = 1, 4, 1 do
        imgMenuBoxes[i] = gfx.image.new(145, 35)
        gfx.pushContext(imgMenuBoxes[i])

        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, 145, 35)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(0, 0, 145, 35)
        gfx.setFont(bigFont)
        gfx.drawTextAligned(boxLoc[i][locID], 145 / 2, 8, kTextAlignment.center)

        gfx.popContext()
    end

    imgSelection = gfx.image.new(151, 41)
    gfx.pushContext(imgSelection)
    gfx.drawRect(0, 0, 151, 41)
    gfx.drawRect(1, 1, 149, 39)
    gfx.popContext()
end
function SetMenuType(newMenu)
    subState = newMenu
end

function UpdateMainMenu()
    local function UpdateMenu()
        if playdate.buttonJustPressed(playdate.kButtonUp) and menuMainI > 1 then
            PlayAudioTable(soundSwipes)
            menuMainI = menuMainI - 1
        elseif playdate.buttonJustPressed(playdate.kButtonDown) and menuMainI < 4 then
            PlayAudioTable(soundSwipes)
            menuMainI = menuMainI + 1
        elseif playdate.buttonJustPressed(playdate.kButtonA) then
            PlayAudio(soundMenuSelect)
            if menuMainI == 1 then LaunchTransition("play")  end
            if menuMainI == 2 then ChangeLanguage()            end
            if menuMainI == 3 then LaunchTransition("rules")   end
            if menuMainI == 4 then LaunchTransition("credits") end
        end
        menuMainSmoothI = SmoothValue(menuMainSmoothI, menuMainI, 10)

        if deltaTime then backgroundDeltaX = (backgroundDeltaX + deltaTime * 30) % screenWidth  end
    end
    local function UpdateRules()
        
    end
    local function UpdateCredits()
        
    end

    if     subState == "menu" then    UpdateMenu()
    elseif subState == "rules" then   UpdateRules()
    elseif subState == "credits" then UpdateCredits() end

    UpdateTransition()
end
function DrawMainMenu()
    local function DrawMenu()
        gfx.setFont(bigFont)
        gfx.drawTextAligned("MINESWEEPER", screenWidth / 2, 30, kTextAlignment.center)

        for i, menuBox in ipairs(imgMenuBoxes) do
            menuBox:drawCentered(screenWidth / 2, 50 + i * 40)
        end

        if imgSelection then imgSelection:drawCentered(screenWidth / 2, 50 + menuMainSmoothI * 40) end
    end
    local function DrawRules()

    end
    local function DrawCredits()

    end

    if imgBackground then imgBackground:draw(backgroundDeltaX, 0) end
    if imgBackground then imgBackground:draw(backgroundDeltaX - screenWidth, 0) end

    if     subState == "menu" then    DrawMenu()
    elseif subState == "rules" then   DrawRules()
    elseif subState == "credits" then DrawCredits() end

    DrawTransition()
end