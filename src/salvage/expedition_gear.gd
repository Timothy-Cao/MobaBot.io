class_name ExpeditionGear
extends RefCounted
## Separate v2 file; legacy collection is read-only and its exact snapshot is retained.
const PATH := "user://mobabot_expedition.json"
const SLOTS := ["helmet", "chest", "legs", "boots", "charm", "ring", "flower", "cape"]
const SETS := ["courier", "bastion", "dynamo", "relay", "reclaimer"]
const SET_TEXT := {
	"courier": "2: +6% move speed. 4: commanded hits charge the next basic every 5s.",
	"bastion": "2: +12 hull, +8 resistance. 4: one-hit barrier every 12s while enemies are close.",
	"dynamo": "2: +20 energy, +1 energy/sec. 4: every 80 energy spent releases a 25-damage pulse (3s limit).",
	"relay": "2: +20% summon duration. 4: +1 major summon capacity and +15% summon damage.",
	"reclaimer": "2: +50 pickup radius, +20% drop odds. 4: opening a chest repairs 8% hull."}
const AFFIXES := {"health": 2.0, "damage": 0.006, "regen": 0.15, "luck": 0.025, "resistance": 1.0}
var credits := 150
var unlocked_ascension := 0
var inventory: Dictionary = {}
var equipped: Dictionary = {}
var checkpoint: Dictionary = {}
var migration: Dictionary = {}
var loadouts: Dictionary = {}
var blocked := false
var message := ""
var rng := RandomNumberGenerator.new()
var path := PATH
static var ITEMS: Dictionary = make_items()

static func make_items() -> Dictionary:
	var items := {}
	for set_id in SETS:
		for slot in SLOTS:
			var tier := 0 if SLOTS.find(slot) < 4 else (1 if slot in ["charm", "ring"] else 2)
			var stat: String = {"helmet": "health", "chest": "resistance", "legs": "health", "boots": "speed", "charm": "damage", "ring": "attack", "flower": "health_regen", "cape": "energy"}[slot]
			var value: float = {"helmet": 5.0, "chest": 4.0, "legs": 5.0, "boots": 0.025, "charm": 0.035, "ring": 0.04, "flower": 0.18, "cape": 10.0}[slot]
			items[set_id + "_" + slot] = {"name": set_id.capitalize() + " " + {"chest": "plate", "legs": "greaves", "flower": "bloom", "cape": "mantle"}.get(slot, slot), "slot": slot, "set": set_id, "tier": tier, "stat": stat, "value": value, "icon": "gear_" + set_id + "_" + slot}
	return items

func _init() -> void:
	rng.randomize()
	for id in ITEMS: inventory[id] = {"copies": 0, "stars": 0, "bonus": "health", "roll": 1}
	for slot in SLOTS: equipped[slot] = ""
	for slot in ["helmet", "chest", "boots"]:
		inventory["courier_" + slot].copies = 1
		equipped[slot] = "courier_" + slot

static func roll_item(random: RandomNumberGenerator, ascension: int) -> String:
	var set_id: String = SETS[random.randi_range(0, 4)]
	var roll := random.randf()
	var slot: String
	if roll < 0.04 + ascension * 0.006: slot = ["flower", "cape"][random.randi_range(0,1)]
	elif roll < 0.25: slot = ["charm", "ring"][random.randi_range(0,1)]
	else: slot = SLOTS[random.randi_range(0,3)]
	return set_id + "_" + slot

func snapshot() -> Dictionary:
	return {"version": 2, "credits": credits, "ascension": unlocked_ascension, "inventory": inventory.duplicate(true), "equipped": equipped.duplicate(), "checkpoint": checkpoint.duplicate(true), "migration": migration.duplicate(true), "loadouts": loadouts.duplicate(true)}

func valid(data: Variant) -> bool:
	if not data is Dictionary or data.get("version") != 2: return false
	for key in ["inventory", "equipped", "checkpoint", "migration"]:
		if not data.get(key) is Dictionary: return false
	for key in ["credits", "ascension"]:
		if not integer(data.get(key), 0, 10000000 if key == "credits" else 5): return false
	for id in ITEMS:
		var item: Variant = data.inventory.get(id)
		if not item is Dictionary or not AFFIXES.has(item.get("bonus", "")): return false
		if not integer(item.get("copies"), 0, 999) or not integer(item.get("stars"), 0, 5) or not integer(item.get("roll"), 1, 5): return false
	for slot in SLOTS:
		var id: Variant = data.equipped.get(slot)
		if not id is String: return false
		if id != "" and (not ITEMS.has(id) or ITEMS[id].slot != slot or data.inventory[id].copies < 1): return false
	if not data.checkpoint.is_empty() and not valid_checkpoint(data.checkpoint): return false
	if not data.get("loadouts", {}) is Dictionary: return false
	for id in data.get("loadouts", {}):
		if not BotExpedition.CLASSES.has(id) or not MobaKit.valid_loadout(data.loadouts[id]): return false
	return true

