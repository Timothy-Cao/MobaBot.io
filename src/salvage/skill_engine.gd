class_name BotSkillEngine
extends RefCounted
## Bounded runtime for the expanded kit. No owner reference or recursive casts.
var fields: Array[Dictionary] = []
var blades: Array[Dictionary] = []
var summons: Array[Dictionary] = []
var walls: Array[Dictionary] = []
var plates: Array[Vector2] = []
var hits: Dictionary = {}
var recasts: Dictionary = {}
var vault_locks: Dictionary = {}
var serial := 0
var cursor := Vector2.RIGHT * 500
var empowered := false
var hop_ready := false
var combo := 0
var repair_left := 0.0
var repair_origin := Vector2.ZERO
var repair_rate := 0.08
var roll_left := 0.0
var roll_speed := 0.0
var roll_angle := 0.0
var roll_power := 1.0
var roll_size := 1.0
var flywheel := 0.0
var crash_cd := 0.0
var converter_mode := 0
var mounted_clock := 0.0
var capacity := 1
var duration_bonus := 0.0
var summon_power := 1.0
var decoy_left := 0.0
var decoy_position := Vector2.ZERO
var recall_hits: Dictionary = {}
var dash_crosses_walls := false

func clear_combat() -> void:
	fields.clear(); blades.clear(); summons.clear(); walls.clear(); plates.clear(); hits.clear(); recasts.clear()
	repair_left = 0; roll_left = 0; flywheel = 0; hop_ready = false
	decoy_left = 0; recall_hits.clear()

func valid_target(run, point: Vector2, reach: float) -> Dictionary:
	var target: Dictionary = run.nearest_enemy(point)
	if target.is_empty() or Vector2(target.pos).distance_to(point) > float(target.radius) + 45 or Vector2(target.pos).distance_to(run.player) > reach + target.radius: return {}
	return target

func can_cast(run, id: String, point: Vector2, reach: float) -> bool:
	if id in ["consume", "pursuit"]:
		var target := valid_target(run, point, reach)
		if target.is_empty(): return false
		for wall in walls:
			if Geometry2D.segment_intersects_segment(run.player, target.pos, wall.a, wall.b) != null: return false
		if id == "consume": return target.kind != 2 and not target.get("elite", false) and target.hp <= target.max_hp * 0.5
	if id == "vault": return not vault_wall(run, point).is_empty()
	if id == "recall": return not plates.is_empty()
	return true

func recast(run, slot: String, point: Vector2) -> bool:
	if not recasts.has(slot): return false
	var r: Dictionary = recasts[slot]
	match r.id:
		"echo_dash":
			run.emit_event("blink", run.player, {"target": r.pos})
			run.player = r.pos; run.stop_movement(); run.invincible = maxf(run.invincible, 0.15)
		"crosswire":
			line_hit(run, r.pos, point, 16 * run.kit.area_scale(slot), 30 * r.scale, 0.7)
		"artillery":
			field(point, 110 * run.kit.area_scale(slot), 0.55, 65 * r.scale, "slam", "artillery")
			r.left -= 1
			if r.left > 0: return true
		"roller": roll_left = 0
	recasts.erase(slot)
	return true

