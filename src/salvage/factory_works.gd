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
		var tint:=Color("ddbd75") if run.exp.operation_chapter!=3 else Color("76c6bd")
		var lit: Color=tint if m.cooldown<=0 or m.armed else Color("566c70")
		art.draw_line(m.pad,m.target,Color("10212a"),13)
		art.draw_line(m.pad,m.target,Color(lit,0.45),3)
		art.draw_circle(m.pad+Vector2(0,6),46,Color("0d1e26"))
		art.draw_circle(m.pad,42,Color("344e57"))
		art.draw_arc(m.pad,36,0,TAU,24,lit,4,true)
		for side in [-1,1]: ExpeditionArt.chevron(art,m.pad+Vector2(side*17,0),Vector2(-side,0),lit,9)
		if m.cooldown>0: art.draw_arc(m.pad,43,-PI/2,-PI/2+TAU*(1-m.cooldown/45),32,tint,3,true)
		var p: Vector2=m.target
		match run.exp.operation_chapter:
			1:
				art.draw_rect(Rect2(p-Vector2(170,110),Vector2(340,220)),Color("537078",0.22),false,5)
				for x in [-150,150]:
					art.draw_line(p+Vector2(x,-140),p+Vector2(x,140),Color("324e5a"),14)
					art.draw_line(p+Vector2(x-3,-140),p+Vector2(x-3,140),Color("6b8387"),3)
				art.draw_line(p-Vector2(150,90),p+Vector2(150,-90),tint,8)
				art.draw_line(p-Vector2(0,90),p-Vector2(0,25),tint,4)
				art.draw_arc(p-Vector2(0,12),13,-PI/2,PI,12,tint,5)
				if m.active>0: art.draw_arc(p,80+100*(1-m.active),0,TAU,40,Color(tint,m.active),4)
			2:
				art.draw_circle(p,210,Color("714e35",0.17))
				art.draw_arc(p,210,0,TAU,48,Color(tint,0.4),4,true)
				for i in range(12):
					var d:=Vector2.from_angle(i*TAU/12)
					art.draw_line(p+d*188,p+d*204,tint,6)
				if m.armed or m.active>0:
					var scale_value: float=1.0-m.windup/0.8 if m.armed else m.active/0.7
					art.draw_circle(p,210*scale_value,Color(tint,0.14))
					art.draw_arc(p,210*scale_value,0,TAU,40,tint,5,true)
			3:
				for radius in [70,82,94]: art.draw_arc(p,radius,0,TAU,32,Color("507e84"),5)
				for i in range(-2,3): art.draw_line(p+Vector2(-50,i*18),p+Vector2(50,i*18),Color("6f999b"),6)
				if m.active>0:
					art.draw_circle(p,300,Color(tint,0.08))
					art.draw_arc(p,300,0,TAU,64,Color(tint,0.6),3,true)
		if m.armed: art.draw_arc(m.pad,48,-PI/2,-PI/2+TAU*(1-m.windup/0.8),32,tint,4,true)
