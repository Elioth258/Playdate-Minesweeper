import "transition"
import "audio"
import "conf"

local gfx <const> = playdate.graphics

local imgBackground     = gfx.image.new("images/Menu/Background")
local imgBallEmpty      = gfx.image.new("images/Menu/RuleBallEmpty")
local imgBallFull       = gfx.image.new("images/Menu/RuleBallFull")
local imgSelectionArrow = gfx.image.new("images/Menu/SelectionArrow")

local imgRuleMainGoal   = gfx.image.new("images/Menu/Rules/MainGoal")
local imgRuleBoard      = gfx.image.new("images/Menu/Rules/Board")
local imgRuleClick      = gfx.image.new("images/Menu/Rules/Click")
local imgRuleNumber     = gfx.image.new("images/Menu/Rules/Number")
local imgRuleDeduce     = gfx.image.new("images/Menu/Rules/Deduce")
local imgRuleMarking    = gfx.image.new("images/Menu/Rules/Marking")
local imgRuleUncovering = gfx.image.new("images/Menu/Rules/Uncovering")

local imgMainTitle        = OutlinedText(allLoc.mainTitle[locID], bigFont)
local imgMenuBackground   = OutlinedRectangle(160, 125, 1)
local imgRuleBackground   = OutlinedRectangle(244, 202, 4)
local imgPlayBackground   = OutlinedRectangle(100, 120, 2)
local imgCustomBackground = OutlinedRectangle(95,  110, 2)

local backgroundDeltaX = 0
local slideSpeed = 8

local menuBoxes       = {}
local menuMainI       = 1
local menuMainMaxI    = 3
local menuMainSmoothI = 1
local menuDeltaX      = screenHalfWidth

local playLocs    = {allLoc.boardModeEasy, allLoc.boardModeMedium, allLoc.boardModeHard, allLoc.boardModeCustom}
local playBoxes   = {}
local playI       = 1
local playMaxI    = 4
local playSmoothI = 1
local playDeltaX  = screenHalfWidth

local customLocs    = {allLoc.boardCustomWidth, allLoc.boardCustomHeight, allLoc.boardCustomBombs, allLoc.boardCustomLaunch}
local customBoxes   = {}
local customI       = 1
local customMaxI    = 4
local customSmoothI = 1
local customDeltaX  = screenHalfWidth

local customVar = {
    [1] = 5,
    [2] = 5,
    [3] = 5,
}

local ruleLocs = {allLoc.ruleMainGoal, allLoc.ruleBoard, allLoc.ruleClick, allLoc.ruleNumber, allLoc.ruleDeduce, allLoc.ruleMarking, allLoc.ruleUncovering}
local ruleImgs = {imgRuleMainGoal, imgRuleBoard, imgRuleClick, imgRuleNumber, imgRuleDeduce, imgRuleMarking, imgRuleUncovering}
local ruleI    = 1

local subState = "menu" -- menu / play / custom / rules
local menu = playdate.getSystemMenu()
local menuQuitBtn = nil

function MuteMusic(callback)
    if callback then
        StopAudio(soundMainTheme)
    else
        PlayAudio(soundMainTheme, 0)
    end
    muteMusic = callback
end

function ChangeLanguage()
    locID = locID + 1
    if locID > #locISO then locID = 1 end
    InitMenuBoxes()
    gfx.setFont(bigFont)
    imgMainTitle = OutlinedText(allLoc.mainTitle[locID])
end
function InitMenuBoxes()
    local function CreateBoxes()
        local newBox = {
            offsetX = 0,
            image = gfx.image.new(145, 35),
        }
        return newBox
    end

    local boxLoc = {allLoc.mainPlay, allLoc.mainLanguage, allLoc.mainRules}

    gfx.setFont(bigFont)
    for i = 1, menuMainMaxI, 1 do
        menuBoxes[i] = CreateBoxes()
        gfx.pushContext(menuBoxes[i].image)
        gfx.drawTextAligned(boxLoc[i][locID], 0, 8, kTextAlignment.left)
        gfx.popContext()
    end
    menuBoxes[menuMainI].offsetX = 10

    gfx.setFont(smallFont)
    for i = 1, playMaxI, 1 do
        playBoxes[i] = CreateBoxes()
        gfx.pushContext(playBoxes[i].image)
        gfx.drawTextAligned(playLocs[i][locID], 0, 4, kTextAlignment.left)
        gfx.popContext()
    end

    gfx.setFont(smallFont)
    for i = 1, customMaxI, 1 do
        customBoxes[i] = CreateBoxes()
        gfx.pushContext(customBoxes[i].image)
        gfx.drawTextAligned(customLocs[i][locID], 0, 4, kTextAlignment.left)
        gfx.popContext()
    end
end
function SetMenuType(newMenu)
    if newMenu == "launch" then
        LaunchGame()
        menuQuitBtn = menu:addMenuItem("Quit to menu", QuitToMenu)
    else
        subState = newMenu
    end
end

function StartMainMenu()
    menu:addCheckmarkMenuItem("Mute music", muteMusic, MuteMusic)
    InitMenuBoxes()

    if not muteMusic then
        PlayAudio(soundMainTheme, 0)
    end
