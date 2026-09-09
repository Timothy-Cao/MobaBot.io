extends RefCounted
## Short follow-through, never delayed damage or a second gameplay clock.
static func draw(c, e: Dictionary) -> bool:
	var t:=clampf(float(e.age)/e.life,0,1)
	var fade:=1-t
	var p: Vector2=e.pos
	if e.kind=="skill_cut":
		fade=1-pow(t,3) # Hold a readable cutting edge, then clear promptly.
		if e.style=="reap":
			var radius: float=e.radius
			c.draw_arc(p,radius,0,TAU,64,Color(c.PALE,fade*0.45),1.5,true)
			c.draw_arc(p,e.inner,0,TAU,48,Color(c.TEAL,fade*0.35),1,true)
			var angle: float=Vector2(e.direction).angle()+t*TAU
			var edge:=PackedVector2Array()
			for i in range(9): edge.append(p+Vector2.from_angle(angle-0.65+i*0.085)*(radius-2))
			for i in range(8,-1,-1): edge.append(p+Vector2.from_angle(angle-0.65+i*0.085)*(radius-13))
			c.draw_colored_polygon(edge,Color(c.PALE,fade))
			c.draw_arc(p,radius-2,angle-0.65,angle+0.03,20,Color(c.CREAM,fade),2,true)
			for i in range(1 if c.reduced_effects else 3):
				var a: float=angle-i*0.17
				c.draw_arc(p,radius-3-i*4,a-1.8,a,32,Color(c.GOLD if i==0 else c.PALE,fade*(1-i*0.25)),4 if i==0 else 2,true)
		else:
			var end: Vector2=e.target
			var d: Vector2=(end-p).normalized()
			var side:=d.orthogonal()*float(e.width)*0.45
			var extension:=minf(1,t/0.2)
			var tip:=p.lerp(end,extension)
			c.draw_line(p,tip,Color(c.PALE,fade),5,true)
			var head:=PackedVector2Array([tip,tip-d*25+side*0.7,tip-d*18,tip-d*25-side*0.7])
			c.draw_colored_polygon(head,Color(c.PALE,fade))
			c.draw_line(p+d*24,p+d*65,Color(c.TEAL,fade),9,true)
			c.draw_polyline(PackedVector2Array([tip-d*24+side,tip,tip-d*24-side]),Color(c.GOLD if e.get("empowered",false) else c.CREAM,fade),3,true)
			if e.get("empowered",false):
				for sign_value in [-1,1]: c.draw_line(p+side*sign_value,tip+side*sign_value,Color(c.TEAL,fade*0.6),2,true)
		return true
	if e.kind in ["nuke_impact","rocket_impact"]:
		var radius: float=e.radius
		var expansion:=1-pow(1-t,3)
		c.draw_arc(p,radius*(0.3+0.7*expansion),0,TAU,64,Color(c.PALE,fade*0.7),4*fade+1,true)
		if not c.reduced_effects:
			c.draw_arc(p,radius*expansion*0.72,0,TAU,48,Color(c.GOLD,fade*0.35),2,true)
		var count:=4 if c.reduced_effects else 7
		for i in range(count):
			var d:=Vector2.from_angle(i*TAU/count+0.3)
			var at:=p+d*radius*expansion*0.85
			var side:=d.orthogonal()*(3+radius*0.015)*fade
			var length: float=(8+radius*0.05)*fade
			c.draw_colored_polygon(PackedVector2Array([at,at-d*length+side,at-d*length*1.6,at-d*length-side]),Color(c.GOLD,fade*0.8))
		# No opaque expanding disc: player, ground and hostile projectiles stay visible.
		return true
	if e.kind!="cast": return false
	var id: String=e.get("ability","")
	if id in ["tumble","echo_dash","veil_dash","hop","vault","pursuit","landing"]:
		var end: Vector2=e.target
		var d: Vector2=(end-p).normalized()
		if d==Vector2.ZERO: return true
		var distance: float=p.distance_to(end)
		for sign_value in [-1,1]:
			var side: Vector2=d.orthogonal()*11*sign_value
			c.draw_line(p+side,p.lerp(end,minf(0.7,t*1.7))+side,Color(c.TEAL,fade*0.4),2,true)
		var count:=1 if c.reduced_effects else 3
		for i in range(count):
			var at:=p+d*minf(distance,(i+1)*18+t*25)
			ExpeditionArt.chevron(c,at,d,Color(c.PALE,fade*0.7),6)
		if id in ["echo_dash","veil_dash"]: c.draw_arc(p,20,0,TAU,24,Color(c.TEAL,fade*0.65),2,true)
		return true
	if id=="consume":
		var target: Vector2=e.target
		for side in [-1,1]:
			var x: float=side*lerpf(22,5,minf(1,t*3))
			c.draw_polyline(PackedVector2Array([target+Vector2(x*0.65,-12),target+Vector2(x,-8),target+Vector2(x,8),target+Vector2(x*0.65,12)]),Color(c.PALE,fade),5,true)
		return true
	return false
