class_name MobaKit
extends RefCounted
## Data and simulation only. No retained owner reference, input or rendering.

const SLOTS := ["q", "w", "e", "r", "d", "f", "t"]
const BIND_SLOTS := ["q", "w", "e", "r", "d", "f", "t", "p1", "p2", "p3", "p4"]
const DEFAULT_BINDS := {"q": KEY_Q, "w": KEY_W, "e": KEY_E, "r": KEY_R, "d": KEY_D, "f": KEY_F, "t": KEY_T, "p1": KEY_1, "p2": KEY_2, "p3": KEY_3, "p4": KEY_4}
const ENERGY_COST := {"salvo": 14.0, "nova": 16.0, "shield": 20.0, "rail": 12.0, "mortar": 18.0, "lunge": 12.0, "overdrive": 30.0, "beam": 30.0, "turret": 20.0, "pylon": 24.0}
const UPKEEP := {"bolt": 2.0, "orbit": 2.0, "pulse": 3.0, "ricochet": 2.0, "plating": 2.0, "thorns": 1.0, "lightning": 4.0, "poison": 3.0, "sidebolts": 3.0, "plates": 3.0, "threehit": 3.0, "momentum": 3.0, "hopdrive": 2.0, "converter": 0.0, "mounted": 3.0}
const RARITIES := ["Common", "Rare", "Epic"]
const RARITY_COLORS := [Color("a0b3b7"), Color("69b9ed"), Color("c697eb")]
const LEGACY_PASSIVES := {
	"poison": {"name": "Coolant trail", "icon": "poison", "text": "Leave a 4-second coolant trail while powered. 8 damage/sec to enemies inside; overlapping patches do not stack. 3 energy/sec. Toggle off to stop laying trails. No self-damage."},
	"lightning": {"name": "Arc coil", "icon": "lightning", "text": "Cycle short-range chain lightning, long-range focused strikes and off. Expedition: 200 range / 0.9s chain; 440 range / 2.2s focused double damage. 4 energy/sec in either mode."},
	"bolt": {"name": "Auto gun", "icon": "power", "text": "Autonomous weapon, separate from basic attacks. Cycle machine gun, sniper and off. Machine gun: rapid short-range shots with spread. Sniper: slower, stronger, longer shots. Neither homes. S does not stop it."},
	"orbit": {"name": "Scrap orbit", "icon": "grinder", "text": "Collected scrap becomes orbiting tools."},
	"pulse": {"name": "Collection pulse", "icon": "pulse", "text": "Every 8 scrap releases a damaging pulse."},
	"ricochet": {"name": "Ricochet", "icon": "ricochet", "text": "Spent orbit tools become bouncing shards. Requires Scrap orbit."},
	"plating": {"name": "Reactive plating", "icon": "capacity", "text": "After taking damage, gain 0.65 seconds of extra invulnerability."},
	"thorns": {"name": "Recoil shell", "icon": "thorns", "text": "Taking hull damage releases a 6-damage ring in 100 radius."},
}
const LEGACY_ABILITIES := {
	"rocket": {"name": "Impact bolt", "category": "active", "icon": "power", "glyph": "rail", "cd": 3.0, "max": 2, "range": 540.0, "aim": "line", "text": "Aim a straight rocket. 15 impact damage plus an 8-damage blast on contact or at maximum range."},
	"flame": {"name": "Welding torch", "category": "active", "icon": "rapid", "glyph": "flame", "cd": 7.0, "max": 1, "range": 190.0, "aim": "line", "text": "Burn a forward cone for 2 seconds: 26 damage total. Steer with the cursor while moving."},
	"nuke": {"name": "Reactor drop", "category": "active", "icon": "pulse", "glyph": "target", "cd": 16.0, "max": 1, "range": 480.0, "aim": "ground", "text": "85 damage in a 135-radius area after 0.65s. Confirm with left click; right click cancels."},
	"laser": {"name": "Core cutter", "category": "ultimate", "icon": "power", "glyph": "beam", "cd": 30.0, "max": 1, "range": 700.0, "aim": "line", "text": "Channel for up to 5s: 75 damage/sec. Rooted while firing. Right click to steer with inertia; R again cancels. D or F cancels into an escape."},
	"salvo": {"name": "Homing salvo", "category": "active", "icon": "rapid", "glyph": "salvo", "cd": 8.0, "max": 3, "range": 440.0, "aim": "auto", "text": "5 seeking bolts over 1 second. Each deals 2 + bolt damage. Needs a nearby enemy."},
	"nova": {"name": "Shock ring", "category": "active", "icon": "pulse", "glyph": "ring", "cd": 7.0, "max": 1, "range": 155.0, "aim": "self", "text": "Deal 9 + pulse rank x 2 damage in a ring. Push enemies away."},
	"shield": {"name": "Safety shell", "category": "active", "icon": "capacity", "glyph": "shield", "cd": 12.0, "max": 1, "range": 0.0, "aim": "self", "text": "Block the next hit within 4 seconds. No aiming."},
	"rail": {"name": "Rail spike", "category": "active", "icon": "power", "glyph": "rail", "cd": 8.0, "max": 3, "range": 620.0, "aim": "line", "text": "Aim a narrow spike: 8 + bolt damage, piercing up to 4 enemies."},
	"mortar": {"name": "Scrap mortar", "category": "active", "icon": "pulse", "glyph": "target", "cd": 8.0, "max": 1, "range": 380.0, "aim": "ground", "text": "Target a 90-radius blast. Explodes after 0.55 seconds for 16 damage."},
	"lunge": {"name": "Ram strike", "category": "active", "icon": "grinder", "glyph": "dash", "cd": 9.0, "max": 2, "range": 170.0, "aim": "line", "text": "Dash through enemies, dealing 12 damage once per enemy. Invulnerable during dash."},
	"overdrive": {"name": "Overdrive", "category": "ultimate", "icon": "grinder", "glyph": "sun", "cd": 28.0, "max": 1, "range": 180.0, "aim": "self", "text": "For 5 seconds, emit 5-damage rings twice per second. +25% move speed."},
	"beam": {"name": "Foundry lance", "category": "ultimate", "icon": "power", "glyph": "beam", "cd": 28.0, "max": 1, "range": 620.0, "aim": "line", "text": "After 0.4 seconds, fire a 56-wide beam for 55 damage. You can keep moving."},
	"sprint": {"name": "Ghost drive", "category": "speed", "icon": "rapid", "glyph": "speed", "cd": 18.0, "max": 1, "range": 0.0, "aim": "self", "text": "+65% movement speed. Intangible for 3 seconds; pass through enemies and ignore damage and slows."},
	"blink": {"name": "Phase hop", "category": "mobility", "icon": "ricochet", "glyph": "blink", "cd": 8.0, "max": 3, "range": 185.0, "aim": "ground", "text": "Blink toward the cursor, up to 185 distance. Brief protection on arrival."},
	"dash": {"name": "Skate jets", "category": "mobility", "icon": "rapid", "glyph": "dash", "cd": 6.0, "max": 2, "range": 220.0, "aim": "line", "text": "Dash toward the cursor over 0.18 seconds. Invulnerable during travel."},
	"turret": {"name": "Bolt sentry", "category": "summon", "icon": "power", "glyph": "turret", "cd": 10.0, "max": 1, "range": 320.0, "aim": "ground", "text": "Deploy a stationary turret for 18 seconds. Fires 3-damage bolts within 300 range. Replaces the old summon."},
	"pylon": {"name": "Repair beacon", "category": "summon", "icon": "magnet", "glyph": "cross", "cd": 14.0, "max": 1, "range": 320.0, "aim": "ground", "text": "Stationary beacon lasts 18 seconds. Restore 1 hull every 5 seconds while within 100 range. Replaces the old summon."},
	"sacrifice": {"name": "Emergency cell", "category": "active", "icon": "magnet", "glyph": "cell", "cd": 16.0, "max": 1, "range": 0.0, "aim": "self", "text": "Spend 1 hull to restore 55 energy. Cannot cast at 1 hull or when energy is full. Ignores shields; cannot kill you."},
}
const PETS := {"scout": "Scrap scout", "drone": "Bolt drone", "none": "No pet"}
static var ABILITIES: Dictionary = _all_abilities()
static var PASSIVES: Dictionary = _all_passives()
var extra := BotSkillEngine.new()
var discovery := false
var rank_bonus := 0

