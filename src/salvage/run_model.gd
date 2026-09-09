class_name SalvageRun
extends RefCounted
## Simulation owns rules; the renderer and sound system consume its events.

const ARENA := Rect2(-2200, -1400, 5360, 3400)
const DURATION := 90.0
const MAX_ENEMIES := 180
const MAX_PROJECTILES := 240
const MAX_PICKUPS := 360
const COLLISION_CELL := 64.0
const UPGRADES := {
	"grinder": {"name": "Grinder", "description": "Stronger, longer-lasting orbit tools.", "tag": "ORBIT", "max": 3},
	"ricochet": {"name": "Ricochet", "description": "Spent tools fire bouncing shards.", "tag": "SHARDS", "max": 3},
	"pulse": {"name": "Pulse coil", "description": "Collect 8 scrap to release a pulse.", "tag": "AREA DAMAGE", "max": 3},
	"magnet": {"name": "Magnet", "description": "Collect scrap from farther away.", "tag": "COLLECTION", "max": 4},
	"rapid": {"name": "Fire rate", "description": "Fire bolts more often.", "tag": "BOLT GUN", "max": 4},
	"power": {"name": "Heavy bolts", "description": "More damage and penetration.", "tag": "BOLT GUN", "max": 3},
	"capacity": {"name": "Tool rack", "description": "Carry more orbit tools.", "tag": "CAPACITY", "max": 3},
	"reactor": {"name": "Reactor", "description": "Regenerate energy faster.", "tag": "ENERGY REGEN", "max": 3},
	"cell": {"name": "Energy cell", "description": "Increase maximum stored energy.", "tag": "ENERGY", "max": 3},
}

var mode := "salvage"
var run_seed := 2407
var state := "running"
var time := 0.0
var player := Vector2(480, 300)
var velocity := Vector2.ZERO
var aim := Vector2.RIGHT
var health := 5.0
var exp: RefCounted
var mastery := BotMastery.new()
var attacks := BotAttackOrders.new()
var xp_fraction := 0.0
var slow_left := 0.0

func max_health() -> float:
	if exp != null: return exp.max_health(self)
	return 5 + mastery.rank_of("hull")

func heal(hull_units: float) -> void:
	health = minf(max_health(), health + hull_units * (20 if exp != null else 1))

func apply_slow(seconds: float) -> void:
	if invincible > 0: return
	if exp != null: seconds *= 1 - minf(0.6, exp.stats.get("tenacity", 0))
	slow_left = maxf(slow_left, seconds * (0.5 if mastery.rank_of("resolve") > 0 else 1.0))
var invincible := 0.0
var kills := 0
var total_xp := 0
var level := 1
var next_level := 8
var collected := 0
var pulse_charge := 0
var pending_pulses := 0
var pulse_cooldown := 0.0
var next_id := 1
var enemies: Array[Dictionary] = []
var projectiles: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var orbit: Array[Dictionary] = []
var events: Array[Dictionary] = []
var offers: Array[String] = []
var upgrades: Dictionary = {}
var spawn_clock := 0.6
var shot_clock := 0.2
var boss_spawned := false
var boss_defeated := false
var damage_taken := 0.0
var last_damage := ""
var last_damage_time := -99.0
var last_damage_direction := Vector2.ZERO
var damage_history: Array[Dictionary] = []
var damage_dealt := {"bolt": 0.0, "orbit": 0.0, "shard": 0.0, "pulse": 0.0}
var upgrade_history: Array[Dictionary] = []
var spawn_rng := RandomNumberGenerator.new()
var offer_rng := RandomNumberGenerator.new()
var caches: Array[Dictionary] = []
var caches_opened := 0
var kit: MobaKit
var move_target := Vector2.ZERO
var moving := false
var view_size := Vector2(960, 540)
var detached_camera := false
var detached_origin := Vector2.ZERO
var coins := 0
var equipment_snapshot: Array[Dictionary] = []
var consumables := [2, 2]
var drop_bonus := 0.0
var loot_rng := RandomNumberGenerator.new()
var staged := false
var stage := 1
var stage_time := 0.0
var stage_rewards: Array[Dictionary] = []
var stage_history: Array[Dictionary] = []
var stage_clear_wait := -1.0
var pressure_wave := 0
var pressure_warning := 0
var vacuum_clock := 15.0
var supply_drops: Array[Dictionary] = []
var utility_history: Array[Dictionary] = []
var demo_mode := false
var demo_minis_spawned := 0
var demo_minis_killed := 0
var hazards: Array[Dictionary] = []
var demo_history: Array[Dictionary] = []
var level_start_time := 0.0
const STAGE_LENGTH := 60.0
const STAGE_COUNT := 3

func enable_stages() -> void:
	if staged: return
	staged = true
	upgrades.magnet = maxi(1, rank_of("magnet"))
	for slot in MobaKit.SLOTS:
		upgrades["skill_" + slot] = 0
	_sync_resource_ranks()

func enable_demo() -> void:
	enable_stages()
	demo_mode = true
	DemoCampaign.enter(self)

func rank_limit(id: String) -> int:
	if exp != null: return 10 if id != "magnet" else 5
	var maximum: int = upgrade_data(id).max
	return mini(maximum, [5, 8, 10][stage - 1]) if demo_mode and id != "magnet" else maximum

func encounter_seconds() -> float:
	if exp != null: return exp.round_seconds()
	return DemoCampaign.info(self).seconds if demo_mode else STAGE_LENGTH

func upgrade_data(id: String) -> Dictionary:
	return SalvageProgression.data(self, id) if staged else UPGRADES.get(id, {"name": "Repair", "description": "Restore one hull point.", "tag": "HULL", "max": 1})

func upgrade_ids() -> Array:
	var ids: Array = UPGRADES.keys()
	if staged:
		for slot in kit.active_slots():
			ids.append("skill_" + slot)
	return ids

func milestone(id: String) -> int:
	return SalvageProgression.milestone(rank_of(id)) if staged else 0

func upgrade_note(id: String, r: int) -> String:
	return SalvageProgression.note(self, id, r) if staged else str(upgrade_data(id).description)

func _sync_resource_ranks() -> void:
	if staged and kit != null:
		kit.rank_regen = rank_of("reactor") + milestone("reactor") * 2
		kit.rank_energy = rank_of("cell") * 10 + milestone("cell") * 20

func grant_utility() -> void:
	if not staged or rank_of("magnet") >= 5:
		return
	upgrades.magnet += 1
	utility_history.append({"id": "magnet", "rank": rank_of("magnet"), "level": level})
	emit_event("utility", player, {"rank": rank_of("magnet")})

