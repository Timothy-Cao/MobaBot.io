class_name FactoryMaps
extends RefCounted
## Fixed route geometry, independent of player position, camera and loot RNG.
const CENTER:=Vector2(480,300)
const NAMES:=["Loading yard","Assembly hall","Cooling plant"]
static func enabled(run) -> bool:
	return DemoPacing.enabled(run) and run.kit.loadout.get("factory31",false)==true
static func enable(run) -> void:
	run.kit.loadout.factory31=true; run.player=CENTER; run.kit.pet_position=CENTER; build(run)
static func layout(level: int, round_index: int) -> Array:
	var result: Array=[]
	if level==1:
		# Paired loading islands leave a broad, open central apron.
		for row in [-1,1]:
			for col in [-2,-1,0,1,2]:
				var p:=Vector2(col*820+row*100,row*470)
				add(result,p,Vector2.RIGHT,110 if col%2 else 155,65,2)
		for side in [-1,1]: add(result,Vector2(side*1900,0),Vector2.UP,140,75,0)
	elif level==2:
		# Interrupted parallel lines: broad crossovers, never a sealed corridor.
		for row in [-1,0,1]:
			for col in [-2,-1,1,2]:
				add(result,Vector2(col*790,row*650+120),Vector2.RIGHT,225,70,0)
		for side in [-1,1]: add(result,Vector2(0,side*900),Vector2.UP,110,65,2)
	else:
		# Four cooling banks bound a spacious court; corners remain open.
		for side in [-1,1]:
			add(result,Vector2(0,side*570),Vector2.RIGHT,270,100,1)
			add(result,Vector2(side*760,0),Vector2.UP,240,100,1)
			for row in [-1,1]:
				add(result,Vector2(side*1650,row*850),Vector2.RIGHT,150,80,1)
			add(result,Vector2(side*1850,0),Vector2.UP,160,75,2)
	# Alternate stagger/diagonal variants while preserving the level's route identity.
	for wall in result:
		for key in ["a","b"]:
			var p: Vector2=wall[key]
			if round_index==1: p.y=-p.y; p.x+=45 if int(wall.uid)%2 else -45
			elif round_index==2: p=p.rotated(0.12 if level!=2 else -0.08)
			wall[key]=CENTER+p
	return result
static func add(result: Array, p: Vector2, axis: Vector2, half: float, width: float, theme: int) -> void:
	result.append({"uid":-3100-result.size(),"a":p-axis*half,"b":p+axis*half,"width":width,"life":99999.0,"terrain":true,"factory_theme":theme})
static func build(run) -> void:
	run.kit.extra.walls.assign(FactoryWorks.layout(run.exp.operation_chapter,run.exp.route_index) if DiscoveryRules.enabled(run) else layout(run.exp.operation_chapter,run.exp.route_index))
static func floor_art(c, run) -> void:
	var level: int=run.exp.operation_chapter
	var view:=Rect2(run.camera_origin(),run.view_size).grow(100)
	var paint:=Color("849084",0.26)
	# Flush markings communicate routes; only raised machines block movement.
	if level==1:
		for col in range(-2,3):
			for side in [-1,1]:
				var bay:=Rect2(CENTER+Vector2(col*820-250,side*470-230),Vector2(500,460))
				if view.intersects(bay): c.draw_rect(bay,paint,false,3)
	elif level==2:
		for row in [-1,0,1]:
			var y: float=CENTER.y+row*650+120
			for side in [-1,1]:
				c.draw_line(Vector2(maxf(view.position.x,-2100),y+side*110),Vector2(minf(view.end.x,3060),y+side*110),paint,3)
			for col in range(-5,6):
				var p:=CENTER+Vector2(col*400,row*650+330)
				if view.has_point(p): ExpeditionArt.chevron(c,p,Vector2.RIGHT if row!=0 else Vector2.LEFT,paint,20)
	else:
		for radius in [400,950]:
			c.draw_arc(CENTER,radius,0,TAU,96,paint,4,true)
		for side in [-1,1]:
			c.draw_line(CENTER+Vector2(side*1000,-1200),CENTER+Vector2(side*1000,1200),Color("618d91",0.25),8)
	if view.has_point(CENTER+Vector2(-200,-200)):
		c.draw_string(c.stencil_font,CENTER+Vector2(-200,-200),NAMES[level-1].to_upper(),HORIZONTAL_ALIGNMENT_LEFT,-1,30,paint)