func flexible() -> bool: return loadout.get("flexible",false)
func active_slots() -> Array: return BotKeyboard.ACTIVE_BANKS if flexible() else SLOTS
func effective_rank(slot: String) -> int: return mini(10,int(ranks.get(slot,0))+(rank_bonus if unlocked(slot) else 0))
var discovered: Array = ["q", "d", "f", "p1"]
var cooldown_bonus := 0.0
var attack_speed_bonus := 0.0
var attack_damage_bonus := 0.0
var attack_range_bonus := 0.0

static func _all_abilities() -> Dictionary:
	var data := LEGACY_ABILITIES.duplicate(true)
	data.merge(BotSkillCatalog.actives())
	data.merge(Vanguard.abilities())
	return data

static func _all_passives() -> Dictionary:
	var data := LEGACY_PASSIVES.duplicate(true)
	data.merge(BotSkillCatalog.passives())
	return data
var loadout: Dictionary
var bindings: Dictionary
var charges: Dictionary = {}
var recharge: Dictionary = {}
var salvos: Array[Dictionary] = []
var zones: Array[Dictionary] = []
var summon: Dictionary = {}
var pet_position := Vector2.ZERO
var pet_clock := 0.0
var forge_pet := false
var forge_pet_clock := 0.0
var shield := 0.0
var sprint := 0.0
var overdrive := 0.0
var overdrive_tick := 0.0
var dash_left := 0.0
var dash_velocity := Vector2.ZERO
var dash_damage := 0.0
var dash_hits: Array = []
var cast_counts: Dictionary = {}
var toggles: Array[bool] = [true, true, true, true]
var energy := 100.0
var energy_bonus := 0.0
var regen_bonus := 0.0
var energy_spent := 0.0
var health_spent := 0
var tiers: Dictionary = {}
var last_failure := ""
var ranks: Dictionary = {}
var rank_regen := 0.0
var rank_energy := 0.0
var shield_hits := 1
var onboarding := false
var elapsed := 0.0
var orbit_far := false
var flame_left := 0.0
var flame_tick := 0.25
var flame_slot := "w"
var flame_direction := Vector2.RIGHT
var gear_damage := 0.0
var gear_speed := 0.0
var boost_speed := 0.0
var mastery_damage := 0.0
var laser_left := 0.0
var laser_angle := 0.0
var laser_target := 0.0
var laser_turn := 0.0
var laser_slot := "r"
var arc_clock := 0.0
var arc_focused := false
var starting_gun := false
var gun_sniper := false
var poison_trail: Array[Dictionary] = []
var poison_clock := 0.0
const UNLOCKS := {"q": 0.0, "d": 0.0, "f": 0.0, "p1": 10.0, "w": 20.0, "p2": 32.0, "e": 45.0, "p3": 58.0, "r": 70.0, "t": 95.0, "p4": 110.0}

