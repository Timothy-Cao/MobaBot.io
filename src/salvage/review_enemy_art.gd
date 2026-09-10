class_name ReviewEnemyArt
extends RefCounted

static func draw(art) -> void:
	var run=art.model
	for e in run.enemies:
		if e.dead: continue
		if float(e.get("vulnerable",0))>0:
			art.draw_arc(e.pos,e.radius+7,0,TAU,32,art.GOLD,2,true)
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
	if run.vanguard.combo_left>0:
		art.draw_arc(run.player,28,-PI/2,-PI/2+TAU*run.vanguard.combo_left/1.2,24,art.GOLD,3,true)

static func atmosphere(art) -> void:
	# Darken the environment before actors/tells, never the threat overlay.
	var run=art.model
	if not run.enemies.any(func(e): return not e.dead and e.has("exp_boss")): return
	art.draw_rect(Rect2(run.follow_origin()-Vector2.ONE*1000,run.view_size+Vector2.ONE*2000),Color(0.025,0.025,0.09,0.22))
	for wall in run.kit.extra.walls:
		for point in [wall.a,wall.b]: art.draw_circle(point,5,Color("d89969"))
