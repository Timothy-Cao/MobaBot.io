class_name CombatReadability
extends RefCounted
## Shared vocabulary and screen geometry; never changes combat difficulty.

const NAMES := {"rammer": "Ram Warden", "artillery": "Artillery Warden", "foreman": "Foreman"}
const SAFE_VIEW := Rect2(54, 133, 852, 218)

static func enemy_name(enemy: Dictionary) -> String:
	return NAMES.get(enemy.get("role", ""), ["Bumper", "Charger", "Foreman", "Armored tank"][enemy.kind])

static func hint(cause: String) -> String:
	if "blast" in cause: return "Leave the marked ground before the ring fills."
	if "charge" in cause.to_lower(): return "Step sideways across the charge path."
	if "projectile" in cause: return "Move through a gap between projectiles."
	return "Keep space around your hull; use a shield or blink if trapped."

static func nearest_objective(run: SalvageRun) -> Dictionary:
	var result: Dictionary = {}
	var distance := INF
	for enemy in run.enemies:
		if enemy.dead or not enemy.has("role"): continue
		var candidate: float = run.player.distance_squared_to(enemy.pos)
		if candidate < distance:
			result = enemy
			distance = candidate
	return result

static func markers(run: SalvageRun) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not run.demo_mode: return result
	var scale_value := Vector2(960, 540) / run.view_size
	var origin := run.camera_origin()
	var player_screen := (run.player - origin) * scale_value
	var anchor := player_screen.clamp(SAFE_VIEW.position + Vector2.ONE, SAFE_VIEW.end - Vector2.ONE)
	for enemy in run.enemies:
		if enemy.dead or not enemy.has("role"): continue
		var screen_point: Vector2 = (Vector2(enemy.pos) - origin) * scale_value
		if SAFE_VIEW.has_point(screen_point): continue
		var direction := (screen_point - anchor).normalized()
		var t := INF
		if absf(direction.x) > 0.001:
			t = minf(t, ((SAFE_VIEW.end.x if direction.x > 0 else SAFE_VIEW.position.x) - anchor.x) / direction.x)
		if absf(direction.y) > 0.001:
			t = minf(t, ((SAFE_VIEW.end.y if direction.y > 0 else SAFE_VIEW.position.y) - anchor.y) / direction.y)
		result.append({"pos": anchor + direction * t, "dir": direction, "name": enemy_name(enemy), "id": enemy.id})
	var labels: Array[Vector2] = []
	for marker in result:
		var p: Vector2 = marker.pos
		var stack_up := p.y > 260
		var label_pos := Vector2(clampf(p.x - 72, 26, 788), p.y - 23 if stack_up else p.y + 27)
		if stack_up:
			label_pos.x = clampf(p.x + 24 if p.x >= 480 else p.x - 174, 26, 788)
		for prior in labels:
			if absf(prior.x - label_pos.x) < 155 and absf(prior.y - label_pos.y) < 18:
				label_pos.y += -18 if stack_up else 18
		labels.append(label_pos)
		marker.label_pos = label_pos
	return result
