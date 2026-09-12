class_name FactoryFinish
extends RefCounted
## Quiet, flush floor materials and inset machinery. No simulation or RNG writes.
static func floor_draw(c, view: Rect2, sector: int) -> void:
	var base: Color=[Color("2b393c"),Color("353534"),Color("29383f")][sector]
	c.draw_rect(view,base)
	var tile:=Vector2(480,360)
	for x in range(int(floor(view.position.x/tile.x)),int(ceil(view.end.x/tile.x))):
		for y in range(int(floor(view.position.y/tile.y)),int(ceil(view.end.y/tile.y))):
			var p:=Vector2(x,y)*tile
			var seed_value:=posmod(x*73+y*131,17)
			var tone:=base.lightened(0.012+seed_value*0.0015)
			c.draw_rect(Rect2(p+Vector2(2,2),tile-Vector2(4,4)),tone)
			c.draw_line(p+Vector2(3,3),p+Vector2(477,3),base.lightened(0.065),1)
			# Sparse wear has no raised edge or collision-like shadow.
			for i in range(3):
				var at:=p+Vector2(34+posmod(seed_value*41+i*97,400),38+posmod(seed_value*29+i*83,270))
				c.draw_line(at,at+Vector2(9+i*7,-2),Color("89958a",0.09),2)
			if sector==0:
				# Concrete loading slabs: interrupted tyre scuffs, small bay stencils.
				if seed_value%3==0:
					for lane in [0,17]: c.draw_line(p+Vector2(80+lane,130),p+Vector2(110+lane,240),Color("17282b",0.34),7)
				if seed_value%4==0:
					c.draw_string(c.stencil_font,p+Vector2(360,320),"%02d"%(seed_value+1),HORIZONTAL_ALIGNMENT_LEFT,-1,28,Color("a8a083",0.22))
			elif sector==1:
				# Riveted steel and recessed service strips.
				for at in [Vector2(12,12),Vector2(468,348)]: c.draw_circle(p+at,2,Color("78817a",0.24))
				if seed_value%3==0:
					c.draw_rect(Rect2(p+Vector2(100,295),Vector2(160,26)),Color("1b292c"))
					for i in range(13): c.draw_line(p+Vector2(108+i*12,299),p+Vector2(108+i*12,317),Color("586566",0.45),3)
			else:
				# Cooling deck: access hatches and short recessed coolant conduits.
				if seed_value%3==0:
					c.draw_rect(Rect2(p+Vector2(270,220),Vector2(115,75)),Color("213239"))
					c.draw_rect(Rect2(p+Vector2(276,226),Vector2(103,63)),Color("496269",0.3),false,2)
					for i in range(5): c.draw_line(p+Vector2(287,238+i*10),p+Vector2(368,238+i*10),Color("536b70",0.28),3)
				if seed_value%4==1:
					for i in [0,8]: c.draw_line(p+Vector2(0,70+i),p+Vector2(185,70+i),Color("61878a",0.2),2)

static func plate(c, rect: Rect2, color: Color, bevel: float=5.0) -> void:
	c.draw_rect(rect,Color("112329"))
	c.draw_rect(rect.grow(-2),color.darkened(0.3))
	c.draw_rect(Rect2(rect.position+Vector2(3,3),rect.size-Vector2(6,bevel+3)),color)
	c.draw_line(rect.position+Vector2(3,3),rect.position+Vector2(rect.size.x-3,3),color.lightened(0.2),2)

static func machine(c, m: Dictionary, level: int) -> void:
	var p: Vector2=m.target
	var tint:=Color("d5b36f") if level!=3 else Color("76c6bd")
	var ready: bool=m.cooldown<=0 or m.armed
	var lit: Color=tint if ready else Color("536b70")
	# Orthogonal recessed cable, with a quiet colored conductor.
	var elbow:=Vector2(m.pad.x,p.y+110)
	var cable:=PackedVector2Array([m.pad,elbow,Vector2(p.x,p.y+110),p])
	c.draw_polyline(cable,Color("14262d"),10)
	c.draw_polyline(cable,Color(lit,0.35),2)
	match level:
		1: crane(c,p,tint,m)
		2: press(c,p,tint,m)
		3: cooler(c,p,tint,m)
	# Small inset pedal: the surrounding ring is the actual activation radius.
	c.draw_circle(m.pad,43,Color("13272e"))
	c.draw_arc(m.pad,40,0,TAU,32,lit,3,true)
	plate(c,Rect2(m.pad-Vector2(27,24),Vector2(54,48)),Color("435b61"))
	for i in range(4): c.draw_line(m.pad+Vector2(-20,-13+i*8),m.pad+Vector2(20,-13+i*8),Color("243b42"),3)
	for side in [-1,1]: ExpeditionArt.chevron(c,m.pad+Vector2(side*33,0),Vector2(-side,0),lit,6)
	c.draw_rect(Rect2(m.pad+Vector2(-9,-20),Vector2(18,4)),lit)
	if m.cooldown>0: c.draw_arc(m.pad,46,-PI/2,-PI/2+TAU*clampf(1-m.cooldown/45,0,1),32,tint,3,true)
	if m.armed: c.draw_arc(m.pad,46,-PI/2,-PI/2+TAU*clampf(1-m.windup/0.8,0,1),32,tint,4,true)

