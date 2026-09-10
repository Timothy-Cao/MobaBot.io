class_name FieldEnemies
extends RefCounted
## Bounded specialist roles sharing the salvage-machine material language.
static func step(run, e: Dictionary, dt: float) -> void:
	e.clock-=dt
	var offset: Vector2=run.player-e.pos
	var speed: float=run.exp.enemy_speed(run)
	if e.phase=="seek":
		var desired: float=180 if e.gunner_kind=="breacher" else 310
		var point: Vector2=run.kit.extra.route(e.pos,run.player,e.radius)
		var move: Vector2=(point-Vector2(e.pos)).normalized()* (125 if e.gunner_kind=="breacher" else 80)*speed
		if offset.length()>desired: e.pos=run.kit.extra.solid_point(e.pos,Vector2(e.pos)+move*dt,e.radius)
		elif offset.length()<170 and e.gunner_kind!="breacher": e.pos=run.kit.extra.solid_point(e.pos,Vector2(e.pos)-offset.normalized()*65*speed*dt,e.radius)
		if e.clock<=0 and offset.length()< (310 if e.gunner_kind=="breacher" else 510) and Rect2(run.follow_origin(),run.view_size).grow(-30).has_point(e.pos):
			e.phase="aim"; e.clock=0.65; e.dir=offset.normalized(); e.hit_player=false
			run.emit_event("enemy_windup",e.pos)
	elif e.phase=="aim" and e.clock<=0:
		if e.gunner_kind=="breacher": e.phase="rush"; e.clock=0.6
		elif e.gunner_kind=="scatter":
			for i in range(7):
				var direction: Vector2=Vector2(e.dir).rotated(deg_to_rad(-30+i*10))
				run._add_projectile(Vector2(e.pos)+direction*28,direction*280,1,"hostile",0,2.0)
			e.phase="recover"; e.clock=3.0; run.emit_event("enemy_shot",e.pos)
		else:
			e.links.clear()
			for ally in run.enemies:
				if ally.dead or ally.get("dummy",false) or ally.has("role") or ally.get("gunner_kind","")=="mender" or ally.hp>=ally.max_hp: continue
				if Vector2(ally.pos).distance_to(e.pos)>230: continue
				ally.hp=minf(ally.max_hp,ally.hp+minf(ally.max_hp*0.08,12*BotExpedition.stage_health(run.exp.ROUTE[run.exp.route_index][0])))
				e.links.append(Vector2(ally.pos))
				if e.links.size()>=3: break
			e.phase="repair"; e.clock=0.35
			if not e.links.is_empty(): run.emit_event("enemy_repair",e.pos)
	elif e.phase=="rush":
		var start: Vector2=e.pos
		var desired: Vector2=start+Vector2(e.dir)*480*minf(dt,maxf(0,e.clock+dt))
		# Substeps prevent a long frame from tunnelling through a thick wall edge.
		var travel: float=start.distance_to(desired)
		for i in range(ceili(travel/4)):
			var next: Vector2=start+Vector2(e.dir)*minf(travel,(i+1)*4)
			var safe: Vector2=run.kit.extra.solid_point(e.pos,next,e.radius)
			e.pos=safe
			if safe.distance_to(next)>1: break
		if not e.hit_player and Geometry2D.get_closest_point_to_segment(run.player,start,e.pos).distance_to(run.player)<e.radius+12:
			run.hurt_player(e.pos,"Breacher rush",2); e.hit_player=true
		if e.clock<=0 or Vector2(e.pos).distance_to(desired)>2: e.phase="recover"; e.clock=1.7
	elif e.phase=="repair" and e.clock<=0: e.links.clear(); e.phase="recover"; e.clock=3.4
	elif e.phase=="recover" and e.clock<=0: e.phase="seek"; e.clock=0.3
	if offset.length()<e.radius+12 and e.phase!="rush": run.hurt_player(e.pos,e.title+" contact",1)
	e.pos+=Vector2(e.knock)*dt; e.knock=Vector2(e.knock).move_toward(Vector2.ZERO,900*dt)
	e.pos=Vector2(e.pos).clamp(run.ARENA.position+Vector2.ONE*30,run.ARENA.end-Vector2.ONE*30)

static func draw(art, e: Dictionary) -> void:
	var p: Vector2=e.pos+art.frame_offset
	art.draw_set_transform(p)
	art.draw_circle(Vector2(0,12),26,Color(art.INK,0.55))
	var tint: Color={"breacher":Color("dc8559"),"mender":Color("78ba99"),"scatter":Color("b89bce")}[e.gunner_kind]
	if e.flash>0 and not art.reduced_effects: tint=art.CREAM
	art._box(Rect2(-22,-20,44,39),tint,3,art.INK,3)
	for side in [-1,1]: art._box(Rect2(side*22-4,-13,8,32),art.PALE,2,art.INK,2)
	art._box(Rect2(-14,-8,28,13),art.INK,2)
	art._line(Vector2(-8,-2),Vector2(8,-2),art.CREAM,3)
	if e.gunner_kind=="mender":
		art._line(Vector2(0,-37),Vector2(0,-18),art.PALE,5)
		art._line(Vector2(-8,-29),Vector2(8,-29),art.PALE,5)
		art.draw_arc(Vector2.ZERO,29,0,TAU,24,Color(tint,0.5),2,true)
	else:
		art.draw_set_transform(p,Vector2(e.dir).angle())
		if e.gunner_kind=="breacher":
			art.draw_colored_polygon(PackedVector2Array([Vector2(12,-24),Vector2(38,0),Vector2(12,24),Vector2(21,0)]),art.PALE)
			art._line(Vector2(27,-9),Vector2(35,0),tint,3)
		else:
			for i in [-1,0,1]:
				art._box(Rect2(12,i*12-4,25,8),art.PALE,1,art.INK,2)
				art.draw_circle(Vector2(34,i*12),3,tint)
	art.draw_set_transform(p)
	art._box(Rect2(-22,25,44,4),art.INK,0)
	art._line(Vector2(-20,27),Vector2(-20+40*maxf(0,e.hp/e.max_hp),27),tint,2)
	art.draw_set_transform(Vector2.ZERO)

static func tell(art, e: Dictionary) -> void:
	if e.gunner_kind=="breacher" and e.phase=="aim":
		var end: Vector2=e.pos+Vector2(e.dir)*288
		for side in [-1,1]:
			var shift: Vector2=Vector2(e.dir).orthogonal()*e.radius*side
			art._line(e.pos+shift,end+shift,Color(art.CORAL,0.55),2)
	elif e.gunner_kind=="scatter" and e.phase=="aim":
		for angle in [-30,30]: art._line(e.pos,e.pos+Vector2(e.dir).rotated(deg_to_rad(angle))*180,Color(art.CORAL,0.65),2)
	elif e.gunner_kind=="mender":
		if e.phase=="aim": art.draw_arc(e.pos,38,-PI*0.5,TAU*(1-e.clock/0.65)-PI*0.5,32,Color("a8e0b7"),2,true)
		if e.phase=="repair":
			for point in e.links: art._line(e.pos,point,Color("a8e0b7"),2)
