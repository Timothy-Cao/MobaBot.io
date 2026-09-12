class_name DiscoveryRules
extends RefCounted
## A new-run contract; historical checkpoints keep their original rewards.
const BONUS := ["xp_gain","pickup_range"]
const CAP := 40
static func enabled(run) -> bool:
	return FactoryMaps.enabled(run) and run.kit.loadout.get("discovery35",false)==true
static func enable(run) -> void:
	run.kit.loadout.discovery35=true
	run.kit.loadout.field_ranks={"xp_gain":0,"pickup_range":0}
	run.next_level=cost(1)
	run.discovery_chests=DiscoveryRules.new()
	FactoryMaps.build(run)
static func rank_of(run, id: String) -> int:
	return int(run.kit.loadout.get("field_ranks",{}).get(id,0)) if enabled(run) else 0
static func xp_rate(run) -> float:
	return 1.25*(1.0+rank_of(run,"xp_gain")*0.1) if enabled(run) else 1.0
static func cost(level: int) -> int:
	return [6,8,10,12][level-1] if level<5 else 20
static func threshold(level: int) -> int:
	var value:=0
	for i in range(1,level+1): value+=cost(i)
	return value
static func picks(level: int) -> int: return 1 if level<=5 else 2
static func progress(run) -> void:
	# A chest advances one complete level, preserving progress inside the XP bar.
	while run.exp.pending_chests>0:
		run.exp.pending_chests-=1; run.exp.chests_opened+=1
		var awards:=1
		if LevelMastery.enabled(run) and run.mastery.value("double_chest")>0 and run.loot_rng.randf()<run.mastery.value("double_chest"): awards=2
		for i in range(awards):
			if run.level<CAP:
				run.total_xp+=cost(run.level)
				levels(run)
			else: Vanguard.earn(run)
	levels(run)
static func levels(run) -> void:
	while run.level<CAP and run.total_xp>=run.next_level:
		run.level+=1; run.next_level=threshold(run.level)
		for i in range(picks(run.level)): Vanguard.earn(run)
		if (run.level-1)%3==0: run.grant_utility()
		run.emit_event("equipped",run.player,{"id":"power"})
static func spend(run, id: String) -> bool:
	if not enabled(run) or run.state!="upgrade" or id not in run.offers or run.kit.loadout.rewards18.is_empty(): return false
	if id=="field_credit": run.exp.field_credits+=200
	elif id in BONUS and rank_of(run,id)<5: run.kit.loadout.field_ranks[id]+=1
	else: return false
	run.kit.loadout.rewards18.pop_front()
	run.emit_event("equipped",run.player,{"id":"power"})
	return true
static func opening(run) -> bool:
	return enabled(run) and run.exp.route_index==0 and run.stage_time<90

var chest_rng:=RandomNumberGenerator.new()
var due: float=-1
func killed(run, enemy: Dictionary) -> void:
	if due<0:
		chest_rng.seed=run.run_seed+35061
		due=chest_rng.randf_range(50,70)
	var count:=0
	if enemy.has("role") or enemy.has("miniboss"): count=2
	elif run.time>=due:
		count=1; due=run.time+chest_rng.randf_range(50,70)
	for i in range(count):
		run.exp.loot_chests.append({"pos":Vector2(enemy.pos)+Vector2(i*36-18,0),"life":60.0})
