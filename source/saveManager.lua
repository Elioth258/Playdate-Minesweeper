import "localization"

function SaveGameData(customDifficulty)
    local gameData = {
        locID = locID,
        muteMusic = muteMusic,
        customDifficulty = customDifficulty,

        saveID = saveID,
        record = stopwatchRecord,
    }

    playdate.datastore.write(gameData, "save")
end
function ReadGameData()
	local gameData = playdate.datastore.read("save")

    return gameData
end