static func demo_preset() -> Dictionary:
	var config := preset()
	config.q = "rocket"
	config.w = "flame"
	config.e = "nuke"
	config.r = "laser"
	config.passives = ["bolt", "orbit", "lightning", "plating"]
	config.pet = "drone"
	return config

func unlocked(slot: String) -> bool:
	if discovery: return slot in discovered
	if starting_gun and slot.begins_with("p") and loadout.passives[int(slot.substr(1)) - 1] == "bolt": return true
	return not onboarding or elapsed >= float(UNLOCKS.get(slot, 0))

static func with_starter_gun(config: Dictionary) -> Dictionary:
	var result := config.duplicate(true)
	var index: int = result.passives.find("bolt")
	if index < 0:
		# Preserve orbit when an older custom kit depends on it for ricochet.
		index = result.passives.size() - 1
		if result.passives[index] == "orbit" and "ricochet" in result.passives:
			index = 0
	if index > 0: result.passives[index] = result.passives[0]
	result.passives[0] = "bolt"
	return result

func ability_cost(id: String) -> float:
	return float({"rocket": 8, "flame": 18, "nuke": 28, "laser": 40}.get(id, ENERGY_COST.get(id, ABILITIES[id].get("cost", 0))))

static func deals_damage(id: String) -> bool:
	return id not in ["shield", "sprint", "blink", "dash", "pylon", "sacrifice", "repair_channel", "wall", "medic_sentry", "tumble", "veil_dash", "vault", "consume"]

static func migrate_loadout(config: Dictionary) -> Dictionary:
	var result := config.duplicate(true)
	if result.get("r") == "nuke":
		result.e = "nuke"
		result.r = "laser"
		if result.get("passives") == ["bolt", "orbit", "pulse", "ricochet"]:
			result.passives = ["bolt", "orbit", "lightning", "plating"]
	if result.get("passives") is Array and "magnet" in result.passives:
		var index: int = result.passives.find("magnet")
		for replacement in ["thorns", "bolt", "orbit", "pulse", "plating", "ricochet"]:
			if replacement not in result.passives:
				result.passives[index] = replacement
				break
	return result

func milestone(slot: String) -> int:
	return SalvageProgression.milestone(effective_rank(slot))

func area_scale(slot: String) -> float:
	return (1.0 + milestone(slot) * 0.25) * (1.15 if loadout.get("rules17",false) and loadout.get(slot,"") in ["flame","reap","sweep","thrust","repulsor","tractor"] else 1.0)

func cast_range(slot: String) -> float:
	if loadout.get("vanguard",false) and slot=="w": return 650.0
	var id: String = loadout[slot]
	return float(ABILITIES[id].range) * (area_scale(slot) if id in ["nova", "overdrive", "blink", "dash", "lunge", "tumble", "echo_dash", "veil_dash", "hop", "vault", "pursuit", "landing"] else 1.0)

func rank_up(slot: String) -> bool:
	if slot not in active_slots() or ranks[slot] >= 10:
		return false
	var old := cooldown(slot)
	ranks[slot] += 1
	recharge[slot] = float(recharge[slot]) * cooldown(slot) / old
	return true

func energy_max() -> float:
	return 100.0 + energy_bonus + rank_energy

func energy_regen() -> float:
	return 8.0 + regen_bonus + rank_regen

func drain_rate() -> float:
	var rate := 0.0
	for id in loadout.passives:
		if passive_active(id):
			rate += float(UPKEEP.get(id, 0))
	return rate

func passive_active(id: String) -> bool:
	if loadout.get("vanguard",false) and id=="bolt": return true
	if id=="": return false
	var index: int = loadout.passives.find(id)
	if index < 0 or not toggles[index] or not unlocked("p%d" % (index + 1)):
		return false
	return id != "ricochet" or passive_active("orbit")

