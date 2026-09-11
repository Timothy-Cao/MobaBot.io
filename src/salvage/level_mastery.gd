class_name LevelMastery
extends RefCounted
## New-run tree; older checkpoints retain their authored nodes.
static var TREE: Dictionary=make_tree()
static func make_tree() -> Dictionary:
	var result: Dictionary={"field":{"name":"Field sense","stat":"magnet","value":10.0,"max":1,"parent":"","branch":0,"index":-1}}
	var branches: Array=[
		[["reach","Extended reach","range",8.0,3],["economy","Efficient circuits","efficiency",0.04,3],["insulation","Insulation","emp_resist",0.1,3],["charge","Head start","starting_ability",1.0,1]],
		[["learner","Scavenger training","xp",0.03,3],["salvager","Salvage sorting","loot_bonus",0.04,3],["supplies","Resource recovery","supplies",1.0,3],["windfall","Lucky chest","double_chest",0.01,1]],
		[["companion","Little helper","pet_damage",2.0,3],["collector","Pickup helper","pet_magnet",12.0,3],["repair","Repair helper","pet_repair",0.15,3],["disruptor","Disruptor pulse","pet_stun",0.25,1]]]
	for branch in range(3):
		var parent: String="field"
		for depth in range(4):
			var row: Array=branches[branch][depth]
			result[row[0]]={"name":row[1],"stat":row[2],"value":row[3],"max":row[4],"parent":parent,"branch":branch,"index":depth}; parent=row[0]
	return result

static func enabled(run) -> bool: return run!=null and run.kit!=null and run.kit.loadout.get("level22",false)
static func enable(run) -> void:
	run.kit.loadout.level22=true; run.mastery.modern=true
	run.exp.ascension=0; run.exp.sync_stats(run)

static func text(id: String) -> String:
	if id=="charge": return "Unlock E at the start of future runs. Bank at a round clear to keep this unlock. Mastery points still reset each run."
	return {"field":"+10 pickup radius.","reach":"+8 hammer reach per rank.","economy":"Ability energy cost and drive upkeep -4%, energy regeneration +0.2/sec per rank. No cooldown bonus.","insulation":"EMP duration -10% per rank. Does not grant immunity.","charge":"Q stores one extra charge. Recharge speed is unchanged.","learner":"+3% pickup XP per rank. Survival XP is unchanged.","salvager":"+4% field coins and banked Salvage per rank. More crates over time; crate odds are unchanged.","supplies":"Unlock rare energy and repair drops from monsters: 1% per rank. Each supplies 12 + 4 per rank energy or 2 + 1 per rank HP.","windfall":"1% chance for a recovered chest to give double field credits.","companion":"Untargetable helper deals 2 damage per rank every 1.5 seconds within 240 range. Suppressed by EMP.","collector":"+12 pickup radius per rank through the helper.","repair":"Helper repairs 0.15 HP/sec per rank while you have avoided damage for 3 seconds.","disruptor":"Helper briefly stuns one ordinary enemy for 0.25 seconds every 6 seconds. Bosses are immune."}.get(id,"")

static func tick(run, delta: float) -> void:
	if not enabled(run) or run.vanguard.emp_left>0 or run.mastery.value("pet_damage")<=0: return
	run.kit.pet_position=run.kit.pet_position.move_toward(run.player+Vector2(-42,30),delta*240)
	run.vanguard.helper_clock-=delta; run.vanguard.helper_stun=maxf(0,run.vanguard.helper_stun-delta)
	if run.vanguard.helper_clock<=0:
		run.vanguard.helper_clock=1.5
		var target: Dictionary={}; var distance:=240.0
		for enemy in run.enemies:
			var d: float=Vector2(enemy.pos).distance_to(run.kit.pet_position)
			if not enemy.get("dead",false) and d<distance: target=enemy; distance=d
		if not target.is_empty():
			run.hit_enemy(target,run.mastery.value("pet_damage"),"pet")
			if run.mastery.value("pet_stun")>0 and run.vanguard.helper_stun<=0 and not target.has("role"):
				target.stun=maxf(target.get("stun",0),0.25); run.vanguard.helper_stun=6
	if run.health<run.vanguard.helper_health: run.vanguard.helper_safe=0
	else: run.vanguard.helper_safe+=delta
	if run.vanguard.helper_safe>=3: run.health=minf(run.max_health(),run.health+run.mastery.value("pet_repair")*delta)
	run.vanguard.helper_health=run.health
