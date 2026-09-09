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
			if id=="returner":
				c.poly([Vector2(14,13),Vector2(48,25),Vector2(50,47),Vector2(37,36),Vector2(22,32)],c.STEEL)
				c.draw_arc(center,22,0.1,PI*1.2,30,c.GOLD,3,true)
			else:
				for i in range(3):
					var p:=Vector2(18+i*13,15+i*4)
					c.poly([p+Vector2(-5,-4),p+Vector2(6,-4),p+Vector2(4,9),p+Vector2(-6,8)],c.STEEL)
					c.line(p+Vector2(0,10),Vector2(32,48),c.TEAL,2)
				c.draw_polyline(PackedVector2Array([Vector2(22,41),Vector2(32,52),Vector2(42,41)]),c.GOLD,4,true)
		"gravity":
			for r in [11,18,24]: c.draw_arc(center,r,0.4+r*0.07,5.4+r*0.07,32,c.TEAL if r==24 else c.STEEL,3,true)
			c.draw_circle(center,7,c.INK); c.draw_circle(center,3,c.GOLD)
		"crosswire", "wall":
			if id=="crosswire":
				for p in [Vector2(16,44),Vector2(48,20)]:
					c.poly([p+Vector2(-5,-9),p+Vector2(5,-9),p+Vector2(7,9),p+Vector2(-7,9)],c.STEEL)
					c.draw_circle(p,3,c.GOLD)
				c.draw_polyline(PackedVector2Array([Vector2(18,43),Vector2(27,27),Vector2(36,36),Vector2(47,20)]),c.TEAL,3,true)
			else:
				for i in range(3):
					var x:=12+i*14
					c.poly([Vector2(x,22),Vector2(x+11,17),Vector2(x+11,44),Vector2(x,49)],c.STEEL)
					c.line(Vector2(x+4,27),Vector2(x+4,40),c.TEAL,3)
				c.line(Vector2(11,50),Vector2(53,45),c.GOLD,3)
		"strike", "landing", "artillery":
			if id=="strike":
				c.draw_arc(Vector2(32,43),18,0,TAU,32,c.TEAL,3,true)
				c.poly([Vector2(23,16),Vector2(41,16),Vector2(41,32),Vector2(32,42),Vector2(23,32)],c.STEEL)
				c.line(Vector2(32,12),Vector2(32,29),c.GOLD,5)
			elif id=="landing":
				c.poly([Vector2(17,12),Vector2(46,12),Vector2(50,28),Vector2(40,33),Vector2(24,33),Vector2(13,28)],c.TEAL)
				for x in [23,41]:
					c.line(Vector2(x,20),Vector2(x,30),c.STEEL,7)
					c.poly([Vector2(x-4,35),Vector2(x+4,35),Vector2(x,48)],c.GOLD)
				c.draw_arc(Vector2(32,45),19,0,PI,24,c.CREAM,3,true)
			else:
				for i in range(3):
					var p:=Vector2(16+i*16,17+abs(i-1)*10)
					c.poly([p+Vector2(-5,-6),p+Vector2(5,-6),p+Vector2(5,7),p+Vector2(0,13),p+Vector2(-5,7)],c.STEEL)
					c.line(p+Vector2(0,13),p+Vector2(0,19),c.GOLD,3)
				c.line(Vector2(12,53),Vector2(52,53),c.TEAL,3)
		"reap", "sweep":
			c.poly([Vector2(12,44),Vector2(31,23),Vector2(47,14),Vector2(41,31),Vector2(20,51)],c.STEEL)
			c.draw_circle(Vector2(22,42),6,c.TEAL)
			if id=="reap": c.draw_arc(center,23,-0.7,2.9,32,c.GOLD,4,true); c.draw_arc(center,17,-0.7,2.9,28,c.TEAL,2,true)
			elif id=="sweep": c.poly([Vector2(9,14),Vector2(23,11),Vector2(25,29),Vector2(17,36),Vector2(9,28)],c.TEAL)
		"thrust":
			c.poly([Vector2(10,36),Vector2(24,36),Vector2(24,51),Vector2(10,51)],c.TEAL)
			c.line(Vector2(20,42),Vector2(39,23),c.STEEL,9)
			c.line(Vector2(24,39),Vector2(42,20),c.CREAM,3)
			c.poly([Vector2(32,18),Vector2(53,11),Vector2(47,33),Vector2(43,22)],c.STEEL)
			c.line(Vector2(13,30),Vector2(20,23),c.GOLD,3)
			c.line(Vector2(29,51),Vector2(36,44),c.GOLD,3)
		"tractor", "repulsor":
			c.poly([Vector2(9,24),Vector2(24,19),Vector2(28,25),Vector2(28,41),Vector2(22,47),Vector2(9,42)],c.STEEL)
			c.line(Vector2(21,25),Vector2(21,40),c.TEAL,5)
			for i in range(2):
				var x:=35+i*13
				var tip:=x-5 if id=="tractor" else x+5
				c.draw_polyline(PackedVector2Array([Vector2(x,22),Vector2(tip,32),Vector2(x,42)]),c.GOLD,3,true)
		"repair_channel", "consume":
			c.poly([Vector2(17,14),Vector2(47,14),Vector2(50,49),Vector2(14,49)],c.TEAL)
			if id=="repair_channel": c.line(Vector2(32,23),Vector2(32,43),c.CREAM,7); c.line(Vector2(22,33),Vector2(42,33),c.CREAM,7)
			else: c.poly([Vector2(20,24),Vector2(32,33),Vector2(44,24),Vector2(40,42),Vector2(24,42)],c.INK)
		"roller":
			c.draw_circle(center,22,c.STEEL); c.draw_circle(center,15,c.TEAL); c.draw_circle(center,6,c.GOLD)
			c.line(Vector2(9,46),Vector2(25,46),c.CREAM,3)
		"tumble":
			c.poly([Vector2(13,39),Vector2(36,15),Vector2(50,17),Vector2(48,31),Vector2(25,51)],c.TEAL)
			c.line(Vector2(23,39),Vector2(40,22),c.STEEL,7)
			c.draw_arc(Vector2(25,37),20,PI,TAU,28,c.GOLD,3,true)
		"echo_dash":
			for p in [Vector2(16,44),Vector2(47,20)]: c.draw_arc(p,10,0,TAU,24,c.STEEL,4,true); c.draw_circle(p,4,c.TEAL)
			c.draw_polyline(PackedVector2Array([Vector2(17,31),Vector2(25,17),Vector2(36,17)]),c.GOLD,3,true)
			c.draw_polyline(PackedVector2Array([Vector2(47,33),Vector2(40,47),Vector2(29,47)]),c.GOLD,3,true)
		"veil_dash":
			c.poly([Vector2(30,10),Vector2(45,20),Vector2(49,49),Vector2(38,45),Vector2(29,51),Vector2(16,45),Vector2(18,20)],c.TEAL)
			c.line(Vector2(23,26),Vector2(39,26),c.INK,8); c.line(Vector2(27,25),Vector2(35,25),c.CREAM,3)
			c.line(Vector2(9,36),Vector2(24,36),c.STEEL,3); c.line(Vector2(6,43),Vector2(21,43),c.GOLD,3)
		"hop":
			c.draw_arc(Vector2(32,35),21,PI,TAU,28,c.GOLD,3,true)
			c.poly([Vector2(22,26),Vector2(39,26),Vector2(44,36),Vector2(40,43),Vector2(20,43)],c.STEEL)
			c.draw_polyline(PackedVector2Array([Vector2(21,46),Vector2(40,49),Vector2(23,52),Vector2(40,55)]),c.TEAL,3,true)
		"vault":
			c.poly([Vector2(28,26),Vector2(39,23),Vector2(41,52),Vector2(28,55)],c.STEEL)
			c.draw_arc(Vector2(31,29),21,PI,TAU,28,c.GOLD,4,true)
			c.draw_polyline(PackedVector2Array([Vector2(45,14),Vector2(53,28),Vector2(42,25)]),c.CREAM,3,true)
		"pursuit":
			c.draw_arc(Vector2(43,21),12,0,TAU,24,c.GOLD,3,true)
			c.line(Vector2(43,6),Vector2(43,13),c.CREAM,2); c.line(Vector2(51,21),Vector2(58,21),c.CREAM,2)
			c.poly([Vector2(10,40),Vector2(20,48),Vector2(38,30),Vector2(42,35),Vector2(44,21),Vector2(29,23),Vector2(34,27)],c.STEEL)
			c.line(Vector2(9,51),Vector2(18,42),c.TEAL,4)
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
