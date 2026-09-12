extends SceneTree
var checks:=0
var failures:=0
func check(ok: bool, label: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(label)
func fresh(level: int=1) -> SalvageRun:
	var run:=SalvageRun.new(7127)
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
	BotExpedition.new().start(run,"ranged",0); run.exp.enable_revision(run)
	Vanguard.setup(run); ReviewRules.enable(run); OperationRules.enable(run,level); LevelMastery.enable(run)
	run.kit.loadout.support23=true; run.kit.loadout.arsenal26=true; DemoPacing.enable(run)
	return run
func _initialize() -> void: execute.call_deferred()
func execute() -> void:
	var run:=fresh()
	check(DemoPacing.LEVELS==3 and run.exp.route().size()==3,"Three levels with three stages")
	for stage in range(3):
		run.exp.route_index=stage; run.stage_time=150; OperationRules.pace(run)
		check(run.exp.round_seconds()==300,"Each stage lasts five minutes")
		check(run.kit.loadout.operation_xp[stage]==roundi(OperationRules.SURVIVAL_XP[stage]*1.1)/2,"Half budget at half duration")
		run.stage_time=300; OperationRules.pace(run)
	check(run.total_xp==198,"Survival XP total increased ten percent")
	for id in DemoPacing.INTRO:
		run=fresh(); var seconds: int=DemoPacing.INTRO[id]
		run.exp.route_index=seconds/300; run.stage_time=seconds%300
		check(DemoPacing.specialist(run,int(run.stage_time/30))==id,"Introduction: "+id)
	run=fresh(); run.stage_time=60
	check(DemoPacing.specialist(run,2)=="","Opening has no specialists")
	run._spawn_pack(15,true)
	check(run.enemies.all(func(e): return e.kind==0),"Opening packs exclude lungers and tanks")
	run=fresh(); run.stage_time=299; run.exp.spawns(run,0)
	check(not run.exp.encounter_spawned,"No early guardian")
	run.stage_time=300; run.exp.spawns(run,0)
	check(run.exp.encounter_spawned,"Guardian at five minutes")
	run=fresh(); run.collect_pickup({"value":180,"pos":run.player})
	check(run.total_xp==3,"Pickup XP reduced to thirty percent in stage one")
	run.state="camp"; run.exp.clear_clock=-2
	var forge:=ForgeEquipment.new(); check(forge.bank_camp(run,false),"In-memory checkpoint banks")
	check(ForgeEquipment.valid_checkpoint(forge.checkpoint),"Demo checkpoint validates")
	var resumed:=fresh(); check(forge.resume_into(resumed) and resumed.exp.round_seconds()==300,"Resume preserves pacing")
	var invalid:=forge.checkpoint.duplicate(true); invalid.loadout.operation20=4
	check(not ForgeEquipment.valid_checkpoint(invalid),"Demo checkpoint rejects level four")
	invalid.loadout.erase("demo27")
	check(ForgeEquipment.valid_checkpoint(invalid),"Historical higher-level checkpoint preserved")
	run=fresh(); run.kit.extra.walls.clear(); var hatch:=RangedThreats.spawn(run,"hatchery",run.player+Vector2(300,0),true); hatch.warmup=0
	check(hatch.hp==360 and hatch.max_hp==360,"Hatchery has triple base hull")
	SupportEnemies.step(run,hatch,8)
	var children: Array=run.enemies.filter(func(e): return e.get("hatch_parent",-1)==hatch.id)
	check(children.size()==4 and children.all(func(e): return e.kind==0 and e.get("runner",false)),"Four fast chasers per hatch")
	run.hit_enemy(hatch,100000,"test"); check(hatch.dead,"Hatchery is destructible")
	Vanguard.setup(run)
	check(not run.exp.demo_pace and not run.kit.loadout.has("demo27"),"Reset clears pacing family")
	print("DEMO PACING: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)