func cast(run, slot: String, id: String, point: Vector2, direction: Vector2, scale_value: float) -> void:
	repair_left = 0
	var size_scale: float = run.kit.area_scale(slot)
	match id:
		"returner": blade(run.player, point, 22 * scale_value, false, size_scale)
		"gravity": field(point, 115 * size_scale, 3, 12 * scale_value, "gravity", id)
		"strike": field(point, 110 * size_scale, 0.6, 32 * scale_value, "strike", id)
		"crosswire": recasts[slot] = {"id": id, "pos": point, "life": 4.0, "scale": scale_value}
		"echo_dash":
			recasts[slot] = {"id": id, "pos": run.player, "life": 3.0}
			var landing_point := solid_point(run.player, point, 12)
			dash(run, landing_point, 0.2, 0.25)
			field(landing_point, 85 * size_scale, 0.2, 24 * scale_value, "slam", id)
		"hop", "landing":
			var duration := 0.55 if id == "hop" else 0.9
			dash(run, point, duration, duration + 0.1, true)
			field(point, (90 if id == "hop" else 150) * size_scale, duration, (24 if id == "hop" else 120) * scale_value, "slam", id)
		"tumble", "veil_dash", "vault":
			if id == "vault":
				var wall := vault_wall(run, point)
				vault_locks[wall.uid] = 12.0
			if id == "veil_dash": decoy_left = 1; decoy_position = run.player
			dash(run, point, 0.18, 1.0 if id == "veil_dash" else 0.23, id in ["vault","veil_dash"])
			if id == "tumble": empowered = true
		"pursuit", "consume":
			var target := valid_target(run, point, run.kit.cast_range(slot))
			if target.is_empty(): return
			if id == "consume":
				run.hit_enemy(target, target.hp + 1, "crusher")
				run.health = minf(run.max_health(), run.health + run.max_health() * 0.15 * size_scale)
			else:
				dash(run, target.pos, 0.16, 0.2)
				run.hit_enemy(target, 32 * scale_value, "pursuit")
				if target.dead: run.kit.charges[slot] = mini(1, run.kit.charges[slot] + 1)
		"sweep", "tractor", "repulsor":
			var reached := false
			for enemy in run.enemies:
				var offset: Vector2 = enemy.pos - run.player
				if not live(enemy) or offset.length() > run.kit.cast_range(slot) * size_scale + enemy.radius or absf(direction.angle_to(offset)) > PI * 0.34: continue
				reached = true
				var force: Vector2 = offset.normalized() * (-340 if id == "tractor" else 300)
				run.hit_enemy(enemy, {"sweep": 26, "tractor": 18, "repulsor": 20}[id] * scale_value, id, Vector2.ZERO if enemy.has("role") else force)
			if id == "sweep" and reached: run.kit.shield = 2; run.kit.shield_hits = 1
			if id == "repulsor":
				for plate in plates:
					if plate.distance_to(run.player) < 280: blade(plate, plate + direction * 430, 18 * scale_value, true, size_scale)
				plates.clear()
			field(run.player,run.kit.cast_range(slot)*size_scale,0.22,0,"cone",id)
			fields.back()["direction"]=direction
		"reap":
			var edge_hits := 0
			for enemy in run.enemies:
				var distance: float = Vector2(enemy.pos).distance_to(run.player)
				if not live(enemy) or distance > 165 * size_scale + enemy.radius: continue
				var edge := distance >= 100 * size_scale
				run.hit_enemy(enemy, (36 if edge else 16) * scale_value, "reap")
				if edge: edge_hits += 1
			run.health = minf(run.max_health(), run.health + run.max_health() * 0.05 * mini(3, edge_hits))
			run.emit_event("skill_cut", run.player, {"radius":165*size_scale,"inner":100*size_scale,"direction":direction,"style":id})
		"thrust":
			combo = (combo + 1) % 3
			line_hit(run, run.player, run.player + direction * (440 if combo == 0 else 230) * size_scale, 20 * size_scale, 25 * scale_value, 0.6 if combo == 0 else 0.0)
			run.emit_event("skill_cut",run.player,{"target":run.player+direction*(440 if combo==0 else 230)*size_scale,"width":40*size_scale,"style":id,"empowered":combo==0})
		"recall":
			recall_hits.clear()
			for plate in plates:
				blade(plate, run.player, 18 * scale_value, true, size_scale)
				blades.back()["recall"] = true
			plates.clear()
		"repair_channel": repair_left = 3; repair_rate = 0.08 * size_scale; repair_origin = run.player; run.stop_movement()
		"wall":
			serial += 1
			var side := direction.orthogonal() * 95 * size_scale
			if side == Vector2.ZERO: side = Vector2.UP * 95
			walls.append({"uid": serial, "a": point - side, "b": point + side, "life": 5.0 * size_scale, "duration":5.0*size_scale})
			if walls.size() > 4: walls.pop_front()
		"roller":
			roll_left = 4; roll_speed = 205; roll_angle = direction.angle()
			roll_power = scale_value; roll_size = size_scale
			recasts[slot] = {"id": id, "life": 4.0}
		"artillery":
			run.stop_movement()
			recasts[slot] = {"id": id, "life": 6.0, "left": 3, "scale": scale_value}
		_:
			if id.ends_with("sentry") or id == "crawler":
				for unit in summons:
					if unit.id == id and Vector2(unit.pos).distance_to(point) < 45 and id in ["pulse_sentry", "medic_sentry"]:
						var old: Vector2 = run.player
						run.player = unit.pos; run.stop_movement()
						if id == "pulse_sentry": unit.pos = old
						return
				serial += 1
				while summons.size() >= capacity: summons.pop_front()
				var lifetime: float=(18 if id in ["forward_sentry", "pulse_sentry"] else 20)*(1+duration_bonus)*size_scale
				summons.append({"uid": serial, "id": id, "pos": point, "life":lifetime, "duration":lifetime, "flash":0.0, "clock": 0.1, "mirror": 0.0, "scale": scale_value * summon_power, "direction": direction})

