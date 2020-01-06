-- Introduction
setTextAlign(Position.center)
say "\nExploration game template"
hideText()
setTextAlign(Position.left)

sleep(0.5)
scene("example place.png", 1.5)
playMusic("Pond.ogg")

sakura:show("normal", transitions.blockFade)

s "Learn how to use this template at\nhttps://iris-engine.readthedocs.io/"

hideText()

-- Add a character with dialogue options at Example Place
world.placeCharacter("examplePlace", "sakura1.png", "normal", "conversation example.lua")