extends Control
var active:=false
func _ready() -> void: mouse_filter=Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
	var p:=Vector2(12,(size.y-14)*0.5)
	draw_style_box(FoundryButtonStyle.make(false,"pressed"),Rect2(p,Vector2(36,16)))
	var x: float=p.x+(20 if active else 3)
	draw_rect(Rect2(x,p.y+3,12,9),Color("a7c7b9") if active else Color("71848a"))
	draw_line(Vector2(x+5,p.y+4),Vector2(x+5,p.y+10),Color("253d45"),1)
	draw_circle(p+Vector2(-5,7),2,Color("8fe0b9") if active else Color("435d64"))
