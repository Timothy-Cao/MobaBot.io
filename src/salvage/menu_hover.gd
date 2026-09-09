extends Control
## Separate painted silhouette with native, understated thrust motion.
const ROBOT=preload("res://assets/menu/menu-bot-v2.png")
var clock:=0.0
var reduced:=false
func _process(delta: float) -> void:
	clock+=delta; queue_redraw()
func _draw() -> void:
	var hover:=0.0 if reduced else sin(clock*1.8)*4
	draw_set_transform(Vector2(0,hover))
	for pos in [Vector2(52,246),Vector2(202,246)]:
		var length:=24.0 if reduced else 24.0+sin(clock*18+pos.x)*4
		draw_colored_polygon(PackedVector2Array([pos+Vector2(-10,0),pos+Vector2(8,0),pos+Vector2(3,length),pos+Vector2(-4,length*0.75)]),Color("4ab9c299"))
		draw_colored_polygon(PackedVector2Array([pos+Vector2(-5,0),pos+Vector2(4,0),pos+Vector2(0,length*0.7)]),Color("bdf9eccc"))
	draw_texture_rect(ROBOT,Rect2(0,0,286,286),false)
	draw_set_transform(Vector2.ZERO)