func toggle(index: int) -> bool:
	if index < 0 or index >= loadout.passives.size():
		return false
	if not unlocked("p%d" % (index + 1)): return false
	if loadout.passives[index] == "converter":
		if not toggles[index]: toggles[index] = true; extra.converter_mode = 0
		elif extra.converter_mode == 0: extra.converter_mode = 1
		else: toggles[index] = false
		return true
	if starting_gun and loadout.passives[index] == "bolt":
		if not toggles[index]:
			if energy < 1: return false
			toggles[index] = true
			gun_sniper = false
		elif gun_sniper:
			toggles[index] = false
			gun_sniper = false
		else: gun_sniper = true
		return true
	if loadout.passives[index] == "lightning" and toggles[index]:
		arc_focused = not arc_focused
		if not arc_focused: toggles[index] = false
		return true
	if onboarding and loadout.passives[index] == "orbit":
		if not toggles[index]:
			if energy < 1: return false
			toggles[index] = true
			orbit_far = false
			return true
		orbit_far = not orbit_far
		return true
	if not toggles[index] and UPKEEP.has(loadout.passives[index]) and energy < 1:
		return false
	toggles[index] = not toggles[index]
	return true

func cooldown(slot: String) -> float:
	return cooldown_at(slot, int(ranks.get(slot, 0)))

func cooldown_at(slot: String, rank_value: int, tier_value: int = -1) -> float:
	var tier := int(tiers.get(slot, 0)) if tier_value < 0 else tier_value
	var base: float=4.0/0.9 if loadout.get("vanguard",false) and slot=="q" else float(ABILITIES[loadout[slot]].cd)
	return base * (1.0 - tier * 0.08) * (1.0 - SalvageProgression.bonus(mini(10,rank_value+(rank_bonus if unlocked(slot) else 0))) * 0.5) / (1.0 + cooldown_bonus)

func damage_scale(slot: String) -> float:
	return damage_scale_at(slot, int(ranks.get(slot, 0)))

func damage_scale_at(slot: String, rank_value: int, tier_value: int = -1) -> float:
	var tier: int = int(tiers.get(slot, 0)) if tier_value < 0 else tier_value
	return (1.6 if loadout.get("rules17",false) and loadout.get(slot,"") in ["flame","reap","sweep","thrust","repulsor","tractor"] else 1.0) * (1.0 + gear_damage + mastery_damage) * (1.0 + tier * 0.15) * (1.0 + SalvageProgression.bonus(mini(10,rank_value+(rank_bonus if unlocked(slot) else 0))))

func promote(slot: String) -> bool:
	if slot not in active_slots() or tiers[slot] >= 2:
		return false
	var old := cooldown(slot)
	tiers[slot] += 1
	recharge[slot] = float(recharge[slot]) * cooldown(slot) / old
	return true

static func cost_text(id: String) -> String:
	if BotSkillCatalog.SPECS.has(id): return "%d energy" % ABILITIES[id].cost if ABILITIES[id].cost > 0 else "Free"
	if id in ["rocket", "flame", "nuke", "laser"]: return "%d energy" % {"rocket": 8, "flame": 18, "nuke": 28, "laser": 40}[id]
	return "1 hull -> 55 energy" if id == "sacrifice" else ("%d energy" % ENERGY_COST[id] if ENERGY_COST.has(id) else "Free")

static func resolve_bindings(config: Dictionary) -> Dictionary:
	# Migrate seven-key saves without stealing an existing number-key binding.
	var result := DEFAULT_BINDS.duplicate()
	for slot in BIND_SLOTS:
		if not config.has(slot):
			continue
		var old: int = result[slot]
		for other in BIND_SLOTS:
			if result[other] == config[slot]:
				result[other] = old
		result[slot] = config[slot]
	for slot in BIND_SLOTS:
		if result[slot] in [KEY_A, KEY_S, KEY_M, KEY_L, KEY_5, KEY_6]:
			for candidate in [KEY_Q, KEY_W, KEY_E, KEY_R, KEY_D, KEY_F, KEY_T, KEY_1, KEY_2, KEY_3, KEY_4, KEY_B, KEY_C, KEY_G, KEY_H, KEY_J]:
				if candidate not in result.values():
					result[slot] = candidate
					break
	return result

static func preset(precision: bool = false) -> Dictionary:
	return {"passives": ["bolt", "orbit", "pulse", "ricochet"], "q": "rail" if precision else "salvo", "w": "mortar" if precision else "nova", "e": "lunge" if precision else "shield", "r": "beam" if precision else "overdrive", "d": "sprint", "f": "dash" if precision else "blink", "t": "turret", "pet": "drone" if precision else "scout"}

static func category(slot: String) -> String:
	return {"q": "active", "w": "active", "e": "active", "r": "ultimate", "d": "speed", "f": "mobility", "t": "summon"}.get(slot, "")

static func valid_loadout(config: Dictionary) -> bool:
	if config.get("flexible",false): return BotKeyboard.valid_config(config)
	if config.get("flexible",false): return BotKeyboard.valid_config(config)
	var passives: Variant = config.get("passives", [])
	if not passives is Array or passives.size() != 4:
		return false
	var used: Array = []
	for id in passives:
		if not PASSIVES.has(id) or id in used:
			return false
		used.append(id)
	if "ricochet" in passives and "orbit" not in passives:
		return false
	for slot in SLOTS:
		var id: String = str(config.get(slot, ""))
		if not ABILITIES.has(id) or ABILITIES[id].category != category(slot) or id in used:
			return false
		used.append(id)
	return PETS.has(config.get("pet", ""))

