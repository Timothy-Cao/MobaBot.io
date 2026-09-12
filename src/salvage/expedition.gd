class_name BotExpedition
extends RefCounted
## Route, discoveries and one authoritative, high-resolution stat budget.
const ROUTE := [
	[1,"neutral"],[1,"neutral"],[1,"boss"],
	[2,"neutral"],[2,"neutral"],[2,"boss"],
	[3,"neutral"],[3,"boss"],[3,"loot"],
	[4,"neutral"],[4,"boss"],[5,"neutral"],[5,"boss"],
	[6,"neutral"],[6,"boss"],[6,"neutral"],[6,"boss"],
	[7,"loot"],[7,"neutral"],[7,"boss"],[8,"boss"],[8,"final"]]
const STAGES := ["Loading bay", "Pressworks", "Coolant garden", "Rail foundry", "Coil bank", "Relay yards", "Salvage vault", "Core chamber"]
const BOSSES := ["Gatekeeper", "Stamp press", "Coolant keeper", "Rail marshal", "Coil warden", "Relay foreman", "Vault guardian", "Core sovereign"]
const CLASSES := {
	"ranged": {"name": "Gunner", "text": "Long-range basics. Commanded hits grant a short movement burst.", "w": "returner", "e": "strike", "t": "forward_sentry", "passives": ["bolt", "threehit", "plates", "sidebolts"]},
	"melee": {"name": "Brawler", "text": "Short-range heavy basics. Faster movement, stronger hull and repair.", "w": "reap", "e": "sweep", "t": "pulse_sentry", "passives": ["bolt", "orbit", "momentum", "converter"]},
	"summoner": {"name": "Engineer", "text": "Two major summons. Stronger constructs and extended battery life.", "w": "gravity", "e": "repulsor", "t": "mirror_sentry", "passives": ["bolt", "mounted", "poison", "lightning"]}}
var route_index := 0
var operation_chapter := 0
var demo_pace:=false

func route() -> Array:
	return [[operation_chapter,"neutral"],[operation_chapter,"neutral"],[operation_chapter,"boss"]] if operation_chapter>0 else ROUTE

func stage_number() -> int: return int(route()[route_index][0])
func final_round() -> bool: return route_index==route().size()-1
var ascension := 0
var class_id := "ranged"
var pending_chests := 0
var chests_opened := 0
var chest_choices: Array[Dictionary] = []
var loot_chests: Array[Dictionary] = []
var pending_items: Array[String] = []
var field_credits := 0
var carry_credits := 0
var gear_stats: Dictionary = {}
var stats: Dictionary = {}
var encounter_spawned := false
var last_wave := -1
var clear_clock := -1.0
var cleared := 0
var shop_stock: Array[String] = []
var reward_receipt: Dictionary={"chests":0,"points":0,"credits":0,"items":{}}
var save_id := ""
var last_receipt := -1
var resistance := 0.0
var set_counts: Dictionary = {}
var courier_clock := 0.0
var dynamo_clock := 0.0
var bastion_clock := 0.0
var energy_meter := 0.0
var previous_energy_spent := 0.0
var chest_return := "running"
var revised := false
var practice := false
var god_mode := true
var free_energy := true
var fast_cooldowns := false
var threat_wave := 0
var roaming_mini_spawned:=false
var progression_samples: Array[Dictionary]=[]
var sample_time := -1.0
var sample_damage: Dictionary={}

func enable_revision(run) -> void:
	revised = true
	class_id = "shared"
	if not run.kit.loadout.get("rules17", false):
		run.next_level = run.total_xp + ceili(maxi(1, run.next_level-run.total_xp) * xp_factor(run.level))
	run.kit.loadout["rules17"] = true
	if not run.kit.loadout.has("library"): run.kit.loadout["library"] = {}
	sync_stats(run)
	RunTerrain.build(run)

static func xp_factor(level: int) -> float:
	if level <= 5: return 1.25
	var t := clampf(float(level-5)/15.0,0,1) if level <= 20 else clampf(float(level-20)/15.0,0,1)
	return (1.25 if level <= 20 else 1.5) + 0.25 * t*t*(3-2*t)

