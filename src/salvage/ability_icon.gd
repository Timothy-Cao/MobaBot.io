extends Control
## Original action icons: a fixed 64-unit canvas, shared materials, no bitmap variants.
var ability := "salvo"
var base_only := false
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
	var shadow := shape.duplicate()
	for i in range(shadow.size()): shadow[i] += Vector2(2, 3)
	draw_colored_polygon(shadow, Color(INK, 0.75))
	draw_colored_polygon(shape, color)
	shape.append(shape[0])
	draw_polyline(shape, INK, 2, true)
	# A shared upper-left bevel adds form without painted texture noise.
	for i in range(shape.size() - 1):
		if shape[i + 1].x > shape[i].x and shape[i + 1].y <= shape[i].y:
			line(shape[i] + Vector2(1, 1), shape[i + 1] + Vector2(-1, 1), color.lightened(0.25), 1)

func bolt(p: Vector2, scale_value: float = 1.0) -> void:
	var points: Array = []
	for point in [Vector2(-13, 7), Vector2(1, -7), Vector2(10, -10), Vector2(7, -1), Vector2(-7, 13)]:
		points.append(p + point * scale_value)
	poly(points, STEEL)
	line(p + Vector2(-8, 8) * scale_value, p + Vector2(6, -6) * scale_value, CREAM, 2)
	draw_circle(p + Vector2(-6, 6) * scale_value, 3 * scale_value, GOLD)

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, size / 64.0)
	texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var painted: Texture2D=null if base_only else PaintedIcons.texture(ability)
	if painted!=null:
		draw_texture_rect(painted,Rect2(0,0,64,64),false)
		return
	var icon_id: String=MobaKit.PASSIVES[ability].icon if MobaKit.PASSIVES.has(ability) and ability not in ["poison","lightning","pulse"] else ability
	icon_id={"vanguard_q":"rocket","vanguard_w":"strike","vanguard_e":"thrust","vanguard_r":"nuke","vanguard_d":"sprint","vanguard_f":"blink","vanguard_p1":"orbit","vanguard_x1":"pulse_sentry","vanguard_x2":"medic_sentry","vanguard_x3":"converter","vanguard_hammer":"hammer","vanguard_gun":"bolt"}.get(icon_id,icon_id)
	draw_rect(Rect2(0, 0, 64, 64), INK)
	draw_rect(Rect2(3, 3, 58, 58), Color("223c46"))
	draw_colored_polygon(PackedVector2Array([Vector2(3, 3), Vector2(61, 3), Vector2(61, 15), Vector2(3, 44)]), Color("294b54"))
	line(Vector2(5, 5), Vector2(59, 5), Color("557976"), 1)
	line(Vector2(5, 5), Vector2(5, 59), Color("557976"), 1)
	line(Vector2(59, 5), Vector2(59, 59), Color("10232c"), 2)
	line(Vector2(5, 59), Vector2(59, 59), Color("10232c"), 2)
	if ExpeditionIcon.draw(self, icon_id): return
	match icon_id:
		"hammer":
			line(Vector2(17,52),Vector2(40,24),INK,11)
			line(Vector2(17,52),Vector2(40,24),STEEL,6)
			poly([Vector2(25,17),Vector2(35,9),Vector2(56,28),Vector2(46,40)],TEAL)
			line(Vector2(46,16),Vector2(53,24),CREAM,5)
			line(Vector2(30,20),Vector2(44,32),GOLD,3)
		"poison":
			poly([Vector2(24, 13), Vector2(40, 13), Vector2(39, 24), Vector2(49, 48), Vector2(44, 53), Vector2(20, 53), Vector2(15, 48), Vector2(25, 24)], STEEL)
			poly([Vector2(24, 33), Vector2(40, 33), Vector2(45, 47), Vector2(20, 47)], TEAL)
			line(Vector2(23, 14), Vector2(41, 14), GOLD, 4)
			draw_circle(Vector2(30, 40), 3, LIGHT)
			draw_circle(Vector2(37, 45), 2, CREAM)
		"lightning":
			for p in [Vector2(12, 47), Vector2(49, 15)]:
				draw_circle(p, 10, INK)
				draw_circle(p, 7, TEAL)
				draw_arc(p, 7, PI, TAU, 16, STEEL, 3, true)
			poly([Vector2(34, 9), Vector2(17, 34), Vector2(29, 34), Vector2(24, 56), Vector2(47, 27), Vector2(35, 27)], GOLD)
			line(Vector2(29, 29), Vector2(36, 19), CREAM, 3)
		"power", "pulse", "reactor":
			for i in range(8):
				var d := Vector2.from_angle(i * TAU / 8)
				line(Vector2(32, 32) + d * 15, Vector2(32, 32) + d * 26, STEEL, 7)
			draw_circle(Vector2(32, 32), 21, INK)
			draw_circle(Vector2(32, 32), 18, TEAL)
			draw_arc(Vector2(32, 32), 16, PI, TAU * 0.9, 24, LIGHT, 3, true)
			draw_circle(Vector2(32, 32), 11, INK)
			draw_circle(Vector2(32, 32), 7, GOLD)
			if icon_id == "power": bolt(Vector2(34, 29), 0.8)
			if icon_id == "reactor": line(Vector2(28, 32), Vector2(36, 32), CREAM, 3)
		"grinder", "ricochet":
			var points: Array = []
			for i in range(24): points.append(Vector2(32, 32) + Vector2.from_angle(i * TAU / 24) * (26 if i % 3 == 0 else 21))
			poly(points, STEEL)
			draw_circle(Vector2(32, 32), 15, INK)
			draw_circle(Vector2(32, 32), 12, TEAL)
			draw_arc(Vector2(32, 32), 11, PI, TAU, 20, LIGHT, 2, true)
			draw_circle(Vector2(32, 32), 5, GOLD)
			if icon_id == "ricochet":
				line(Vector2(11, 51), Vector2(44, 18), GOLD, 4)
				line(Vector2(44, 18), Vector2(53, 40), GOLD, 4)
		"magnet":
			poly([Vector2(9, 12), Vector2(23, 12), Vector2(23, 38), Vector2(29, 44), Vector2(35, 44), Vector2(41, 38), Vector2(41, 12), Vector2(55, 12), Vector2(55, 41), Vector2(43, 55), Vector2(21, 55), Vector2(9, 41)], TEAL)
			draw_rect(Rect2(10, 12, 12, 10), STEEL)
			draw_rect(Rect2(42, 12, 12, 10), GOLD)
			line(Vector2(15, 27), Vector2(15, 39), LIGHT, 3)
		"chassis", "capacity":
			poly([Vector2(8, 16), Vector2(22, 9), Vector2(42, 9), Vector2(56, 16), Vector2(51, 47), Vector2(40, 55), Vector2(24, 55), Vector2(13, 47)], STEEL)
			poly([Vector2(20, 19), Vector2(44, 19), Vector2(44, 45), Vector2(20, 45)], TEAL)
			draw_rect(Rect2(24, 25, 16, 12), INK)
			for x in [27, 36]: draw_circle(Vector2(x, 30), 2, CREAM)
			line(Vector2(24, 41), Vector2(40, 41), GOLD, 3)
		"jets", "rapid":
			for x in [12, 36]:
				poly([Vector2(x, 16), Vector2(x + 7, 9), Vector2(x + 17, 16), Vector2(x + 15, 42), Vector2(x + 2, 42)], STEEL)
				draw_rect(Rect2(x + 3, 20, 10, 14), TEAL)
				poly([Vector2(x + 3, 43), Vector2(x + 14, 43), Vector2(x + 8, 58)], GOLD)
				line(Vector2(x + 7, 45), Vector2(x + 8, 52), CREAM, 3)
		"cell":
			poly([Vector2(20, 8), Vector2(44, 8), Vector2(49, 18), Vector2(49, 53), Vector2(15, 53), Vector2(15, 18)], STEEL)
			draw_rect(Rect2(21, 19, 22, 28), TEAL)
			for y in [23, 31, 39]: draw_rect(Rect2(25, y, 14, 4), GOLD)
		"rocket":
			poly([Vector2(13, 47), Vector2(29, 19), Vector2(50, 10), Vector2(46, 33), Vector2(22, 53)], STEEL)
			poly([Vector2(29, 19), Vector2(50, 10), Vector2(46, 33)], TEAL)
			line(Vector2(9, 55), Vector2(21, 43), GOLD, 7)
		"flame":
			poly([Vector2(17, 53), Vector2(8, 34), Vector2(22, 37), Vector2(24, 10), Vector2(36, 28), Vector2(49, 14), Vector2(55, 36), Vector2(44, 54)], GOLD)
			poly([Vector2(25, 51), Vector2(24, 35), Vector2(34, 40), Vector2(43, 29), Vector2(43, 49)], CREAM)
		"nuke":
			for r in [14, 25]: draw_arc(Vector2(32, 37), r, 0, TAU, 40, GOLD, 3, true)
			line(Vector2(32, 7), Vector2(32, 35), STEEL, 9)
			poly([Vector2(21, 29), Vector2(43, 29), Vector2(32, 45)], CREAM)
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
		"shield", "thorns":
			poly([Vector2(12, 13), Vector2(32, 7), Vector2(53, 13), Vector2(48, 39), Vector2(32, 56), Vector2(17, 39)], STEEL)
			poly([Vector2(20, 18), Vector2(32, 14), Vector2(45, 18), Vector2(41, 36), Vector2(32, 47), Vector2(23, 36)], TEAL)
			line(Vector2(32, 18), Vector2(32, 39), CREAM, 3)
			line(Vector2(25, 28), Vector2(39, 28), CREAM, 3)
			if icon_id == "thorns":
				for side in [-1, 1]:
					poly([Vector2(32 + side * 15, 22), Vector2(32 + side * 29, 15), Vector2(32 + side * 18, 35)], GOLD)
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
		"beam", "laser":
			line(Vector2(10, 54), Vector2(53, 11), TEAL, 22)
			line(Vector2(10, 54), Vector2(53, 11), GOLD, 11)
			line(Vector2(10, 54), Vector2(53, 11), CREAM, 4)
			line(Vector2(29, 7), Vector2(58, 36), STEEL, 3)
			poly([Vector2(8, 45), Vector2(19, 35), Vector2(30, 46), Vector2(19, 57)], STEEL)
			draw_circle(Vector2(19, 46), 5, TEAL)
		"sprint", "dash":
			for i in range(2):
				var x := i * 20
				poly([Vector2(9 + x, 12), Vector2(31 + x, 31), Vector2(9 + x, 52), Vector2(16 + x, 32)], GOLD if icon_id == "sprint" else STEEL)
			if icon_id == "dash":
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
			if icon_id == "pylon":
				line(Vector2(25, 34), Vector2(39, 34), CREAM, 5)
				line(Vector2(32, 27), Vector2(32, 41), CREAM, 5)
			else:
				poly([Vector2(32, 23), Vector2(23, 39), Vector2(26, 44), Vector2(37, 44), Vector2(41, 39)], Color("ee796c"))
	draw_set_transform(Vector2.ZERO)
