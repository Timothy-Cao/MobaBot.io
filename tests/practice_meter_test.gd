extends SceneTree
var failures:=0
func check(ok: bool, caption: String) -> void:
	if not ok: failures+=1; push_error(caption)
func _initialize() -> void:
	var run:=SalvageRun.new(17017)
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo()
	BotExpedition.new().start(run,"ranged",0); run.exp.practice=true
	run.spawn_enemy(Vector2(600,300),3)
	var dummy: Dictionary=run.enemies.back(); dummy["dummy"]=true
	var meter:=run.practice_meter
	run.hit_enemy(dummy,10,"q")
	check(meter.targets[dummy.id].total==10 and meter.targets[dummy.id].dps==0,"Single hit total; no invented duration")
	meter.tick(1); run.hit_enemy(dummy,30,"w")
	check(meter.targets[dummy.id].total==40 and meter.targets[dummy.id].dps==40,"Burst sum and first-to-last DPS")
	meter.tick(2.99)
	check(meter.targets[dummy.id].total==40 and meter.targets[dummy.id].dps==40,"Result holds during idle grace")
	meter.tick(0.02); check(meter.targets.is_empty(),"Three-second reset")
	run.hit_enemy(dummy,2000000,"q")
	check(not dummy.dead and dummy.hp==dummy.max_hp and run.kills==0,"Dummy cannot die, lose health or grant kills")
	check(meter.targets[dummy.id].total==2000000,"Dummy damage never capped by fake health")
	meter.numbers=false; meter.hits.clear(); run.hit_enemy(dummy,0.5,"bolt")
	check(meter.hits.is_empty() and meter.targets[dummy.id].total==2000000.5,"Numbers toggle leaves measurement working")
	run.spawn_enemy(Vector2(800,300),0); var normal: Dictionary=run.enemies.back()
	run.hit_enemy(normal,99,"q")
	check(not meter.targets.has(normal.id) and normal.dead,"Real enemy behavior unchanged")
	meter.clear(); check(meter.targets.is_empty() and meter.hits.is_empty(),"Manual reset")
	run.exp.practice=false; run.spawn_enemy(Vector2(900,300),3)
	run.hit_enemy(run.enemies.back(),1,"q")
	check(meter.targets.is_empty() and meter.hits.is_empty(),"No campaign measurement")
	print("Practice meter: 10 checks; failures: ",failures)
	quit(1 if failures else 0)
