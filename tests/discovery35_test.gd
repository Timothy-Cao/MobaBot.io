extends "res://tests/factory_maps_test.gd"
func modern(level: int=1) -> SalvageRun:
	var run:=fresh(level); FactoryMaps.enable(run); DiscoveryRules.enable(run); return run
func drain(run) -> void:
	ReviewRules.offer(run)
	var guard:=0
	while run.state=="upgrade" and guard<256:
		check(ReviewRules.choose(run,0),"Queued choice resolves")
		guard+=1
func execute() -> void:
	var run:=modern()
	check(run.next_level==6,"Cheap first level")
	run.total_xp=36; Vanguard.progression(run)
	check(run.level==5 and run.next_level==56 and run.kit.loadout.rewards18.size()==4,"Four cheap levels, one choice each")
	drain(run)
	run.total_xp=56; Vanguard.progression(run)
	check(run.level==6 and run.kit.loadout.rewards18.size()==2,"Two picks from level six")
	drain(run)
	run.exp.pending_chests=2; Vanguard.progression(run)
	check(run.level==8 and run.exp.pending_chests==0 and run.kit.loadout.rewards18.size()==4,"Boss chests grant two immediate levels")
	drain(run)
	run=modern(); run.total_xp=3; run.exp.pending_chests=1; Vanguard.progression(run)
	check(run.level==2 and run.total_xp==9,"Chest retains partial XP")
	drain(run)
	for id in DiscoveryRules.BONUS:
		for rank_value in range(5):
			Vanguard.earn(run); run.state="upgrade"; run.offers=[id]
			check(ReviewRules.choose(run,0),"Bonus can be chosen: "+id)
		check(DiscoveryRules.rank_of(run,id)==5 and id not in ReviewRules.candidates(run),"Bonus cap excludes completed option")
	var boosted: float=run.magnet_radius(); run.kit.loadout.field_ranks.pickup_range=0
	check(is_equal_approx(boosted,run.magnet_radius()*1.5),"Pickup range grows fifty percent")
	run.kit.loadout.field_ranks.pickup_range=5
	check(is_equal_approx(DiscoveryRules.xp_rate(run),1.875),"XP bonus multiplies eased rate")
	for slot in ReviewRules.CORE:
		if slot=="hammer": run.kit.loadout.hammer_rank=10
		elif slot=="gun": run.upgrades.power=10
		else: run.kit.ranks[slot]=10
	Vanguard.earn(run); ReviewRules.offer(run)
	check(run.offers==["field_credit","field_credit","field_credit"],"Three credit options after all ranks cap")
	var credits: int=run.exp.field_credits
	check(ReviewRules.choose(run,2) and run.exp.field_credits==credits+200,"Credit choice grants once")
	check(not ReviewRules.choose(run,2),"Repeated selection does not pay twice")
	run=modern(); run.kit.loadout.field_ranks.xp_gain=5; run.stage_time=300; OperationRules.pace(run)
	check(run.total_xp==82,"XP rank applies to survival grants")
	run=modern(3); run.stage_time=60; run._spawn_pack(12,true)
	check(run.enemies.all(func(e): return e.kind==0 and not e.runner and not e.elite),"All Levels open with basic bodies")
	check(DemoPacing.specialist(run,2)=="","No opening specialists")
	run=modern(); var enemy: Dictionary={"pos":run.player}
	run.time=49; run.exp.enemy_killed(run,enemy); check(run.exp.loot_chests.is_empty(),"Chest cannot drop too early")
	run.time=71; run.exp.enemy_killed(run,enemy); check(run.exp.loot_chests.size()==1,"One timed chest")
	run.exp.enemy_killed(run,enemy); check(run.exp.loot_chests.size()==1,"No duplicate timed chest on next kill")
	enemy.role="boss"; run.exp.enemy_killed(run,enemy); check(run.exp.loot_chests.size()==3,"Boss adds two chests")
	run.exp.finish_step(run,0.01)
	check(run.state=="upgrade" and run.level==4,"Touching chests pauses immediately")
	drain(run)
	run=modern(); run.stage_time=301; run.exp.finish_step(run,0.01)
	var guard:=0
	while run.state!="camp" and guard<200:
		drain(run); run.exp.finish_step(run,0.5); guard+=1
	check(run.state=="camp" and run.exp.pending_chests==0,"Clear collection cannot trap the run")
	var forge:=ForgeEquipment.new()
	check(forge.bank_camp(run,false),"New progression checkpoint validates")
	var resumed:=fresh(); check(forge.resume_into(resumed) and DiscoveryRules.enabled(resumed),"Resume preserves new rules")
	var corrupt:=forge.checkpoint.duplicate(true); corrupt.loadout.field_ranks.pickup_range=6
	check(not ForgeEquipment.valid_checkpoint(corrupt),"Reject invalid pickup rank")
	corrupt=forge.checkpoint.duplicate(true); corrupt.loadout.discovery35="true"
	check(not ForgeEquipment.valid_checkpoint(corrupt),"Reject malformed rule flag")
	corrupt=forge.checkpoint.duplicate(true); corrupt.next="six"
	check(not ForgeEquipment.valid_checkpoint(corrupt),"Reject malformed XP threshold")
	var old:=fresh(); old.total_xp=20; Vanguard.progression(old)
	check(old.level==2 and old.kit.loadout.rewards18.size()==3,"Historical progression unchanged")
	for level in range(1,4):
		for stage_index in range(3):
			run=modern(level); run.exp.route_index=stage_index; run.exp.enter(run)
			check(free_point(run.player,run.kit.extra.walls,150),"Spawn stays clear")
			connected(run.kit.extra.walls)
			run.factory_works.ensure(run)
			for m in run.factory_works.machines: check(free_point(m.pad,run.kit.extra.walls,40),"Every machinery control is reachable")
		run=modern(level); run.factory_works.ensure(run); var machine: Dictionary=run.factory_works.machines[0]
		run.player=machine.pad
		run.factory_works.step(run,0.36)
		check(machine.armed,"Standing on control arms machinery")
		run.spawn_enemy(machine.target,0); var target: Dictionary=run.enemies.back(); target.warmup=0
		var hp: float=target.hp
		run.factory_works.step(run,0.81)
		check(machine.active>0 and machine.cooldown>0,"Machinery activates and cools down")
		if level==2: check(target.hp<hp,"Press damages a target inside marked circle")
		if level==3:
			var points: Dictionary=run.factory_works.before_move(run)
			target.pos+=Vector2(100,0); run.factory_works.after_move(run,points)
			check(is_equal_approx(Vector2(target.pos).distance_to(machine.target),45),"Cooling vent slows displacement")
		run.exp.practice=true; machine.cooldown=0; machine.armed=false; run.factory_works.step(run,1)
		check(not machine.armed,"Practice never activates campaign machinery")
	var dense:=spawn_sample(1,0,0,90,true)
	var previous:=spawn_sample(1,0,0,90,false)
	check(dense.total>previous.total*1.7 and dense.total<previous.total*2.0,"Opening gets substantially more basic bodies")
	check(dense.special==0,"Extra opening bodies remain ordinary blobs")
	for context in [[1,0,120],[1,1,0],[2,0,0],[3,0,0]]:
		var current:=spawn_sample(context[0],context[1],context[2],20,true)
		var baseline_sample:=spawn_sample(context[0],context[1],context[2],20,false)
		check(current.total==baseline_sample.total,"Later time, rounds and Levels keep spawn counts")
	print("OPENING SPAWNS / 90s: previous=%d current=%d"%[previous.total,dense.total])
	if "--render" in OS.get_cmdline_user_args(): await captures35()
	print("DISCOVERY 35: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
func captures35() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
	root.add_child(game); await process_frame; game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.collection=ForgeEquipment.new(); game.collection.chapter_cleared=3; game.launch_expedition(); game.auto_play=true
	OperationView.prepare(game); await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/discovery35-selector.png")
	for level in range(1,4):
		game.model.exp.operation_chapter=level; game.model.exp.enter(game.model)
		game.model.factory_works.ensure(game.model)
		game.model.factory_works.machines[0].active=5 if level==3 else 0.5
		game.ui.show_running(); game.ui.announce(FactoryMaps.NAMES[level-1]); game.ui.update_hud(game.model); game.art.queue_redraw()
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/discovery35-map-%d.png"%level)
	game.model.state="upgrade"; game.model.offers.assign(["q","xp_gain","pickup_range"]); Vanguard.earn(game.model)
	ReviewView.upgrades(game.ui,game.model); await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/discovery35-cards.png")
	game.ui.reduced=true; ReviewView.upgrades(game.ui,game.model); await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/discovery35-cards-reduced.png")
	game.queue_free(); await process_frame

func connected(walls: Array) -> void:
	var cells: Dictionary={}; var queue: Array[Vector2i]=[]
	for x in range(66):
		for y in range(41):
			if free_point(Vector2(-2160+x*80,-1360+y*80),walls,40): cells[Vector2i(x,y)]=false
	queue.append(cells.keys()[0]); cells[queue[0]]=true; var index:=0
	while index<queue.size():
		var cell: Vector2i=queue[index]; index+=1
		for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i=cell+d
			if cells.has(next) and not cells[next]: cells[next]=true; queue.append(next)
	check(queue.size()==cells.size(),"Every sampled walkable route connects")

func spawn_sample(chapter: int, round_index: int, start: float, seconds: float, current: bool) -> Dictionary:
	var run:=modern(chapter); run.exp.route_index=round_index; run.exp.enter(run)
	if not current: run.kit.loadout.discovery35=false
	run.exp.last_wave=int(start/50); run.exp.threat_wave=int(start/30)
	var result: Dictionary={"total":0,"special":0}
	for frame in range(int(seconds*30)):
		run.stage_time=start+frame/30.0
		run.exp.spawns(run,1.0/30)
		for enemy in run.enemies:
			result.total+=1
			if enemy.kind!=0 or enemy.get("runner",false) or enemy.get("elite",false) or enemy.has("gunner_kind"): result.special+=1
		run.enemies.clear()
	return result
