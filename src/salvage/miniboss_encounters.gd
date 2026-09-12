class_name MinibossEncounters
extends RefCounted
const TYPES:=["drifter","bulwark"]
static func setup(e: Dictionary, type: String) -> void:
	e.miniboss=type; e.radius=34.0; e.hp=650.0 if type=="drifter" else 800.0; e.max_hp=e.hp
	e.phase="approach"; e.clock=0.8; e.sequence=0; e.attack="ram"; e.target=e.pos
static func step(run, e: Dictionary, delta: float) -> void:
	e.clock-=delta
	var offset: Vector2=run.player-e.pos
	if e.phase=="approach":
		ReviewEnemies.move(run,e,(run.kit.extra.route(e.pos,run.player,e.radius)-Vector2(e.pos)).normalized(),200,delta)
		if offset.length()<600 and e.clock<=0:
			e.attack="ram" if e.miniboss=="drifter" else "spin" if e.sequence%2==0 else "ring"
			e.sequence+=1; e.phase="telegraph"; e.clock=0.85 if e.attack!="ring" else 1.0
			e.dir=offset.normalized(); e.target=ReviewEnemies.destination(run,e.pos,e.dir,minf(350,offset.length()),e.radius)
			run.emit_event("boss_windup",e.pos)
	elif e.phase=="telegraph" and e.clock<=0:
		e.phase="attack"; e.clock=0.85 if e.attack=="ram" else 0.38 if e.attack=="spin" else 0.15; e.struck=false
	elif e.phase=="attack":
		if e.attack=="ram":
			var turn: float=clampf(Vector2(e.dir).angle_to(offset),-0.45*delta,0.45*delta)
			e.dir=Vector2(e.dir).rotated(turn)
			var before: Vector2=e.pos
			ReviewEnemies.move(run,e,e.dir,820,minf(delta,maxf(0,e.clock+delta)))
			if Geometry2D.get_closest_point_to_segment(run.player,before,e.pos).distance_to(run.player)<e.radius+12:
				if not e.struck: run.hurt_player(e.pos,"Drift rammer charge",3); e.struck=true
			if Vector2(e.pos).distance_to(before)<820*delta*0.4: e.clock=0
		elif e.attack=="spin":
			var remaining: Vector2=Vector2(e.target)-Vector2(e.pos)
			ReviewEnemies.move(run,e,remaining,950,minf(delta,remaining.length()/950))
			if e.clock<=0 and not e.struck:
				if run.player.distance_to(e.pos)<142: run.hurt_player(e.pos,"Bulwark spin",3,"ground")
				e.struck=true; e.spin_fx=0.35; run.emit_event("boss_phase",e.pos)
		elif not e.struck:
			e.struck=true; e.ring_fx=0.35
			var distance: float=run.player.distance_to(e.pos)
			if distance>=73 and distance<=222: run.hurt_player(e.pos,"Bulwark outer shockwave",3,"ground")
			for i in range(16):
				if i%8<2: continue
				var heading:=Vector2.from_angle(i*TAU/16+Vector2(e.dir).angle())
				run._add_projectile(Vector2(e.pos)+heading*220,heading*250,1,"hostile",0,2.0)
		if e.clock<=0: e.phase="recover"; e.clock=1.8
	elif e.phase=="recover" and e.clock<=0: e.phase="approach"; e.clock=0.4
	e.spin_fx=maxf(0,float(e.get("spin_fx",0))-delta); e.ring_fx=maxf(0,float(e.get("ring_fx",0))-delta)
static func damage_factor(e: Dictionary) -> float:
	if e.get("miniboss","")!="bulwark": return 1.0
	return 1.35 if e.phase=="recover" else 0.55