static func integer(value: Variant, low: int, high: int) -> bool:
	return (value is float or value is int) and is_finite(value) and value == floorf(value) and value >= low and value <= high

static func valid_checkpoint(c: Dictionary) -> bool:
	if not integer(c.get("route"), 0, 21) or not integer(c.get("ascension"), 0, 5) or not BotExpedition.CLASSES.has(c.get("class", "")): return false
	if not MobaKit.valid_loadout(c.get("loadout", {})): return false
	for key in ["ranks", "tiers", "upgrades", "tree", "stats", "sets"]:
		if not c.get(key) is Dictionary: return false
	for key in ["level", "xp", "next", "spent", "pending", "opened", "field", "seed"]:
		if not integer(c.get(key), 0, 2147483647): return false
	if c.level < 1 or c.next < 1: return false
	if not c.get("discovered") is Array or not c.get("items") is Array: return false
	if not c.get("toggles") is Array or c.toggles.size() != 4: return false
	for enabled in c.toggles:
		if not enabled is bool: return false
	for key in ["sniper", "orbit_far", "arc_focused"]:
		if not c.get(key) is bool: return false
	if not integer(c.get("converter"), 0, 1): return false
	for slot in c.discovered:
		if slot not in MobaKit.BIND_SLOTS: return false
	for slot in MobaKit.SLOTS:
		if not integer(c.ranks.get(slot), 0, 10) or not integer(c.tiers.get(slot), 0, 2): return false
	for id in c.tree:
		if not ExpeditionTree.TREE.has(id) or not integer(c.tree[id], 0, ExpeditionTree.TREE[id].max): return false
	var spent := 0
	for id in c.tree:
		spent += int(c.tree[id])
		var parent: String = ExpeditionTree.TREE[id].parent
		if c.tree[id] > 0 and parent != "" and c.tree.get(parent,0) <= 0: return false
	if spent != c.spent or spent > 1 + (c.level-1)*2: return false
	for id in c.upgrades:
		if id not in SalvageRun.UPGRADES and id not in ["skill_q","skill_w","skill_e","skill_r","skill_d","skill_f","skill_t"]: return false
		if not integer(c.upgrades[id],0,10): return false
	for id in SalvageRun.UPGRADES:
		if not c.upgrades.has(id): return false
	for slot in MobaKit.SLOTS:
		if c.upgrades.get("skill_"+slot) != c.ranks[slot]: return false
	for stat in c.stats:
		if stat not in ["health","resistance","health_regen","damage","attack","haste","range","speed","cooldown","tenacity","energy","regen","magnet","xp","luck","summon_damage","duration","capacity"]: return false
		if not (c.stats[stat] is int or c.stats[stat] is float) or not is_finite(c.stats[stat]) or c.stats[stat] < 0 or c.stats[stat] > 1000: return false
	for id in c.sets:
		if id not in SETS or not integer(c.sets[id],0,8): return false
	for id in c.items:
		if not ITEMS.has(id): return false
	for key in ["health", "energy"]:
		if not (c.get(key) is float or c.get(key) is int) or not is_finite(c[key]) or c[key] < 0 or c[key] > 10000: return false
	if not c.get("consumables") is Array or c.consumables.size()!=2: return false
	for count in c.consumables:
		if not integer(count,0,99): return false
	for key in ["rng","offers_rng","loot_rng"]:
		if not c.get(key) is String or not c[key].is_valid_int(): return false
	if not c.get("shop") is Array: return false
	for id in c.shop:
		if id != "" and not ITEMS.has(id): return false
	if c.shop.size()>3 or c.pending>99 or c.level>1000: return false
	if not integer(c.get("kills",0),0,10000000): return false
	if not (c.get("time",0) is float or c.get("time",0) is int) or not is_finite(c.get("time",0)) or c.get("time",0)<0 or c.get("time",0)>1000000: return false
	if not c.get("equipment",[]) is Array: return false
	for item in c.get("equipment",[]):
		if not item is Dictionary: return false
		for key in ["name","slot","icon","stats"]:
			if not item.get(key) is String: return false
		if not integer(item.get("stars"),0,5): return false
	return true

func restore(data: Dictionary) -> void:
	credits = int(data.credits); unlocked_ascension = int(data.ascension)
	inventory = data.inventory.duplicate(true); equipped = data.equipped.duplicate()
	checkpoint = data.checkpoint.duplicate(true); migration = data.migration.duplicate(true)
	loadouts = data.get("loadouts", {}).duplicate(true)