static func valid_bindings(config: Dictionary) -> bool:
	var used: Array = []
	for slot in (BIND_SLOTS if config.has("p1") else SLOTS):
		var key := int(config.get(slot, 0))
		# S is a hard stop; Escape/Tab and the audio shortcuts remain system keys.
		if not ((key >= KEY_A and key <= KEY_Z) or (key >= KEY_0 and key <= KEY_9)) or key in [KEY_A, KEY_S, KEY_M, KEY_L, KEY_5, KEY_6] or key in used:
			return false
		used.append(key)
	return true

func _init(config: Dictionary = {}, keys: Dictionary = {}) -> void:
	config = migrate_loadout(config)
	loadout = config.duplicate(true) if valid_loadout(config) else preset()
	bindings = resolve_bindings(keys) if valid_bindings(keys) else DEFAULT_BINDS.duplicate()
	while toggles.size()<loadout.passives.size(): toggles.append(false)
	for slot in active_slots():
		charges[slot] = int(ABILITIES[loadout[slot]].max)
		recharge[slot] = 0.0
		tiers[slot] = 0
		ranks[slot] = 0

func passive_scale(id: String) -> float:
	return 1.2 if rank_bonus>0 and BotKeyboard.learned(self,id)!="" else 1.0

func has_passive(id: String) -> bool:
	return id!="" and id in loadout.passives

func speed() -> float:
	var drive:=0.65
	if loadout.get("vanguard",false): drive+=maxi(0,effective_rank("d")-1)*0.035
	return 205.0 * (1.0 + gear_speed + (0.4 if boost_speed > 0 else 0.0) + (drive if sprint > 0 else 0.0) + (0.25 if overdrive > 0 else 0.0))

func target_point(run, slot: String, cursor: Vector2) -> Vector2:
	var offset: Vector2 = cursor - run.player
	var point: Vector2 = run.player + offset.limit_length(cast_range(slot))
	if loadout[slot] in ["beam", "rail", "rocket", "flame", "laser"]:
		point = run.player + offset.normalized() * cast_range(slot)
	return point.clamp(run.ARENA.position + Vector2.ONE * 16, run.ARENA.end - Vector2.ONE * 16)

func preview_ready(run, slot: String, cursor: Vector2) -> bool:
	if Vanguard.enabled(run):
		if run.vanguard.ghost or slot not in Vanguard.KEYS or not unlocked(slot) or run.vanguard.slam_left>0: return false
		if slot=="p1": return true
		if charges[slot]<=0 or (energy<ability_cost(loadout[slot]) and not run.vanguard.powered(run)): return false
		var target:=target_point(run,slot,cursor)
		if slot=="f": return Vanguard.blink_target(run,target).distance_to(run.player)>1
		return Vanguard.valid_point(run,target,22) if slot in ["x1","x2","x3"] else true
	if extra.recasts.has(slot): return true
	if laser_left > 0 and slot not in ["d", "f"]: return false
	if slot not in active_slots() or charges[slot] <= 0 or not unlocked(slot): return false
	var id: String = loadout[slot]
	if energy < ability_cost(id): return false
	if not extra.can_cast(run, id, target_point(run, slot, cursor), cast_range(slot)): return false
	if id == "sacrifice": return run.health > 1 and energy < energy_max()
	if id == "salvo":
		var target: Dictionary = run.nearest_enemy(run.player)
		return not target.is_empty() and run.player.distance_to(target.pos) <= cast_range(slot)
	if id in ["dash", "lunge", "blink"]:
		return dash_left <= 0 and target_point(run, slot, cursor).distance_squared_to(run.player) > 0.01
	return ABILITIES[id].aim != "line" or (cursor - run.player).normalized() != Vector2.ZERO