static func draw(art, e: Dictionary) -> void:
	var p: Vector2=Vector2(e.pos)+art.frame_offset
	var open: bool=e.phase=="recover"
	var moving: bool=e.phase in ["approach","attack"]
	var motion: float=0 if art.reduced_effects or not moving else fmod(art.model.time*40,10)
	art.draw_circle(p+Vector2(0,8),37,Color(art.INK,0.45))
	if e.miniboss=="drifter":
		var heading: Vector2=Vector2(e.dir) if e.phase!="approach" else (art.model.player-Vector2(e.pos)).normalized()
		art.draw_set_transform(p,heading.angle()+PI/2)
		for side in [-1,1]:
			art._box(Rect2(side*27-8,-24,16,58),art.INK,3)
			for i in range(5):
				var y: float=-20+i*10+motion
				art.draw_line(Vector2(side*27-5,y),Vector2(side*27+5,y),art.PALE,3,true)
		ExpeditionArt.poly(art,[Vector2(-20,27),Vector2(-22,-17),Vector2(0,-33),Vector2(22,-17),Vector2(20,27)],art.GOLD)
		# The broad plow is separate from its narrower tracked chassis.
		ExpeditionArt.poly(art,[Vector2(-30,-18),Vector2(0,-42),Vector2(30,-18),Vector2(21,-12),Vector2(0,-27),Vector2(-21,-12)],Color("d3c5a1"))
		art._box(Rect2(-14,-9,28,15),art.INK,2)
		art.draw_line(Vector2(-9,-2),Vector2(9,-2),art.CORAL,3,true)
		for x in [-10,10]:
			art.draw_line(Vector2(x,12),Vector2(x,24),Color("745937"),4,true)
			if open: art.draw_line(Vector2(x,28),Vector2(x,36),Color("b6c3b0"),2,true)
	else:
		art.draw_set_transform(p)
		var spread: float=7 if open else 0
		for side in [-1,1]:
			var x: float=side*(26+spread)
			art._box(Rect2(x-10,-27,20,44),Color("526e79"),4,art.INK,3)
			art.draw_line(Vector2(x-5,-21),Vector2(x+5,-21),art.PALE,3,true)
			art._box(Rect2(x-8,18,16,13),art.INK,2)
		art._box(Rect2(-21,-22,42,48),Color("8ba2a5"),5,art.INK,3)
		art.draw_circle(Vector2(0,6),18,art.INK)
		var rotor: float=0 if art.reduced_effects else art.model.time*(12 if e.phase=="attack" else 1.5)
		for i in range(4):
			var d:=Vector2.from_angle(rotor+i*PI/2)
			art.draw_line(Vector2(0,6)+d*6,Vector2(0,6)+d*14,art.GOLD if open else Color("668f9a"),5,true)
		art.draw_circle(Vector2(0,6),5,art.GOLD if open else art.PALE)
		art._box(Rect2(-15,-20,30,10),art.INK,2)
		for x in [-8,8]: art.draw_circle(Vector2(x,-15),3,art.CORAL)
		# Split shield arcs physically open during the damage window.
		for side in [0,1]:
			art.draw_arc(Vector2.ZERO,42,side*PI+0.25+(0.30 if open else 0),side*PI+PI-0.25-(0.30 if open else 0),20,art.GOLD if open else Color("8bd4ef"),2 if open else 5,true)
	art.draw_set_transform(Vector2.ZERO)
	art._box(Rect2(p-Vector2(34,53),Vector2(68,5)),art.INK,0)
	art._box(Rect2(p-Vector2(33,52),Vector2(66*maxf(0,e.hp/e.max_hp),3)),art.CORAL,0,art.CORAL,0)
static func tell(art, e: Dictionary) -> void:
	if e.phase=="telegraph":
		if e.attack=="ram": art.draw_line(e.pos,Vector2(e.pos)+Vector2(e.dir)*697,art.CORAL,3,true)
		elif e.attack=="spin":
			art.draw_line(e.pos,e.target,art.CORAL,3,true); art.draw_arc(e.target,130,0,TAU,48,art.CORAL,3,true)
		else:
			art.draw_arc(e.pos,85,0,TAU,48,art.TEAL,3,true); art.draw_arc(e.pos,210,0,TAU,64,art.CORAL,3,true)
	if float(e.get("spin_fx",0))>0: art.draw_arc(e.pos,130,0,TAU,48,art.CREAM,6,true)
	if float(e.get("ring_fx",0))>0:
		art.draw_arc(e.pos,85,0,TAU,48,art.TEAL,3,true); art.draw_arc(e.pos,210,0,TAU,64,art.CREAM,6,true)
