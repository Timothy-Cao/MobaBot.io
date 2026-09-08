class_name DemoCampaign
extends RefCounted
## One authored demo Stage, three Levels. No post-demo content.
const LEVELS := [
	{"name": "Loading bay", "seconds": 75.0, "goal": "Survive the waves", "start": Vector2(480, 300)},
	{"name": "Assembly line", "seconds": 90.0, "goal": "Defeat both wardens", "start": Vector2(1150, -480)},
	{"name": "Reactor floor", "seconds": 90.0, "goal": "Survive, then defeat the Foreman", "start": Vector2(-700, 950)}]

static func info(run) -> Dictionary:
	return LEVELS[clampi(run.stage - 1, 0, 2)]

static func enter(run) -> void:
	run.player = info(run).start
	run.stop_movement()
	run.kit.pet_position = run.player + Vector2(-34, 26)
	run.demo_minis_spawned = 0
	run.demo_minis_killed = 0
	run.hazards.clear()
	run.level_start_time = run.time
	run.emit_event("demo_level", run.player)

static func ready_to_clear(run) -> bool:
	if run.stage == 3: return run.boss_defeated
	return run.stage_time >= info(run).seconds and (run.stage == 1 or run.demo_minis_killed >= 2)

static func spawn_special(run, role: String) -> void:
	if run.enemies.size() >= run.MAX_ENEMIES:
		# Never retire another required objective to make room.
		for i in range(run.enemies.size() - 1, -1, -1):
			if not run.enemies[i].has("role"):
				run.enemies.remove_at(i)
				break
	run.spawn_enemy(run._offscreen_point(), 2)
	var enemy: Dictionary = run.enemies.back()
	enemy.role = role
	enemy.hp = {"rammer": 140.0, "artillery": 180.0, "foreman": 900.0}[role]
	enemy.max_hp = enemy.hp
	enemy.radius = 31.0 if role == "foreman" else 24.0
	enemy.phase = "approach"
	enemy.clock = 1.0
	enemy.attack = ""
	enemy.sequence = 0
	enemy.enraged = false
	run.emit_event("demo_boss", enemy.pos, {"role": role})

static func spawns(run, delta: float) -> void:
	run.enemies = run.enemies.filter(func(e: Dictionary) -> bool: return e.kind == 2 or Vector2(e.pos).distance_to(run.player) < maxf(1500, run.view_size.length() + 200))
	if ready_to_clear(run): return
	if run.stage == 2:
		if run.stage_time >= 25 and run.demo_minis_spawned == 0:
			spawn_special(run, "rammer")
			run.demo_minis_spawned = 1
		if run.stage_time >= 60 and run.demo_minis_spawned == 1:
			spawn_special(run, "artillery")
			run.demo_minis_spawned = 2
	if run.stage_time >= info(run).seconds:
		if run.stage == 3 and not run.boss_spawned:
			# Clear the wave before the capstone: boss tells must dominate the screen.
			run.enemies.clear()
			run.projectiles = run.projectiles.filter(func(b: Dictionary) -> bool: return b.kind != "hostile")
			spawn_special(run, "foreman")
			run.boss_spawned = true
		return
	if run.boss_spawned: return
	var surge_times: Array = [24, 51] if run.stage == 1 else [18, 42, 72]
	for i in range(surge_times.size()):
		if run.stage_time >= surge_times[i] - 2 and run.pressure_warning < i + 1:
			run.pressure_warning = i + 1
			run.emit_event("pressure_warning", run.player)
		if run.stage_time >= surge_times[i] and run.pressure_wave < i + 1:
			run.pressure_wave = i + 1
			run._spawn_pack(7 + run.stage * 2, run.stage > 1)
			run.emit_event("pressure", run.player)
	run.spawn_clock -= delta
	while run.spawn_clock <= 0:
		var recovering := false
		for t in surge_times:
			if run.stage_time >= t and run.stage_time < t + 5: recovering = true
		run.spawn_clock += 1.3 if recovering else (0.95 if run.stage == 1 else 0.8)
		var count: int = (1 if recovering else (2 if run.stage == 1 else 2 + run.stage))
		# Make room to read a miniboss without turning off the horde entirely.
		if run.enemies.any(func(e: Dictionary) -> bool: return e.has("role") and not e.dead): count = mini(count, 2)
		run._spawn_pack(count)