func cast(run, slot: String, cursor: Vector2) -> bool:
	if Vanguard.enabled(run): return run.vanguard.cast(run,slot,cursor)
	last_failure = "Not ready"
	if run.state != "running": return false
	if extra.recast(run, slot, target_point(run, slot, cursor)): return true
	if laser_left > 0:
		if slot == laser_slot:
			cancel_laser()
			return true
		if slot not in ["d", "f"]:
			last_failure = "Channeling"
			return false
	if run.state != "running" or slot not in active_slots() or charges[slot] <= 0:
		return false
	if not unlocked(slot):
		last_failure = "Find in a chest" if discovery else "Unlocks at %d seconds" % UNLOCKS[slot]
		return false
	var id: String = loadout[slot]
	var data: Dictionary = ABILITIES[id]
	var direction: Vector2 = (cursor - run.player).normalized()
	if data.aim == "line" and direction == Vector2.ZERO:
		return false
	var point := target_point(run, slot, cursor)
	if not extra.can_cast(run, id, point, cast_range(slot)):
		last_failure = "No valid target"
		return false
	if id in ["dash", "lunge", "blink"] and point.distance_squared_to(run.player) <= 0.01:
		last_failure = "No room to move"
		return false
	if id == "salvo":
		var target: Dictionary = run.nearest_enemy(run.player)
		if target.is_empty() or run.player.distance_to(target.pos) > cast_range(slot):
			last_failure = "No target in range"
			return false
	if id in ["dash", "lunge", "blink"] and dash_left > 0:
		return false
	var cost := ability_cost(id)
	if energy < cost:
		last_failure = "Need %d energy" % cost
		return false
	if id == "sacrifice" and (run.health <= 1 or energy >= energy_max()):
		last_failure = "Need more than 1 hull" if run.health <= 1 else "Energy is full"
		return false
	energy -= cost
	if slot in ["d", "f"]: cancel_laser()
	energy_spent += cost
	charges[slot] -= 1
	if recharge[slot] <= 0:
		recharge[slot] = cooldown(slot)
	var multiplier := damage_scale(slot)
	extra.repair_left = 0
	cast_counts[id] = int(cast_counts.get(id, 0)) + 1
	run.aim = direction if direction != Vector2.ZERO else run.aim
	run.emit_event("cast", run.player, {"ability": id, "target": point, "milestone": milestone(slot)})
	match id:
		"laser":
			laser_left = 5.0
			laser_slot = slot
			laser_angle = direction.angle()
			laser_target = laser_angle
			laser_turn = 0.0
			flame_left = 0.0
			run.stop_movement()
		"rocket":
			var before: int = run.projectiles.size()
			run._add_projectile(run.player, direction * 720, 15 * multiplier, "rocket", 0)
			if run.projectiles.size() > before:
				run.projectiles.back().life = cast_range(slot) / 720.0
				run.projectiles.back().blast = 8 * multiplier
				run.projectiles.back().radius = 62 * area_scale(slot)
				run.projectiles.back().milestone = milestone(slot)
		"flame":
			flame_left = 2.0
			flame_tick = 0.25
			flame_slot = slot
			flame_direction = direction
		"nuke": zones.append({"pos": point, "time": 0.65, "duration": 0.65, "radius": 135.0 * area_scale(slot), "kind": "nuke", "scale": multiplier})
		"salvo": salvos.append({"left": 5 + milestone(slot) * 2, "clock": 0.0, "scale": multiplier, "interval": 1.0 / (5 + milestone(slot) * 2)})
		"nova": area(run, run.player, cast_range(slot), (9 + run.rank_of("pulse") * 2) * multiplier, "active", 280)
		"shield":
			shield = 4.0
			shield_hits = 1 + milestone(slot)
		"rail": run._add_projectile(run.player, direction * 850, (8 + run.bolt_damage()) * multiplier, "rail", 3 + milestone(slot) * 2)
		"mortar": zones.append({"pos": point, "time": 0.55, "duration": 0.55, "radius": 90.0 * area_scale(slot), "kind": "blast", "scale": multiplier})
		"lunge", "dash":
			extra.dash_crosses_walls = false
			dash_left = 0.18
			dash_velocity = (point - run.player) / dash_left
			dash_damage = 12.0 * multiplier if id == "lunge" else 0.0
			dash_hits.clear()
			run.stop_movement()
			run.invincible = maxf(run.invincible, 0.23)
		"overdrive":
			overdrive = 5.0
			overdrive_tick = 0.0
		"beam": zones.append({"pos": run.player, "end": point, "time": 0.4, "duration": 0.4, "radius": 28.0 * area_scale(slot), "kind": "beam", "scale": multiplier})
		"sprint":
			sprint = 3.0 + milestone(slot)
			run.invincible = maxf(run.invincible, 3.0)
			run.slow_left = 0
			if run.mastery.rank_of("resolve") > 0: run.heal(1)
		"blink":
			run.emit_event("blink", run.player, {"target": point})
			run.player = point
			run.stop_movement()
			run.invincible = maxf(run.invincible, 0.18)
		"turret", "pylon": summon = {"id": id, "pos": point, "life": 18.0, "clock": 0.2 if id == "turret" else 5.0, "scale": multiplier, "milestone": milestone(slot)}
		"sacrifice":
			run.health -= 1
			health_spent += 1
			energy = minf(energy_max(), energy + 55 + milestone(slot) * 15)
		_: extra.cast(run, slot, id, point, direction, multiplier)
	extra.mirror(run, id, direction, multiplier)
	last_failure = ""
	return true

