extends Control
## An assembly diagram, not a claim that inventory changes the world sprite.
var highlighted := "Core"
const INK := Color("0d1c24")
const LINE := Color("49676c")
const STEEL := Color("bdd3ce")
const TEAL := Color("399c99")
const GOLD := Color("efc16b")

func _draw() -> void:
	draw_set_transform(size * 0.5, 0, Vector2.ONE * minf(size.x / 250, size.y / 270))
	for y in range(-120, 130, 20): draw_line(Vector2(-115, y), Vector2(115, y), Color(LINE, 0.17), 1)
	for x in range(-100, 120, 20): draw_line(Vector2(x, -128), Vector2(x, 128), Color(LINE, 0.17), 1)
	draw_arc(Vector2.ZERO, 104, 0, TAU, 64, Color(LINE, 0.45), 1, true)
	draw_line(Vector2(-118, 0), Vector2(118, 0), LINE, 1)
	draw_line(Vector2(0, -129), Vector2(0, 129), LINE, 1)
	_box(Rect2(-64, -54, 128, 125), Color("1c3f49"), STEEL if highlighted == "Chassis" else LINE, 3)
	_box(Rect2(-80, -16, 23, 71), TEAL, INK, 3)
	_box(Rect2(57, -16, 23, 71), TEAL, INK, 3)
	_box(Rect2(-49, -45, 98, 77), Color("fff0c7"), INK, 4)
	_box(Rect2(-34, -27, 68, 39), INK, INK, 2)
	draw_rect(Rect2(-21, -16, 8, 18), Color("78cbb6"))
	draw_rect(Rect2(13, -16, 8, 18), Color("78cbb6"))
	# The three fitted regions have distinct silhouettes even without color.
	draw_circle(Vector2(0, 53), 24, INK)
	draw_arc(Vector2(0, 53), 22, 0, TAU, 36, GOLD if highlighted == "Core" else LINE, 3, true)
	draw_circle(Vector2(0, 53), 13, TEAL)
	draw_circle(Vector2(0, 53), 6, STEEL)
	for x in [-48, 48]:
		_box(Rect2(x - 14, 65, 28, 25), STEEL, GOLD if highlighted == "Drive" else INK, 3)
		draw_colored_polygon(PackedVector2Array([Vector2(x - 10, 94), Vector2(x + 10, 94), Vector2(x, 111)]), Color("78cbb6"))
	draw_polyline(PackedVector2Array([Vector2(-18, -86), Vector2(-18, -66), Vector2(18, -66), Vector2(18, -86)]), Color("ee796c"), 10, true)
	draw_line(Vector2(-18, -92), Vector2(-18, -84), STEEL, 10)
	draw_line(Vector2(18, -92), Vector2(18, -84), STEEL, 10)
	for point in [Vector2(-105, -103), Vector2(105, -103), Vector2(-105, 118), Vector2(105, 118)]:
		draw_line(point - Vector2(4, 0), point + Vector2(4, 0), STEEL, 1)
		draw_line(point - Vector2(0, 4), point + Vector2(0, 4), STEEL, 1)

func _box(rect: Rect2, fill: Color, border: Color, width: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(5)
	draw_style_box(style, rect)
