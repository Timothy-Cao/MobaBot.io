class_name ReviewEnemies
extends RefCounted
## Simulation-only attacks; tell geometry is rendered by ReviewEnemyArt.

static func destination(run, start: Vector2, direction: Vector2, distance: float, radius: float) -> Vector2:
	var point:=start
	var heading:=direction.limit_length()
	for i in range(ceili(distance/4.0)):
		var desired: Vector2=start+heading*minf(distance,(i+1)*4.0)
		var safe: Vector2=run.kit.extra.solid_point(point,desired,radius)
		point=safe.clamp(run.ARENA.position+Vector2.ONE*radius,run.ARENA.end-Vector2.ONE*radius)
		if point.distance_to(desired)>0.1: break
	return point

static func move(run, e: Dictionary, direction: Vector2, speed: float, delta: float) -> void:
	e.pos=destination(run,e.pos,direction,speed*delta,e.radius)

static func mobile_ranged(run, e: Dictionary, delta: float) -> void:
	var offset: Vector2=run.player-e.pos
	var tangent:=offset.normalized().orthogonal()*(1 if int(e.id)%2 else -1)
	var radial: float=clampf((offset.length()-350)/110,-1,1)
	move(run,e,(tangent*0.8+offset.normalized()*radial).normalized(),210*run.exp.enemy_speed(run),delta)

static func emp(run, e: Dictionary, delta: float) -> void:
	e.clock-=delta
	var offset: Vector2=run.player-e.pos
	if e.phase=="seek":
		if offset.length()>280: move(run,e,offset.normalized(),65,delta)
		if e.clock<=0 and offset.length()<520 and Rect2(run.follow_origin(),run.view_size).has_point(e.pos):
			e.phase="emp_aim"; e.clock=1.1; e.emp_target=run.player+run.velocity.limit_length(100)*0.35
			run.emit_event("enemy_windup",e.pos)
	elif e.phase=="emp_aim" and e.clock<=0:
		e.phase="emp_wave"; e.clock=0.8; e.emp_hit=false
		run.emit_event("enemy_shot",e.pos)
	elif e.phase=="emp_wave":
		var radius: float=160*clampf(1-e.clock/0.8,0,1)
		if not e.emp_hit and run.player.distance_to(e.emp_target)<=radius+12:
			ReviewRules.suppress(run); e.emp_hit=true
		if e.clock<=0: e.phase="recover"; e.clock=6.0
	elif e.phase=="recover" and e.clock<=0: e.phase="seek"; e.clock=0.2

static func tank(run, e: Dictionary, delta: float) -> void:
	e.clock-=delta
	var offset: Vector2=run.player-e.pos
	if not e.has("melee_phase"): e.melee_phase="seek"
	if e.melee_phase=="seek":
		move(run,e,(run.kit.extra.route(e.pos,run.player,e.radius)-Vector2(e.pos)).normalized(),130*run.exp.enemy_speed(run),delta)
		if offset.length()<115 and e.clock<=0:
			e.melee_phase="aim"; e.clock=0.55; e.dir=offset.normalized(); run.emit_event("enemy_windup",e.pos)
	elif e.melee_phase=="aim" and e.clock<=0:
		if offset.length()<125 and absf(Vector2(e.dir).angle_to(offset))<PI*0.45: run.hurt_player(e.pos,"Tank sweep",2)
		e.melee_phase="recover"; e.clock=1.1
	elif e.melee_phase=="recover" and e.clock<=0: e.melee_phase="seek"

