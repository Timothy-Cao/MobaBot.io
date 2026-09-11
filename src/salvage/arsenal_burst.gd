class_name ArsenalBurst
extends RefCounted
static func enabled(run) -> bool: return run!=null and run.kit!=null and run.kit.loadout.get("arsenal26",false)
static func scale(rank_value: int) -> float: return 0.24+(0.03/9.0)*(clampi(rank_value,1,10)-1)
static func fire(run, cursor: Vector2) -> bool:
	var v=run.vanguard
	if v.burst_left<=0 or v.burst_clock>0 or run.projectiles.size()>=run.MAX_PROJECTILES: return false
	if run.kit.energy<5:
		run.kit.last_failure="Low energy"; run.emit_event("energy_empty",run.player); return false
	run.kit.energy-=5; run.kit.energy_spent+=5
	var direction: Vector2=(cursor-run.player).normalized()
	if direction.is_zero_approx(): direction=run.aim
	var power: float=run.kit.damage_scale("q")*scale(run.kit.effective_rank("x3"))
	run._add_projectile(run.player,direction*1000,15*power,"rocket",0,run.kit.cast_range("q")/1000)
	var shot: Dictionary=run.projectiles.back()
	shot.blast=8*power; shot.radius=37.2*run.kit.area_scale("q"); shot.milestone=0; shot.mini_rocket=true
	v.burst_clock=0.3
	run.kit.cast_counts.rocket=int(run.kit.cast_counts.get("rocket",0))+1
	run.emit_event("cast",run.player,{"ability":"rocket","target":cursor,"milestone":0})
	return true
