extends SceneTree
## Isolated geometry probe, not a model of human aim or full encounters.
const BUDGET := {"rocket":23.0,"flame":26.0,"nuke":85.0,"laser":375.0,"returner":44.0,"gravity":36.0,"strike":64.0,"crosswire":30.0,"repulsor":20.0,"sweep":26.0,"reap":36.0,"thrust":25.0,"tractor":18.0,"echo_dash":24.0,"hop":24.0,"pursuit":32.0,"landing":120.0,"artillery":195.0}
func _initialize() -> void:
	for id in BUDGET:
		var row: Dictionary={"id":id,"ceiling_per_cast":BUDGET[id],"recharge":MobaKit.ABILITIES[id].cd,"energy":MobaKit.new().ability_cost(id)}
		row.ceiling_dps=snappedf(BUDGET[id]/MobaKit.ABILITIES[id].cd,0.01)
		row.stationary=measure(id,"stationary",0)
		for policy in ["snapshot","track"]:
			var total:=0.0; var low:=INF; var high:=0.0
			for trial in range(12):
				var value: float=measure(id,policy,trial).fraction
				total+=value; low=minf(low,value); high=maxf(high,value)
			row[policy]={"mean_fraction":snappedf(total/12,0.001),"low":low,"high":high}
		print("DAMAGE_PROBE ",JSON.stringify(row))
	quit()
func measure(id: String, policy: String, trial: int) -> Dictionary:
	var run:=SalvageRun.new(401)
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo()
	BotExpedition.new().start(run,"ranged",0); BotKeyboard.enable(run)
	var slot: String="f" if MobaKit.ABILITIES[id].category=="mobility" else "q"
	run.exp.install(run,slot,id); run.kit.energy=1000
	run.kit.toggles.fill(false); run.kit.extra.walls.clear()
	var distance: float=130 if id in ["reap","sweep","thrust","tractor","repulsor","flame"] else 260
	var point: Vector2=run.player+Vector2(distance,0)
	var phase: float=trial*TAU/12
	var amplitude: float=70+trial%3*25
	var frequency: float=1.3+trial%3*0.4
	run.spawn_enemy(point,0); var enemy: Dictionary=run.enemies.back()
	enemy.warmup=0; enemy.hp=10000; enemy.max_hp=10000
	if policy!="stationary": enemy.pos=point+Vector2(0,sin(phase)*amplitude)
	var initial: Vector2=enemy.pos
	# Tracking policy also leads projectile/delayed attacks using the known fixture velocity.
	var lead: float={"rocket":distance/800,"returner":distance/650,"strike":0.6,"nuke":0.65,"hop":0.55,"landing":0.9}.get(id,0)
	var target: Vector2=point+Vector2(0,sin(phase+lead*frequency)*amplitude) if policy=="track" else initial
	if id=="crosswire":
		run.kit.cast(run,slot,target+Vector2(0,-80)); run.kit.cast(run,slot,target+Vector2(0,80))
	else: run.kit.cast(run,slot,target)
	for frame in range(1200):
		var time_value: float=frame/60.0
		if policy!="stationary": enemy.pos=point+Vector2(0,sin(phase+time_value*frequency)*amplitude)
		var aim: Vector2=enemy.pos if policy=="track" else initial
		run.kit.extra.cursor=aim
		if run.kit.flame_left>0: run.kit.flame_direction=(aim-run.player).normalized()
		if run.kit.laser_left>0: run.kit.steer_laser(run,aim)
		if id=="artillery" and frame in [6,36,66]: run.kit.cast(run,slot,aim)
		run.kit.step(run,1.0/60)
		if run.kit.dash_left>0: run.kit.move_dash(run,1.0/60)
		run._projectile_step(1.0/60)
		run.events.clear()
	var damage: float=10000-enemy.hp
	return {"damage":snappedf(damage,0.01),"fraction":snappedf(damage/BUDGET[id],0.001)}