static func crane(c, p: Vector2, tint: Color, m: Dictionary) -> void:
	# Flush rail bed; the trolley and magnetic head give the pickup machine weight.
	c.draw_rect(Rect2(p-Vector2(168,138),Vector2(336,276)),Color("1c3036",0.45))
	for x in [-153,153]:
		for y in range(-130,140,32): c.draw_rect(Rect2(p+Vector2(x-9,y),Vector2(18,8)),Color("253f47"))
		c.draw_line(p+Vector2(x,-138),p+Vector2(x,138),Color("172c33"),10)
		c.draw_line(p+Vector2(x-2,-138),p+Vector2(x-2,138),Color("6d8180"),3)
	var travel: float=40*(1-m.active) if m.active>0 else 0
	var at:=p+Vector2(0,-75+travel)
	plate(c,Rect2(at-Vector2(168,17),Vector2(336,34)),Color("877955"))
	for x in [-157,141]: plate(c,Rect2(at+Vector2(x,-23),Vector2(18,48)),Color("526b70"))
	for x in range(-130,131,32): c.draw_line(at+Vector2(x,-9),at+Vector2(x+15,10),Color("413f35"),5)
	plate(c,Rect2(at-Vector2(33,24),Vector2(66,48)),Color("627a7c"))
	for x in [-8,8]: c.draw_line(at+Vector2(x,18),p+Vector2(x,10),Color("b3b0a0"),3)
	c.draw_circle(p+Vector2(0,17),31,Color("14292f"))
	c.draw_circle(p+Vector2(0,12),26,Color("76847d"))
	c.draw_arc(p+Vector2(0,12),19,0,TAU,24,tint,5,true)
	c.draw_circle(p+Vector2(0,12),11,Color("263f45"))
	if m.active>0: c.draw_arc(p,80+100*(1-m.active),0,TAU,40,Color(tint,m.active*0.7),3)

static func press(c, p: Vector2, tint: Color, m: Dictionary) -> void:
	# Inset segmented workbed. The thin perimeter remains the exact damage radius.
	c.draw_circle(p,210,Color("1c282b",0.6))
	c.draw_circle(p,178,Color("3d4140"))
	c.draw_arc(p,178,0,TAU,48,Color("606961"),5,true)
	for i in range(8):
		var angle:=i*TAU/8
		var d:=Vector2.from_angle(angle)
		c.draw_line(p+d*54,p+d*170,Color("273638"),4)
		c.draw_arc(p,199,angle+0.025,angle+0.21,8,Color(tint,0.45),9,true)
		c.draw_line(p+d*182,p+d*192,Color("152c32"),3)
	c.draw_circle(p,54,Color("223338"))
	c.draw_arc(p,49,0,TAU,24,Color("66716b"),3,true)
	for y in [-18,0,18]: c.draw_line(p+Vector2(-30,y),p+Vector2(30,y),Color("4b5a59"),4)
	c.draw_arc(p,210,0,TAU,64,Color(tint,0.35),2,true)
	if m.armed or m.active>0:
		var amount: float=clampf(1-m.windup/0.8 if m.armed else m.active/0.7,0,1)
		c.draw_circle(p,210*amount,Color(tint,0.12))
		c.draw_arc(p,210*amount,0,TAU,48,tint,4,true)

static func cooler(c, p: Vector2, tint: Color, m: Dictionary) -> void:
	c.draw_circle(p,100,Color("142a32"))
	c.draw_circle(p,94,Color("49646c"))
	c.draw_circle(p,78,Color("152e37"))
	for i in range(8):
		var d:=Vector2.from_angle(i*TAU/8)
		c.draw_circle(p+d*86,3,Color("9daea3"))
	# Static turbine under a protective grille; no ambient spin in reduced effects.
	for i in range(6):
		var d:=Vector2.from_angle(i*TAU/6)
		c.draw_colored_polygon(PackedVector2Array([p+d*14,p+d.rotated(0.45)*65,p+d.rotated(0.8)*60,p+d.rotated(0.6)*24]),Color("4c7378"))
	for y in range(-54,55,18):
		var width:=sqrt(70*70-y*y)
		c.draw_line(p+Vector2(-width,y),p+Vector2(width,y),Color("1b3740"),5)
	c.draw_circle(p,15,Color("74958e"))
	c.draw_arc(p,95,PI*1.1,PI*1.9,24,Color(tint,0.65),3,true)
	if m.active>0:
		c.draw_circle(p,300,Color(tint,0.05))
		c.draw_arc(p,300,0,TAU,64,Color(tint,0.55),3,true)
		for i in range(8):
			var d:=Vector2.from_angle(i*TAU/8)
			ExpeditionArt.chevron(c,p+d*282,-d,Color(tint,0.5),9)
