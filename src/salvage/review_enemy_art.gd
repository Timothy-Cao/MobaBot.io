class_name ReviewEnemyArt
extends RefCounted

static func draw(art) -> void:
	var run=art.model
	var brackets:=PackedVector2Array()
	var sparks:=PackedVector2Array()
	var view:=Rect2(run.camera_origin(),run.view_size).grow(80)
	for e in run.enemies:
		if e.dead: continue
		# Cull only status badges. An offscreen boss can still fire into view.
		var visible: bool=view.has_point(e.pos)
		if float(e.get("aura_left",0))>0: art.draw_arc(e.pos,e.radius+6,0,TAU,24,Color(0.53,0.84,0.62,0.65*e.aura_left/3.0),2,true)
		if visible and float(e.get("vulnerable",0))>0:
			var radius: float=e.radius+7
			# Collect small angular brackets into one batch for the entire crowd.
			for side in [-1,1]:
				var middle: Vector2=Vector2(e.pos)+Vector2(side*radius,0)
				brackets.append(Vector2(e.pos)+Vector2(side*radius*0.85,-radius*0.5)); brackets.append(middle)
				brackets.append(middle); brackets.append(Vector2(e.pos)+Vector2(side*radius*0.85,radius*0.5))
		if visible and float(e.get("stun",0))>0:
			var top: Vector2=Vector2(e.pos)-Vector2(0,e.radius+15)
			for i in range(3 if e.has("role") else 1):
				var at:=top+Vector2((i-1)*10 if e.has("role") else 0,0)
				sparks.append(at+Vector2(2,-5)); sparks.append(at+Vector2(-3,0))
				sparks.append(at+Vector2(-3,0)); sparks.append(at+Vector2(3,0))
				sparks.append(at+Vector2(3,0)); sparks.append(at+Vector2(-2,5))
		if e.get("gunner_kind","")=="emp":
			art.draw_arc(e.pos,32,0,TAU,24,Color("bda9ed"),4,true)
			for i in range(4):
				var d:=Vector2.from_angle(i*PI/2)
				art.draw_line(Vector2(e.pos)+d*18,Vector2(e.pos)+d*39,art.CREAM,3,true)
			if e.phase in ["emp_aim","emp_wave"]:
				var radius: float=160 if e.phase=="emp_aim" else 160*clampf(1-e.clock/0.8,0,1)
				art.draw_arc(e.emp_target,160,0,TAU,64,Color("bda9ed"),2,true)
				art.draw_line(e.pos,e.emp_target,Color("bda9ed80"),2,true)
				if e.phase=="emp_wave": art.draw_arc(e.emp_target,radius,0,TAU,64,art.CREAM,4,true)
		if e.get("melee_phase","")=="aim": art.draw_arc(e.pos,125,Vector2(e.dir).angle()-PI*0.45,Vector2(e.dir).angle()+PI*0.45,32,art.CORAL,3,true)
		if not e.get("review_boss",false): continue
		if e.get("overload",false): art.draw_arc(e.pos,e.radius+19,0,TAU,32,art.CORAL,5,true)
		if e.phase=="pursuit":
			art.draw_arc(e.pos,e.radius+12,0,TAU,32,art.CORAL,3,true)
		if e.phase not in ["telegraph","attack"]: continue
		if e.attack=="sweep":
			var end: Vector2=Vector2(e.pos)+Vector2(e.dir)*740
			art.draw_line(e.pos,end,Color(art.CORAL,0.2),46 if e.phase=="attack" else 2,true)
			art.draw_line(e.pos,end,art.CREAM if e.phase=="attack" else art.CORAL,4 if e.phase=="attack" else 2,true)
		elif e.attack=="melee": art.draw_arc(e.pos,155,Vector2(e.dir).angle()-PI*0.6,Vector2(e.dir).angle()+PI*0.6,48,art.CORAL,3,true)
	if not brackets.is_empty():
		art.draw_multiline(brackets,art.INK,5)
		art.draw_multiline(brackets,art.GOLD,2)
	if not sparks.is_empty():
		art.draw_multiline(sparks,art.INK,5)
		art.draw_multiline(sparks,art.CREAM,2)
	if run.vanguard.combo_left>0:
		art.draw_arc(run.player,28,-PI/2,-PI/2+TAU*run.vanguard.combo_left/(0.1 if ArsenalBurst.enabled(run) else 1.2),24,art.GOLD,3,true)

static func atmosphere(art) -> void:
	# Darken the environment before actors/tells, never the threat overlay.
	var run=art.model
	if not run.enemies.any(func(e): return not e.dead and e.has("exp_boss")): return
	art.draw_rect(Rect2(run.follow_origin()-Vector2.ONE*1000,run.view_size+Vector2.ONE*2000),Color(0.025,0.025,0.09,0.22))
	for wall in run.kit.extra.walls:
		for point in [wall.a,wall.b]: art.draw_circle(point,5,Color("d89969"))