static func enemy_step(run, enemy: Dictionary, delta: float) -> void:
	var role: String = enemy.role
	var direction: Vector2 = (run.player - Vector2(enemy.pos)).normalized()
	if role == "foreman" and enemy.hp <= enemy.max_hp * 0.5 and not enemy.enraged:
		enemy.enraged = true
		run.emit_event("boss_phase", enemy.pos)
	enemy.clock -= delta
	if enemy.phase == "approach":
		if Vector2(enemy.pos).distance_to(run.player) > 310:
			enemy.pos += direction * 95 * delta
		elif enemy.clock <= 0:
			var pattern: Array = ["charge"] if role == "rammer" else (["shells"] if role == "artillery" else ["charge", "shells", "fan"])
			enemy.attack = pattern[enemy.sequence % pattern.size()]
			enemy.sequence += 1
			enemy.phase = "telegraph"
			enemy.clock = 0.95 if enemy.enraged else 1.25
			enemy.dir = direction
			run.emit_event("boss_windup", enemy.pos)
			enemy["target"] = (Vector2(enemy.pos) + direction * 420).clamp(run.ARENA.position + Vector2.ONE * 32, run.ARENA.end - Vector2.ONE * 32)
			if enemy.attack == "charge":
				# Clamping a diagonal endpoint can rotate the actual travel segment.
				enemy.dir = (Vector2(enemy.target) - Vector2(enemy.pos)).normalized()
			if enemy.attack == "shells":
				var center: Vector2 = run.player
				var points: Array = [center]
				if role == "foreman": points.append_array([center + Vector2(150, 0), center - Vector2(150, 0)])
				for point in points:
					run.hazards.append({"pos": point, "radius": 82.0, "time": enemy.clock, "duration": enemy.clock, "owner": enemy.id, "spent": false})
	elif enemy.phase == "telegraph" and enemy.clock <= 0:
		if enemy.attack == "charge":
			enemy.phase = "charge"
			enemy.clock = 0.7
			enemy["charge_velocity"] = (Vector2(enemy.target) - Vector2(enemy.pos)) / 0.7
		else:
			if enemy.attack == "fan":
				for angle in [-0.7, -0.35, 0.0, 0.35, 0.7]:
					run._add_projectile(enemy.pos, Vector2(enemy.dir).rotated(angle) * 170, 1, "hostile", 0)
			enemy.phase = "recover"
			enemy.clock = 1.5 if enemy.enraged else 2.0
	elif enemy.phase == "charge":
		var before: Vector2 = enemy.pos
		enemy.pos = (before + Vector2(enemy.charge_velocity) * minf(delta, maxf(0, enemy.clock + delta))).clamp(run.ARENA.position + Vector2.ONE * 32, run.ARENA.end - Vector2.ONE * 32)
		if Geometry2D.get_closest_point_to_segment(run.player, before, enemy.pos).distance_to(run.player) < enemy.radius + 12:
			run.hurt_player(enemy.pos, CombatReadability.enemy_name(enemy) + " charge")
		if enemy.clock <= 0:
			enemy.phase = "recover"
			enemy.clock = 1.5 if enemy.enraged else 2.0
	elif enemy.phase == "recover" and enemy.clock <= 0:
		enemy.phase = "approach"
		enemy.clock = 0.6
	# Recovery rewards committing damage, not hiding an unavoidable contact hit.
	if enemy.phase != "recover" and Vector2(enemy.pos).distance_to(run.player) < enemy.radius + 12:
		run.hurt_player(enemy.pos, CombatReadability.enemy_name(enemy) + " contact")

static func hazards_step(run, delta: float) -> void:
	for hazard in run.hazards:
		if not run.enemies.any(func(e: Dictionary) -> bool: return e.id == hazard.owner and not e.dead):
			hazard.spent = true
			continue
		hazard.time -= delta
		if hazard.time <= 0 and not hazard.spent:
			hazard.spent = true
			run.emit_event("hostile_blast", hazard.pos, {"radius": hazard.radius})
			if Vector2(hazard.pos).distance_to(run.player) <= hazard.radius + 12:
				run.hurt_player(hazard.pos, "Artillery blast")
	run.hazards = run.hazards.filter(func(h: Dictionary) -> bool: return not h.spent)

static func test_direction(run) -> Vector2:
	# Test-driver policy, never used for a human player or boss decisions.
	var center: Vector2 = info(run).start
	var target: Vector2 = center + Vector2(cos(run.time * 0.11) * 260, sin(run.time * 0.11) * 130)
	for enemy in run.enemies:
		if enemy.has("role") and not enemy.dead:
			target = Vector2(enemy.pos) + (run.player - Vector2(enemy.pos)).normalized() * 160
	var desired: Vector2 = (target - run.player).normalized()
	for enemy in run.enemies:
		var offset: Vector2 = run.player - Vector2(enemy.pos)
		if offset.length() < 95: desired += offset.normalized() * (1 - offset.length() / 95) * 3
		if enemy.has("role") and enemy.phase in ["telegraph", "charge"] and enemy.attack in ["charge", "fan"]:
			var perpendicular: Vector2 = Vector2(enemy.dir).orthogonal()
			if offset.dot(perpendicular) < 0: perpendicular = -perpendicular
			desired += perpendicular * 4
	for hazard in run.hazards:
		var offset: Vector2 = run.player - Vector2(hazard.pos)
		if offset.length() < hazard.radius + 45:
			desired += (offset.normalized() if offset.length() > 2 else Vector2.UP) * 5
	return desired.normalized()