func load_profile() -> void:
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null: blocked = true; message = "Save unreadable. Original preserved."; return
		var data: Variant = JSON.parse_string(file.get_as_text())
		if valid(data): restore(data)
		else: blocked = true; message = "Save damaged. Original preserved."
		return
	var legacy := BotEquipment.new()
	legacy.load_profile()
	if legacy.save_blocked: blocked = true; message = legacy.message; return
	if not FileAccess.file_exists(BotEquipment.PATH): return
	credits = legacy.credits
	var mapping := {"coil": "dynamo_charm", "reactor": "dynamo_ring", "rack": "bastion_chest", "shell": "bastion_helmet", "jets": "courier_boots", "rotor": "courier_legs"}
	for old in mapping:
		var item: Dictionary = legacy.inventory[old]
		inventory[mapping[old]] = item.duplicate()
		if inventory[mapping[old]].bonus == "drop": inventory[mapping[old]].bonus = "luck"
		if old in legacy.equipped.values(): equipped[ITEMS[mapping[old]].slot] = mapping[old]
	migration = {"source": BotEquipment.PATH, "mapping": mapping, "original": legacy.snapshot()}
	message = "Legacy collection imported. Original save preserved."

func save() -> bool:
	if blocked or not valid(snapshot()): return false
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(snapshot())); file.flush()
	var ok := file.get_error() == OK
	file.close()
	if not ok: return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(path + ".tmp"), ProjectSettings.globalize_path(path)) == OK

func transact(action: String, id: String, persist: bool = true) -> bool:
	if blocked or not ITEMS.has(id) or inventory[id].copies < 1: return false
	var before := snapshot()
	var item: Dictionary = inventory[id]
	match action:
		"equip": equipped[ITEMS[id].slot] = id
		"reroll":
			if credits < 35: message = "35 credits required"; return false
			credits -= 35; item.bonus = AFFIXES.keys()[rng.randi_range(0, AFFIXES.size() - 1)]; item.roll = rng.randi_range(1,5)
		"star":
			var needed := int(item.stars) + 1
			if needed > 5 or item.copies <= needed or credits < needed * 25: message = "Max stars" if needed > 5 else "%d credits · %d spare copies" % [needed * 25, needed]; return false
			credits -= needed * 25; item.copies -= needed; item.stars += 1
		_: return false
	if persist and not save(): restore(before); message = "Save failed. Nothing spent."; return false
	message = ""
	return true

func values(id: String) -> Dictionary:
	var data: Dictionary = ITEMS[id]
	var item: Dictionary = inventory[id]
	var result := {data.stat: data.value * (1 + int(item.stars) * 0.2)}
	result[item.bonus] = float(result.get(item.bonus, 0)) + AFFIXES[item.bonus] * int(item.roll)
	# High-tier pieces carry an individual specialty, even without their set.
	if data.tier >= 1:
		var stat: String = {"courier": "haste", "bastion": "resistance", "dynamo": "regen", "relay": "summon_damage", "reclaimer": "luck"}[data.set]
		result[stat] = float(result.get(stat, 0)) + {"courier": 0.06, "bastion": 6.0, "dynamo": 0.8, "relay": 0.1, "reclaimer": 0.12}[data.set] * data.tier
	return result

func item_text(id: String) -> String:
	var lines: Array[String] = []
	for key in values(id):
		var percent: bool = key in ["damage", "attack", "speed", "haste", "luck", "summon_damage"]
		lines.append("+%s%s %s" % [str(snappedf(values(id)[key] * (100 if percent else 1), 0.01)), "%" if percent else "", key.replace("_", " ")])
	lines.append(SET_TEXT[ITEMS[id].set])
	return "\n".join(lines)

func apply_to(run) -> void:
	var total := {}
	var counts := {}
	run.equipment_snapshot.clear()
	for id in equipped.values():
		if id == "": continue
		for key in values(id): total[key] = float(total.get(key, 0)) + values(id)[key]
		var data: Dictionary = ITEMS[id]
		counts[data.set] = int(counts.get(data.set, 0)) + 1
		run.equipment_snapshot.append({"name": data.name, "slot": data.slot, "icon": data.icon, "stars": int(inventory[id].stars), "stats": item_text(id)})
	var bonuses := {"courier": {"speed": 0.06}, "bastion": {"health": 12, "resistance": 8}, "dynamo": {"energy": 20, "regen": 1}, "relay": {"duration": 0.2}, "reclaimer": {"magnet": 50, "luck": 0.2}}
	for set_id in counts:
		if counts[set_id] >= 2:
			for key in bonuses[set_id]: total[key] = float(total.get(key, 0)) + bonuses[set_id][key]
		if counts[set_id] >= 4 and set_id == "relay": total.capacity = 1; total.summon_damage = float(total.get("summon_damage", 0)) + 0.15
	run.exp.gear_stats = total; run.exp.set_counts = counts
	run.exp.sync_stats(run)