func step(run, delta: float) -> void:
	_step_laser(run, delta)
	_step_arc(run, delta)
	var previous := elapsed
	elapsed += delta
	if onboarding and not discovery:
		for slot in UNLOCKS:
			if starting_gun and slot.begins_with("p") and loadout.passives[int(slot.substr(1)) - 1] == "bolt": continue
			if previous < UNLOCKS[slot] and elapsed >= UNLOCKS[slot]:
				run.emit_event("unlock", run.player, {"slot": slot})
	boost_speed = maxf(0, boost_speed - delta)
	if flame_left > 0:
		flame_tick -= minf(delta, flame_left)
		while flame_tick <= 0.000001:
			flame_tick += 0.25
			for enemy in run.enemies:
				var offset: Vector2 = enemy.pos - run.player
				if not enemy.dead and enemy.warmup <= 0 and offset.length() <= cast_range(flame_slot) * area_scale(flame_slot) + enemy.radius and absf(flame_direction.angle_to(offset)) <= PI / 5:
					run.hit_enemy(enemy, 3.25 * damage_scale(flame_slot), "flame")
		flame_left = maxf(0, flame_left - delta)
	var available := energy + energy_regen() * delta
	var drain := drain_rate() * delta
	if drain > available:
		for i in range(loadout.passives.size()):
			if UPKEEP.has(loadout.passives[i]):
				toggles[i] = false
		run.emit_event("energy_low", run.player)
	energy_spent += minf(available, drain)
	energy = clampf(available - drain, 0, energy_max())
	_step_poison(run, delta)
	shield = maxf(0, shield - delta)
	sprint = maxf(0, sprint - delta)
	for slot in active_slots():
		var data: Dictionary = ABILITIES[loadout[slot]]
		var maximum: int=2 if loadout.get("vanguard",false) and slot in ["q","w","e"] else int(data.max)
		charges[slot]=mini(charges[slot],maximum)
		if charges[slot] < maximum:
			recharge[slot] -= delta
			while recharge[slot] <= 0 and charges[slot] < maximum:
				charges[slot] += 1
				recharge[slot] += cooldown(slot)
			if charges[slot] == maximum:
				recharge[slot] = 0.0
	for salvo in salvos:
		salvo.clock -= delta
		while salvo.clock <= 0 and salvo.left > 0:
			salvo.clock += salvo.get("interval", 0.2)
			salvo.left -= 1
			var target: Dictionary = run.nearest_enemy(run.player)
			if not target.is_empty() and run.player.distance_to(target.pos) <= 440:
				var direction: Vector2 = (target.pos - run.player).normalized()
				run._add_projectile(run.player, direction * 430, (2 + run.bolt_damage()) * float(salvo.get("scale", 1)), "homing", 0)
				run.emit_event("shot", run.player)
	salvos = salvos.filter(func(s: Dictionary) -> bool: return s.left > 0)
	for zone in zones:
		zone.time -= delta
		if zone.time <= 0:
			if zone.kind == "nuke":
				area(run, zone.pos, zone.radius, 85 * zone.scale, "ultimate", 240)
				run.emit_event("nuke_impact", zone.pos, {"radius": zone.radius})
			elif zone.kind == "blast":
				area(run, zone.pos, zone.radius, 16 * zone.get("scale", 1.0), "active", 150)
			else:
				for enemy in run.enemies:
					if not enemy.dead and enemy.warmup <= 0 and Geometry2D.get_closest_point_to_segment(enemy.pos, zone.pos, zone.end).distance_to(enemy.pos) <= zone.radius + enemy.radius:
						run.hit_enemy(enemy, 55 * zone.get("scale", 1.0), "ultimate")
				run.emit_event("beam", zone.pos, {"target": zone.end, "width": zone.radius * 2})
	zones = zones.filter(func(z: Dictionary) -> bool: return z.time > 0)
	if overdrive > 0:
		overdrive_tick -= delta
		if overdrive_tick <= 0:
			overdrive_tick += 0.5
			area(run, run.player, cast_range("r"), 5 * damage_scale("r"), "ultimate", 60)
		overdrive = maxf(0, overdrive - delta)
	if not summon.is_empty():
		summon.life -= delta
		summon.clock -= delta
		if summon.clock <= 0:
			if summon.id == "turret":
				summon.clock = 0.6 / (1 + summon.get("milestone", 0) * 0.25)
				fire_companion(run, summon.pos, 300, 3 * summon.get("scale", 1.0), "summon")
			else:
				summon.clock = 5.0
				if run.player.distance_to(summon.pos) <= 100 * (1 + summon.get("milestone", 0) * 0.5):
					run.heal(1)
					run.emit_event("equipped", run.player, {"id": "repair"})
		if summon.life <= 0:
			summon.clear()
	pet_position = pet_position.move_toward(run.player + Vector2(-34, 26), delta * 290)
	forge_pet_clock=maxf(0,forge_pet_clock-delta)
	if forge_pet and forge_pet_clock<=0:
		forge_pet_clock=run.attacks.auto_interval(run)
		fire_companion(run,pet_position,run.attacks.auto_range(run),run.attacks.auto_damage(run),"forge_pet")
	pet_clock -= delta
	if loadout.pet == "drone" and pet_clock <= 0:
		pet_clock = 1.3
		fire_companion(run, pet_position, 290, 2, "pet")
	elif loadout.pet == "scout":
		for pickup in run.pickups:
			if Vector2(pickup.pos).distance_to(pet_position) < 105:
				pickup.pull = true
	extra.step(run, delta)

func cancel_laser() -> void:
	laser_left = 0
	laser_turn = 0

