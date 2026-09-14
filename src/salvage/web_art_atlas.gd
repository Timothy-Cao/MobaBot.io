class_name WebArtAtlas
extends RefCounted
## Bake existing repeated decoration once on the GPU. No asset files or simulation changes.
const CELL:=64
const SCALE:=2
var viewport: SubViewport
var ready:=false

class Painter extends Node2D:
	const INK:=Color("14242c")
	const CREAM:=Color("fff0c7")
	const GOLD:=Color("efc16b")
	func box(rect: Rect2, color: Color, radius: int, border: Color=INK, width: int=2) -> void:
		var style:=StyleBoxFlat.new(); style.bg_color=color; style.border_color=border
		style.set_border_width_all(width); style.set_corner_radius_all(radius); draw_style_box(style,rect)
	func _draw() -> void:
		for cell in range(6):
			draw_set_transform(Vector2(cell*64+32,32)*2,0,Vector2.ONE*2)
			if cell<2:
				box(Rect2(-18,-4,36,13),INK,5)
				draw_circle(Vector2.ZERO,15,INK)
				draw_circle(Vector2(0,-1),12,Color("ee796c") if cell==0 else CREAM)
				draw_arc(Vector2(0,-1),9,PI*1.1,PI*1.8,12,Color("ffb49a"),2,true)
				box(Rect2(-8,-2,16,7),INK,3,INK,0)
				draw_circle(Vector2(-4,1),2,CREAM); draw_circle(Vector2(4,1),2,CREAM)
				draw_line(Vector2(-5,9),Vector2(5,9),INK,2,true)
			elif cell<4:
				box(Rect2(-4,-5,8,10),GOLD,2,INK,1)
				draw_line(Vector2(-2,-2),Vector2(2,-2),CREAM,1,true)
				if cell==3: draw_circle(Vector2(3,-4),2,CREAM)
			else:
				draw_circle(Vector2.ZERO,18 if cell==4 else 5,Color(INK,0.7 if cell==4 else 0.6))
			draw_set_transform(Vector2.ZERO)

func attach(parent: Node) -> void:
	viewport=SubViewport.new(); viewport.name="WebDecorationAtlas"
	viewport.size=Vector2i(CELL*6*SCALE,CELL*SCALE); viewport.transparent_bg=true
	viewport.disable_3d=true; viewport.render_target_update_mode=SubViewport.UPDATE_ONCE
	parent.add_child(viewport); viewport.add_child(Painter.new())
	# Transparent viewport output is premultiplied. Resolve once to straight alpha
	# before mixing atlas quads with the world's ordinary CanvasItem commands.
	var raw:=viewport
	viewport=SubViewport.new(); viewport.name="WebStraightAlphaAtlas"
	viewport.size=raw.size; viewport.transparent_bg=true; viewport.disable_3d=true
	viewport.render_target_update_mode=SubViewport.UPDATE_ONCE; parent.add_child(viewport)
	var quad:=TextureRect.new(); quad.texture=raw.get_texture(); quad.size=Vector2(raw.size)
	var shader:=Shader.new()
	shader.code="shader_type canvas_item; render_mode unshaded, blend_disabled; void fragment() { vec4 c = texture(TEXTURE, UV); COLOR = vec4(c.a > 0.00001 ? c.rgb / c.a : vec3(0.0), c.a); }"
	var material:=ShaderMaterial.new(); material.shader=shader; quad.material=material
	viewport.add_child(quad)
	RenderingServer.frame_post_draw.connect(func() -> void: ready=true,CONNECT_ONE_SHOT)

func draw(canvas: CanvasItem, cell: int) -> void:
	canvas.draw_texture_rect_region(viewport.get_texture(),Rect2(-32,-32,64,64),Rect2(cell*128,0,128,128))
