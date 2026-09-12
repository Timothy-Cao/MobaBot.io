extends "res://tests/discovery35_test.gd"
func intentional(level: int=1) -> SalvageRun:
	var run:=modern(level); IntentRules.enable(run); return run
func execute() -> void:
	for seed_value in range(128):
		var run:=intentional(); run.offer_rng.seed=seed_value
		Vanguard.earn(run); ReviewRules.offer(run)
		check("q" in run.offers,"First choice supports starting attack")
		check(run.offers.size()==3 and len({run.offers[0]:true,run.offers[1]:true,run.offers[2]:true})==3,"Protected cards remain unique")
		var before:=run.offer_rng.state; var cards:=run.offers.duplicate()
		ReviewRules.offer(run)
		check(before==run.offer_rng.state and cards==run.offers,"Reopening choice never rerolls")
		check(ReviewRules.choose(run,run.offers.find("q")),"Choose offered attack")
		Vanguard.earn(run); ReviewRules.offer(run)
		check("e" in run.offers,"E is guaranteed on second offer")
		check(ReviewRules.choose(run,run.offers.find("e")),"E remains a voluntary selection")
		Vanguard.earn(run); ReviewRules.offer(run)
		check("e" in run.offers,"Next focused offer follows chosen E")
		check("w" in run.offers,"Third offer supplies optional area-control tool")
		check(run.kit.loadout.intent_choices==2,"Offers do not spend choices")
	var run:=intentional()
	for round_index in range(3):
		run.exp.route_index=round_index
		var previous: int=-1; var budget:=OperationRules.survival_budget(round_index,true)
		for tick in range(601):
			run.stage_time=tick*0.5
			var value:=IntentRules.survival_expected(run,budget)
			check(value>=previous and value<=budget,"XP curve is monotone and bounded")
			previous=value
		check(previous==budget,"Whole-round XP budget unchanged")
	run=intentional(); run.stage_time=15; OperationRules.pace(run); Vanguard.progression(run)
	check(run.level==2,"First upgrade arrives by fifteen seconds without perfect collection")
	var old:=modern(); old.stage_time=15; OperationRules.pace(old)
	check(old.total_xp<6,"Historical checkpoint retains original XP timing")
	run=intentional(); run.kit.loadout.intent_choices=1; run.health=run.max_health()*0.2
	Vanguard.earn(run); ReviewRules.offer(run)
	check("e" in run.offers and "full_heal" in run.offers,"E access and recovery option coexist")
	var counter: int=run.kit.loadout.intent_choices
	check(not ReviewRules.choose(run,8) and run.kit.loadout.intent_choices==counter,"Invalid choice cannot advance policy")
	run.exp.practice=true; check(not IntentRules.enabled(run),"Practice is excluded")
	run=intentional(); run.state="camp"; run.exp.clear_clock=-2
	var forge:=ForgeEquipment.new()
	check(forge.bank_camp(run,false),"Memory-only banking accepts new policy")
	var resumed:=modern(); check(forge.resume_into(resumed) and IntentRules.enabled(resumed),"Resume retains new rule family")
	for pair in [["intent_choices",-1],["intent_choices",1.5],["intent_focus","bogus"],["intent39","true"]]:
		var c: Dictionary=forge.checkpoint.duplicate(true); c.loadout[pair[0]]=pair[1]
		check(not ForgeEquipment.valid_checkpoint(c),"Malformed offer state rejected")
	var detached: Dictionary=forge.checkpoint.duplicate(true); detached.loadout.erase("intent39")
	check(not ForgeEquipment.valid_checkpoint(detached),"Orphaned policy fields rejected")
	Vanguard.setup(run,1); check(not run.kit.loadout.has("intent39"),"Practice setup clears policy")
	run=intentional(); run.stage_time=100
	check(IntentRules.pressure_pack(run) and IntentRules.spawn_delay(run)<1,"Surge begins a pressure interval")
	run.stage_time=135
	check(not IntentRules.pressure_pack(run) and IntentRules.spawn_delay(run)>1,"Recovery interval gives collection space")
	run.stage_time=141; var direction:=IntentRules.pack_side(run)
	run.stage_time=149; check(direction==IntentRules.pack_side(run),"Approach direction is stable within a group")
	run.stage_time=150
	check(direction!=IntentRules.pack_side(run),"Approach direction rotates")
	run.stage_time=30
	run._spawn_pack(8,false)
	var positions: Array=[]
	for e in run.enemies: positions.append(e.pos)
	var other:=intentional(); other.stage_time=30; other.detached_camera=true; other.detached_origin=Vector2(1000,800)
	other._spawn_pack(8,false)
	check(positions==other.enemies.map(func(e): return e.pos),"Detached camera does not relocate group spawns")
	for level_value in range(1,40):
		run=intentional(); run.level=level_value; run.total_xp=DiscoveryRules.threshold(level_value-1)+3; run.next_level=DiscoveryRules.threshold(level_value)
		run.exp.pending_chests=1; DiscoveryRules.progress(run)
		check(run.level==level_value+1 and run.total_xp==DiscoveryRules.threshold(level_value)+3,"Chest grants exactly one level and keeps partial XP")
		check(run.next_level==DiscoveryRules.threshold(run.level),"Level thresholds retain the existing curve")
	run=intentional(); run.level=25; run.total_xp=DiscoveryRules.threshold(24); run.next_level=DiscoveryRules.threshold(25)
	run.state="camp"; run.exp.clear_clock=-2
	forge=ForgeEquipment.new(); check(forge.bank_camp(run,false),"Late checkpoint banks")
	resumed=modern(); check(forge.resume_into(resumed) and resumed.next_level==run.next_level,"Late threshold survives resume")
	run=intentional(); Vanguard.earn(run); ReviewRules.offer(run); var offered:=run.offers.duplicate()
	ReviewRules.choose(run,0)
	check(run.intent_decisions.size()==1 and run.intent_decisions[0].offered==offered,"Chosen-card diagnostics retain actual offers")
	var diagnostic: Dictionary={}; RunDiagnostics.annotate(diagnostic,run,false)
	diagnostic.progression_decisions.clear()
	check(run.intent_decisions.size()==1,"Diagnostic export cannot mutate the run")
	run=intentional(); run.spawn_enemy(run.player+Vector2(100,0),0)
	var stunned: Dictionary=run.enemies.back(); stunned.hp=500; stunned.max_hp=500; stunned.warmup=0
	ReviewRules.strike_status(run,stunned,true)
	run.vanguard.hammer_direction=Vector2.RIGHT; run.vanguard.spin_swing=true; run.vanguard.hit_hammer(run)
	check(is_equal_approx(stunned.stun,1.1),"Hammer follow-up cannot shorten a longer W stun")
	check(run.intent_combos.spins==1 and run.intent_combos.spins_hit==1 and run.intent_combos.targets_hit==1,"Spin contact recorded once")
	run.enemies.clear(); run.vanguard.spin_swing=true; run.vanguard.hit_hammer(run)
	check(run.intent_combos.spins==2 and run.intent_combos.spins_hit==1,"Missed spin remains distinguishable")
	print("INTENT39: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