func pack_run(run) -> Dictionary:
	return {
		"route": run.exp.route_index, "ascension": run.exp.ascension, "class": run.exp.class_id,
		"loadout": run.kit.loadout.duplicate(true), "discovered": run.kit.discovered.duplicate(),
		"ranks": run.kit.ranks.duplicate(), "tiers": run.kit.tiers.duplicate(), "upgrades": run.upgrades.duplicate(),
		"tree": run.mastery.ranks.duplicate(), "spent": run.mastery.spent,
		"level": run.level, "xp": run.total_xp, "next": run.next_level, "health": run.health, "energy": run.kit.energy,
		"pending": run.exp.pending_chests, "opened": run.exp.chests_opened, "field": run.exp.field_credits,
		"items": run.exp.pending_items.duplicate(), "stats": run.exp.gear_stats.duplicate(), "sets": run.exp.set_counts.duplicate(),
		"seed": run.run_seed, "consumables": run.consumables.duplicate(),
		"toggles": run.kit.toggles.duplicate(), "sniper": run.kit.gun_sniper, "orbit_far": run.kit.orbit_far,
		"arc_focused": run.kit.arc_focused, "converter": run.kit.extra.converter_mode,
		"rng": str(run.spawn_rng.state), "offers_rng": str(run.offer_rng.state), "loot_rng": str(run.loot_rng.state),
		"shop": run.exp.shop_stock.duplicate(), "time": run.time, "kills": run.kills, "equipment": run.equipment_snapshot.duplicate(true)}

func bank_camp(run, persist: bool = true) -> bool:
	if run.state != "camp" or blocked: return false
	var before := snapshot()
	credits = mini(10000000, credits + int(run.exp.carry_credits * (1 + run.exp.ascension * 0.1)))
	for id in run.exp.pending_items: inventory[id].copies = mini(999, inventory[id].copies + 1)
	checkpoint = pack_run(run)
	checkpoint.items = []
	if persist and not save(): restore(before); message = "Save failed. Rewards remain unbanked."; return false
	run.exp.carry_credits = 0; run.exp.pending_items.clear()
	message = ""
	return true

func resume_into(run) -> bool:
	if checkpoint.is_empty() or not valid_checkpoint(checkpoint): return false
	var c := checkpoint
	var expedition := BotExpedition.new()
	expedition.start(run, c.class, int(c.ascension))
	expedition.route_index = int(c.route); expedition.gear_stats = c.stats.duplicate(); expedition.set_counts = c.sets.duplicate()
	run.kit.loadout = c.loadout.duplicate(true); run.kit.discovered = c.discovered.duplicate()
	run.kit.ranks = c.ranks.duplicate(); run.kit.tiers = c.tiers.duplicate(); run.upgrades = c.upgrades.duplicate()
	run._sync_resource_ranks()
	run.kit.toggles.assign(c.toggles); run.kit.gun_sniper = c.sniper; run.kit.orbit_far = c.orbit_far
	run.kit.arc_focused = c.arc_focused; run.kit.extra.converter_mode = int(c.converter)
	for slot in MobaKit.SLOTS:
		run.kit.charges[slot] = int(MobaKit.ABILITIES[run.kit.loadout[slot]].max)
		run.kit.recharge[slot] = 0.0
	run.mastery.ranks = c.tree.duplicate(); run.mastery.spent = int(c.spent)
	run.level = int(c.level); run.total_xp = int(c.xp); run.next_level = int(c.next)
	expedition.pending_chests = int(c.pending); expedition.chests_opened = int(c.opened); expedition.field_credits = int(c.field)
	expedition.pending_items.assign(c.items)
	expedition.sync_stats(run)
	run.health = minf(run.max_health(), c.health); run.kit.energy = minf(run.kit.energy_max(), c.energy)
	run.state = "camp"; expedition.clear_clock = -2
	run.consumables.assign(c.consumables)
	run.spawn_rng.state=int(c.rng); run.offer_rng.state=int(c.offers_rng); run.loot_rng.state=int(c.loot_rng)
	expedition.shop_stock.assign(c.shop)
	run.time=float(c.get("time",0)); run.kills=int(c.get("kills",0))
	run.equipment_snapshot.assign(c.get("equipment",[]))
	return true