static func boss(run, e: Dictionary, delta: float) -> void:
	if not e.get("review_boss",false):
		e.review_boss=true; e.radius=48.0; e.sequence=0; e.phase="approach"; e.clock=0.7
		e.summon_clock=9.0; e.shot_clock=0.0; e.attack="fan"; e.pursuit=0.0
	e.enraged=e.hp<e.max_hp*0.5
	e.clock-=delta; e.summon_clock-=delta
	var offset: Vector2=run.player-e.pos
	var direction:=offset.normalized()
	if e.summon_clock<=0:
		e.summon_clock=8.0 if e.enraged else 12.0
		if run.enemies.size()<90: run._spawn_pack(3,true)
	# Open arena: a visible, wall-respecting pursuit replaces invisible leashing.
	if offset.length()>850 and e.phase in ["approach","recover"]:
		e.phase="pursuit"; e.clock=2.2; run.emit_event("boss_windup",e.pos)
	if e.phase=="pursuit":
		move(run,e,(run.kit.extra.route(e.pos,run.player,e.radius)-Vector2(e.pos)).normalized(),490,delta)
		if e.clock<=0 or offset.length()<320: e.phase="recover"; e.clock=0.7
	elif e.phase=="approach":
		var tangent:=direction.orthogonal()*sin(run.time*1.8+e.id)
		move(run,e,(direction*clampf((offset.length()-270)/160,-1,1)+tangent*0.85).normalized(),220 if e.enraged else 185,delta)
		if e.clock<=0 and offset.length()<700:
			e.attack=["fan","charge","shells","sweep","ring","melee"][e.sequence%6]; e.sequence+=1
			e.phase="telegraph"; e.clock=0.55 if e.attack=="charge" else 0.85
			e.dir=(run.player+run.velocity.limit_length(240)*0.3-Vector2(e.pos)).normalized()
			if e.attack=="sweep": e.dir=direction.rotated(-0.65)
			e.target=destination(run,e.pos,e.dir,480,e.radius)
			run.emit_event("boss_windup",e.pos)
	elif e.phase=="telegraph" and e.clock<=0:
		e.phase="attack"; e.clock={"fan":0.9,"charge":0.48,"shells":2.5,"sweep":1.5,"ring":0.2,"melee":0.2}[e.attack]
		e.shot_clock=0.0; e.burst=0
	elif e.phase=="attack":
		e.shot_clock-=delta
		match e.attack:
			"charge":
				var before: Vector2=e.pos
				move(run,e,e.dir,1000,minf(delta,minf(maxf(0,e.clock+delta),Vector2(e.pos).distance_to(e.target)/1000)))
				if Geometry2D.get_closest_point_to_segment(run.player,before,e.pos).distance_to(run.player)<e.radius+12: run.hurt_player(e.pos,"Boss charge",3)
			"sweep":
				e.dir=Vector2(e.dir).rotated(minf(delta,maxf(0,e.clock+delta))*0.9)
				if e.shot_clock<=0:
					e.shot_clock=0.25
					if Geometry2D.get_closest_point_to_segment(run.player,e.pos,Vector2(e.pos)+Vector2(e.dir)*740).distance_to(run.player)<23: run.hurt_player(e.pos,"Boss sweep laser",1,"ground")
			"shells":
				if e.shot_clock<=0 and e.burst<5:
					e.shot_clock+=0.5; e.burst+=1
					var target: Vector2=run.player+run.velocity.limit_length(160)*0.35+direction.orthogonal()*sin(e.burst*2.4)*65
					run.hazards.append({"pos":target,"radius":78.0,"time":0.8,"duration":0.8,"owner":e.id,"spent":false})
			"fan":
				if e.shot_clock<=0 and e.burst<3:
					e.shot_clock+=0.3; e.burst+=1
					for i in range(9):
						var aim: Vector2=Vector2(e.dir).rotated((i-4)*0.18+(e.burst%2)*0.07)
						run._add_projectile(Vector2(e.pos)+aim*e.radius,aim*340,1,"hostile",0,2.5)
			"ring":
				if e.burst==0:
					e.burst=1
					for i in range(18):
						if i in [0,1,9,10]: continue
						var aim:=Vector2.from_angle(i*TAU/18+Vector2(e.dir).angle())
						run._add_projectile(Vector2(e.pos)+aim*e.radius,aim*280,1,"hostile",0,3.0)
			"melee":
				if e.burst==0:
					e.burst=1
					if offset.length()<155 and absf(Vector2(e.dir).angle_to(offset))<PI*0.6: run.hurt_player(e.pos,"Boss melee sweep",3)
		if e.clock<=0: e.phase="recover"; e.clock=0.85 if e.enraged else 1.15
	elif e.phase=="recover" and e.clock<=0: e.phase="approach"; e.clock=0.7
