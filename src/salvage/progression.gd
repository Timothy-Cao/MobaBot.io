class_name SalvageProgression
extends RefCounted
## Main-mode rank curves. Legacy sample formulas remain in SalvageRun.
const WEAPONS := ["power", "rapid", "grinder", "ricochet", "pulse", "capacity", "reactor", "cell"]

static func bonus(rank_value: int) -> float:
	return 0.0 if rank_value <= 0 else 0.15 + 0.05 * mini(rank_value, 10)

static func milestone(rank_value: int) -> int:
	return mini(2, rank_value / 5)

static func multiplier(rank_value: int) -> float:
	return 1.0 + bonus(rank_value) + milestone(rank_value) * 0.25

static func data(run, id: String) -> Dictionary:
	if id.begins_with("skill_"):
		var slot := id.trim_prefix("skill_")
		return {"name": MobaKit.ABILITIES[run.kit.loadout[slot]].name, "tag": "%s / ABILITY" % slot.to_upper(), "max": 10, "description": "Numerical ranks. Milestones at 5 and 10."}
	var result: Dictionary = run.UPGRADES.get(id, {"name": "Repair", "description": "Restore one hull.", "tag": "HULL", "max": 1}).duplicate()
	if id == "power" and run.kit != null and run.kit.has_passive("lightning"): result.name = "Weapon power"
	if id in WEAPONS:
		result.max = 10
		result.description = "Numerical ranks. Milestones at 5 and 10."
	elif id == "magnet":
		result.max = 5
		result.tag = "UTILITY / FREE"
		result.description = "Free at start, then every 3 level-ups."
	return result

static func note(run, id: String, r: int) -> String:
	var m := milestone(r)
	if id == "power" and run.kit != null and run.kit.has_passive("lightning"):
		return "5 / 10: +25% / +50% weapon damage. Auto bolt also gains +1 / +2 pierces." if run.kit.has_passive("bolt") else "5 / 10: +25% / +50% lightning damage."
	if id == "magnet":
		return "Rank 5: 180 px reach. Bonus drops require close collection." if run.kit.onboarding else "Rank 5: sweep all scrap every 15s."
	if id.begins_with("skill_"):
		var slot := id.trim_prefix("skill_")
		var ability: String = run.kit.loadout[slot]
		if ability in ["rocket", "flame", "nuke"]: return "5 / 10: effect size +25% / +50%."
		if ability == "laser": return "5 / 10: cutter width +25% / +50%; twin outer rails."
		return {"salvo": "5 / 10: volley fires 7 / 9 bolts.", "nova": "5 / 10: ring radius +25% / +50%.", "mortar": "5 / 10: blast radius +25% / +50%.", "beam": "5 / 10: beam width +25% / +50%.", "rail": "5 / 10: +2 / +4 pierces; gold core.", "shield": "5 / 10: blocks 2 / 3 hits.", "sprint": "5 / 10: lasts 4 / 5 seconds.", "blink": "5 / 10: range +25% / +50%.", "dash": "5 / 10: range +25% / +50%.", "lunge": "5 / 10: range +25% / +50%.", "overdrive": "5 / 10: radius +25% / +50%.", "turret": "5 / 10: sentry fires 25% / 50% faster.", "pylon": "5 / 10: heal radius +50% / +100%.", "sacrifice": "5 / 10: restores 70 / 85 energy."}.get(ability, "")
	return {"power": "5 / 10: +25% / +50% damage, +1 / +2 pierces.", "rapid": "5 / 10: +25% / +50% firing speed.", "grinder": "5 / 10: larger orbit, +1 / +2 tool hits.", "ricochet": "5 / 10: +2 / +4 extra bounces.", "pulse": "5 / 10: +25% / +50% pulse radius.", "capacity": "5 / 10: +2 / +4 extra tool slots.", "reactor": "5 / 10: +2 / +4 extra energy/sec.", "cell": "5 / 10: +20 / +40 extra capacity."}.get(id, "")

