class_name VanguardArt
extends RefCounted
const Motion=preload("res://src/salvage/vanguard_motion.gd")
## Teal/steel bodies, brass impacts, mint support. Geometry reads from simulation.
static func draw(c, run) -> void:
	var v: Vanguard=run.vanguard
	if LevelMastery.enabled(run) and run.mastery.value("pet_damage")>0:
		var p: Vector2=run.kit.pet_position
		c.draw_circle(p,9,c.INK); c.draw_circle(p,6,c.TEAL if v.emp_left<=0 else c.PALE)
		c.draw_line(p+Vector2(-3,-1),p+Vector2(3,-1),c.CREAM,2,true)
	for trace in v.ghosts:
		if c.reduced_effects: continue
		c._box(Rect2(trace.pos-Vector2(16,17),Vector2(32,30)),Color(c.TEAL,trace.life*0.25),8,Color(c.PALE,trace.life*0.65),1)
		c.draw_line(trace.pos+Vector2(-7,-5),trace.pos+Vector2(7,-5),Color(c.CREAM,trace.life*0.45),2,true)
	if v.ghost:
		c.draw_arc(run.player,25,0,TAU,32,Color(c.TEAL,0.65),2,true)
		var travel: Vector2=run.velocity.normalized() if run.velocity.length()>1 else run.aim
		for i in range(1+run.kit.milestone("d")):
			var back: Vector2=run.player-travel*(22+i*9)
			c.draw_line(back-travel.orthogonal()*6,back-travel*7,c.GOLD,2,true)
			c.draw_line(back+travel.orthogonal()*6,back-travel*7,c.GOLD,2,true)
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
		var age: float=unit.get("duration",5 if unit.id=="recovery_totem" else 35)-unit.life
		var deployment: float=1-pow(1-clampf(age/0.24,0,1),3)
		for i in range(3):
			var d:=Vector2.from_angle(i*TAU/3+PI/2)
			var foot: Vector2=p+d*lerpf(11,25,deployment)
			c.draw_line(p+d*8,foot,c.INK,8,true); c.draw_line(p+d*8,foot,c.PALE,4,true)
			c.draw_circle(foot,3,c.GOLD)
		c.draw_circle(p+Vector2(0,3),19,c.INK)
		c.draw_circle(p,15,tint)
		c.draw_circle(p,9,c.INK)
		var grade: int=run.kit.milestone(unit.slot)
		# Upgrades change hardware silhouettes, not just tint or aura size.
		if grade>=1:
			for side in [-1,1]:
				var shoulder:=p+Vector2(side*18,-5)
				c._box(Rect2(shoulder-Vector2(5,9),Vector2(10,18)),c.INK,2,c.PALE,2)
				c.draw_line(shoulder-Vector2(0,5),shoulder+Vector2(0,5),tint,3,true)
		if grade>=2:
			c.draw_arc(p,29,0,TAU,32,Color(c.GOLD,0.6),2,true)
			for side in [-1,1]:
				var fin:=p+Vector2(side*14,-20)
				c.draw_line(p+Vector2(side*8,-8),fin,c.INK,7,true)
				c.draw_line(p+Vector2(side*8,-8),fin,c.GOLD,3,true)
				c.draw_circle(fin,3,c.CREAM)
		for i in range(grade+1):
			var spoke:=Vector2.from_angle(run.time*(0.7+grade*0.3)+i*TAU/(grade+1))
			c.draw_line(p+spoke*18,p+spoke*23,c.GOLD,3,true)
		if unit.id=="guard_bot":
			if SupportModules.enabled(run):
				c.draw_polyline(PackedVector2Array([p+Vector2(-12,-17),p+Vector2(-12,5),p+Vector2(12,5),p+Vector2(12,-17)]),c.GOLD,4,true)
				c.draw_circle(p,5,c.CREAM)
				c.draw_rect(Rect2(p+Vector2(-23,29),Vector2(46,5)),c.INK)
				c.draw_rect(Rect2(p+Vector2(-23,29),Vector2(46*maxf(0,unit.hp/unit.max_hp),5)),c.TEAL)
				continue
			var barrel: Vector2=unit.get("aim",Vector2.RIGHT)
			var cadence: float=0.8*Vanguard.GUN_INTERVAL[Vanguard.gun_rank(run)]/0.24
			c.draw_line(p,p+barrel*(24-5*clampf(unit.clock/cadence,0,1)),c.PALE,9,true)
			if grade>=1:
				for side in [-1,1]:
					var mount: Vector2=p+barrel.orthogonal()*side*6
					c.draw_line(mount,mount+barrel*(26+grade*3),c.INK,5,true)
					c.draw_line(mount,mount+barrel*(26+grade*3),c.PALE,2,true)
			if Vanguard.gun_rank(run)>=10 and unit.get("shots",0)>0 and int(unit.shots)%5==0 and unit.clock>cadence-0.08:
				c.draw_circle(p+barrel*25,4,c.GOLD)
			c.draw_rect(Rect2(p+Vector2(-20,27),Vector2(40,4)),c.INK)
			c.draw_rect(Rect2(p+Vector2(-20,27),Vector2(40*clampf(unit.hp/unit.max_hp,0,1),4)),tint)
		elif unit.id=="reserve_totem" or (SupportModules.enabled(run) and unit.id=="recovery_totem"):
			if LevelMastery.enabled(run):
				var inside: bool=run.player.distance_to(p)<=unit.radius
				var fill: float=clampf(unit.bank/(86*Vanguard.power(run.kit.effective_rank(unit.slot))),0,1)
				c.draw_rect(Rect2(p+Vector2(-24,29),Vector2(48,7)),c.INK)
				c.draw_rect(Rect2(p+Vector2(-23,30),Vector2(46*fill,5)),c.TEAL)
				if not inside:
					c.draw_line(p+Vector2(0,22),p+Vector2(0,12),c.TEAL,3,true)
					c.draw_line(p+Vector2(-4,17),p+Vector2(0,12),c.TEAL,2,true)
				elif unit.bank<=0.1:
					c.draw_line(p+Vector2(-7,23),p+Vector2(7,23),c.PALE,3,true)
			if unit.id=="recovery_totem":
				c.draw_polyline(PackedVector2Array([p+Vector2(4,-8),p+Vector2(-4,1),p+Vector2(3,1),p+Vector2(-3,8)]),c.CREAM,3,true)
			else:
				c.draw_line(p-Vector2(0,6),p+Vector2(0,6),c.CREAM,4,true)
				c.draw_line(p-Vector2(6,0),p+Vector2(6,0),c.CREAM,4,true)
			c.draw_arc(p,21,-PI/2,-PI/2+TAU*minf(1,unit.bank/(86*Vanguard.power(run.kit.effective_rank(unit.slot)))),32,tint,3,true)
			if unit.bank>0 and run.player.distance_to(p)<=unit.radius:
				var phase: float=fposmod(run.time*2,1)
				c.draw_circle(p.lerp(run.player,phase),3,tint)
				if not c.reduced_effects: c.draw_circle(p.lerp(run.player,fposmod(phase+0.5,1)),2,c.CREAM)
		else:
			c.draw_polyline(PackedVector2Array([p+Vector2(4,-8),p+Vector2(-4,1),p+Vector2(3,1),p+Vector2(-3,8)]),c.CREAM,3,true)
			c.draw_arc(p,23,-PI/2,-PI/2+TAU*unit.life/unit.get("duration",5.0),40,c.GOLD,2,true)
			if run.player.distance_to(p)<=unit.radius:
				for i in range(2):
					var d:=Vector2.from_angle(run.time*2+i*PI)
					c.draw_arc(run.player,23,d.angle(),d.angle()+0.7,12,tint,2,true)
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
			Motion.canister(c,p,h,reactor,progress,grade)
		elif effect.kind in ["detonation","slam_hit","blast"]:
			var family: String="reactor" if effect.kind=="detonation" else "slam" if effect.kind=="slam_hit" else effect.get("source","strike")
			Motion.burst(c,p,effect.radius,progress,family,effect.get("direction",Vector2.RIGHT),grade)
		elif effect.kind=="hammer":
			var direction: Vector2=effect.direction
			var half_angle: float=effect.get("angle",PI/4)
			var sweep: float=1-pow(1-clampf(progress/0.28,0,1),3)
			c.draw_arc(p,effect.radius,direction.angle()-half_angle,direction.angle()+half_angle,40,Color(c.GOLD,1-progress),4+grade,true)
			for i in range(0 if c.reduced_effects else grade):
				c.draw_arc(p,effect.radius*(0.88-i*0.12),direction.angle()-half_angle,direction.angle()+half_angle*sweep,40,Color(c.CREAM,(1-progress)*0.7),2,true)
			var recovery: float=clampf((progress-0.55)/0.45,0,1)
			hammer(c,p,direction.rotated(lerpf(-half_angle,half_angle,sweep)-recovery*0.25),1-progress*0.5,effect.radius/125.0,int(effect.get("rank",1)))
		elif effect.kind=="poof":
			Motion.phase(c,p,progress,grade)
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