static func class_loadout(id: String) -> Dictionary:
	var config: Dictionary = MobaKit.demo_preset()
	for key in ["w", "e", "t", "passives"]: config[key] = CLASSES[id][key].duplicate() if CLASSES[id][key] is Array else CLASSES[id][key]
	config.pet = "none"
	return config

func start(run, selected_class: String, difficulty: int, preferred: Dictionary = {}) -> void:
	class_id = selected_class if CLASSES.has(selected_class) else "ranged"
	ascension = clampi(difficulty, 0, 5)
	run.exp = self
	run.mastery = ExpeditionTree.new()
	run.kit.discovery = true
	run.kit.discovered = ["q", "d", "f", "p1"]
	var config: Dictionary = preferred.duplicate(true) if MobaKit.valid_loadout(preferred) else class_loadout(class_id)
	config = MobaKit.with_starter_gun(config)
	config.q = "rocket" # Every class starts with one consistent aimed skill.
	if not MobaKit.valid_loadout(config): config = class_loadout(class_id)
	for slot in MobaKit.SLOTS: install(run, slot, config[slot], false)
	run.kit.loadout.passives = config.passives.duplicate()
	run.kit.loadout.pet = config.pet
	sync_stats(run)
	run.health = max_health(run)
	run.kit.energy = run.kit.energy_max()
	enter(run)

func max_health(run) -> float:
	return 100.0 + (25 if class_id == "melee" else 0) + float(stats.get("health", 0))

func sync_stats(run) -> void:
	stats = gear_stats.duplicate()
	for stat in ["health", "resistance", "health_regen", "damage", "attack", "haste", "range", "speed", "cooldown", "tenacity", "energy", "regen", "magnet", "xp", "luck", "summon_damage", "duration", "capacity"]:
		stats[stat] = float(stats.get(stat, 0)) + run.mastery.value(stat)
	resistance = minf(120, stats.resistance + (18 if class_id == "melee" else 0))
	run.kit.gear_damage = minf(1.5, stats.damage)
	run.kit.mastery_damage = 0
	run.kit.gear_speed = minf(0.55, stats.speed + (0.12 if class_id == "melee" else 0))
	run.kit.energy_bonus = stats.energy - (15 if ascension >= 3 else 0)
	run.kit.regen_bonus = stats.regen - (1 if ascension >= 5 else 0)
	run.kit.attack_damage_bonus = minf(1.5, stats.attack)
	run.kit.attack_speed_bonus = minf(1.0, stats.haste)
	run.kit.attack_range_bonus = minf(120, stats.range)
	run.kit.cooldown_bonus = minf(0.6, stats.cooldown)
	run.kit.rank_bonus=int(stats.get("ability_rank",0))
	run.kit.forge_pet=stats.get("forge_pet",0)>0
	run.kit.energy_efficiency=run.mastery.value("efficiency") if LevelMastery.enabled(run) else 0.0
	run.kit.extra_q_charge=LevelMastery.enabled(run) and run.mastery.value("extra_charge")>0
	if LevelMastery.enabled(run):
		stats.magnet+=run.mastery.value("pet_magnet")
		run.kit.regen_bonus+=run.mastery.rank_of("economy")*0.2
	run.kit.extra.capacity = mini(4, (2 if class_id == "summoner" else 1) + int(stats.capacity))
	run.kit.extra.duration_bonus = stats.duration + (0.2 if class_id == "summoner" else 0)
	run.kit.extra.summon_power = 1 + stats.summon_damage + (0.2 if class_id == "summoner" else 0)
	run.drop_bonus = minf(2, stats.luck)
	run.health = minf(run.health, max_health(run))
	run.kit.energy = minf(run.kit.energy, run.kit.energy_max())

func incoming(run, hull_units: float) -> float:
	var value := hull_units * 20 * (1 + ascension * 0.12) * 100 / (100 + resistance)
	if Vanguard.enabled(run) and not practice:
		value*=(0.55*(1+0.1*(operation_chapter-1))*(1+0.15*route_index) if operation_chapter>0 else stage_damage(stage_number())*round_damage())
		if encounter_spawned and route()[route_index][1] in ["boss","final"]: value*=1.25
		if ReviewRules.enabled(run): value*=ReviewRules.enrage_multiplier(run)
	if run.kit.extra.roll_left > 0: value *= 0.65
	if run.kit.extra.flywheel >= 1: value *= 0.85
	return value*DemoPacing.enemy_rate(run)