func make_stage_rewards() -> void:
	stage_rewards.clear()
	var pool: Array = MobaKit.SLOTS.filter(func(slot: String) -> bool: return kit.tiers[slot] < 2)
	for i in range(mini(2, pool.size())):
		var candidates: Array = pool
		if i == 0:
			var damage_slots: Array = pool.filter(func(slot: String) -> bool: return slot in ["q", "w", "e", "r"] and kit.loadout[slot] not in ["shield", "sacrifice"])
			if not damage_slots.is_empty():
				candidates = damage_slots
			var promoted: Array = candidates.filter(func(slot: String) -> bool: return kit.tiers[slot] > 0)
			if not promoted.is_empty():
				candidates = promoted
		var slot: String = candidates[offer_rng.randi_range(0, candidates.size() - 1)]
		stage_rewards.append({"kind": "ability", "slot": slot, "tier": kit.tiers[slot] + 1})
		pool.erase(slot)
	stage_rewards.append({"kind": "reactor", "tier": 1})

func choose_stage_reward(index: int) -> bool:
	if state != "stage_reward" or index < 0 or index >= stage_rewards.size():
		return false
	var reward: Dictionary = stage_rewards[index]
	if reward.kind == "ability":
		kit.promote(reward.slot)
	else:
		kit.energy_bonus += 20
		kit.regen_bonus += 2
	stage_history.append({"stage": stage, "reward": reward.duplicate(), "time": time})
	stage_rewards.clear()
	heal(1)
	kit.energy = kit.energy_max()
	if stage == STAGE_COUNT:
		state = "won"
		emit_event("win", player)
	else:
		stage += 1
		stage_time = 0
		stage_clear_wait = -1
		pressure_wave = 0
		pressure_warning = 0
		boss_spawned = false
		boss_defeated = false
		state = "running"
		spawn_clock = 0.6
		invincible = 1.5
		stop_movement()
		if demo_mode: DemoCampaign.enter(self)
		emit_event("stage_start", player)
	return true

func enable_moba(config: Dictionary = {}, keys: Dictionary = {}) -> void:
	kit = MobaKit.new(config, keys)
	kit.pet_position = player + Vector2(-34, 26)
	move_target = player
	for source in ["homing", "rail", "active", "ultimate", "pet", "summon"]:
		damage_dealt[source] = 0.0

func command_move(point: Vector2) -> void:
	if kit != null and kit.extra.movement_order(self, point): return
	if kit != null and kit.laser_left > 0: return
	if attacks.enabled: attacks.move(point)
	move_target = point.clamp(ARENA.position + Vector2.ONE * 16, ARENA.end - Vector2.ONE * 16)
	moving = true

func stop_movement() -> void:
	moving = false
	move_target = player
	velocity = Vector2.ZERO

func passive_enabled(id: String) -> bool:
	return kit == null or kit.passive_active(id)

func upgrade_available(id: String) -> bool:
	if id == "power" and kit != null:
		for index in range(kit.loadout.passives.size()):
			if kit.loadout.passives[index] in ["bolt", "lightning", "poison", "threehit"] and kit.unlocked("p%d" % (index + 1)): return true
		for slot in MobaKit.SLOTS:
			if kit.loadout[slot] in ["salvo", "rail"] and kit.unlocked(slot): return true
		return false
	if staged and id.begins_with("skill_"):
		return id.trim_prefix("skill_") in kit.active_slots() and kit.unlocked(id.trim_prefix("skill_"))
	if kit != null and kit.onboarding:
		var passive: String = {"grinder": "orbit", "capacity": "orbit", "ricochet": "ricochet", "pulse": "pulse", "rapid": "bolt"}.get(id, "")
		if not passive.is_empty():
			var index: int = kit.loadout.passives.find(passive)
			if index < 0 or not kit.unlocked("p%d" % (index + 1)): return false
	if kit == null:
		if id in ["reactor", "cell"]:
			return false
		return mode == "salvage" or id in ["rapid", "power", "magnet"]
	return {"grinder": kit.has_passive("orbit"), "capacity": kit.has_passive("orbit"), "ricochet": kit.has_passive("ricochet"), "pulse": kit.has_passive("pulse"), "rapid": kit.has_passive("bolt"), "power": true, "magnet": true, "reactor": true, "cell": true}.get(id, false)

func _init(seed_value: int = 2407, selected_mode: String = "salvage") -> void:
	run_seed = seed_value
	mode = selected_mode
	spawn_rng.seed = seed_value
	offer_rng.seed = seed_value + 7919
	for key in UPGRADES:
		upgrades[key] = 0
	# A few harmless starting bolts teach the collection interaction immediately.
	for i in range(4):
		_drop(player + Vector2.from_angle(float(i) * TAU / 4.0) * 72.0, 1)
	for offset in [Vector2(420, 130), Vector2(-530, -160), Vector2(160, -600), Vector2(-200, 580), Vector2(1050, -510), Vector2(-1060, 700), Vector2(1200, 950), Vector2(-1250, -900)]:
		caches.append({"pos": player + offset, "opened": false})

func camera_origin() -> Vector2:
	return detached_origin if detached_camera else follow_origin()

func follow_origin() -> Vector2:
	if demo_mode:
		# Camera overscan is visual only. Keep the player clear of HUD at all four
		# edges, with margins expressed in screen pixels so zoom cannot erase them.
		var scale_value := view_size / Vector2(960, 540)
		return (player - view_size / 2 - Vector2(0, 20)).clamp(ARENA.position - Vector2(48, 96) * scale_value, ARENA.end + Vector2(48, 200) * scale_value - view_size)
	return (player - view_size / 2 - Vector2(0, 20)).clamp(ARENA.position, ARENA.end - view_size)

func bolt_damage() -> float:
	if staged:
		return 2.0 * SalvageProgression.multiplier(rank_of("power"))
	return 2.0 + rank_of("power") * 1.5

func fire_interval() -> float:
	if staged:
		return 0.43 / SalvageProgression.multiplier(rank_of("rapid"))
	return 0.43 / pow(1.22, rank_of("rapid"))

func orbit_damage() -> float:
	if staged:
		return 4.0 * SalvageProgression.multiplier(rank_of("grinder"))
	return 4.0 + rank_of("grinder") * 2.0

func shard_damage() -> float:
	if staged:
		return 4.0 * SalvageProgression.multiplier(rank_of("ricochet")) if passive_enabled("ricochet") else 0.0
	return 4.0 + rank_of("ricochet") * 2.0 if passive_enabled("ricochet") and (rank_of("ricochet") > 0 or kit != null) else 0.0

