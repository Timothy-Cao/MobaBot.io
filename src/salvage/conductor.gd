class_name Conductor
extends RefCounted
## Practice-only prototype. Never persisted or advertised as a campaign class.
var relays: Array[Dictionary]=[]
var beams: Array[Dictionary]=[]
var departure:=Vector2.ZERO
var moved_relay:=false
static func enabled(run) -> bool: return run!=null and run.exp!=null and run.exp.practice and run.vanguard.conductor_active

func cast(run, slot: String, target: Vector2) -> void:
	var aim: Vector2=(target-run.player).normalized()
	if aim.is_zero_approx(): aim=Vector2.RIGHT
	match slot:
		"q":
			var finish: Vector2=run.player+aim*650
			var hit_ids: Array=[]
			beam(run,run.player,finish,36*run.kit.damage_scale("q"),12,hit_ids)
			for relay in relays:
				if Geometry2D.get_closest_point_to_segment(relay.pos,run.player,finish).distance_to(relay.pos)<30:
					beam(run,relay.pos,relay.pos+aim.rotated(0.55)*350,36*run.kit.damage_scale("q"),12,hit_ids)
					break
		"w":
			if relays.size()==2: relays.pop_front()
			relays.append({"pos":target,"life":12.0})
		"e":
			departure=run.player; moved_relay=false
			run.vanguard.slam_direction=aim; run.vanguard.slam_left=run.kit.cast_range("e")/Vanguard.SLAM_SPEED
			run.vanguard.slam_bounced=false; run.vanguard.buffered_hammer=false
			run.vanguard.blast(run,run.player,75,16*run.kit.damage_scale("e"),"conductor",0,100)
		"r":
			var a: Vector2=relays[0].pos if relays.size()==2 else run.player
			var b: Vector2=relays[1].pos if relays.size()==2 else run.player+aim*320
			beams.append({"a":a,"b":b,"life":0.65,"pending":true,"damage":135*run.kit.damage_scale("r"),"width":28.0})
			relays.clear()

func beam(run, a: Vector2, b: Vector2, damage: float, width: float, hits: Array) -> void:
	for enemy in run.enemies:
		if not run.attacks.valid(enemy) or enemy.id in hits: continue
		if Geometry2D.get_closest_point_to_segment(enemy.pos,a,b).distance_to(enemy.pos)<=enemy.radius+width:
			hits.append(enemy.id); run.hit_enemy(enemy,damage,"conductor")
	beams.append({"a":a,"b":b,"life":0.2,"pending":false,"width":width})

func tick(run, delta: float) -> void:
	for relay in relays:
		relay.life-=delta
		if run.vanguard.slam_left>0 and not moved_relay and run.player.distance_to(relay.pos)<65:
			relay.pos=departure; moved_relay=true
	relays=relays.filter(func(r): return r.life>0)
	for ray in beams.duplicate():
		ray.life-=delta
		if ray.life<=0:
			if ray.pending: beam(run,ray.a,ray.b,ray.damage,ray.width,[])
			beams.erase(ray)

func draw(c) -> void:
	for relay in relays:
		var p: Vector2=relay.pos
		c.draw_circle(p,17,c.INK)
		c.draw_arc(p,14,0,TAU*clampf(relay.life/12.0,0,1),24,Color("a99ed3"),3,true)
		c.draw_rect(Rect2(p-Vector2(7,9),Vector2(14,18)),c.TEAL)
		c.draw_line(p-Vector2(0,6),p+Vector2(0,6),c.CREAM,3,true)
	if relays.size()==2: c.draw_line(relays[0].pos,relays[1].pos,Color("a99ed340"),2,true)
	for ray in beams:
		var direction: Vector2=(Vector2(ray.b)-Vector2(ray.a)).normalized().orthogonal()*ray.width
		if ray.pending:
			for side in [-1,1]: c.draw_line(ray.a+direction*side,ray.b+direction*side,Color("a99ed3"),2,true)
		else:
			c.draw_line(ray.a,ray.b,Color("75cbe3"),ray.width*2,true)
			c.draw_line(ray.a,ray.b,c.CREAM,3,true)

static func detail(slot: String) -> String:
	return {"q":"Arc bolt\nA straight electrical shot. Cross a relay to fork once. Each enemy is hit once.","w":"Relay\nPlace up to two relays. They last 12 seconds and do no passive damage.","e":"Slip current\nDash with a departure pulse. Pass near a relay to move it to your departure point.","r":"Discharge\nAfter 0.65 seconds, strike between two relays and consume them. Without two, fire a shorter line."}.get(slot,"")