end
function QuitToMenu()
    LaunchTransition("menu")
    menu:removeMenuItem(menuQuitBtn)
end

function UpdateMainMenu()
    local function UpdateMenu()
        if playdate.buttonJustPressed(playdate.kButtonUp) and menuMainI > 1 then
            PlayAudioTable(soundSwipes)
            menuMainI -= 1
        elseif playdate.buttonJustPressed(playdate.kButtonDown) and menuMainI < menuMainMaxI then
            PlayAudioTable(soundSwipes)
            menuMainI += 1
        elseif playdate.buttonJustPressed(playdate.kButtonA) then
            PlayAudio(soundMenuSelect)
            if menuMainI == 1 then subState = "play"         end
            if menuMainI == 2 then ChangeLanguage()          end
            if menuMainI == 3 then LaunchTransition("rules") ruleI = 1 end
        end
        menuMainSmoothI = SmoothValue(menuMainSmoothI, menuMainI, 10)

        for i, menuBox in ipairs(menuBoxes) do
            if i == menuMainI then
                menuBox.offsetX = SmoothValue(menuBox.offsetX, 10, 10)
            else
                menuBox.offsetX = SmoothValue(menuBox.offsetX, 0, 10)
            end
        end

        menuDeltaX   = SmoothValue(menuDeltaX, screenHalfWidth, slideSpeed)
        playDeltaX   = SmoothValue(playDeltaX, menuDeltaX, slideSpeed)
        customDeltaX = SmoothValue(customDeltaX, playDeltaX, slideSpeed)
    end
    local function UpdatePlay()
        if playdate.buttonJustPressed(playdate.kButtonUp) and playI > 1 then
            PlayAudioTable(soundSwipes)
            playI -= 1
        elseif playdate.buttonJustPressed(playdate.kButtonDown) and playI < playMaxI then
            PlayAudioTable(soundSwipes)
            playI += 1
        elseif playdate.buttonJustPressed(playdate.kButtonA) then
            PlayAudio(soundMenuSelect)
            if playI == 1 then LaunchTransition("launch") SetDifficulty("easy") end
            if playI == 2 then LaunchTransition("launch") SetDifficulty("medium") end
            if playI == 3 then LaunchTransition("launch") SetDifficulty("hard") end
            if playI == 4 then subState = "custom" end
        elseif playdate.buttonJustPressed(playdate.kButtonB) then
            PlayAudio(soundMenuSelect)
            subState = "menu"
        end
        playSmoothI = SmoothValue(playSmoothI, playI, 10)

        for i, playBox in ipairs(playBoxes) do
            if i == playI then
                playBox.offsetX = SmoothValue(playBox.offsetX, 8, 10)
            else
                playBox.offsetX = SmoothValue(playBox.offsetX, 0, 10)
            end
        end
        for i, menuBox in ipairs(menuBoxes) do
            menuBox.offsetX = SmoothValue(menuBox.offsetX, 0, 10)
        end

        menuDeltaX   = SmoothValue(menuDeltaX, screenHalfWidth - 80, slideSpeed)
        playDeltaX   = SmoothValue(playDeltaX, menuDeltaX + 135, slideSpeed)
        customDeltaX = SmoothValue(customDeltaX, playDeltaX, slideSpeed)
    end
    local function UpdateCustom()
        local previousVar1, previousVar2, previousVar3 = customVar[1], customVar[2], customVar[3]
        if playdate.buttonJustPressed(playdate.kButtonUp) and customI > 1 then
            PlayAudioTable(soundSwipes)
            customI -= 1
        elseif playdate.buttonJustPressed(playdate.kButtonDown) and customI < customMaxI then
            PlayAudioTable(soundSwipes)
            customI += 1
        elseif playdate.buttonJustPressed(playdate.kButtonA) and customI == 4 then
            PlayAudio(soundMenuSelect)
            SetDifficulty("custom", customVar[1], customVar[2], customVar[3])
            LaunchTransition("launch")
        elseif playdate.buttonJustPressed(playdate.kButtonB) then
            PlayAudio(soundMenuSelect)
            subState = "play"
        elseif playdate.buttonJustPressed(playdate.kButtonLeft) then
            if customI == 1 then customVar[1] -= 1 end
            if customI == 2 then customVar[2] -= 1 end
            if customI == 3 then customVar[3] -= 1 end
            CheckCustomValidity()
        elseif playdate.buttonJustPressed(playdate.kButtonRight) then
            if customI == 1 then customVar[1] += 1 end
            if customI == 2 then customVar[2] += 1 end
            if customI == 3 then customVar[3] += 1 end
            CheckCustomValidity()
        end
        if not (previousVar1 == customVar[1]) or not (previousVar2 == customVar[2]) or not (previousVar3 == customVar[3]) then
            PlayAudioTable(soundSwipes)
        end

        customSmoothI = SmoothValue(customSmoothI, customI, 10)

        for i, customBox in ipairs(customBoxes) do
            if i == customI then
                customBox.offsetX = SmoothValue(customBox.offsetX, 8, 10)
            else
                customBox.offsetX = SmoothValue(customBox.offsetX, 0, 10)
            end
        end
        for i, playBox in ipairs(playBoxes) do
            playBox.offsetX = SmoothValue(playBox.offsetX, 0, 10)
        end

        menuDeltaX   = SmoothValue(menuDeltaX, screenHalfWidth - 103, slideSpeed)
        playDeltaX   = SmoothValue(playDeltaX, menuDeltaX + 135, slideSpeed)
        customDeltaX = SmoothValue(customDeltaX, playDeltaX + 103, slideSpeed)
    end
    local function UpdateRules()
        if playdate.buttonJustPressed(playdate.kButtonRight) and ruleI < #ruleLocs then
            PlayAudioTable(soundSwipes)
            ruleI += 1
        end
        if playdate.buttonJustPressed(playdate.kButtonLeft) and ruleI > 1 then
            PlayAudioTable(soundSwipes)
            ruleI -= 1
        end

        if playdate.buttonJustPressed(playdate.kButtonB) then
            PlayAudio(soundMenuSelect)
            LaunchTransition("quitRule")
        end
    end

    if subState == "menu" then
        UpdateMenu()
    elseif subState == "play" then
        UpdatePlay()
    elseif subState == "custom" then
        UpdateCustom()
    elseif subState == "rules" then
        UpdateRules()
    end

    if deltaTime then backgroundDeltaX = (backgroundDeltaX + deltaTime * 30) % screenWidth  end