func pulse_damage() -> float:
	if staged:
		return 5.0 * SalvageProgression.multiplier(rank_of("pulse")) if passive_enabled("pulse") else 0.0
	return 5.0 + rank_of("pulse") * 3.0 if passive_enabled("pulse") and (rank_of("pulse") > 0 or kit != null) else 0.0

func pulse_radius() -> float:
	if staged:
		return 108.0 * (1 + milestone("pulse") * 0.25) if pulse_damage() > 0 else 0.0
	return 108.0 + rank_of("pulse") * 20.0 if pulse_damage() > 0 else 0.0

func upgrade_values(id: String, rank_value: int = -1) -> Array[Dictionary]:
	var r := rank_of(id) if rank_value < 0 else rank_value
	if staged:
		return SalvageProgression.values(self, id, r)
	match id:
		"grinder": return [{"label": "Damage", "value": 4 + r * 2, "unit": ""}, {"label": "Hits / tool", "value": 1 + r, "unit": ""}, {"label": "Orbit radius", "value": 49 + r * 7, "unit": " px"}]
		"ricochet": return [{"label": "Shard damage", "value": 4 + r * 2 if r > 0 or kit != null else 0, "unit": ""}, {"label": "Bounces", "value": r + (1 if kit != null else 0), "unit": ""}]
		"pulse": return [{"label": "Pulse damage", "value": 5 + r * 3 if r > 0 or kit != null else 0, "unit": ""}, {"label": "Radius", "value": 108 + r * 20 if r > 0 or kit != null else 0, "unit": " px"}]
		"magnet": return [{"label": "Pickup radius", "value": 83 + r * 27 + (45 if kit != null and kit.passive_active("magnet") else 0), "unit": " px"}]
		"reactor": return [{"label": "Regen / sec", "value": 8 + r * 2 + (kit.regen_bonus - rank_of("reactor") * 2 if kit != null else 0), "unit": ""}]
		"cell": return [{"label": "Max energy", "value": 100 + r * 20 + (kit.energy_bonus - rank_of("cell") * 20 if kit != null else 0), "unit": ""}]
		"rapid": return [{"label": "Shots / sec", "value": snappedf(pow(1.22, r) / 0.43, 0.01), "unit": ""}]
		"power": return [{"label": "Bolt damage", "value": 2 + r * 1.5, "unit": ""}, {"label": "Pierces", "value": r, "unit": ""}]
		"capacity": return [{"label": "Tool slots", "value": 6 + r * 2, "unit": ""}]
	return [{"label": "Hull", "value": health, "unit": " / %d" % max_health()}]

func stats() -> Dictionary:
	return {"bolt_damage": bolt_damage(), "fire_rate": 1.0 / fire_interval(), "pierce": bolt_pierces(),
		"orbit_damage": orbit_damage(), "orbit_hits": orbit_hits(), "orbit_radius": orbit_radius(),
		"capacity": capacity(), "magnet_radius": magnet_radius(), "move_speed": kit.speed() if kit != null else 205.0,
		"shard_damage": shard_damage(), "bounces": shard_bounces() if passive_enabled("ricochet") else 0, "pulse_damage": pulse_damage(), "pulse_radius": pulse_radius()}

func rank_of(id: String) -> int:
	var bonus:=0
	if kit!=null and kit.rank_bonus>0 and id in ["power","rapid","grinder","ricochet","pulse","capacity"]:
		var owner: String={"power":"bolt","rapid":"bolt","grinder":"orbit","ricochet":"ricochet","pulse":"pulse","capacity":"orbit"}[id]
		if BotKeyboard.learned(kit,owner)!="" or (id=="power" and (BotKeyboard.learned(kit,"lightning")!="" or BotKeyboard.learned(kit,"poison")!="" or BotKeyboard.learned(kit,"threehit")!="")): bonus=kit.rank_bonus
	return mini(10,int(upgrades.get(id,0))+bonus)

func capacity() -> int:
	if staged:
		return 6 + rank_of("capacity") + milestone("capacity") * 2
	return 6 + rank_of("capacity") * 2

func orbit_radius() -> float:
	if kit != null and kit.onboarding and kit.orbit_far:
		return 105.0 * (1 + milestone("grinder") * 0.35)
	if staged:
		return 49.0 * (1 + milestone("grinder") * 0.35)
	return 49.0 + rank_of("grinder") * 7.0

func magnet_radius() -> float:
	if exp != null: return 65 + rank_of("magnet") * 23 + exp.stats.get("magnet", 0)
	if kit != null and kit.onboarding:
		return 65.0 + rank_of("magnet") * 23.0 + mastery.rank_of("reach") * 35.0
	if staged:
		return 150.0 + rank_of("magnet") * 100.0
	return 83.0 + rank_of("magnet") * 27.0 + (45.0 if kit != null and kit.passive_active("magnet") else 0.0)

func orbit_hits() -> int:
	return 1 + (milestone("grinder") if staged else rank_of("grinder"))

func bolt_pierces() -> int:
	return milestone("power") if staged else rank_of("power")

func shard_bounces() -> int:
	return 1 + rank_of("ricochet") / 2 + milestone("ricochet") * 2 if staged else rank_of("ricochet") + (1 if kit != null else 0)

func emit_event(kind: String, position: Vector2, extra: Dictionary = {}) -> void:
	if events.size() >= 400:
		return
	var event := {"kind": kind, "pos": position}
	event.merge(extra)
	events.append(event)

