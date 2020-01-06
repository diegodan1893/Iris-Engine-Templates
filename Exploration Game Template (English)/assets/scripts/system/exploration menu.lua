explorationMenu = {}

-- Menu properties
local zindex = 101
local mainMenuTransitionTime = 0.2

local mainMenuProperties = {
	buttons = {
		talk = {x = 45, y = 886, img = "explore talk.png"},
		examine = {x = 411, y = 886, img = "explore examine.png"},
		move = {x = 777, y = 886, img = "explore move.png"},
		save = {x = 1509, y = 886, img = "explore save.png"}
	},
	filler = {
		--{x = -321, y = 886, img = "explore filler.png"},
		{x = 1143, y = 886, img = "explore filler.png"},
		--{x = 1875, y = 886, img = "explore filler.png"}
	}
}

local talkMenuProperties = {
	position = {x = 0, y = 0},
	size = {w = 1920, h = 800},
	buttonSize = {w = 1920, h = 66},
	buttonSeparation = {x = 0, y = 75},
	img = "choices_BG.png",
	imgSeen = "choices_BG seen.png",

	timePerButton = 0.5,
	timeBetweenButtons = 0.1,
	hideTransition = {type=Transition.fade, time=0.3, block=false}
}

local moveMenuProperties = {
	thumbPath = "thumbnails/",
	thumbNoVisited = "new.png",
	thumbPosition = {x = 235, y = 362},

	position = {x = 1087, y = 0},
	size = {w = 833, h = 1080},
	buttonSize = {w = 833, h = 65},
	buttonSeparation = {x = 0, y = 69},
	img = "place button.png",

	timePerButton = 0.3,
	timeBetweenButtons = 0.1
}

-- Menu elements
local mainMenu = {}
local talkMenu = {}
local moveMenu = {}

-- Forward declaration of some functions
local openMainMenu, closeMainMenu, openTalkMenu, closeTalkMenu, openMoveMenu, closeMoveMenu


-- Helper functions
local function createElement(type, properties)
	local element = type.new(properties.img, zindex)
	element:setPosition(properties.x, properties.y)

	return element
end

local function centerMenu(properties, numberOfOptions)
	local p = properties

	-- Calculate position and size of the menu
	local width  = p.buttonSeparation.x * (numberOfOptions - 1) + p.buttonSize.w
	local height = p.buttonSeparation.y * (numberOfOptions - 1) + p.buttonSize.h
	local x = p.size.w / 2 - width / 2 + p.position.x
	local y = p.size.h / 2 - height / 2 + p.position.y

	return math.floor(x), math.floor(y), math.floor(width), math.floor(height)
end

-- Main menu button functions
local mainMenuActions = {}

mainMenuActions.talk = function()
	closeMainMenu()
	openTalkMenu()
end

mainMenuActions.examine = function()
	closeMainMenu()
	
	gui.beginExamination()
	world.enterExaminationMode()
end

mainMenuActions.move = function()
	closeMainMenu()
	openMoveMenu()
end

mainMenuActions.save = function()
	saveMenu.openSaveMenu(world.load, world.getGameState(), world.getChapterString())
end

-- Main menu
openMainMenu = function()
	-- Create menu elements
	mainMenu = {}

	for i = 1, #mainMenuProperties.filler do
		-- Create filler sprites
		local element = createElement(Sprite, mainMenuProperties.filler[i])

		table.insert(mainMenu, element)
	end

	-- Create menu buttons
	for k, v in pairs(mainMenuProperties.buttons) do
		local button = createElement(Button, v)
		button.onClick = mainMenuActions[k]

		mainMenu[k] = button
	end

	-- Disable talk button if there is no character to talk to
	mainMenu.talk.enabled = world.isCharacterPresent()

	-- Disable move button if there are no places to travel to
	mainMenu.move.enabled = #world.getAccessiblePlaces() > 1

	yield()

	-- Show menu elements
	for k, element in pairs(mainMenu) do
		transitions.showFadeUp(element, nil, false, nil, mainMenuTransitionTime)
	end
end

closeMainMenu = function()
	-- Hide menu elements
	for k, element in pairs(mainMenu) do
		transitions.hideFadeDown(element, nil, false, nil, mainMenuTransitionTime)
	end

	disableSkip()
	sleep(mainMenuTransitionTime)
	enableSkip()

	-- Destroy menu elements
	mainMenu = {}
end

