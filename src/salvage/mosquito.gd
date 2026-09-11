class_name Mosquito
extends RefCounted
static func wave(level: int, round_index: int, index: int) -> bool:
	return (level>=2 or round_index>=1) and index%(2 if level in [3,6] else 3)==0
## Physical avoidance only: no invulnerability, teleport or reading future input.
static func zones(run, e: Dictionary) -> Array:
	var result: Array=[]
	for effect in run.vanguard.impacts:
		if effect.kind in ["strike","reactor"] and effect.life>0:
			result.append({"a":effect.pos,"b":effect.pos,"radius":effect.radius+e.radius+8})
	for shot in run.projectiles:
		if shot.kind not in ["rocket","rail","basic"] or shot.life<=0: continue
		if Vector2(shot.pos).distance_to(e.pos)>420: continue
		result.append({"a":shot.pos,"b":Vector2(shot.pos)+Vector2(shot.vel)*minf(0.24,shot.life),"radius":float(shot.get("radius",5))+e.radius+10})
	if run.vanguard.slam_left>0:
		result.append({"a":run.player,"b":run.player+run.vanguard.slam_direction*run.vanguard.slam_left*(Vanguard.REBOUND_SPEED if run.vanguard.slam_bounced else Vanguard.SLAM_SPEED),"radius":e.radius+42})
	return result

static func risk(point: Vector2, threats: Array) -> float:
	var value:=0.0
	for zone in threats:
		var depth: float=zone.radius-Geometry2D.get_closest_point_to_segment(point,zone.a,zone.b).distance_to(point)
		if depth>0: value+=1000+depth*5
	return value

static func step(run, e: Dictionary, delta: float) -> void:
	e.phase="orbit"
	e.clock-=delta; e.dodge_clock=float(e.get("dodge_clock",0))-delta
	var away: Vector2=Vector2(e.pos)-run.player
	var orbit:=away.normalized().orthogonal()*(1 if int(e.id)%2 else -1)
	var preferred: Vector2=(orbit*0.75+away.normalized()*clampf((310-away.length())/80,-1,1)).normalized()
	if e.dodge_clock<=0:
		e.dodge_clock=0.10
		var threats:=zones(run,e)
		var danger:=risk(e.pos,threats)>0
		var speed:=720.0 if danger else 420.0
		var best:=preferred
		var best_score:=INF
		# Short horizon and finite speed make overlapping tells/cornering real counters.
		for i in range(17):
			var direction:=preferred if i==16 else Vector2.from_angle(i*TAU/16)
			var candidate:=ReviewEnemies.destination(run,e.pos,direction,speed*0.16,e.radius)
			var score:=risk(candidate,threats)+absf(candidate.distance_to(run.player)-310)*0.3+(1-direction.dot(preferred))*8
			if candidate.distance_to(run.player)<run.attacks.attack_range(run)+30: score+=180
			if candidate.distance_to(e.pos)<speed*0.08: score+=150
			if score<best_score: best_score=score; best=direction
		e.dodge_dir=best; e.dodge_speed=speed
	ReviewEnemies.move(run,e,e.get("dodge_dir",preferred),float(e.get("dodge_speed",420)),delta)
	# Gun knockback and stuns remain valid. The caller handles stun before AI.
	e.pos=run.kit.extra.solid_point(e.pos,Vector2(e.pos)+Vector2(e.knock)*delta,e.radius)
	e.knock=Vector2(e.knock).move_toward(Vector2.ZERO,900*delta)
	if e.clock<=0 and away.length()<500 and Rect2(run.follow_origin(),run.view_size).has_point(e.pos):
		e.clock=1.8
		var heading: Vector2=(run.player-Vector2(e.pos)).normalized()
		run._add_projectile(e.pos,heading*340,1,"hostile",0,1.8)
		run.emit_event("enemy_shot",e.pos)

static func draw(art, e: Dictionary) -> void:
	var p: Vector2=e.pos+art.frame_offset
	var facing: float=Vector2(e.get("dodge_dir",Vector2.RIGHT)).angle()
	art.draw_set_transform(p,facing)
	for side in [-1,1]:
		art.draw_colored_polygon(PackedVector2Array([Vector2(-8,side*4),Vector2(-16,side*20),Vector2(7,side*9)]),Color("789ca8"))
	art.draw_line(Vector2(-12,0),Vector2(10,0),art.INK,13,true)
	art.draw_line(Vector2(-10,0),Vector2(9,0),Color("b9a078"),8,true)
	art.draw_line(Vector2(8,0),Vector2(20,0),art.CORAL,3,true)
	art.draw_circle(Vector2(5,0),3,art.CREAM if e.flash>0 else art.CORAL)
	art.draw_set_transform(Vector2.ZERO)
