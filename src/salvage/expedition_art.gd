class_name ExpeditionArt
extends RefCounted
## Read-only, collision-aligned machinery. Motion comes from simulation lifetimes.
static func poly(c, points: Array, color: Color) -> void:
	var shape:=PackedVector2Array(points)
	c.draw_colored_polygon(shape,color)
	shape.append(shape[0]); c.draw_polyline(shape,c.INK,2,true)

static func ring(c, p: Vector2, radius: float, color: Color, width: float=2) -> void:
	c.draw_arc(p,maxf(1,radius),0,TAU,48,color,width,true)

static func chevron(c, p: Vector2, direction: Vector2, color: Color, size_value: float=6) -> void:
	var side:=direction.orthogonal()*size_value*0.6
	c.draw_polyline(PackedVector2Array([p-direction*size_value+side,p,p-direction*size_value-side]),color,2,true)

static func draw(c, run) -> void:
	var engine: BotSkillEngine=run.kit.extra
	for wall in engine.walls: barrier(c,wall)
	for f in engine.fields: field(c,f,run.time)
	for r in engine.recasts.values():
		if not r.has("pos"): continue
		var p: Vector2=r.pos
		ring(c,p,17,Color(c.TEAL,0.65))
		for i in range(4):
			var d:=Vector2.from_angle(i*PI/2)
			c.draw_line(p+d*9,p+d*16,c.GOLD,3,true)
		if r.id=="crosswire":
			c.draw_line(p-Vector2(0,6),p+Vector2(0,6),c.PALE,4,true)
		else: ring(c,p,7,c.PALE)
	for b in engine.blades: blade(c,b,run)
	for p in engine.plates:
		c.draw_set_transform(p,-0.35)
		poly(c,[Vector2(-8,-3),Vector2(7,-5),Vector2(9,3),Vector2(-6,5)],c.PALE)
		c.draw_line(Vector2(-3,-1),Vector2(4,-1),c.TEAL,3,true)
		c.draw_set_transform(Vector2.ZERO)
	for unit in engine.summons: construct(c,unit,run)
	modes(c,run)
	if run.exp!=null:
		for chest in run.exp.loot_chests:
			var p: Vector2=chest.pos
			c.draw_rect(Rect2(p+Vector2(-16,7),Vector2(32,7)),Color(c.INK,0.5))
			poly(c,[p+Vector2(-14,-9),p+Vector2(10,-12),p+Vector2(16,-6),p+Vector2(16,10),p+Vector2(-14,10)],c.GOLD)
			c.draw_line(p+Vector2(-12,-2),p+Vector2(14,-2),c.INK,2,true)
			c.draw_rect(Rect2(p-Vector2(3,3),Vector2(6,8)),c.CREAM)
			if not c.reduced_effects: ring(c,p,22+sin(run.time*3)*2,Color(c.GOLD,0.2),1)

static func barrier(c, wall: Dictionary) -> void:
	if wall.has("width"):
		var width: float=wall.width
		c.draw_line(wall.a,wall.b,c.INK,width*2+2,true)
		c.draw_circle(wall.a,width+1,c.INK); c.draw_circle(wall.b,width+1,c.INK)
		c.draw_line(wall.a,wall.b,Color("32434a"),width*2-4,true)
		c.draw_circle(wall.a,width-2,Color("32434a")); c.draw_circle(wall.b,width-2,Color("32434a"))
		c.draw_line(wall.a-Vector2(0,width*0.55),wall.b-Vector2(0,width*0.55),Color("50626a"),7,true)
		return
	var a: Vector2=wall.a
	var b: Vector2=wall.b
	var along: Vector2=(b-a).normalized()
	var normal:=along.orthogonal()
	var age: float=float(wall.get("duration",wall.life+1))-wall.life
	var build:=clampf(age/0.16,0,1) if not c.reduced_effects else 1.0
	c.draw_line(a,b,c.INK,18,true)
	c.draw_line(a,b,c.PALE,10,true)
	for i in range(1,int(a.distance_to(b)/28)):
		var p:=a+along*i*28
		c.draw_line(p-normal*4,p+normal*4,c.TEAL,4,true)
	c.draw_line(a-normal*3,b-normal*3,c.CREAM,2,true)
	for end in [a,b]:
		c.draw_circle(end,9,c.INK)
		c.draw_line(end-normal*7*build,end+normal*7*build,c.GOLD,7,true)
		c.draw_circle(end,2,c.CREAM)

