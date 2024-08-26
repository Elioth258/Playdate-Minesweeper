import "animation"
import "mainMenu"
import "conf"

local gfx <const> = playdate.graphics

local animTrans = CreateAnimation("Transition", 7)

local nextMenuType = "none"
local isTransitionning = false
local timer = 2

function UpdateTransition()
    if isTransitionning then
        if deltaTime then timer += deltaTime * 2.5 end

        if timer >= 0.5 and not (nextMenuType == "none") then
            if nextMenuType == "menu" then
                globalState = "menu"
            elseif nextMenuType == "quitRule" then
                SetMenuType("menu")
            elseif nextMenuType == "restart" then
                LaunchGame()
            else
                SetMenuType(nextMenuType)
            end
            nextMenuType = "none"
        elseif timer >= 1 then
            isTransitionning = false
        end
    end
end
function DrawTransition()
    if isTransitionning then
        local frame = GetSpecificFrame(animTrans, timer)
        frame:draw(0, 0)
    end
end

function LaunchTransition(newMenuType)
    if not isTransitionning then
        isTransitionning = true
        nextMenuType = newMenuType
        timer = 0
    end
end