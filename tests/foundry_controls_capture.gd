extends SceneTree
func _initialize() -> void: capture.call_deferred()
func shot(game, label: String) -> void:
	game.art.queue_redraw(); await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/buttons33-"+label+".png")
func capture() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
	root.add_child(game); await process_frame; game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.collection=ForgeEquipment.new(); game.launch_expedition(); game.auto_play=true
	game.ui.settings_page="options"; game.ui.show_settings(); await shot(game,"settings")
	game.ui.settings_page="controls"; game.ui.show_settings(); await shot(game,"controls")
	game.model.state="camp"; game.model.exp.clear_clock=-2; game.screen="camp"; game.model.exp.field_credits=350
	for tab in ["Round clear","Build","Mastery","Equipment"]:
		game.review_tab=tab; ReviewView.camp(game); await shot(game,tab.to_lower().replace(" ","-"))
	game.ui.clear_overlay(); game.ui.hud.visible=false
	for i in range(5):
		var state: String=["normal","hover","pressed","disabled","focus"][i]
		game.ui._label(game.ui.overlay,state,Rect2(90,70+i*75,140,35),16,game.ui.CREAM)
		for j in range(3):
			var button: Button=game.ui._button(["Continue","Back","Mastery"][j],Rect2(250+j*200,70+i*75,180,40),func(): pass,j==0)
			button.add_theme_stylebox_override("normal",FoundryButtonStyle.make(j==0,"normal" if state=="focus" else state,j==2,j==2))
			if state=="disabled": button.disabled=true
			if state=="focus": button.add_theme_stylebox_override("focus",FoundryButtonStyle.make(false,"focus")); button.grab_focus()
	await shot(game,"states")
	game.ui.settings_page="options"; game.ui.show_settings()
	var before: bool=game.ui.reduced
	for b in game.ui.overlay.find_children("*","Button",true,false):
		if b.text in ["On","Off"]: b.pressed.emit(); break
	assert(game.ui.reduced!=before,"Switch action must still fire")
	game.ui.settings_page="controls"; game.ui.show_settings()
	var q: Button=game.ui.overlay.find_child("Cast_q",true,false)
	var quick_before: bool=game.cast_quick.q; q.pressed.emit()
	assert(game.cast_quick.q!=quick_before,"Casting control must remain interactive")
	print("BUTTONS33 CAPTURE AND INTERACTION PASS"); game.queue_free(); await process_frame; quit()
