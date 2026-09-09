class_name ExpeditionArt
extends RefCounted

static func draw(c, run) -> void:
	var engine: BotSkillEngine = run.kit.extra
	for wall in engine.walls:
		c.draw_line(wall.a,wall.b,c.INK,18,true)
		c.draw_line(wall.a,wall.b,c.PALE,11,true)
		c.draw_line(wall.a+Vector2(0,-3),wall.b+Vector2(0,-3),c.CREAM,2,true)
	for f in engine.fields:
		if f.kind=="cone":
			var cone:=PackedVector2Array([f.pos])
			for i in range(21): cone.append(f.pos+Vector2(f.direction).rotated(lerpf(-PI*0.34,PI*0.34,i/20.0))*f.radius)
			c.draw_colored_polygon(cone,Color(c.PALE,0.13))
			cone.append(f.pos); c.draw_polyline(cone,c.GOLD,2,true)
			continue
		c.draw_circle(f.pos,f.radius,Color(c.PALE,0.07))
		c.draw_arc(f.pos,f.radius,0,TAU,64,c.PALE,2,true)
		if f.kind=="gravity":
			for i in range(3): c.draw_arc(f.pos,f.radius*(0.25+i*0.24),run.time*2+i,run.time*2+i+3.8,32,c.GOLD,2,true)
		elif f.kind=="strike": c.draw_arc(f.pos,f.radius*0.35,0,TAU,32,c.GOLD,2,true)
	for r in engine.recasts.values():
		if r.has("pos"):
			c.draw_circle(r.pos,8,c.INK); c.draw_arc(r.pos,16,0,TAU,24,c.GOLD,3,true)
	for b in engine.blades:
		c.draw_set_transform(b.pos,run.time*14)
		c.draw_colored_polygon(PackedVector2Array([Vector2(-b.width,-5),Vector2(-3,-b.width),Vector2(b.width,-3),Vector2(4,b.width)]),c.PALE)
		c.draw_circle(Vector2.ZERO,4,c.GOLD)
		c.draw_set_transform(Vector2.ZERO)
	for plate in engine.plates:
		c.draw_line(plate-Vector2(5,5),plate+Vector2(5,5),c.PALE,6,true)
	for unit in engine.summons:
		var p: Vector2 = unit.pos
		c.draw_circle(p+Vector2(0,5),19,c.INK)
		c.draw_line(p+Vector2(-19,14),p+Vector2(0,-8),c.PALE,5,true)
		c.draw_line(p+Vector2(19,14),p+Vector2(0,-8),c.PALE,5,true)
		c.draw_circle(p,14,c.PALE); c.draw_circle(p,10,c.INK)
		if unit.id=="medic_sentry": c.draw_line(p-Vector2(6,0),p+Vector2(6,0),c.CREAM,3,true); c.draw_line(p-Vector2(0,6),p+Vector2(0,6),c.CREAM,3,true)
		elif unit.id=="mirror_sentry": c.draw_circle(p-Vector2(4,0),3,c.GOLD); c.draw_circle(p+Vector2(4,0),3,c.GOLD)
		elif unit.id=="pulse_sentry": c.draw_arc(p,7,0,TAU,20,c.GOLD,3,true); c.draw_circle(p,2,c.CREAM)
		elif unit.id=="hook_sentry": c.draw_arc(p,7,-PI,PI/2,20,c.GOLD,3,true); c.draw_line(p+Vector2(0,7),p+Vector2(0,-14),c.GOLD,3,true)
		elif unit.id=="crawler":
			c.draw_circle(p,5,c.GOLD)
			for side in [-1,1]: c.draw_line(p+Vector2(side*16,-9),p+Vector2(side*16,9),c.CREAM,5,true)
		else: c.draw_line(p,p+Vector2(unit.direction)*23,c.GOLD,5,true)
		c.draw_arc(p,21,-PI/2,-PI/2+TAU*minf(1,unit.life/20),32,Color(c.PALE,0.5),1,true)
	if engine.repair_left>0: c.draw_arc(run.player,34,0,TAU*engine.repair_left/3,40,c.PALE,3,true)
	if engine.roll_left>0: c.draw_arc(run.player,32,run.time*10,run.time*10+4.7,32,c.GOLD,5,true)
	if run.exp != null:
		for chest in run.exp.loot_chests:
			c.draw_rect(Rect2(chest.pos-Vector2(15,11),Vector2(30,22)),c.INK)
			c.draw_rect(Rect2(chest.pos-Vector2(12,8),Vector2(24,16)),c.GOLD)
			c.draw_line(chest.pos-Vector2(0,8),chest.pos+Vector2(0,8),c.CREAM,4,true)
