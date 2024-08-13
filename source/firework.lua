import "animation"
import "conf"

local gfx <const> = playdate.graphics

local animExplosion = CreateAnimation("Firework", 7)

local imgShell = nil

local fireworkList = {}

local timerNextFirework = 0

function InitFirework()
    imgShell = gfx.image.new(5, 5)
    gfx.pushContext(imgShell)

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, 5, 5)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(1, 1, 3, 3)

    gfx.popContext()
end

function UpdateFirework()
    local function CreateFirework()
        local newFirework = {
            pos = {x = math.random(20, screenWidth - 20), y = screenHeight},
            speedMin = 5,
            speedMax = math.random(120, 200),
            shellLife = 0,
        }

        table.insert(fireworkList, newFirework)
    end

    if deltaTime then timerNextFirework -= deltaTime end
    if timerNextFirework < 0 then
        timerNextFirework = math.random(50, 200) / 100

        CreateFirework()
    end

    for i, firework in ipairs(fireworkList) do
        if firework.shellLife > 2 then
            table.remove(fireworkList, i)
        elseif firework.shellLife > 1 then
            firework.shellLife += deltaTime
            firework.pos.y += deltaTime * 5
        else
            firework.shellLife += deltaTime / 2
            firework.pos.y -= deltaTime * Lerp(firework.speedMax, firework.speedMin, firework.shellLife)
        end
    end
end

function DrawFirework()
    for i, firework in ipairs(fireworkList) do
        local imgToDraw = imgShell

        if firework.shellLife > 1 then
            imgToDraw = GetSpecificFrame(animExplosion, firework.shellLife - 1)
        end

        if imgToDraw then imgToDraw:drawCentered(firework.pos.x, firework.pos.y) end
    end
end