static func stage_health(number: int) -> float:
	var depth:=clampi(number,1,8)-1
	return 1.0+1.2*depth+0.35*depth*depth

static func stage_damage(number: int) -> float:
	return 1.0+0.12*(clampi(number,1,8)-1)

func round_health() -> float:
	return 1.10*(1.0+0.06*route_index)

func round_damage() -> float:
	return 1.05*(1.0+0.02*route_index)

func scale_enemy(run, enemy: Dictionary) -> void:
	if not Vanguard.enabled(run) or practice or enemy.get("stage_scaled",false) or enemy.get("dummy",false): return
	enemy.stage_scaled=true
	# Boss HP is set explicitly after spawn; every other spawn path shares this rule.
	if enemy.has("exp_boss"): return
	var number: int=stage_number()
	var factor: float=OperationRules.chapter_health(number)*[0.8,1.25,1.9][route_index] if operation_chapter>0 else stage_health(number)*round_health()
	if enemy.has("role"):
		if number>1 and operation_chapter==0: factor*=3.0
	else: factor*=1.2 if ascension>=2 else 1.0
	enemy.hp*=factor; enemy.max_hp*=factor
	if ReviewRules.enabled(run): ReviewRules.scale_role(run,enemy)
	enemy.hp*=DemoPacing.enemy_rate(run); enemy.max_hp=enemy.hp

func enemy_speed(run=null) -> float:
	if operation_chapter>0: return 1.0+minf(0.18,(operation_chapter-1)*0.015+route_index*0.025)+ascension*0.02
	return 1 + (0.08 if ascension >= 1 else 0) + (0.07 if ascension >= 4 else 0) + (minf(0.18,route_index*0.008) if run!=null and Vanguard.enabled(run) and not practice else 0.0)

func round_seconds() -> float:
	if demo_pace and operation_chapter>0: return DemoPacing.ROUND_SECONDS
	if operation_chapter>0: return OperationRules.ROUND_SECONDS[route_index]
	if revised: return 120.0
	return 35.0 if ROUTE[route_index][1] in ["boss", "final"] else (40.0 if ROUTE[route_index][1] == "loot" else 50.0)

func label() -> String:
	if operation_chapter>0: return "Level %d · Round %d / 3"%[operation_chapter,route_index+1]
	if revised:
		var round_number:=1
		for i in range(route_index):
			if ROUTE[i][0]==ROUTE[route_index][0]: round_number+=1
		return "%d.%d · %s"%[ROUTE[route_index][0],round_number,STAGES[ROUTE[route_index][0]-1]]
	return "%d · %s" % [ROUTE[route_index][0], STAGES[ROUTE[route_index][0] - 1]]

static func difficulty_text(value: int) -> String:
	var rules: Array = ["Enemy damage +%d%%" % (value * 12)] if value > 0 else ["Standard difficulty"]
	if value >= 1: rules.append("Enemy speed +8%")
	if value >= 2: rules.append("Enemy hull +20%; additional pressure packs")
	if value >= 3: rules.append("15 less energy; repair regeneration -20%")
	if value >= 4: rules.append("Enemy speed +15% total; boss recovery windows shorter")
	if value >= 5: rules.append("1 less energy/sec; elite reinforcement waves")
	return "\n".join(rules)

