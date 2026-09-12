extends Control
## Native, resolution-independent foundry controls. Text remains a real Button.
var primary:=false
var symbol:="Play"
const INK:=Color("08151b")
const STEEL:=Color("34525b")
const CREAM:=Color("eee9d5")
const BRASS:=Color("e9b958")
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	show_behind_parent=true
	var button:=get_parent() as Button
	for signal_name in ["mouse_entered","mouse_exited","focus_entered","focus_exited","button_down","button_up","resized"]:
		button.connect(signal_name,queue_redraw)
func shape(rect: Rect2, cut: float) -> PackedVector2Array:
	var a:=rect.position; var b:=rect.end
	return PackedVector2Array([a+Vector2(cut,0),Vector2(b.x, a.y),Vector2(b.x,b.y-cut),b-Vector2(cut,0),Vector2(a.x,b.y),a+Vector2(0,cut)])
func plate(rect: Rect2, color: Color, cut: float, edge: Color, width: float=2) -> void:
	var points:=shape(rect,cut); draw_colored_polygon(points,color)
	points.append(points[0]); draw_polyline(points,edge,width,true)
func _draw() -> void:
	var button:=get_parent() as Button
	var hot:=button.is_hovered() or button.has_focus()
	var down:=button.is_pressed()
	var compact:=size.y<42
	var y:=3.0 if down else 0.0
	var face:=Rect2(Vector2(0,y),size-Vector2(0,5))
	plate(Rect2(Vector2(0,5),size-Vector2(0,5)),INK,8,INK,3)
	plate(face,BRASS.lightened(0.12) if primary and hot else BRASS if primary else STEEL.lightened(0.12) if hot else Color("243d46"),8,INK,3)
	var accent:=Color("ffe6a0") if primary else Color("75958f")
	draw_line(Vector2(10,y+2),Vector2(size.x-3,y+2),accent,2)
	draw_line(Vector2(3,size.y-7+y),Vector2(size.x-11,size.y-7+y),Color("745b36") if primary else Color("152a33"),3)
	if hot:
		var outline:=shape(face.grow(-3),6); outline.append(outline[0]); draw_polyline(outline,CREAM if primary else Color("83d7c1"),1.5,true)
	# Recessed icon socket and slotted fasteners, with a common industrial vocabulary.
	var center:=Vector2(24 if compact else 32,size.y*0.5-2+y)
	if not compact:
		plate(Rect2(center-Vector2(19,19),Vector2(38,38)),INK,4,Color("aa8748") if primary else Color("547079"),1)
	var color:=BRASS if primary else CREAM
	draw_set_transform(center,0,Vector2.ONE*(0.66 if compact else 1))
	match symbol:
		"Play":
			draw_colored_polygon(PackedVector2Array([Vector2(-6,-11),Vector2(11,0),Vector2(-6,11)]),color)
		"Equipment","Loadout":
			draw_polyline(PackedVector2Array([Vector2(-12,-8),Vector2(-5,-13),Vector2(0,-7),Vector2(5,-13),Vector2(12,-8),Vector2(8,0),Vector2(7,12),Vector2(-7,12),Vector2(-8,0),Vector2(-12,-8)]),color,2.5,true)
			draw_line(Vector2(-5,3),Vector2(5,3),color,2)
		"Practice":
			draw_arc(Vector2.ZERO,10,0,TAU,24,color,2,true)
			for i in range(4):
				var d:=Vector2.from_angle(i*PI/2); draw_line(d*6,d*15,color,2)
			draw_circle(Vector2.ZERO,3,Color("de895b"))
		"Settings":
			for i in range(3):
				var x: float=-10+i*10; draw_line(Vector2(x,-12),Vector2(x,12),color,2)
				draw_rect(Rect2(x-3,-6 if i%2==0 else 3,6,5),color)
		"Quit":
			draw_arc(Vector2.ZERO,11,-PI*0.32,PI*1.32,24,color,2.5,true)
			draw_line(Vector2(0,-15),Vector2(0,-2),color,3)
	draw_set_transform(Vector2.ZERO)
	if not compact:
		for px in [size.x-12,size.x-24]:
			draw_circle(Vector2(px,11+y),2.5,INK)
			draw_line(Vector2(px-1,10+y),Vector2(px+1,12+y),accent,1)
		for i in range(2):
			var x:=size.x-29-i*10
			draw_polyline(PackedVector2Array([Vector2(x-4,face.get_center().y-5),Vector2(x+1,face.get_center().y),Vector2(x-4,face.get_center().y+5)]),INK if primary else Color("83d7c1") if hot else Color("66848a"),2,true)
