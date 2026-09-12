extends "res://tests/demo_pacing_test.gd"
func execute() -> void:
	var run:=fresh(); run.field_pickups.killed(run,run.player)
	var first: Dictionary=run.field_pickups.due.duplicate()
	check(first.health_pack>=45 and first.health_pack<=75 and first.vacuum>=45 and first.vacuum<=75,"Independent initial windows")
	check(first.health_pack!=first.vacuum and run.supply_drops.is_empty(),"No immediate or synchronized reward")
	run.time=first.health_pack; run.field_pickups.killed(run,run.player)
	check(run.supply_drops.any(func(s): return s.kind=="health_pack"),"Next kill after deadline drops health")
	check(run.field_pickups.due.health_pack-run.time>=45,"No instant repeat")
	run.health=run.max_health()*0.5; var pack: Dictionary={"kind":"health_pack","value":25}
	run._collect_supply(pack); run._collect_supply(pack)
	check(is_equal_approx(run.health,run.max_health()*0.75),"Quarter max-health pack claimed once")
	run.health=run.max_health()*0.95; run._collect_supply({"kind":"health_pack","value":25})
	check(run.health==run.max_health(),"Healing capped at maximum")
	run=fresh(); run.health=run.max_health()*0.5
	run.pickups.append({"pos":run.player+Vector2(2000,0),"value":1800})
	run._drop_supply(run.player+Vector2(1800,0),"health_pack",25)
	run._drop_supply(run.player+Vector2(1900,0),"coins",100)
	run._drop_supply(run.player+Vector2(2000,0),"vacuum",1)
	run.exp.loot_chests.append({"pos":run.player+Vector2(2100,0),"life":30.0})
	run._collect_supply({"kind":"vacuum","value":1})
	check(run.total_xp==33 and run.pickups.is_empty(),"Magnet collects distant XP")
	check(run.exp.field_credits==30 and is_equal_approx(run.health,run.max_health()*0.75),"Magnet collects credits and health")
	check(run.exp.pending_chests==1 and run.exp.loot_chests.is_empty(),"Magnet claims dropped chest")
	check(run.supply_drops.all(func(s): return s.value==0),"Other magnets consumed without recursive collection")
	FieldPickups.sweep(run)
	check(run.total_xp==33 and run.exp.pending_chests==1,"Repeated sweep cannot duplicate rewards")
	run=fresh(); run.exp.practice=true; run.time=1000; run.field_pickups.killed(run,run.player)
	check(run.supply_drops.is_empty() and run.field_pickups.due.is_empty(),"Practice kills do not generate timed rewards")
	if "--render" in OS.get_cmdline_user_args(): await capture_pickups()
	print("FIELD PICKUPS: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
func capture_pickups() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
	root.add_child(game); await process_frame; game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.launch_practice(); game.close_practice(); game.model.enemies.clear()
	game.model._drop_supply(game.model.player+Vector2(-70,-40),"health_pack",25)
	game.model._drop_supply(game.model.player+Vector2(70,-40),"vacuum",1)
	game.art.queue_redraw(); await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/field-pickups.png")
	game.art.reduced_effects=true; game.art.queue_redraw()
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/field-pickups-reduced.png")
	game.queue_free(); await process_frame
