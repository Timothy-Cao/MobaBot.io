extends SceneTree
func _initialize() -> void: verify.call_deferred()
func verify() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate()
	game.persist_settings=false
	root.add_child(game); await process_frame
	game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.launch_practice(); game.close_practice()
	for id in ["vanguard_q","vanguard_anchor","mastery_utility","conductor_q"]:
		assert(PaintedIcons.texture(id)!=null,"Missing exported icon: "+id)
	for track in ["menu","settings","casual","main_loop1","main_loop2","main_loop3","boss1","big_boss","big_boss2"]:
		assert(load("res://music/%s.mp3"%track) is AudioStreamMP3,"Missing exported music: "+track)
	game.model.vanguard.burst_left=8
	ArsenalBurst.fire(game.model,game.model.player+Vector2(400,0))
	game.model._projectile_step(0.15)
	game.ui.update_hud(game.model); game.art.queue_redraw()
	await process_frame
	if DisplayServer.get_name()!="headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_executable_path().get_base_dir()+"/../export-smoke.png")
	assert(ProjectSettings.get_setting("application/config/version")=="0.35.0-test.2","Release version mismatch")
	game.collection=ForgeEquipment.new(); game.launch_expedition(); game.auto_play=true
	assert(DiscoveryRules.enabled(game.model),"Export must launch current progression")
	for id in ["yard","assembly","cooling"]: assert(load("res://assets/levels/"+id+".png") is Texture2D,"Missing level illustration")
	for level in range(1,4):
		game.model.exp.operation_chapter=level; game.model.exp.enter(game.model)
		assert(game.model.kit.extra.walls.size()==FactoryWorks.layout(level,game.model.exp.route_index).size(),"Missing factory geometry")
		game.art.queue_redraw(); await process_frame
	game.queue_free(); await process_frame
	print("EXPORTED BUILD SMOKE PASS: Practice, HUD, icons, projectile")
	quit()
