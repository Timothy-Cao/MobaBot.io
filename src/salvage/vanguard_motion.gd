extends RefCounted
## Original pose-based VFX. Pure presentation: no RNG, actors, timers or saves mutated.

static func pose(progress: float, count: int=8) -> float:
	return floorf(clampf(progress,0,1)*float(count-1))/float(count-1)

static func shard(c, center: Vector2, direction: Vector2, length: float, width: float, tint: Color) -> void:
	if length<0.25 or width<0.25 or direction.length_squared()<0.0001: return
	direction=direction.normalized()
	var side:=direction.orthogonal()*width
	var points:=PackedVector2Array([center-direction*length*0.25,center+side,center+direction*length,center-side])
	c.draw_colored_polygon(points,tint)

static func burst(c, point: Vector2, radius: float, progress: float, family: String, direction: Vector2=Vector2.RIGHT, grade: int=0) -> void:
	if progress>=1: return
	var t:=pose(progress)
	var spread: float=1-pow(1-t,3)
	var alpha: float=1-progress
	var support: bool=family in ["bulwark","reserve"]
	var tint: Color=Color("92d1ac") if support else c.GOLD
	# Always retain the true damage boundary; lobes and debris stay within it.
	c.draw_arc(point,radius,0,TAU,64,Color(tint,alpha*0.28),1,true)
	c.draw_arc(point,radius*(0.16+spread*0.84),0,TAU,64,Color(tint,alpha),3 if support else 4,true)
	if support:
		for i in range(4):
			var d:=Vector2.from_angle(i*PI/2)
			c.draw_line(point+d*radius*spread*0.7,point+d*radius*spread,Color(tint,alpha),3,true)
		return
	var count: int=4 if family=="strike" else 8 if family=="reactor" else 6
	for i in range(count):
		var angle: float=i*TAU/count+PI/4
		if family=="slam": angle=direction.angle()+lerpf(-1.05,1.05,float(i)/float(count-1))
		var d:=Vector2.from_angle(angle)
		var center: Vector2=point+d*radius*(0.14+spread*0.54)
		var length: float=radius*(0.18 if family=="reactor" else 0.23)*alpha
		shard(c,center,d,length,radius*0.05*alpha,Color(tint,alpha))
		if not c.reduced_effects:
			shard(c,center-d*radius*0.03,d,length*0.62,radius*0.02*alpha,Color(c.CREAM,alpha))
	# One brief, small contact core, never an opaque full damage disc.
	if progress<0.25:
		shard(c,point,Vector2.UP,radius*0.25*(1-progress*3),radius*0.16*(1-progress*3),Color(c.CREAM,0.55 if c.reduced_effects else 0.85))
	if family=="reactor" and not c.reduced_effects:
		for i in range(5+grade):
			var d:=Vector2.from_angle(i*TAU/(5+grade)+0.3)
			var p: Vector2=point+d*radius*spread*0.5
			c.draw_arc(p,radius*0.09*(1-progress),0,TAU,16,Color(c.PALE,alpha*0.45),3,true)

static func canister(c, point: Vector2, height: float, reactor: bool, progress: float, grade: int) -> void:
	var size: float=1.65 if reactor else 1.0
	var unfold: float=clampf(progress*3,0,1)
	c.draw_set_transform(point+Vector2(0,-height),0,Vector2.ONE*size)
	if reactor:
		# A reactor is a wide caged drum, not a scaled-up W projectile.
		c.draw_rect(Rect2(-17,-20,34,34),c.INK)
		c.draw_rect(Rect2(-14,-17,28,28),c.TEAL)
		for x in [-1,1]:
			c.draw_line(Vector2(x*12,-18),Vector2(x*(16+unfold*6),8),c.PALE,5,true)
		c.draw_circle(Vector2(0,-3),10,c.INK)
		c.draw_circle(Vector2(0,-3),7,c.GOLD)
		c.draw_line(Vector2(-13,13),Vector2(13,13),c.PALE,4,true)
	else:
		c.draw_colored_polygon(PackedVector2Array([Vector2(-9,-18),Vector2(9,-18),Vector2(9,5),Vector2(0,18),Vector2(-9,5)]),c.PALE)
		c.draw_rect(Rect2(-6,-15,12,21),c.TEAL)
		c.draw_line(Vector2(-11,-9),Vector2(-11,5),c.INK,4,true)
		c.draw_line(Vector2(11,-9),Vector2(11,5),c.INK,4,true)
		c.draw_rect(Rect2(-4,-9,8,8),c.GOLD)
	for i in range(grade): c.draw_line(Vector2(-6,-14+i*6),Vector2(6,-14+i*6),c.CREAM,2,true)
	if not c.reduced_effects:
		shard(c,Vector2(0,-22),Vector2.UP,15+progress*20,4,c.GOLD)
	c.draw_set_transform(Vector2.ZERO)

static func phase(c, point: Vector2, progress: float, grade: int) -> void:
	var t:=pose(progress,6)
	var width: float=18*(1-t)+2
	var height: float=18+14*t
	var color:=Color(c.TEAL,1-progress)
	for side in [-1,1]:
		c.draw_polyline(PackedVector2Array([point+Vector2(side*width,-height),point+Vector2(side*(width+6),-height*0.5),point+Vector2(side*(width+6),height*0.5),point+Vector2(side*width,height)]),color,3,true)
	if not c.reduced_effects:
		for i in range(2+grade):
			c.draw_line(point+Vector2(-width,-8+i*8),point+Vector2(width,-8+i*8),Color(c.CREAM,(1-progress)*0.65),1,true)