static func field(c, f: Dictionary, time: float) -> void:
	var p: Vector2=f.pos
	var radius: float=f.radius
	var progress:=clampf(1-f.life/maxf(0.001,f.duration),0,1)
	var style: String=f.get("visual","")
	if f.kind=="cone":
		var d: Vector2=f.direction
		var fade:=1-pow(progress,3)
		var points:=PackedVector2Array([p])
		for i in range(25): points.append(p+d.rotated(lerpf(-PI*0.34,PI*0.34,i/24.0))*radius)
		c.draw_colored_polygon(points,Color(c.TEAL,0.10*fade))
		points.append(p); c.draw_polyline(points,Color(c.PALE,fade),1.5,true)
		if style=="sweep":
			c.draw_arc(p,radius*0.94,d.angle()-PI*0.34,d.angle()+PI*0.34,32,Color(c.GOLD,fade),5,true)
			var cutter:=d.rotated(lerpf(-PI*0.34,PI*0.34,1-pow(1-progress,3)))
			c.draw_line(p+cutter*radius*0.3,p+cutter*radius*0.95,Color(c.PALE,fade),9,true)
			c.draw_line(p+cutter*radius*0.6,p+cutter*radius*0.95,Color(c.CREAM,fade),3,true)
		else:
			for i in range(3 if c.reduced_effects else 5):
				var direction:=d.rotated((i-1 if c.reduced_effects else i-2)*0.28)
				var fraction: float=lerpf(0.9,0.23,progress) if style=="tractor" else lerpf(0.2,0.95,progress)
				chevron(c,p+direction*radius*fraction,-direction if style=="tractor" else direction,Color(c.GOLD,fade),9)
		return
	c.draw_circle(p,radius,Color(c.TEAL,0.035))
	ring(c,p,radius,Color(c.PALE,0.75),1.5)
	if f.kind=="gravity":
		c.draw_circle(p,15,c.INK); ring(c,p,18,c.PALE,3)
		var count:=3 if c.reduced_effects else 6
		for i in range(count):
			var angle: float=i*TAU/count+time*0.8
			var points:=PackedVector2Array()
			for step in range(13):
				var fraction:=step/12.0
				points.append(p+Vector2.from_angle(angle+fraction*1.7)*lerpf(radius*0.85,20,fraction))
			c.draw_polyline(points,Color(c.TEAL,0.5),2,true)
			var travel:=fmod(time*0.7+i*0.17,1)
			var mote:=p+Vector2.from_angle(angle+travel*1.7)*lerpf(radius*0.85,20,travel)
			c.draw_line(mote,mote+(p-mote).normalized()*7,c.GOLD,2,true)
		return
	# A countdown fills the exact ground boundary; only strike has a critical center.
	c.draw_arc(p,radius,-PI/2,-PI/2+TAU*progress,64,c.GOLD,3,true)
	if f.kind=="strike": ring(c,p,radius*0.35,Color(c.GOLD,0.8),1.5)
	for i in range(4):
		var d:=Vector2.from_angle(i*PI/2)
		c.draw_line(p+d*radius*0.9,p+d*radius,c.CREAM,3,true)
	if style in ["strike","artillery"] or f.kind=="strike":
		var core:=p-Vector2(0,120*pow(1-progress,2))
		if not c.reduced_effects: c.draw_line(core-Vector2(0,28),core,Color(c.GOLD,0.4),5,true)
		poly(c,[core+Vector2(0,12),core+Vector2(-9,-3),core+Vector2(-7,-16),core+Vector2(7,-16),core+Vector2(9,-3)],c.PALE)
		c.draw_line(core-Vector2(0,12),core+Vector2(0,4),c.GOLD,4,true)
	else:
		for i in range(3):
			var d:=Vector2.from_angle(i*TAU/3+PI/6)
			chevron(c,p+d*lerpf(radius*0.8,22,progress),-d,Color(c.GOLD,0.75),8)

static func blade(c, b: Dictionary, run) -> void:
	var end: Vector2=run.player if b.returning and not b.one_way else b.end
	var direction: Vector2=(end-Vector2(b.pos)).normalized()
	var width: float=b.width
	var accent: Color=c.GOLD if b.returning else c.TEAL
	if not c.reduced_effects:
		c.draw_line(b.pos-direction*width*3,b.pos,Color(accent,0.16),width,true)
		c.draw_line(b.pos-direction*width*2.2,b.pos,Color(c.PALE,0.4),2,true)
	c.draw_set_transform(b.pos,run.time*18)
	var s:=width/12.0
	poly(c,[Vector2(-12,-4)*s,Vector2(2,-12)*s,Vector2(4,-4)*s,Vector2(12,4)*s,Vector2(-2,12)*s,Vector2(-4,4)*s],c.PALE)
	c.draw_line(Vector2(-9,-3)*s,Vector2(2,-9)*s,c.CREAM,2,true)
	c.draw_circle(Vector2.ZERO,5*s,c.INK); c.draw_circle(Vector2.ZERO,3*s,accent)
	c.draw_set_transform(Vector2.ZERO)

