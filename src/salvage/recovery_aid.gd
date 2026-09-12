class_name RecoveryAid
extends RefCounted
const LOW_HP:=0.30
const SCREEN:=Vector2(960,540)
const EDGE:=Rect2(30,138,900,286)
var rng:=RandomNumberGenerator.new()
var seeded:=false
var low_seconds:=0.0
var cooldown:=0.0

static func low(run) -> bool:
	return DiscoveryRules.enabled(run) and run.health>0 and run.health<=run.max_health()*LOW_HP

func step(run, delta: float) -> void:
	if not DiscoveryRules.enabled(run) or run.state!="running" or run.exp.clear_clock>=0: return
	if not seeded: rng.seed=run.run_seed+36013; seeded=true
	cooldown=maxf(0,cooldown-delta)
	low_seconds=low_seconds+delta if low(run) else 0.0
	if low_seconds<6 or cooldown>0: return
	if run.supply_drops.any(func(s): return s.get("rescue",false) and s.value>0): return
	var point:=spawn_point(run)
	if point==Vector2.INF: cooldown=5; return
	var count: int=run.supply_drops.size()
	run._drop_supply(point,"health_pack",25)
	if run.supply_drops.size()>count:
		run.supply_drops.back().rescue=true
		run.supply_drops.back().expires=75.0
	cooldown=rng.randf_range(45,65); low_seconds=0

func spawn_point(run) -> Vector2:
	var angle:=rng.randf_range(0,TAU)
	for i in range(24):
		var point: Vector2=run.player+Vector2.from_angle(angle+i*TAU/24)*rng.randf_range(650,1000)
		if not run.ARENA.grow(-70).has_point(point): continue
		var clear:=true
		for wall in run.kit.extra.walls:
			if Geometry2D.get_closest_point_to_segment(point,wall.a,wall.b).distance_to(point)<wall.width+40: clear=false; break
		if clear: return point
	return Vector2.INF

static func indicators(run) -> Array:
	var result: Array=[]
	if not DiscoveryRules.enabled(run) or run.state!="running": return result
	var packs: Array=run.supply_drops.filter(func(s): return s.kind=="health_pack" and s.value>0 and float(s.get("age",0))<float(s.get("expires",INF)))
	packs.sort_custom(func(a,b): return Vector2(a.pos).distance_squared_to(run.player)<Vector2(b.pos).distance_squared_to(run.player))
	for pack in packs:
		var screen_point: Vector2=(Vector2(pack.pos)-run.camera_origin())/run.view_size*SCREEN
		if Rect2(Vector2.ZERO,SCREEN).has_point(screen_point): continue
		var direction: Vector2=(screen_point-SCREEN/2).normalized()
		var distance:=INF
		if absf(direction.x)>0.0001: distance=minf(distance,((EDGE.end.x if direction.x>0 else EDGE.position.x)-SCREEN.x/2)/direction.x)
		if absf(direction.y)>0.0001: distance=minf(distance,((EDGE.end.y if direction.y>0 else EDGE.position.y)-SCREEN.y/2)/direction.y)
		var point: Vector2=SCREEN/2+direction*distance
		if result.any(func(marker): return Vector2(marker.pos).distance_to(point)<48): continue
		result.append({"pos":point,"direction":direction})
		if result.size()==3: break
	return result

static func draw(art, run) -> void:
	var markers:=indicators(run)
	if markers.is_empty(): return
	art.draw_set_transform(run.camera_origin(),0,run.view_size/SCREEN)
	for marker in markers:
		var p: Vector2=marker.pos
		art.draw_circle(p,20,Color("14242c"))
		art.draw_arc(p,19,0,TAU,24,Color("78c995"),2,true)
		FieldPickups.draw(art,p,"health_pack")
		var direction: Vector2=marker.direction
		var tip: Vector2=p+direction*29
		art.draw_colored_polygon(PackedVector2Array([tip,tip-direction*8+direction.orthogonal()*5,tip-direction*8-direction.orthogonal()*5]),Color("b9eed1"))
	art.draw_set_transform(Vector2.ZERO)
