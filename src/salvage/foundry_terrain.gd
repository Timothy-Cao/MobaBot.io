class_name FoundryTerrain
extends RefCounted
## Presentation only. The capsule footing remains the exact solid silhouette.
static func draw(c, wall: Dictionary) -> void:
	var a: Vector2=wall.a; var b: Vector2=wall.b; var w: float=wall.width
	var bounds:=Rect2(a,Vector2.ZERO).expand(b).grow(w+20)
	if not bounds.intersects(Rect2(c.model.camera_origin(),c.model.view_size).grow(80)): return
	var length:=a.distance_to(b); var center: Vector2=(a+b)*0.5
	c.draw_set_transform(center,(b-a).angle())
	var left:=Vector2(-length*0.5,0); var right:=Vector2(length*0.5,0)
	# Low shadow, exact dark footing, raised inset top. No extra collision.
	for layer in range(3):
		var offset:=Vector2(0,9 if layer==0 else 0)
		var radius: float=w+(3 if layer==0 else 0 if layer==1 else -5)
		var color:=Color("07151b77") if layer==0 else Color("0b1d25") if layer==1 else Color("4a6267")
		c.draw_line(left+offset,right+offset,color,radius*2,true)
		c.draw_circle(left+offset,radius,color); c.draw_circle(right+offset,radius,color)
	c.draw_line(left-Vector2(0,w-7),right-Vector2(0,w-7),Color("819087"),3,true)
	c.draw_line(left+Vector2(0,w-7),right+Vector2(0,w-7),Color("263c45"),6,true)
	var type:=int(wall.get("factory_theme",absi(int(wall.get("uid",0)))%3))
	if type==0:
		# Conveyor: inset belt, rollers and two brass drive housings.
		c.draw_rect(Rect2(-length/2,-w*0.6,length,w*1.2),Color("152a33"))
		for x in range(int(-length/2)+12,int(length/2),20):
			c.draw_line(Vector2(x,-w*0.49),Vector2(x,w*0.49),Color("62767a"),7,true)
			c.draw_line(Vector2(x+3,-w*0.49),Vector2(x+3,w*0.49),Color("2c424b"),3,true)
		for end in [left,right]:
			c.draw_circle(end,w*0.48,Color("1b3038"))
			c.draw_arc(end,w*0.39,0,TAU,24,Color("b4965c"),5,true)
			c.draw_circle(end,7,Color("6d8080"))
	elif type==1:
		# Cooling unit: circular reservoirs joined by recessed pipe work.
		for y in [-w*0.25,w*0.25]:
			c.draw_line(left+Vector2(0,y),right+Vector2(0,y),Color("233c45"),14,true)
			c.draw_line(left+Vector2(0,y-3),right+Vector2(0,y-3),Color("76928f"),4,true)
		for end in [left,right]:
			c.draw_circle(end,w*0.72,Color("1b313b")); c.draw_circle(end-Vector2(0,3),w*0.62,Color("58817f"))
			c.draw_arc(end-Vector2(0,3),w*0.50,PI,TAU,24,Color("a0b5a5"),3,true)
			for i in range(4):
				var d:=Vector2.from_angle(i*PI/2)*w*0.30
				c.draw_line(end-d,end+d,Color("29474f"),5,true)
			c.draw_circle(end,7,Color("bba572"))
	else:
		# Press bed: cross-braces, piston housings and a dark work surface.
		c.draw_rect(Rect2(-length/2,-w*0.55,length,w*1.1),Color("263b44"))
		for x in [-length*0.38,0.0,length*0.38]:
			c.draw_line(Vector2(x,-w*0.65),Vector2(x,w*0.65),Color("9c8b66"),14,true)
			c.draw_line(Vector2(x-3,-w*0.65),Vector2(x-3,w*0.65),Color("c0ad7f"),3,true)
		for end in [left,right]:
			c.draw_circle(end,w*0.40,Color("20343e")); c.draw_circle(end,w*0.27,Color("708489"))
	# Repeated maintenance strip and fasteners tie all three props together.
	for i in range(3):
		var x: float=-18+i*12
		c.draw_line(Vector2(x,w-14),Vector2(x+6,w-20),Color("c0a36b"),4,true)
	for end in [left,right]:
		for side in [-1,1]: c.draw_circle(end+Vector2(0,side*(w-13)),3,Color("bec3ac"))
	c.draw_set_transform(Vector2.ZERO)
