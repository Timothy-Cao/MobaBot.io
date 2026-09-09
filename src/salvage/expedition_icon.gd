class_name ExpeditionIcon
extends RefCounted
## Eight equipment silhouettes × five materials. Native art, not forty unrelated paintings.
static func draw(c, id: String) -> bool:
	var center := Vector2(32,32)
	if id.begins_with("gear_"):
		var bits := id.split("_")
		var slot: String = bits[2]
		var material: Color = {"courier": c.TEAL, "bastion": c.STEEL, "dynamo": c.GOLD, "relay": Color("6aadb4"), "reclaimer": Color("98bba3")}[bits[1]]
		match slot:
			"helmet":
				c.poly([Vector2(13,43),Vector2(16,24),Vector2(24,14),Vector2(43,14),Vector2(51,25),Vector2(51,43)],material)
				c.line(Vector2(19,35),Vector2(45,35),c.INK,8); c.line(Vector2(22,34),Vector2(29,34),c.CREAM,3)
			"chest":
				c.poly([Vector2(9,19),Vector2(23,14),Vector2(32,23),Vector2(41,14),Vector2(55,19),Vector2(47,49),Vector2(32,55),Vector2(17,49)],material)
				c.line(Vector2(22,30),Vector2(42,30),c.CREAM,4); c.line(Vector2(32,33),Vector2(32,47),c.INK,3)
			"legs":
				c.poly([Vector2(18,13),Vector2(46,13),Vector2(49,51),Vector2(35,51),Vector2(32,28),Vector2(29,51),Vector2(15,51)],material)
				c.line(Vector2(20,21),Vector2(44,21),c.GOLD,4)
			"boots":
				for x in [13,35]: c.poly([Vector2(x,15),Vector2(x+12,15),Vector2(x+11,39),Vector2(x+18,43),Vector2(x+18,51),Vector2(x-2,51)],material)
			"charm":
				c.draw_arc(Vector2(32,19),10,PI,TAU,24,c.STEEL,3,true)
				c.poly([Vector2(21,25),Vector2(43,25),Vector2(47,44),Vector2(32,55),Vector2(17,44)],material)
			"ring":
				c.draw_circle(center,21,c.INK); c.draw_arc(center,17,0,TAU,40,material,9,true); c.draw_circle(Vector2(43,18),8,c.STEEL); c.draw_circle(Vector2(43,18),4,c.GOLD)
			"flower":
				for i in range(6):
					var p := center + Vector2.from_angle(i*TAU/6)*15
					c.poly([p+Vector2(-7,0),p+Vector2(0,-10),p+Vector2(7,0),p+Vector2(0,10)],material)
				c.draw_circle(center,8,c.INK); c.draw_circle(center,5,c.GOLD)
			"cape":
				c.poly([Vector2(23,11),Vector2(41,11),Vector2(52,52),Vector2(12,52)],material)
				for i in range(3): c.line(Vector2(20-i*2,24+i*9),Vector2(44+i*2,24+i*9),c.INK,2)
		var motif: int = ExpeditionGear.SETS.find(bits[1])
		for i in range(motif+1): c.draw_circle(Vector2(26+i*3,39),1.5,c.CREAM)
		return true
	if not BotSkillCatalog.SPECS.has(id): return false
	match id:
		"returner", "recall":
			c.poly([Vector2(14,13),Vector2(48,25),Vector2(50,47),Vector2(37,36),Vector2(22,32)],c.STEEL)
			c.draw_arc(center,22,0.1,PI*1.2,30,c.GOLD,3,true)
			if id == "recall": c.line(Vector2(16,48),Vector2(37,36),c.LIGHT,3)
		"gravity":
			for r in [11,18,24]: c.draw_arc(center,r,0.4+r*0.07,5.4+r*0.07,32,c.TEAL if r==24 else c.STEEL,3,true)
			c.draw_circle(center,7,c.INK); c.draw_circle(center,3,c.GOLD)
		"crosswire", "wall":
			for p in [Vector2(16,44),Vector2(48,20)]: c.poly([p+Vector2(-6,-10),p+Vector2(6,-10),p+Vector2(8,10),p+Vector2(-8,10)],c.STEEL)
			c.line(Vector2(18,43),Vector2(47,20),c.TEAL,8 if id=="wall" else 3)
			c.line(Vector2(18,39),Vector2(47,16),c.CREAM,2)
		"strike", "landing", "artillery":
			c.draw_arc(Vector2(32,43),20,0,TAU,32,c.TEAL,3,true)
			c.bolt(Vector2(32,26),1.4)
			if id=="artillery": c.draw_circle(Vector2(14,16),4,c.GOLD); c.draw_circle(Vector2(48,16),4,c.GOLD)
			if id=="landing": c.line(Vector2(18,12),Vector2(28,32),c.CREAM,3)
		"reap", "sweep", "tractor", "repulsor", "thrust":
			c.poly([Vector2(12,44),Vector2(31,23),Vector2(47,14),Vector2(41,31),Vector2(20,51)],c.STEEL)
			c.draw_circle(Vector2(22,42),6,c.TEAL)
			if id in ["reap","sweep"]: c.draw_arc(center,23,-0.7,2.9,32,c.GOLD,4,true)
			elif id=="thrust": c.line(Vector2(36,29),Vector2(54,10),c.CREAM,3)
			else:
				for i in range(3): c.line(Vector2(14+i*8,12),Vector2(18+i*8,23),c.TEAL,3)
		"repair_channel", "consume":
			c.poly([Vector2(17,14),Vector2(47,14),Vector2(50,49),Vector2(14,49)],c.TEAL)
			if id=="repair_channel": c.line(Vector2(32,23),Vector2(32,43),c.CREAM,7); c.line(Vector2(22,33),Vector2(42,33),c.CREAM,7)
			else: c.poly([Vector2(20,24),Vector2(32,33),Vector2(44,24),Vector2(40,42),Vector2(24,42)],c.INK)
		"roller":
			c.draw_circle(center,22,c.STEEL); c.draw_circle(center,15,c.TEAL); c.draw_circle(center,6,c.GOLD)
			c.line(Vector2(9,46),Vector2(25,46),c.CREAM,3)
		"tumble", "echo_dash", "veil_dash", "hop", "vault":
			c.poly([Vector2(13,39),Vector2(36,15),Vector2(50,17),Vector2(48,31),Vector2(25,51)],c.TEAL)
			c.line(Vector2(23,39),Vector2(40,22),c.STEEL,7)
			c.draw_arc(Vector2(25,37),20,PI,TAU,28,c.GOLD,3,true)
			for i in range(["tumble","echo_dash","veil_dash","hop","vault"].find(id)+1): c.line(Vector2(12+i*7,51),Vector2(16+i*7,55),c.CREAM,2)
		"pursuit": c.bolt(center,1.7); c.draw_arc(Vector2(43,19),12,0,TAU,24,c.GOLD,2,true)
		_:
			c.poly([Vector2(14,47),Vector2(20,27),Vector2(44,27),Vector2(50,47)],c.STEEL)
			c.draw_circle(Vector2(32,27),14,c.TEAL)
			var key: String = {"forward_sentry":"line","pulse_sentry":"ring","medic_sentry":"cross","mirror_sentry":"pair","hook_sentry":"hook","crawler":"legs"}.get(id,"")
			match key:
				"cross": c.line(Vector2(32,17),Vector2(32,37),c.CREAM,4); c.line(Vector2(22,27),Vector2(42,27),c.CREAM,4)
				"ring": c.draw_arc(Vector2(32,27),8,0,TAU,24,c.GOLD,3,true)
				"pair": c.draw_circle(Vector2(26,25),5,c.CREAM); c.draw_circle(Vector2(38,25),5,c.GOLD)
				"hook": c.draw_arc(Vector2(32,23),8,0,PI*1.6,24,c.GOLD,3,true)
				"legs": c.line(Vector2(17,44),Vector2(10,54),c.GOLD,4); c.line(Vector2(47,44),Vector2(54,54),c.GOLD,4)
				_: c.line(Vector2(32,27),Vector2(49,10),c.CREAM,6)
	return true
