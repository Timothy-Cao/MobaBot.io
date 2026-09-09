class_name RewardMotion
extends Control
var age := 0.0
var reduced := false

func _process(delta: float) -> void:
	age+=delta
	queue_redraw()
	if age>=1: set_process(false)

func _draw() -> void:
	var t:=1.0 if reduced else clampf(age/0.7,0,1)
	var center:=size*0.5
	var gold:=Color("efc16b"); var ink:=Color("14242c"); var steel:=Color("bdd3ce")
	var settle:=1+sin(t*PI)*0.07
	draw_set_transform(center,0,Vector2.ONE*settle)
	draw_rect(Rect2(-45,-12,90,51),ink)
	draw_rect(Rect2(-40,-8,80,42),gold)
	draw_rect(Rect2(-33,-2,66,27),Color("31536b"))
	# Shared industrial material planes; avoid a generic flat treasure-box glyph.
	draw_colored_polygon(PackedVector2Array([Vector2(-33,-2),Vector2(33,-2),Vector2(25,7),Vector2(-25,7)]),Color("47747b"))
	draw_rect(Rect2(-29,9,58,12),Color("203741"))
	for side in [-1,1]:
		draw_rect(Rect2(side*35-4,-5,8,35),steel)
		draw_circle(Vector2(side*35,0),2.2,ink)
		draw_circle(Vector2(side*35,25),2.2,ink)
		for i in range(3): draw_line(Vector2(side*(13+i*5),12),Vector2(side*(13+i*5),18),gold,1.5)
	draw_rect(Rect2(-36,-15,72,6),Color("09151b"))
	draw_rect(Rect2(-30,-14,60,3),Color(gold,t*0.8))
	draw_rect(Rect2(-45,-26-t*22,90,19),ink)
	draw_rect(Rect2(-40,-22-t*22,80,11),steel)
	draw_rect(Rect2(-32,-20-t*22,64,6),Color("47747b"))
	draw_rect(Rect2(-5,-8,10,23),gold)
	if t<1 and not reduced:
		for i in range(8):
			var d:=Vector2.from_angle(i*TAU/8)
			draw_line(d*(43+t*28),d*(47+t*41),Color(gold,sin(t*PI)*0.7),2,true)
	draw_set_transform(Vector2.ZERO)

static func reveal(ui, cards: Array) -> void:
	if ui.reduced: return
	for i in range(cards.size()):
		var card: Control=cards[i]
		card.pivot_offset=card.size*0.5
		card.scale=Vector2.ONE*0.94; card.modulate.a=0
		var tween:=card.create_tween().set_parallel()
		tween.tween_property(card,"scale",Vector2.ONE,0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(i*0.045)
		tween.tween_property(card,"modulate:a",1.0,0.16).set_delay(i*0.045)

static func compact(ui) -> void:
	for child in ui.overlay.get_children():
		if not child is Control: continue
		if child is ColorRect and child.size.x>=950: continue
		child.position=Vector2(96,54)+child.position*0.8
		child.scale*=0.8