func _step_poison(run, delta: float) -> void:
	for patch in poison_trail: patch.life -= delta
	poison_trail = poison_trail.filter(func(p: Dictionary) -> bool: return p.life > 0)
	poison_clock = maxf(0, poison_clock - delta)
	if passive_active("poison") and poison_clock <= 0:
		poison_clock = 0.12
		if poison_trail.is_empty() or Vector2(poison_trail.back().pos).distance_to(run.player) >= 12:
			if poison_trail.size() >= 40: poison_trail.pop_front()
			poison_trail.append({"pos": run.player, "life": 4.0})
		else: poison_trail.back().life = 4.0
	for enemy in run.enemies:
		if enemy.dead or enemy.warmup > 0: continue
		for patch in poison_trail:
			if Vector2(patch.pos).distance_to(enemy.pos) <= 26 + enemy.radius:
				run.hit_enemy(enemy, 8.0 * SalvageProgression.multiplier(run.rank_of("power")) * delta, "poison")
				break # One damage rate, regardless of overlapping trail patches.

func steer_laser(run, point: Vector2) -> void:
	if laser_left > 0 and point.distance_squared_to(run.player) > 4:
		laser_target = (point - run.player).angle()

func _step_laser(run, delta: float) -> void:
	if laser_left <= 0: return
	if run.state != "running":
		cancel_laser()
		return
	var dt := minf(delta, laser_left)
	var error := wrapf(laser_target - laser_angle, -PI, PI)
	# Bounded angular speed + acceleration: no cursor teleport or 180-degree snap.
	var desired := clampf(error * 5.0, -1.25, 1.25)
	laser_turn = move_toward(laser_turn, desired, 3.5 * dt)
	laser_angle = wrapf(laser_angle + laser_turn * dt, -PI, PI)
	var end: Vector2 = run.player + Vector2.from_angle(laser_angle) * cast_range(laser_slot)
	var radius := 23.0 * area_scale(laser_slot)
	run.aim = Vector2.from_angle(laser_angle)
	for enemy in run.enemies:
		if not enemy.dead and enemy.warmup <= 0 and Geometry2D.get_closest_point_to_segment(enemy.pos, run.player, end).distance_to(enemy.pos) <= radius + enemy.radius:
			run.hit_enemy(enemy, 75 * damage_scale(laser_slot) * dt, "ultimate")
	laser_left = maxf(0, laser_left - dt)
	if laser_left <= 0: cancel_laser()

func _step_arc(run, delta: float) -> void:
	if not passive_active("lightning") or energy < 1: return
	arc_clock -= delta
	if arc_clock > 0: return
	var target: Dictionary = run.nearest_enemy(run.player)
	var reach := (440.0 if arc_focused else 200.0) if discovery else 280.0
	if target.is_empty() or Vector2(target.pos).distance_to(run.player) > reach: return
	arc_clock = (2.2 if arc_focused else 0.9) if discovery else 1.8
	var origin: Vector2 = run.player
	var visited: Array = []
	for i in range(1 if arc_focused else 4):
		if target.is_empty() or Vector2(target.pos).distance_to(origin) > (reach if i == 0 else 145): break
		visited.append(target.id)
		run.emit_event("lightning", origin, {"target": target.pos})
		if run.mastery.rank_of("shock") > 0 and not target.has("role"):
			target["stun"] = 0.35
		var power := SalvageProgression.multiplier(run.rank_of("power"))
		run.hit_enemy(target, 7 * power * (2 if arc_focused else 1), "lightning")
		origin = target.pos
		target = run.nearest_enemy(origin, visited)

func move_dash(run, delta: float) -> void:
	var before: Vector2 = run.player
	var travel := minf(delta, dash_left)
	run.velocity = dash_velocity
	run.player = (before + dash_velocity * travel).clamp(run.ARENA.position + Vector2.ONE * 16, run.ARENA.end - Vector2.ONE * 16)
	if not extra.dash_crosses_walls: run.player = extra.solid_point(before,run.player,16)
	dash_left = maxf(0, dash_left - delta)
	if dash_damage > 0:
		for enemy in run.enemies:
			if not enemy.dead and enemy.warmup <= 0 and enemy.id not in dash_hits and Geometry2D.get_closest_point_to_segment(enemy.pos, before, run.player).distance_to(enemy.pos) <= 20 + enemy.radius:
				dash_hits.append(enemy.id)
				run.hit_enemy(enemy, dash_damage, "active", dash_velocity.normalized() * 140)
	if dash_left <= 0:
		run.velocity = Vector2.ZERO

static func fire_companion(run, point: Vector2, radius: float, damage: float, source: String) -> void:
	var target: Dictionary = run.nearest_enemy(point)
	if not target.is_empty() and point.distance_to(target.pos) <= radius:
		var count: int=run.projectiles.size()
		var speed: float=700 if source=="forge_pet" else 450
		run._add_projectile(point, (Vector2(target.pos) - point).normalized() * speed, damage, source, run.bolt_pierces() if source=="forge_pet" else 0)
		if source=="forge_pet" and run.projectiles.size()>count:
			run.projectiles.back().life=radius/speed
			run.projectiles.back().basic_attack=true

static func area(run, point: Vector2, radius: float, damage: float, source: String, force: float) -> void:
	run.emit_event("pulse", point, {"radius": radius})
	for enemy in run.enemies:
		if not enemy.dead and enemy.warmup <= 0 and Vector2(enemy.pos).distance_to(point) <= radius + enemy.radius:
			run.hit_enemy(enemy, damage, source, (Vector2(enemy.pos) - point).normalized() * force)
