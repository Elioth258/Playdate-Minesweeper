import "conf"
import "audio"

local gfx <const> = playdate.graphics

local card = {
    width  = 45,
    height = 65,

    color = "clubs", -- clubs (♣), diamonds (♦), hearts (♥), spades (♠)
    number = 1, -- 1 = ace | 11 = jack, 12 = queen, 13 = king
}

function UpdateBoard()

end
function DrawBoard()

    for i = 1, 8, 1 do
        local di = i - 1
        gfx.drawRect(5 + (card.width + 4) * di, 10, card.width, card.height)
    end

end