func enter(run) -> void:
	sample_time=-1; sample_damage.clear()
	if Vanguard.enabled(run): run.vanguard.clear(); run.kit.emp_left=0
	run.stage = mini(3, stage_number()) # Legacy renderer sectors, not campaign ownership.
	run.stage_time = 0; run.boss_spawned = false; run.boss_defeated = false
	run.stage_clear_wait = -1; run.spawn_clock = 0.8; run.demo_minis_killed = 0
	encounter_spawned = false; last_wave = -1; clear_clock = -1
	reward_receipt=RewardLedger.empty()
	threat_wave = 0; roaming_mini_spawned=false
	run.kit.extra.clear_combat()
	run.enemies.clear(); run.projectiles.clear(); run.hazards.clear(); run.pickups.clear(); run.supply_drops.clear(); run.orbit.clear()
	run.kit.salvos.clear(); run.kit.zones.clear(); run.kit.poison_trail.clear(); run.kit.summon.clear(); run.kit.cancel_laser(); run.kit.flame_left = 0; run.kit.dash_left = 0
	run.player = [Vector2(480,300), Vector2(1150,-480), Vector2(-700,950)][route_index % 3]
	if FactoryMaps.enabled(run): run.player=FactoryMaps.CENTER
	run.kit.pet_position = run.player
	run.factory_works=FactoryWorks.new()
	run.stop_movement(); run.attacks.stop(run)
	run.caches.clear()
	for i in range(3):
		var point: Vector2 = run.player + Vector2.from_angle(i * TAU / 3 + 0.4) * 430
		run.kit.extra.walls.append({"uid": -i - 1, "a": point + Vector2(-90, 0), "b": point + Vector2(90, 0), "life": 9999.0})
	run.state = "running"
	if revised: RunTerrain.build(run)
	run.emit_event("demo_level", run.player)

func spawns(run, delta: float) -> void:
	if practice or clear_clock >= 0: return
	var kind: String = route()[route_index][1]
	var stage_number: int = stage_number()
	if run.stage_time >= round_seconds():
		if revised and kind not in ["boss", "final"] and not encounter_spawned:
			encounter_spawned = true
			DemoCampaign.spawn_special(run, "rammer" if route_index % 2 == 0 else "artillery")
			var mini: Dictionary = run.enemies.back()
			mini.hp = (100 + stage_number*30) * (1.2 if ascension >= 2 else 1); mini.max_hp = mini.hp
			if operation_chapter>0:
				mini.hp=(320.0+route_index*280)*OperationRules.chapter_health(operation_chapter)*(1+ascension*0.12); mini.max_hp=mini.hp
		if kind in ["boss", "final"] and not encounter_spawned:
			encounter_spawned = true; run.boss_spawned = true
			DemoCampaign.spawn_special(run, "foreman")
			var boss: Dictionary = run.enemies.back()
			boss["exp_boss"] = stage_number
			boss["title"] = BOSSES[stage_number - 1]
			boss.hp = (350 + stage_number * 150) * (1.2 if ascension >= 2 else 1) * (1.7 if kind == "final" else 1)
			if Vanguard.enabled(run): boss.hp*=50.0
			if operation_chapter>0: boss.hp=OperationRules.boss_hp(run)
			boss.max_hp = boss.hp
			boss["patterns"] = [["charge","fan"],["shells","charge"],["ring","shells"],["fan","charge","fan"],["ring","fan"],["shells","ring","charge"],["charge","shells","fan"],["ring","shells","charge","fan"]][stage_number - 1]
		return
	if DemoPacing.enabled(run) and run.stage_time>=180 and not roaming_mini_spawned:
		var mini_type: String="drifter" if route_index%2==0 else "bulwark"
		var roaming: Dictionary=RangedThreats.spawn(run,mini_type,Vector2.INF,true)
		if not roaming.is_empty(): roaming_mini_spawned=true
	if revised:
		var threat_index := int(run.stage_time / (30.0 if DemoPacing.enabled(run) else maxf(15,23-route_index*0.4) if Vanguard.enabled(run) else 26))
		if threat_index > threat_wave:
			threat_wave = threat_index
			var roster: Array=["lancer","volley","bomber"]
			if Vanguard.enabled(run):
				roster=["breacher","volley","lancer","scatter"] if route_index==0 else ["breacher","mender","scatter","lancer","volley","bomber"]
				if ReviewRules.enabled(run): roster=ReviewRules.specialist_roster(route_index)
				if operation_chapter>0: roster=OperationRules.roster(run)
			if ArsenalBurst.enabled(run): roster=roster.filter(func(id): return id not in ["emp","uplink"])
			var selected: String=roster[(threat_index+route_index-1)%roster.size()]
			if SupportModules.enabled(run) and Mosquito.wave(operation_chapter,route_index,threat_index): selected="mosquito"
			if ArsenalBurst.enabled(run) and (operation_chapter>=2 or route_index>=1):
				if threat_index%4==1: selected="hatchery"
				elif threat_index%4==3: selected="scatter"
			if DemoPacing.enabled(run): selected=DemoPacing.specialist(run,threat_index)
			if selected!="": RangedThreats.spawn(run,selected)
	run.spawn_clock -= delta
	if run.spawn_clock <= 0:
		run.spawn_clock = maxf(0.45, 1.5 - stage_number * 0.11)
		if Vanguard.enabled(run): run.spawn_clock/=1.0+0.012*route_index+0.15*clampf(run.stage_time/round_seconds(),0,1)
		var before: int = run.enemies.size()
		run._spawn_pack(2 + stage_number / 2 + (1 if kind == "loot" else 0), int(run.stage_time) % 15 > 11)
		for i in range(before, run.enemies.size()):
			var enemy: Dictionary = run.enemies[i]
			if not Vanguard.enabled(run): enemy.hp *= (1 + (stage_number - 1) * 0.22) * (1.2 if ascension >= 2 else 1)
			enemy.max_hp = enemy.hp
	var wave := int(run.stage_time / (50 if DemoPacing.enabled(run) else 17))
	if wave > last_wave:
		last_wave = wave
		if wave > 0:
			run._spawn_pack(7 + stage_number + (3 if ascension >= 2 else 0) + (mini(5,route_index/4) if Vanguard.enabled(run) else 0), true)
			run.emit_event("surge", run.player)
	if not revised and not encounter_spawned and kind == "neutral" and (route_index > 0 or run.stage_time >= 28):
		if run.stage_time >= 28:
			encounter_spawned = true
			DemoCampaign.spawn_special(run, "rammer" if route_index % 2 == 0 else "artillery")
			var mini_boss: Dictionary = run.enemies.back()
			mini_boss.hp = (65 + stage_number * 25) * (1.2 if ascension >= 2 else 1); mini_boss.max_hp = mini_boss.hp

