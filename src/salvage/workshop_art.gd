extends Node2D
## Code-authored world art follows docs/design/ART_STYLE_SCHEMA.md.

const INK := Color("14242c")
const CREAM := Color("fff0c7")
const TEAL := Color("399c99")
const GOLD := Color("efc16b")
const CORAL := Color("ee796c")
const FLOOR := Color("314d56")
const PALE := Color("bdd3ce")

var model: SalvageRun
var visual_time := 0.0
var effects: Array[Dictionary] = []
var reduced_effects := false
var shake := 0.0
var shot_recoil := 0.0
var styles: Dictionary = {}
var frame_offset := Vector2.ZERO
var world_mode := false
var stencil_font := SystemFont.new()
var preview_slot := ""
var preview_attack := false
var cursor_world := Vector2.ZERO
var cast_pose := 0.0
var placement_points: Array[Vector2] = []
var placement_valid := false
var placement_radius := 25.0

func impact_bank() -> float:
	return 0.0 if reduced_effects else sin(visual_time * 38) * minf(shake, 5.0) * 0.008

func _process(delta: float) -> void:
	visual_time += delta
	shot_recoil = maxf(0, shot_recoil - delta * 6)
	cast_pose = maxf(0, cast_pose-delta*3.5)
	shake = maxf(0, shake - delta * 20)
	for effect in effects:
		effect.age += delta
	effects = effects.filter(func(e: Dictionary) -> bool: return e.age < e.life)
	queue_redraw()

func receive(event: Dictionary) -> void:
	var kind: String = event.kind
	if kind in ["shot","heavy_shot"]:
		shot_recoil = 1.0
		return
	if kind == "auto_shot": return
	if kind == "cast": cast_pose = 1.0
	if kind == "hurt" and not reduced_effects:
		shake = 5.0
	# Automatic collection/ultimate pulses must not continuously shake the actors.
	if kind in ["kill", "hit", "spent", "pulse", "pickup", "equipped", "boss_down", "loot", "blink", "beam", "move", "cast", "skill_cut", "milestone", "vacuum", "hostile_blast", "nuke_impact", "rocket_impact", "lightning", "boss_summon"]:
		# Displace a cosmetic hit/pickup first so important cast feedback survives a crowd.
		if effects.size()>=(65 if reduced_effects else 180) and kind in ["cast","skill_cut","nuke_impact","rocket_impact","hostile_blast","boss_summon"]:
			for i in range(effects.size()):
				if effects[i].kind in ["pickup","hit","spent","kill"]:
					effects.remove_at(i); break
		if effects.size() < (65 if reduced_effects else 180):
			var e := event.duplicate()
			e.age = 0.0
			e.life = 0.55 if kind in ["kill", "pulse", "boss_down", "loot", "move"] else 0.24
			if kind in ["nuke_impact", "rocket_impact", "boss_summon"]: e.life = 0.6
			if kind=="skill_cut": e.life=0.30
			effects.append(e)

func _box(rect: Rect2, color: Color, radius: int = 5, border: Color = INK, width: int = 2) -> void:
	var key := "%s_%s_%d_%d" % [color.to_html(), border.to_html(), radius, width]
	if not styles.has(key):
		var style := StyleBoxFlat.new()
		style.bg_color = color
		style.border_color = border
		style.set_border_width_all(width)
		style.set_corner_radius_all(radius)
		styles[key] = style
	draw_style_box(styles[key], rect)

func _line(a: Vector2, b: Vector2, color: Color, width: float = 2) -> void:
	draw_line(a, b, color, width, true)

