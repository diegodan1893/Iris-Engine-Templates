-- Introducción
setTextAlign(Position.center)
say "\nPlantilla para juegos de exploración"
hideText()
setTextAlign(Position.left)

sleep(0.5)
scene("example place.png", 1.5)
playMusic("Pond.ogg")

sakura:show("normal", transitions.blockFade)

s "Para aprender a usar esta plantilla, consulta la documentación en https://iris-engine.readthedocs.io/"

hideText()

-- Colocar a un personaje con una conversación
world.placeCharacter("examplePlace", "sakura1.png", "normal", "conversation example.lua")