extends Control

var model: SalvageRun

func _draw() -> void:
	if model == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color("14242ce8"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("526d74"), false, 1)
	var bounds := Rect2(Vector2(7, 7), size - Vector2(14, 14))
	var scale_value := bounds.size / SalvageRun.ARENA.size
	if FactoryMaps.enabled(model):
		for wall in model.kit.extra.walls:
			if not wall.get("terrain",false): continue
			var a: Vector2=bounds.position+(Vector2(wall.a)-SalvageRun.ARENA.position)*scale_value
			var b: Vector2=bounds.position+(Vector2(wall.b)-SalvageRun.ARENA.position)*scale_value
			draw_line(a,b,Color("7b8d89"),maxf(2,wall.width*2*minf(scale_value.x,scale_value.y)),true)
	for cache in model.caches:
		if not cache.opened:
			var point: Vector2 = bounds.position + (Vector2(cache.pos) - SalvageRun.ARENA.position) * scale_value
			draw_rect(Rect2(point - Vector2.ONE * 2, Vector2.ONE * 4), Color("efc16b"))
	var camera_box := Rect2(bounds.position + (model.camera_origin() - SalvageRun.ARENA.position) * scale_value, model.view_size * scale_value)
	camera_box = camera_box.intersection(bounds)
	draw_rect(camera_box, Color("a0b3b780"), false, 1)
	var player_point := bounds.position + (model.player - SalvageRun.ARENA.position) * scale_value
	draw_circle(player_point, 3, Color("78cbb6"))
	for enemy in model.enemies:
		if enemy.kind == 2 and not enemy.dead:
			var point: Vector2 = bounds.position + (Vector2(enemy.pos) - SalvageRun.ARENA.position) * scale_value
			draw_circle(point, 3, Color("ee796c"))
