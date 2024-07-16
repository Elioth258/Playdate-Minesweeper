import "conf"

local gfx <const> = playdate.graphics

function CreateAnimation(name, nbFrames)
    local animation = {
        frames = {},
    }

    for i = 1, nbFrames, 1 do
        table.insert(animation.frames, gfx.image.new("images/Animations/" .. name .. "/" .. name .. i))
    end

    return animation
end

function GetFrame(animation)
    return animation.frames[Clamp(math.ceil(timerLerp * #animation.frames), 1, #animation.frames)]
end
function GetSpecificFrame(animation, timer)
    return animation.frames[Clamp(math.ceil(timer * #animation.frames), 1, #animation.frames)]
end