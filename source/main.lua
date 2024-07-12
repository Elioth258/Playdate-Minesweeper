import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/object"
import "CoreLibs/ui"

import "conf"
import "audio"
import "localization"
import "saveManager"
import "scroll"
import "mainMenu"
import "board"

local gfx <const> = playdate.graphics

local currentState = "Menu" -- Menu / Game

local gameData = ReadGameData()
locID     = gameData.locID
muteMusic = gameData.muteMusic

playdate.setCrankSoundsDisabled(not playdate.isSimulator)
playdate.resetElapsedTime()

if directlyGoInGame then

end

InitBorder()

function playdate.update()
	Update()
	Draw()
end

function Update()
	deltaTime = playdate.getElapsedTime()
	totalTime += deltaTime

	if currentState == "Menu" then
		UpdateMainMenu()
	elseif currentState == "Game" then
		UpdateBoard()
	end

	playdate.resetElapsedTime()
end

function Draw()
	gfx.clear()
	gfx.sprite.update()

	if currentState == "Menu" then
		DrawMainMenu()
	elseif currentState == "Game" then
		DrawBoard()
	end

	if showDebugInfo then
		playdate.drawFPS(0, 0)
	end
end

function playdate.gameWillTerminate()
	SaveGameData()
end
function playdate.deviceWillSleep()
	SaveGameData()
end