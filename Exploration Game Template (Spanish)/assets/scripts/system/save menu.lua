saveMenu = {}

-- Menu properties
local titlePosition = {x = 45, y = 60}

local slotsPosition = {x = 45, y = 162}
local slotsDistance = {x = 369, y = 340}
local slotNumbersPosition = {x = 12, y = 4}
local slotLockPosition = {x = 4, y = 288}
local slotSwapPosition = {x = 123, y = 288}
local slotDeletePosition = {x = 241, y = 288}

local slotScreenshotPosition = {x = 0, y = 39}
local slotDatePosition = {x = 84, y = 6}
local slotDescriptionPosition = {x = 20, y = 246}

local pageNumbersPosition = {x = 775, y = 60}
local pageNumbersDistance = 55

local tooltipBgPosition = {x = 45, y = 887}
local tooltipTextPosition = {x = 19, y = 8}

local sysbarSavePosition = {x = 45, y = 952}
local sysbarLoadPosition = {x = 411, y = 952}
local sysbarTitlePosition = {x = 777, y = 952}
local sysbarQuitPosition = {x = 1143, y = 952}
local sysbarBackPosition = {x = 1509, y = 952}

local pages = 20
local slotsCols = 5
local slotsRows = 2

-- Fonts
local pageNumbersFont = {
	file = "assets/fonts/Roboto-Medium.ttf",
	size = 28,
	color = {r = 255, g = 255, b = 255, a = 255},
	shadowDistance = 0,
	shadowColor = {r = 0, g = 0, b = 0, a = 0}
}

local slotNumbersFont = {
	file = "assets/fonts/Roboto-Medium.ttf",
	size = 26,
	color = {r = 255, g = 255, b = 255, a = 255},
	shadowDistance = 0,
	shadowColor = {r = 0, g = 0, b = 0, a = 0}
}

local slotDateFont = {
	file = "assets/fonts/Roboto-Medium.ttf",
	size = 22,
	color = {r = 255, g = 255, b = 255, a = 255},
	shadowDistance = 0,
	shadowColor = {r = 0, g = 0, b = 0, a = 0}
}

local slotDescriptionFont = {
	file = "assets/fonts/Roboto-Regular.ttf",
	size = 22,
	color = {r = 36, g = 36, b = 36, a = 255},
	shadowDistance = 0,
	shadowColor = {r = 0, g = 0, b = 0, a = 0}
}

local tooltipFont = {
	file = "assets/fonts/Roboto-Regular.ttf",
	size = 26,
	color = {r = 255, g = 255, b = 255, a = 255},
	shadowDistance = 0,
	shadowColor = {r = 0, g = 0, b = 0, a = 0}
}

-- Menu modes
local swap = nil
local mode
local modes = {
	save = 1,
	load = 2
}

-- Menu elements
local slots = {}
local decorative = {}
local pageButtons = {}
local sysbar = {}
local currentPage = 1
local tooltipText

-- Save data
local meta = {}
local savePath = "savedata/"
local dateFormat = "%d/%m/%Y  %H:%M"
local gameState = nil
local gameStateDescription = nil

-- Text to show as tooltip
local tooltipStrings = {
	[modes.save] = "Haz clic en una ranura para guardar la partida",
	[modes.load] = "Haz clic en un archivo de guardado para cargar la partida",
	swap = "Selecciona la ranura a la que quieres mover el archivo de guardado"
}

-- Confirmation dialogue
local confirmDialogText = {
	overwrite = "Ya hay una partida guardada, ¿quieres sobrescribirla?",
	delete = "¿Quieres borrar la partida seleccionada?",
	load = "¿Quieres cargar la partida seleccionada?",
	title = "¿Quieres volver al menú principal?",
	quit = "¿Quieres salir del juego?"
}

-- Function to call after closing menu
local closeCallback = nil

-- Menu transitions
local clearScreenTransition = {type=Transition.imageDissolve, time=0.08, image="fade right.png"}
local showBgTransition = {type=Transition.dissolve, time=0.2, block=false}
local showElementsTransition = {type=Transition.fade, time=0.2, block=false}
local closeTransition = {type=Transition.dissolve, time=0.08}
local populateTransition = {type=Transition.none}
local delayAfterYesNoDialog = 0.1
local musicFadeOutTime = 0.5

