extends SceneTree
func _initialize() -> void:
	var run:=SalvageRun.new(7127); run.loot_rng.seed=8028
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
	BotExpedition.new().start(run,"ranged",0); run.exp.enable_revision(run)
	Vanguard.setup(run,1); ReviewRules.enable(run); OperationRules.enable(run,1); LevelMastery.enable(run)
	run.kit.loadout.support23=true; run.enemies.clear(); run.player=Vector2(480,300)
	PracticeSandbox.terrain(run)
	for i in range(25):
		var p:=run.player+Vector2.from_angle(i*TAU/25)*140
		var bug:=RangedThreats.spawn(run,"mosquito",p,true); bug.warmup=0
	for crowded in [false,true]:
		run.projectiles.clear()
		if crowded:
			for i in range(60): run._add_projectile(run.player+Vector2.from_angle(i*TAU/60)*180,Vector2.from_angle(i*TAU/60)*700,1,"rocket",0,1)
		var samples: Array[int]=[]
		for frame in range(600):
			var start:=Time.get_ticks_usec()
			for bug in run.enemies: Mosquito.step(run,bug,1.0/60)
			samples.append(Time.get_ticks_usec()-start)
		samples.sort(); var total:=0
		for value in samples: total+=value
		print("MOSQUITO_PERF ",JSON.stringify({"crowded":crowded,"count":25,"mean_us":total/600.0,"p95_us":samples[570],"max_us":samples.back()}))
	quit()