func step(delta: float, input_direction: Vector2) -> void:
	if state != "running":
		return
	time += delta
	if staged:
		stage_time += delta
	invincible = maxf(0.0, invincible - delta)
	slow_left = maxf(0, slow_left - delta)
	if kit != null:
		kit.step(self, delta)
		attacks.prepare(self, delta)
		if kit.dash_left > 0:
			kit.move_dash(self, delta)
		elif kit.laser_left > 0 or kit.extra.rooted():
			stop_movement()
		elif moving:
			var offset := kit.extra.route(player, move_target, 16) - player
			velocity = offset.limit_length(kit.speed() * (0.8 if slow_left > 0 else 1.0) * delta) / maxf(delta, 0.00001)
			player = kit.extra.solid_point(player, player + velocity * delta, 16)
			if player.distance_to(move_target) < 0.01:
				stop_movement()
		else:
			velocity = Vector2.ZERO
	else:
		velocity = input_direction.limit_length() * 205.0
		player += velocity * delta
	player = player.clamp(ARENA.position + Vector2(16, 16), ARENA.end - Vector2(16, 16))
	_spawn_step(delta)
	_enemy_step(delta)
	if demo_mode: DemoCampaign.hazards_step(self, delta)
	if state != "running":
		return
	_weapon_step(delta)
	_projectile_step(delta)
	if state != "running":
		return
	_orbit_step(delta)
	_pickup_step(delta)
	_supply_step(delta)
	_cache_step()
	_pulse_step(delta)
	# Always finish before opening a new menu on the last tick.
	if exp != null:
		exp.finish_step(self, delta)
	elif staged and state == "running" and (DemoCampaign.ready_to_clear(self) if demo_mode else boss_defeated):
		if stage_clear_wait < 0:
			stage_clear_wait = 1.4
		stage_clear_wait -= delta
		# Let the boss loot burst play before opening its reward screen.
		if stage_clear_wait <= 0:
			if demo_mode:
				demo_history.append({"level": stage, "name": DemoCampaign.info(self).name, "seconds": snappedf(time - level_start_time, 0.01), "power_level": level, "kills": kills, "ranks": upgrades.duplicate(), "hull": health, "minibosses": demo_minis_killed})
				hazards.clear()
			enemies.clear() # Retire survivors before collection pulses can create more drops.
			for pickup in pickups.duplicate():
				collect_pickup(pickup)
			pickups.clear()
			for supply in supply_drops:
				_collect_supply(supply)
			supply_drops.clear()
			projectiles.clear()
			pending_pulses = 0
			kit.salvos.clear()
			kit.zones.clear()
			kit.dash_left = 0
			kit.cancel_laser()
			kit.flame_left = 0
			kit.summon.clear()
			kit.poison_trail.clear()
			stop_movement()
			if stage >= STAGE_COUNT:
				state = "won"
				emit_event("win", player)
			else:
				make_stage_rewards()
				state = "stage_reward"
				emit_event("stage_clear", player)
	elif not staged and time >= DURATION and state == "running":
		state = "won"
		emit_event("win", player)
	elif total_xp >= next_level and state == "running":
		_make_offers()
		state = "upgrade"
		emit_event("upgrade", player)

func _spawn_step(delta: float) -> void:
	if exp != null:
		exp.spawns(self, delta)
		return
	if demo_mode:
		DemoCampaign.spawns(self, delta)
		return
	if staged:
		_staged_spawns(delta)
		return
	# Keep the encounter around the moving camera. Distant ordinary enemies are
	# retired without rewards; the boss persists. Earned scrap is never culled.
	enemies = enemies.filter(func(e: Dictionary) -> bool: return e.kind == 2 or Vector2(e.pos).distance_to(player) < maxf(1250, view_size.length()))
	if staged and (boss_spawned or boss_defeated):
		return
	spawn_clock -= delta
	while spawn_clock <= 0.0:
		spawn_clock += maxf(0.24, 0.9 - time * 0.007)
		var side := spawn_rng.randi_range(0, 3)
		var point := Vector2.ZERO
		var view := follow_origin()
		var size := view_size
		match side:
			0: point = view + Vector2(spawn_rng.randf_range(30, size.x - 30), -35)
			1: point = view + Vector2(size.x + 35, spawn_rng.randf_range(30, size.y - 30))
			2: point = view + Vector2(spawn_rng.randf_range(30, size.x - 30), size.y + 35)
			3: point = view + Vector2(-35, spawn_rng.randf_range(30, size.y - 30))
		point = point.clamp(ARENA.position + Vector2.ONE * 20, ARENA.end - Vector2.ONE * 20)
		var kind := 1 if time > 12.0 and spawn_rng.randf() < 0.24 else 0
		if kit != null and time > 24 and spawn_rng.randf() < 0.15:
			kind = 3
		spawn_enemy(point, kind)
	if (stage_time >= STAGE_LENGTH if staged else time >= 67.0) and not boss_spawned:
		# The required boss must not be blocked by the ordinary-enemy cap.
		if enemies.size() >= MAX_ENEMIES:
			enemies.pop_back()
		boss_spawned = true
		var point := (player + Vector2(0, -360)).clamp(ARENA.position + Vector2.ONE * 40, ARENA.end - Vector2.ONE * 40)
		spawn_enemy(point, 2)
		if staged and not enemies.is_empty():
			var boss: Dictionary = enemies.back()
			boss.hp = 100.0 + stage * 35
			boss.max_hp = boss.hp
		emit_event("boss", point)

func _cache_step() -> void:
	for cache in caches:
		if not cache.opened and player.distance_to(cache.pos) < 40:
			cache.opened = true
			caches_opened += 1
			for i in range(8):
				_drop(Vector2(cache.pos) + Vector2.from_angle(i * TAU / 8) * 42, 1)
			emit_event("cache", cache.pos)

func spawn_enemy(point: Vector2, kind: int = 0) -> void:
	if enemies.size() >= MAX_ENEMIES:
		return
	var hp := [3.0, 8.0, 150.0, 32.0][kind] as float
	enemies.append({"id": next_id, "pos": point, "kind": kind, "hp": hp, "max_hp": hp,
		"radius": [14.0, 17.0, 31.0, 25.0][kind], "flash": 0.0, "knock": Vector2.ZERO,
		"phase": "seek", "clock": 1.4 + float(next_id % 5) * 0.2, "dir": Vector2.DOWN,
		"warmup": 0.65, "dead": false})
	next_id += 1

func _offscreen_point(side: int = -1) -> Vector2:
	var view := Rect2(follow_origin(), view_size).grow(70)
	var valid: Array[int] = []
	if view.position.y > ARENA.position.y + 30: valid.append(0)
	if view.end.x < ARENA.end.x - 30: valid.append(1)
	if view.end.y < ARENA.end.y - 30: valid.append(2)
	if view.position.x > ARENA.position.x + 30: valid.append(3)
	if side not in valid:
		side = valid[spawn_rng.randi_range(0, valid.size() - 1)]
	var point := Vector2.ZERO
	match side:
		0: point = Vector2(spawn_rng.randf_range(view.position.x, view.end.x), view.position.y)
		1: point = Vector2(view.end.x, spawn_rng.randf_range(view.position.y, view.end.y))
		2: point = Vector2(spawn_rng.randf_range(view.position.x, view.end.x), view.end.y)
		3: point = Vector2(view.position.x, spawn_rng.randf_range(view.position.y, view.end.y))
	return point.clamp(ARENA.position + Vector2.ONE * 25, ARENA.end - Vector2.ONE * 25)

