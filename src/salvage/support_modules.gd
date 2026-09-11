class_name SupportModules
extends RefCounted
## Opt-in replacement behavior. Existing module ownership/ranks remain valid.
static func enabled(run) -> bool: return LevelMastery.enabled(run) and run.kit.loadout.get("support23",false)

static func attract(run, enemy: Dictionary, delta: float) -> bool:
	if not enabled(run) or run.vanguard.emp_left>0 or enemy.has("role") or enemy.has("exp_boss"): return false
	var anchor: Dictionary={}; var distance:=340.0
	for unit in run.vanguard.constructs:
		var d: float=Vector2(enemy.pos).distance_to(unit.pos)
		if unit.id=="guard_bot" and unit.hp>0 and unit.life>0 and d<distance: anchor=unit; distance=d
	if anchor.is_empty(): return false
	var target: Vector2=run.kit.extra.route(enemy.pos,anchor.pos,enemy.radius)
	var old: Vector2=enemy.pos
	var speed: float=(105.0 if enemy.kind==1 else 60.0)*run.exp.enemy_speed(run)
	enemy.pos=run.kit.extra.solid_point(old,old+(target-old).normalized()*speed*delta+Vector2(enemy.knock)*delta,enemy.radius)
	enemy.knock=Vector2(enemy.knock).move_toward(Vector2.ZERO,500*delta)
	enemy.lure_clock=maxf(0,float(enemy.get("lure_clock",0))-delta)
	if Vector2(enemy.pos).distance_to(anchor.pos)<enemy.radius+24 and enemy.lure_clock<=0:
		anchor.hp-=12.0*(1+0.1*(run.exp.stage_number()-1)); enemy.lure_clock=0.8
	# Existing projectiles keep flying; attraction cannot erase attacks already fired.
	return true

static func energy(run, unit: Dictionary, delta: float) -> void:
	var rank_value: int=run.kit.effective_rank(unit.slot)
	var maximum:=86.0*Vanguard.power(rank_value)
	var inside: bool=run.player.distance_to(unit.pos)<=unit.radius
	if not inside: unit.bank=minf(maximum,unit.bank+delta*6*Vanguard.power(rank_value))
	elif unit.bank>0:
		var amount: float=minf(unit.bank,minf(delta*45*sqrt(Vanguard.power(rank_value)),run.kit.energy_max()-run.kit.energy))
		run.kit.energy+=amount; unit.bank-=amount

static func title(slot: String) -> String: return "Anchor" if slot=="x1" else "Energy reserve"
static func detail(slot: String) -> String:
	return "Anchor\nA destructible decoy draws nearby ordinary enemies, including ranged specialists. Bosses and guardians ignore it. No gun or damage pulse. Lasts 35s; redeploy replaces it." if slot=="x1" else "Energy reserve\nStores energy while you are outside its area. Return to draw the stored energy. No healing, damage, free casts or cooldown acceleration. Lasts 35s; redeploy clears its store. Suppressed by EMP."
