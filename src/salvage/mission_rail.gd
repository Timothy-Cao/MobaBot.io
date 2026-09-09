extends Control
var stage := 1
var progress := 0.0

func _draw() -> void:
	for i in range(3):
		var x := i * 37.0
		draw_rect(Rect2(x, 2, 29, 3), Color("425863"))
		if i + 1 <= stage:
			draw_rect(Rect2(x, 2, 29 * (progress if i + 1 == stage else 1.0), 3), Color("efc16b") if i + 1 == stage else Color("78cbb6"))
		if i + 1 == stage:
			draw_colored_polygon(PackedVector2Array([Vector2(x + 11, 9), Vector2(x + 18, 9), Vector2(x + 14.5, 6)]), Color("efc16b"))
