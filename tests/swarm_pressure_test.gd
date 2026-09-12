extends "res://tests/demo_pacing_test.gd"
func execute() -> void:
	var run:=fresh(); run.kit.extra.walls.clear()
	check(RangedThreats.beam_end(run,Vector2.ZERO,Vector2.RIGHT).x==940,"Longer lance uses shared tell/hit geometry")
	run.stage_time=120; check(DemoPacing.specialist(run,4)=="lancer","Lancer introduced at two minutes")
	var bomber:=RangedThreats.spawn(run,"bomber",run.player+Vector2(250,0),true)
	bomber.phase="aim"; bomber.clock=0; run.exp.route_index=2; run.stage_time=200
	RangedThreats.step(run,bomber,0.01)
	check(bomber.phase=="bombard" and bomber.bomb_count==8,"Later bomber capped at eight bombs")
	RangedThreats.step(run,bomber,0.01)
	check(run.hazards.size()==1 and run.hazards[0].time==1.05,"Bombs receive individual warnings, not prequeued targets")
	var first: Vector2=run.hazards[0].pos; run.player+=Vector2(200,0)
	RangedThreats.step(run,bomber,0.45)
	check(run.hazards.size()==2 and Vector2(run.hazards[1].pos).distance_to(first)>100,"Later shots follow changed position")
	for i in range(6): RangedThreats.step(run,bomber,0.45)
	check(run.hazards.size()==8 and bomber.phase=="recover" and is_equal_approx(bomber.clock,2.4),"Finite barrage and recovery")
	run=fresh(); run.kit.extra.walls.clear(); run.enemies.clear()
	for i in range(12): run.spawn_enemy(run.player+Vector2(200,0),0)
	for i in range(120): SwarmSpacing.step(run,1.0/60)
	var closest:=1000.0
	for e in run.enemies:
		for other in run.enemies:
			if e.id!=other.id: closest=minf(closest,Vector2(e.pos).distance_to(other.pos))
	check(closest>27,"Coincident pack spreads into separate bodies")
	var anchor: Dictionary=run.enemies[0]; anchor.phase="aim"
	var before: Vector2=anchor.pos; run.enemies[1].pos=anchor.pos
	SwarmSpacing.step(run,0.1)
	check(anchor.pos==before,"Attack windup stays fixed while neighbors yield")
	run.exp.practice=true; run.vanguard.freeze_ai=true
	before=run.enemies[1].pos; SwarmSpacing.step(run,0.1)
	check(run.enemies[1].pos==before,"Practice freeze also freezes spacing")
	run.vanguard.freeze_ai=false; run.enemies.clear()
	var wall_x: float=run.player.x+250
	run.kit.extra.walls.append({"a":Vector2(wall_x,run.player.y-200),"b":Vector2(wall_x,run.player.y+200),"width":100.0,"life":9999.0})
	run.spawn_enemy(run.player+Vector2(160,0),0); run.spawn_enemy(run.player+Vector2(180,0),0)
	for i in range(60): SwarmSpacing.step(run,1.0/60)
	check(run.enemies.all(func(e): return Vanguard.valid_point(run,e.pos,e.radius) and e.pos.x<wall_x),"Crowd pressure cannot push bodies through walls")
	run.kit.extra.walls.clear(); run.enemies.clear()
	for i in range(180): run.spawn_enemy(run.player+Vector2((i%18)*20,(i/18)*20),0)
	var started:=Time.get_ticks_usec()
	for i in range(60): SwarmSpacing.step(run,1.0/60)
	print("SWARM 180 average spacing us: ",(Time.get_ticks_usec()-started)/60)
	check(run.enemies.all(func(e): return Vanguard.valid_point(run,e.pos,e.radius)),"Separated crowd remains in bounds")
	if "--render" in OS.get_cmdline_user_args():
		var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
		root.add_child(game); await process_frame; game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
		game.launch_practice(); game.close_practice(); game.model.enemies.clear(); game.model.kit.extra.walls.clear()
		for i in range(45):
			game.model.spawn_enemy(game.model.player+Vector2(140+(i%9)*12,-70+(i/9)*12),0)
		for i in range(180): SwarmSpacing.step(game.model,1.0/60)
		for enemy in game.model.enemies: enemy.warmup=0
		game.ui.update_hud(game.model); game.art.queue_redraw()
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/swarm-spacing.png")
		game.queue_free(); await process_frame
	print("SWARM PRESSURE: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
