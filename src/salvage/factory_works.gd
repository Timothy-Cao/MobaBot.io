class_name FactoryWorks
extends RefCounted
## Pressure plates drive helpful machinery. Presentation never activates them.
var machines: Array=[]
static func layout(level: int, round_index: int) -> Array:
	var walls:=FactoryMaps.layout(level,round_index)
	# Loading pens, staggered cross-lines, and a broken outer reservoir bank.
	for side in [-1,1]:
		if level==1:
			for row in [-1,1]:
				FactoryMaps.add(walls,FactoryMaps.CENTER+Vector2(side*1100,row*680),Vector2.UP,160,65,2)
		elif level==2:
			FactoryMaps.add(walls,FactoryMaps.CENTER+Vector2(side*1320,side*340),Vector2.UP,160,70,0)
		else:
			for row in [-1,1]:
				FactoryMaps.add(walls,FactoryMaps.CENTER+Vector2(side*1100,row*1070),Vector2.UP,180,100,1)
	return walls
static func free_pad(run, wanted: Vector2) -> Vector2:
	for ring in range(9):
		for i in range(8):
			var point:=wanted+Vector2.from_angle(i*TAU/8)*ring*60
			if not run.ARENA.grow(-70).has_point(point): continue
			var clear:=true
			for wall in run.kit.extra.walls:
				if Geometry2D.get_closest_point_to_segment(point,wall.a,wall.b).distance_to(point)<wall.width+65: clear=false; break
			if clear: return point
	return wanted
func ensure(run) -> void:
	if not DiscoveryRules.enabled(run) or not machines.is_empty(): return
	for offset in [Vector2.ZERO,Vector2(1450,700),Vector2(-1450,-650)]:
		var center: Vector2=FactoryMaps.CENTER+offset
		machines.append({"pad":free_pad(run,center+Vector2(-120,130)),"target":center+Vector2(270,0),"cooldown":0.0,"hold":0.0,"windup":0.0,"active":0.0,"armed":false})
func step(run, delta: float) -> void:
	if not DiscoveryRules.enabled(run) or run.exp.clear_clock>=0: return
	ensure(run)
	for m in machines:
		m.cooldown=maxf(0,m.cooldown-delta); m.active=maxf(0,m.active-delta)
		if m.armed:
			m.windup-=delta
			if m.windup<=0:
				m.armed=false
				match run.exp.operation_chapter:
					1: FieldPickups.sweep(run); m.active=1.0
					2:
						MobaKit.area(run,m.target,210,ReviewRules.reference_w(run.exp.route_index)*3.0,"factory_press",90)
						m.active=0.7
					3: m.active=7.0
			continue
		if m.cooldown>0: continue
		m.hold=m.hold+delta if run.player.distance_to(m.pad)<=40 else 0.0
		if m.hold>=0.35:
			m.hold=0.0; m.cooldown=45.0; m.windup=0.8; m.armed=true
			run.emit_event("pulse",m.pad,{"radius":40.0})
func before_move(run) -> Dictionary:
	var points: Dictionary={}
	if not DiscoveryRules.enabled(run) or run.exp.operation_chapter!=3: return points
	for m in machines:
		if m.active<=0: continue
		for e in run.enemies:
			if not e.dead and Vector2(e.pos).distance_to(m.target)<=300: points[e.id]=e.pos
	return points
func after_move(run, points: Dictionary) -> void:
	if points.is_empty(): return
	for e in run.enemies:
		if e.dead or not points.has(e.id): continue
		var start: Vector2=points[e.id]
		var target:=start.lerp(e.pos,0.8 if e.has("exp_boss") else 0.45)
		e.pos=run.kit.extra.solid_point(start,target,e.radius)
func draw(art, run) -> void:
	if not DiscoveryRules.enabled(run): return
	# Uninitialized models can still render without mutating simulation.
	var visible: Array=machines
	if visible.is_empty():
		visible=[]
		for offset in [Vector2.ZERO,Vector2(1450,700),Vector2(-1450,-650)]:
			visible.append({"pad":free_pad(run,FactoryMaps.CENTER+offset+Vector2(-120,130)),"target":FactoryMaps.CENTER+offset+Vector2(270,0),"cooldown":0.0,"hold":0.0,"windup":0.0,"active":0.0,"armed":false})
	var view:=Rect2(run.camera_origin(),run.view_size).grow(360)
	for m in visible:
		if not view.has_point(m.pad) and not view.has_point(m.target): continue
		FactoryFinish.machine(art,m,run.exp.operation_chapter)