func enemy_killed(run, enemy: Dictionary) -> void:
	if practice: return
	if DiscoveryRules.enabled(run): run.discovery_chests.killed(run,enemy); return
	if enemy.has("role") or enemy.has("miniboss") or (enemy.get("elite", false) and run.loot_rng.randf() < 0.2*DemoPacing.reward_rate(run)):
		loot_chests.append({"pos": enemy.pos, "life": 30.0})
		if loot_chests.size() > 8: pending_chests += 1; loot_chests.pop_front()

func level_up(run) -> void:
	if run.level % 5 == 0: pending_chests += 1

func finish_step(run, delta: float) -> void:
	if run.state != "running": return
	run.factory_works.step(run,delta)
	OperationRules.pace(run)
	if ReviewRules.enabled(run) and not practice: RunDiagnostics.sample_progression(run)
	if practice:
		if god_mode: run.health = run.max_health()
		if free_energy: run.kit.energy = run.kit.energy_max()
		if fast_cooldowns:
			for slot in run.kit.ranks:
				run.kit.charges[slot] = MobaKit.ABILITIES[run.kit.loadout[slot]].max
				run.kit.recharge[slot] = 0.0
		return
	if Vanguard.enabled(run): Vanguard.progression(run)
	if ReviewRules.enabled(run): ReviewRules.offer(run)
	if DiscoveryRules.enabled(run) and run.state!="running": return
	courier_clock = maxf(0, courier_clock - delta)
	dynamo_clock = maxf(0, dynamo_clock - delta)
	bastion_clock = maxf(0, bastion_clock - delta)
	energy_meter += maxf(0, run.kit.energy_spent - previous_energy_spent)
	previous_energy_spent = run.kit.energy_spent
	if dynamo_clock <= 0 and set_counts.get("dynamo", 0) >= 4 and energy_meter >= 80:
		energy_meter -= 80; dynamo_clock = 3; MobaKit.area(run, run.player, 150, 25, "dynamo", 80)
	if bastion_clock <= 0 and set_counts.get("bastion", 0) >= 4:
		var enemy: Dictionary = run.nearest_enemy(run.player)
		if not enemy.is_empty() and run.player.distance_to(enemy.pos) < 140: run.kit.shield = 2; run.kit.shield_hits = 1; bastion_clock = 12
	energy_meter = minf(160, energy_meter)
	run.health = minf(max_health(run), run.health + (stats.get("health_regen", 0) + (0.35 if class_id == "melee" else 0.12)) * delta * (0.8 if ascension >= 3 else 1))
	for chest in loot_chests:
		chest.life -= delta
		if run.player.distance_to(chest.pos) < (run.magnet_radius() if DiscoveryRules.enabled(run) else 52) or chest.life <= 0: pending_chests += 1; chest.life = -1
	loot_chests = loot_chests.filter(func(c: Dictionary) -> bool: return c.life > 0)
	if DiscoveryRules.enabled(run):
		Vanguard.progression(run); ReviewRules.offer(run)
		if run.state!="running": return
	var kind: String = route()[route_index][1]
	var ready: bool = run.boss_defeated if kind in ["boss", "final"] else run.stage_time >= round_seconds() and run.enemies.filter(func(e: Dictionary) -> bool: return e.has("role") and not e.dead).is_empty()
	if ready:
		if clear_clock < 0:
			clear_clock = 12.0 if revised else 1.4
			if DiscoveryRules.enabled(run):
				FieldPickups.sweep(run)
				Vanguard.progression(run); ReviewRules.offer(run)
			if revised:
				run.enemies.clear(); run.projectiles.clear(); run.hazards.clear()
		if DiscoveryRules.enabled(run) and run.state!="running": return
		clear_clock -= delta
		if clear_clock <= 0:
			cleared += 1
			run.enemies.clear()
			for pickup in run.pickups.duplicate(): run.collect_pickup(pickup)
			run.pickups.clear()
			for supply in run.supply_drops: run._collect_supply(supply)
			run.supply_drops.clear()
			carry_credits += run.coins
			if operation_chapter>0: carry_credits+=40+route_index*15+operation_chapter*5
			var field_reward: int=OperationRules.FIELD_REWARD[route_index] if operation_chapter>0 else 65+stage_number()*15
			field_credits += field_reward
			if Vanguard.enabled(run): reward_receipt.credits+=field_reward
			run.coins = 0
			pending_chests += (0 if DiscoveryRules.enabled(run) else 3 if kind == "loot" else 1) + loot_chests.size(); loot_chests.clear(); clear_clock = -2
			if kind == "loot":
				pending_items.append(ForgeEquipment.roll_item(run.loot_rng,ascension) if run.kit.flexible() else ExpeditionGear.roll_item(run.loot_rng,ascension))
				if Vanguard.enabled(run): reward_receipt.items[pending_items.back()]=int(reward_receipt.items.get(pending_items.back(),0))+1
			run.enemies.clear(); run.projectiles.clear(); run.hazards.clear()
			run.health = minf(max_health(run), run.health + max_health(run) * 0.2)
			run.kit.energy = run.kit.energy_max()
			run.state = "camp"
			run.emit_event("stage_clear",run.player)
			if Vanguard.enabled(run): Vanguard.progression(run)
			return
		if revised: return # Collection is uninterrupted; choices wait for camp.
	if Vanguard.enabled(run): return
	if run.total_xp >= run.next_level:
		run._make_offers(); run.state = "upgrade"; run.emit_event("upgrade", run.player)
	elif pending_chests > 0:
		make_chest(run); run.state = "chest"

