class_name OperationView
extends RefCounted

static func prepare(game) -> void:
	var ui=game.ui
	game.chapter_choice=clampi(game.chapter_choice,1,DemoPacing.LEVELS)
	ExpeditionView.frame(ui,"Levels",game.show_home)
	for i in range(DemoPacing.LEVELS):
		var chapter: int=i+1
		var button: Button=ui._button("",Rect2(48+i*292,105,278,316),func():
			game.chapter_choice=chapter; prepare(game),false)
		button.disabled=chapter>game.collection.unlocked_chapter()
		button.set_meta("chapter",chapter)
		for state in ["normal","hover","pressed","disabled"]: button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
		var art:=LevelPortrait.new(); art.size=button.size; art.mouse_filter=Control.MOUSE_FILTER_IGNORE
		art.texture=load("res://assets/levels/"+["yard","assembly","cooling"][i]+".png")
		art.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		art.selected=game.chapter_choice==chapter; art.locked=button.disabled
		button.add_child(art)
		button.mouse_entered.connect(func(): art.hovered=true; art.queue_redraw())
		button.mouse_exited.connect(func(): art.hovered=false; art.queue_redraw())
		ui._label(button,"Level %d"%chapter,Rect2(20,247,238,30),25,ui.MUTED if button.disabled else ui.CREAM,true)
		ui._label(button,FactoryMaps.NAMES[i],Rect2(20,281,238,22),15,ui.MUTED if button.disabled else ui.GOLD)
		if button.disabled: button.tooltip_text="Clear Level %d"%(chapter-1)

	var start: Button=ui._button("Play Level %d"%game.chapter_choice,Rect2(679,439,234,44),game.confirm_new_run)
	start.disabled=game.collection.blocked; start.grab_focus()
	if not game.collection.checkpoint.is_empty(): ui._button("Continue",Rect2(424,439,234,44),func(): game.launch_expedition(true),false)
	if not game.collection.message.is_empty(): ui._label(ui.overlay,game.collection.message,Rect2(48,491,850,21),12,ui.CORAL)