func _spawn_pack(count: int, pressure: bool = false) -> void:
	var side := spawn_rng.randi_range(0, 3)
	for i in range(count):
		if enemies.size() >= MAX_ENEMIES: break
		var kind := 0
		if pressure:
			kind = 3 if i % 5 == 4 else (1 if i % 3 == 2 else 0)
		elif stage_time > 12 and spawn_rng.randf() < 0.18:
			kind = 1
		spawn_enemy(_offscreen_point(side if pressure else -1), kind)
		var enemy: Dictionary = enemies.back()
		enemy["elite"] = pressure
		enemy["runner"] = pressure and kind == 0
		enemy.hp *= (1.0 + stage * 0.18) * (1.65 if pressure else 1.0)
		enemy.max_hp = enemy.hp

func _staged_spawns(delta: float) -> void:
	# Open sides only: clamping a spawn along a blocked edge would reveal it.
	enemies = enemies.filter(func(e: Dictionary) -> bool: return e.kind == 2 or Vector2(e.pos).distance_to(player) < maxf(1500, view_size.length() + 200))
	if boss_spawned or boss_defeated: return
	if stage_time >= STAGE_LENGTH:
		if enemies.size() >= MAX_ENEMIES: enemies.pop_back()
		spawn_enemy(_offscreen_point(), 2)
		var boss: Dictionary = enemies.back()
		boss.hp = 260.0 + stage * 90
		boss.max_hp = boss.hp
		boss_spawned = true
		emit_event("boss", boss.pos)
		return
	var wave := mini(3, int((stage_time + 2) / 18))
	if wave > pressure_warning:
		pressure_warning = wave
		emit_event("pressure_warning", player)
	wave = mini(3, int(stage_time / 18))
	if wave > pressure_wave:
		pressure_wave = wave
		_spawn_pack(8 + stage * 3, true)
		emit_event("pressure", player)
	spawn_clock -= delta
	while spawn_clock <= 0:
		# A short recovery interval follows each surge.
		var recovering := fmod(stage_time, 18.0) < 5.0 and stage_time > 18
		spawn_clock += 1.2 if recovering else 0.72
		_spawn_pack(1 if recovering else 2 + stage)

func _enemy_step(delta: float) -> void:
	for enemy in enemies:
		if enemy.dead:
			continue
		enemy.flash = maxf(0, float(enemy.flash) - delta)
		enemy.warmup = maxf(0, float(enemy.warmup) - delta)
		if enemy.warmup > 0:
			continue
		if enemy.get("stun", 0.0) > 0:
			enemy.stun = maxf(0, enemy.stun - delta)
			continue
		if demo_mode and enemy.has("role"):
			DemoCampaign.enemy_step(self, enemy, delta)
			if state != "running": break
			continue
		var tracked_player: Vector2 = kit.extra.decoy_position if kit != null and kit.extra.decoy_left > 0 else player
		var target_point: Vector2 = kit.extra.route(enemy.pos, tracked_player, enemy.radius) if kit != null else player
		var direction := (target_point - Vector2(enemy.pos)).normalized()
		var speed := 40.0 + minf(time * 0.28, 22.0)
		enemy.clock -= delta
		if enemy.kind == 1:
			if enemy.phase == "seek" and enemy.clock <= 0:
				enemy.phase = "windup"
				enemy.clock = 0.7
				enemy.dir = direction
			elif enemy.phase == "windup":
				speed = 0.0
				if enemy.clock <= 0:
					enemy.phase = "dash"
					enemy.clock = 0.65
			elif enemy.phase == "dash":
				direction = enemy.dir
				speed = 255.0
				if enemy.clock <= 0:
					enemy.phase = "seek"
					enemy.clock = 2.2
		elif enemy.kind == 3:
			speed = 32.0
		elif enemy.kind == 2:
			speed = 26.0
			if enemy.clock <= 0:
				enemy.clock = 2.4
				for angle in [-0.35, 0.0, 0.35]:
					_add_projectile(enemy.pos, direction.rotated(angle) * 138.0, 1.0, "hostile", 0)
		if staged:
			if enemy.kind == 0: speed = (210.0 + stage * 8) if enemy.get("runner", false) else (80.0 + stage * 10)
			elif enemy.kind == 3: speed = 55.0 + stage * 5
			elif enemy.kind == 2: speed = 44.0
			elif enemy.phase == "seek": speed = 105.0
		if demo_mode:
			speed *= 1.2 if enemy.kind != 1 or enemy.phase == "seek" else 1.0
		if exp != null: speed *= exp.enemy_speed()
		var previous_pos: Vector2 = enemy.pos
		enemy.pos += (direction * speed + Vector2(enemy.knock)) * delta
		if kit != null: enemy.pos = kit.extra.solid_point(previous_pos, enemy.pos, enemy.radius)
		enemy.knock = Vector2(enemy.knock).move_toward(Vector2.ZERO, delta * 500.0)
		if Vector2(enemy.pos).distance_to(player) < float(enemy.radius) + 12.0:
			if demo_mode and enemy.kind == 3: apply_slow(1.2)
			hurt_player(enemy.pos, CombatReadability.enemy_name(enemy) + (" charge" if enemy.phase == "dash" else " contact"), 2 if demo_mode and (enemy.kind in [1, 3] or enemy.get("elite", false)) else 1)
			if state != "running":
				break

func hurt_player(source: Vector2, cause: String = "Collision", amount: int = 1) -> void:
	if invincible > 0 or state != "running":
		return
	if kit != null and kit.shield > 0:
		kit.shield_hits -= 1
		if kit.shield_hits <= 0: kit.shield = 0
		invincible = 0.4
		emit_event("pulse", player, {"radius": 45.0})
		return
	var actual := float(amount)
	if exp != null: actual = exp.incoming(self, actual)
	health = maxf(0, health - actual)
	if kit != null: kit.extra.repair_left = 0
	damage_taken += actual
	last_damage = cause
	last_damage_time = time
	last_damage_direction = (source - player).normalized()
	damage_history.append({"seconds": snappedf(time, 0.01), "level": stage, "cause": cause, "hull_after": health})
	if damage_history.size() > 32: damage_history.pop_front()
	invincible = 0.85 if demo_mode else 1.35
	if kit != null and kit.passive_active("plating"):
		invincible += 0.65 * kit.passive_scale("plating")
	if health > 0 and kit != null and kit.passive_active("thorns"):
		MobaKit.area(self, player, 100, 6 * kit.passive_scale("thorns"), "active", 180)
	emit_event("hurt", player)
	for enemy in enemies:
		if Vector2(enemy.pos).distance_to(player) < 85.0:
			enemy.knock = (Vector2(enemy.pos) - player).normalized() * 240.0
	if health <= 0:
		if kit != null: kit.cancel_laser()
		state = "lost"
		emit_event("lost", source)

