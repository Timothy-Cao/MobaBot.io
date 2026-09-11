class_name ReviewRules
extends RefCounted
## September human-review rules. Opt-in new runs preserve older checkpoints.
const CORE := ["q","w","e","r","d","f","gun","hammer"]
const MODULES := ["p1","x1","x2","x3"]
const BOSS_ENRAGE_SECONDS := 300.0

static func boss_overtime(run) -> float:
	if not enabled(run) or run.exp.practice or not run.boss_spawned or run.boss_defeated: return 0.0
	return maxf(0,run.stage_time-run.exp.round_seconds()-boss_deadline(run))

static func boss_deadline(run) -> float:
	return OperationRules.ENRAGE_SECONDS if OperationRules.enabled(run) else BOSS_ENRAGE_SECONDS

static func specialist_roster(round_index: int) -> Array:
	# Teach pursuit and aimed shots first; add support/area denial next, EMP in Stage 2.
	if round_index==0: return ["breacher","volley","lancer","scatter"]
	if round_index<3: return ["breacher","mender","scatter","lancer","volley","bomber"]
	return ["breacher","mender","scatter","lancer","volley","bomber","emp"]

static func enabled(run) -> bool:
	return Vanguard.enabled(run) and run.kit.loadout.get("review19",false)

static func enable(run) -> void:
	run.kit.loadout.review19=true
	run.kit.loadout.unified_mastery=true; run.mastery.unified=true
	run.kit.charges.f=1 if run.kit.effective_rank("f")<5 else 2
	RunTerrain.build(run)

static func candidates(run) -> Array:
	return CORE.filter(func(slot): return Vanguard.rank_of(run,slot)<10)

static func offer(run) -> void:
	if run.exp.practice or run.exp.clear_clock>=0 or run.state not in ["running","upgrade"]: return
	if run.kit.loadout.rewards18.is_empty(): return
	var pool:=candidates(run)
	if pool.is_empty():
		run.exp.field_credits+=20*run.kit.loadout.rewards18.size()
		run.kit.loadout.rewards18.clear(); run.offers.clear(); run.state="running"; return
	if run.state=="upgrade" and not run.offers.is_empty(): return
	run.offers.clear()
	while run.offers.size()<3 and not pool.is_empty():
		var index: int=run.offer_rng.randi_range(0,pool.size()-1)
		run.offers.append(pool[index]); pool.remove_at(index)
	run.state="upgrade"; run.vanguard.ghost=false; run.kit.sprint=0; run.stop_movement(); run.attacks.stop(run)

static func choose(run, index: int) -> bool:
	if run.state!="upgrade" or index<0 or index>=run.offers.size(): return false
	if not Vanguard.spend(run,run.offers[index]): return false
	run.offers.clear(); run.state="running"; offer(run)
	return true

static func module_price(run, slot: String) -> int:
	return 100+Vanguard.rank_of(run,slot)*65

static func buy_module(game, slot: String) -> bool:
	var run=game.model
	if not enabled(run) or run.exp.practice or run.state!="camp" or slot not in MODULES or Vanguard.rank_of(run,slot)>=10 or game.collection.blocked: return false
	var price:=module_price(run,slot)
	if run.exp.field_credits<price: return false
	# One transaction: restore the complete affected simulation fields on disk failure.
	var loadout: Dictionary=run.kit.loadout.duplicate(true)
	var ranks: Dictionary=run.kit.ranks.duplicate(true)
	var discovered: Array=run.kit.discovered.duplicate()
	var upgrades: Dictionary=run.upgrades.duplicate()
	var recharge: Dictionary=run.kit.recharge.duplicate()
	var orbit: Array=run.orbit.duplicate(true)
	run.exp.field_credits-=price
	if slot=="p1":
		run.upgrades.grinder+=1
	else:
		run.kit.rank_up(slot); run.upgrades["skill_"+slot]=run.kit.ranks[slot]
	if slot not in run.kit.discovered: run.kit.discovered.append(slot)
	run._sync_resource_ranks()
	if not game.collection.bank_camp(run,game.persistent_run()):
		run.exp.field_credits+=price; run.kit.loadout=loadout; run.kit.ranks=ranks
		run.kit.discovered.assign(discovered); run.upgrades=upgrades; run.kit.recharge=recharge; run.orbit.assign(orbit)
		run._sync_resource_ranks(); return false
	run.emit_event("equipped",run.player,{"id":Vanguard.TOOLS[slot]})
	return true

static func drive_cost(run) -> float:
	# Rank 1: 100 energy / (28 drain - 8 regen) = 5 seconds.
	# Rank 10: 8 / 10 gross drain = 80% duty cycle without other spending.
	return lerpf(28.0,10.0,float(clampi(run.kit.effective_rank("d"),1,10)-1)/9.0)*(1-run.kit.energy_efficiency)