-- Declaration of some functions
local refresh, rightClickAction, destroyMenu, createMenu, makeVisible, closeMenu


-- Loading and saving
local function serialize(object, file, indent)
	indent = indent or ""

	if type(object) == "number" then
		file:write(object)
	elseif type(object) == "boolean" then
		file:write(tostring(object))
	elseif type(object) == "string" then
		file:write(string.format("%q", object))
	elseif type(object) == "table" then
		file:write("{\n")

		for k, v in pairs(object) do
			file:write(indent, "\t[")
			serialize(k, file)
			file:write("] = ")
			serialize(v, file, indent.."\t")
			file:write(",\n")
		end

		file:write(indent, "}")
	else
		error("Cannot serialize a " .. type(object))
	end
end

local function loadMeta()
	local oldMeta = META
	function META(t) meta = t end

	local data = loadfile(savePath .. "meta.sav")

	if data then
		data()
	end

	META = oldMeta
end

local function saveMeta()
	local metaFile = io.open(savePath .. "meta.sav", "w")
	metaFile:write("META ")

	serialize(meta, metaFile)

	metaFile:close()
end

local function copyFile(source, target)
	source = io.open(source, "rb")
	target = io.open(target, "wb")

	target:write(source:read("*a"))

	source:close()
	target:close()
end

local function save(slot)
	local timestamp = os.date("%Y%m%d%H%M%S" ..  slot)
	local date = os.date(dateFormat)

	-- Save screenshot
	copyFile(savePath .. "tmp.png", savePath .. timestamp .. ".png")

	-- Save data
	local saveFile = io.open(savePath .. timestamp .. ".sav", "w")
	saveFile:write("SAVEDATA ")

	serialize(gameState, saveFile)

	saveFile:close()

	-- Update meta
	meta[slot] = {
		date = date,
		description = gameStateDescription,
		locked = false,

		screenshot = timestamp .. ".png",
		savedata = timestamp .. ".sav"
	}

	saveMeta()
	refresh()
end

local function load(slot)
	local oldSavedata = SAVEDATA
	function SAVEDATA(t) gameState = t end

	local data = loadfile(savePath .. meta[slot].savedata)

	if data then
		data()
	end

	SAVEDATA = oldSavedata
end

local function toggleLock(slot)
	meta[slot].locked = not meta[slot].locked

	saveMeta()
	refresh()
end

local function swapSaves(slotA, slotB)
	meta[slotA], meta[slotB] = meta[slotB], meta[slotA]

	saveMeta()
	refresh()
end

local function delete(slot)
	-- Delete files
	os.remove(savePath .. meta[slot].screenshot)
	os.remove(savePath .. meta[slot].savedata)

	-- Delete meta
	meta[slot] = nil

	saveMeta()
	refresh()
end

-- Button functions
local function slotBtnAction(slot)
	if swap then
		local slotB = swap
		swap = nil

		swapSaves(slot, slotB)
	elseif mode == modes.save then
		if meta[slot] then
			-- The slot is not empty, ask for confirmation
			local yes = function()
				delete(slot)
				save(slot)
			end

			gui.yesNoDialogue(confirmDialogText.overwrite, yes, nil, rightClickAction, true)
		else
			save(slot)
		end
	elseif mode == modes.load then
		local yes = function()
			disableMouseInput()
			sleep(delayAfterYesNoDialog)
			enableMouseInput()

			load(slot)

			fadeOutMusic(musicFadeOutTime)
			closeMenu()
		end

		gui.yesNoDialogue(confirmDialogText.load, yes, nil, rightClickAction)
	end
end

local function lockBtnAction(slot)
	toggleLock(slot)
end

local function swapBtnAction(slot)
	swap = slot
	refresh()
end

local function deleteBtnAction(slot)
	local yes = function()
		delete(slot)
	end

	gui.yesNoDialogue(confirmDialogText.delete, yes, nil, rightClickAction, true)
end

-- Sysbar button functions
local function sysbarSaveAction()
	mode = modes.save
	scene("savedata menu.png", populateTransition)
	destroyMenu()
	createMenu()
	makeVisible(populateTransition)
