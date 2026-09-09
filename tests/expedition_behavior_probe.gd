extends SceneTree
func _initialize() -> void: _run.call_deferred()

func simulate(class_id: String, policy: String, difficulty: int=0) -> Dictionary:
	var run:=SalvageRun.new(7127)
	# Match the game controller's seed convention; comparisons must not randomize loot.
	run.loot_rng.seed=run.run_seed+901
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo()
	run.kit.onboarding=true; run.kit.starting_gun=true; run.attacks.enabled=true
	BotExpedition.new().start(run,class_id,difficulty)
	ExpeditionGear.new().apply_to(run)
	run.health=run.max_health()
	var peak:=0
	var max_us:=0
	var samples: Array[int]=[]
	for frame in range(120000):
		if run.state in ["won","lost"]: break
		if run.state=="upgrade":
			var index:=0
			for preferred in ["skill_q","power","rapid","skill_w","reactor"]:
				if preferred in run.offers: index=run.offers.find(preferred); break
			run.choose_upgrade(index)
		elif run.state=="chest": run.exp.choose_chest(run,0)
		elif run.state=="camp":
			if run.exp.pending_chests>0: run.exp.make_chest(run); run.state="chest"
			else: run.exp.advance(run)
		else:
			if policy=="soak": run.health=run.max_health()
			if policy!="idle":
				var direction: Vector2=DemoCampaign.test_direction(run)
				if direction==Vector2.ZERO: direction=Vector2.RIGHT
				run.command_move(run.player+direction*110)
				for chest in run.exp.loot_chests:
					if run.player.distance_to(chest.pos)<230: run.command_move(chest.pos)
				var enemy:=run.nearest_enemy(run.player)
				if not enemy.is_empty():
					run.kit.extra.cursor=enemy.pos
					if frame%20==0:
						for slot in ["q","w","e","r","t"]: run.kit.cast(run,slot,enemy.pos)
						run.kit.steer_laser(run,enemy.pos)
						if run.player.distance_to(enemy.pos)<130: run.kit.cast(run,"d",run.player+direction*200)
						if run.player.distance_to(enemy.pos)<85: run.kit.cast(run,"f",run.player+direction*200)
				if run.health<run.max_health()*0.4: run.use_consumable(0)
				if run.kit.energy<20: run.use_consumable(1)
				if run.mastery.available(run.level)>0:
					for id in ["b0_0","b0_1","b3_1","b2_0","b2_1","b3_3","b0_3","b2_2","b2_4"]:
						if run.mastery.can_buy(id,run.level): run.mastery.buy(run,id); break
			var before:=Time.get_ticks_usec()
			run.step(1.0/30,Vector2.ZERO)
			var elapsed:=Time.get_ticks_usec()-before
			if samples.size()<60000: samples.append(elapsed)
			max_us=maxi(max_us,elapsed); peak=maxi(peak,run.enemies.size())
			run.events.clear()
	samples.sort()
	return {"class":class_id,"policy":policy,"ascension":difficulty,"state":run.state,"round":run.exp.route_index+1,"seconds":snappedf(run.time,0.1),"level":run.level,"kills":run.kills,"peak_enemies":peak,"p95_step_us":samples[int(samples.size()*0.95)] if not samples.is_empty() else 0,"max_step_us":max_us,"casts":run.kit.cast_counts}

func _run() -> void:
	if "--soak" in OS.get_cmdline_user_args():
		var result:=simulate("summoner","soak",5)
		print("EXPEDITION_SOAK ",JSON.stringify(result))
		quit(0 if result.state=="won" else 1)
	else:
		for id in BotExpedition.CLASSES:
			for policy in ["idle","active"]: print("EXPEDITION_PROBE ",JSON.stringify(simulate(id,policy)))
		quit()
