class_name SupportEnemies
extends RefCounted
const RADIUS:=280.0
static func step(run, e: Dictionary, delta: float) -> void:
	e.phase="support"; e.clock-=delta
	var offset: Vector2=run.player-e.pos
	if offset.length()>340: ReviewEnemies.move(run,e,(run.kit.extra.route(e.pos,run.player,e.radius)-Vector2(e.pos)).normalized(),75,delta)
	if e.gunner_kind!="hatchery" or e.clock>0: return
	e.clock=8.0
	var living: int=run.enemies.filter(func(x): return not x.dead and x.get("hatch_parent",-1)==e.id).size()
	for i in range(mini(4,16-living)):
		if run.enemies.size()>=run.MAX_ENEMIES: break
		var point: Vector2=Vector2(e.pos)+Vector2.from_angle((i+int(e.id)%4)*TAU/4)*65
		if not Vanguard.valid_point(run,point,14): continue
		run.spawn_enemy(point,0)
		var child: Dictionary=run.enemies.back(); child.runner=true; child.hatch_parent=e.id
		run.emit_event("enemy_windup",point)

static func prepare(run, delta: float) -> Dictionary:
	var before: Dictionary={}
	var sources: Array=run.enemies.filter(func(e): return not e.dead and e.warmup<=0 and e.get("gunner_kind","")=="uplink")
	for enemy in run.enemies:
		if enemy.dead: continue
		enemy.aura_left=maxf(0,float(enemy.get("aura_left",0))-delta)
		before[enemy.id]=enemy.pos
		var healing:=0.0
		for source in sources:
			if source.dead or source.warmup>0 or source.id==enemy.id or source.get("gunner_kind","")!="uplink": continue
			if Vector2(source.pos).distance_to(enemy.pos)>RADIUS: continue
			enemy.aura_left=3.0
			healing=maxf(healing,minf(12,enemy.max_hp*0.02))
		enemy.hp=minf(enemy.max_hp,enemy.hp+healing*delta)
	return before

static func movement(run, before: Dictionary) -> void:
	for enemy in run.enemies:
		if enemy.dead or not before.has(enemy.id) or float(enemy.get("aura_left",0))<=0: continue
		var bonus: Vector2=(Vector2(enemy.pos)-Vector2(before[enemy.id]))*(0.3*enemy.aura_left/3.0)
		enemy.pos=run.kit.extra.solid_point(enemy.pos,Vector2(enemy.pos)+bonus,enemy.radius).clamp(run.ARENA.position+Vector2.ONE*enemy.radius,run.ARENA.end-Vector2.ONE*enemy.radius)

static func draw(art, e: Dictionary) -> void:
	var p: Vector2=e.pos+art.frame_offset
	var uplink: bool=e.gunner_kind=="uplink"
	if uplink: art.draw_arc(p,RADIUS,0,TAU,64,Color("87d69f55"),2,true)
	art._box(Rect2(p-Vector2(24,22),Vector2(48,44)),Color("40565e"),5,art.INK,3)
	art._box(Rect2(p-Vector2(17,13),Vector2(34,26)),art.INK,2)
	if uplink:
		art.draw_line(p-Vector2(0,11),p+Vector2(0,11),Color("87d69f"),6,true)
		art.draw_line(p-Vector2(11,0),p+Vector2(11,0),Color("87d69f"),6,true)
		art.draw_line(p-Vector2(0,24),p-Vector2(0,40),art.PALE,4,true)
		art.draw_circle(p-Vector2(0,41),5,Color("87d69f"))
	else:
		for x in [-10,10]:
			art.draw_line(p+Vector2(x,-9),p+Vector2(x,11),art.GOLD,5,true)
		art.draw_arc(p,29,-PI/2,-PI/2+TAU*clampf(1-e.clock/8.0,0,1),32,art.GOLD,2,true)