func mirror(run, id: String, direction: Vector2, scale_value: float) -> void:
	if id not in ["rocket", "returner", "thrust", "sweep", "flame", "repulsor"]: return
	for unit in summons:
		if unit.id != "mirror_sentry" or unit.mirror > 0: continue
		unit.mirror = 3.0
		unit["flash"] = 0.22
		var damage: float = {"rocket": 23, "returner": 22, "thrust": 25, "sweep": 26, "flame": 26, "repulsor": 20}[id] * 0.45 * scale_value * unit.scale
		if id in ["sweep", "flame"]:
			line_hit(run, unit.pos, unit.pos + direction * 160, 55, damage, 0)
		else: blade(unit.pos, unit.pos + direction * 400, damage, true, 1)

func live(enemy: Dictionary) -> bool:
	return not enemy.dead and enemy.warmup <= 0

func dash(run, point: Vector2, duration: float, protection: float, crosses_walls: bool = false) -> void:
	dash_crosses_walls = crosses_walls
	run.kit.dash_left = duration
	run.kit.dash_velocity = (point - run.player) / duration
	run.kit.dash_damage = 0; run.kit.dash_hits.clear()
	run.stop_movement(); run.invincible = maxf(run.invincible, protection)

func field(point: Vector2, radius: float, seconds: float, damage: float, kind: String, visual: String = "") -> void:
	if fields.size() >= 24: fields.pop_front()
	fields.append({"pos": point, "radius": radius, "life": seconds, "duration": seconds, "damage": damage, "kind": kind, "visual":visual})

func blade(start: Vector2, end: Vector2, damage: float, one_way: bool, size_scale: float) -> void:
	if blades.size() >= 48: return
	blades.append({"pos": start, "end": end, "start": start, "damage": damage, "returning": one_way, "one_way": one_way, "hits": [], "life": 2.5, "width": 12 * size_scale})

func line_hit(run, start: Vector2, end: Vector2, width: float, damage: float, stun: float) -> void:
	for enemy in run.enemies:
		if live(enemy) and Geometry2D.get_closest_point_to_segment(enemy.pos, start, end).distance_to(enemy.pos) <= width + enemy.radius:
			if stun > 0 and not enemy.has("role"): enemy.stun = stun
			if damage > 0: run.hit_enemy(enemy, damage, "skill")
	run.emit_event("beam", start, {"target": end, "width": width * 2})