end

local function sysbarLoadAction()
	mode = modes.load
	scene("savedata menu.png", populateTransition)
	destroyMenu()
	createMenu()
	makeVisible(populateTransition)
end

local function sysbarTitleAction()
	local yes = function()
		disableMouseInput()
		sleep(delayAfterYesNoDialog)
		enableMouseInput()

		fadeOutMusic(musicFadeOutTime)
		closeCallback = nil
		closeMenu()
		openScript("_start.lua")
	end

	gui.yesNoDialogue(confirmDialogText.title, yes, nil, rightClickAction)
end

local function sysbarQuitAction()
	local yes = function()
		disableMouseInput()
		sleep(delayAfterYesNoDialog)
		enableMouseInput()

		fadeOutMusic(musicFadeOutTime)
		closeCallback = nil
		closeMenu()
		exitGame()
	end

	gui.yesNoDialogue(confirmDialogText.quit, yes, nil, rightClickAction)
end

-- Savedata menu
local function updateTooltipText()
	if swap then
		tooltipText:setText(tooltipStrings.swap)
	else
		tooltipText:setText(tooltipStrings[mode])
	end
end

local function prepareOpenMenu()
	-- Save a screenshot of the game
	saveScreenshot(savePath.."tmp.png", 354, 200)
	yield()

	-- Clear the screen
	scene("black.png", clearScreenTransition)

	-- Load data
	loadMeta()
end

makeVisible = function(transition)
	-- Show decorative elements
	for i = 1, #decorative do
		decorative[i]:show(transition)
	end

	-- Show page buttons
	for i = 1, #pageButtons do
		pageButtons[i]:show(transition)
	end

	-- Show slots
	for i = 1, #slots do
		local slot = slots[i]

		for k, element in pairs(slot) do
			if element.show then
				element:show(transition)
			end
		end
	end

	-- Show sysbar
	for k, element in pairs(sysbar) do
		element:show(transition)
	end
end

local function openMenu()
	-- Show elements
	precacheImage("assets/images/backgrounds/savedata menu.png")
	sleep(0.5)
	setBackground("savedata menu.png", showBgTransition)

	makeVisible(showElementsTransition)
end