-- Talk menu
openTalkMenu = function()
	local options = world.getDialogueOptions()
	local p = talkMenuProperties

	local x, y, width, height = centerMenu(p, #options)

	-- Create a button for each option
	for i = 1, #options do
		local j = i - 1

		-- Use the appropiate background for the button (this expression is a ternary conditional in Lua)
		local img = options[i].seen and p.imgSeen or p.img
		local button = Button.new(img, zindex, options[i].text, true)

		button:setPosition(x + p.buttonSeparation.x * j, y + p.buttonSeparation.y * j)

		-- Button action
		button.onClick = function()
			-- Close GUI
			closeTalkMenu()

			-- Execute dialogue function
			options[i].dialogue()

			-- Reopen talk menu
			openTalkMenu()
		end

		table.insert(talkMenu, button)
	end

	-- Show menu
	disableMouseInput()
	yield()

	for i = 1, #talkMenu do
		talkMenu[i]:show({type=Transition.fade, time=p.timePerButton, block=false})
		sleep(p.timeBetweenButtons)
	end

	enableMouseInput()

	-- Close menu with right click
	gui.showRightClickPrompt()

	setOnRightClick(function()
		closeTalkMenu()
		openMainMenu()
	end)
end

closeTalkMenu = function()
	setOnRightClick(nil)
	gui.hideRightClickPrompt()

	-- Hide elements
	for i = 1, #talkMenu do
		talkMenu[i]:hide(talkMenuProperties.hideTransition)
	end

	disableSkip()
	sleep(talkMenuProperties.hideTransition.time)
	enableSkip()

	-- Destroy menu elements
	talkMenu = {}
end

-- Move menu
openMoveMenu = function()
	local options = world.getAccessiblePlaces()
	local p = moveMenuProperties
	local thumbnails = {}

	local x, y, width, height = centerMenu(p, #options - 1)

	-- Prevent the player from selectin an option before all the buttons are shown
	disableMouseInput()

	-- Create a button for each place
	for i = 1, #options do
		-- The player can't travel to the current place
		if options[i] ~= world.getCurrentPlace() then

			-- Create button
			local button = Button.new(p.img, zindex, places[options[i]].name, true)
			button:setPosition(x, y)
			x = x + p.buttonSeparation.x
			y = y + p.buttonSeparation.y

			-- Create thumbnail
			local thumbnailPath = world.hasBeenVisited(options[i]) and places[options[i]].img or p.thumbNoVisited
			local thumbnail = Sprite.new(p.thumbPath .. thumbnailPath, zindex)
			thumbnail:setPosition(p.thumbPosition.x, p.thumbPosition.y)
			thumbnails[i] = thumbnail

			-- Button actions
			button.onClick = function()
				-- Close GUI
				transitions.hideFadeLeft(thumbnail, p.thumbPosition.x, nil, nil, p.timePerButton)
				closeMoveMenu()

				-- Travel to the selected place
				world.travelTo(options[i])
			end

			button.onMouseEnter = function()
				-- Hide other thumbnails
				for k, v in pairs(thumbnails) do
					v:skipTransition()
					v:hide({type=Transition.none})
				end

				transitions.showFadeLeft(thumbnail, p.thumbPosition.x, nil, nil, p.timePerButton)
			end

			button.onMouseExit = function()
				transitions.hideFadeLeft(thumbnail, p.thumbPosition.x, nil, nil, p.timePerButton)
			end

			-- Show the button
			-- We can't do this in a separate loop because #options ~= #moveMenu
			transitions.showFadeLeft(button, nil, nil, nil, p.timePerButton)
			sleep(p.timeBetweenButtons)

			table.insert(moveMenu, button)
		end
	end

	enableMouseInput()

	-- Close menu with right click
	gui.showRightClickPrompt()

	setOnRightClick(function()
		-- Hide thumbnails
		for k, v in pairs(thumbnails) do
			v:skipTransition()
			v:hide({type=Transition.none})
		end

		closeMoveMenu()
		openMainMenu()
	end)
end

closeMoveMenu = function()
	local p = moveMenuProperties

	setOnRightClick(nil)
	gui.hideRightClickPrompt()

	-- Hide elements
	disableMouseInput()

	for i = 1, #moveMenu do
		transitions.hideFadeRight(moveMenu[i], nil, nil, nil, p.timePerButton)
		sleep(p.timeBetweenButtons)
	end

	enableMouseInput()

	-- Destroy menu elements
	moveMenu = {}
end


-- Public interface

-- Open the menu
function explorationMenu.open()
	openMainMenu()
end