func commanded_hit(run, enemy: Dictionary) -> void:
	if run.kit.passive_active("threehit"):
		var counter: Dictionary = hits.get(enemy.id, {"count": 0, "life": 6.0})
		counter.count += 1; counter.life = 6.0
		if counter.count >= 3:
			counter.count = 0
			run.hit_enemy(enemy, 12 * SalvageProgression.multiplier(run.rank_of("power")), "proc")
			run.emit_event("lightning", run.player, {"target": enemy.pos})
		hits[enemy.id] = counter
	if run.kit.passive_active("plates"):
		if plates.size() >= int(12*run.kit.passive_scale("plates")): plates.pop_front()
		plates.append(enemy.pos)

func after_basic(run, direction: Vector2) -> void:
	hop_ready = run.kit.passive_active("hopdrive")
	if run.kit.passive_active("sidebolts"):
		var excluded: Array = [run.attacks.target_id]
		for i in range(2):
			var enemy: Dictionary = run.nearest_enemy(run.player, excluded)
			if enemy.is_empty() or Vector2(enemy.pos).distance_to(run.player) > run.attacks.attack_range(run): break
			excluded.append(enemy.id)
			run._add_projectile(run.player, (enemy.pos - run.player).normalized() * 800, run.attacks.damage(run) * 0.45 * run.kit.passive_scale("sidebolts"), "sidebolt", 0)
	if run.exp != null and run.exp.class_id == "ranged": run.kit.boost_speed = maxf(run.kit.boost_speed, 0.55)
	if run.exp != null and run.exp.set_counts.get("courier", 0) >= 4 and run.exp.courier_clock <= 0:
		empowered = true; run.exp.courier_clock = 5

func movement_order(run, point: Vector2) -> bool:
	repair_left = 0
	for slot in recasts.keys():
		if recasts[slot].id == "artillery": recasts.erase(slot)
	if hop_ready and run.kit.dash_left <= 0:
		hop_ready = false
		dash(run, run.player + (point - run.player).limit_length(65*run.kit.passive_scale("hopdrive")), 0.12, 0)
		return true
	return false

func rooted() -> bool:
	for r in recasts.values():
		if r.id == "artillery": return true
	return repair_left > 0

func vault_wall(run, point: Vector2) -> Dictionary:
	for wall in walls:
		if vault_locks.get(wall.uid, 0.0) > 0: continue
		if Geometry2D.get_closest_point_to_segment(run.player, wall.a, wall.b).distance_to(run.player) < 95 and Geometry2D.segment_intersects_segment(run.player, point, wall.a, wall.b) != null: return wall
	return {}

func route(point: Vector2, target: Vector2, radius: float) -> Vector2:
	for wall in walls:
		if Geometry2D.segment_intersects_segment(point, target, wall.a, wall.b) == null: continue
		var along: Vector2 = (wall.b - wall.a).normalized() * (radius + 18)
		var a: Vector2 = wall.a - along
		var b: Vector2 = wall.b + along
		return a if point.distance_to(a) + a.distance_to(target) <= point.distance_to(b) + b.distance_to(target) else b
	return target

func solid_point(before: Vector2, after: Vector2, radius: float) -> Vector2:
	for wall in walls:
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(after, wall.a, wall.b)
		if Geometry2D.segment_intersects_segment(before, after, wall.a, wall.b) != null: return before
		if after.distance_to(closest) < radius + 6:
			var normal := (before - closest).normalized()
			if normal == Vector2.ZERO: normal = (wall.b - wall.a).orthogonal().normalized()
			after = closest + normal * (radius + 7)
	return after