static func suppress(run, seconds: float=3.0) -> void:
	if not enabled(run): return
	if LevelMastery.enabled(run): seconds*=1-run.mastery.value("emp_resist")
	run.vanguard.emp_left=maxf(run.vanguard.emp_left,seconds)
	run.kit.emp_left=run.vanguard.emp_left
	run.vanguard.ghost=false; run.kit.sprint=0
	run.emit_event("energy_empty",run.player)

static func tick(run, delta: float) -> void:
	LevelMastery.tick(run,delta)
	var v=run.vanguard
	v.emp_left=maxf(0,v.emp_left-delta); run.kit.emp_left=v.emp_left
	v.combo_left=maxf(0,v.combo_left-delta)
	for enemy in run.enemies:
		if enemy.has("vulnerable"): enemy.vulnerable=maxf(0,enemy.vulnerable-delta)
		if enemy.has("stun_guard"): enemy.stun_guard=maxf(0,enemy.stun_guard-delta)

static func strike_status(run, enemy: Dictionary, center: bool) -> void:
	# The triggering W cannot amplify itself. Repeated W refreshes rather than stacks.
	enemy.vulnerable=1.0
	if center and float(enemy.get("stun_guard",0))<=0:
		enemy.stun=maxf(float(enemy.get("stun",0)),1.1)
		if enemy.has("role"): enemy.stun_guard=4.0

static func hammer_multiplier(run, enemy: Dictionary) -> float:
	# Boss-specific payoff is concentrated in a deliberate E follow-up.
	return (3.0 if enemy.has("role") else 1.5) if run.vanguard.combo_swing else 0.9

static func terrain(run) -> void:
	run.kit.extra.walls.clear()
	for row in range(5):
		for col in range(7):
			var center:=Vector2(-1800+col*600+(150 if row%2 else 0),-1100+row*550)
			if center.distance_to(run.player)<340: continue
			var axis:=Vector2.from_angle([0.0,PI/2,PI/6][(row+col)%3])
			var half_length: float=100 if (row+col)%2 else 140
			run.kit.extra.walls.append({"uid":-1000-row*7-col,"a":center-axis*half_length,"b":center+axis*half_length,"width":65.0 if col%2 else 85.0,"life":99999.0,"terrain":true})

static func estimate_rank(round_index: int) -> int:
	# Fixed reference progression, never adaptive scaling against a player's build.
	return mini(10,1+round_index/2)

static func reference_w(round_index: int) -> float:
	return 76.0*1.2*Vanguard.power(estimate_rank(round_index))

static func scale_role(run, enemy: Dictionary) -> void:
	if run.exp.practice or enemy.get("review_scaled",false): return
	enemy.review_scaled=true
	if enemy.has("exp_boss"): return
	var budget:=reference_w(run.exp.route_index)
	if OperationRules.enabled(run): budget=91.2*Vanguard.power(OperationRules.reference_rank(run.exp.route_index))*OperationRules.chapter_health(run.exp.operation_chapter)
	var factor: float=1.0+run.exp.ascension*0.06
	if enemy.has("gunner_kind"):
		var tank: bool=enemy.gunner_kind in ["lancer","volley","emp"]
		enemy.hp=maxf(enemy.hp,budget*(1.3 if tank else 0.7)*factor)
	elif enemy.has("role"):
		enemy.hp=maxf(enemy.hp,budget*4.0*factor)
	elif enemy.kind==3:
		enemy.hp=maxf(enemy.hp,budget*2.1*factor)
	enemy.max_hp=enemy.hp

static func detail(run, slot: String) -> String:
	match slot:
		"w": return "Core strike · Two charges\nCenter deals double damage and stuns for 1.1s.\nHit: +50% damage taken for 1s; does not stack.\nBosses resist another center stun for 4s."
		"e": return "Body slam · Two charges\nAfter landing, hammer within 1.2s for a combo.\nCombo: 3× hammer damage to bosses/guardians; 1.5× to others.\nOne wall rebound; 2× remaining distance."
		"r": return "Reactor drop\n1 second descent: set up with W's center stun.\n5: impact grants shield if inside. 10: second impact."
		"hammer": return "Hammer\nE landing readies one empowered swing for 1.2s.\nCombo deals 3× damage to bosses/guardians.\nOrdinary swings deal 90% of the previous baseline."
		"d": return "Ghost drive\nHold D · %.1f energy/sec. No invulnerability.\nAbout 5s early endurance; 80%% rank-10 duty cycle\nwith base regeneration and no other spending.\n10: cast while driving."%drive_cost(run)
		"f": return "Phase hop\nOne charge. Rank 5: two charges, lower cost/recharge.\nRank 10: arrival blast."
		"p1": return "Orbit\nBuy and upgrade with field credits at round clear.\nEarly ranks: short reach, slower rotation and lower damage.\n1 switches near/far radius. Suppressed by EMP."
	return ""