func make_chest(run) -> void:
	if run.kit.flexible(): KeyboardRewards.make_chest(run); return
	chest_choices.clear()
	chest_return = "camp" if run.state == "camp" else "running"
	var slots: Array = MobaKit.SLOTS.duplicate()
	for i in range(1,4): slots.append("p%d" % (i + 1))
	var locked: Array = slots.filter(func(s: String) -> bool: return not run.kit.unlocked(s))
	var used_slots: Array = []
	for i in range(3):
		var available: Array = slots.filter(func(s: String) -> bool: return s not in used_slots)
		var slot: String = locked.pop_front() if not locked.is_empty() else available[run.offer_rng.randi_range(0, available.size() - 1)]
		used_slots.append(slot)
		var id: String
		if slot.begins_with("p"):
			id = run.kit.loadout.passives[int(slot.substr(1)) - 1]
			if run.kit.unlocked(slot) and run.offer_rng.randf() < 0.65:
				var options: Array = MobaKit.PASSIVES.keys().filter(func(p: String) -> bool: return p not in run.kit.loadout.passives and p != "ricochet")
				options = options.filter(func(p: String) -> bool:
					var candidate: Dictionary = run.kit.loadout.duplicate(true)
					candidate.passives[int(slot.substr(1))-1] = p
					return MobaKit.valid_loadout(candidate))
				if not options.is_empty(): id = options[run.offer_rng.randi_range(0, options.size()-1)]
		else:
			var pool: Array = BotSkillCatalog.modern_ids(MobaKit.category(slot))
			pool = pool.filter(func(candidate: String) -> bool: return candidate not in run.kit.loadout.values() or candidate == run.kit.loadout[slot])
			id = run.kit.loadout[slot] if not run.kit.unlocked(slot) or run.offer_rng.randf() < 0.4 else BotSkillCatalog.draw_discovery(pool,run.offer_rng)
		var rarity := 2 if run.offer_rng.randf() < 0.08 else (1 if run.offer_rng.randf() < 0.25 else 0)
		chest_choices.append({"slot": slot, "id": id, "tier": rarity})