func step(run, delta: float) -> void:
	decoy_left = maxf(0, decoy_left - delta)
	for key in vault_locks.keys():
		vault_locks[key] -= delta
		if vault_locks[key] <= 0: vault_locks.erase(key)
	for key in hits.keys():
		hits[key].life -= delta
		if hits[key].life <= 0: hits.erase(key)
	for slot in recasts.keys():
		recasts[slot].life -= delta
		if recasts[slot].life <= 0: recasts.erase(slot)
	for wall in walls: wall.life -= delta
	walls = walls.filter(func(w: Dictionary) -> bool: return w.life > 0)
	if repair_left > 0:
		if run.player.distance_to(repair_origin) > 3: repair_left = 0
		else:
			run.health = minf(run.max_health(), run.health + run.max_health() * repair_rate * minf(delta, repair_left))
			repair_left = maxf(0, repair_left - delta)
	if roll_left > 0:
		roll_left = maxf(0, roll_left - delta)
		roll_speed = minf(540, roll_speed + delta * 120)
		roll_angle = rotate_toward(roll_angle, (cursor - run.player).angle(), delta * 1.8)
		var next: Vector2 = run.player + Vector2.from_angle(roll_angle) * roll_speed * delta
		var clipped := solid_point(run.player, next, 12)
		if clipped.distance_to(next) > 1:
			roll_left = 0
			MobaKit.area(run, run.player, 135 * roll_size, clampf(roll_speed * 0.19, 35, 100) * roll_power, "roll", 300)
		run.player = clipped
		run.stop_movement()
		for enemy in run.enemies:
			if live(enemy) and Vector2(enemy.pos).distance_to(run.player) < 25 + enemy.radius:
				MobaKit.area(run, run.player, 135 * roll_size, clampf(roll_speed * 0.19, 35, 100) * roll_power, "roll", 300)
				roll_left = 0; run.invincible = maxf(run.invincible, 0.3); break
	if roll_left <= 0:
		for slot in recasts.keys():
			if recasts[slot].id == "roller": recasts.erase(slot)
	crash_cd = maxf(0, crash_cd - delta)
	if run.kit.passive_active("momentum"):
		flywheel = clampf(flywheel + delta * (0.4 if run.velocity.length() > 100 else -0.8), 0, 1)
		if flywheel >= 1 and crash_cd <= 0:
			for enemy in run.enemies:
				if live(enemy) and Vector2(enemy.pos).distance_to(run.player) < 38 + enemy.radius:
					MobaKit.area(run, run.player, 110, 45*run.kit.passive_scale("momentum"), "flywheel", 280); crash_cd = 5; flywheel = 0; break
	else: flywheel = 0
	if run.kit.passive_active("converter"):
		var amount: float = minf(10 * delta, run.kit.energy if converter_mode == 0 else maxf(0, run.kit.energy_max() - run.kit.energy))
		var hp_per_energy: float = run.max_health() * 0.002 * (run.kit.passive_scale("converter") if converter_mode==0 else 1.0/run.kit.passive_scale("converter"))
		if converter_mode == 0:
			amount = minf(amount, (run.max_health() - run.health) / hp_per_energy)
			run.kit.energy -= amount; run.health += amount * hp_per_energy
		else:
			amount = minf(amount, maxf(0, run.health - run.max_health() * 0.3) / hp_per_energy)
			run.kit.energy += amount; run.health -= amount * hp_per_energy
	mounted_clock -= delta
	if run.kit.passive_active("mounted") and mounted_clock <= 0:
		mounted_clock = 0.7
		for offset in [-22, 22]: MobaKit.fire_companion(run, run.player + Vector2(offset, -22), 300, 3*run.kit.passive_scale("mounted"), "mounted")
	for f in fields:
		var dt: float = minf(delta, f.life)
		f.life -= delta
		if f.kind == "gravity":
			for enemy in run.enemies:
				if not live(enemy) or Vector2(enemy.pos).distance_to(f.pos) > f.radius + enemy.radius: continue
				if not enemy.has("role"): enemy.pos = Vector2(enemy.pos).move_toward(f.pos, 100 * dt)
				run.hit_enemy(enemy, f.damage * dt, "gravity")
		elif f.life <= 0 and f.kind != "cone":
			for enemy in run.enemies:
				if live(enemy) and Vector2(enemy.pos).distance_to(f.pos) <= f.radius + enemy.radius:
					var center: bool = f.kind == "strike" and Vector2(enemy.pos).distance_to(f.pos) < f.radius * 0.35
					run.hit_enemy(enemy, f.damage * (2 if center else 1), "strike")
			run.emit_event("nuke_impact", f.pos, {"radius": f.radius, "style":f.get("visual","")})
	fields = fields.filter(func(f: Dictionary) -> bool: return f.life > 0)
	for b in blades:
		b.life -= delta
		var before: Vector2 = b.pos
		var target: Vector2 = run.player if b.returning and not b.one_way else b.end
		b.pos = Vector2(b.pos).move_toward(target, 650 * delta)
		var blocked := false
		for wall in walls:
			if Geometry2D.segment_intersects_segment(before,b.pos,wall.a,wall.b) != null: blocked = true; break
		if blocked: b.life = 0; continue
		for enemy in run.enemies:
			if live(enemy) and enemy.id not in b.hits and Geometry2D.get_closest_point_to_segment(enemy.pos, before, b.pos).distance_to(enemy.pos) <= enemy.radius + b.width:
				b.hits.append(enemy.id); run.hit_enemy(enemy, b.damage, "blade")
				if b.get("recall", false):
					recall_hits[enemy.id] = int(recall_hits.get(enemy.id, 0)) + 1
					if recall_hits[enemy.id] >= 3 and not enemy.has("role"): enemy.stun = 0.7
		if Vector2(b.pos).distance_to(target) < 1:
			if b.returning: b.life = 0
			else: b.returning = true; b.hits.clear()
	blades = blades.filter(func(b: Dictionary) -> bool: return b.life > 0)
	for unit in summons:
		unit.life -= delta; unit.clock -= delta; unit.mirror = maxf(0, unit.mirror - delta)
		unit["flash"] = maxf(0,float(unit.get("flash",0))-delta)
		if unit.id == "crawler":
			var nearest: Dictionary = run.nearest_enemy(unit.pos)
			if not nearest.is_empty(): unit.pos = Vector2(unit.pos).move_toward(nearest.pos, delta * 100)
			var count := 0
			for enemy in run.enemies:
				if live(enemy) and Vector2(enemy.pos).distance_to(unit.pos) < 80: count += 1
			if count >= 4: MobaKit.area(run, unit.pos, 130, 55 * unit.scale, "summon", 200); unit.life = 0
		if unit.clock > 0: continue
		unit.clock = 1.0
		match unit.id:
			"forward_sentry":
				unit["flash"] = 0.16
				unit.clock = 0.65
				unit.direction = (cursor - Vector2(unit.pos)).normalized()
				run._add_projectile(unit.pos, unit.direction * 600, 5 * unit.scale, "summon", 1)
			"pulse_sentry": unit.clock = 1.5; unit["flash"]=0.35; MobaKit.area(run, unit.pos, 125, 12 * unit.scale, "summon", 20)
			"medic_sentry":
				if run.player.distance_to(unit.pos) < 120: run.health = minf(run.max_health(), run.health + run.max_health() * 0.02)
			"hook_sentry":
				unit.clock = 2
				var enemy: Dictionary = run.nearest_enemy(unit.pos)
				if not enemy.is_empty() and Vector2(enemy.pos).distance_to(unit.pos) < 300:
					unit["flash"]=0.22; unit.direction=(enemy.pos-Vector2(unit.pos)).normalized()
					run.emit_event("beam", unit.pos, {"target": enemy.pos, "width": 5})
					run.hit_enemy(enemy, 16 * unit.scale, "summon")
					if not enemy.has("role"): enemy.pos = Vector2(enemy.pos).move_toward(unit.pos, 120)
			"crawler": MobaKit.fire_companion(run, unit.pos, 300, 5 * unit.scale, "summon")
	summons = summons.filter(func(s: Dictionary) -> bool: return s.life > 0)
