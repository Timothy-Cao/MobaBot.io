extends Control
## Original action icons: a fixed 64-unit canvas, shared materials, no bitmap variants.
var ability := "salvo"
const INK := Color("14242c")
const TEAL := Color("4cafaa")
const LIGHT := Color("b9ead8")
const GOLD := Color("efc16b")
const STEEL := Color("bdd3ce")
const CREAM := Color("fff0c7")

func line(a: Vector2, b: Vector2, color: Color, width: float = 2) -> void:
	draw_line(a, b, color, width, true)

func poly(points: Array, color: Color) -> void:
	var shape := PackedVector2Array(points)
	draw_colored_polygon(shape, color)
	shape.append(shape[0])
	draw_polyline(shape, INK, 2, true)

func bolt(p: Vector2, scale_value: float = 1.0) -> void:
	var points: Array = []
	for point in [Vector2(-13, 7), Vector2(1, -7), Vector2(10, -10), Vector2(7, -1), Vector2(-7, 13)]:
		points.append(p + point * scale_value)
	poly(points, STEEL)
	line(p + Vector2(-8, 8) * scale_value, p + Vector2(6, -6) * scale_value, CREAM, 2)
	draw_circle(p + Vector2(-6, 6) * scale_value, 3 * scale_value, GOLD)

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, size / 64.0)
	draw_rect(Rect2(0, 0, 64, 64), INK)
	poly([Vector2(3, 3), Vector2(60, 3), Vector2(60, 38), Vector2(38, 60), Vector2(3, 60)], Color("244a53"))
	poly([Vector2(3, 42), Vector2(42, 3), Vector2(60, 3), Vector2(3, 60)], Color("2f6466"))
	line(Vector2(5, 5), Vector2(57, 5), Color("57817e"), 1)
	for i in range(3):
		line(Vector2(7 + i * 5, 55), Vector2(7 + i * 5, 58), Color("668577"), 1)
	match ability:
		"salvo":
			for p in [Vector2(22, 20), Vector2(37, 32), Vector2(47, 47)]:
				line(p + Vector2(-15, 14), p, Color(TEAL, 0.6), 4)
				bolt(p, 0.7)
		"rail":
			line(Vector2(8, 57), Vector2(55, 10), TEAL, 10)
			bolt(Vector2(34, 29), 1.55)
		"nova":
			for r in [25, 18, 11]:
				draw_arc(Vector2(32, 32), r, 0.15, TAU - 0.1, 48, GOLD if r == 18 else TEAL, 4, true)
			draw_circle(Vector2(32, 32), 6, CREAM)
		"shield":
			poly([Vector2(12, 13), Vector2(32, 7), Vector2(53, 13), Vector2(48, 39), Vector2(32, 56), Vector2(17, 39)], STEEL)
			poly([Vector2(20, 18), Vector2(32, 14), Vector2(45, 18), Vector2(41, 36), Vector2(32, 47), Vector2(23, 36)], TEAL)
			line(Vector2(32, 18), Vector2(32, 39), CREAM, 3)
			line(Vector2(25, 28), Vector2(39, 28), CREAM, 3)
		"mortar":
			draw_arc(Vector2(29, 39), 18, 0, TAU, 32, TEAL, 4, true)
			for i in range(4):
				var d := Vector2.from_angle(i * PI / 2)
				line(Vector2(29, 39) + d * 12, Vector2(29, 39) + d * 24, STEEL, 3)
			line(Vector2(50, 9), Vector2(30, 37), GOLD, 6)
			draw_circle(Vector2(30, 37), 6, CREAM)
		"lunge":
			poly([Vector2(12, 47), Vector2(16, 24), Vector2(36, 10), Vector2(53, 29), Vector2(31, 42)], STEEL)
			poly([Vector2(19, 38), Vector2(24, 23), Vector2(36, 17), Vector2(44, 29)], TEAL)
			for i in range(3):
				line(Vector2(8 + i * 9, 55), Vector2(12 + i * 9, 44), GOLD, 3)
		"overdrive":
			for i in range(12):
				var d := Vector2.from_angle(i * TAU / 12)
				line(Vector2(32, 32) + d * 20, Vector2(32, 32) + d * 28, GOLD, 4)
			draw_circle(Vector2(32, 32), 19, STEEL)
			draw_circle(Vector2(32, 32), 14, INK)
			draw_circle(Vector2(32, 32), 10, TEAL)
			poly([Vector2(34, 18), Vector2(26, 32), Vector2(33, 32), Vector2(30, 46), Vector2(40, 29), Vector2(33, 29)], CREAM)
		"beam":
			line(Vector2(10, 54), Vector2(53, 11), TEAL, 22)
			line(Vector2(10, 54), Vector2(53, 11), GOLD, 11)
			line(Vector2(10, 54), Vector2(53, 11), CREAM, 4)
			line(Vector2(29, 7), Vector2(58, 36), STEEL, 3)
		"sprint", "dash":
			for i in range(2):
				var x := i * 20
				poly([Vector2(9 + x, 12), Vector2(31 + x, 31), Vector2(9 + x, 52), Vector2(16 + x, 32)], GOLD if ability == "sprint" else STEEL)
			if ability == "dash":
				line(Vector2(6, 55), Vector2(55, 55), LIGHT, 3)
		"blink":
			draw_arc(Vector2(19, 40), 14, 0, TAU, 32, Color(TEAL, 0.6), 3, true)
			draw_arc(Vector2(45, 22), 14, 0, TAU, 32, STEEL, 4, true)
			poly([Vector2(11, 47), Vector2(28, 27), Vector2(32, 34), Vector2(53, 13), Vector2(38, 39), Vector2(31, 34)], GOLD)
		"turret":
			poly([Vector2(13, 47), Vector2(20, 27), Vector2(42, 27), Vector2(52, 47)], STEEL)
			poly([Vector2(21, 26), Vector2(40, 26), Vector2(40, 46), Vector2(21, 46)], TEAL)
			poly([Vector2(27, 10), Vector2(36, 10), Vector2(36, 34), Vector2(27, 34)], GOLD)
			line(Vector2(12, 52), Vector2(52, 52), STEEL, 5)
		"pylon", "sacrifice":
			poly([Vector2(17, 16), Vector2(25, 16), Vector2(25, 10), Vector2(39, 10), Vector2(39, 16), Vector2(47, 16), Vector2(47, 53), Vector2(17, 53)], STEEL)
			draw_rect(Rect2(22, 21, 20, 27), TEAL)
			if ability == "pylon":
				line(Vector2(25, 34), Vector2(39, 34), CREAM, 5)
				line(Vector2(32, 27), Vector2(32, 41), CREAM, 5)
			else:
				poly([Vector2(32, 23), Vector2(23, 39), Vector2(26, 44), Vector2(37, 44), Vector2(41, 39)], Color("ee796c"))
	draw_set_transform(Vector2.ZERO)
