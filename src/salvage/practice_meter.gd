class_name PracticeMeter
extends RefCounted
## Scratch measurement only. Simulation time excludes paused configuration.
var numbers := true
var clock := 0.0
var targets: Dictionary = {}
var hits: Array[Dictionary] = []

func clear() -> void:
	targets.clear(); hits.clear(); clock=0

func tick(delta: float) -> void:
	clock+=delta
	for id in targets.keys():
		if clock-float(targets[id].last)>=3.0: targets.erase(id)
	hits=hits.filter(func(hit): return clock-float(hit.time)<0.7)

func record(enemy: Dictionary, amount: float) -> void:
	if amount<=0: return
	var id: int=enemy.id
	if enemy.get("dummy",false):
		if not targets.has(id) or clock-float(targets[id].last)>=3.0:
			targets[id]={"first":clock,"last":clock,"total":0.0,"dps":0.0}
		var sample: Dictionary=targets[id]
		sample.total+=amount; sample.last=clock
		# One instantaneous hit has no measurable duration; do not invent DPS.
		sample.dps=sample.total/(clock-sample.first) if clock-sample.first>0.05 else 0.0
	if numbers:
		# Coalesce rapid ticks on the same target, retaining fractional damage.
		if not hits.is_empty() and hits.back().id==id and clock-hits.back().time<0.1:
			hits.back().amount+=amount
		else:
			if hits.size()>=96: hits.pop_front()
			hits.append({"id":id,"pos":enemy.pos,"amount":amount,"time":clock})

func draw(art, run) -> void:
	for enemy in run.enemies:
		if not enemy.get("dummy",false): continue
		var p: Vector2=enemy.pos
		art.draw_arc(p,enemy.radius+4,0,TAU,32,art.GOLD,2,true)
		var sample: Dictionary=targets.get(enemy.id,{})
		var caption: String="DUMMY" if sample.is_empty() else "%.1f DMG"%sample.total
		var rate: String="" if sample.is_empty() else ("%.1f DPS"%sample.dps if sample.dps>0 else "DPS —")
		for i in range(2):
			var line: String=caption if i==0 else rate
			var at:=p+Vector2(-55,-enemy.radius-34+i*15)
			art.draw_string_outline(art.stencil_font,at,line,HORIZONTAL_ALIGNMENT_CENTER,110,13,4,art.INK)
			art.draw_string(art.stencil_font,at,line,HORIZONTAL_ALIGNMENT_CENTER,110,13,art.CREAM if i==0 else art.PALE)
	if not numbers: return
	for hit in hits:
		var at: Vector2=hit.pos+Vector2(28,-10-(clock-hit.time)*45)
		var caption: String="%.1f"%hit.amount
		art.draw_string_outline(art.stencil_font,at,caption,HORIZONTAL_ALIGNMENT_LEFT,-1,15,4,art.INK)
		art.draw_string(art.stencil_font,at,caption,HORIZONTAL_ALIGNMENT_LEFT,-1,15,art.GOLD)
