gui = {}

-- GUI properties
-- Dialogue box
local dialogBoxPosition = {x = 0, y = 444}
local dialogTextPosition = {x = 293, y = 32}
local dialogYesBtnPosition = {x = 1124, y = 23}
local dialogNoBtnPosition = {x = 1417, y = 23}

local showDialogueTransition = {type=Transition.fade, time=0.1, block=false}
local hideDialogueTransition = {type=Transition.fade, time=0.1, block=false}

local zindex = 150

-- Right click prompt
local rightClickPrompt = Sprite.new("right click prompt.png", zindex)
rightClickPrompt:setPosition(30, 30)

local showRightClickPromptTransition = {type=Transition.fade, time=0.1, block=false}
local hideRightClickPromptTransition = {type=Transition.fade, time=0.1, block=false}

-- GUI elements
local dialogueBox = {}

-- Cursors
local examineCursor = Cursor.new("examine cursor.png", 24, 24)
local examineHoverCursor = Cursor.new("examine hover cursor.png", 24, 24)
local examineSeenCursor = Cursor.new("examine seen cursor.png", 24, 24)

-- Fonts
local dialogBoxFont = {
	file = "assets/fonts/Roboto-Medium.ttf",
	size = 30,
	color = {r = 255, g = 255, b = 255, a = 255},
	shadowDistance = 0,
	shadowColor = {r = 0, g = 0, b = 0, a = 0}
}


local function closeDialogueBox(onRightClickAfter)
	for k, element in pairs(dialogueBox) do
		element:hide(hideDialogueTransition)
	end

	setOnRightClick(onRightClickAfter)
	dialogueBox = {}

	enableMouseInput()
end


-- Public interface

-- Create a yes-no dialogue box
function gui.yesNoDialogue(text, yesFunction, noFunction, onRightClickAfter, important)
	local bgPath

	if important then
		bgPath = "dialogue box important.png"
	else
		bgPath = "dialogue box.png"
	end

	-- Create dialogue box
	dialogueBox.background = Sprite.new(bgPath, zindex)
	dialogueBox.background:setPosition(dialogBoxPosition.x, dialogBoxPosition.y)

	dialogueBox.text = Text.new(dialogBoxFont, zindex + 1)
	dialogueBox.text:setPosition(dialogBoxPosition.x + dialogTextPosition.x, dialogBoxPosition.y + dialogTextPosition.y)
	dialogueBox.text:setText(text)

	dialogueBox.yesBtn = Button.new("yes btn.png", zindex + 1)
	dialogueBox.yesBtn:setPosition(dialogBoxPosition.x + dialogYesBtnPosition.x, dialogBoxPosition.y + dialogYesBtnPosition.y)
	dialogueBox.yesBtn.onClick = function()
		closeDialogueBox(onRightClickAfter)

		if yesFunction then
			yesFunction()
		end
	end

	dialogueBox.noBtn = Button.new("no btn.png", zindex + 1)
	dialogueBox.noBtn:setPosition(dialogBoxPosition.x + dialogNoBtnPosition.x, dialogBoxPosition.y + dialogNoBtnPosition.y)

	no = function()
		closeDialogueBox(onRightClickAfter)

		if noFunction then
			noFunction()
		end
	end

	dialogueBox.noBtn.onClick = no
	setOnRightClick(no)

	-- Disable mouse input for items below the dialogue box
	disableMouseInput(zindex + 1)

	-- Show dialogue box
	yield()

	for k, element in pairs(dialogueBox) do
		element:show(showDialogueTransition)
	end
end

-- Show a prompt telling the player to press right click to go back
function gui.showRightClickPrompt()
	rightClickPrompt:show(showRightClickPromptTransition)
end

-- Hide the prompt telling the player to press right click to go back
function gui.hideRightClickPrompt()
	rightClickPrompt:hide(hideRightClickPromptTransition)
end

-- Show the gui for the examination mode
function gui.beginExamination()
	setCursor(examineCursor)
	gui.showRightClickPrompt()

	-- Exit examination on right click
	setOnRightClick(function()
		setOnRightClick(nil)

		gui.endExamination()
		world.exitExaminationMode()
		explorationMenu.open()
	end)
end

-- Hide the gui for the examination mode
function gui.endExamination()
	setCursor(nil)
	gui.hideRightClickPrompt()

	-- Disable right click action
	setOnRightClick(nil)
end

-- Tell the player that the mouse is over an examinable item
function gui.beginHoverExaminableItem(alreadyExamined)
	playSound("item hover.ogg")

	if alreadyExamined then
		setCursor(examineSeenCursor)
	else
		setCursor(examineHoverCursor)
	end
end

-- Tell the player that the mouse is no longer over an examinable item
function gui.endHoverExaminableItem()
	setCursor(examineCursor)
end