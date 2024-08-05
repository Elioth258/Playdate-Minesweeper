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
import "UI"

local gfx <const> = playdate.graphics

local currentState = "menu" -- menu / game

local gameData = ReadGameData()
locID     = gameData.locID
muteMusic = gameData.muteMusic

playdate.setCrankSoundsDisabled(not playdate.isSimulator)
playdate.resetElapsedTime()

StartMainMenu()

function StartGame()
	StartGameBoard(15, 10, 20)
	currentState = "game"
end

if directlyGoInGame then
	StartGame()
end

function playdate.update()
	Update()
	Draw()
end

function Update()
	deltaTime = playdate.getElapsedTime()
	totalTime += deltaTime

	if currentState == "menu" then
		UpdateMainMenu()
	elseif currentState == "game" then
		UpdateBoard()
	end

	UpdateTransition()

	playdate.resetElapsedTime()
end

function Draw()
	gfx.clear()
	gfx.sprite.update()

	if currentState == "menu" then
		DrawMainMenu()
	elseif currentState == "game" then
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