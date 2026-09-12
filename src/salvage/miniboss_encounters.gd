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
	var color: Color=art.GOLD if e.miniboss=="drifter" else Color("8bb7ca")
	for side in [-1,1]:
		art._box(Rect2(p+Vector2(side*33-7,-19),Vector2(14,44)),art.INK,2)
		for y in [-12,0,12]: art.draw_line(p+Vector2(side*33-4,y),p+Vector2(side*33+4,y),art.PALE,3,true)
	art._box(Rect2(p-Vector2(31,28),Vector2(62,56)),color,5,art.INK,4)
	art._box(Rect2(p-Vector2(21,10),Vector2(42,20)),art.INK,2)
	for x in [-12,12]: art.draw_circle(p+Vector2(x,0),5,art.CORAL)
	if e.miniboss=="bulwark": art.draw_arc(p,42,0,TAU,32,art.GOLD if e.phase=="recover" else Color("8bd4ef"),2 if e.phase=="recover" else 5,true)
	else:
		for x in [-32,32]: art.draw_line(p+Vector2(x,-25),p+Vector2(x,-42),art.CREAM,6,true)
	art._box(Rect2(p-Vector2(34,51),Vector2(68,5)),art.INK,0)
	art._box(Rect2(p-Vector2(33,50),Vector2(66*maxf(0,e.hp/e.max_hp),3)),art.CORAL,0,art.CORAL,0)
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
