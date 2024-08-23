import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/object"
import "CoreLibs/ui"

import "conf"
import "audio"
import "localization"
import "saveManager"
import "mainMenu"
import "transition"
import "board"

local gfx <const> = playdate.graphics

local gameData = ReadGameData()
locID     = gameData.locID
muteMusic = gameData.muteMusic

playdate.setCrankSoundsDisabled(not playdate.isSimulator)
playdate.resetElapsedTime()

StartMainMenu()

if directlyGoInGame then
	LaunchGame()
end

function playdate.update()
	Update()
	Draw()
end

function Update()
	deltaTime = playdate.getElapsedTime()
	totalTime += deltaTime

	if globalState == "menu" then
		UpdateMainMenu()
	elseif globalState == "game" then
		UpdateBoard()
	end

	UpdateTransition()

	playdate.resetElapsedTime()
end

function Draw()
	gfx.clear()
	gfx.sprite.update()

	if globalState == "menu" then
		DrawMainMenu()
	elseif globalState == "game" then
		DrawBoard()
	end
	DrawTransition()

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