import "transition"
import "conf"
import "audio"

local gfx <const> = playdate.graphics

local imgBackground = gfx.image.new("images/Menu/Background")
local imgBallEmpty  = gfx.image.new("images/Menu/RuleBallEmpty")
local imgBallFull   = gfx.image.new("images/Menu/RuleBallFull")

local imgRuleMainGoal   = gfx.image.new("images/Menu/Rules/MainGoal")
local imgRuleBoard      = gfx.image.new("images/Menu/Rules/Board")
local imgRuleClick      = gfx.image.new("images/Menu/Rules/Click")
local imgRuleNumber     = gfx.image.new("images/Menu/Rules/Number")
local imgRuleDeduce     = gfx.image.new("images/Menu/Rules/Deduce")
local imgRuleMarking    = gfx.image.new("images/Menu/Rules/Marking")
local imgRuleUncovering = gfx.image.new("images/Menu/Rules/Uncovering")

local imgMenuBoxes = {}
local imgSelection = nil
local imgMainTitle      = OutlinedText(allLoc.mainTitle[locID], bigFont)
local imgRuleBackground = OutlinedRectangle(244, 202, 4)

local backgroundDeltaX = 0

local menuMainI       = 1
local menuMainMaxI    = 3
local menuMainSmoothI = 1

local ruleLocs = {allLoc.ruleMainGoal, allLoc.ruleBoard, allLoc.ruleClick, allLoc.ruleNumber, allLoc.ruleDeduce, allLoc.ruleMarking, allLoc.ruleUncovering}
local ruleImgs = {imgRuleMainGoal, imgRuleBoard, imgRuleClick, imgRuleNumber, imgRuleDeduce, imgRuleMarking, imgRuleUncovering}
local ruleI    = 1

local subState = "menu" -- menu / rules / credits
local menu = playdate.getSystemMenu()

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
    imgMainTitle = OutlinedText(allLoc.mainTitle[locID])
end
function InitMenuBoxes()
    local boxLoc = {allLoc.mainPlay, allLoc.mainLanguage, allLoc.mainRules, allLoc.mainCredits}

    gfx.setFont(bigFont)
    for i = 1, menuMainMaxI, 1 do
        imgMenuBoxes[i] = OutlinedRectangle(145, 35, 1)
        gfx.pushContext(imgMenuBoxes[i])
        gfx.drawTextAligned(boxLoc[i][locID], 145 / 2, 8, kTextAlignment.center)
        gfx.popContext()
    end

    imgSelection = gfx.image.new(151, 41)
    gfx.pushContext(imgSelection)
    gfx.setLineWidth(4)
    gfx.drawRect(0, 0, 151, 41)
    gfx.popContext()
end
function SetMenuType(newMenu)
    if newMenu == "play" then
        StartGame()
        subState = "menu"
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
function UpdateMainMenu()
    local function UpdateMenu()
        if playdate.buttonJustPressed(playdate.kButtonUp) and menuMainI > 1 then
            PlayAudioTable(soundSwipes)
            menuMainI = menuMainI - 1
        elseif playdate.buttonJustPressed(playdate.kButtonDown) and menuMainI < menuMainMaxI then
            PlayAudioTable(soundSwipes)
            menuMainI = menuMainI + 1
        elseif playdate.buttonJustPressed(playdate.kButtonA) then
            PlayAudio(soundMenuSelect)
            if menuMainI == 1 then LaunchTransition("play")  end
            if menuMainI == 2 then ChangeLanguage()            end
            if menuMainI == 3 then LaunchTransition("rules")   end
            -- if menuMainI == 4 then LaunchTransition("credits") end
        end
        menuMainSmoothI = SmoothValue(menuMainSmoothI, menuMainI, 10)
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
            LaunchTransition("menu")
        end
    end
    -- local function UpdateCredits()
  
    --     if playdate.buttonJustPressed(playdate.kButtonB) then
    --         PlayAudio(soundMenuSelect)
    --         LaunchTransition("menu")
    --     end
    -- end

    if     subState == "menu" then    UpdateMenu()
    elseif subState == "rules" then   UpdateRules() end
    -- elseif subState == "credits" then UpdateCredits() end

    if deltaTime then backgroundDeltaX = (backgroundDeltaX + deltaTime * 30) % screenWidth  end
end
function DrawMainMenu()
    local function DrawMenu()
        if imgMainTitle then imgMainTitle:drawCentered(screenHalfWidth, 30) end

        for i, menuBox in ipairs(imgMenuBoxes) do
            menuBox:drawCentered(screenHalfWidth, 50 + i * 40)
        end

        if imgSelection then imgSelection:drawCentered(screenHalfWidth, 50 + menuMainSmoothI * 40) end
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
    -- local function DrawCredits()

    -- end

    if imgBackground then imgBackground:draw(backgroundDeltaX, 0) end
    if imgBackground then imgBackground:draw(backgroundDeltaX - screenWidth, 0) end

    if     subState == "menu" then    DrawMenu()
    elseif subState == "rules" then   DrawRules() end
    -- elseif subState == "credits" then DrawCredits() end
end