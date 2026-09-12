class_name FieldPickups
extends RefCounted
var rng:=RandomNumberGenerator.new()
var due: Dictionary={}
func killed(run, point: Vector2) -> void:
	if not DemoPacing.enabled(run): return
	if due.is_empty():
		rng.seed=run.run_seed+73091
		for kind in ["health_pack","vacuum"]: due[kind]=run.time+rng.randf_range(45,75)
	for kind in due:
		if run.time<due[kind]: continue
		run._drop_supply(point,kind,25 if kind=="health_pack" else 1)
		due[kind]=run.time+rng.randf_range(45,75)
static func sweep(run) -> void:
	# Snapshot once. New drops caused by collection effects wait for a later pickup.
	var xp: Array=run.pickups.duplicate()
	var supplies: Array=run.supply_drops.duplicate()
	for supply in supplies:
		if supply.kind=="vacuum": supply.value=0
	for pickup in xp: run.collect_pickup(pickup)
	for supply in supplies: run._collect_supply(supply)
	run.exp.pending_chests+=run.exp.loot_chests.size(); run.exp.loot_chests.clear()
	run.pickups=run.pickups.filter(func(p): return p.value>0)
	run.emit_event("pulse",run.player,{"radius":240.0})
static func draw(art, p: Vector2, kind: String) -> void:
	art.draw_circle(p+Vector2(0,5),17,Color(art.INK,0.5))
	art._box(Rect2(p-Vector2(13,12),Vector2(26,24)),art.INK,3)
	if kind=="health_pack":
		art._box(Rect2(p-Vector2(10,9),Vector2(20,18)),Color("78c995"),2)
		art.draw_line(p-Vector2(6,0),p+Vector2(6,0),art.CREAM,4)
		art.draw_line(p-Vector2(0,6),p+Vector2(0,6),art.CREAM,4)
	else:
		art.draw_arc(p-Vector2(0,3),7,0,PI,16,art.CORAL,5)
		for x in [-7,7]: art.draw_line(p+Vector2(x,-9),p+Vector2(x,-1),art.CREAM,5)
		art.draw_arc(p,18,0.2,1.1,8,art.TEAL,2)