func _draw() -> void:
	_floor()
	if model == null:
		return
	if not world_mode and model.kit == null:
		var center := model.player
		draw_arc(center, 150, 0, TAU, 80, Color(PALE, 0.15), 1, true)
		for i in range(3):
			var angle := visual_time * 0.16 + i * TAU / 3
			_tool(center + Vector2.from_angle(angle) * 139, angle, true, 1.9)
		_player(3.2)
		return
	if world_mode:
		_draw_caches()
		_moba_ground()
		ExpeditionArt.draw(self, model)
		if Vanguard.enabled(model): VanguardArt.draw(self,model)
		for point in placement_points:
			draw_circle(point,placement_radius,Color(TEAL if placement_valid else CORAL,0.18))
			draw_arc(point,placement_radius,0,TAU,32,TEAL if placement_valid else CORAL,2,true)
		for patch in model.kit.poison_trail:
			var opacity := minf(1.0, patch.life) * 0.28
			draw_circle(patch.pos, 26, Color("77b9a5") * Color(1, 1, 1, opacity))
			draw_arc(patch.pos, 26, 0, TAU, 24, Color(PALE, opacity), 1, true)
			if not reduced_effects:
				draw_circle(Vector2(patch.pos) + Vector2(-6, -5), 3, Color(PALE, opacity))
		if model.attacks.enabled:
			if preview_attack:
				draw_arc(model.player, model.attacks.attack_range(model), 0, TAU, 96, Color(PALE, 0.65), 1.5, true)
			var selected := model.attacks.target(model)
			if not selected.is_empty():
				draw_arc(selected.pos, float(selected.radius) + 5, 0, TAU, 40, GOLD, 2, true)
	# Keep actors, hitboxes, ground tells and cursor geometry in the same space.
	# Hull impact is a small player-only angular recoil, never a world displacement.
	frame_offset = Vector2.ZERO
	# Telegraphs are drawn clearly below actors, never hidden beneath player effects.
	for enemy in model.enemies:
		if enemy.dead:
			continue
		if enemy.warmup > 0:
			draw_arc(enemy.pos, float(enemy.radius) + 10, 0, TAU, 32, Color(CORAL, 0.55), 2, true)
		if enemy.phase == "windup":
			_charge_tell(enemy.pos, Vector2(enemy.pos) + Vector2(enemy.dir) * (255 * 0.65), enemy.radius + 12)
	for pickup in model.pickups:
		_scrap(pickup)
	for supply in model.supply_drops:
		var p: Vector2 = supply.pos
		var color: Color = {"energy": TEAL, "repair": Color("ed9285"), "coins": GOLD, "speed": Color("b7ddee"), "reset": Color("bfa6dd")}.get(supply.kind, TEAL)
		draw_circle(p, 11, INK)
		draw_circle(p, 8, color)
		_line(p - Vector2(4, 0), p + Vector2(4, 0), CREAM, 2)
		if supply.kind == "repair": _line(p - Vector2(0, 4), p + Vector2(0, 4), CREAM, 2)
		if supply.kind == "coins": draw_arc(p, 7, 0, TAU, 20, GOLD, 2, true)
		if supply.kind == "speed":
			_line(p + Vector2(-3, -5), p + Vector2(3, 0), CREAM, 2)
			_line(p + Vector2(3, 0), p + Vector2(-3, 5), CREAM, 2)
		if supply.kind == "reset": draw_arc(p, 6, 0.5, TAU - 0.5, 20, CREAM, 2, true)
		else:
			_line(p + Vector2(2, -5), p + Vector2(-2, 0), CREAM, 2)
			_line(p + Vector2(2, 0), p + Vector2(-2, 5), CREAM, 2)
	for enemy in model.enemies:
		if not enemy.dead:
			_enemy(enemy)
	for bullet in model.projectiles:
		var direction: Vector2 = Vector2(bullet.vel).normalized()
		if bullet.kind == "hostile":
			draw_circle(bullet.pos, 8, INK)
			draw_circle(bullet.pos, 6, CORAL)
			draw_circle(bullet.pos, 2, CREAM)
		elif bullet.kind == "rocket":
			var m: int = bullet.get("milestone", 0)
			_line(bullet.pos - direction * (65 + m * 18), bullet.pos, Color(TEAL, 0.3), 18 + m * 4)
			_line(bullet.pos - direction * 45, bullet.pos, GOLD, 7 + m * 2)
			draw_set_transform(bullet.pos, direction.angle(), Vector2.ONE * (1 + m * 0.18))
			var hull := PackedVector2Array([Vector2(15, 0), Vector2(3, -7), Vector2(-15, -7), Vector2(-20, -13), Vector2(-19, 13), Vector2(-15, 7), Vector2(3, 7)])
			draw_colored_polygon(hull, PALE)
			hull.append(hull[0])
			draw_polyline(hull, INK, 2, true)
			_line(Vector2(-13, -3), Vector2(4, -3), CREAM, 3)
			_line(Vector2(-11, 3), Vector2(0, 3), TEAL, 4)
			draw_set_transform(Vector2.ZERO)
		elif bullet.get("basic_attack", false):
			if bullet.kind=="basic" and model.exp!=null and model.exp.revised:
				_line(bullet.pos-direction*35,bullet.pos,Color(GOLD,0.35),8)
				_line(bullet.pos-direction*17,bullet.pos,GOLD,6)
				_line(bullet.pos-direction*11,bullet.pos,CREAM,2)
			else: _line(bullet.pos - direction * (30 if bullet.get("sniper", false) else 7), bullet.pos, PALE, 2)
		else:
			var color := PALE if bullet.kind in ["rail", "pet", "summon"] else GOLD
			if model.staged and ((bullet.kind == "rail" and model.kit.milestone("q") > 0) or (bullet.kind == "bolt" and model.milestone("power") > 0)):
				color = GOLD
			_line(bullet.pos - direction * (35 if bullet.kind == "rail" else 15), bullet.pos, Color(color, 0.35), 6)
			_line(bullet.pos - direction * (21 if bullet.kind == "rail" else 6), bullet.pos, CREAM if bullet.kind == "bolt" else color, 4)
	if model.mode == "salvage" and model.passive_enabled("orbit"):
		draw_arc(model.player, model.orbit_radius(), 0, TAU, 64, Color(PALE, 0.12), 1, true)
		for i in range(model.orbit.size()):
			_tool(model.orbit_position(i) + frame_offset, model.time * 6 + i, model.rank_of("grinder") > 0, 1.0 + model.milestone("grinder") * 0.2)
	for effect in effects:
		_effect(effect)
	_player()
	if world_mode:
		_companions()
		if model.kit.flexible(): _local_resources()
	# Danger projectiles receive a final outline pass for visibility in crowded FX.
	for bullet in model.projectiles:
		if bullet.kind == "hostile":
			draw_arc(bullet.pos, 8, 0, TAU, 16, CREAM, 1.3, true)
	if model.demo_mode: _demo_tells()
	if model.exp!=null and model.exp.practice: model.practice_meter.draw(self,model)
	for enemy in model.enemies:
		if not enemy.dead and enemy.has("gunner_kind"): RangedThreats.tell(self,enemy)
	# A steady directional arc remains legible even with shake/flashes disabled.
	if model.time - model.last_damage_time < 0.7 and model.last_damage_direction.length_squared() > 0.1:
		var angle := model.last_damage_direction.angle()
		draw_arc(model.player, 37, angle - 0.55, angle + 0.55, 18, INK, 6, true)
		draw_arc(model.player, 37, angle - 0.55, angle + 0.55, 18, CORAL, 3, true)

func _demo_tells() -> void:
	for hazard in model.hazards:
		draw_circle(hazard.pos, hazard.radius, Color(CORAL, 0.1))
		draw_arc(hazard.pos, hazard.radius, 0, TAU, 64, CORAL, 2.5, true)
		draw_arc(hazard.pos, hazard.radius * clampf(1 - hazard.time / hazard.duration, 0, 1), 0, TAU, 48, CREAM, 1.5, true)
	for enemy in model.enemies:
		if enemy.dead or not enemy.has("role"): continue
		var p: Vector2 = enemy.pos
		var title: String = CombatReadability.enemy_name(enemy).to_upper()
		if enemy.phase == "recover":
			draw_arc(p, enemy.radius + 9, 0, TAU, 40, GOLD, 3, true)
			title += " / EXPOSED"
		elif enemy.phase == "telegraph":
			if enemy.attack == "charge":
				_charge_tell(p, enemy.target, enemy.radius + 12)
			elif enemy.attack == "fan":
				for angle in [-0.9, -0.6, -0.3, 0.0, 0.3, 0.6, 0.9]:
					_line(p + Vector2(enemy.dir).rotated(angle) * enemy.radius, p + Vector2(enemy.dir).rotated(angle) * 170, Color(CORAL, 0.55), 1.5)
			elif enemy.attack == "ring":
				var angle: float = Vector2(enemy.dir).angle()
				draw_arc(p, enemy.radius + 30, angle + TAU / 16 * 1.5, angle + TAU - TAU / 32, 64, CORAL, 3, true)
		draw_string(stencil_font, p + Vector2(-70, -enemy.radius - 24), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, GOLD if enemy.phase == "recover" else CREAM)

