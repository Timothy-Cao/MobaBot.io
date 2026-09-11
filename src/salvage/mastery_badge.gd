class_name MasteryBadge
extends Control
## Small native overlays: reusable independently of any painted base or tree.
var symbol: String="health"
const SYMBOLS: Array[String]=["health","energy","range","resist","charge","xp","loot","supplies","double","damage","magnet","stun"]
const STATS: Dictionary={"magnet":"magnet","range":"range","efficiency":"energy","emp_resist":"resist","extra_charge":"charge","xp":"xp","loot_bonus":"loot","supplies":"supplies","double_chest":"double","pet_damage":"damage","pet_magnet":"magnet","pet_repair":"health","pet_stun":"stun"}

static func attach(ui, parent: Node, base: String, kind: String, rect: Rect2) -> Control:
	var icon: Control=ui._ability_icon(parent,base,rect)
	icon.set_meta("mastery_base",base)
	var badge:=MasteryBadge.new(); badge.symbol=kind
	badge.position=Vector2(rect.size.x-12,-4); badge.size=Vector2(18,18)
	badge.mouse_filter=Control.MOUSE_FILTER_IGNORE
	icon.add_child(badge)
	return icon

func _draw() -> void:
	var color:=Color("eac471")
	if symbol in ["health","supplies"]: color=Color("87d69f")
	elif symbol in ["energy","range","magnet"]: color=Color("8ed6e8")
	elif symbol in ["resist","stun","xp"]: color=Color("c4a1e8")
	draw_rect(Rect2(0,0,18,18),Color("10242d"))
	draw_rect(Rect2(0,0,18,18),color,false,1)
	match symbol:
		"health","charge","supplies":
			draw_rect(Rect2(7,4,4,10),color); draw_rect(Rect2(4,7,10,4),color)
			if symbol=="charge": draw_line(Vector2(3,3),Vector2(7,3),color,2)
			if symbol=="supplies": draw_rect(Rect2(3,3,12,12),color,false,1)
		"energy":
			draw_colored_polygon(PackedVector2Array([Vector2(10,2),Vector2(4,10),Vector2(8,10),Vector2(7,16),Vector2(14,7),Vector2(10,7)]),color)
		"range":
			draw_line(Vector2(3,9),Vector2(15,9),color,2)
			draw_polyline(PackedVector2Array([Vector2(6,5),Vector2(3,9),Vector2(6,13)]),color,2)
			draw_polyline(PackedVector2Array([Vector2(12,5),Vector2(15,9),Vector2(12,13)]),color,2)
		"xp":
			for y in [7,12]: draw_polyline(PackedVector2Array([Vector2(4,y),Vector2(9,y-4),Vector2(14,y)]),color,2)
		"resist":
			draw_polyline(PackedVector2Array([Vector2(9,3),Vector2(14,5),Vector2(13,11),Vector2(9,15),Vector2(5,11),Vector2(4,5),Vector2(9,3)]),color,2)
		"loot","double":
			draw_rect(Rect2(4,5,8,9),color,false,2)
			if symbol=="double": draw_polyline(PackedVector2Array([Vector2(7,3),Vector2(15,3),Vector2(15,11)]),color,2)
			else: draw_line(Vector2(8,7),Vector2(8,12),color,2)
		"magnet":
			draw_polyline(PackedVector2Array([Vector2(4,4),Vector2(4,11),Vector2(7,14),Vector2(11,14),Vector2(14,11),Vector2(14,4)]),color,3)
		"damage":
			draw_line(Vector2(4,14),Vector2(14,4),color,3); draw_line(Vector2(4,9),Vector2(9,14),color,2)
		"stun":
			for direction in [Vector2.RIGHT,Vector2.DOWN,Vector2(0.7,0.7),Vector2(0.7,-0.7)]: draw_line(Vector2(9,9)-direction*6,Vector2(9,9)+direction*6,color,2)
