extends "res://tests/discovery35_test.gd"
func execute() -> void:
	var run:=modern(); run.health=run.max_health()*0.3
	Vanguard.earn(run); Vanguard.earn(run); ReviewRules.offer(run)
	check(run.offers.size()==3 and run.offers.count("full_heal")==1,"At exactly 30 percent one card is a heal")
	var before: Array=run.offers.duplicate(); ReviewRules.offer(run)
	check(run.offers==before,"Pending cards remain stable")
	check(ReviewRules.choose(run,2),"Heal selection succeeds")
	check(run.health==run.max_health() and run.kit.loadout.rewards18.size()==1,"Full heal spends one pick")
	check("full_heal" not in run.offers,"Next pick after healing has no heal card")
	drain(run); run.health=run.max_health()*0.301; Vanguard.earn(run); ReviewRules.offer(run)
	check("full_heal" not in run.offers,"Above threshold no forced heal")
	run=modern(); run.health=run.max_health()*0.2
	var aid: RecoveryAid=run.recovery_aid
	aid.step(run,5.9); check(run.supply_drops.is_empty(),"Brief low health does not create immediate pack")
	aid.step(run,0.2)
	check(run.supply_drops.size()==1,"Sustained low health spawns a pack without a kill")
	var pack: Dictionary=run.supply_drops[0]
	check(pack.kind=="health_pack" and pack.value==25 and pack.rescue,"Rescue uses the standard quarter-health pack")
	check(run.player.distance_to(pack.pos)>=650 and run.player.distance_to(pack.pos)<=1000,"Rescue requires travel")
	check(free_point(pack.pos,run.kit.extra.walls,40) and run.ARENA.grow(-70).has_point(pack.pos),"Pack lies on walkable arena floor")
	check(aid.cooldown>=45 and aid.cooldown<=65,"Bounded randomized recovery cadence")
	aid.step(run,70); check(run.supply_drops.size()==1,"Only one unclaimed rescue pack")
	var hp: float=run.health; run._collect_supply(pack); run._collect_supply(pack)
	check(is_equal_approx(run.health,hp+run.max_health()*0.25),"Health pack is claimed once")
	run=modern(); run.health=run.max_health()*0.1; run.state="upgrade"
	run.recovery_aid.step(run,100); check(run.supply_drops.is_empty(),"Paused upgrade cannot spawn packs")
	run.state="running"; run.exp.clear_clock=10; run.recovery_aid.step(run,100)
	check(run.supply_drops.is_empty(),"Collection interval does not generate new packs")
	run.exp.clear_clock=-1; run.exp.practice=true; run.recovery_aid.step(run,100)
	check(run.supply_drops.is_empty() and not RecoveryAid.low(run),"Practice excluded")
	run=modern(); run.health=run.max_health()*0.1; run.recovery_aid.step(run,7)
	pack=run.supply_drops[0]; pack.age=74.9; run._supply_step(0.2)
	check(run.supply_drops.is_empty(),"Expired rescue pack disappears")
	for level in range(1,4):
		for round_index in range(3):
			run=modern(level); run.exp.route_index=round_index; run.exp.enter(run); run.health=run.max_health()*0.3
			run.recovery_aid.step(run,7)
			check(run.supply_drops.size()==1 and free_point(run.supply_drops[0].pos,run.kit.extra.walls,40),"Safe rescue on each map variant")
	run=modern(); run.health=run.max_health()*0.2
	var detached:=modern(); detached.health=detached.max_health()*0.2; detached.detached_camera=true; detached.detached_origin=Vector2(-1500,-1000)
	run.recovery_aid.step(run,7); detached.recovery_aid.step(detached,7)
	check(run.supply_drops[0].pos==detached.supply_drops[0].pos,"Detached camera never relocates supplies")
	run.supply_drops.clear()
	for direction in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]: run._drop_supply(run.player+direction*1400,"health_pack",25)
	for scale_value in [0.65,1.0,1.4]:
		run.view_size=Vector2(960,540)/scale_value
		var markers:=RecoveryAid.indicators(run)
		check(markers.size()==3,"Bound indicator count")
		for marker in markers: check(RecoveryAid.EDGE.grow(0.01).has_point(marker.pos),"Markers remain inside HUD-safe edge at every zoom")
	run.supply_drops.clear(); run._drop_supply(run.player,"health_pack",25)
	check(RecoveryAid.indicators(run).is_empty(),"Visible pack needs no edge indicator")
	run.supply_drops[0].pos=run.player+Vector2(1500,0); run.supply_drops[0].value=0
	check(RecoveryAid.indicators(run).is_empty(),"Collected pack indicator vanishes immediately")
	run.state="upgrade"; run.supply_drops[0].value=25
	check(RecoveryAid.indicators(run).is_empty(),"Markers do not obscure upgrade choices")
	run.state="camp"
	check(RecoveryAid.indicators(run).is_empty(),"No world markers in camp")
	if "--render" in OS.get_cmdline_user_args(): await recovery_capture()
	print("RECOVERY 36: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
func recovery_capture() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
	root.add_child(game); await process_frame; game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.collection=ForgeEquipment.new(); game.launch_expedition(); game.auto_play=true
	game.model.health=game.model.max_health()*0.25
	for direction in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP]: game.model._drop_supply(game.model.player+direction*1400,"health_pack",25)
	game.ui.show_running(); game.ui.update_hud(game.model); game.art.queue_redraw()
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/recovery36-markers.png")
	game.art.reduced_effects=true; game.art.queue_redraw(); await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/recovery36-markers-reduced.png")
	Vanguard.earn(game.model); ReviewRules.offer(game.model); ReviewView.upgrades(game.ui,game.model)
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/recovery36-heal-card.png")
	game.queue_free(); await process_frame
