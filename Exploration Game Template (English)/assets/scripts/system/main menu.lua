-------------------------
-- Main menu functions --
-------------------------

-- Initialize game
-- This function will be called at the beginning of the game
-- regardless of wether the player is starting a new game or
-- loading a previous save.
-- Use it to define global variables you will use in your game.
local function init()
	-- Define important characters that appear in every script
	s = Character.new("Sakura")
	sakura = CharacterSprite.new("sakura1.png")
end

-- Called when the player starts a new game.
-- Use it to prepare the events for the beginning of your game.
local function newGame()
	-- Allow the player to travel to the place where the story begins
	world.makeAccessible("examplePlace")

	-- Set up the beginning of the story
	world.setChapterString("Chapter 1 - Example Title")

	world.enableEvent("examplePlace", "story start.lua")
	world.travelTo("examplePlace")
end



--------------------------
-- Main menu properties --
--------------------------

local background = "main menu.png"
local music = "Brothers Unite.ogg"



--------------------
-- Main menu code --
--------------------

-- Button definitions
local newGameBtn = Button.new("main menu new game.png", 50, true)
newGameBtn:setPosition(674, 705)

local loadGameBtn = Button.new("main menu load game.png", 50, true)
loadGameBtn:setPosition(674, 805)

local quitGameBtn = Button.new("main menu quit game.png", 50, true)
quitGameBtn:setPosition(674, 905)

-- Functions
local function showMenu()
	disableMouseInput()

	transitions.showFadeLeft(newGameBtn)
	sleep(0.1)
	transitions.showFadeLeft(loadGameBtn)
	sleep(0.1)
	transitions.showFadeLeft(quitGameBtn)

	enableMouseInput()
end

local function hideMenu()
	disableMouseInput()

	transitions.hideFadeLeft(newGameBtn)
	sleep(0.1)
	transitions.hideFadeLeft(loadGameBtn)
	sleep(0.1)
	transitions.hideFadeLeft(quitGameBtn)

	enableMouseInput()
end

-- Button functionality
newGameBtn.onClick = function()
	hideMenu()
	sleep(0.5)
	fadeOutMusic(2)
	scene("black.png", 2)
	sleep(1)

	-- Start new game
	newGame()
end

loadGameBtn.onClick = function()
	saveMenu.openLoadMenu(function(state)
		if state then
			world.load(state)
		else
			scene(background, 0.2)
			showMenu()
		end
	end)
end

quitGameBtn.onClick = function()
	fadeOutMusic(2)
	scene("black.png", 2)
	exitGame()
end

-- Init game
init()

-- Open main menu
scene("white.png", 1)
sleep(1)
playMusic(music)
scene(background, 2)
sleep(0.3)
newGameBtn:show({type=Transition.fade, time=1.5, block=false})
sleep(0.1)
loadGameBtn:show({type=Transition.fade, time=1.5, block=false})
sleep(0.1)
quitGameBtn:show({type=Transition.fade, time=1.5, block=false})