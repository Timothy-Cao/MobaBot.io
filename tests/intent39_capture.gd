extends SceneTree
## Rendered combat review; in-memory fixture, no saves, settings or music writes.
func _initialize() -> void: capture.call_deferred()
func capture() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
	root.add_child(game); await process_frame
	game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.collection=ForgeEquipment.new(); game.launch_expedition(); game.auto_play=true
	var run=game.model
	run.enemies.clear(); run.kit.extra.walls.clear()
	for i in range(6):
		run.spawn_enemy(run.player+Vector2.from_angle(i*TAU/6)*105,0)
		var e: Dictionary=run.enemies.back(); e.warmup=0; e.hp=500; e.max_hp=500
		ReviewRules.strike_status(run,e,true)
	run.vanguard.spin_swing=true; run.vanguard.combo_swing=true; run.vanguard.hit_hammer(run)
	assert(run.intent_combos.spins==1 and run.intent_combos.spins_hit==1,"Spin contact must be recorded")
	game.ui.show_running(); game.ui.update_hud(run)
	for reduced in [false,true]:
		game.art.reduced_effects=reduced
		for progress in [0.1,0.4,0.8]:
			run.vanguard.impacts.back().life=0.3*(1-progress)
			var state:=var_to_str([run.enemies,run.vanguard.impacts,run.intent_combos,run.player,run.health,run.loot_rng.state])
			game.art.queue_redraw(); await process_frame; await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://output/intent39-spin-%s-%d.png"%["reduced" if reduced else "normal",roundi(progress*10)])
			assert(state==var_to_str([run.enemies,run.vanguard.impacts,run.intent_combos,run.player,run.health,run.loot_rng.state]),"Readability rendering must preserve simulation state")
	print("INTENT39 VISUAL: six spin/status captures; simulation and RNG preserved")
	if "--crowd" in OS.get_cmdline_user_args():
		run.enemies.clear(); run.vanguard.impacts.clear()
		for i in range(180):
			run.spawn_enemy(run.player+Vector2((i%18-9)*35,(i/18-5)*35),0)
			run.enemies.back().warmup=0
		for reduced in [false,true]:
			game.art.reduced_effects=reduced
			for status in [false,true]:
				for e in run.enemies: e.stun=1.0 if status else 0.0; e.vulnerable=1.0 if status else 0.0
				var samples: Array[int]=[]
				for i in range(40):
					var start:=Time.get_ticks_usec(); game.art.queue_redraw()
					await process_frame; await RenderingServer.frame_post_draw
					if i>=10: samples.append(Time.get_ticks_usec()-start)
				samples.sort()
				print("INTENT39 CROWD ",JSON.stringify({"reduced":reduced,"status":status,"median_us":samples[15],"p95_us":samples[28]}))
				if status: root.get_texture().get_image().save_png("res://output/intent39-crowd-%s.png"%["reduced" if reduced else "normal"])
	game.queue_free(); await process_frame; quit()