func nearest_enemy(point: Vector2, excluded: Array = []) -> Dictionary:
	var best: Dictionary = {}
	var distance := INF
	for enemy in enemies:
		if enemy.dead or enemy.warmup > 0 or enemy.id in excluded:
			continue
		var d := point.distance_squared_to(enemy.pos)
		if d < distance:
			distance = d
			best = enemy
	return best

func _weapon_step(delta: float) -> void:
	if attacks.enabled:
		attacks.fire(self)
		return
	if not passive_enabled("bolt"):
		return
	shot_clock -= delta
	if shot_clock > 0:
		return
	var target := nearest_enemy(player)
	if target.is_empty():
		return
	if kit != null and player.distance_to(target.pos) > 310:
		return
	var direction := (Vector2(target.pos) - player).normalized()
	if kit == null or kit.laser_left <= 0: aim = direction
	shot_clock = fire_interval()
	_add_projectile(player + direction * 22.0, direction * 540.0, bolt_damage(), "bolt", bolt_pierces())
	emit_event("shot", player)

func _add_projectile(point: Vector2, motion: Vector2, damage: float, kind: String, pierce: int) -> void:
	if projectiles.size() >= MAX_PROJECTILES:
		if kind != "hostile": return
		# A promised boss attack cannot vanish because friendly spectacle filled the pool.
		var replacement := -1
		for i in range(projectiles.size()):
			if projectiles[i].kind != "hostile":
				replacement = i
				break
		if replacement < 0: return
		projectiles.remove_at(replacement)
	projectiles.append({"pos": point, "prev": point, "vel": motion, "damage": damage,
		"kind": kind, "life": 620.0 / 850.0 if kind == "rail" else 2.7, "pierce": pierce, "hits": []})

func _projectile_step(delta: float) -> void:
	# Rebuild a small spatial index once per tick instead of testing every bullet
	# against the whole crowd. Each center occurs in exactly one cell.
	var grid: Dictionary = {}
	for enemy in enemies:
		if enemy.dead or enemy.warmup > 0:
			continue
		var cell := Vector2i((Vector2(enemy.pos) / COLLISION_CELL).floor())
		if not grid.has(cell):
			grid[cell] = []
		grid[cell].append(enemy)
	for bullet in projectiles:
		if bullet.life <= 0: continue
		if bullet.kind == "homing":
			var target := nearest_enemy(bullet.pos, bullet.hits)
			if not target.is_empty():
				bullet.vel = Vector2(bullet.vel).lerp((Vector2(target.pos) - Vector2(bullet.pos)).normalized() * 430, minf(1, delta * 12)).normalized() * 430
		bullet.prev = bullet.pos
		bullet.pos += Vector2(bullet.vel) * (minf(delta, maxf(0, bullet.life)) if bullet.kind in ["rail", "rocket"] or bullet.get("basic_attack", false) else delta)
		bullet.life -= delta
		var blocked := false
		if kit != null:
			for wall in kit.extra.walls:
				if Geometry2D.segment_intersects_segment(bullet.prev, bullet.pos, wall.a, wall.b) != null: bullet.life = 0; blocked = true; break
		if blocked: continue
		if bullet.kind == "hostile":
			var near := Geometry2D.get_closest_point_to_segment(player, bullet.prev, bullet.pos)
			if near.distance_to(player) < 17:
				if bullet.get("slow", false): apply_slow(1.2)
				hurt_player(bullet.pos, "Hostile projectile", int(bullet.damage))
				bullet.life = 0.0
			continue
		var start: Vector2 = bullet.prev
		var end: Vector2 = bullet.pos
		# Largest enemy radius + projectile radius: grow both ends of the swept box.
		var minimum := Vector2i(((start.min(end) - Vector2.ONE * 68) / COLLISION_CELL).floor())
		var maximum := Vector2i(((start.max(end) + Vector2.ONE * 68) / COLLISION_CELL).floor())
		var candidates: Array[Dictionary] = []
		for x in range(minimum.x, maximum.x + 1):
			for y in range(minimum.y, maximum.y + 1):
				candidates.append_array(grid.get(Vector2i(x, y), []))
		# Stable front-to-back order also handles rare fast, long swept segments.
		var motion := end - start
		candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			var da := (Vector2(a.pos) - start).dot(motion)
			var db := (Vector2(b.pos) - start).dot(motion)
			return a.id < b.id if is_equal_approx(da, db) else da < db)
		for enemy in candidates:
			if enemy.dead or enemy.warmup > 0 or enemy.id in bullet.hits:
				continue
			var closest := Geometry2D.get_closest_point_to_segment(enemy.pos, bullet.prev, bullet.pos)
			if closest.distance_to(enemy.pos) > float(enemy.radius) + 4.0:
				continue
			bullet.hits.append(enemy.id)
			if bullet.kind == "rocket" and mastery.rank_of("shock") > 0 and not enemy.has("role"): enemy["stun"] = 0.35
			hit_enemy(enemy, bullet.damage, bullet.kind, Vector2(bullet.vel).normalized() * 72.0)
			if bullet.kind == "basic" and kit != null: kit.extra.commanded_hit(self, enemy)
			if bullet.pierce <= 0:
				if bullet.kind == "rocket": bullet.pos = closest
				bullet.life = 0.0
				break
			bullet.pierce -= 1
			if bullet.kind == "shard":
				var target := nearest_enemy(enemy.pos, bullet.hits)
				if not target.is_empty():
					bullet.pos = enemy.pos
					bullet.vel = (Vector2(target.pos) - Vector2(bullet.pos)).normalized() * 480.0
				break
		if bullet.kind == "rocket" and bullet.life <= 0:
			MobaKit.area(self, bullet.pos, bullet.get("radius", 62), bullet.get("blast", 8), "rocket", 110)
			emit_event("rocket_impact", bullet.pos, {"radius": bullet.get("radius", 62)})
			if mastery.rank_of("aftershock") > 0:
				MobaKit.area(self, bullet.pos, bullet.get("radius", 62) * 1.5, 12 * bullet.get("blast", 8) / 8.0, "aftershock", 160)
	projectiles = projectiles.filter(func(b: Dictionary) -> bool: return b.life > 0)
	enemies = enemies.filter(func(e: Dictionary) -> bool: return not e.dead)

