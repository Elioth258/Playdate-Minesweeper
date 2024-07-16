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

        if timer >= 1 then
            SetMenuType(nextMenuType)
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