static func construct(c, unit: Dictionary, run) -> void:
	var p: Vector2=unit.pos
	var duration: float=unit.get("duration",20)
	var age: float=duration-unit.life
	var deploy:=clampf(age/0.18,0,1) if not c.reduced_effects else 1.0
	var flash: float=unit.get("flash",0)
	c.draw_circle(p+Vector2(0,9),21,Color(c.INK,0.65))
	for i in range(3):
		var d:=Vector2.from_angle(i*TAU/3+PI/2)
		c.draw_line(p+d*9,p+d*21*deploy,c.INK,7,true)
		c.draw_line(p+d*9,p+d*20*deploy,c.PALE,4,true)
	c.draw_circle(p,15,c.INK); c.draw_circle(p,12,c.TEAL)
	c.draw_arc(p,12,PI,TAU,20,c.PALE,2,true)
	match unit.id:
		"forward_sentry":
			var d: Vector2=unit.direction
			var recoil: float=clampf(flash/0.16,0,1)*4 if not c.reduced_effects else 0
			c.draw_line(p-d*3,p+d*(26-recoil),c.INK,10,true)
			c.draw_line(p-d*3,p+d*(24-recoil),c.PALE,6,true)
			if flash>0: c.draw_line(p+d*26,p+d*33,Color(c.GOLD,flash/0.16),3,true)
		"pulse_sentry":
			ring(c,p,7,c.GOLD,3); c.draw_circle(p,2,c.CREAM)
			if flash>0:
				ring(c,p,125,Color(c.PALE,flash*0.8),1)
				ring(c,p,125*(1-flash/0.35),Color(c.TEAL,flash*1.8),2)
		"medic_sentry":
			c.draw_line(p-Vector2(6,0),p+Vector2(6,0),c.CREAM,4,true)
			c.draw_line(p-Vector2(0,6),p+Vector2(0,6),c.CREAM,4,true)
			ring(c,p,120,Color(c.TEAL,0.22),1)
			if run.player.distance_to(p)<120 and not c.reduced_effects:
				var at:=p.lerp(run.player,fmod(run.time,1))
				c.draw_line(at-Vector2(3,0),at+Vector2(3,0),c.PALE,2,true)
				c.draw_line(at-Vector2(0,3),at+Vector2(0,3),c.PALE,2,true)
		"mirror_sentry":
			var spread:=7+minf(flash,0.22)*16
			for side in [-1,1]:
				var at:=p+Vector2(side*spread,-2)
				c.draw_line(at-Vector2(0,7),at+Vector2(0,7),c.PALE,5,true)
				c.draw_circle(at,3,c.GOLD)
			c.draw_line(p-Vector2(spread,0),p+Vector2(spread,0),Color(c.CREAM,0.6),1,true)
		"hook_sentry":
			var tip: Vector2=p+Vector2(unit.direction)*19
			c.draw_line(p,tip,c.PALE,5,true)
			c.draw_arc(tip,6,-PI,PI/2,18,c.GOLD,3,true)
		"crawler":
			for side in [-1,1]:
				c.draw_line(p+Vector2(side*16,-10),p+Vector2(side*16,10),c.PALE,6,true)
				if not c.reduced_effects:
					for i in range(3):
						var y:=fmod(run.time*24+i*7,21)-10
						c.draw_line(p+Vector2(side*16-3,y),p+Vector2(side*16+3,y),c.INK,2,true)
			c.draw_circle(p,5,c.GOLD)
	c.draw_arc(p,25,-PI/2,-PI/2+TAU*clampf(unit.life/duration,0,1),32,Color(c.PALE,0.5),1,true)

static func modes(c, run) -> void:
	var engine: BotSkillEngine=run.kit.extra
	var p: Vector2=run.player
	if engine.repair_left>0:
		for side in [-1,1]:
			var x: float=side*(29+sin(run.time*7)*2)
			c.draw_polyline(PackedVector2Array([p+Vector2(x,-15),p+Vector2(x*1.15,-15),p+Vector2(x*1.15,15),p+Vector2(x,15)]),c.PALE,3,true)
		c.draw_arc(p,40,-PI/2,-PI/2+TAU*engine.repair_left/3,40,c.TEAL,2,true)
	if engine.roll_left>0:
		var angle: float=engine.roll_angle
		for side in [-1,1]:
			c.draw_arc(p,30,angle+side*PI/2-0.55,angle+side*PI/2+0.55,20,c.PALE,5,true)
		for i in range(1 if c.reduced_effects else 3):
			var d:=Vector2.from_angle(angle+PI)
			chevron(c,p+d*(34+i*13),-d,Color(c.GOLD,0.6-i*0.15),7)
	if engine.decoy_left>0:
		var ghost: Vector2=engine.decoy_position
		c.draw_rect(Rect2(ghost-Vector2(16,19),Vector2(32,32)),Color(c.TEAL,engine.decoy_left*0.15))
		ring(c,ghost,22,Color(c.PALE,engine.decoy_left*0.4),1)
	if engine.empowered or engine.hop_ready:
		for i in range(3): chevron(c,p+Vector2(-8+i*8,28),Vector2.UP,c.GOLD,4)
	for enemy in run.enemies:
		if not engine.hits.has(enemy.id) or enemy.dead: continue
		for i in range(int(engine.hits[enemy.id].count)):
			c.draw_circle(Vector2(enemy.pos)+Vector2(-4+i*8,-enemy.radius-8),2.5,c.GOLD)
