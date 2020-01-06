local hiddenOption

world.registerDialogueOption("Example dialogue option 1", false, function(sakura)
	s "This is the first dialogue option."
	s "After having this conversation a new dialogue option will be unlocked."

	world.unhideDialogueOption(hiddenOption)
end)

hiddenOption = world.registerDialogueOption("Unlocked dialogue option", true, function(sakura)
	s "This dialogue option has been unlocked after choosing the first one."
end)