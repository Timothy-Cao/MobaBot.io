extends RefCounted
## Offline design instrument. Never loaded by gameplay and never opens a save.
const LEVELS := [5,14,24]
const IDEAL_SECONDS := 60.0
const PATHS := [["b0_1","b0_3","b0_5","b0_7"],["b2_0","b2_2","b2_4","b2_6"],["b3_0","b3_2","b3_4","b3_6"]]

static func build(chapter: int, round_index: int, tier: int, focus: String="balanced") -> SalvageRun:
	var run:=SalvageRun.new(7127); run.loot_rng.seed=8028
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
	BotExpedition.new().start(run,"ranged",0); run.exp.enable_revision(run)
	Vanguard.setup(run); ReviewRules.enable(run); OperationRules.enable(run,chapter)
	run.exp.route_index=round_index
	# Same earned budget in every comparison; ideal selection ignores card luck.
	run.total_xp=(LEVELS[round_index]-1)*20; Vanguard.progression(run)
	while not run.kit.loadout.rewards18.is_empty():
		var pool:=ReviewRules.candidates(run)
		pool.sort_custom(func(a,b): return Vanguard.rank_of(run,a)<Vanguard.rank_of(run,b))
		run.state="upgrade"; run.offers=[pool[0]]; Vanguard.spend(run,pool[0])
	run.state="running"
	var order: Array=[0,1,2] if focus=="balanced" else [0,2,1] if focus=="offense" else [1,2,0] if focus=="defense" else [2,1,0]
	run.mastery.buy(run,"b0_0")
	while run.mastery.available(run.level)>0:
		var bought:=false
		for branch in order:
			for id in PATHS[branch]:
				if run.mastery.buy(run,id): bought=true; break
			if bought and focus!="balanced": break
		if not bought: break
	var gear:=ForgeEquipment.new()
	for slot in ForgeEquipment.SLOTS:
		gear.equipped[slot]="" if tier==0 else ForgeEquipment.SETS[tier-1]+"_"+slot
	gear.apply_to(run)
	run.health=run.exp.max_health(run); run.kit.energy=run.kit.energy_max()
	return run

static func measure(run) -> Dictionary:
	var q:=UpgradePreview.stats(run,"q",Vanguard.rank_of(run,"q"))
	var w:=UpgradePreview.stats(run,"w",Vanguard.rank_of(run,"w"))
	var e:=UpgradePreview.stats(run,"e",Vanguard.rank_of(run,"e"))
	var r:=UpgradePreview.stats(run,"r",Vanguard.rank_of(run,"r"))
	var h:=UpgradePreview.stats(run,"hammer",Vanguard.rank_of(run,"hammer"))
	var g:=UpgradePreview.stats(run,"gun",Vanguard.rank_of(run,"gun"))
	var energy:=0.0
	for slot in ["q","w","e","r"]: energy+=run.kit.ability_cost(run.kit.loadout[slot])/run.kit.cooldown(slot)
	var spells: float=q["Direct + blast"]/q["Recharge sec"]+w["Center damage"]/w["Recharge sec"]+e["Impact damage"]/e["Recharge sec"]+r["Impact damage"]*(1.25 if run.kit.effective_rank("r")>=10 else 1)/r["Recharge sec"]
	var autos: float=h["Head damage"]*h["Swing / sec"]+g.Damage*g["Shots / sec"]*(1.2 if Vanguard.gun_rank(run)>=10 else 1.0)
	# A 60-second resource envelope, not an executable perfect rotation. Charged
	# opening burst, animation timing, modules, pets and mastery proc hits excluded.
	var energy_factor:=minf(1.0,(run.kit.energy_regen()+run.kit.energy_max()/IDEAL_SECONDS)/energy)
	var combo: float=h["Head damage"]*(3.0/0.9-1.0)*minf(h["Swing / sec"],energy_factor/e["Recharge sec"])
	var w_dps: float=w["Center damage"]/w["Recharge sec"]*energy_factor
	var vulnerability:=0.5*minf(1.0,energy_factor/w["Recharge sec"])
	var reference: float=(autos+spells*energy_factor+combo-w_dps)*(1+vulnerability)+w_dps
	var boss_hp:=OperationRules.boss_hp(run)
	var original_encounter: bool=run.exp.encounter_spawned
	run.exp.encounter_spawned=run.exp.final_round()
	var standard_hit: float=run.exp.incoming(run,1.0)
	run.exp.encounter_spawned=original_encounter
	var drive:=ReviewRules.drive_cost(run)
	var movement_budget: float=drive*0.2+run.kit.ability_cost("blink")/12.0
	var tank: Dictionary={"kind":3,"hp":1.0,"max_hp":1.0}
	ReviewRules.scale_role(run,tank)
	return {"level":run.level,"ranks":run.kit.ranks.duplicate(),"mastery":run.mastery.ranks.duplicate(),"reference_dps":reference,"cooldown_only_dps":autos+spells,"spell_energy_sec":energy,"energy_factor":energy_factor,"target_boss_hp":reference*IDEAL_SECONDS,"current_boss_hp":boss_hp,"ideal_ttk":boss_hp/reference,"ttk_at_two_thirds":boss_hp/reference*1.5,"ttk_at_half":boss_hp/reference*2.0,"effective_health":run.exp.max_health(run)*(1+run.exp.resistance/100.0),"standard_hit_fraction":standard_hit/run.exp.max_health(run),"standard_hits_to_die":ceilf(run.exp.max_health(run)/standard_hit),"tank_w_hits":tank.hp/w["Center damage"],"drive_seconds":run.kit.energy_max()/maxf(0.001,drive-run.kit.energy_regen()),"drive_duty":minf(1,run.kit.energy_regen()/drive),"mobile_spell_energy_factor":clampf((run.kit.energy_regen()+run.kit.energy_max()/IDEAL_SECONDS-movement_budget)/energy,0,1)}