static func values(run, id: String, r: int) -> Array[Dictionary]:
	var b := bonus(r)
	var m := milestone(r)
	if id.begins_with("skill_"):
		var slot := id.trim_prefix("skill_")
		var combat := MobaKit.deals_damage(run.kit.loadout[slot])
		var effects := {
			"laser": ["Beam width", 46 * (1 + m * 0.25), " px"],
			"rocket": ["Blast radius", 62 * (1 + m * 0.25), " px"], "flame": ["Cone reach", 190 * (1 + m * 0.25), " px"], "nuke": ["Blast radius", 135 * (1 + m * 0.25), " px"],
			"salvo": ["Bolts / volley", 5 + m * 2, ""], "nova": ["Radius", 155 * (1 + m * 0.25), " px"],
			"mortar": ["Blast radius", 90 * (1 + m * 0.25), " px"], "beam": ["Beam width", 56 * (1 + m * 0.25), " px"],
			"rail": ["Targets pierced", 4 + m * 2, ""], "shield": ["Hits blocked", 1 + m, ""],
			"sprint": ["Duration", 3 + m, "s"], "blink": ["Range", 185 * (1 + m * 0.25), " px"],
			"dash": ["Range", 220 * (1 + m * 0.25), " px"], "lunge": ["Range", 170 * (1 + m * 0.25), " px"],
			"overdrive": ["Radius", 180 * (1 + m * 0.25), " px"], "turret": ["Sentry shots/sec", snappedf((1 + m * 0.25) / 0.6, 0.01), ""],
			"pylon": ["Heal radius", 100 * (1 + m * 0.5), " px"], "sacrifice": ["Energy restored", 55 + m * 15, ""]}
		var effect: Array = effects[run.kit.loadout[slot]]
		return [{"label": "Damage bonus" if combat else "Recharge cut", "value": snappedf(b * (100 if combat else 50), 0.1), "unit": "%"}, {"label": effect[0], "value": effect[1], "unit": effect[2]}, {"label": "Recharge", "value": snappedf(run.kit.cooldown_at(slot, r), 0.01), "unit": "s"}]
	match id:
		"power":
			if run.kit != null and run.kit.has_passive("lightning"):
				return [{"label": "Damage bonus", "value": roundi(b * 100), "unit": "%"}, {"label": "Arc damage", "value": snappedf(7 * multiplier(r), 0.01), "unit": ""}, {"label": "Bolt damage" if run.kit.has_passive("bolt") else "Focused arc", "value": snappedf((2 if run.kit.has_passive("bolt") else 14) * multiplier(r), 0.01), "unit": ""}]
			return [{"label": "Damage bonus", "value": roundi(b * 100), "unit": "%"}, {"label": "Bolt damage", "value": snappedf(2 * multiplier(r), 0.01), "unit": ""}, {"label": "Pierces", "value": m, "unit": ""}]
		"rapid": return [{"label": "Rate bonus", "value": roundi(b * 100), "unit": "%"}, {"label": "Shots / sec", "value": snappedf(multiplier(r) / 0.43, 0.01), "unit": ""}]
		"grinder": return [{"label": "Damage bonus", "value": roundi(b * 100), "unit": "%"}, {"label": "Damage", "value": snappedf(4 * multiplier(r), 0.01), "unit": ""}, {"label": "Hits / tool", "value": 1 + m, "unit": ""}]
		"ricochet": return [{"label": "Damage bonus", "value": roundi(b * 100), "unit": "%"}, {"label": "Shard damage", "value": snappedf(4 * multiplier(r), 0.01), "unit": ""}, {"label": "Bounces", "value": 1 + r / 2 + m * 2, "unit": ""}]
		"pulse": return [{"label": "Damage bonus", "value": roundi(b * 100), "unit": "%"}, {"label": "Pulse damage", "value": snappedf(5 * multiplier(r), 0.01), "unit": ""}, {"label": "Radius", "value": 108 * (1 + m * 0.25), "unit": " px"}]
		"capacity": return [{"label": "Tool slots", "value": 6 + r + m * 2, "unit": ""}]
		"reactor": return [{"label": "Regen / sec", "value": 8 + r + m * 2 + run.kit.regen_bonus, "unit": ""}]
		"cell": return [{"label": "Max energy", "value": 100 + r * 10 + m * 20 + run.kit.energy_bonus, "unit": ""}]
		"magnet": return [{"label": "Pickup radius", "value": 65 + r * 23 if run.kit != null and run.kit.onboarding else 150 + r * 100, "unit": " px"}, {"label": "Pull speed", "value": 800 + r * 180, "unit": " px/s"}]
	return [{"label": "Hull", "value": run.health, "unit": " / %d" % run.max_health()}]
