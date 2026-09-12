class_name SwarmSpacing
extends RefCounted
## Soft body separation, spatially bucketed and bounded by the population cap.
const CELL:=64.0
static func weight(e: Dictionary) -> float:
	if e.get("dummy",false) or e.has("role") or e.phase in ["aim","beam","windup","telegraph","dash"] or e.get("melee_phase","")=="aim": return 0.0
	return 1.0/maxf(1,float(e.radius)/14.0)
static func step(run, delta: float) -> void:
	if delta<=0 or (run.exp.practice and run.vanguard.freeze_ai): return
	var cells: Dictionary={}
	var offsets: Dictionary={}
	var weights: Dictionary={}
	var largest:=0.0
	for e in run.enemies:
		if e.dead: continue
		var cell:=Vector2i(floori(e.pos.x/CELL),floori(e.pos.y/CELL))
		if not cells.has(cell): cells[cell]=[]
		cells[cell].append(e); offsets[e.id]=Vector2.ZERO; weights[e.id]=weight(e)
		largest=maxf(largest,e.radius)
	for e in run.enemies:
		if e.dead: continue
		var cell:=Vector2i(floori(e.pos.x/CELL),floori(e.pos.y/CELL))
		var reach:=ceili((e.radius+largest+2)/CELL)
		for y in range(-reach,reach+1):
			for x in range(-reach,reach+1):
				for other in cells.get(cell+Vector2i(x,y),[]):
					if other.id<=e.id: continue
					var gap: Vector2=Vector2(e.pos)-Vector2(other.pos)
					var radius: float=e.radius+other.radius+2.0
					if gap.length_squared()>=radius*radius: continue
					var a: float=weights[e.id]; var b: float=weights[other.id]
					if a+b==0: continue
					var distance:=gap.length()
					var direction:=gap/distance if distance>0.01 else Vector2.from_angle(fmod(e.id*2.399+other.id*0.731,TAU))
					var correction:=direction*(radius-distance)*0.65
					offsets[e.id]+=correction*a/(a+b); offsets[other.id]-=correction*b/(a+b)
	for e in run.enemies:
		if e.dead or weights[e.id]==0: continue
		var movement: Vector2=Vector2(offsets[e.id]).limit_length(120*delta)
		if movement.length_squared()>0.0001:
			e.pos=ReviewEnemies.destination(run,e.pos,movement,movement.length(),e.radius)
