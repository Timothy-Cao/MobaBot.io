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
	Vanguard.setup(run,5); ReviewRules.enable(run); OperationRules.enable(run,1); LevelMastery.enable(run); run.kit.loadout.support23=true
	run.kit.extra.walls.clear(); run.enemies.clear(); run.player=Vector2(1400,1400)
	return run
func _initialize() -> void: execute.call_deferred()
func execute() -> void:
	var run:=fresh(); var v=run.vanguard
	check(v.cast(run,"e",run.player+Vector2(500,0)),"E starts")
	var duration: float=v.slam_left
	check(run.kit.preview_ready(run,"q",run.player+Vector2.RIGHT) and run.kit.preview_ready(run,"f",run.player+Vector2(0,100)),"Combo previews accept Q and Flash")
	check(v.cast(run,"q",run.player+Vector2(500,0)),"Q fuels active E")
	check(run.kit.charges.q==0 and v.slam_left>duration and run.projectiles.is_empty(),"Fuel spends every charge for travel, no rocket")
	check(not v.cast(run,"q",run.player),"Cannot refuel twice")
	check(v.swing(run,run.player+Vector2.RIGHT),"Hammer buffers during E")
	var destination:=run.player+Vector2(0,180)
	run.spawn_enemy(destination+Vector2(-90,0),3); var enemy: Dictionary=run.enemies.back(); enemy.hp=10000; enemy.warmup=0
	check(v.cast(run,"f",destination),"Flash during fueled E")
	check(v.slam_left==0 and v.hammer<0 and not v.buffered_hammer,"Flash resolves buffered spin immediately")
	check(enemy.hp<10000,"Spin hits behind facing")
	check(v.impacts.any(func(x): return x.kind=="hammer" and is_equal_approx(x.angle,PI)),"Spin visual matches 360 hit")
	run=fresh(); v=run.vanguard
	v.cast(run,"e",run.player+Vector2(500,0)); v.cast(run,"f",run.player+Vector2(0,100))
	check(v.swing(run,run.player+Vector2.RIGHT) and v.spin_swing,"Post-Flash click retains combo")
	run=fresh(); v=run.vanguard
	v.cast(run,"d",run.player); check(v.cast(run,"f",run.player+Vector2(100,0)) and not v.ghost,"Flash cancels drive even below rank ten")
	run=fresh(); v=run.vanguard
	v.cast(run,"e",run.player+Vector2(500,0)); v.swing(run,run.player+Vector2.RIGHT); v.tick(run,1)
	check(v.spin_swing and v.hammer>=0,"Natural E ending starts buffered spin")
	run=fresh(); run.exp.practice=true; run.vanguard.conductor_active=true
	var conductor=run.vanguard.conductor
	conductor.cast(run,"w",run.player+Vector2(100,0)); conductor.cast(run,"w",run.player+Vector2(250,0)); conductor.cast(run,"w",run.player+Vector2(400,0))
	check(conductor.relays.size()==2,"Conductor keeps two relays")
	run.spawn_enemy(run.player+Vector2(300,0),3); enemy=run.enemies.back(); enemy.warmup=0; enemy.hp=10000
	conductor.cast(run,"q",run.player+Vector2(500,0)); check(enemy.hp<10000,"Conductor arc hits actual line")
	conductor.cast(run,"r",run.player+Vector2(500,0)); var hp: float=enemy.hp
	check(conductor.relays.is_empty() and enemy.hp==hp,"Discharge consumes relays and waits")
	conductor.tick(run,0.7); check(enemy.hp<hp,"Delayed discharge hits")
	var forge:=ForgeEquipment.new(); run=fresh(); run.state="camp"; run.exp.clear_clock=-2
	run.mastery.ranks={"field":1,"reach":3,"economy":3,"insulation":3,"charge":1}; run.mastery.spent=11; run.level=12
	check(forge.bank_camp(run,false) and forge.starting_ability,"Utility capstone banks starting ability")
	var saved:=forge.snapshot(); var copy:=ForgeEquipment.new(); copy.restore(saved)
	check(copy.starting_ability and copy.valid(saved),"Starting unlock persists in valid profile")
	var invalid:=saved.duplicate(true); invalid.starting_ability="yes"; check(not copy.valid(invalid),"Reject malformed unlock")
	var failed:=ForgeEquipment.new(); failed.path="res://output/missing-directory/capstone.json"
	check(not failed.bank_camp(run,true) and not failed.starting_ability,"Failed bank rolls back capstone unlock")
	var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
	root.add_child(game); await process_frame; game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.collection=ForgeEquipment.new(); game.launch_expedition(); game.model.offers.assign(["e","f","hammer"])
	game.model.kit.loadout.rewards18.assign(["upgrade","upgrade","upgrade"])
	game.model.kit.ranks.e=4; game.model.kit.ranks.f=4; game.model.kit.loadout.hammer_rank=9
	ReviewView.upgrades(game.ui,game.model)
	check(game.ui.hud.visible,"Paused world HUD remains visible")
	if "--render" in OS.get_cmdline_user_args():
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/upgrade24.png")
	game.collection=copy; game.launch_expedition()
	check(game.model.kit.unlocked("e") and game.model.kit.ranks.e==1,"Future run starts with E learned")
	game.ui.show_running(); game.model.vanguard.combo_left=1.2
	game.model.vanguard.swing(game.model,game.model.player+Vector2.RIGHT); game.model.vanguard.hit_hammer(game.model)
	game.model.vanguard.impacts.back().life=0.2; game.art.queue_redraw()
	if "--render" in OS.get_cmdline_user_args():
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/spin24.png")
	game.launch_practice()
	for button in game.ui.overlay.get_children():
		if button is Button and button.text=="Conductor experiment": button.pressed.emit(); break
	check(Conductor.enabled(game.model),"Practice button selects second class")
	game.practice_reset(); check(Conductor.enabled(game.model),"Practice reset preserves class")
	game.model.vanguard.conductor.cast(game.model,"w",game.model.player+Vector2(100,-120))
	game.model.vanguard.conductor.cast(game.model,"w",game.model.player+Vector2(300,-120))
	game.model.vanguard.conductor.cast(game.model,"q",game.model.player+Vector2(500,-120))
	game.model.supply_drops.append({"pos":game.model.player+Vector2(-80,0),"kind":"energy","life":10.0})
	game.model.supply_drops.append({"pos":game.model.player+Vector2(-120,0),"kind":"repair","life":10.0})
	game.art.queue_redraw()
	if "--render" in OS.get_cmdline_user_args():
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/conductor24.png")
		game.art.reduced_effects=true; game.art.queue_redraw()
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/conductor24-reduced.png")
	game.queue_free(); await process_frame
	print("COMBO24: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
