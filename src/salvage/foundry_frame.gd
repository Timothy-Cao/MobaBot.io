class_name FoundryFrame
extends Control
func _ready() -> void: mouse_filter=Control.MOUSE_FILTER_IGNORE
func plate(rect: Rect2, color: Color, edge: Color, cut: float=10) -> void:
	var a:=rect.position; var b:=rect.end
	var points:=PackedVector2Array([a+Vector2(cut,0),Vector2(b.x,a.y),Vector2(b.x,b.y-cut),b-Vector2(cut,0),Vector2(a.x,b.y),a+Vector2(0,cut)])
	draw_colored_polygon(points,color); points.append(points[0]); draw_polyline(points,edge,2,true)
func _draw() -> void:
	plate(Rect2(0,5,size.x,size.y),Color("07131a"),Color("07131a"))
	plate(Rect2(Vector2.ZERO,size),Color("203740"),Color("71817b"))
	plate(Rect2(8,8,size.x-16,55),Color("304951"),Color("162d36"),6)
	draw_line(Vector2(22,64),Vector2(size.x-22,64),Color("a28c5e"),2)
	plate(Rect2(14,107,size.x-28,size.y-133),Color("182e37"),Color("29424b"),5)
	for x in [7.0,size.x-7]:
		for y in [88.0,size.y-14]:
			draw_circle(Vector2(x,y),3,Color("091a22")); draw_line(Vector2(x-1,y-1),Vector2(x+1,y+1),Color("98a394"),1)
	for i in range(5):
		var x:=24+i*10
		draw_line(Vector2(x,size.y-10),Vector2(x+5,size.y-16),Color("ac925e"),3)
	draw_line(Vector2(22,2),Vector2(80,2),Color("efc568"),3)
