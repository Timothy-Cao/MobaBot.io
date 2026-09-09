class_name BotAttackOrders
extends RefCounted
## Basic-attack orders are independent of camera, raw input and skill cooldowns.
var enabled := false
var suppressed := true
var target_id := -1
var order := "guard"
var destination := Vector2.ZERO
var cursor_point := Vector2.ZERO
var cooldown := 0.0
var shots := 0
var auto_cooldown := 0.0
var auto_shots := 0
var windup := -1.0

func revised(run) -> bool:
	return run.exp != null and run.exp.revised

func attack_range(run) -> float:
	if revised(run): return 530.0 + run.kit.attack_range_bonus
	return (105.0 if run.exp != null and run.exp.class_id == "melee" else 310.0) + run.kit.attack_range_bonus

func interval(run) -> float:
	if revised(run): return (1.0/0.7) / SalvageProgression.multiplier(run.rank_of("rapid")) / (1 + run.kit.attack_speed_bonus)
	return 0.43 / SalvageProgression.multiplier(run.rank_of("rapid")) / (1 + run.kit.attack_speed_bonus)

func damage(run) -> float:
	if revised(run): return (14.0625/0.7) * SalvageProgression.multiplier(run.rank_of("power")) * (1 + run.kit.attack_damage_bonus) * (1.75 if run.kit.extra.empowered else 1.0)
	return (7.0 if run.exp != null and run.exp.class_id == "melee" else 2.0) * SalvageProgression.multiplier(run.rank_of("power")) * (1 + run.kit.attack_damage_bonus) * (1.75 if run.kit.extra.empowered else 1.0)

func auto_range(run) -> float:
	return 470.0 if run.kit.gun_sniper else 265.0

func auto_interval(run) -> float:
	return (0.8 if run.kit.gun_sniper else 0.16) / SalvageProgression.multiplier(run.rank_of("rapid")) / (1 + run.kit.attack_speed_bonus)

func auto_damage(run) -> float:
	return (7.0 if run.kit.gun_sniper else 1.5) * (0.8 if revised(run) else 1.0) * SalvageProgression.multiplier(run.rank_of("power")) * (1 + run.kit.attack_damage_bonus)

func valid(enemy: Dictionary) -> bool:
	return not enemy.is_empty() and not enemy.dead and enemy.warmup <= 0 and enemy.hp > 0

func target(run) -> Dictionary:
	for enemy in run.enemies:
		if enemy.id == target_id and valid(enemy): return enemy
	return {}

func line_of_fire(run, point: Vector2) -> bool:
	if not revised(run): return true
	for wall in run.kit.extra.walls:
		if Geometry2D.segment_intersects_segment(run.player,point,wall.a,wall.b)!=null: return false
	return true

func closest(run, point: Vector2, in_range: bool = false, under_cursor: bool = false) -> Dictionary:
	var best: Dictionary = {}
	var distance := INF
	for enemy in run.enemies:
		if not valid(enemy): continue
		if in_range and run.player.distance_to(enemy.pos) > attack_range(run) + enemy.radius: continue
		var d := point.distance_squared_to(enemy.pos)
		if under_cursor and d > pow(float(enemy.radius) + 7.0, 2): continue
		if d < distance or (is_equal_approx(d, distance) and (best.is_empty() or enemy.id < best.id)):
			best = enemy
			distance = d
	return best

func move(point: Vector2) -> void:
	windup = -1
	suppressed = true
	target_id = -1
	order = "move"
	destination = point

func stop(run) -> void:
	windup = -1
	suppressed = true
	target_id = -1
	order = "stop"
	run.stop_movement()

func attack(run, enemy: Dictionary) -> bool:
	if not enabled or not valid(enemy) or run.state != "running": return false
	suppressed = false
	order = "target"
	target_id = enemy.id
	return true

func attack_move(run, point: Vector2) -> void:
	if not enabled or run.state != "running": return
	suppressed = false
	order = "attack_move"
	target_id = -1
	destination = point.clamp(run.ARENA.position + Vector2.ONE * 16, run.ARENA.end - Vector2.ONE * 16)
	cursor_point = point

