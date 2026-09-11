extends SceneTree
var checks:=0
var failures:=0
func check(ok: bool, label: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(label)
func fresh(rank_value: int=1) -> SalvageRun:
	var run:=SalvageRun.new(7127); run.loot_rng.seed=8028
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
	BotExpedition.new().start(run,"ranged",0); run.exp.enable_revision(run)
	Vanguard.setup(run,rank_value); ReviewRules.enable(run); OperationRules.enable(run,1); LevelMastery.enable(run)
	run.kit.loadout.support23=true; run.kit.loadout.arsenal26=true; run.kit.extra.walls.clear(); run.enemies.clear()
	return run
func _initialize() -> void: execute.call_deferred()
func execute() -> void:
	var run:=fresh(); var v=run.vanguard
	check(v.cast(run,"x3",run.player),"Barrage activates")
	check(v.burst_left==8 and run.kit.recharge.x3==60 and v.constructs.is_empty(),"Eight-second buff, sixty-second cooldown, no totem")
	run.kit.energy=200
	var normal: int=run.kit.charges.q; var energy: float=run.kit.energy
	check(v.cast(run,"q",run.player+Vector2.RIGHT*400),"First barrage shot")
	check(not v.cast(run,"q",run.player+Vector2.RIGHT*400),"Cannot fire faster than 0.3 seconds")
	check(run.projectiles.back().mini_rocket and run.projectiles.back().milestone==0,"Small rockets have no rank-ten aftershock")
	var count:=1
	for i in range(799):
		v.tick(run,0.01)
		if v.cast(run,"q",run.player+Vector2.RIGHT*400): count+=1
	check(count==27,"Unlimited mode permits 27 paced shots in eight seconds")
	check(run.kit.charges.q==normal and run.kit.energy==energy-135,"Barrage preserves normal charges and spends five energy per rocket")
	v.burst_clock=0; run.kit.energy=4
	check(not v.cast(run,"q",run.player+Vector2.RIGHT*400) and run.kit.energy==4,"Barrage cannot fire below five energy")
	v.tick(run,0.02); check(v.burst_left==0,"Mode expires")
	for rank_value in [1,5,10]:
		var ratio:=27*23*ArsenalBurst.scale(rank_value)/135.0
		check(ratio>1 and ratio<1.25,"Equal-rank full burst modestly exceeds R")
	run=fresh(10); v=run.vanguard
	var low:=fresh(1)
	check(run.kit.cast_range("e")==low.kit.cast_range("e") and run.kit.damage_scale("e")==low.kit.damage_scale("e"),"E ranks do not increase range or impact damage")
	check(run.kit.cooldown("e")<low.kit.cooldown("e"),"E ranks improve recharge")
	run.kit.charges.e=4; run.kit.step(run,0.01)
	check(run.kit.charges.e==4,"Rank ten stores four E charges")
	v.cast(run,"e",run.player+Vector2.RIGHT*500); v.hammer_cooldown=10
	check(v.swing(run,run.player+Vector2.RIGHT),"Spin buffers even during hammer cooldown")
	v.tick(run,0.23)
	check(v.impacts.any(func(x): return x.kind=="hammer") and not v.buffered_hammer,"Buffered spin commits on landing")
	check(v.shield==0,"E grants no shield")
	run=fresh(10); v=run.vanguard; run.kit.charges.e=4; run.kit.energy=200
	v.cast(run,"e",run.player+Vector2.RIGHT*500)
	check(v.cast(run,"e",run.player+Vector2.RIGHT*900) and run.kit.charges.e==3,"E queues without spending its next charge early")
	v.tick(run,0.23)
	check(v.slam_left>0 and run.kit.charges.e==2 and not v.buffered_e,"Buffered E starts on arrival and spends one charge")
	v.tick(run,0.23)
	check(v.slam_left==0 and run.kit.charges.e==2,"One buffer does not repeat indefinitely")
	run=fresh(10); v=run.vanguard; v.cast(run,"e",run.player+Vector2.RIGHT*500); v.tick(run,1)
	check(v.combo_left<=0.1,"Arrival combo window is strict")
	v.tick(run,0.11); v.swing(run,run.player+Vector2.RIGHT)
	check(not v.spin_swing and not v.combo_swing,"Late click is ordinary hammer")
	run=fresh(); v=run.vanguard; run.player=Vector2(run.ARENA.end.x-40,300)
	v.cast(run,"e",run.player+Vector2.RIGHT*500); v.tick(run,0.1)
	check(v.slam_bounced and v.slam_direction.x<0 and Vanguard.valid_point(run,run.player,16),"E rebounds from arena edge")
	run=fresh(); var hatch:=RangedThreats.spawn(run,"hatchery",run.player+Vector2(300,0),true); hatch.warmup=0
	SupportEnemies.step(run,hatch,8)
	check(run.enemies.filter(func(x): return x.get("hatch_parent",-1)==hatch.id).size()==4,"Hatchery spawns four pursuers")
	for i in range(8): SupportEnemies.step(run,hatch,8)
	check(run.enemies.filter(func(x): return x.get("hatch_parent",-1)==hatch.id).size()==16,"Hatchery respects living-child cap")
	var aura:=RangedThreats.spawn(run,"uplink",hatch.pos+Vector2(80,0),true); aura.warmup=0; hatch.hp=20
	SupportEnemies.prepare(run,1); check(hatch.hp>20 and hatch.aura_left==3,"Aura heals and applies speed")
	aura.pos=run.player+Vector2(-1000,0); SupportEnemies.prepare(run,1)
	check(hatch.aura_left==2,"Speed decays outside aura")
	SupportEnemies.prepare(run,3); check(hatch.aura_left==0,"Speed bonus expires")
	var before: Dictionary={hatch.id:hatch.pos}; var start: Vector2=hatch.pos
	hatch.pos+=Vector2.RIGHT*10; hatch.aura_left=3; SupportEnemies.movement(run,before)
	check(is_equal_approx(hatch.pos.x-start.x,13),"Aura adds thirty percent actual movement")
	run=fresh(); run.spawn_enemy(run.player+Vector2(300,0),0)
	var boss: Dictionary=run.enemies.back(); boss.max_hp=100000; boss.hp=100000
	ReviewEnemies.boss(run,boss,0)
	boss.phase="telegraph"; boss.attack="sweep"; boss.clock=0; boss.dir=Vector2.RIGHT; boss.summon_clock=100
	ReviewEnemies.boss(run,boss,0)
	check(boss.clock==4,"Full sweep has four seconds of active laser")
	for i in range(400): ReviewEnemies.boss(run,boss,0.01)
	check(Vector2(boss.dir).distance_to(Vector2.RIGHT)<0.001,"Laser rotates one complete circle")
	run=fresh(10); run.state="camp"; run.exp.clear_clock=-2
	var forge:=ForgeEquipment.new(); check(forge.bank_camp(run,false),"Arsenal checkpoint banks in memory")
	var resumed:=fresh(); check(forge.resume_into(resumed) and ArsenalBurst.enabled(resumed) and resumed.kit.charges.e==4,"Checkpoint restores arsenal rules and four E charges")
	var old: Dictionary=forge.checkpoint.duplicate(true); old.loadout.erase("arsenal26")
	check(ForgeEquipment.valid_checkpoint(old),"Older support checkpoint remains valid")
	run=fresh(); v=run.vanguard; v.burst_left=8; v.emp_left=3
	check(v.cast(run,"q",run.player+Vector2.RIGHT*300) and run.kit.charges.q==1,"EMP leaves ordinary Q usable, suppressing barrage")
	run=fresh(); v=run.vanguard; run.kit.charges.e=1
	v.cast(run,"e",run.player+Vector2.RIGHT*500); v.cast(run,"e",run.player+Vector2.RIGHT*900); v.tick(run,0.23)
	check(v.slam_left==0 and not v.buffered_e and run.kit.charges.e==0,"Unavailable buffered E is dropped without debt")
	if "--render" in OS.get_cmdline_user_args():
		var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
		root.add_child(game); await process_frame; game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
		game.launch_practice(); game.close_practice(); game.model.enemies.clear()
		for i in range(2):
			var foe:=RangedThreats.spawn(game.model,"hatchery" if i==0 else "uplink",game.model.player+Vector2(-160 if i==0 else 160,-140),true); foe.warmup=0
		game.model.vanguard.burst_left=8; game.model.vanguard.burst_clock=0
		ArsenalBurst.fire(game.model,game.model.player+Vector2(400,0))
		game.model._projectile_step(0.15)
		game.model.vanguard.spin_swing=true; game.model.vanguard.hit_hammer(game.model)
		game.ui.update_hud(game.model); game.art.queue_redraw()
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/arsenal26.png")
		game.art.reduced_effects=true; game.art.queue_redraw()
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/arsenal26-reduced.png")
		game.queue_free(); await process_frame
	print("ARSENAL26: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
