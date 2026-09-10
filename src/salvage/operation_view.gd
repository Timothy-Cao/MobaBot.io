class_name OperationView
extends RefCounted

static func prepare(game) -> void:
	var ui=game.ui
	ExpeditionView.frame(ui,"Operation",game.show_home)
	ui._label(ui.overlay,"Choose a Chapter · 3 rounds · Build resets each attempt",Rect2(48,95,850,28),17,ui.GOLD)
	for i in range(OperationRules.CHAPTERS):
		var chapter: int=i+1
		var button: Button=ui._button("%d · %s"%[chapter,BotExpedition.STAGES[i]],Rect2(48+(i%4)*218,147+(i/4)*82,208,64),func():
			game.chapter_choice=chapter; prepare(game),game.chapter_choice==chapter)
		button.add_theme_font_size_override("font_size",15)
		button.disabled=chapter>game.collection.unlocked_chapter()
		button.set_meta("chapter",chapter)
		button.tooltip_text="Replay for Salvage" if chapter<=game.collection.chapter_cleared else "Clear to unlock the next Chapter"
	ui._label(ui.overlay,"Ascension",Rect2(48,345,170,28),17,ui.MUTED)
	for i in range(6):
		var button: Button=ui._button(str(i),Rect2(205+i*47,340,40,38),func():
			game.ascension_choice=i; prepare(game),i==game.ascension_choice)
		button.disabled=i>game.collection.unlocked_ascension
		button.tooltip_text=OperationRules.difficulty_text(i)
	ui._label(ui.overlay,"%d Salvage · Equipment persists"%game.collection.credits,Rect2(48,397,650,26),16,ui.TEAL)
	var start: Button=ui._button("Start Operation",Rect2(679,439,234,44),game.confirm_new_run)
	start.disabled=game.collection.blocked; start.grab_focus()
	if not game.collection.checkpoint.is_empty(): ui._button("Continue saved run",Rect2(424,439,234,44),func(): game.launch_expedition(true),false)
	ui._label(ui.overlay,"Save between rounds",Rect2(48,445,340,25),13,ui.MUTED)
	if not game.collection.message.is_empty(): ui._label(ui.overlay,game.collection.message,Rect2(48,491,850,21),12,ui.CORAL)
