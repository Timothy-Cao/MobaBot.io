extends "res://tests/intent39_test.gd"

func guardian(run, stage: int=0) -> Dictionary:
	run.exp.route_index=stage; run.exp.enter(run)
	run.stage_time=run.exp.round_seconds(); run.exp.spawns(run,0)
	var enemy: Dictionary=run.enemies.back()
	run.exp.scale_enemy(run,enemy)
	return enemy

func cadence(run, enemy: Dictionary) -> int:
	run.kit.extra.walls.clear()
	enemy.pos=Vector2.ZERO; enemy.phase="approach"; enemy.clock=0; enemy.sequence=0
	# Isolate the attack scheduler; the player follows at fixed range, without hits/rewards.
	for tick in range(6000):
		run.player=Vector2(enemy.pos)+Vector2(200,0)
		DemoCampaign.enemy_step(run,enemy,0.005)
	return enemy.sequence

func execute() -> void:
	var run:=intentional(); var old:=modern()
	var enemy:=guardian(run); var baseline:=guardian(old)
	check(enemy.role=="rammer" and enemy.get("opening_guardian42",false),"Only the required opening guardian is tagged")
	check(is_equal_approx(enemy.hp,baseline.hp*3) and enemy.hp==enemy.max_hp,"Three times final scaled hull, including role floor")
	var hp: float=enemy.hp
	run.exp.scale_enemy(run,enemy); run.exp.spawns(run,0)
	check(enemy.hp==hp and run.enemies.size()==1,"Repeated scaling/spawning cannot multiply hull or duplicate guardian")
	var fast:=cadence(run,enemy); var slow:=cadence(old,baseline)
	check(fast>=slow*1.8 and fast<=slow*2.2,"Fixed-range attack starts approximately double")
	print("OPENING GUARDIAN: hull %.3f -> %.3f; attacks/30s %d -> %d"%[baseline.max_hp,enemy.max_hp,slow,fast])
	enemy.phase="approach"; enemy.clock=0; enemy.sequence=0; enemy.pos=Vector2.ZERO; run.player=Vector2(200,0)
	DemoCampaign.enemy_step(run,enemy,0)
	check(enemy.phase=="telegraph" and enemy.clock==0.65,"Charge keeps a clear 650ms warning")
	enemy.clock=0; DemoCampaign.enemy_step(run,enemy,0)
	check(enemy.phase=="charge" and enemy.clock==0.55,"Charge duration and travel speed unchanged")
	enemy.clock=0; DemoCampaign.enemy_step(run,enemy,0)
	check(enemy.phase=="recover" and enemy.clock==0.3,"Attack retains an explicit recovery window")
	for level in range(1,4):
		for stage in range(3):
			if level==1 and stage==0: continue
			var other:=intentional(level); var historical:=modern(level)
			var actual:=guardian(other,stage); var expected:=guardian(historical,stage)
			check(not actual.has("opening_guardian42") and actual.hp==expected.hp,"Other Level/stage guardians and main bosses unchanged")
	run=intentional(); run.stage_time=180; run.exp.spawns(run,0)
	check(run.enemies.any(func(e): return e.has("miniboss")),"Roaming miniboss still appears")
	check(not run.enemies.any(func(e): return e.has("opening_guardian42")),"Roaming encounter unchanged")
	run=intentional(); run.stage_time=299; run.exp.spawns(run,0)
	check(not run.exp.encounter_spawned,"Guardian never appears before five minutes")
	print("OPENING GUARDIAN: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