func _charge_tell(start: Vector2, end: Vector2, radius: float) -> void:
	var direction := (end - start).normalized()
	if direction == Vector2.ZERO:
		draw_arc(start, radius, 0, TAU, 32, CORAL, 2.5, true)
		return
	var normal := direction.orthogonal() * radius
	_line(start + normal, end + normal, CORAL, 2.5)
	_line(start - normal, end - normal, CORAL, 2.5)
	_line(start, end, Color(CORAL, 0.13), radius * 2)
	var angle := direction.angle()
	draw_arc(start, radius, angle + PI / 2, angle + PI * 1.5, 24, CORAL, 2.5, true)
	draw_arc(end, radius, angle - PI / 2, angle + PI / 2, 24, CREAM, 2.5, true)

func _floor() -> void:
	if world_mode and model != null:
		_world_floor()
		return
	draw_rect(Rect2(0, 0, 960, 540), INK)
	_box(Rect2(22, 84, 916, 428), Color("263f48"), 12, Color("122d35"), 3)
	_box(Rect2(34, 96, 892, 406), FLOOR, 8, Color("44636b"), 2)
	for x in range(180, 924, 150):
		_line(Vector2(x, 102), Vector2(x, 494), Color("2c4751"), 2)
	for y in range(180, 492, 104):
		_line(Vector2(42, y), Vector2(918, y), Color("2c4751"), 2)
	# Restrained workshop fixtures sit on the perimeter, not in the fight.
	for x in [50, 910]:
		for y in [110, 488]:
			draw_circle(Vector2(x, y), 4, Color("718883"))
			_line(Vector2(x - 2, y), Vector2(x + 2, y), INK, 1)
	for y in [148, 416]:
		_box(Rect2(15, y, 13, 64), Color("9d8860"), 2, INK, 2)
		_box(Rect2(932, y, 13, 64), Color("9d8860"), 2, INK, 2)
		for stripe in range(4):
			_line(Vector2(16, y + stripe * 15 + 7), Vector2(27, y + stripe * 15 + 15), INK, 4)
			_line(Vector2(933, y + stripe * 15 + 7), Vector2(944, y + stripe * 15 + 15), INK, 4)
	# Dashed maintenance markings imply a place without a noisy background texture.
	for x in range(352, 610, 25):
		_line(Vector2(x, 116), Vector2(x + 10, 116), Color("607b7c"), 2)
		_line(Vector2(x, 482), Vector2(x + 10, 482), Color("607b7c"), 2)

