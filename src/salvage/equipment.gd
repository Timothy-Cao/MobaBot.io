class_name BotEquipment
extends RefCounted
## Persistent local collection. Each type shares its own stars/bonus across copies.
const PATH := "user://mobabot_equipment.json"
const ITEM_ORDER := ["coil", "rack", "jets", "reactor", "shell", "rotor"]
const ITEMS := {
	"coil": {"name": "Pulse core", "slot": "Core", "icon": "pulse", "base": 0.04, "stat": "damage"},
	"reactor": {"name": "Heavy core", "slot": "Core", "icon": "pulse", "base": 0.08, "stat": "damage"},
	"rack": {"name": "Tool chassis", "slot": "Chassis", "icon": "chassis-v1", "base": 10.0, "stat": "energy"},
	"shell": {"name": "Flux chassis", "slot": "Chassis", "icon": "chassis-v1", "base": 20.0, "stat": "energy"},
	"jets": {"name": "Skate drive", "slot": "Drive", "icon": "drive-v1", "base": 0.03, "stat": "speed"},
	"rotor": {"name": "Rotor drive", "slot": "Drive", "icon": "drive-v1", "base": 0.06, "stat": "speed"}}
var credits := 150
var inventory: Dictionary = {}
var equipped := {"Core": "coil", "Chassis": "rack", "Drive": "jets"}
var rng := RandomNumberGenerator.new()
var message := "Changes apply next run."
var save_blocked := false

func _init() -> void:
	rng.randomize()
	for id in ITEMS:
		inventory[id] = {"copies": 2 if id in equipped.values() else 0, "stars": 0, "bonus": "regen", "roll": 1}

func snapshot() -> Dictionary:
	return {"version": 1, "credits": credits, "inventory": inventory.duplicate(true), "equipped": equipped.duplicate()}

func valid(data: Variant) -> bool:
	if not data is Dictionary or data.get("version") != 1 or not data.get("inventory") is Dictionary or not data.get("equipped") is Dictionary: return false
	if not (data.get("credits") is float or data.get("credits") is int): return false
	if data.credits < 0 or data.credits > 10000000: return false
	for id in ITEMS:
		var item: Variant = data.inventory.get(id)
		if not item is Dictionary: return false
		for key in ["copies", "stars", "roll"]:
			if not (item.get(key) is float or item.get(key) is int): return false
			if not is_finite(float(item[key])) or float(item[key]) != floorf(float(item[key])): return false
		if item.copies < 0 or item.copies > 999 or item.stars < 0 or item.stars > 5 or item.roll < 1 or item.roll > 5 or item.get("bonus") not in ["regen", "damage", "drop"]: return false
	for slot in equipped:
		var id: String = str(data.equipped.get(slot, ""))
		if not ITEMS.has(id) or ITEMS[id].slot != slot or data.inventory[id].copies < 1: return false
	return true

func restore(data: Dictionary) -> void:
	credits = int(data.credits)
	inventory = data.inventory.duplicate(true)
	for id in inventory:
		for key in ["copies", "stars", "roll"]: inventory[id][key] = int(inventory[id][key])
	equipped = data.equipped.duplicate()

func load_profile(path: String = PATH) -> void:
	if not FileAccess.file_exists(path): return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		save_blocked = true
		message = "Cannot read equipment save. Original preserved."
		return
	var data: Variant = JSON.parse_string(file.get_as_text())
	if valid(data): restore(data)
	else:
		save_blocked = true
		message = "Equipment save is damaged. Original preserved."

func save_profile(path: String = PATH) -> bool:
	if save_blocked: return false
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(snapshot()))
	file.flush()
	var ok := file.get_error() == OK
	file.close()
	if not ok: return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(path + ".tmp"), ProjectSettings.globalize_path(path)) == OK

func transact(action: String, id: String, persist: bool = true) -> bool:
	if save_blocked or not ITEMS.has(id) or inventory[id].copies < 1: return false
	var before := snapshot()
	var item: Dictionary = inventory[id]
	match action:
		"equip": equipped[ITEMS[id].slot] = id
		"reroll":
			if credits < 35:
				message = "Need 35 credits."
				return false
			credits -= 35
			item.bonus = ["regen", "damage", "drop"][rng.randi_range(0, 2)]
			item.roll = rng.randi_range(1, 5)
		"star":
			var cost := 25 * (int(item.stars) + 1)
			var duplicates := int(item.stars) + 1
			if item.stars >= 5 or credits < cost or item.copies <= duplicates:
				message = "Max stars." if item.stars >= 5 else "Need %d credits and %d spare copies." % [cost, duplicates]
				return false
			credits -= cost
			item.copies -= duplicates
			item.stars += 1
		_: return false
	if persist and not save_profile():
		restore(before)
		message = "Save failed. Nothing spent."
		return false
	message = {"equip": "Equipped for next run.", "reroll": "Bonus rerolled.", "star": "Star added."}[action]
	return true

func award(amount: int, level_number: int, persist: bool = true) -> bool:
	var before := snapshot()
	credits = mini(10000000, credits + maxi(0, amount))
	var id: String = ITEMS.keys()[rng.randi_range(0, ITEMS.size() - 1)]
	if level_number > 0:
		inventory[id].copies = mini(999, int(inventory[id].copies) + 1)
		message = "Recovered: " + ITEMS[id].name
	if persist and not save_profile():
		restore(before)
		message = "Equipment save failed. Rewards not banked."
		return false
	return true

func primary(id: String) -> float:
	return float(ITEMS[id].base) * (1.0 + int(inventory[id].stars) * 0.20)

func stats_for(id: String) -> Dictionary:
	var values := {"damage": 0.0, "energy": 0.0, "speed": 0.0, "regen": 0.0, "drop": 0.0}
	values[ITEMS[id].stat] = primary(id)
	var item: Dictionary = inventory[id]
	values[item.bonus] += item.roll * {"regen": 0.2, "damage": 0.01, "drop": 0.05}[item.bonus]
	return values

func compare_to_fitted(id: String) -> Dictionary:
	var current := stats_for(equipped[ITEMS[id].slot])
	var candidate := stats_for(id)
	var differences := {}
	for stat in current:
		var delta: float = candidate[stat] - current[stat]
		if not is_zero_approx(delta): differences[stat] = delta
	return differences

func item_text(id: String) -> String:
	var data: Dictionary = ITEMS[id]
	var base := "+%d energy" % primary(id) if data.stat == "energy" else "+%.1f%% %s" % [primary(id) * 100, "ability damage" if data.stat == "damage" else "move speed"]
	var item: Dictionary = inventory[id]
	var bonus := {"regen": "+%.1f energy/sec" % (item.roll * 0.2), "damage": "+%d%% ability damage" % item.roll, "drop": "+%d%% bonus drop chance" % (item.roll * 5)}
	return base + "\n" + bonus[item.bonus]

func apply_to(run) -> void:
	for id in equipped.values():
		run.equipment_snapshot.append({"name": ITEMS[id].name, "slot": ITEMS[id].slot, "icon": ITEMS[id].icon, "stars": inventory[id].stars, "stats": item_text(id)})
		match ITEMS[id].stat:
			"damage": run.kit.gear_damage += primary(id)
			"energy": run.kit.energy_bonus += primary(id)
			"speed": run.kit.gear_speed += primary(id)
		var item: Dictionary = inventory[id]
		match item.bonus:
			"regen": run.kit.regen_bonus += item.roll * 0.2
			"damage": run.kit.gear_damage += item.roll * 0.01
			"drop": run.drop_bonus += item.roll * 0.05
	run.kit.energy = run.kit.energy_max()