end
function DrawMainMenu()
    local function DrawMenu()
        if imgMainTitle then imgMainTitle:drawCentered(screenHalfWidth, 30) end

        if imgMenuBackground then imgMenuBackground:drawCentered(menuDeltaX, screenHalfHeight + 10) end
        for i, menuBox in ipairs(menuBoxes) do
            menuBox.image:drawCentered(menuDeltaX + menuBox.offsetX, 50 + i * 40)
        end

        if subState == "menu" then
            if imgSelectionArrow then imgSelectionArrow:drawCentered(menuDeltaX - 70, 50 + menuMainSmoothI * 40) end
        end
    end
    local function DrawPlay()
        if imgPlayBackground then imgPlayBackground:drawCentered(playDeltaX, screenHalfHeight + 10) end
        for i, playBox in ipairs(playBoxes) do
            playBox.image:drawCentered(playDeltaX + 30 + playBox.offsetX, 75 + i * 25)
        end

        if subState == "play" then
            if imgSelectionArrow then imgSelectionArrow:drawCentered(playDeltaX - 42, 67 + playSmoothI * 25) end
        end
    end
    local function DrawCustom()
        if imgCustomBackground then imgCustomBackground:drawCentered(customDeltaX, screenHalfHeight + 10) end

        gfx.setFont(smallFont)
        for i, customBox in ipairs(customBoxes) do
            local y = 75 + i * 25
            customBox.image:drawCentered(customDeltaX + 32 + customBox.offsetX, y)

            if i < 4 then
                gfx.drawTextAligned(string.format("< %02d >", customVar[i]), customDeltaX + 40, y - 14, kTextAlignment.right)
            end
        end

        if subState == "custom" then
            if imgSelectionArrow then imgSelectionArrow:drawCentered(customDeltaX - 40, 67 + customSmoothI * 25) end
        end
    end
    local function DrawRules()
        for i = 1, #ruleLocs, 1 do
            local ballX = ((screenHalfWidth) - (#ruleLocs * 6)) + (i * 12) - 6
            local ballY = screenHeight - 10
            local imgBall = i == ruleI and imgBallFull or imgBallEmpty

            if imgBall then imgBall:drawCentered(ballX, ballY) end
        end

        if imgRuleBackground then imgRuleBackground:draw(3, 19) end
        gfx.setFont(bigFont)
        gfx.drawTextInRect(ruleLocs[ruleI][locID], 10, 30, 230, 185)

        local ruleToDraw = ruleImgs[ruleI]
        if ruleToDraw then ruleToDraw:drawCentered(325, screenHalfHeight) end
    end

    if imgBackground then imgBackground:draw(-backgroundDeltaX, 0) end
    if imgBackground then imgBackground:draw(-backgroundDeltaX + screenWidth, 0) end

    if subState == "menu" or subState == "play" or subState == "custom" then
        if not (math.abs(customDeltaX - playDeltaX) < 5) then
            DrawCustom()
        end
        if not (math.abs(playDeltaX - menuDeltaX) < 5) then
            DrawPlay()
        end
        DrawMenu()
    elseif subState == "rules" then
        DrawRules()
    end
end
function CheckCustomValidity()
    customVar[1] = Clamp(customVar[1], 5, 15)
    customVar[2] = Clamp(customVar[2], 5, 11)

    local maxBomb = (customVar[1] * customVar[2]) - 9
    customVar[3] = Clamp(customVar[3], 1, maxBomb)
end

function SetMainMenuCustomVar(diffCustom)
    customVar[1] = diffCustom.width
    customVar[2] = diffCustom.height
    customVar[3] = diffCustom.bombs
end