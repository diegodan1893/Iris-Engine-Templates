local hiddenOption

world.registerDialogueOption("Opción de diálogo de ejemplo 1", false, function(sakura)
	s "Esta es la opción de ejemplo 1."
	s "Al elegirla se ha desbloqueado una nueva opción de diálogo."

	world.unhideDialogueOption(hiddenOption)
end)

hiddenOption = world.registerDialogueOption("Opción desbloqueable de ejemplo", true, function(sakura)
	s "Esta opción de diálogo estaba oculta y se ha desbloqueado al elegir la primera."
end)