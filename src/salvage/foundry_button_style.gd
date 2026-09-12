class_name FoundryButtonStyle
extends StyleBox
## Shared native control material. State is provided by the Button theme.
var face:=Color("29424b")
var edge:=Color("61787b")
var accent:=Color("92a5a0")
var pressed:=false
var focused:=false
var tab:=false
var selected:=false
var disabled:=false
static func make(primary: bool, state: String, is_tab: bool=false, active: bool=false) -> FoundryButtonStyle:
	var style:=FoundryButtonStyle.new()
	style.pressed=state=="pressed"; style.focused=state=="focus"
	style.tab=is_tab; style.selected=active; style.disabled=state=="disabled"
	style.face=Color("c6a365") if primary else Color("263e48")
	style.edge=Color("e5c58b") if primary else Color("657c7f")
	style.accent=Color("f2d9a4") if primary else Color("a1b4ad")
	if is_tab: style.face=Color("35474a") if active else Color("192e37")
	if state=="hover": style.face=style.face.lightened(0.09)
	if style.pressed: style.face=style.face.darkened(0.10)
	if style.disabled:
		style.face=Color("1c3038"); style.edge=Color("40565d"); style.accent=Color("61767a")
	style.content_margin_left=8; style.content_margin_right=8
	style.content_margin_top=2 if style.pressed else 0; style.content_margin_bottom=0 if style.pressed else 2
	return style
func polygon(rect: Rect2, cut: float) -> PackedVector2Array:
	var a:=rect.position; var b:=rect.end
	return PackedVector2Array([a+Vector2(cut,0),Vector2(b.x,a.y),Vector2(b.x,b.y-cut),b-Vector2(cut,0),Vector2(a.x,b.y),a+Vector2(0,cut)])
func fill(canvas: RID, points: PackedVector2Array, color: Color) -> void:
	RenderingServer.canvas_item_add_polygon(canvas,points,PackedColorArray([color]))
func line(canvas: RID, a: Vector2, b: Vector2, color: Color, width: float=1) -> void:
	RenderingServer.canvas_item_add_line(canvas,a,b,color,width,true)
func _draw(canvas: RID, rect: Rect2) -> void:
	var cut:=minf(7,rect.size.y*0.20)
	var a:=rect.position; var b:=rect.end
	if focused:
		# Inset corner brackets remain distinct from the selected tab/material.
		for p in [a+Vector2(4,4),Vector2(b.x-4,b.y-4)]:
			var sign_value:=1 if p==a+Vector2(4,4) else -1
			line(canvas,p,p+Vector2(12*sign_value,0),Color("91dfc9"),2)
			line(canvas,p,p+Vector2(0,7*sign_value),Color("91dfc9"),2)
		return
	fill(canvas,polygon(rect,cut),Color("091a22"))
	var body:=Rect2(a+Vector2(1,2 if pressed else 0),rect.size-Vector2(2,3 if pressed else 4))
	fill(canvas,polygon(body,cut),edge)
	fill(canvas,polygon(body.grow(-1),maxf(2,cut-1)),face)
	# An upper bevel and restrained lower shadow replace the flat rounded rectangle.
	line(canvas,body.position+Vector2(cut+2,2),Vector2(body.end.x-3,body.position.y+2),Color(accent,0.45))
	line(canvas,Vector2(body.position.x+3,body.end.y-2),body.end-Vector2(cut+2,2),Color("102732"),1)
	if tab:
		if selected:
			line(canvas,Vector2(a.x+10,b.y-2),Vector2(b.x-10,b.y-2),Color("e9bd6b"),3)
		else: line(canvas,Vector2(a.x+10,b.y-2),Vector2(b.x-10,b.y-2),Color("3d545c"))
	elif rect.size.x>=100 and rect.size.y>=30:
		# Small stamped corner details, outside the text and icon area.
		line(canvas,Vector2(b.x-10,a.y+5),Vector2(b.x-5,a.y+5),Color(accent,0.55))
		line(canvas,Vector2(a.x+5,b.y-9),Vector2(a.x+10,b.y-9),Color(accent,0.35))
