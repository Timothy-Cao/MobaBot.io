extends SceneTree
var checks:=0
var failures:=0
func check(ok: bool, label: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(label)
func fresh() -> SalvageRun:
	var run:=SalvageRun.new(7127); run.loot_rng.seed=8028
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
	BotExpedition.new().start(run,"ranged",0); run.exp.enable_revision(run)
	Vanguard.setup(run,1); ReviewRules.enable(run); OperationRules.enable(run,1); LevelMastery.enable(run); run.kit.loadout.support23=true
	run.kit.extra.walls.clear(); run.enemies.clear(); run.player=Vector2(480,300)
	return run
func _initialize() -> void: execute.call_deferred()
func execute() -> void:
	var run:=fresh()
	check(run.attacks.auto_range(run)==340,"Base gun range")
	run.upgrades.power=4; check(run.attacks.auto_range(run)==425,"Rank five adds 25 percent range")
	run.upgrades.power=9; Vanguard.gun_bullet(run,run.player,Vector2.RIGHT,2,425,4,"bolt",9)
	check(run.projectiles.back().pierce==2 and run.projectiles.back().damage==2,"Rank ten has exactly three total hits without old double damage")
	for i in range(4):
		run.spawn_enemy(run.player+Vector2(60+i*65,0),0); run.enemies.back().warmup=0; run.enemies.back().hp=100
	run._projectile_step(0.15)
	check(run.enemies.filter(func(e): return e.hp<100).size()==3,"Piercing shot hits three enemies, not four")
	run=fresh(); run.spawn_enemy(run.player+Vector2(80,80),0); run.enemies.back().warmup=0
	var bug:=RangedThreats.spawn(run,"mosquito",run.player+Vector2(300,0),true); bug.warmup=0
	ReviewRules.scale_role(run,bug); check(bug.hp<20,"Mosquito avoids tank W health floor")
	run.attacks._fire_auto(run)
	check(not run.projectiles.is_empty() and run.projectiles.back().get("tracking_target",-1)==bug.id,"Gun prioritizes farther mosquito")
	var hp: float=bug.hp
	for i in range(16): Mosquito.step(run,bug,0.01); run._projectile_step(0.01)
	check(bug.hp<hp,"Fast tracking gun lands against moving mosquito")
	run=fresh(); bug=RangedThreats.spawn(run,"mosquito",run.player+Vector2(300,0),true); bug.warmup=0
	var center: Vector2=bug.pos
	run.vanguard.impacts.append({"kind":"strike","pos":center,"radius":100.0,"life":0.55})
	for i in range(40): Mosquito.step(run,bug,0.01)
	check(Vector2(bug.pos).distance_to(center)>112,"Mosquito leaves isolated W zone")
	check(Vanguard.valid_point(run,bug.pos,bug.radius),"Dodge remains within arena")
	MobaKit.area(run,bug.pos,100,100,"strike",0); check(bug.dead,"Point-blank damage still hits; no immunity")
	check(not Mosquito.wave(1,0,3) and Mosquito.wave(1,1,3),"Introduced after first round")
	check(Mosquito.wave(3,0,2) and not Mosquito.wave(2,0,2),"Level three has more mosquito waves")
	run=fresh(); run.boss_spawned=true; run.boss_defeated=false
	run.stage_time=run.exp.round_seconds()+60
	check(ReviewRules.boss_deadline(run)==60 and ReviewRules.enrage_multiplier(run)==1,"Enrage starts without a damage jump")
	run.stage_time+=60; check(is_equal_approx(ReviewRules.enrage_multiplier(run),1.5),"Damage ramps slowly over next minute")
	run.stage_time+=60; check(is_equal_approx(ReviewRules.enrage_multiplier(run),2),"Damage continues ramping")
	if "--render" in OS.get_cmdline_user_args():
		var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
		root.add_child(game); await process_frame; game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
		game.launch_practice(); game.close_practice()
		for i in range(3):
			var foe:=RangedThreats.spawn(game.model,"mosquito",game.model.player+Vector2.from_angle(i*TAU/3)*240,true); foe.warmup=0
		game.model.upgrades.power=9; game.ui.update_hud(game.model); game.art.queue_redraw()
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/mosquito25.png")
		game.art.reduced_effects=true; game.art.queue_redraw()
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/mosquito25-reduced.png")
		game.queue_free(); await process_frame
	print("MOSQUITO25: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
