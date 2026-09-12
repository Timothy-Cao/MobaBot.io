class_name OperationView
extends RefCounted

static func prepare(game) -> void:
	var ui=game.ui
	game.chapter_choice=clampi(game.chapter_choice,1,DemoPacing.LEVELS)
	ExpeditionView.frame(ui,"Levels",game.show_home)
	for i in range(DemoPacing.LEVELS):
		var chapter: int=i+1
		var button: Button=ui._button("Level %d\n%s"%[chapter,FactoryMaps.NAMES[i]],Rect2(48+i*292,168,278,80),func():
			game.chapter_choice=chapter; prepare(game),game.chapter_choice==chapter)
		button.add_theme_font_size_override("font_size",18)
		button.disabled=chapter>game.collection.unlocked_chapter()
		button.set_meta("chapter",chapter)
	var start: Button=ui._button("Play Level %d"%game.chapter_choice,Rect2(679,439,234,44),game.confirm_new_run)
	start.disabled=game.collection.blocked; start.grab_focus()
	if not game.collection.checkpoint.is_empty(): ui._button("Continue",Rect2(424,439,234,44),func(): game.launch_expedition(true),false)
	if not game.collection.message.is_empty(): ui._label(ui.overlay,game.collection.message,Rect2(48,491,850,21),12,ui.CORAL)
