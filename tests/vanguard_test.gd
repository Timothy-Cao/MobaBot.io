extends SceneTree
var failures:=0
var checks:=0
func check(value: bool, message: String) -> void:
	checks+=1
	if not value: failures+=1; push_error(message)
func fresh(rank_value: int=1) -> SalvageRun:
	var run:=SalvageRun.new(17017)
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
	BotExpedition.new().start(run,"ranged",0); BotKeyboard.enable(run); run.exp.enable_revision(run)
	Vanguard.setup(run,rank_value); run.kit.extra.walls.clear(); run.exp.practice=true; run.exp.god_mode=false; run.exp.free_energy=false
	return run
func _initialize() -> void: execute.call_deferred()
func execute() -> void:
	var run:=fresh(0)
	check(run.kit.discovered==["q","d","f"],"Starter fixed kit")
	check(run.passive_enabled("bolt") and BotKeyboard.learned(run.kit,"bolt")=="","Permanent gun consumes no slot")
	run.exp.practice=false; run.total_xp=run.next_level
	Vanguard.progression(run)
	check(run.state=="running" and run.level==2 and Vanguard.reward_kind(run)=="upgrade","XP non-modal")
	check(not Vanguard.spend(run,"w"),"Cannot learn during upgrade")
	check(Vanguard.spend(run,"q") and run.kit.ranks.q==2,"Spend owned rank")
	Vanguard.earn(run)
	check(Vanguard.reward_kind(run)=="learn" and Vanguard.spend(run,"w"),"Alternating learn")
	var gear:=ForgeEquipment.new()
	run.state="camp"
	var packed:=gear.pack_run(run)
	check(ForgeEquipment.valid_checkpoint(packed),"New checkpoint validates")
	gear.checkpoint=packed
	var restored:=fresh()
	check(gear.resume_into(restored) and Vanguard.enabled(restored) and restored.kit.ranks.w==1,"Fixed kit roundtrip")
	var bad:=packed.duplicate(true); bad.loadout.rewards18=["cheat"]
	check(not ForgeEquipment.valid_checkpoint(bad),"Malformed queue rejected")
	bad=packed.duplicate(true); bad.bindings=1
	check(not ForgeEquipment.valid_checkpoint(bad),"Malformed fixed bindings rejected without exceptions")
	run=fresh(5)
	run.spawn_enemy(run.player+Vector2(120,0),3); run.enemies[0].warmup=0; run.enemies[0].hp=10000; run.enemies[0].max_hp=10000
	run.vanguard.cast(run,"d",run.player)
	check(run.vanguard.ghost and not run.vanguard.cast(run,"q",run.player+Vector2(100,0)),"D prevents active casts")
	run.attacks.stop(run); run.attacks.fire(run)
	check(run.attacks.auto_shots==1,"D/S never stop gun")
	run.vanguard.ghost=false
	run.projectiles.clear()
	var before: Vector2=run.player
	check(run.vanguard.cast(run,"q",before+Vector2(400,0)),"Queue Q")
	check(run.vanguard.cast(run,"f",before+Vector2(100,100)),"Blink in cast buffer")
	run.vanguard.tick(run,0.081)
	check(run.projectiles.size()==1 and run.projectiles[0].pos==run.player and run.player!=before,"Q release from blink endpoint")
	check(run.kit.cast_counts.rocket==1 and run.kit.cast_counts.blink==1,"Costs and counts once")
	run=fresh()
	var p: Vector2=run.player
	run.kit.extra.walls.append({"uid":-1,"a":p+Vector2(200,-150),"b":p+Vector2(200,150),"width":170.0,"life":9999.0,"terrain":true})
	var far:=Vanguard.blink_target(run,p+Vector2(220,0))
	var near:=Vanguard.blink_target(run,p+Vector2(180,0))
	check(far.x>p.x+385 and Vanguard.valid_point(run,far,16),"Past-half thick blink exits far side")
	check(near.x<p.x+15 and Vanguard.valid_point(run,near,16),"Near half stays near side")
	run=fresh(5); run.vanguard.touch_guard=1
	var hp: float=run.health
	run.hurt_player(run.player,"touch",1,"touch")
	check(run.health==hp,"Slam contact guard")
	run.hurt_player(run.player,"projectile",1,"projectile")
	check(run.health<hp,"Projectile bypasses contact guard")
	run.vanguard.shield=1; hp=run.health; run.hurt_player(run.player,"ground",1,"ground")
	check(run.health==hp,"Full shield blocks ground")
	run=fresh(5)
	run.spawn_enemy(run.player+Vector2(95,0),3); run.enemies[0].warmup=0; run.enemies[0].hp=1000
	check(run.vanguard.swing(run,run.player+Vector2(95,0)),"Hammer starts")
	run.vanguard.tick(run,0.21)
	check(run.damage_dealt.get("hammer",0)>30,"Hammer head payoff")
	run=fresh(5)
	run.spawn_enemy(run.player+Vector2(95,0),3); run.enemies[0].warmup=0; run.enemies[0].hp=1000
	check(run.vanguard.cast(run,"e",run.player+Vector2(200,0)),"Slam begins")
	for i in range(15): run.vanguard.tick(run,1.0/60)
	check(run.damage_dealt.get("body_slam",0)>0 and run.vanguard.slam_left==0,"Slam first contact impact")
	run=fresh(5)
	check(run.vanguard.cast(run,"x3",run.player),"Recovery deployment")
	check(run.vanguard.powered(run),"Inside recovery aura")
	run.vanguard.tick(run,4)
	check(run.kit.charges.x3==0 and run.kit.recharge.x3==run.kit.cooldown("x3"),"Totem cooldown waits for expiry")
	run.player+=Vector2(400,0)
	check(not run.vanguard.powered(run),"Aura benefit stays local")
	for rank_value in [1,5,10]:
		for slot in ["q","w","e","r","x1","x2","x3"]:
			run=fresh(rank_value); run.exp.free_energy=true
			run.spawn_enemy(run.player+Vector2(160,0),3); run.enemies[0].warmup=0; run.enemies[0].hp=10000; run.enemies[0].max_hp=10000; run.enemies[0]["dummy"]=true
			check(run.vanguard.cast(run,slot,run.enemies[0].pos),"Cast %s rank %d"%[slot,rank_value])
			for tick in range(120): run.step(1.0/60,Vector2.ZERO); run.events.clear()
			check(is_finite(run.health) and run.vanguard.impacts.size()<30,"Bounded complete simulation")
			if slot in ["q","w","e","r"]: check(run.damage_dealt.size()>1,"Skill damage lands")
	run=fresh(5); run.exp.practice=false; run.exp.god_mode=false
	run.spawn_enemy(run.player+Vector2(60,0),0); run.enemies[0].warmup=0
	run.hit_enemy(run.enemies[0],100,"test")
	check(not run.pickups.is_empty(),"Campaign still awards loot")
	run=fresh(5); run.spawn_enemy(run.player+Vector2(60,0),0); run.enemies[0].warmup=0
	run.hit_enemy(run.enemies[0],100,"test")
	check(run.pickups.is_empty() and run.supply_drops.is_empty() and run.total_xp==0,"Practice kills award nothing")
	run=fresh(5); run.exp.practice=false; run.exp.encounter_spawned=true; run.stage_time=180
	run.exp.finish_step(run,0.1)
	check(run.exp.clear_clock>11,"Vanguard keeps collection window")
	run.exp.finish_step(run,12)
	check(run.state=="camp" and run.exp.pending_chests==0 and run.kit.loadout.rewards18.size()>0,"Camp rewards queued without popup")
	check(ForgeEquipment.valid_checkpoint(gear.pack_run(run)),"End-round save validates")
	await ui_checks()
	print("VANGUARD: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)

func ui_checks() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate()
	game.persist_settings=false; game.mute_setting=true
	root.add_child(game); await process_frame; game.set_physics_process(false)
	var before:=JSON.stringify(game.collection.snapshot())
	game.launch_practice(); await process_frame
	check(game.screen=="practice" and Vanguard.enabled(game.model),"Practice fixed-kit default")
	game.practice_page="Enemies"; PracticeSandbox.draw(game); await process_frame
	game.practice_enemy="bumper"; game.practice_count=10; game.practice_formation="Cluster"
	var point: Vector2=game.model.player+Vector2(600,0)
	check(PracticeSandbox.place(game,point) and game.model.enemies.size()==10,"World cluster placement")
	check(not PracticeSandbox.place(game,point),"Reject overlapping batch atomically")
	game.practice_clear(); check(game.model.enemies.is_empty() and game.model.vanguard.constructs.is_empty(),"Clear simulation")
	check(JSON.stringify(game.collection.snapshot())==before,"Practice collection unchanged")
	Vanguard.setup(game.model,5); game.close_practice()
	Vanguard.earn(game.model); game.ui.update_hud(game.model)
	var event:=InputEventKey.new(); event.keycode=KEY_D; event.pressed=true
	game._input(event); check(game.model.vanguard.ghost,"D key down starts drive")
	event.pressed=false; game._input(event); check(not game.model.vanguard.ghost,"D key up stops drive")
	event.keycode=KEY_Q; event.pressed=true; event.ctrl_pressed=true
	game._input(event); check(game.model.kit.ranks.q==6 and game.model.vanguard.pending.is_empty(),"Ctrl-Q upgrades without casting")
	if "--render" in OS.get_cmdline_user_args():
		DirAccess.make_dir_recursive_absolute("res://output/vanguard")
		await process_frame; await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/vanguard/hud.png")
		game.model.spawn_enemy(game.model.player+Vector2(190,0),3)
		var dummy: Dictionary=game.model.enemies.back(); dummy["dummy"]=true
		game.model.hit_enemy(dummy,38,"q"); game.model.practice_meter.tick(1); game.model.hit_enemy(dummy,76,"w")
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/vanguard/dummy.png")
		game.art.reduced_effects=true
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/vanguard/dummy-reduced.png")
		game.art.reduced_effects=false
		game.model.enemies.clear(); game.model.practice_meter.clear()
		game.open_practice(); game.practice_page="Enemies"; PracticeSandbox.draw(game)
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/vanguard/practice.png")
		game.close_practice(); game.model.kit.extra.walls.clear()
		for reduced in [false,true]:
			game.art.reduced_effects=reduced
			for slot in ["q","w","e","r","x1","x2","x3"]:
				game.model.projectiles.clear(); game.model.orbit.clear(); game.art.effects.clear(); game.model.player=Vector2(480,300); game._update_camera()
				Vanguard.setup(game.model,10); game.model.kit.energy=100; game.model.vanguard.cast(game.model,slot,game.model.player+Vector2(160,0))
				game.model.vanguard.tick(game.model,0.12)
				game.ui.update_hud(game.model)
				await process_frame; await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("res://output/vanguard/%s-%s.png"%[slot,"reduced" if reduced else "normal"])
	game.queue_free(); await process_frame