func hit_enemy(enemy: Dictionary, damage: float, source: String, knock: Vector2 = Vector2.ZERO) -> void:
	if enemy.dead:
		return
	if demo_mode and enemy.has("role") and enemy.phase == "recover": damage *= 1.5
	damage_dealt[source] = float(damage_dealt.get(source, 0.0)) + minf(damage, enemy.hp)
	enemy.hp -= damage
	enemy.flash = 0.085
	enemy.knock = knock
	emit_event("hit", enemy.pos)
	if enemy.hp <= 0:
		enemy.dead = true
		if exp != null: exp.enemy_killed(self, enemy)
		kills += 1
		if kit != null and kit.onboarding:
			if loot_rng.randf() < minf(0.20, (1.0 + drop_bonus) / 25.0):
				_drop_supply(enemy.pos, "coins", 25)
			if loot_rng.randf() < minf(0.25, (1.0 + drop_bonus) / 15.0):
				_drop_supply(Vector2(enemy.pos) + Vector2(-20, 0), "speed" if loot_rng.randf() < 0.5 else "reset", 1)
			if enemy.has("role"): _drop_supply(Vector2(enemy.pos) + Vector2(0, 24), "coins", 75)
		if kit != null:
			var count: int = [3, 10, 72, 20][enemy.kind] if staged else [1, 6, 48, 12][enemy.kind]
			if enemy.has("role") and enemy.role != "foreman": count = 30
			if staged and enemy.get("elite", false): count += 5
			loot_shower(enemy.pos, count)
			if staged and enemy.kind != 0:
				_drop_supply(enemy.pos, "energy", 18 if enemy.kind != 2 else 50)
				if enemy.kind == 2 or (enemy.kind == 3 and kills % 3 == 0):
					_drop_supply(Vector2(enemy.pos) + Vector2(22, 0), "repair", 1)
		else:
			_drop(enemy.pos, 12 if enemy.kind == 2 else (3 if enemy.kind == 1 else 1))
		emit_event("kill", enemy.pos, {"enemy_kind": enemy.kind})
		if demo_mode and enemy.has("role") and enemy.role != "foreman":
			demo_minis_killed += 1
			emit_event("miniboss_down", enemy.pos)
		elif enemy.kind == 2:
			boss_defeated = true
			if demo_mode:
				# The final victory beat must not be overturned by lingering attacks.
				hazards.clear()
				for bullet in projectiles:
					if bullet.kind == "hostile": bullet.life = 0
			heal(1)
			emit_event("boss_down", enemy.pos)

func orbit_position(index: int) -> Vector2:
	var angle := time * 2.6 + float(orbit[index].slot) * TAU / float(capacity())
	return player + Vector2.from_angle(angle) * orbit_radius()

func _orbit_step(delta: float) -> void:
	if mode != "salvage" or not passive_enabled("orbit"):
		return
	for index in range(orbit.size()):
		var piece: Dictionary = orbit[index]
		piece.cooldown = maxf(0.0, float(piece.cooldown) - delta)
		if piece.cooldown > 0:
			continue
		var point := orbit_position(index)
		for enemy in enemies:
			if enemy.dead or enemy.warmup > 0:
				continue
			if point.distance_to(enemy.pos) > float(enemy.radius) + 12.0 + rank_of("grinder") * 2:
				continue
			hit_enemy(enemy, orbit_damage(), "orbit", (Vector2(enemy.pos) - player).normalized() * 110)
			piece.hits -= 1
			piece.cooldown = 0.28
			if piece.hits <= 0:
				emit_event("spent", point)
				if shard_damage() > 0:
					var target := nearest_enemy(point, [enemy.id])
					var direction := (point - player).normalized()
					if not target.is_empty():
						direction = (Vector2(target.pos) - point).normalized()
					_add_projectile(point, direction * 480, shard_damage(), "shard", shard_bounces())
			break
	orbit = orbit.filter(func(p: Dictionary) -> bool: return p.hits > 0)

func loot_shower(point: Vector2, count: int) -> void:
	for i in range(count):
		var before := pickups.size()
		_drop(point, 1)
		if pickups.size() > before:
			var angle := i * 2.399963 + time
			pickups.back().scatter = Vector2.from_angle(angle) * (75 + (i % 7) * 23)
			pickups.back().settle = 0.25 + (i % 5) * 0.025
	if count >= 6:
		emit_event("loot", point, {"count": count})

func _drop(point: Vector2, value: int) -> void:
	if pickups.size() >= MAX_PICKUPS:
		# Conserve XP; visual-object caps must never discard earned rewards.
		var closest: Dictionary = pickups[0]
		for existing in pickups:
			if point.distance_squared_to(existing.pos) < point.distance_squared_to(closest.pos):
				closest = existing
		closest.value += value
		return
	pickups.append({"pos": point, "value": value, "pull": false, "speed": 0.0, "id": next_id})
	next_id += 1

func _pickup_step(delta: float) -> void:
	if staged and rank_of("magnet") >= 5 and not (kit != null and kit.onboarding):
		vacuum_clock -= delta
		if vacuum_clock <= 0:
			vacuum_clock += 15
			for pickup in pickups: pickup.pull = true
			emit_event("vacuum", player)
	for pickup in pickups.duplicate():
		if pickup.get("settle", 0.0) > 0:
			pickup.settle -= delta
			pickup.pos = (Vector2(pickup.pos) + Vector2(pickup.scatter) * delta).clamp(ARENA.position + Vector2.ONE * 17, ARENA.end - Vector2.ONE * 17)
			pickup.scatter = Vector2(pickup.scatter).move_toward(Vector2.ZERO, delta * 260)
			continue
		var distance := Vector2(pickup.pos).distance_to(player)
		if distance < magnet_radius():
			pickup.pull = true
		if pickup.pull:
			pickup.speed = minf(800 + rank_of("magnet") * 180 if staged else 640, float(pickup.speed) + delta * (2200 if staged else 1100))
			pickup.pos = Vector2(pickup.pos).move_toward(player, float(pickup.speed) * delta)
		if Vector2(pickup.pos).distance_to(player) < 17:
			collect_pickup(pickup)
	pickups = pickups.filter(func(p: Dictionary) -> bool: return p.value > 0)

func collect_pickup(pickup: Dictionary) -> void:
	var value := int(pickup.value)
	if value <= 0:
		return
	pickup.value = 0 # Claim before triggering damage/reward events.
	xp_fraction += value * (1.0 + (float(exp.stats.get("xp", 0)) if exp != null else mastery.rank_of("learning") * 0.1))
	var gained := floori(xp_fraction + 0.000001)
	total_xp += gained
	xp_fraction = maxf(0, xp_fraction - gained)
	collected += value
	if mode == "salvage":
		for i in range(mini(value, capacity() - orbit.size()) if passive_enabled("orbit") else 0):
			var used: Array = orbit.map(func(p: Dictionary) -> int: return p.slot)
			for slot in range(capacity()):
				if slot not in used:
					orbit.append({"slot": slot, "hits": orbit_hits(), "cooldown": 0.0})
					break
		if pulse_damage() > 0:
			pulse_charge += value
			if pulse_charge >= 8:
				pending_pulses += pulse_charge / 8
				pulse_charge %= 8
				_pulse_step(0)
	emit_event("pickup", player, {"value": value})

