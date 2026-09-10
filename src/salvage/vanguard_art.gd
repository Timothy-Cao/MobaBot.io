class_name VanguardArt
extends RefCounted
## Teal/steel bodies, brass impacts, mint support. Geometry reads from simulation.
static func draw(c, run) -> void:
	var v: Vanguard=run.vanguard
	for trace in v.ghosts:
		if c.reduced_effects: continue
		c.draw_rect(Rect2(trace.pos-Vector2(15,15),Vector2(30,30)),Color(c.PALE,trace.life*0.6),false,2)
	if v.ghost:
		c.draw_arc(run.player,25,0,TAU,32,Color(c.TEAL,0.65),2,true)
	if v.shield>0:
		c.draw_arc(run.player,31,0,TAU,40,c.GOLD,3,true)
		for i in range(4):
			var p: Vector2=run.player+Vector2.from_angle(i*PI/2)*34
			c.draw_circle(p,3,c.CREAM)
	elif v.touch_guard>0:
		c.draw_arc(run.player,25,v.slam_direction.angle()-1.0,v.slam_direction.angle()+1.0,20,c.PALE,3,true)
	if v.slam_left>0:
		var d: Vector2=v.slam_direction
		for i in range(2 if c.reduced_effects else 4):
			var side: Vector2=d.orthogonal()*(12+i*3)
			c.draw_line(run.player-d*(15+i*9)+side,run.player-d*(40+i*10)+side,Color(c.PALE,0.65-i*0.12),2,true)
	if v.hammer>=0:
		var d: Vector2=v.hammer_direction.rotated(-PI*0.55)
		hammer(c,run.player,d,0.8,run.attacks.attack_range(run)/125.0)
	for unit in v.constructs:
		var p: Vector2=unit.pos
		var tint: Color=Color("92d1ac") if unit.id=="reserve_totem" else Color("72b9de") if unit.id=="recovery_totem" else c.TEAL
		c.draw_arc(p,unit.radius,0,TAU,64,Color(tint,0.42),1.3,true)
		c.draw_circle(p,unit.radius,Color(tint,0.035))
		for i in range(3):
			var d:=Vector2.from_angle(i*TAU/3+PI/2)
			c.draw_line(p+d*8,p+d*25,c.INK,8,true); c.draw_line(p+d*8,p+d*25,c.PALE,4,true)
		c.draw_circle(p+Vector2(0,3),19,c.INK)
		c.draw_circle(p,15,tint)
		c.draw_circle(p,9,c.INK)
		if unit.id=="guard_bot":
			c.draw_line(p,p+Vector2(24,0),c.PALE,9,true)
			c.draw_rect(Rect2(p+Vector2(-20,27),Vector2(40,4)),c.INK)
			c.draw_rect(Rect2(p+Vector2(-20,27),Vector2(40*clampf(unit.hp/unit.max_hp,0,1),4)),tint)
		elif unit.id=="reserve_totem":
			c.draw_line(p-Vector2(0,6),p+Vector2(0,6),c.CREAM,4,true)
			c.draw_line(p-Vector2(6,0),p+Vector2(6,0),c.CREAM,4,true)
			c.draw_arc(p,21,-PI/2,-PI/2+TAU*minf(1,unit.bank/100),32,tint,3,true)
		else:
			c.draw_polyline(PackedVector2Array([p+Vector2(4,-8),p+Vector2(-4,1),p+Vector2(3,1),p+Vector2(-3,8)]),c.CREAM,3,true)
			c.draw_arc(p,23,-PI/2,-PI/2+TAU*unit.life/5,40,c.GOLD,2,true)
	for effect in v.impacts:
		var p: Vector2=effect.pos
		var progress: float=clampf(1-effect.life/effect.duration,0,1)
		if effect.kind in ["strike","reactor"]:
			var radius: float=effect.radius
			c.draw_circle(p,radius,Color(c.TEAL,0.055))
			c.draw_arc(p,radius,0,TAU,64,c.PALE,1.5,true)
			c.draw_arc(p,radius,-PI/2,-PI/2+TAU*progress,64,c.GOLD,3,true)
			if effect.kind=="strike": c.draw_arc(p,radius*0.4,0,TAU,40,c.GOLD,1,true)
			var h: float=(1-progress)*95
			c.draw_rect(Rect2(p+Vector2(-8,-h-15),Vector2(16,25)),c.INK)
			c.draw_rect(Rect2(p+Vector2(-5,-h-13),Vector2(10,20)),c.PALE)
			c.draw_line(p+Vector2(0,-h-21),p+Vector2(0,-h-40),c.GOLD,4,true)
		elif effect.kind=="hammer":
			var direction: Vector2=effect.direction
			c.draw_arc(p,effect.radius,direction.angle()-PI/4,direction.angle()+PI/4,30,Color(c.GOLD,1-progress),5,true)
			hammer(c,p,direction.rotated(lerpf(-PI/4,PI/4,progress)),1-progress*0.5,effect.radius/125.0)
		else:
			var color: Color=c.PALE if effect.kind=="poof" else c.GOLD
			c.draw_arc(p,effect.radius*(0.25+progress*0.75),0,TAU,40,Color(color,1-progress),3,true)
			if not c.reduced_effects:
				for i in range(6):
					var d:=Vector2.from_angle(i*TAU/6)
					c.draw_line(p+d*effect.radius*progress*0.7,p+d*effect.radius*progress,Color(color,1-progress),2,true)

static func hammer(c, point: Vector2, direction: Vector2, opacity: float, size_scale: float=1.0) -> void:
	c.draw_set_transform(point,direction.angle(),Vector2.ONE*size_scale)
	c.draw_line(Vector2(12,0),Vector2(94,0),Color(c.INK,opacity),11,true)
	c.draw_line(Vector2(12,0),Vector2(94,0),Color(c.PALE,opacity),6,true)
	c.draw_rect(Rect2(88,-20,30,40),Color(c.INK,opacity))
	c.draw_rect(Rect2(91,-17,24,34),Color(c.TEAL,opacity))
	c.draw_rect(Rect2(107,-17,8,34),Color(c.PALE,opacity))
	c.draw_line(Vector2(93,-13),Vector2(103,-13),Color(c.GOLD,opacity),3,true)
	c.draw_set_transform(Vector2.ZERO)
