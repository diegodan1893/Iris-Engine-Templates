world = {}

-- Properties
local placesPath = "assets/scripts/places/"
local eventsPath = "assets/scripts/events/"
local charaDialoguePath = "assets/scripts/character dialogue/"
local clickableMapPath = "maps/"

local travelTransition = {type=Transition.imageDissolve, image="fade right.png", time=0.5}
local loadTransition = {type=Transition.dissolve, time=0.2}
local characterTransition = {type=Transition.fade, time=0.3, block=true}

-- Game state
local gameState = {}
gameState.flags = {}
gameState.accessiblePlaces = {}
gameState.currentPlaceName = nil
gameState.visitedPlaces = {}
gameState.activeEvents = {}
gameState.examinedItems = {}
gameState.characters = {}
gameState.allowTravel = true

-- Name of the current story chapter
gameState.chapterString = " "

-- Current place data
local currentPlace
local currentPlaceData = {}

-- Dialogue state enum
local dialogueState = {
	unhidden = 1,
	seen = 2
}


-- If there is a character in the current place, show it
local function showCharacter(transition)
	local transition = transition or characterTransition

	local characterData = gameState.characters[gameState.currentPlaceName]

	if characterData then
		currentPlaceData.character = CharacterSprite.new(characterData.base)

		-- Make the transition smoother
		if transition.block then
			yield()
		end

		currentPlaceData.character:show(characterData.expression, transition)
	end
end

-- If there is a character in the current place, hide it
local function hideCharacter()
	if currentPlaceData.character then
		currentPlaceData.character:hide(characterTransition)
		currentPlaceData.character = nil
	end
end

-- If there is a character in the current place, load it
local function loadCharacter()
	if gameState.characters[gameState.currentPlaceName] then
		dofile(charaDialoguePath .. gameState.characters[gameState.currentPlaceName].script)
	end
end


-- Public interface

function world.flags()
	return gameState.flags
end

function world.getGameState()
	return gameState
end

function world.getChapterString()
	return gameState.chapterString
end

function world.setChapterString(str)
	gameState.chapterString = str
end

-- If allowTravel is false, the player will not be able to travel during exploration
function world.setAllowTravel(allowTravel)
	gameState.allowTravel = allowTravel
end

-- Move the player to a new place with a transition
-- This will trigger events if necessary
function world.travelTo(placeName)
	-- Make sure the place exists
	if not places[placeName] then
		error("Trying to travel to a non-existent place: " .. placeName, 2)
	end

	local switchMusic = true

	if currentPlace then
		-- Stop music if necessary
		if currentPlace.music ~= places[placeName].music or gameState.activeEvents[placeName] then
			fadeOutMusic(1)
		else
			switchMusic = false
		end

		-- Transition out of the current place
		scene("black.png", travelTransition)
		sleep(0.5)
	end

	-- Load the new place
	world.setPlace(placeName)

	if gameState.activeEvents[placeName] then
		-- There is an event in the new place, trigger it
		local eventScript = gameState.activeEvents[placeName]
		gameState.activeEvents[placeName] = nil
		dofile(eventsPath .. eventScript)

		-- If the event has added a character in the current place, load it
		loadCharacter()

		-- Clear the scene and show the character without a transition
		-- We do this because the sprite object used in the event is not the same
		-- we use after the event is finished
		hideText()
		scene(currentPlace.img, {type=Transition.none})
		showCharacter({type=Transition.none})
	else
		-- No event, travel normally
		scene(currentPlace.img, travelTransition)

		-- If there is a character, show it
		showCharacter()

		-- Set the music
		if switchMusic then
			playMusic(currentPlace.music)
		end
	end

	-- Show the exploration menu
	explorationMenu.open()
end

-- Set the current place
-- This will not trigger events
function world.setPlace(placeName)
	-- Make sure the place exists
	if not places[placeName] then
		error("Trying to travel to a non-existent place: " .. placeName, 2)
	end

	gameState.currentPlaceName = placeName
	gameState.visitedPlaces[placeName] = true

	currentPlace = places[placeName]

	-- Load the data of the place
	currentPlaceData = {
		map = ClickableMap.new(clickableMapPath .. currentPlace.img),
		questions = {}
	}

	dofile(placesPath .. currentPlace.script)

	-- If there is a character in this place, load its data
	loadCharacter()
end

-- Check if the player has visited a certain place
function world.hasBeenVisited(placeName)
	-- Make sure the place exists
	if not places[placeName] then
		error("Trying check a non-existent place: " .. placeName, 2)
	end

	return gameState.visitedPlaces[placeName]
end

