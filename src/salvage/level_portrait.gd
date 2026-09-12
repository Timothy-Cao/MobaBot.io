class_name LevelPortrait
extends Control
var texture: Texture2D
var selected:=false
var locked:=false
var hovered:=false
func _draw() -> void:
	var points:=PackedVector2Array([Vector2(14,0),Vector2(size.x,0),Vector2(size.x,size.y-14),Vector2(size.x-14,size.y),Vector2(0,size.y),Vector2(0,14)])
	var uvs:=PackedVector2Array()
	for p in points: uvs.append(Vector2(p.x/size.x,0.15+p.y/size.y*0.7))
	if texture!=null: draw_polygon(points,PackedColorArray([Color("89949a") if locked else Color.WHITE]),uvs,texture)
	draw_polygon(points,PackedColorArray([Color(0.03,0.08,0.12,0.4 if locked else 0.02)]))
	for i in range(85):
		var y: float=size.y-85+i
		draw_line(Vector2(1,y),Vector2(size.x-1,y),Color(0.035,0.07,0.10,0.88*float(i)/84),1)
	points.append(points[0])
	draw_polyline(points,Color("e7bd6b") if selected else Color("afd3cc") if hovered else Color("527079"),4 if selected else 2,true)
	if selected: draw_line(Vector2(20,5),Vector2(size.x-20,5),Color("f5d98c"),4)