func choose_chest(run, index: int) -> bool:
	if run.kit.flexible(): return KeyboardRewards.choose(run,index)
	if run.state != "chest" or index < 0 or index >= chest_choices.size() or pending_chests <= 0: return false
	var choice: Dictionary = chest_choices[index]
	var slot: String = choice.slot
	var known: bool = run.kit.unlocked(slot)
	if slot.begins_with("p"):
		var passive_index := int(slot.substr(1)) - 1
		if known and run.kit.loadout.passives[passive_index] == choice.id: field_credits += 40
		else: run.kit.loadout.passives[passive_index] = choice.id
	else:
		if known and run.kit.loadout[slot] == choice.id:
			for i in range(2):
				if run.kit.rank_up(slot): run.upgrades["skill_" + slot] = run.kit.ranks[slot]
				else: field_credits += 20
		else: install(run, slot, choice.id)
		run.kit.tiers[slot] = maxi(run.kit.tiers[slot], choice.tier)
	if slot not in run.kit.discovered: run.kit.discovered.append(slot)
	pending_chests -= 1; chests_opened += 1
	if run.loot_rng.randf() < 0.18: pending_items.append(ExpeditionGear.roll_item(run.loot_rng, ascension))
	chest_choices.clear()
	if set_counts.get("reclaimer", 0) >= 4: run.health = minf(max_health(run), run.health + max_health(run) * 0.08)
	run.state = chest_return
	return true

func install(run, slot: String, id: String, unlock: bool = true) -> void:
	run.kit.loadout[slot] = id
	run.kit.ranks[slot] = 0; run.kit.tiers[slot] = 0
	run.upgrades["skill_" + slot] = 0
	run.kit.charges[slot] = MobaKit.ABILITIES[id].max; run.kit.recharge[slot] = 0.0
	run.kit.extra.recasts.erase(slot)
	if unlock and slot not in run.kit.discovered: run.kit.discovered.append(slot)

func advance(run) -> void:
	if run.state != "camp" or pending_chests > 0: return
	if final_round(): run.state = "won"; return
	route_index += 1
	enter(run)

func is_shop(every_stage: bool=false) -> bool:
	if operation_chapter>0: return false # Field shops sell modules; permanent crates live at Home.
	if every_stage: return route_index==ROUTE.size()-1 or ROUTE[route_index+1][0]!=ROUTE[route_index][0]
	return route_index in [5,12,19]

func ensure_shop(run) -> void:
	if run.state!="camp" or not is_shop(Vanguard.enabled(run)) or not shop_stock.is_empty(): return
	for i in range(3): shop_stock.append(ForgeEquipment.roll_item(run.loot_rng,ascension) if run.kit.flexible() else ExpeditionGear.roll_item(run.loot_rng,ascension))
