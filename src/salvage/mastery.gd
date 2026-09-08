class_name BotMastery
extends RefCounted
## Run-only points. Never interrupt combat with a purchase prompt.
const NODES := {
	"reach": {"name": "Long reach", "icon": "magnet", "branch": 0, "row": 0, "max": 3, "parent": "", "text": "+35 pickup radius per point."},
	"learning": {"name": "Fast learner", "icon": "cell", "branch": 0, "row": 1, "max": 3, "parent": "reach", "text": "+10% scrap XP per point. Fractional XP carries over."},
	"fortune": {"name": "Lucky find", "icon": "ricochet", "branch": 0, "row": 2, "max": 3, "parent": "learning", "text": "+25% relative bonus-drop chance per point."},
	"hull": {"name": "Reinforced", "icon": "capacity", "branch": 1, "row": 0, "max": 3, "parent": "", "text": "+1 maximum hull and restore 1 hull per point."},
	"recovery": {"name": "Second wind", "icon": "reactor", "branch": 1, "row": 1, "max": 3, "parent": "hull", "text": "+1 energy regeneration per second per point."},
	"resolve": {"name": "Unstoppable", "icon": "jets", "branch": 1, "row": 2, "max": 1, "parent": "recovery", "text": "Enemy slows last half as long. D restores 1 hull."},
	"focus": {"name": "Hot core", "icon": "power", "branch": 2, "row": 0, "max": 3, "parent": "", "text": "+6% active ability damage per point."},
	"shock": {"name": "Static lock", "icon": "lightning", "branch": 2, "row": 1, "max": 1, "parent": "focus", "text": "Arc Coil and Impact bolt direct hits stun ordinary enemies for 0.35s. Bosses resist stuns."},
	"aftershock": {"name": "Aftershock", "icon": "pulse", "branch": 2, "row": 2, "max": 1, "parent": "shock", "text": "Q explosions release a second, wider 12-damage shockwave."},
}
var ranks: Dictionary = {}
var spent := 0
var read_only := false

func rank_of(id: String) -> int:
	return int(ranks.get(id, 0))

func available(power_level: int) -> int:
	return maxi(0, 1 + (power_level - 1) / 2 - spent)

func can_buy(id: String, power_level: int) -> bool:
	if read_only or not NODES.has(id) or available(power_level) <= 0: return false
	var node: Dictionary = NODES[id]
	return rank_of(id) < node.max and (node.parent.is_empty() or rank_of(node.parent) > 0)

func buy(run, id: String) -> bool:
	if run.state not in ["running", "upgrade", "stage_reward"] or not can_buy(id, run.level): return false
	ranks[id] = rank_of(id) + 1
	spent += 1
	match id:
		"hull": run.health += 1
		"recovery": run.kit.regen_bonus += 1
		"fortune": run.drop_bonus += 0.25
		"focus": run.kit.mastery_damage += 0.06
	run.emit_event("equipped", run.player, {"id": id})
	return true