local function populateSlots()
	-- Use the correct image paths for each mode
	local emptySlotPath
	local usedSlotPath
	local slotUnlockedPath
	local slotLockedPath
	local slotSwapPath
	local slotDeletePath

	if mode == modes.save then
		emptySlotPath = "save slot empty.png"
		usedSlotPath = "save slot used.png"
		slotUnlockedPath = "save unlocked.png"
		slotLockedPath = "save locked.png"
		slotSwapPath = "save swap.png"
		slotDeletePath = "save delete.png"
	elseif mode == modes.load then
		emptySlotPath = "load slot empty.png"
		usedSlotPath = "load slot used.png"
		slotUnlockedPath = "load unlocked.png"
		slotLockedPath = "load locked.png"
		slotSwapPath = "load swap.png"
		slotDeletePath = "load delete.png"
	end

	-- Populate slots
	for i = 1, #slots do
		slots[i] = {position = slots[i].position}

		local slot = slots[i]
		local slotNumber = (currentPage - 1) * (slotsCols * slotsRows) + i

		local empty = not meta[slotNumber]
		local locked = not empty and meta[slotNumber].locked

		-- Slot
		if empty then
			slot.button = Button.new(emptySlotPath, 1)
		else
			slot.button = Button.new(usedSlotPath, 1)

			slot.screenshot = Sprite.new("../../../" .. savePath .. meta[slotNumber].screenshot, 2)
			slot.screenshot:setPosition(slot.position.x + slotScreenshotPosition.x, slot.position.y + slotScreenshotPosition.y)

			slot.date = Text.new(slotDateFont, 2)
			slot.date:setText(meta[slotNumber].date)
			slot.date:setPosition(slot.position.x + slotDatePosition.x, slot.position.y + slotDatePosition.y)

			slot.description = Text.new(slotDescriptionFont, 2)
			slot.description:setText(meta[slotNumber].description)
			slot.description:setPosition(slot.position.x + slotDescriptionPosition.x, slot.position.y + slotDescriptionPosition.y)
		end

		slot.button:setPosition(slot.position.x, slot.position.y)

		if swap then
			slot.button.enabled = not locked and swap ~= slotNumber
		else
			slot.button.enabled = not (mode == modes.load and empty) and not (mode == modes.save and locked)
		end

		slot.button.onClick = function() slotBtnAction(slotNumber) end

		-- Swapping
		if swap == slotNumber then
			slot.swapIndicator = Sprite.new("swapping.png", 3)
			slot.swapIndicator:setPosition(slot.position.x + slotScreenshotPosition.x, slot.position.y + slotScreenshotPosition.y)
		end

		-- Slot number
		slot.number = Text.new(slotNumbersFont, 2)
		slot.number:setPosition(slot.position.x + slotNumbersPosition.x, slot.position.y + slotNumbersPosition.y)
		slot.number:setText(string.format("%03d", slotNumber))

		-- Lock
		if locked then
			slot.lockBtn = Button.new(slotLockedPath, 2)
		else
			slot.lockBtn = Button.new(slotUnlockedPath, 2)
		end

		slot.lockBtn:setPosition(slot.position.x + slotLockPosition.x, slot.position.y + slotLockPosition.y)
		slot.lockBtn.enabled = not empty and not swap
		slot.lockBtn.onClick = function() lockBtnAction(slotNumber) end

		-- Swap
		slot.swapBtn = Button.new(slotSwapPath, 2)
		slot.swapBtn:setPosition(slot.position.x + slotSwapPosition.x, slot.position.y + slotSwapPosition.y)
		slot.swapBtn.enabled = not empty and not locked and not swap
		slot.swapBtn.onClick = function() swapBtnAction(slotNumber) end

		-- Delete
		slot.deleteBtn = Button.new(slotDeletePath, 2)
		slot.deleteBtn:setPosition(slot.position.x + slotDeletePosition.x, slot.position.y + slotDeletePosition.y)
		slot.deleteBtn.enabled = not empty and not locked and not swap
		slot.deleteBtn.onClick = function() deleteBtnAction(slotNumber) end
	end
end

refresh = function()
	scene("savedata menu.png", populateTransition)
	populateSlots()
	updateTooltipText()

	if gameState then
		sysbar.save.enabled = mode ~= modes.save
	end
	
	sysbar.load.enabled = mode ~= modes.load

	makeVisible(populateTransition)
end

local function setPage(page)
	pageButtons[currentPage].enabled = true
	currentPage = page
	pageButtons[currentPage].enabled = false

	refresh()
end

destroyMenu = function()
	slots = {}
	decorative = {}
	pageButtons = {}
	sysbar = {}
	tooltipText = nil
end

closeMenu = function()
	scene("black.png", closeTransition)
	destroyMenu()
	meta = {}
	swap = nil

	setOnRightClick(nil)

	sleep(0.5)

	local state, callback = gameState, closeCallback
	closeCallback = nil
	gameState = nil
	gameStateDescription = nil

	if callback then
		callback(state)
	end
end

