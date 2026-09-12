extends "res://tests/demo_pacing_test.gd"
func execute() -> void:
	var run:=fresh(); run.kit.extra.walls.clear()
	check(not DemoPacing.INTRO.has("emp") and not DemoPacing.INTRO.has("uplink"),"Retired enemies absent from demo roster")
	run.stage_time=180; run.exp.spawns(run,0)
	check(run.enemies.filter(func(e): return e.has("miniboss")).size()==1 and not run.exp.encounter_spawned,"Mid-stage miniboss does not replace guardian")
	run.exp.spawns(run,0)
	check(run.enemies.filter(func(e): return e.has("miniboss")).size()==1,"Mid-stage encounter cannot duplicate")
	var ram: Dictionary=run.enemies.filter(func(e): return e.has("miniboss"))[0]
	ram.phase="attack"; ram.attack="ram"; ram.clock=0.85; ram.dir=Vector2.RIGHT; ram.struck=false
	run.player=Vector2(ram.pos)+Vector2(0,300)
	var before: Vector2=ram.pos; MinibossEncounters.step(run,ram,0.1)
	check(absf(Vector2(ram.dir).angle())<=0.0451 and Vector2(ram.pos).distance_to(before)>80,"Fast ram has limited turning")
	ram.clock=0; MinibossEncounters.step(run,ram,0.01)
	check(ram.phase=="recover" and ram.clock==1.8,"Charge leaves punish window")
	var b:=RangedThreats.spawn(run,"bulwark",run.player+Vector2(200,0),true)
	var hp: float=b.hp; run.hit_enemy(b,100,"test")
	check(is_equal_approx(hp-b.hp,55),"Guard reduces damage without immunity")
	b.phase="recover"; hp=b.hp; run.hit_enemy(b,100,"test")
	check(is_equal_approx(hp-b.hp,135),"Recovery exposes hull")
	b.phase="approach"; b.clock=0; MinibossEncounters.step(run,b,0.01)
	check(b.attack=="spin" and b.phase=="telegraph","Brawler starts with marked dash-spin")
	b.phase="approach"; b.clock=0; MinibossEncounters.step(run,b,0.01)
	check(b.attack=="ring","Brawler alternates outer shockwave")
	b.phase="attack"; b.clock=0.1; b.struck=false; run.player=b.pos; hp=run.health
	MinibossEncounters.step(run,b,0.01)
	check(run.health==hp and run.projectiles.size()==12,"Inner space avoids ring; projectile ring has gaps")
	var chest_count: int=run.exp.loot_chests.size(); run.hit_enemy(b,100000,"test")
	check(b.dead and run.exp.loot_chests.size()==chest_count+1,"Miniboss awards one in-run chest")
	run=fresh(); run.kit.extra.walls.clear(); run.spawn_enemy(run.player+Vector2(400,0),3)
	var tank: Dictionary=run.enemies.back(); before=tank.pos
	ReviewEnemies.tank(run,tank,0.1)
	check(is_equal_approx(before.distance_to(tank.pos),9.72),"Tank travels at ninety percent of stage-one swarm speed")
	run=fresh(3); run.kit.extra.walls.clear(); DemoCampaign.spawn_special(run,"foreman")
	var boss: Dictionary=run.enemies.back(); boss.exp_boss=3
	ReviewEnemies.boss(run,boss,0)
	boss.phase="attack"; boss.attack="fan"; boss.clock=0.9; boss.shot_clock=0; boss.burst=0; boss.summon_clock=100
	for i in range(28): ReviewEnemies.boss(run,boss,1.0/30)
	check(run.projectiles.size()==36,"Final boss fires four nine-shot fans")
	boss.phase="approach"; boss.sequence=1; boss.clock=0; boss.pos=run.player+Vector2(400,0)
	ReviewEnemies.boss(run,boss,0.01)
	check(boss.attack=="charge" and is_equal_approx(boss.clock,0.45),"Final boss charge warning shortened")
	if "--render" in OS.get_cmdline_user_args(): await render_encounters()
	print("MINIBOSS: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
func render_encounters() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
	root.add_child(game); await process_frame; game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.launch_practice(); game.close_practice(); game.model.enemies.clear(); game.model.kit.extra.walls.clear()
	var a:=RangedThreats.spawn(game.model,"drifter",game.model.player+Vector2(-260,-100),true)
	var b:=RangedThreats.spawn(game.model,"bulwark",game.model.player+Vector2(260,0),true)
	a.warmup=0; a.phase="telegraph"; a.dir=Vector2.DOWN; a.attack="ram"
	b.warmup=0; b.phase="telegraph"; b.attack="ring"
	game.ui.update_hud(game.model); game.art.queue_redraw()
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/minibosses.png")
	game.art.reduced_effects=true; game.art.queue_redraw()
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/minibosses-reduced.png")
	game.queue_free(); await process_frame