func prepare(run, delta: float) -> void:
	if not enabled: return
	cooldown = maxf(-delta, cooldown - delta)
	auto_cooldown = maxf(-delta, auto_cooldown - delta)
	if windup >= 0: windup = maxf(0, windup-delta)
	if run.kit.laser_left > 0 or run.kit.dash_left > 0:
		windup=-1; return
	if order == "target":
		var enemy := target(run)
		if enemy.is_empty():
			order = "guard"
			target_id = -1
			run.stop_movement()
			return
		var offset: Vector2 = enemy.pos - run.player
		# Small margin prevents boundary jitter while keeping range truthful.
		var reach := attack_range(run) + float(enemy.radius)
		if not line_of_fire(run,enemy.pos):
			run.move_target=enemy.pos; run.moving=true; windup=-1
		elif offset.length() > reach:
			run.move_target = Vector2(enemy.pos) - offset.normalized() * (reach - 5)
			run.moving = true
		else: run.stop_movement()
	elif order == "attack_move":
		var enemy := target(run)
		if enemy.is_empty() or run.player.distance_to(enemy.pos) > attack_range(run) + enemy.radius:
			enemy = closest(run, cursor_point, true)
			target_id = -1 if enemy.is_empty() else int(enemy.id)
		if enemy.is_empty():
			run.move_target = destination
			run.moving = run.player.distance_to(destination) > 0.01
		elif not line_of_fire(run,enemy.pos): run.move_target=enemy.pos; run.moving=true; windup=-1
		else: run.stop_movement()

func fire(run) -> void:
	if not enabled: return
	_fire_auto(run)
	if suppressed or cooldown > 0: return
	if run.kit.laser_left > 0 or run.kit.dash_left > 0: return
	var enemy := target(run)
	if enemy.is_empty(): enemy = closest(run, cursor_point if order == "attack_move" else run.player, true)
	if enemy.is_empty() or run.player.distance_to(enemy.pos) > attack_range(run) + enemy.radius or not line_of_fire(run,enemy.pos):
		windup = -1; return
	if revised(run):
		if windup < 0:
			windup = 0.2
			run.aim = (Vector2(enemy.pos)-run.player).normalized()
			run.emit_event("basic_windup",run.player)
			return
		if windup > 0: return
		windup = -1
	if run.projectiles.size() >= run.MAX_PROJECTILES: return
	var direction: Vector2 = (Vector2(enemy.pos) - run.player).normalized()
	if direction == Vector2.ZERO: direction = Vector2.RIGHT
	run.aim = direction
	run._add_projectile(run.player + direction * 20, direction * 850, damage(run), "basic", run.bolt_pierces())
	run.projectiles.back().life = (attack_range(run) - 20.0) / 850.0
	run.projectiles.back().basic_attack = true
	cooldown = interval(run) - (0.2 if revised(run) else 0.0)
	shots += 1
	run.kit.extra.empowered = false
	run.kit.extra.after_basic(run, direction)
	run.emit_event("heavy_shot" if revised(run) else "shot", run.player)

func _fire_auto(run) -> void:
	# Powered autonomous weapon ignores movement, attack orders, S and channels.
	if auto_cooldown > 0 or not run.passive_enabled("bolt") or run.projectiles.size() >= run.MAX_PROJECTILES: return
	var enemy := closest(run, run.player)
	if enemy.is_empty() or run.player.distance_to(enemy.pos) > auto_range(run) + enemy.radius: return
	var direction: Vector2 = (Vector2(enemy.pos) - run.player).normalized()
	if direction == Vector2.ZERO: direction = Vector2.RIGHT
	if run.kit.laser_left <= 0 and windup < 0: run.aim = direction
	if not run.kit.gun_sniper: direction = direction.rotated(deg_to_rad([-2.5, 0.0, 2.5, -1.0, 1.0][auto_shots % 5]))
	var speed := 900.0 if run.kit.gun_sniper else 700.0
	run._add_projectile(run.player + direction * 20, direction * speed, auto_damage(run), "bolt", run.bolt_pierces())
	run.projectiles.back().life = (auto_range(run) - 20.0) / speed
	run.projectiles.back().basic_attack = true
	run.projectiles.back().autonomous = true
	run.projectiles.back().sniper = run.kit.gun_sniper
	auto_cooldown += auto_interval(run)
	auto_shots += 1
	run.emit_event("auto_shot" if revised(run) else "shot", run.player)
