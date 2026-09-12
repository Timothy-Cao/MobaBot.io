extends SceneTree
func _initialize() -> void: capture.call_deferred()
func capture() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
	root.add_child(game); await process_frame; game.set_physics_process(false)
	game.sound.set_muted(true); game.music_player.shutdown(); game.show_home()
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/menu-foundry.png")
	for button in game.ui.overlay.get_children():
		if button is Button and button.text=="Equipment": button.grab_focus()
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/menu-foundry-focus.png")
	game.ui.reduced=true; game.show_home()
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/menu-foundry-reduced.png")
	game.ui.gear_requested.emit()
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/menu-foundry-equipment.png")
	game.queue_free(); await process_frame; quit()
