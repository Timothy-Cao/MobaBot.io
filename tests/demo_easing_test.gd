extends "res://tests/demo_pacing_test.gd"
func execute() -> void:
	for level in range(1,4):
		var run:=fresh(level); var old:=fresh(level); old.exp.demo_pace=false
		var expected:=0.9 if level==1 else 1.0
		check(is_equal_approx(run.exp.incoming(run,2)/old.exp.incoming(old,2),expected),"Incoming damage scope, level %d"%level)
		check(is_equal_approx(OperationRules.boss_hp(run)/OperationRules.boss_hp(old),expected),"Boss health scope, level %d"%level)
		for kind in [0,1,3]:
			run.spawn_enemy(run.player,kind); old.spawn_enemy(old.player,kind)
			var e: Dictionary=run.enemies.back(); var baseline: Dictionary=old.enemies.back()
			run.exp.scale_enemy(run,e); old.exp.scale_enemy(old,baseline)
			check(is_equal_approx(e.hp/baseline.hp,expected),"Enemy health reduction after role floor")
			var hp: float=e.hp; run.exp.scale_enemy(run,e)
			check(e.hp==hp and e.max_hp==hp,"Health scaling cannot apply twice")
		for kind in ["lancer","mosquito","drifter","bulwark"]:
			var e:=RangedThreats.spawn(run,kind,run.player,true); var baseline:=RangedThreats.spawn(old,kind,old.player,true)
			run.exp.scale_enemy(run,e); old.exp.scale_enemy(old,baseline)
			check(is_equal_approx(e.hp/baseline.hp,expected),"Specialist/miniboss health scope")
	var run:=fresh()
	run.collect_pickup({"value":1800,"pos":run.player})
	check(run.total_xp==33,"Pickup XP gets ten percent increase")
	run=fresh(); run.stage_time=300; OperationRules.pace(run); OperationRules.pace(run)
	check(run.total_xp==44,"Survival bonus remains idempotent")
	run.state="camp"; run.exp.clear_clock=-2
	var forge:=ForgeEquipment.new(); forge.bank_camp(run,false)
	check(ForgeEquipment.valid_checkpoint(forge.checkpoint),"Increased survival XP checkpoint validates")
	var resumed:=fresh(); check(forge.resume_into(resumed) and resumed.total_xp==44,"Increased XP resumes")
	var invalid: Dictionary=forge.checkpoint.duplicate(true); invalid.loadout.operation_xp[0]=45
	check(not ForgeEquipment.valid_checkpoint(invalid),"Reject XP above new budget")
	invalid=forge.checkpoint.duplicate(true); invalid.loadout.erase("demo27")
	check(not ForgeEquipment.valid_checkpoint(invalid),"Historical checkpoint retains historical budget")
	run.exp.practice=true
	check(DemoPacing.xp_rate(run)==1 and DemoPacing.enemy_rate(run)==1,"Practice balance excluded")
	print("DEMO EASING: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
