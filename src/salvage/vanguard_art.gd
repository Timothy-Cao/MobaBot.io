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
		for i in range(1+run.kit.milestone("d")):
			var back: Vector2=run.player-run.aim*(22+i*9)
			c.draw_line(back-run.aim.orthogonal()*6,back-run.aim*7,c.GOLD,2,true)
			c.draw_line(back+run.aim.orthogonal()*6,back-run.aim*7,c.GOLD,2,true)
	if v.shield>0:
		c.draw_arc(run.player,31,0,TAU,40,c.GOLD,3,true)
		for i in range(4):
			var p: Vector2=run.player+Vector2.from_angle(i*PI/2)*34
			c.draw_circle(p,3,c.CREAM)
	elif v.touch_guard>0:
		c.draw_arc(run.player,25,v.slam_direction.angle()-1.0,v.slam_direction.angle()+1.0,20,c.PALE,3,true)
	if v.slam_left>0:
		var d: Vector2=v.slam_direction
		# A steel shoulder/plow leads the chassis: this reads as a body attack,
		# not a second blink. This rim is cosmetic, not extra collision reach.
		var front: Vector2=run.player+d*7
		c.draw_arc(front,29,d.angle()-1.05,d.angle()+1.05,24,c.INK,11,true)
		c.draw_arc(front,29,d.angle()-1.05,d.angle()+1.05,24,c.PALE,7,true)
		c.draw_arc(front,32,d.angle()-0.7,d.angle()+0.7,20,c.GOLD,3,true)
		for i in range(run.kit.milestone("e")):
			c.draw_arc(front,24-i*5,d.angle()-0.8,d.angle()+0.8,20,c.CREAM,2,true)
		for i in range(2 if c.reduced_effects else 4):
			var side: Vector2=d.orthogonal()*(12+i*3)
			c.draw_line(run.player-d*(15+i*9)+side,run.player-d*(40+i*10)+side,Color(c.PALE,0.65-i*0.12),2,true)
	if v.hammer>=0:
		var d: Vector2=v.hammer_direction.rotated(lerpf(-0.65,-PI*0.55,clampf(1-v.hammer/0.20,0,1)))
		hammer(c,run.player,d,0.8,run.attacks.attack_range(run)/125.0,Vanguard.hammer_rank(run))
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
		var grade: int=run.kit.milestone(unit.slot)
		for i in range(grade+1):
			var spoke:=Vector2.from_angle(run.time*(0.7+grade*0.3)+i*TAU/(grade+1))
			c.draw_line(p+spoke*18,p+spoke*23,c.GOLD,3,true)
		if unit.id=="guard_bot":
			c.draw_line(p,p+Vector2(24-5*clampf(unit.clock/0.8,0,1),0),c.PALE,9,true)
			c.draw_rect(Rect2(p+Vector2(-20,27),Vector2(40,4)),c.INK)
			c.draw_rect(Rect2(p+Vector2(-20,27),Vector2(40*clampf(unit.hp/unit.max_hp,0,1),4)),tint)
		elif unit.id=="reserve_totem":
			c.draw_line(p-Vector2(0,6),p+Vector2(0,6),c.CREAM,4,true)
			c.draw_line(p-Vector2(6,0),p+Vector2(6,0),c.CREAM,4,true)
			c.draw_arc(p,21,-PI/2,-PI/2+TAU*minf(1,unit.bank/(86*Vanguard.power(run.kit.effective_rank(unit.slot)))),32,tint,3,true)
		else:
			c.draw_polyline(PackedVector2Array([p+Vector2(4,-8),p+Vector2(-4,1),p+Vector2(3,1),p+Vector2(-3,8)]),c.CREAM,3,true)
			c.draw_arc(p,23,-PI/2,-PI/2+TAU*unit.life/5,40,c.GOLD,2,true)
	for effect in v.impacts:
		var p: Vector2=effect.pos
		var progress: float=clampf(1-effect.life/effect.duration,0,1)
		var grade: int=int(effect.get("rank",1))/5
		if effect.kind in ["strike","reactor"]:
			var radius: float=effect.radius
			c.draw_circle(p,radius,Color(c.TEAL,0.055))
			c.draw_arc(p,radius,0,TAU,64,c.PALE,1.5,true)
			c.draw_arc(p,radius,-PI/2,-PI/2+TAU*progress,64,c.GOLD,3,true)
			if effect.kind=="strike": c.draw_arc(p,radius*0.4,0,TAU,40,c.GOLD,1,true)
			var reactor: bool=effect.kind=="reactor"
			var h: float=(1-progress*progress)*(165 if reactor else 95)
			var scale: float=1.8 if reactor else 1.0
			c.draw_set_transform(p+Vector2(0,-h),0,Vector2.ONE*scale)
			c.draw_rect(Rect2(-11,-19,22,34),c.INK)
			c.draw_rect(Rect2(-8,-16,16,28),c.TEAL)
			c.draw_rect(Rect2(-11,-10,5,21),c.PALE)
			c.draw_rect(Rect2(6,-10,5,21),c.PALE)
			c.draw_rect(Rect2(-5,-8,10,13),c.GOLD)
			for i in range(grade):
				c.draw_line(Vector2(-13,-13+i*10),Vector2(13,-13+i*10),c.CREAM,2,true)
			c.draw_line(Vector2(0,-21),Vector2(0,-40-progress*20),c.GOLD,5,true)
			c.draw_line(Vector2(0,-21),Vector2(0,-34),c.CREAM,2,true)
			c.draw_set_transform(Vector2.ZERO)
		elif effect.kind in ["detonation","slam_hit"]:
			var radius: float=effect.radius
			var expansion: float=1-pow(1-progress,3)
			var opacity: float=1-progress
			if effect.kind=="detonation":
				var flare:=PackedVector2Array()
				for i in range(16):
					var reach: float=radius*(0.48 if i%2==0 else 0.18)*(1-progress)
					flare.append(p+Vector2.from_angle(i*TAU/16)*reach)
				c.draw_colored_polygon(flare,Color(c.GOLD,opacity*0.5))
				c.draw_circle(p,radius*0.12*(1-progress),Color(c.CREAM,opacity*0.8))
			c.draw_arc(p,radius*expansion,0,TAU,64,Color(c.GOLD,opacity),5 if effect.kind=="detonation" else 4,true)
			c.draw_arc(p,radius*expansion*0.82,0,TAU,48,Color(c.CREAM,opacity*0.85),2,true)
			for i in range(grade):
				c.draw_arc(p,radius*expansion*(0.60-i*0.15),progress*PI,-progress*PI+TAU,40,Color(c.TEAL,opacity*0.7),3,true)
			# Brief, separated blast petals leave incoming threats visible.
			for i in range(6 if c.reduced_effects else 10):
				var d:=Vector2.from_angle(i*TAU/(6 if c.reduced_effects else 10))
				var center: Vector2=p+d*radius*expansion*0.55
				var bloom: float=radius*0.16*sin(progress*PI)
				c.draw_arc(center,bloom,0,TAU,16,Color(c.PALE,opacity*0.55),2,true)
				c.draw_line(p+d*radius*expansion*0.65,p+d*radius*expansion*0.9,Color(c.GOLD,opacity),3,true)
			if not c.reduced_effects:
				for i in range(8):
					var d:=Vector2.from_angle(i*TAU/8+0.25)
					var shard: Vector2=p+d*radius*progress*0.8
					c.draw_line(shard,shard+d*7,Color(c.PALE,opacity),3,true)
		elif effect.kind=="hammer":
			var direction: Vector2=effect.direction
			var half_angle: float=effect.get("angle",PI/4)
			var sweep: float=1-pow(1-progress,3)
			c.draw_arc(p,effect.radius,direction.angle()-half_angle,direction.angle()+half_angle,40,Color(c.GOLD,1-progress),4+grade,true)
			for i in range(grade):
				c.draw_arc(p,effect.radius*(0.88-i*0.12),direction.angle()-half_angle,direction.angle()+half_angle*sweep,40,Color(c.CREAM,(1-progress)*0.7),2,true)
			hammer(c,p,direction.rotated(lerpf(-half_angle,half_angle,sweep)),1-progress*0.5,effect.radius/125.0,int(effect.get("rank",1)))
		else:
			var color: Color=c.PALE if effect.kind=="poof" else c.GOLD
			c.draw_arc(p,effect.radius*(0.25+progress*0.75),0,TAU,40,Color(color,1-progress),3,true)
			for i in range(grade):
				c.draw_arc(p,effect.radius*(0.20+progress*0.65-i*0.08),0,TAU,32,Color(c.TEAL,1-progress),2,true)
			if not c.reduced_effects:
				for i in range(6):
					var d:=Vector2.from_angle(i*TAU/6)
					c.draw_line(p+d*effect.radius*progress*0.7,p+d*effect.radius*progress,Color(color,1-progress),2,true)

static func hammer(c, point: Vector2, direction: Vector2, opacity: float, size_scale: float=1.0, rank_value: int=1) -> void:
	c.draw_set_transform(point,direction.angle(),Vector2.ONE*size_scale)
	c.draw_line(Vector2(12,0),Vector2(94,0),Color(c.INK,opacity),11,true)
	c.draw_line(Vector2(12,0),Vector2(94,0),Color(c.PALE,opacity),6,true)
	c.draw_rect(Rect2(88,-20,30,40),Color(c.INK,opacity))
	c.draw_rect(Rect2(91,-17,24,34),Color(c.TEAL,opacity))
	c.draw_rect(Rect2(107,-17,8,34),Color(c.PALE,opacity))
	c.draw_line(Vector2(93,-13),Vector2(103,-13),Color(c.GOLD,opacity),3,true)
	for i in range(int(rank_value/5)):
		c.draw_line(Vector2(94,0+i*8),Vector2(113,0+i*8),Color(c.CREAM,opacity),3,true)
	if rank_value>=10:
		c.draw_line(Vector2(26,0),Vector2(85,0),Color(c.GOLD,opacity),2,true)
	c.draw_set_transform(Vector2.ZERO)