func _pulse_step(delta: float) -> void:
	if kit != null and not kit.passive_active("pulse"):
		pending_pulses = 0
		return
	pulse_cooldown = maxf(0, pulse_cooldown - delta)
	if pending_pulses > 0 and pulse_cooldown <= 0:
		pending_pulses -= 1
		pulse_cooldown = 0.15
		pulse()

func pulse() -> void:
	var radius := pulse_radius()
	emit_event("pulse", player, {"radius": radius})
	# Dead enemies are claimed immediately; no recursive collection is performed.
	for enemy in enemies:
		if Vector2(enemy.pos).distance_to(player) <= radius + float(enemy.radius):
			hit_enemy(enemy, pulse_damage(), "pulse", (Vector2(enemy.pos) - player).normalized() * 220)

func _make_offers() -> void:
	offers.clear()
	if level == 1 and mode == "salvage" and kit == null:
		offers.assign(["grinder", "ricochet", "pulse"])
		return
	var pool: Array[String] = []
	for id in upgrade_ids():
		if staged and id == "magnet": continue # Utility never consumes a combat choice.
		if not upgrade_available(id):
			continue
		if rank_of(id) < rank_limit(id):
			pool.append(id)
	if staged:
		# Offer one focused continuation so rank-5/10 milestones are attainable.
		var focused: Array = pool.filter(func(id: String) -> bool: return rank_of(id) > 0)
		if not focused.is_empty():
			focused.sort_custom(func(a: String, b: String) -> bool: return rank_of(a) > rank_of(b))
			offers.append(focused[0])
			pool.erase(focused[0])
	while offers.size() < 3 and not pool.is_empty():
		var index := offer_rng.randi_range(0, pool.size() - 1)
		offers.append(pool[index])
		pool.remove_at(index)
	if offers.is_empty():
		offers.append("repair")

func choose_upgrade(index: int) -> bool:
	if state != "upgrade" or index < 0 or index >= offers.size():
		return false
	var id := offers[index]
	if id == "repair":
		heal(1)
	else:
		if rank_of(id) >= rank_limit(id): return false
		upgrades[id] += 1
		if staged and id.begins_with("skill_"):
			kit.rank_up(id.trim_prefix("skill_"))
		if staged:
			_sync_resource_ranks()
		elif kit != null and id == "reactor":
			kit.regen_bonus += 2
		elif kit != null and id == "cell":
			kit.energy_bonus += 20
		if id == "grinder" and (not staged or rank_of(id) % 5 == 0):
			for piece in orbit:
				piece.hits += 1
	upgrade_history.append({"time": snappedf(time, 0.01), "id": id, "level": level, "demo_level": stage if demo_mode else 0})
	level += 1
	if exp != null: exp.level_up(self)
	if staged and (level - 1) % 3 == 0: grant_utility()
	next_level += (12 + level * 8) if staged else (8 + level * 4)
	offers.clear()
	state = "running"
	invincible = maxf(invincible, 0.65)
	emit_event("equipped", player, {"id": id})
	if staged and rank_of(id) > 0 and rank_of(id) % 5 == 0:
		emit_event("milestone", player, {"id": id, "rank": rank_of(id)})
	return true

func _drop_supply(point: Vector2, kind: String, value: int) -> void:
	# Separate bounded pool: supply rewards cannot consume XP or be converted to it.
	if supply_drops.filter(func(s: Dictionary) -> bool: return s.kind == kind).size() >= 20:
		for existing in supply_drops:
			if existing.kind == kind:
				existing.value += value
				return
		return
	supply_drops.append({"pos": point, "kind": kind, "value": value, "age": 0.0})

func _collect_supply(supply: Dictionary) -> void:
	if supply.value <= 0: return
	match supply.kind:
		"energy": kit.energy = minf(kit.energy_max(), kit.energy + supply.value)
		"repair": heal(supply.value)
		"coins": coins += supply.value
		"speed": kit.boost_speed = 6.0
		"reset":
			for slot in (kit.active_slots() if kit.flexible() else ["q", "w", "e"]):
				if kit.flexible() and (not kit.unlocked(slot) or MobaKit.ABILITIES[kit.loadout[slot]].category!="active"): continue
				kit.charges[slot] = MobaKit.ABILITIES[kit.loadout[slot]].max
				kit.recharge[slot] = 0
	emit_event("supply", player, {"supply": supply.kind})
	supply.value = 0
	emit_event("equipped", player, {"id": "repair"})

func _supply_step(delta: float) -> void:
	if not staged: return
	for supply in supply_drops:
		supply.age += delta
		if supply.age < 0.35: continue
		if Vector2(supply.pos).distance_to(player) < (48.0 if kit.onboarding else magnet_radius()):
			supply.pos = Vector2(supply.pos).move_toward(player, delta * 900)
		if Vector2(supply.pos).distance_to(player) < 18: _collect_supply(supply)
	supply_drops = supply_drops.filter(func(s: Dictionary) -> bool: return s.value > 0)

func use_consumable(index: int) -> bool:
	if state != "running" or kit == null or index < 0 or index > 1 or consumables[index] <= 0: return false
	if (index == 0 and health >= max_health()) or (index == 1 and kit.energy >= kit.energy_max()): return false
	consumables[index] -= 1
	if index == 0: heal(2)
	else: kit.energy = minf(kit.energy_max(), kit.energy + 50)
	emit_event("equipped", player, {"id": "repair" if index == 0 else "cell"})
	return true

func summary() -> Dictionary:
	return {"seed": run_seed, "mode": mode, "result": state, "seconds": snappedf(time, 0.01),
		"kills": kills, "scrap": collected, "level": level, "damage_taken": damage_taken,
		"last_damage": last_damage, "recent_damage": damage_history.duplicate(true),
		"damage_by_source": damage_dealt.duplicate(), "upgrades": upgrade_history.duplicate(true),
		"boss_defeated": boss_defeated, "control_mode": "moba" if kit != null else "legacy",
		"loadout": kit.loadout.duplicate(true) if kit != null else {}, "casts": kit.cast_counts.duplicate() if kit != null else {},
		"stage": stage, "stage_rewards": stage_history.duplicate(true), "energy_spent": kit.energy_spent if kit != null else 0, "health_spent": kit.health_spent if kit != null else 0,
		"ranks": upgrades.duplicate(), "utility_rewards": utility_history.duplicate(true), "demo": demo_mode, "demo_levels": demo_history.duplicate(true)}