function world.getCurrentPlace()
	return gameState.currentPlaceName
end

-- Load a saved game state
function world.load(newGameState)
	if newGameState and newGameState ~= gameState then
		gameState = newGameState
		world.setPlace(gameState.currentPlaceName)
		playMusic(currentPlace.music)
	end

	scene(currentPlace.img, loadTransition)
	showCharacter()

	-- Show the exploration menu
	explorationMenu.open()
end

-- Make a place accessible to the player
function world.makeAccessible(placeName)
	-- Make sure the place exists
	if not places[placeName] then
		error("Trying to make accessible a non-existent place: " .. placeName, 2)
	end

	local insert = true
	local i = 1

	while insert and i <= #gameState.accessiblePlaces do
		if gameState.accessiblePlaces[i] == placeName then
			insert = false
		end

		i = i + 1
	end

	if insert then
		table.insert(gameState.accessiblePlaces, placeName)
	end
end

-- Get a list of accessible places
function world.getAccessiblePlaces()
	if gameState.allowTravel then
		return gameState.accessiblePlaces
	else
		return {}
	end
end

-- Enable an event in a place
function world.enableEvent(placeName, eventScript)
	-- Make sure the place exists
	if not places[placeName] then
		error("Trying to enable an event in a non-existent place: " .. placeName, 2)
	end

	gameState.activeEvents[placeName] = eventScript
end

-- Place a character in an area
function world.placeCharacter(placeName, base, expression, dialogueScript)
	-- Make sure the place exists
	if not places[placeName] then
		error("Trying to place a character in a non-existent place: " .. placeName, 2)
	end

	gameState.characters[placeName] = {
		base = base,
		expression = expression,
		script = dialogueScript,
		questions = {}
	}
end

-- Remove a character from a place
function world.removeCharacter(placeName)
	gameState.characters[placeName] = nil
end

-- Register a dialogue option for a character in the current place
-- Called by the dialogue script of the character
function world.registerDialogueOption(text, hidden, dialogue)
	local place = gameState.currentPlaceName
	local index = #currentPlaceData.questions + 1

	currentPlaceData.questions[index] = {
		text = text,
		hiddenByDefault = hidden,
		dialogue = function()
			dialogue(currentPlaceData.character)
			gameState.characters[place].questions[index] = dialogueState.seen
			hideText()
		end
	}

	return index
end

-- Unhide a dialogue option
function world.unhideDialogueOption(index)
	gameState.characters[gameState.currentPlaceName].questions[index] = dialogueState.unhidden
end

-- Gets a table with all the visible questions for the character in the current place
function world.getDialogueOptions()
	local options = {}
	local allQuestions = currentPlaceData.questions
	local savedState = gameState.characters[gameState.currentPlaceName].questions

	for i = 1, #allQuestions do
		if savedState[i] or not allQuestions[i].hiddenByDefault then
			-- The option is not hidden
			table.insert(options, {
				text = allQuestions[i].text,
				seen = savedState[i] == dialogueState.seen,
				dialogue = allQuestions[i].dialogue
			})
		end
	end

	return options
end

-- Check if there is a character in this place
function world.isCharacterPresent()
	return gameState.characters[gameState.currentPlaceName] ~= nil
end

-- Register an examinable item in the current place
-- Called by the script that loads that place
function world.registerItem(r, examineFunction, hoverBeginFunction, hoverEndFunction)
	local place = gameState.currentPlaceName
	local map = currentPlaceData.map

	if not gameState.examinedItems[place] then
		gameState.examinedItems[place] = {}
	end

	-- Register mouse events
	map:setOnMouseEnter(r, function()
		gui.beginHoverExaminableItem(gameState.examinedItems[place][r])

		if hoverBeginFunction then
			hoverBeginFunction()
		end
	end)

	map:setOnMouseExit(r, function()
		gui.endHoverExaminableItem()

		if hoverEndFunction then
			hoverEndFunction()
		end
	end)

	map:setOnClick(r, function()
		gui.endExamination()

		examineFunction()
		gameState.examinedItems[place][r] = true
		hideText()

		gui.beginExamination()
		map:enable()
	end)
end

-- Set a function to be called when examination mode is deactivated
function world.onEndExamination(callback)
	currentPlaceData.onEndExamination = callback
end

-- Let the player examine the current place
function world.enterExaminationMode()
	disableMouseInput()
	hideCharacter()
	enableMouseInput()
	currentPlaceData.map:enable()
end

function world.exitExaminationMode()
	currentPlaceData.map:disable()

	if currentPlaceData.onEndExamination then
		currentPlaceData.onEndExamination()
	end

	showCharacter()
end