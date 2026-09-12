extends SceneTree
func _initialize() -> void: capture.call_deferred()
func shot(game, name: String) -> void:
	game.art.queue_redraw(); await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/foundry-"+name+".png")
func capture() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
	root.add_child(game); await process_frame; game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.launch_practice(); game.close_practice(); game.auto_play=true # Capture must not react to focus loss.
	game.screen="running"; game.model.state="running"; game.ui.show_running(); game.model.enemies.clear()
	var walls: String=var_to_str(game.model.kit.extra.walls)
	var rng_state: int=game.model.loot_rng.state
	await shot(game,"terrain")
	game.art.reduced_effects=true; await shot(game,"terrain-reduced"); game.art.reduced_effects=false
	game.model.kit.extra.walls.clear()
	var a:=RangedThreats.spawn(game.model,"drifter",game.model.player+Vector2(-170,-60),true)
	var b:=RangedThreats.spawn(game.model,"bulwark",game.model.player+Vector2(170,-60),true)
	a.warmup=0; b.warmup=0; a.phase="telegraph"; a.dir=Vector2.DOWN; b.phase="telegraph"; b.attack="ring"
	var actors: String=var_to_str(game.model.enemies)
	await shot(game,"minibosses")
	if actors!=var_to_str(game.model.enemies): push_error("Drawing mutated enemy state"); quit(1); return
	a.phase="recover"; b.phase="recover"; await shot(game,"recovery")
	game.art.reduced_effects=true; await shot(game,"recovery-reduced")
	game.model.kit.extra.walls=str_to_var(walls)
	await shot(game,"restored-terrain")
	if walls!=var_to_str(game.model.kit.extra.walls) or rng_state!=game.model.loot_rng.state:
		push_error("Presentation changed terrain or loot RNG"); quit(1); return
	game.model.enemies.clear()
	for i in range(180):
		game.model.spawn_enemy(game.model.player+Vector2((i%18-9)*35,(i/18-5)*35),0)
		game.model.enemies.back().warmup=0
	var samples: Array[int]=[]
	var original_walls: Array=game.model.kit.extra.walls.duplicate(true)
	var baseline=load("res://output/foundry_baseline.gd") if "--baseline" in OS.get_cmdline_user_args() else null
	var mode: Dictionary={"old":false}
	var draw_terrain: Callable=func():
		for wall in original_walls:
			if mode.old: baseline.barrier(game.art,wall)
			else: FoundryTerrain.draw(game.art,wall)
	game.model.kit.extra.walls.clear(); game.art.draw.connect(draw_terrain)
	for old in ([true,false] if baseline!=null else [false]):
		mode.old=old; samples.clear()
		for i in range(40):
			var start:=Time.get_ticks_usec(); game.art.queue_redraw()
			await process_frame; await RenderingServer.frame_post_draw
			if i>=10: samples.append(Time.get_ticks_usec()-start)
		samples.sort(); print("FOUNDRY 180 ","baseline" if old else "current"," cadence median/p95 us: ",samples[15]," / ",samples[28])
	game.art.draw.disconnect(draw_terrain); game.model.kit.extra.walls.assign(original_walls)
	await shot(game,"crowd")
	game.auto_play=false; game.collection=ForgeEquipment.new(); game.launch_expedition(); game.auto_play=true
	game.model.state="camp"; game.model.exp.clear_clock=-2; game.screen="camp"
	for tab in ["Round clear","Build","Mastery","Equipment"]:
		game.review_tab=tab; ReviewView.camp(game); await shot(game,tab.to_lower().replace(" ","-"))
	print("FOUNDRY VISUAL: render state and loot RNG preserved; captures complete")
	game.queue_free(); await process_frame; quit()
