extends "res://tests/intent39_test.gd"
## Fixed seeds, default starter equipment, no profile writes. A control-policy comparison,
## not an estimate of human skill or whether combat feels good.
func pick(run) -> int:
	var order: Array=[]
	for id in ["e","w"]:
		if Vanguard.rank_of(run,id)==0: order.append(id)
	for id in ["q","w","gun","e"]:
		if Vanguard.rank_of(run,id)<5: order.append(id)
	order.append_array(["full_heal","r","hammer","q","w","gun","e","d","f"])
	for id in order:
		if id in run.offers: return run.offers.find(id)
	return 0
func simulate(seed_value: int, use_intent: bool, passive: bool=false) -> Dictionary:
	var run:=intentional() if use_intent else modern()
	run.run_seed=seed_value; run.spawn_rng.seed=seed_value; run.loot_rng.seed=seed_value+901; run.offer_rng.seed=seed_value+1701
	ForgeEquipment.new().apply_to(run); run.health=run.max_health()
	var result: Dictionary={"seed":seed_value,"intent":use_intent,"passive":passive,"first_upgrade":-1,"e_offer":-1,"e_learned":-1,"first_rank5":-1,"samples":[]}
	var next_sample:=30.0; var peak:=0; var steps: Array[int]=[]
	for frame in range(12000):
		if run.state in ["lost","won","camp"] or run.time>=300: break
		if run.state=="upgrade":
			if result.first_upgrade<0: result.first_upgrade=snappedf(run.time,0.1)
			if result.e_offer<0 and "e" in run.offers: result.e_offer=snappedf(run.time,0.1)
			run.choose_upgrade(pick(run))
			if result.e_learned<0 and Vanguard.rank_of(run,"e")>0: result.e_learned=snappedf(run.time,0.1)
			if result.first_rank5<0:
				for id in IntentRules.OFFENSE:
					if Vanguard.rank_of(run,id)>=5: result.first_rank5=snappedf(run.time,0.1); break
			continue
		if not passive:
			var direction:=DemoCampaign.test_direction(run)
			run.command_move(run.player+direction*110)
			for chest in run.exp.loot_chests:
				if run.player.distance_to(chest.pos)<260: run.command_move(chest.pos); break
			var enemy:=run.nearest_enemy(run.player)
			if not enemy.is_empty() and frame%6==0:
				run.kit.extra.cursor=enemy.pos
				for id in ["w","r","q"]:
					if run.kit.unlocked(id): run.kit.cast(run,id,enemy.pos)
				if run.kit.unlocked("e") and run.player.distance_to(enemy.pos)<250:
					run.kit.cast(run,"e",enemy.pos); run.vanguard.swing(run,enemy.pos)
				elif run.player.distance_to(enemy.pos)<100: run.vanguard.swing(run,enemy.pos)
				if run.player.distance_to(enemy.pos)<60: run.kit.cast(run,"f",run.player+direction*200)
		var start:=Time.get_ticks_usec(); run.step(1.0/30,Vector2.ZERO); steps.append(Time.get_ticks_usec()-start)
		peak=maxi(peak,run.enemies.size())
		if run.time>=next_sample:
			result.samples.append({"time":roundi(run.time),"level":run.level,"hp":roundi(run.health),"kills":run.kills,"enemies":run.enemies.size(),"q":Vanguard.rank_of(run,"q"),"e":Vanguard.rank_of(run,"e")})
			next_sample+=30
	steps.sort()
	result.merge({"seconds":snappedf(run.time,0.1),"state":run.state,"level":run.level,"kills":run.kills,"peak":peak,"p95_us":steps[int(steps.size()*0.95)],"casts":run.kit.cast_counts})
	return result
func execute() -> void:
	for seed_value in [7127,1931,4820]:
		for use_intent in [false,true]: print("INTENT_PROBE ",JSON.stringify(simulate(seed_value,use_intent)))
	for use_intent in [false,true]: print("INTENT_PROBE ",JSON.stringify(simulate(7127,use_intent,true)))
	quit()
