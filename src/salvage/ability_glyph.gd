extends Control
## Small code-native action marks layered on the existing equipment illustrations.
var glyph := "ring"
var color := Color("fff0c7")

func _draw() -> void:
	var center := size / 2
	var r := minf(size.x, size.y) * 0.36
	draw_circle(center, r + 3, Color("14242cef"))
	match glyph:
		"ring", "sun", "blink", "target":
			draw_arc(center, r * 0.7, 0, TAU, 24, color, 2, true)
			if glyph == "ring":
				draw_arc(center, r * 0.25, 0, TAU, 16, color, 1.5, true)
			elif glyph == "blink":
				draw_line(center - Vector2(r, r), center + Vector2(r, r), color, 2, true)
			elif glyph == "sun":
				for i in range(8):
					var d := Vector2.from_angle(i * PI / 4)
					draw_line(center + d * r * 0.85, center + d * r * 1.25, color, 2, true)
			else:
				for i in range(4):
					var d := Vector2.from_angle(i * PI / 2)
					draw_line(center + d * r * 0.35, center + d * r, color, 2, true)
		"shield":
			draw_polyline(PackedVector2Array([center + Vector2(-r, -r), center + Vector2(r, -r), center + Vector2(r * 0.7, r * 0.3), center + Vector2(0, r), center + Vector2(-r * 0.7, r * 0.3), center + Vector2(-r, -r)]), color, 2, true)
		"cross", "turret":
			draw_line(center - Vector2(r, 0), center + Vector2(r, 0), color, 3, true)
			draw_line(center - Vector2(0, r), center + Vector2(0, r), color, 3, true)
			if glyph == "turret":
				draw_line(center + Vector2(-r, r), center + Vector2(r, r), color, 2, true)
		"salvo":
			for i in range(3):
				draw_circle(center + Vector2((i - 1) * r * 0.8, -(i % 2) * r * 0.5), 2.5, color)
		_:
			draw_line(center - Vector2(r, 0), center + Vector2(r, 0), color, 3 if glyph == "beam" else 2, true)
			draw_polyline(PackedVector2Array([center + Vector2(0, -r), center + Vector2(r, 0), center + Vector2(0, r)]), color, 2, true)
			if glyph in ["speed", "dash"]:
				draw_polyline(PackedVector2Array([center + Vector2(-r, -r), center, center + Vector2(-r, r)]), color, 2, true)
