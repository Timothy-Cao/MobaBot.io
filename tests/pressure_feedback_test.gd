extends SceneTree
var checks:=0
var failures:=0
func check(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(message)
func fresh() -> SalvageRun:
	var run:=SalvageRun.new(17017); run.loot_rng.seed=17918
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
	BotExpedition.new().start(run,"ranged",0); BotKeyboard.enable(run); run.exp.enable_revision(run); Vanguard.setup(run,1)
	run.kit.extra.walls.clear()
	return run
func _initialize() -> void: execute.call_deferred()
func execute() -> void:
	var run:=fresh(); var last_hp:=0.0; var last_damage:=0.0; var last_speed:=0.0
	for round_index in range(22):
		run.exp.route_index=round_index
		var hp: float=BotExpedition.stage_health(run.exp.ROUTE[round_index][0])*run.exp.round_health()
		var damage: float=run.exp.incoming(run,1)
		check(hp>last_hp and damage>last_damage,"Every round increases health and damage")
		check(run.exp.enemy_speed(run)>=last_speed and run.exp.enemy_speed(run)<=1.18,"Speed growth bounded")
		check(run.exp.round_seconds()==120,"Every revised round has two-minute survival")
		last_hp=hp; last_damage=damage; last_speed=run.exp.enemy_speed(run)
	run=fresh(); run.stage_time=119.99; run.exp.spawns(run,0)
	check(not run.exp.encounter_spawned,"No early guardian")
	run.stage_time=120; run.exp.spawns(run,0)
	check(run.exp.encounter_spawned,"Guardian spawns at two minutes")
	for kind in ["breacher","mender","scatter"]:
		run=fresh(); var foe:=RangedThreats.spawn(run,kind,run.player+Vector2(240,0),true)
		var base: float=foe.hp; run._enemy_step(0)
		check(is_equal_approx(foe.hp,base*1.1),"New specialist receives common HP rule once")
		run._enemy_step(0); check(is_equal_approx(foe.hp,base*1.1),"No compounded scaling")
		foe.clock=0; FieldEnemies.step(run,foe,0)
		check(foe.phase=="aim" and foe.clock==0.65,"Visible specialist windup")
		FieldEnemies.step(run,foe,0.66)
		check(foe.phase in ["rush","recover","repair"],"Windup resolves to role")
		if kind=="scatter":
			check(run.projectiles.size()==7,"Seven-shot spread")
			for bullet in run.projectiles: check(bullet.life==2.0 and bullet.damage==1,"Bounded lifetime and actual projectile damage")
		if kind=="breacher":
			var health: float=run.health
			FieldEnemies.step(run,foe,0.6)
			check(run.health<health and foe.hit_player,"Swept rush contact deals damage")
			var after: float=run.health; FieldEnemies.step(run,foe,0.1)
			check(run.health==after,"Same rush cannot multi-hit")
	# Mender heals at most three damaged non-boss allies; never itself or another mender.
	run=fresh(); var mender:=RangedThreats.spawn(run,"mender",run.player+Vector2(300,0),true)
	for i in range(4):
		run.spawn_enemy(mender.pos+Vector2(0,40+i*25),0); run.enemies.back().hp=5; run.enemies.back().max_hp=100
	var other:=RangedThreats.spawn(run,"mender",mender.pos+Vector2(70,0),true); other.hp=1
	mender.phase="aim"; mender.clock=0; FieldEnemies.step(run,mender,0.01)
	check(mender.links.size()==3 and run.enemies[1].hp==13 and run.enemies[4].hp==5 and other.hp==1,"Repair caps count/amount and excludes menders")
	run=fresh(); RangedThreats.spawn(run,"mender",run.player+Vector2(300,0))
	check(RangedThreats.spawn(run,"mender").is_empty(),"Campaign allows one Mender at a time")
	for i in range(8): RangedThreats.spawn(run,"scatter")
	check(run.enemies.size()==3,"Stage one specialist cap")
	run=fresh(); run.exp.route_index=21
	for i in range(9): RangedThreats.spawn(run,"scatter")
	check(run.enemies.size()==5,"Late specialist cap")
	# Collision remains body-only, including at deliberately long frame times.
	for dt in [0.016,0.1,0.6]:
		run=fresh(); var start: Vector2=run.player+Vector2(-200,0)
		var charger:=RangedThreats.spawn(run,"breacher",start,true)
		run.kit.extra.walls.append({"a":start+Vector2(100,-100),"b":start+Vector2(100,100),"width":30,"life":100})
		charger.phase="rush"; charger.clock=0.6; charger.dir=Vector2.RIGHT
		for i in range(ceili(0.6/dt)): FieldEnemies.step(run,charger,dt)
		check(charger.pos.x<start.x+50,"Breacher cannot tunnel through wall")
	run=fresh(); var attached:=RangedThreats.spawn(run,"scatter")
	var detached:=fresh(); detached.detached_camera=true; detached.detached_origin=Vector2(10000,10000)
	check(RangedThreats.spawn(detached,"scatter").pos==attached.pos,"Detached camera never relocates specialist spawns")
	run=fresh(); run.exp.practice=true; run.exp.route_index=21
	var practice_enemy:=RangedThreats.spawn(run,"breacher",run.player+Vector2(200,0),true)
	run._enemy_step(0); check(practice_enemy.hp==55 and run.exp.enemy_speed(run)==1,"Practice retains unscaled baseline")
	run=fresh()
	for i in range(run.MAX_PROJECTILES): run._add_projectile(run.player,Vector2.RIGHT,1,"hostile",0)
	var scatter:=RangedThreats.spawn(run,"scatter",run.player+Vector2(200,0),true); scatter.phase="aim"; scatter.clock=0
	FieldEnemies.step(run,scatter,0.01)
	check(run.projectiles.size()==run.MAX_PROJECTILES and run.projectiles.back().life==2.7,"Full projectile pool never mutates existing shots")
	run=fresh(); run.kit.energy=0; run.events.clear()
	var charges: int=run.kit.charges.q
	check(not run.vanguard.cast(run,"q",run.player+Vector2.RIGHT*200),"Empty-energy Q rejected")
	check(run.events.back().kind=="energy_empty" and run.kit.charges.q==charges and run.kit.energy==0,"Failed cast cues without consuming charge")
	check(not run.vanguard.cast(run,"d",run.player) and run.events.back().kind=="energy_empty","Empty-energy drive also cues")
	for pair in [[0.5,0],[0.49,1],[0.25,1],[0.24,2]]: check(CombatFeedback.severity(pair[0])==pair[1],"Exact damage thresholds")
	run.health=run.max_health()*0.49; run.events.clear(); run.hurt_player(run.player+Vector2.RIGHT*50,"test",1,"projectile")
	check(run.events[0].kind=="hurt" and is_equal_approx(run.events[0].health_fraction,run.health/run.max_health()),"Damage event carries actual post-hit fraction")
	await audio_checks()
	await visuals()
	print("PRESSURE/FEEDBACK: %d checks, %d failures"%[checks,failures]); quit(0 if failures==0 else 1)

func audio_checks() -> void:
	var sound=load("res://src/salvage/synth_audio.gd").new(); root.add_child(sound)
	for pair in [[0.5,"hurt"],[0.49,"hurt_low"],[0.25,"hurt_low"],[0.24,"hurt_critical"]]:
		check(sound.cue_for({"kind":"hurt","health_fraction":pair[0]})==pair[1],"Hit audio matches severity")
	for type in ["energy","coins","repair","speed","reset"]:
		check(sound.cue_for({"kind":"supply","supply":type})!="supply","Supply gets distinct mapped cue")
	for cue in ["hurt_low","hurt_critical","energy_empty","repair_pickup","energy_pickup","credit_pickup","boost_pickup","chest_contents","deploy"]:
		var stream: AudioStreamWAV=sound.sounds[cue]
		check(stream.get_length()>0.05 and stream.get_length()<0.6,"Bounded cue duration")
		var data: PackedByteArray=stream.data
		var peak:=0
		for i in range(0,data.size(),2): peak=maxi(peak,absi(data.decode_s16(i)))
		check(peak>1000 and peak<32767,"Audible PCM without sample clipping")
	var index: int=sound.important_cursor
	sound.receive({"kind":"energy_empty"}); check(sound.important_cursor!=index,"Failure uses reserved voice")
	index=sound.important_cursor
	for i in range(30): sound.receive({"kind":"energy_empty"})
	check(sound.important_cursor==index,"Repeated failure is rate limited")
	sound.receive({"kind":"hurt","health_fraction":0.2})
	var voice: AudioStreamPlayer=sound.players[9+(sound.important_cursor+2)%3]
	check(voice.stream==sound.sounds.hurt_critical and voice.volume_db==-9,"Critical hit has heavier protected mix")
	for i in range(40): sound.cooldowns.erase("pickup"); sound.receive({"kind":"pickup"})
	check(voice.stream==sound.sounds.hurt_critical,"Pickup shower cannot steal injury voice")
	sound.set_muted(true)
	check(sound.players.all(func(p): return not p.playing),"Mute stops every cue")
	sound.queue_free(); await process_frame

func visuals() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
	root.add_child(game); await process_frame; game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.model=fresh(); game.art.model=game.model; game.art.visible=true; game.screen="running"; game.ui.show_running()
	game.free_center=game.model.player; game._update_camera()
	for i in range(3):
		var enemy:=RangedThreats.spawn(game.model,["breacher","mender","scatter"][i],game.model.player+Vector2(-200+i*200,-125),true)
		enemy.warmup=0
		enemy.phase="aim"; enemy.clock=0.35; enemy.dir=(game.model.player-Vector2(enemy.pos)).normalized()
	for reduced in [false,true]:
		game.art.reduced_effects=reduced; game.ui.reduced=reduced
		for ratio in [0.49,0.24]:
			game.model.health=game.model.max_health()*ratio; game.ui.update_hud(game.model)
			game.combat_feedback.sync(ratio,true,reduced)
			game.combat_feedback.receive({"kind":"hurt","health_fraction":ratio})
			game.combat_feedback.set_process(false); game.art.queue_redraw()
			check(game.combat_feedback.mouse_filter==Control.MOUSE_FILTER_IGNORE,"Danger edges never consume clicks")
			await process_frame
			if "--render" in OS.get_cmdline_user_args():
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("res://output/pressure-%s-%s.png"%[str(ratio),str(reduced)])
	game.combat_feedback.sync(1,false,true); check(not game.combat_feedback.visible and game.combat_feedback.hit_left==0,"Menus clear hit warning")
	game.queue_free(); await process_frame
