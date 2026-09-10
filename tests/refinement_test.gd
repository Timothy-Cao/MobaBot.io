extends SceneTree
var checks:=0
var failures:=0
func check(value: bool, message: String) -> void:
	checks+=1
	if not value: failures+=1; push_error(message)
func fresh() -> SalvageRun:
	var run:=SalvageRun.new(17017)
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo()
	run.attacks.enabled=true; run.kit.starting_gun=true; run.kit.onboarding=true
	BotExpedition.new().start(run,"ranged",0); BotKeyboard.enable(run); run.exp.enable_revision(run)
	return run
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var run:=fresh()
	check(run.exp.class_id=="shared" and run.exp.round_seconds()==180,"Shared pool and three-minute round")
	check(run.next_level==10,"Initial XP +25%")
	var previous:=1.25
	for level in range(1,101):
		var factor:=BotExpedition.xp_factor(level)
		check(factor>=previous and factor<=1.75,"Smooth monotone XP cap")
		previous=factor
	check(is_equal_approx(BotExpedition.xp_factor(20),1.5),"Mid-curve +50%")
	check(run.kit.extra.walls.size()>40,"Distributed terrain")
	for index in range(20):
		var point:=Vector2(-1700+(index%5)*950,-1050+(index/5)*800)
		var target:=Vector2(2600-(index%5)*900,1500-(index/5)*700)
		point=run.kit.extra.solid_point(point,point,16); target=run.kit.extra.solid_point(target,target,16)
		for tick in range(1600):
			var next:=point.move_toward(run.kit.extra.route(point,target,16),7)
			point=run.kit.extra.solid_point(point,next,16)
			if point.distance_to(target)<3: break
		if point.distance_to(target)>=3: print("ROUTE_STUCK ",index," ",point," target=",target," next=",run.kit.extra.route(point,target,16))
		check(point.distance_to(target)<3,"Cross-map terrain route %d"%index)
	for wall in run.kit.extra.walls:
		check(Geometry2D.get_closest_point_to_segment(run.player,wall.a,wall.b).distance_to(run.player)>100,"Safe player start")
	run.exp.spawns(run,0.1); run.stage_time=179.9; run.exp.spawns(run,0.1)
	check(not run.exp.encounter_spawned,"No early mini-boss")
	run.stage_time=180; run.exp.spawns(run,0.1)
	check(run.exp.encounter_spawned and run.enemies.any(func(e):return e.has("role")),"Miniboss at 180 seconds")
	for e in run.enemies: e.dead=true
	run.exp.finish_step(run,0.1)
	check(run.state=="running" and run.exp.clear_clock>11,"Collection starts without a modal")
	run.total_xp=1000; run.exp.pending_chests=2
	run.exp.finish_step(run,5)
	check(run.state=="running","XP/chests don't interrupt collection")
	run.exp.finish_step(run,7)
	check(run.state=="camp","Collection reaches camp")
	check(not BotKeyboard.place(run,"laser",KEY_Q),"Discoveries never overwrite occupied slots")
	run.kit.ranks.q=7; run.upgrades.skill_q=7
	SkillLibrary.remember(run.kit,"laser",3,1)
	check(SkillLibrary.equip(run,"laser",KEY_Q),"Explicit camp fit")
	check(SkillLibrary.stored(run.kit,"rocket") and run.kit.loadout.library.rocket.rank==7,"Old Q retained at rank seven")
	check(SkillLibrary.equip(run,"rocket",KEY_Q) and run.kit.ranks.q==7,"Restore original Q rank")
	var gear:=ForgeEquipment.new()
	gear.checkpoint=gear.pack_run(run)
	check(ForgeEquipment.valid_checkpoint(gear.checkpoint),"Shared class/library checkpoint validates")
	var resumed:=fresh()
	check(gear.resume_into(resumed) and resumed.exp.revised and SkillLibrary.stored(resumed.kit,"laser"),"Library survives resume")
	var malformed: Dictionary=gear.checkpoint.duplicate(true)
	malformed.loadout.library.laser.rank=999
	check(not ForgeEquipment.valid_checkpoint(malformed),"Reject invalid stored rank")
	run=fresh(); run.exp.practice=true; run.kit.extra.walls.clear(); run.kit.toggles.fill(false)
	run.spawn_enemy(run.player+Vector2(300,0),3)
	var enemy: Dictionary=run.enemies.back(); enemy.warmup=0; enemy.hp=10000; enemy.max_hp=10000; enemy["dummy"]=true
	run.attacks.attack(run,enemy)
	for i in range(10): run.step(1.0/60,Vector2.ZERO)
	check(run.attacks.shots==0,"Basic has a real windup")
	run.command_move(run.player+Vector2(0,100)); run.step(1.0/60,Vector2.ZERO)
	check(run.attacks.shots==0 and run.attacks.windup<0,"Movement cancels windup")
	run.attacks.attack(run,enemy)
	for i in range(90): run.step(1.0/60,Vector2.ZERO)
	check(run.attacks.shots==1 and enemy.hp<10000,"Heavy basic fired and hit")
	check(is_equal_approx(run.attacks.auto_damage(run)/run.attacks.auto_interval(run),7.5),"MG 20% nerf")
	check(is_equal_approx(run.attacks.damage(run)/run.attacks.interval(run),14.0625),"Basic theoretical DPS")
	check(run.attacks.attack_range(run)==run.attacks.auto_range(run)*2,"Double base range")
	run.kit.toggles[0]=true; enemy.pos=run.player+Vector2(100,0); run.attacks.stop(run)
	for i in range(40): run.step(1.0/60,Vector2.ZERO)
	check(run.attacks.auto_shots>0,"S doesn't stop autonomous gun")
	for type in RangedThreats.NAMES:
		run=fresh(); run.exp.practice=true; run.kit.extra.walls.clear(); run.kit.toggles.fill(false)
		var threat:=RangedThreats.spawn(run,type,run.player+Vector2(230,0),true)
		threat.warmup=0; threat.clock=0
		for i in range(100): run._enemy_step(1.0/60)
		check(threat.phase!="seek",type+" enters attack cycle")
		if type=="volley": check(run.projectiles.size()==5,"Five-round sweep burst")
		if type=="bomber": check(run.hazards.size()==3,"Three bomb tells")
		if type=="lancer": check(run.health==run.max_health(),"Practice god mode prevents laser damage")
	var image:=Image.load_from_file("res://assets/menu/menu-bot-v2.png")
	check(image.has_mipmaps()==false and image.detect_alpha()!=Image.ALPHA_NONE,"Robot has real alpha")
	check(image.get_pixel(0,0).a==0 and image.get_pixel(image.get_width()/2,image.get_height()/2).a>0.9,"Transparent outside, opaque subject")
	await ui_test()
	print("REFINEMENT: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)
func ui_test() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate()
	game.persist_settings=false; root.add_child(game); await process_frame
	game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.collection=ForgeEquipment.new()
	game.launch_expedition(); game.model.state="camp"; game.collection.checkpoint=game.collection.pack_run(game.model)
	var saved:=JSON.stringify(game.collection.snapshot())
	game.launch_practice()
	check(game.screen=="practice" and not game.persistent_run(),"Practice isolated")
	game.practice_page="Player"; PracticeSandbox.draw(game)
	await process_frame
	var toggle: Button=game.ui.overlay.find_child("god_mode",true,false)
	var click:=InputEventMouseButton.new(); click.button_index=MOUSE_BUTTON_LEFT; click.position=root.get_final_transform()*toggle.get_global_rect().get_center(); click.global_position=click.position; click.pressed=true
	Input.parse_input_event(click); await process_frame
	click=click.duplicate(); click.pressed=false; Input.parse_input_event(click); await process_frame
	check(not game.model.exp.god_mode,"Practice controls receive real mouse events")
	game.model.exp.god_mode=true
	game.model.kit.loadout.erase("vanguard") # Explicit legacy laboratory regression.
	game.practice_skill="laser"; game.practice_key=KEY_Q; game.practice_rank=5; game.practice_fit()
	check(BotKeyboard.id_at(game.model.kit,BotKeyboard.slot_at(game.model.kit,KEY_Q))=="laser","Practice fits chosen loadout")
	game.practice_enemy="volley"; game.practice_count=5; game.practice_spawn()
	check(game.model.enemies.size()==5 and game.screen=="running","Practice horde spawn resumes play")
	var event:=InputEventKey.new(); event.keycode=KEY_TAB; event.pressed=true
	game._input(event); check(game.screen=="practice","Tab opens practice")
	event.pressed=false; game._input(event); check(game.screen=="practice","Tab release does not close")
	event.pressed=true; game._input(event); check(game.screen=="running","Second Tab closes")
	check(JSON.stringify(game.collection.snapshot())==saved,"Practice preserves real checkpoint and collection")
	game.open_practice()
	if "--render" in OS.get_cmdline_user_args():
		await create_timer(0.4).timeout; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/practice17.png")
		game.show_home(); await create_timer(0.4).timeout; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/menu17.png")
		game.launch_practice(); game.practice_clear(); game.model.kit.extra.walls.clear()
		for i in range(3):
			var e:=RangedThreats.spawn(game.model,RangedThreats.NAMES.keys()[i],game.model.player+Vector2(200,-110+i*95),true)
			e.warmup=0; e.clock=0; RangedThreats.step(game.model,e,0.01)
		game.close_practice(); game.ui.update_hud(game.model)
		await create_timer(0.2).timeout; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/threats17.png")
		game.art.reduced_effects=true
		await create_timer(0.2).timeout; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/threats17-reduced.png")
	game.queue_free(); await process_frame
