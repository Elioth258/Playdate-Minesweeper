import "localization"

function SaveGameData()
    local gameData = {
        locID = locID,
        muteMusic = muteMusic,
    }

    playdate.datastore.write(gameData, "save")
end
function ReadGameData()
	local gameData = playdate.datastore.read("save")

    if not gameData then
        gameData = {
            locID = 1,
            muteMusic = false,
        }
    end

    return gameData
end