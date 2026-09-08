extends Control
## Required targets remain findable, including behind the opaque HUD.
var model: SalvageRun
var font := SystemFont.new()

func _draw() -> void:
	if model == null: return
	for marker in CombatReadability.markers(model):
		var p: Vector2 = marker.pos
		var direction: Vector2 = marker.dir
		draw_circle(p, 13, Color("14242c"))
		var triangle := PackedVector2Array([p + direction * 10, p - direction * 6 + direction.orthogonal() * 6, p - direction * 6 - direction.orthogonal() * 6])
		draw_colored_polygon(triangle, Color("ee796c"))
		var label_pos: Vector2 = marker.label_pos
		draw_rect(Rect2(label_pos - Vector2(3, 12), Vector2(151, 17)), Color("14242ce8"))
		draw_string(font, label_pos, marker.name, HORIZONTAL_ALIGNMENT_CENTER, 145, 11, Color("fff0c7"))