func _world_floor() -> void:
	var origin := model.camera_origin()
	var view := Rect2(origin - Vector2(100, 100), model.view_size + Vector2(200, 200))
	var sector: int=clampi(model.stage-1,0,2)
	var bases: Array=[Color("293e46"),Color("403c3c"),Color("353b49")]
	draw_rect(view, bases[sector])
	for x in range(int(floor(view.position.x / 640)), int(ceil(view.end.x / 640))):
		for y in range(int(floor(view.position.y / 480)), int(ceil(view.end.y / 480))):
			var p := Vector2(x * 640, y * 480)
			var color: Color=bases[sector].lightened(0.055 if posmod(x+y,2)==0 else 0.025)
			draw_rect(Rect2(p + Vector2(4, 4), Vector2(632, 472)), color)
			# Flush service panels, painted bay markings and floor conduits stay walkable.
			_box(Rect2(p + Vector2(60, 82), Vector2(92, 46)), Color("243a42"), 3, Color("3b545b"), 1)
			for vent in range(7):
				_line(p + Vector2(72 + vent * 11, 91), p + Vector2(72 + vent * 11, 119), Color("415960"), 3)
			_line(p + Vector2(8, 455), p + Vector2(632, 455), Color("796c49"), 2)
			_line(p + Vector2(8, 461), p + Vector2(632, 461), Color("796c49"), 1)
			for stripe in range(6):
				_line(p + Vector2(400 + stripe * 28, 35), p + Vector2(414 + stripe * 28, 35), Color("657266"), 3)
			draw_string(stencil_font, p + Vector2(425, 128), "%02d" % (posmod(x * 3 + y, 12) + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 70, Color("3a545d"))
	for x in range(int(floor(view.position.x / 160)), int(ceil(view.end.x / 160))):
		_line(Vector2(x * 160, view.position.y), Vector2(x * 160, view.end.y), Color("253b44"), 1)
	for y in range(int(floor(view.position.y / 120)), int(ceil(view.end.y / 120))):
		_line(Vector2(view.position.x, y * 120), Vector2(view.end.x, y * 120), Color("253b44"), 1)
	var arena := SalvageRun.ARENA
	# Mask decorative tiles beyond the walkable floor when the edge camera overscans.
	if view.position.x < arena.position.x: draw_rect(Rect2(view.position, Vector2(arena.position.x - view.position.x, view.size.y)), INK)
	if view.end.x > arena.end.x: draw_rect(Rect2(Vector2(arena.end.x, view.position.y), Vector2(view.end.x - arena.end.x, view.size.y)), INK)
	if view.position.y < arena.position.y: draw_rect(Rect2(view.position, Vector2(view.size.x, arena.position.y - view.position.y)), INK)
	if view.end.y > arena.end.y: draw_rect(Rect2(Vector2(view.position.x, arena.end.y), Vector2(view.size.x, view.end.y - arena.end.y)), INK)
	draw_rect(SalvageRun.ARENA.grow(8), Color("a39261"), false, 10)
	draw_rect(SalvageRun.ARENA.grow(22), INK, false, 18)
	if model.demo_mode:
		var center: Vector2 = DemoCampaign.info(model).start
		var paint := Color("657266")
		draw_string(stencil_font, center + Vector2(-240, -160), DemoCampaign.info(model).name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 38, Color(paint, 0.5))
		if model.stage == 2:
			for i in range(3):
				_line(center + Vector2(-380, -85 + i * 100), center + Vector2(380, -85 + i * 100), Color(paint, 0.35), 5)
		elif model.stage == 3:
			draw_arc(center, 225, 0, TAU, 96, Color(paint, 0.4), 6, true)
			draw_arc(center, 240, 0, TAU, 96, Color(paint, 0.25), 2, true)

func _draw_caches() -> void:
	var view := Rect2(model.camera_origin() - Vector2.ONE * 60, model.view_size + Vector2.ONE * 120)
	for cache in model.caches:
		var p: Vector2 = cache.pos
		if not view.has_point(p):
			continue
		if not cache.opened:
			draw_arc(p, 35 + sin(visual_time * 3) * 2, 0, TAU, 48, Color(GOLD, 0.28), 2, true)
			draw_set_transform(p)
			_box(Rect2(-23, -15, 46, 32), Color("b99551") if not cache.opened else Color("46595a"), 5, INK, 3)
			_box(Rect2(-18, -20 if not cache.opened else -29, 36, 12), GOLD if not cache.opened else Color("708278"), 4, INK, 2)
			_line(Vector2(-13, -12), Vector2(-13, 13), INK, 3)
			_line(Vector2(13, -12), Vector2(13, 13), INK, 3)
			_box(Rect2(-4, -5, 8, 11), CREAM if not cache.opened else INK, 2, INK, 1)
			draw_set_transform(Vector2.ZERO)

func _scrap(pickup: Dictionary) -> void:
	var p: Vector2 = pickup.pos
	if pickup.pull and not reduced_effects:
		var tail := (p - model.player).normalized()
		_line(p, p + tail * minf(18, pickup.speed * 0.025), Color(GOLD, 0.32), 3)
	var bob := sin(visual_time * 4 + float(pickup.id)) * 1.5
	draw_circle(p + Vector2(0, 4), 5, Color(INK, 0.6))
	draw_set_transform(p + Vector2(0, bob), 0.3)
	_box(Rect2(-4, -5, 8, 10), GOLD, 2, INK, 1)
	_line(Vector2(-2, -2), Vector2(2, -2), CREAM, 1)
	if pickup.value > 1:
		draw_circle(Vector2(3, -4), 2, CREAM)
	draw_set_transform(Vector2.ZERO)

func _enemy(enemy: Dictionary) -> void:
	if enemy.has("gunner_kind"):
		RangedThreats.draw(self,enemy); return
	var p: Vector2 = enemy.pos + frame_offset
	if enemy.get("elite", false):
		draw_arc(p, enemy.radius + 5, 0, TAU, 24, GOLD, 2, true)
		if enemy.get("runner", false):
			var tail: Vector2 = (p - model.player).normalized()
			_line(p + tail * 14, p + tail * 29, CORAL, 3)
	var kind: int = enemy.kind
	var r: float = enemy.radius
	var body := CORAL if kind == 0 else Color("b2809c")
	if enemy.flash > 0 and not reduced_effects:
		body = CREAM
	if enemy.warmup > 0:
		body.a = 0.4
	draw_set_transform(p + Vector2(0, r * 0.6), 0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, r + 3, Color(INK, 0.7))
	draw_set_transform(p + Vector2(0, sin(visual_time * 6 + enemy.id) * 1.4))
	if kind == 0:
		_box(Rect2(-18, -4, 36, 13), INK, 5)
		draw_circle(Vector2.ZERO, 15, INK)
		draw_circle(Vector2(0, -1), 12, body)
		draw_arc(Vector2(0, -1), 9, PI * 1.1, PI * 1.8, 12, Color("ffb49a"), 2, true)
		_box(Rect2(-8, -2, 16, 7), INK, 3, INK, 0)
		draw_circle(Vector2(-4, 1), 2, CREAM)
		draw_circle(Vector2(4, 1), 2, CREAM)
		_line(Vector2(-5, 9), Vector2(5, 9), INK, 2)
	elif kind == 1:
		var rotation_angle: float = Vector2(enemy.dir).angle() + PI / 2 if enemy.phase != "seek" else (model.player - Vector2(enemy.pos)).angle() + PI / 2
		draw_set_transform(p, rotation_angle)
		var points := PackedVector2Array([Vector2(0, -21), Vector2(18, 11), Vector2(11, 18), Vector2(-11, 18), Vector2(-18, 11)])
		draw_colored_polygon(points, body)
		points.append(points[0])
		draw_polyline(points, INK, 3, true)
		_line(Vector2(-6, 3), Vector2(6, 3), CREAM, 3)
		_box(Rect2(-8, 9, 16, 6), INK, 2)
	elif kind == 3:
		_box(Rect2(-27, -11, 54, 27), INK, 6)
		_box(Rect2(-22, -23, 44, 44), Color("9a7882") if enemy.flash <= 0 or reduced_effects else CREAM, 6, INK, 3)
		_box(Rect2(-17, -18, 34, 11), PALE, 3)
		_box(Rect2(-14, -1, 28, 12), INK, 3)
		_line(Vector2(-8, 4), Vector2(8, 4), CORAL, 3)
		for x in [-18, 18]:
			draw_circle(Vector2(x, 15), 3, GOLD)
		_box(Rect2(-23, -32, 46, 4), INK, 2)
		_box(Rect2(-22, -31, 44 * maxf(0, enemy.hp / enemy.max_hp), 2), CORAL, 1, CORAL, 0)
	else:
		_tool(p, visual_time * (0.9 if enemy.get("enraged", false) else 0.4), true, enemy.radius / 11.0, Color("c99864"))
		# Different power sources read in silhouette, using the same workshop materials.
		var facing: Vector2 = Vector2(enemy.get("dir", Vector2.RIGHT)) if enemy.phase in ["telegraph", "charge"] else (model.player - Vector2(enemy.pos)).normalized()
		draw_set_transform(p)
		if enemy.get("role", "") == "rammer":
			draw_set_transform(p, facing.angle())
			var plow := PackedVector2Array([Vector2(-23, -18), Vector2(9, -23), Vector2(31, 0), Vector2(9, 23), Vector2(-23, 18)])
			draw_colored_polygon(plow, CREAM if enemy.flash > 0 and not reduced_effects else Color("c99864"))
			plow.append(plow[0])
			draw_polyline(plow, INK, 3, true)
			_box(Rect2(-16, -10, 21, 20), INK, 4)
			_line(Vector2(-7, -5), Vector2(-7, 5), CORAL, 3)
			_line(Vector2(11, -13), Vector2(23, 0), CREAM, 3)
			_line(Vector2(23, 0), Vector2(11, 13), CREAM, 3)
		elif enemy.get("role", "") == "artillery":
			_box(Rect2(-23, -14, 46, 37), body, 10, INK, 3)
			for x in [-16, 16]:
				_box(Rect2(x - 8, -37, 16, 32), Color("c99864"), 5, INK, 3)
				draw_circle(Vector2(x, -29), 5, INK)
				draw_circle(Vector2(x, -29), 2, CORAL)
			_box(Rect2(-13, 0, 26, 12), INK, 4)
			_line(Vector2(-6, 5), Vector2(6, 5), CORAL, 3)
		else:
			# Foreman: paired piston arms, rotating outer cutter and exposed reactor.
			for side in [-1, 1]:
				_box(Rect2(side * 42 - 9, -24, 18, 49), PALE, 3, INK, 3)
				_box(Rect2(side * 42 - 12, -4, 24, 25), Color("927075"), 3, INK, 3)
			_box(Rect2(-35, -36, 70, 72), body, 6, INK, 4)
			_box(Rect2(-29, -31, 58, 12), PALE, 2)
			_box(Rect2(-23, -13, 46, 27), INK, 3)
			draw_circle(Vector2(0, 26), 12, INK)
			draw_circle(Vector2(0, 26), 8, GOLD if enemy.phase == "recover" else CORAL)
			if not reduced_effects:
				draw_arc(Vector2(0, 26), 14 + sin(visual_time * 8) * 2, 0, TAU, 24, Color(CORAL, 0.5), 2, true)
			for eye_x in [-9, 9]:
				_box(Rect2(eye_x - 3, -4, 6, 6), CORAL, 1, CORAL, 0)
		draw_set_transform(p)
		_box(Rect2(-24, -r - 10, 48, 5), INK, 2)
		_box(Rect2(-23, -r - 9, 46 * maxf(0, float(enemy.hp) / float(enemy.max_hp)), 3), CORAL, 1, CORAL, 0)
	draw_set_transform(Vector2.ZERO)

func _tool(point: Vector2, rotation_angle: float, saw: bool, scale_value: float = 1.0, color: Color = PALE) -> void:
	draw_set_transform(point, rotation_angle, Vector2.ONE * scale_value)
	if saw:
		var points := PackedVector2Array()
		for i in range(24):
			points.append(Vector2.from_angle(float(i) * TAU / 24) * (11 if i % 3 == 0 else 8))
		draw_colored_polygon(points, color)
		points.append(points[0])
		draw_polyline(points, INK, 1.5, true)
	else:
		_box(Rect2(-7, -8, 14, 16), color, 3, INK, 2)
		_line(Vector2(-5, -4), Vector2(5, -4), CREAM, 2)
	draw_circle(Vector2.ZERO, 4.5, TEAL)
	draw_circle(Vector2.ZERO, 2.5, INK)
	draw_circle(Vector2(-0.5, -0.5), 1.5, GOLD)
	draw_set_transform(Vector2.ZERO)

func _player(presentation_scale: float = 1.0) -> void:
	var p := model.player + frame_offset
	var bank := clampf(model.velocity.x / 205.0, -1, 1) * 0.10 + impact_bank()
	var bob := sin(visual_time * 5) * 2
	draw_set_transform(p + Vector2(0, 16) * presentation_scale, 0, Vector2(1.0, 0.35) * presentation_scale)
	draw_circle(Vector2.ZERO, 23, Color(INK, 0.8))
	draw_set_transform(p + Vector2(0, bob), bank, Vector2.ONE * presentation_scale)
	# Thruster pods and small hover jets, independent of the hero's face.
	for x in [-20, 20]:
		_box(Rect2(x - 5, 1, 10, 19), INK, 4)
		_box(Rect2(x - 4, 0, 8, 15), TEAL, 3)
		_line(Vector2(x, 17), Vector2(x, 20 + absf(sin(visual_time * 17)) * 4), Color(PALE, 0.65), 4)
	var body := CREAM
	if model.invincible > 0 and not reduced_effects and sin(visual_time * 28) > 0:
		body = Color("ffc3a0")
	_box(Rect2(-20, -20, 40, 38), INK, 11, INK, 3)
	_box(Rect2(-19, -22, 38, 35), body, 10, INK, 2)
	_box(Rect2(-12, -12, 24, 15), INK, 5, INK, 0)
	var look := model.aim.x * 1.8
	var blink := fmod(visual_time, 4.3) < 0.10
	for eye_x in [-6, 6]:
		_box(Rect2(eye_x - 2 + look, -8, 4, 2 if blink else 7), Color("85d8c1"), 1, Color("85d8c1"), 0)
	_box(Rect2(-7, 6, 14, 4), TEAL, 2, TEAL, 0)
	# A little horseshoe magnet is the fixed visual identity of the salvager.
	_line(Vector2(-10, -25), Vector2(-10, -32), CORAL, 5)
	_line(Vector2(0, -25), Vector2(0, -32), CORAL, 5)
	draw_arc(Vector2(-5, -25), 5, 0, PI, 12, CORAL, 5, true)
	_line(Vector2(-10, -32), Vector2(-10, -35), CREAM, 5)
	_line(Vector2(0, -32), Vector2(0, -35), CREAM, 5)
	draw_set_transform(p, model.aim.angle(), Vector2.ONE * presentation_scale)
	var charge: float=clampf(model.attacks.windup/0.2,0,1) if model.attacks.windup>=0 else 0.0
	_box(Rect2(17 - shot_recoil * 6 - charge*3, -4-cast_pose*2, 15+cast_pose*7, 8+cast_pose*4), Color("a7c7c4"), 2, INK, 2)
	if charge>0 or cast_pose>0:
		_line(Vector2(26,-6-cast_pose*3),Vector2(32+cast_pose*5,-6-cast_pose*3),GOLD,2)
		_line(Vector2(26,6+cast_pose*3),Vector2(32+cast_pose*5,6+cast_pose*3),PALE,2)
	draw_set_transform(Vector2.ZERO)
	if presentation_scale != 1.0: return
	if model.invincible > 0:
		draw_arc(p, 30, 0, TAU, 48, Color(CREAM, 0.5), 1.5, true)
	if model.pulse_damage() > 0:
		draw_arc(p, 31, -PI / 2, -PI / 2 + TAU * maxf(0.02, float(model.pulse_charge) / 8), 40, GOLD, 2, true)
	if model.kit != null and model.kit.shield > 0:
		draw_arc(p, 38, 0, TAU, 48, TEAL, 3, true)
		for i in range(4):
			var direction := Vector2.from_angle(i * PI / 2 + visual_time * 0.4)
			_line(p + direction * 35, p + direction * 41, PALE, 4)

func _moba_ground() -> void:
	if model.kit == null:
		return
	var kit := model.kit
	if kit.laser_left > 0:
		var direction := Vector2.from_angle(kit.laser_angle)
		var end := model.player + direction * kit.cast_range(kit.laser_slot)
		var width := 46.0 * kit.area_scale(kit.laser_slot)
		_line(model.player, end, Color(TEAL, 0.32), width)
		_line(model.player, end, Color(GOLD, 0.65), width * 0.52)
		_line(model.player, end, CREAM, width * 0.18)
		for side in [-1, 1]:
			var edge: Vector2 = direction.orthogonal() * width * 0.5 * side
			_line(model.player + edge, end + edge, Color(TEAL if kit.milestone(kit.laser_slot) == 0 else GOLD, 0.85), 2)
		if not reduced_effects:
			for i in range(8):
				var at := fmod(visual_time * 430 + i * 87, 690.0)
				var point := model.player + direction * at
				_line(point - direction.orthogonal() * width * 0.35, point + direction.orthogonal() * width * 0.35, Color(CREAM, 0.4), 2)
		draw_arc(model.player, 32, -PI / 2, -PI / 2 + TAU * kit.laser_left / 5.0, 48, GOLD, 4, true)
	if kit.sprint > 0 and model.invincible > 0:
		draw_arc(model.player, 28, visual_time * 2, visual_time * 2 + PI * 1.5, 32, Color("9cdedb"), 3, true)
	if kit.flame_left > 0:
		var cone := PackedVector2Array([model.player])
		for i in range(17):
			cone.append(model.player + kit.flame_direction.rotated(lerpf(-PI / 5, PI / 5, i / 16.0)) * kit.cast_range(kit.flame_slot) * kit.area_scale(kit.flame_slot))
		draw_colored_polygon(cone, Color(GOLD, 0.20))
		draw_polyline(cone, Color(GOLD, 0.7), 2, true)
		for i in range(3 if reduced_effects else 7):
			var fraction := fmod(visual_time * 1.7 + i * 0.143, 1.0)
			var direction := kit.flame_direction.rotated(sin(i * 2.7) * PI / 6)
			var reach := kit.cast_range(kit.flame_slot) * kit.area_scale(kit.flame_slot)
			_line(model.player + direction * (20 + fraction * reach * 0.7), model.player + direction * (38 + fraction * reach * 0.8), Color(CREAM if i % 2 == 0 else GOLD, (1 - fraction) * 0.7), 4 * (1 - fraction) + 1)
	if not preview_slot.is_empty():
		var data: Dictionary = MobaKit.ABILITIES[kit.loadout[preview_slot]]
		var radius := kit.cast_range(preview_slot)
		var end := kit.target_point(model, preview_slot, cursor_world)
		if Vanguard.enabled(model) and preview_slot=="f": end=Vanguard.blink_target(model,end)
		var color := TEAL if kit.preview_ready(model, preview_slot, cursor_world) else CORAL
		draw_arc(model.player, radius if radius > 0 else 38, 0, TAU, 80, Color(color, 0.3), 1.5, true)
		if kit.loadout[preview_slot] in ["flame","sweep","tractor","repulsor"]:
			var cone := PackedVector2Array([model.player])
			var facing := (cursor_world - model.player).normalized()
			var angle: float = PI / 5 if kit.loadout[preview_slot] == "flame" else PI * 0.34
			for i in range(17): cone.append(model.player + facing.rotated(lerpf(-angle, angle, i / 16.0)) * radius * kit.area_scale(preview_slot))
			draw_colored_polygon(cone, Color(color, 0.13))
			cone.append(model.player)
			draw_polyline(cone, color, 2, true)
		elif data.aim == "line":
			var line_end := end
			if kit.loadout[preview_slot] == "thrust":
				line_end = model.player + (cursor_world-model.player).normalized() * (440 if kit.extra.combo==2 else 230) * kit.area_scale(preview_slot)
			if data.glyph in ["beam", "rail"]:
				line_end = (model.player + (cursor_world - model.player).normalized() * radius).clamp(SalvageRun.ARENA.position + Vector2.ONE * 16, SalvageRun.ARENA.end - Vector2.ONE * 16)
			var width: float = {"thrust":40,"body_slam":48,"returner":24}.get(kit.loadout[preview_slot],56 if data.glyph == "beam" else 8) * kit.area_scale(preview_slot)
			if Vanguard.enabled(model) and preview_slot=="e": width=48
			_line(model.player, line_end, Color(color, 0.20), width)
			_line(model.player, line_end, color, 2)
			if kit.loadout[preview_slot] == "rocket": draw_arc(line_end, 62 * kit.area_scale(preview_slot), 0, TAU, 40, Color(color, 0.5), 1, true)
		elif data.aim == "ground":
			if kit.loadout[preview_slot] == "echo_dash": end=kit.extra.solid_point(model.player,end,12)
			if kit.loadout[preview_slot] == "wall":
				var side: Vector2=(end-model.player).normalized().orthogonal()*95*kit.area_scale(preview_slot)
				_line(end-side,end+side,color,11)
			var actual_radius: float = {"gravity":115,"strike":110,"artillery":110,"hop":90,"landing":150,"echo_dash":85}.get(kit.loadout[preview_slot],(135 if kit.loadout[preview_slot] == "nuke" else 90) if data.glyph == "target" else 22)
			if Vanguard.enabled(model): actual_radius={"w":100,"r":170,"x1":125,"x2":125,"x3":125}.get(preview_slot,22)
			if Vanguard.enabled(model) and preview_slot in ["x1","x2","x3"]: actual_radius=(125.0+kit.milestone(preview_slot)*20)/kit.area_scale(preview_slot)
			draw_arc(end, actual_radius * kit.area_scale(preview_slot), 0, TAU, 48, color, 2, true)
			if kit.loadout[preview_slot] == "strike": draw_arc(end,actual_radius*(0.4 if Vanguard.enabled(model) else 0.35)*kit.area_scale(preview_slot),0,TAU,32,color,1,true)
			if kit.extra.recasts.has(preview_slot) and kit.extra.recasts[preview_slot].id == "crosswire": _line(kit.extra.recasts[preview_slot].pos,end,color,2)
			_line(end - Vector2(8, 0), end + Vector2(8, 0), color, 2)
			_line(end - Vector2(0, 8), end + Vector2(0, 8), color, 2)
		elif kit.loadout[preview_slot] == "reap":
			draw_arc(model.player,165*kit.area_scale(preview_slot),0,TAU,64,color,2,true)
			draw_arc(model.player,100*kit.area_scale(preview_slot),0,TAU,64,Color(color,0.5),1,true)
	if model.moving:
		draw_arc(model.move_target, 12, 0, TAU, 24, Color(TEAL, 0.8), 2, true)
		for i in range(4):
			var dir := Vector2.from_angle(i * PI / 2)
			_line(model.move_target + dir * 15, model.move_target + dir * 20, TEAL, 2)
	if kit.sprint > 0 or kit.dash_left > 0:
		for i in range(3):
			var p := model.player + Vector2(0, (i - 1) * 10)
			_line(p, p - model.velocity.normalized() * (25 + i * 12), Color(TEAL, 0.35), 4)
	if kit.overdrive > 0:
		draw_arc(model.player, kit.cast_range("r"), 0, TAU, 64, Color(GOLD, 0.35), 2, true)
	for zone in kit.zones:
		if zone.kind == "nuke":
			var height: float = 160 * zone.time / zone.duration
			_line(zone.pos - Vector2(0, height + 32), zone.pos - Vector2(0, height), Color(GOLD, 0.8), 8)
			draw_circle(zone.pos - Vector2(0, height), 5, CREAM)
		if zone.kind == "beam":
			_line(zone.pos, zone.end, Color(TEAL, 0.22), zone.radius * 2)
			_line(zone.pos, zone.end, TEAL, 2)
		else:
			draw_circle(zone.pos, zone.radius, Color(TEAL, 0.10))
			draw_arc(zone.pos, zone.radius, 0, TAU, 48, TEAL, 2, true)
			draw_arc(zone.pos, zone.radius * (1 - zone.time / zone.duration), 0, TAU, 48, PALE, 2, true)

func _companions() -> void:
	if model.kit == null:
		return
	var kit := model.kit
	if not kit.summon.is_empty():
		var p: Vector2 = kit.summon.pos
		var repair: bool = kit.summon.id == "pylon"
		if repair:
			draw_arc(p, 100 * (1 + kit.summon.get("milestone", 0) * 0.5), 0, TAU, 48, Color(TEAL, 0.25), 1.5, true)
		draw_set_transform(p)
		for i in range(3):
			var dir := Vector2.from_angle(i * TAU / 3 - PI / 2)
			_line(dir * 10, dir * 26, INK, 8)
			_line(dir * 10, dir * 25, PALE, 4)
		_box(Rect2(-16, -19, 32, 32), TEAL, 5, INK, 3)
		_box(Rect2(-12, -16, 24, 6), PALE, 2)
		if repair:
			_line(Vector2(-7, 1), Vector2(7, 1), CREAM, 4)
			_line(Vector2(0, -6), Vector2(0, 8), CREAM, 4)
		else:
			_box(Rect2(-5, -29, 10, 24), PALE, 2, INK, 2)
			_box(Rect2(-6, -13, 12, 6), GOLD, 2)
		_box(Rect2(-18, 26, 36 * kit.summon.life / 18.0, 3), TEAL, 1, TEAL, 0)
		draw_set_transform(Vector2.ZERO)
	if kit.loadout.pet != "none" or kit.forge_pet:
		var p: Vector2 = kit.pet_position + Vector2(0, sin(visual_time * 5) * 2)
		draw_circle(p + Vector2(0, 9), 10, Color(INK, 0.45))
		draw_set_transform(p)
		_box(Rect2(-16, -3, 32, 8), PALE, 3)
		_box(Rect2(-11, -11, 22, 21), TEAL, 6, INK, 2)
		_box(Rect2(-7, -6, 14, 8), INK, 3)
		draw_circle(Vector2(-3, -2), 2, GOLD)
		draw_circle(Vector2(3, -2), 2, GOLD)
		if kit.loadout.pet == "scout":
			draw_arc(Vector2(0, 8), 6, 0, PI, 16, GOLD, 3, true)
		else:
			_box(Rect2(-3, 5, 6, 12), PALE, 2)
		draw_set_transform(Vector2.ZERO)

func _effect(effect: Dictionary) -> void:
	if effect.kind=="hit" and effect.get("heavy",false):
		var fade: float=1-effect.age/effect.life
		for i in range(4):
			var direction:=Vector2.from_angle(PI/4+i*PI/2)
			_line(effect.pos+direction*5,effect.pos+direction*(7+18*(1-fade)),Color(GOLD,fade),3)
		return
	if preload("res://src/salvage/skill_vfx.gd").draw(self,effect): return
	var t: float = effect.age / effect.life
	var p: Vector2 = effect.pos + frame_offset
	match effect.kind:
		"lightning":
			var end: Vector2 = effect.target
			var offset := (end - p).orthogonal().normalized()
			var points := PackedVector2Array([p])
			for i in range(1, 6): points.append(p.lerp(end, i / 6.0) + offset * (8 if i % 2 else -8))
			points.append(end)
			draw_polyline(points, Color(TEAL, (1 - t) * 0.6), 8, true)
			draw_polyline(points, Color(CREAM, 1 - t), 2.5, true)
		"boss_summon":
			draw_arc(p, 65 + t * 100, 0, TAU, 64, Color(CORAL, 1 - t), 4, true)
		"beam":
			_line(p, effect.target, Color(TEAL, (1 - t) * 0.4), effect.get("width", 56) * (1 - t))
			_line(p, effect.target, Color(CREAM, 1 - t), 12 * (1 - t))
		"blink":
			_line(p, effect.target, Color(TEAL, (1 - t) * 0.45), 8 * (1 - t))
			draw_arc(effect.target, 12 + t * 30, 0, TAU, 32, Color(PALE, 1 - t), 3, true)
		"move":
			draw_arc(p, 23 * (1 - t), 0, TAU, 24, Color(TEAL, 1 - t), 2, true)
		"cast":
			draw_arc(p, 23 + t * 12, 0, TAU, 24, Color(GOLD if effect.get("milestone", 0) > 0 else TEAL, (1 - t) * 0.5), 2 + effect.get("milestone", 0), true)
		"milestone", "vacuum":
			draw_arc(p, 30 + t * (160 if effect.kind == "milestone" else 350), 0, TAU, 64, Color(GOLD, 1 - t), 4, true)
		"loot":
			draw_arc(p, 10 + t * 60, 0, TAU, 48, Color(GOLD, (1 - t) * 0.55), 2, true)
			draw_string(stencil_font, p + Vector2(-22, -28 - 25 * t), "+%d" % effect.count, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(GOLD, 1 - t))
		"kill", "boss_down":
			var color := CORAL if effect.get("enemy_kind", 0) == 0 else Color("b2809c")
			for i in range(3 if reduced_effects else 6):
				var direction := Vector2.from_angle(i * TAU / 6 + float(effect.pos.x))
				var center := p + direction * (6 + 32 * t)
				_line(center, center + direction.rotated(1.0) * (5 * (1 - t)), Color(color, 1 - t), 4 * (1 - t))
		"hit":
			for i in range(3):
				var direction := Vector2.from_angle(i * TAU / 3 + float(effect.pos.y))
				_line(p + direction * 4, p + direction * (8 + t * 9), Color(CREAM, 1 - t), 2)
		"nuke_impact", "rocket_impact":
			draw_arc(p, effect.radius * (0.5 + t * 0.5), 0, TAU, 64, Color(CREAM, (1 - t) * 0.8), 6 * (1 - t) + 1, true)
			for i in range(4 if reduced_effects else 8):
				var direction := Vector2.from_angle(i * TAU / 8)
				_line(p + direction * effect.radius * t, p + direction * effect.radius * (t + 0.15), Color(GOLD, 1 - t), 3)
		"pulse":
			draw_arc(p, lerpf(20, effect.radius, t), 0, TAU, 64, Color(GOLD, (1 - t) * 0.9), 5 * (1 - t) + 1, true)
			if not reduced_effects:
				draw_arc(p, lerpf(12, effect.radius * 0.8, t), 0, TAU, 64, Color(PALE, (1 - t) * 0.5), 2, true)
		"pickup":
			draw_arc(p, 19 + t * 12, 0.2, 2.4, 20, Color(GOLD, (1 - t) * 0.5), 2, true)
		"hostile_blast":
			draw_arc(p, effect.radius, 0, TAU, 48, Color(CORAL, 1 - t), 5, true)
		"spent":
			draw_circle(p, 5 * (1 - t), Color(CREAM, 1 - t))
		"equipped":
			draw_arc(p, 20 + t * 55, 0, TAU, 48, Color(TEAL, 1 - t), 4, true)


func _local_resources() -> void:
	# Fixed logical-pixel size even at wide zoom; no numeric clutter over the actor.
	var scale_value: float=1.0/maxf(0.35, get_viewport_transform().get_scale().x)
	var origin: Vector2=model.player+Vector2(0,28)+Vector2(-23,5)*scale_value
	draw_rect(Rect2(origin-Vector2.ONE*scale_value,Vector2(48,11)*scale_value),Color("0c1720bf"))
	draw_rect(Rect2(origin,Vector2(46,4)*scale_value),Color("30404aaf"))
	draw_rect(Rect2(origin,Vector2(46*clampf(model.health/model.max_health(),0,1),4)*scale_value),Color("94cfb9dc"))
	draw_rect(Rect2(origin+Vector2(0,6)*scale_value,Vector2(46,3)*scale_value),Color("30404aaf"))
	draw_rect(Rect2(origin+Vector2(0,6)*scale_value,Vector2(46*clampf(model.kit.energy/model.kit.energy_max(),0,1),3)*scale_value),Color("82bfe6dc"))