createMenu = function()
	-- Use the correct image paths for each mode
	local titlePath
	local pageBtnOddPath
	local pageBtnEvenPath

	if mode == modes.save then
		titlePath = "save title.png"
		pageBtnOddPath = "save pag odd.png"
		pageBtnEvenPath = "save pag even.png"
	elseif mode == modes.load then
		titlePath = "load title.png"
		pageBtnOddPath = "load pag odd.png"
		pageBtnEvenPath = "load pag even.png"
	end

	-- Create decorative elements
	local title = Sprite.new(titlePath, 1)
	title:setPosition(titlePosition.x, titlePosition.y)

	table.insert(decorative, title)

	-- Create tooltip
	local tooltipBg = Sprite.new("savedata tooltip bg.png", 1)
	tooltipBg:setPosition(tooltipBgPosition.x, tooltipBgPosition.y)

	tooltipText = Text.new(tooltipFont, 2)
	tooltipText:setPosition(tooltipBgPosition.x + tooltipTextPosition.x, tooltipBgPosition.y + tooltipTextPosition.y)
	updateTooltipText()

	table.insert(decorative, tooltipBg)
	table.insert(decorative, tooltipText)

	-- Create page buttons
	for i = 1, pages, 2 do
		local pageBtnOdd = Button.new(pageBtnOddPath, 1, tostring(i), false, pageNumbersFont, {r=255, g=255, b=255, a=255}, {r=0, g=0, b=0, a=0})
		pageBtnOdd:setPosition(pageNumbersPosition.x + (i - 1) * pageNumbersDistance, pageNumbersPosition.y)
		pageBtnOdd.onClick = function() setPage(i) end

		local pageBtnEven = Button.new(pageBtnEvenPath, 1, tostring(i + 1), false, pageNumbersFont, {r=255, g=255, b=255, a=255}, {r=0, g=0, b=0, a=0})
		pageBtnEven:setPosition(pageNumbersPosition.x + i * pageNumbersDistance, pageNumbersPosition.y)
		pageBtnEven.onClick = function() setPage(i + 1) end

		table.insert(pageButtons, pageBtnOdd)
		table.insert(pageButtons, pageBtnEven)
	end

	pageButtons[currentPage].enabled = false

	-- Create save slots
	for i = 1, slotsRows do
		for j = 1, slotsCols do
			slotNumber = (i - 1) * slotsCols + j

			slots[slotNumber] = {
				position = {x = slotsPosition.x + slotsDistance.x * (j - 1), y = slotsPosition.y + (i - 1) * slotsDistance.y}
			}
		end
	end

	populateSlots()

	-- Create sysbar
	if gameState then
		-- We have a game state to save, create a button to switch to save mode
		sysbar.save = Button.new("sysbar save.png", 1)
		sysbar.save.enabled = mode ~= modes.save
		sysbar.save.onClick = sysbarSaveAction
	else
		-- We don't have a game state to save, show the UP state of the button as a sprite
		sysbar.save = Sprite.new("../gui/sysbar save.png", 1)
		sysbar.save:defineSpriteSheet(4, 4, 1, 0)
	end

	sysbar.save:setPosition(sysbarSavePosition.x, sysbarSavePosition.y)

	sysbar.load = Button.new("sysbar load.png", 1)
	sysbar.load:setPosition(sysbarLoadPosition.x, sysbarLoadPosition.y)
	sysbar.load.enabled = mode ~= modes.load
	sysbar.load.onClick = sysbarLoadAction

	sysbar.title = Button.new("sysbar title.png", 1)
	sysbar.title:setPosition(sysbarTitlePosition.x, sysbarTitlePosition.y)
	sysbar.title.onClick = sysbarTitleAction

	sysbar.quit = Button.new("sysbar quit.png", 1)
	sysbar.quit:setPosition(sysbarQuitPosition.x, sysbarQuitPosition.y)
	sysbar.quit.onClick = sysbarQuitAction

	sysbar.back = Button.new("sysbar back.png", 1)
	sysbar.back:setPosition(sysbarBackPosition.x, sysbarBackPosition.y)
	sysbar.back.onClick = closeMenu
end

rightClickAction = function()
	if swap then
		swap = nil
		refresh()
	else
		setOnRightClick(nil)
		closeMenu()
	end
end


-- Public interface
function saveMenu.openSaveMenu(callback, currentGameState, currentGameStateDescription)
	if not currentGameState or not currentGameStateDescription then
		error("Can't open save menu without a game state.", 2)
	end

	gameState = currentGameState
	gameStateDescription = currentGameStateDescription

	-- Set mode
	mode = modes.save
	closeCallback = callback

	-- Open the menu
	prepareOpenMenu()
	createMenu()
	openMenu()

	-- Close on right click
	setOnRightClick(rightClickAction)
end

function saveMenu.openLoadMenu(callback, currentGameState, currentGameStateDescription)
	gameState = currentGameState
	gameStateDescription = currentGameStateDescription

	-- Set mode
	mode = modes.load
	closeCallback = callback

	-- Open the menu
	prepareOpenMenu()
	createMenu()
	openMenu()

	-- Close on right click
	setOnRightClick(rightClickAction)
end