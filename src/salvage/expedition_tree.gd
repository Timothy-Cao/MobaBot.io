class_name ExpeditionTree
extends BotMastery
## Six routes, two lanes each, four depths. All values feed the shared stat budget.
const BRANCHES := ["Armament", "Mobility", "Hull", "Reactor", "Salvage", "Command"]
const ROUTES := [
	[["Hot barrel", "attack", 0.04], ["Focusing lens", "damage", 0.04], ["Fast cycle", "haste", 0.04], ["Long barrel", "range", 12], ["Static lock", "shock", 1], ["Blast echo", "aftershock", 1], ["Heavy feed", "attack", 0.12], ["Overcharger", "damage", 0.12]],
	[["Light frame", "speed", 0.02], ["Quick release", "cooldown", 0.03], ["Long stride", "speed", 0.025], ["Quickloader", "haste", 0.04], ["Tenacity", "tenacity", 0.1], ["Slipstream", "resistance", 2], ["Cruise drive", "speed", 0.07], ["Short circuit", "cooldown", 0.12]],
	[["Hull plating", "health", 6], ["Impact brace", "resistance", 3], ["Repair mesh", "health_regen", 0.15], ["Deep chassis", "health", 8], ["Shock pads", "resistance", 4], ["Repair loop", "health_regen", 0.2], ["Fortress", "health", 24], ["Self sealing", "health_regen", 0.6]],
	[["Spare cell", "energy", 8], ["Cooling fins", "regen", 0.4], ["Capacitor", "energy", 10], ["Recycling loop", "regen", 0.5], ["Rapid vent", "cooldown", 0.04], ["Field amplifier", "damage", 0.04], ["Deep reserves", "energy", 30], ["Closed loop", "regen", 1.5]],
	[["Long reach", "magnet", 25], ["Fast learner", "xp", 0.06], ["Lucky find", "luck", 0.12], ["Wide sweep", "magnet", 30], ["Sorter", "xp", 0.08], ["Scavenger", "luck", 0.15], ["Tractor field", "magnet", 90], ["Windfall", "luck", 0.5]],
	[["Signal gain", "summon_damage", 0.06], ["Long battery", "duration", 0.08], ["Linked reactor", "regen", 0.5], ["Support frame", "health", 8], ["Relay power", "summon_damage", 0.08], ["Reserve battery", "duration", 0.1], ["Parallel command", "capacity", 1], ["Command core", "summon_damage", 0.2]],
]
static var TREE: Dictionary = make_nodes()

static func make_nodes() -> Dictionary:
	var nodes := {}
	for branch in range(6):
		for index in range(8):
			var s: Array = ROUTES[branch][index]
			var id := "b%d_%d" % [branch, index]
			nodes[id] = {"name": s[0], "stat": s[1], "value": float(s[2]), "branch": branch, "index": index, "max": 1 if index >= 6 or s[1] in ["shock", "aftershock"] else 3, "parent": "" if index < 2 else "b%d_%d" % [branch, index - 2]}
	return nodes

func available(power_level: int) -> int:
	return maxi(0, 1 + (power_level - 1) * 2 - spent)

func value(stat: String) -> float:
	var total := 0.0
	for id in ranks:
		if TREE.has(id) and TREE[id].stat == stat: total += TREE[id].value * int(ranks[id])
	return total

func rank_of(id: String) -> int:
	if id == "shock": return int(value("shock"))
	if id == "aftershock": return int(value("aftershock"))
	return int(ranks.get(id, 0))

func can_buy(id: String, power_level: int) -> bool:
	if read_only or not TREE.has(id) or available(power_level) < 1: return false
	var node: Dictionary = TREE[id]
	return rank_of(id) < node.max and (node.parent.is_empty() or rank_of(node.parent) > 0)

func buy(run, id: String) -> bool:
	if run.state not in ["running", "upgrade", "stage_reward", "chest", "camp"] or not can_buy(id, run.level): return false
	ranks[id] = rank_of(id) + 1; spent += 1
	run.exp.sync_stats(run)
	return true

func refund(run) -> bool:
	if run.state != "camp": return false
	ranks.clear(); spent = 0
	run.exp.sync_stats(run)
	return true

static func text(id: String, vanguard: bool=false) -> String:
	var node: Dictionary = TREE[id]
	var stat: String = node.stat
	if vanguard and stat=="luck": return "+%d%% relative special-drop chance per rank. Shared cap: 5× base chance."%roundi(node.value*400)
	if vanguard and stat=="magnet": return "+%d pickup radius per rank. Maximum: %d."%[node.value,Vanguard.TURRET_RANGE]
	if stat == "shock": return "Impact bolt and Arc coil stun ordinary enemies for 0.35s."
	if stat == "aftershock": return "Impact bolt releases a wider 12-damage aftershock."
	var percent := stat in ["attack", "damage", "haste", "speed", "cooldown", "tenacity", "xp", "luck", "summon_damage", "duration"]
	return "+%s%s %s per rank." % [str(snappedf(node.value * (100 if percent else 1), 0.01)), "%" if percent else "", "recharge speed" if stat == "cooldown" else stat.replace("_", " ")]
