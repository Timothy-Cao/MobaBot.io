extends SceneTree
class ProbeShop extends RefCounted:
	var model: SalvageRun
	var collection=ForgeEquipment.new()
	func persistent_run() -> bool: return false

func _initialize() -> void: _run.call_deferred()

func simulate(class_id: String, policy: String, difficulty: int=0) -> Dictionary:
	var run:=SalvageRun.new(7127)
	# Match the game controller's seed convention; comparisons must not randomize loot.
	run.loot_rng.seed=run.run_seed+901
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo()
	run.kit.onboarding=true; run.kit.starting_gun=true; run.attacks.enabled=true
	BotExpedition.new().start(run,class_id,difficulty)
	BotKeyboard.enable(run)
	if "--revised" in OS.get_cmdline_user_args() or "--vanguard" in OS.get_cmdline_user_args(): run.exp.enable_revision(run)
	if "--vanguard" in OS.get_cmdline_user_args(): Vanguard.setup(run); ReviewRules.enable(run)
	if "--vanguard" in OS.get_cmdline_user_args() and "--long-route" not in OS.get_cmdline_user_args():
		var chapter:=1
		for arg in OS.get_cmdline_user_args():
			if arg.begins_with("--chapter="): chapter=int(arg.trim_prefix("--chapter="))
		OperationRules.enable(run,chapter)
		LevelMastery.enable(run); run.kit.loadout.support23=true; run.kit.loadout.arsenal26=true
		if chapter<=DemoPacing.LEVELS and "--legacy-pace" not in OS.get_cmdline_user_args(): DemoPacing.enable(run); FactoryMaps.enable(run)
		if "--discovery" in OS.get_cmdline_user_args(): DiscoveryRules.enable(run)
	ForgeEquipment.new().apply_to(run)
	# Reliability only: a normal-HP refill can still die to several hits in one
	# frame. Inflate maximum health too, preserving all AI/damage/collision paths.
	if policy=="soak": run.exp.gear_stats.health=100000.0; run.exp.sync_stats(run)
	run.health=run.max_health()
	var peak:=0
	var max_us:=0
	var samples: Array[int]=[]
	var arrivals: Array[Dictionary]=[]
	for frame in range(240000 if run.exp.revised else 120000):
		if Vanguard.enabled(run): run.vanguard.ghost=false
		if Vanguard.enabled(run) and not ReviewRules.enabled(run):
			run.vanguard.ghost=false
			var choices:=Vanguard.candidates(run,Vanguard.reward_kind(run))
			if not choices.is_empty() and Vanguard.reward_kind(run)!="":
				var preferred: String=choices[0]
				for slot in ["q","w","p1","e","x1","x2","r","x3","gun","f","d"]:
					if slot in choices: preferred=slot; break
				Vanguard.spend(run,preferred)
		if run.state in ["won","lost"]: break
		if run.state=="upgrade":
			var index:=0
			for preferred in ["skill_q","power","rapid","skill_w","reactor"]:
				if preferred in run.offers: index=run.offers.find(preferred); break
			run.choose_upgrade(index)
		elif run.state=="chest": run.exp.choose_chest(run,0)
		elif run.state=="camp":
			if ReviewRules.enabled(run):
				var shop:=ProbeShop.new(); shop.model=run
				for slot in ["p1","x1","x2","x3"]: ReviewRules.buy_module(shop,slot)
			if run.exp.pending_chests>0: run.exp.make_chest(run); run.state="chest"
			else: run.exp.advance(run)
		else:
			if policy=="soak": run.health=run.max_health()
			if policy!="idle":
				var direction: Vector2=DemoCampaign.test_direction(run)
				if direction==Vector2.ZERO: direction=Vector2.RIGHT
				if policy!="basics" or run.attacks.windup<0: run.command_move(run.player+direction*110)
				for chest in run.exp.loot_chests:
					if run.player.distance_to(chest.pos)<230 and run.attacks.windup<0: run.command_move(chest.pos)
				var enemy:=run.nearest_enemy(run.player)
				if not enemy.is_empty():
					if policy=="basics" and run.attacks.cooldown<=0 and run.player.distance_to(enemy.pos)<=run.attacks.attack_range(run): run.attacks.attack(run,enemy)
					run.kit.extra.cursor=enemy.pos
					if frame%20==0:
						for slot in run.kit.active_slots():
							if slot not in ["d","f"] and run.kit.unlocked(slot): run.kit.cast(run,slot,enemy.pos)
						run.kit.steer_laser(run,enemy.pos)
						if run.player.distance_to(enemy.pos)<130: run.kit.cast(run,"d",run.player+direction*200)
						if run.player.distance_to(enemy.pos)<85: run.kit.cast(run,"f",run.player+direction*200)
				if run.health<run.max_health()*0.4: run.use_consumable(0)
				if run.kit.energy<20: run.use_consumable(1)
				if run.mastery.available(run.level)>0:
					var path: Array=["b0_0","b0_1","b3_0","b3_2","b2_0","b2_2","b0_3","b2_4"] if run.mastery.unified else ["b0_0","b0_1","b3_1","b2_0","b2_1","b3_3","b0_3","b2_2","b2_4"]
					if run.mastery.modern: path=["field","reach","economy","insulation","charge","learner","salvager","supplies","windfall","companion","collector","repair","disruptor"]
					for id in path:
						if run.mastery.can_buy(id,run.level): run.mastery.buy(run,id); break
			var before:=Time.get_ticks_usec()
			run.step(1.0/30,Vector2.ZERO)
			if run.exp.encounter_spawned and arrivals.size()<=run.exp.route_index:
				arrivals.append({"round":run.exp.route_index+1,"seconds":snappedf(run.time,0.1),"level":run.level,"xp":run.total_xp,"mastery":run.mastery.spent,"credits":run.exp.field_credits})
			var elapsed:=Time.get_ticks_usec()-before
			if samples.size()<60000: samples.append(elapsed)
			max_us=maxi(max_us,elapsed); peak=maxi(peak,run.enemies.size())
			run.events.clear()
	samples.sort()
	return {"class":class_id,"policy":policy,"artificial_health":policy=="soak","chapter":run.exp.operation_chapter,"arrivals":arrivals,"ascension":run.exp.ascension,"state":run.state,"round":run.exp.route_index+1,"seconds":snappedf(run.time,0.1),"level":run.level,"kills":run.kills,"peak_enemies":peak,"p95_step_us":samples[int(samples.size()*0.95)] if not samples.is_empty() else 0,"max_step_us":max_us,"casts":run.kit.cast_counts}

func _run() -> void:
	if "--soak" in OS.get_cmdline_user_args():
		var result:=simulate("summoner","soak",5)
		print("EXPEDITION_SOAK ",JSON.stringify(result))
		quit(0 if result.state=="won" else 1)
	else:
		for id in (["ranged"] if "--revised" in OS.get_cmdline_user_args() or "--vanguard" in OS.get_cmdline_user_args() else BotExpedition.CLASSES.keys()):
			for policy in (["idle","active","basics"] if "--revised" in OS.get_cmdline_user_args() or "--vanguard" in OS.get_cmdline_user_args() else ["idle","active"]): print("EXPEDITION_PROBE ",JSON.stringify(simulate(id,policy)))
		quit()
