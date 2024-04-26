import "audio"

local timeLimit = 0.3
local timeSkip = 0.1

local timeHoldUp = 0
local timeHoldDown = 0

function ScrollUp(index, condition, limit, deltaTime)
    if condition and index > limit then
        if timeHoldUp == 0 or timeHoldUp > timeLimit then
            index = index - 1
            timeHoldUp = timeHoldUp - timeSkip
            swipeSound[math.random(1, 6)]:play(1)
        end
        timeHoldUp = timeHoldUp + deltaTime
    else
        timeHoldUp = 0
    end
    return index
end
function ScrollDown(index, condition, limit, deltaTime)
    if condition and index < limit then
        if timeHoldDown == 0 or timeHoldDown > timeLimit then
            index = index + 1
            timeHoldDown = timeHoldDown - timeSkip
            swipeSound[math.random(1, 6)]:play(1)
        end
        timeHoldDown = timeHoldDown + deltaTime
    else
        timeHoldDown = 0
    end
    return index
end

function ScrollParamReset()
    timeHoldUp = 0
    timeHoldDown = 0
end