class_name RangedThreats
extends RefCounted
const NAMES := {"lancer":"Arc lancer", "volley":"Burst battery", "bomber":"Bomb carrier"}

static func spawn(run, type: String, point: Vector2 = Vector2.INF, bypass_cap: bool = false) -> Dictionary:
	if not NAMES.has(type) or run.enemies.size()>=run.MAX_ENEMIES: return {}
	if not bypass_cap and run.enemies.filter(func(e): return not e.dead and e.has("gunner_kind")).size()>=3: return {}
	var pos: Vector2 = run._offscreen_point() if point == Vector2.INF else point
	run.spawn_enemy(pos,3)
	var enemy: Dictionary=run.enemies.back()
	enemy["gunner_kind"]=type; enemy["title"]=NAMES[type]
	enemy.radius=23.0; enemy.hp=38.0*(1+0.2*(int(BotExpedition.ROUTE[run.exp.route_index][0])-1)); enemy.max_hp=enemy.hp
	enemy.clock=1.0; enemy.phase="seek"; enemy["burst"]=0; enemy["beam_end"]=pos
	return enemy

static func beam_end(run, point: Vector2, direction: Vector2) -> Vector2:
	var end:=point+direction*740
	for wall in run.kit.extra.walls:
		var hit: Variant=Geometry2D.segment_intersects_segment(point,end,wall.a,wall.b)
		if hit!=null: end=hit
	return end

static func step(run, e: Dictionary, delta: float) -> void:
	e.clock-=delta
	var offset: Vector2=run.player-e.pos
	if e.phase=="seek":
		var point: Vector2=run.kit.extra.route(e.pos,run.player,e.radius)
		if offset.length()>360:
			e.pos=run.kit.extra.solid_point(e.pos,Vector2(e.pos)+(point-Vector2(e.pos)).normalized()*95*delta,e.radius)
		elif offset.length()<190:
			e.pos=run.kit.extra.solid_point(e.pos,Vector2(e.pos)-offset.normalized()*60*delta,e.radius)
		# Only start an attack while visible to the player-centered play area.
		var visible_area := Rect2(run.follow_origin(), run.view_size)
		if e.clock<=0 and offset.length()<560 and visible_area.grow(-25).has_point(e.pos):
			e.phase="aim"; e.clock=0.8 if e.gunner_kind=="lancer" else 0.65
			e.dir=offset.normalized(); e.beam_end=beam_end(run,e.pos,e.dir)
			if e.gunner_kind=="bomber":
				var predicted: Vector2=run.player+run.velocity.limit_length(160)*0.3
				for i in range(3):
					var target: Vector2=predicted+Vector2.from_angle(i*TAU/3+e.id)*100
					run.hazards.append({"pos":target,"radius":66.0,"time":1.05+i*0.1,"duration":1.05+i*0.1,"owner":e.id,"spent":false})
	elif e.phase=="aim":
		if e.clock<=0:
			if e.gunner_kind=="lancer":
				e.beam_end=beam_end(run,e.pos,e.dir)
				if Geometry2D.get_closest_point_to_segment(run.player,e.pos,e.beam_end).distance_to(run.player)<=24:
					run.hurt_player(e.pos,"Arc lance",2)
				e.phase="beam"; e.clock=0.22
			elif e.gunner_kind=="volley": e.phase="burst"; e.burst=0; e.clock=0
			else: e.phase="recover"; e.clock=3.4
	elif e.phase=="burst":
		if e.clock<=0:
			var heading: Vector2=Vector2(e.dir).rotated(deg_to_rad(-12+e.burst*6))
			run._add_projectile(Vector2(e.pos)+heading*27,heading*315,1,"hostile",0)
			e.burst+=1; e.clock+=0.12
			if e.burst>=5: e.phase="recover"; e.clock=2.7
	elif e.clock<=0:
		if e.phase=="beam": e.phase="recover"; e.clock=2.8
		else: e.phase="seek"; e.clock=0.4
	if offset.length()<e.radius+12: run.hurt_player(e.pos,NAMES[e.gunner_kind]+" contact",1)
	e.pos+=Vector2(e.knock)*delta; e.knock=Vector2(e.knock).move_toward(Vector2.ZERO,900*delta)
	e.pos=Vector2(e.pos).clamp(run.ARENA.position+Vector2.ONE*30,run.ARENA.end-Vector2.ONE*30)

static func draw(art, e: Dictionary) -> void:
	var p: Vector2=e.pos+art.frame_offset
	art.draw_set_transform(p)
	art.draw_circle(Vector2(0,12),26,Color(art.INK,0.55))
	var color: Color=art.CORAL if e.gunner_kind=="lancer" else Color("ab81ad")
	if e.flash>0 and not art.reduced_effects: color=art.CREAM
	art._box(Rect2(-22,-20,44,38),color,4,art.INK,3)
	art._box(Rect2(-15,-8,30,14),art.INK,2)
	art._line(Vector2(-8,-1),Vector2(8,-1),art.CREAM,3)
	if e.gunner_kind=="bomber":
		for x in [-18,0,18]:
			art._box(Rect2(x-6,-33,12,18),art.PALE,2,art.INK,2)
			art.draw_circle(Vector2(x,-29),3,art.CORAL)
	else:
		art.draw_set_transform(p,Vector2(e.dir).angle())
		for side in ([-8,8] if e.gunner_kind=="volley" else [0]):
			art._box(Rect2(12,side-5,27,10),art.PALE,2,art.INK,2)
			art._line(Vector2(33,side-3),Vector2(33,side+3),art.CORAL if e.phase=="aim" else art.INK,3)
	art.draw_set_transform(p)
	art._box(Rect2(-23,-43,46,4),art.INK,0)
	art._box(Rect2(-22,-42,44*maxf(0,e.hp/e.max_hp),2),art.CORAL,0,art.CORAL,0)
	art.draw_set_transform(Vector2.ZERO)

static func tell(art, e: Dictionary) -> void:
	if e.gunner_kind=="lancer" and e.phase in ["aim","beam"]:
		art._line(e.pos,e.beam_end,Color(art.CORAL,0.7 if e.phase=="aim" else 1),2 if e.phase=="aim" else 24)
		if e.phase=="beam": art._line(e.pos,e.beam_end,art.CREAM,4)
