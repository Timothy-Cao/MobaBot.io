class_name Vanguard
extends RefCounted
## Fixed-kit rules. Durable choices live in loadout; transient combat never does.
const KEYS := {"q":KEY_Q,"w":KEY_W,"e":KEY_E,"r":KEY_R,"d":KEY_D,"f":KEY_F,"p1":KEY_1,"x1":KEY_2,"x2":KEY_3,"x3":KEY_4}
const TOOLS := {"q":"rocket","w":"strike","e":"body_slam","r":"reactor_drop","d":"sprint","f":"blink","p1":"orbit","x1":"guard_bot","x2":"reserve_totem","x3":"recovery_totem"}
const POWER := [1.0,1.0,1.08,1.16,1.24,1.60,1.77,1.94,2.11,2.28,3.30]
const GUN_POWER := [1.0,1.0,1.07,1.14,1.21,1.50,1.64,1.78,1.92,2.06,2.40]
const GUN_INTERVAL := [0.24,0.24,0.232,0.224,0.216,0.20,0.19,0.18,0.17,0.16,0.15]
const TURRET_RANGE := 320.0

static func gun_rank(run) -> int:
	return mini(10,rank_of(run,"gun")+run.kit.rank_bonus)

static func gun_special(run, fired: int) -> bool:
	if SupportModules.enabled(run): return false
	return gun_rank(run)>=10 and (fired+1)%5==0

static func gun_paused(run) -> bool:
	if SupportModules.enabled(run): return false
	return gun_rank(run)<5 and (run.vanguard.ghost or run.vanguard.slam_left>0 or run.kit.dash_left>0)

static func gun_bullet(run, origin: Vector2, direction: Vector2, damage: float, reach: float, fired: int, kind: String, pierce: int=0) -> bool:
	if run.projectiles.size()>=run.MAX_PROJECTILES: return false
	var special:=gun_special(run,fired)
	var speed: float=950 if special else 700
	if SupportModules.enabled(run): speed=2600; pierce=2 if gun_rank(run)>=10 else 0
	run._add_projectile(origin+direction*20,direction*speed,damage*(2 if special else 1),kind,maxi(pierce,3) if special else pierce)
	var bullet: Dictionary=run.projectiles.back()
	bullet.life=(reach-20)/speed; bullet.basic_attack=true
	bullet.autonomous=true; bullet.visual_rank=gun_rank(run); bullet.gun_special=special
	return true

static func power(rank_value: int) -> float:
	return POWER[clampi(rank_value,1,10)]

static func hammer_rank(run) -> int:
	return mini(10,rank_of(run,"hammer")+run.kit.rank_bonus)

static func hammer_angle(run) -> float:
	return deg_to_rad(70 if hammer_rank(run)>=10 else 60 if hammer_rank(run)>=5 else 45)

static func hammer_roots(run) -> bool:
	return hammer_rank(run)<10

static func drive_upkeep(rank_value: int) -> float:
	return (12.0 if rank_value<5 else 7.0)-maxi(0,rank_value-(1 if rank_value<5 else 5))*0.2

static func slam_range(rank_value: int, compact: bool=false) -> float:
	if compact: return 209.0
	return 397.1 if rank_value>=10 else 292.6 if rank_value>=5 else 209.0

func drive_blocks(run) -> bool:
	return ghost and run.kit.effective_rank("d")<10
var emp_left := 0.0
var combo_left := 0.0
var combo_swing := false
var helper_clock := 0.0
var helper_stun := 0.0
var helper_safe := 0.0
var helper_health := 0.0
var ghost := false
var gun_on := true
var gun_shots := 0
var orbit_angle := 0.0
var pending: Dictionary = {}
var hammer := -1.0
var hammer_direction := Vector2.RIGHT
var hammer_cooldown := 0.0
var slam_left := 0.0
var slam_direction := Vector2.RIGHT
var slam_bounced := false
var buffered_hammer := false
var buffered_e := false
var buffered_e_target := Vector2.ZERO
var slam_fueled := false
var spin_swing := false
var conductor_active := false
var conductor:=Conductor.new()
var burst_left:=0.0
var burst_ammo:=0
var burst_clock:=0.0
const SLAM_SPEED := 950.0
const REBOUND_SPEED := 1425.0
var touch_guard := 0.0
var touch_grace := 0.0
var shield := 0.0
var constructs: Array[Dictionary] = []
var impacts: Array[Dictionary] = []
var ghosts: Array[Dictionary] = []
var ghost_clock := 0.0
var freeze_ai := false
var time_scale := 1.0

static func abilities() -> Dictionary:
	return {
		"body_slam":{"name":"Body slam","category":"active","icon":"thrust","glyph":"dash","cd":8.0,"max":2,"range":210.0,"aim":"line","cost":14,"text":"Two charges. One wall rebound for 2× remaining distance. Rank 5: +40% reach and stun. Rank 10: +90% reach and impact shield."},
		"reactor_drop":{"name":"Reactor drop","category":"ultimate","icon":"nuke","glyph":"target","cd":28.0,"max":1,"range":620.0,"aim":"ground","cost":32,"text":"Delayed wide reactor impact. Rank 5: standing inside grants a shield. Rank 10: second impact and stun."},
		"guard_bot":{"name":"Bulwark","category":"summon","icon":"pulse_sentry","glyph":"turret","cd":16.0,"max":1,"range":340.0,"aim":"ground","cost":20,"text":"A durable decoy with a weak gun and pulse. Draws up to four ordinary enemies. Redeploy replaces it."},
		"reserve_totem":{"name":"Reserve","category":"summon","icon":"medic_sentry","glyph":"cross","cd":10.0,"max":1,"range":340.0,"aim":"ground","cost":16,"text":"Banks repair while you are away. Return to convert reserve into hull, then energy, then a shock wave. Redeploy clears reserve."},
		"recovery_totem":{"name":"Overclock well","category":"summon","icon":"pylon","glyph":"sun","cd":15.0,"max":1,"range":340.0,"aim":"ground","cost":20,"text":"Double recharge and free ability energy inside. Rank 5: 7 seconds. Rank 10: 9 seconds and triple recharge. Cooldown starts on expiry."}}

static func enabled(run) -> bool:
	return run != null and run.kit != null and run.kit.loadout.get("vanguard",false)

static func setup(run, rank_value: int = 0) -> void:
	BotKeyboard.enable(run)
	run.kit.loadout.erase("review19"); run.kit.emp_left=0
	run.kit.loadout.erase("unified_mastery")
	run.kit.loadout.erase("operation20"); run.kit.loadout.erase("operation_xp")
	run.kit.loadout.erase("level22")
	run.kit.loadout.erase("support23")
	run.kit.loadout.erase("arsenal26")
	if run.mastery is ExpeditionTree: run.mastery.modern=false
	if run.exp!=null: run.exp.operation_chapter=0
	if run.mastery is ExpeditionTree: run.mastery.unified=false
	var kit: MobaKit = run.kit
	kit.loadout["vanguard"] = true
	kit.loadout["rewards18"] = []
	kit.loadout["reward_turn18"] = 0
	kit.loadout["hammer_rank"] = maxi(1,rank_value)
	kit.loadout["library"] = {}
	kit.discovered.clear()
	kit.loadout.passives = ["orbit","","","","","","","",""]
	kit.toggles.assign([true,false,false,false,false,false,false,false,false])
	for slot in kit.bindings: kit.bindings[slot] = 0
	for slot in KEYS:
		kit.bindings[slot] = KEYS[slot]
		if slot != "p1":
			kit.loadout[slot] = TOOLS[slot]
			kit.ranks[slot] = maxi(1,rank_value) if rank_value > 0 or slot in ["q","d","f"] else 0
			run.upgrades["skill_"+slot] = kit.ranks[slot]
			kit.charges[slot] = MobaKit.ABILITIES[TOOLS[slot]].max
			if slot in ["q","w","e"]: kit.charges[slot]=2
			kit.recharge[slot] = 0.0
		if rank_value > 0 or slot in ["q","d","f"]: kit.discovered.append(slot)
	run.upgrades.grinder = rank_value
	run.upgrades.power = maxi(0,rank_value-1)
	kit.gun_sniper = false
	run.vanguard = Vanguard.new()
	run._sync_resource_ranks()

static func rank_of(run, slot: String) -> int:
	if slot == "hammer": return int(run.kit.loadout.get("hammer_rank",1))
	if slot == "gun": return mini(10,1+int(run.upgrades.power))
	if slot == "p1": return int(run.upgrades.grinder) if run.kit.unlocked(slot) else 0
	return int(run.kit.ranks.get(slot,0))

static func candidates(run, kind: String) -> Array:
	var result: Array = []
	if kind=="": return result
	if ReviewRules.enabled(run): return ReviewRules.candidates(run)
	var advanced:=true
	for slot in KEYS.keys()+["gun","hammer"]:
		if rank_of(run,slot)<5: advanced=false; break
	for slot in KEYS.keys()+["gun","hammer"]:
		var rank_value := rank_of(run,slot)
		if rank_value<5 or (advanced and rank_value<10): result.append(slot)
	return result

static func reward_kind(run) -> String:
	var queue: Array = run.kit.loadout.get("rewards18",[])
	if queue.is_empty(): return ""
	return "upgrade" if not candidates(run,"upgrade").is_empty() else ""

static func earn(run) -> void:
	var turn: int = run.kit.loadout.reward_turn18
	# Keep the validated checkpoint queue format; both old kinds now mean one point.
	run.kit.loadout.rewards18.append("upgrade")
	run.kit.loadout.reward_turn18 = turn+1
	if run.kit.loadout.rewards18.size()>256: run.kit.loadout.rewards18.pop_back()

static func spend(run, slot: String) -> bool:
	if not enabled(run) or slot not in candidates(run,reward_kind(run)) or reward_kind(run)=="": return false
	if ReviewRules.enabled(run) and (run.state!="upgrade" or slot not in run.offers): return false
	if slot == "hammer": run.kit.loadout.hammer_rank=rank_of(run,slot)+1
	elif slot == "gun": run.upgrades.power += 1
	elif slot == "p1":
		run.upgrades.grinder += 1
		if slot not in run.kit.discovered: run.kit.discovered.append(slot)
		while run.orbit.size()<mini(run.capacity(),2+int(run.upgrades.grinder)/2): run.orbit.append({"slot":run.orbit.size(),"hits":3,"cooldown":0.0})
	else:
		run.kit.rank_up(slot); run.upgrades["skill_"+slot] = run.kit.ranks[slot]
		if slot not in run.kit.discovered: run.kit.discovered.append(slot)
	run.kit.loadout.rewards18.pop_front()
	run._sync_resource_ranks()
	run.emit_event("equipped",run.player,{"id":TOOLS.get(slot,"hammer" if slot=="hammer" else "power")})
	if rank_of(run,slot) in [5,10]: run.emit_event("milestone",run.player,{"id":TOOLS.get(slot,"hammer" if slot=="hammer" else "power"),"rank":rank_of(run,slot)})
	return true

static func progression(run) -> void:
	while run.total_xp >= run.next_level and (not OperationRules.enabled(run) or run.level<26):
		run.level += 1
		run.next_level += OperationRules.XP_PER_LEVEL if OperationRules.enabled(run) else ceili((12+run.level*8)*BotExpedition.xp_factor(run.level))
		earn(run)
		if ReviewRules.enabled(run): earn(run); earn(run)
		if (run.level-1)%3==0: run.grant_utility()
		run.emit_event("equipped",run.player,{"id":"power"})
	# Chests remain tangible world loot; opening no longer stops the fight.
	var receipt:=RewardLedger.empty()
	while run.exp.pending_chests>0:
		run.exp.pending_chests -= 1; run.exp.chests_opened += 1
		receipt.chests+=1; receipt.credits+=20; run.exp.field_credits+=20
		if LevelMastery.enabled(run) and run.mastery.value("double_chest")>0 and run.loot_rng.randf()<run.mastery.value("double_chest"):
			receipt.credits+=20; run.exp.field_credits+=20
		if ReviewRules.enabled(run): pass
		elif run.kit.loadout.rewards18.size()<256 and not candidates(run,"upgrade").is_empty():
			earn(run); receipt.points+=1
		else: receipt.credits+=20; run.exp.field_credits+=20
		if not OperationRules.enabled(run) and run.loot_rng.randf()<0.18:
			var item:=ForgeEquipment.roll_item(run.loot_rng,run.exp.ascension)
			run.exp.pending_items.append(item); receipt.items[item]=int(receipt.items.get(item,0))+1
	if receipt.chests>0:
		RewardLedger.merge(run.exp.reward_receipt,receipt)
		run.emit_event("chest_contents",run.player,{"receipt":receipt})
	if reward_kind(run)=="" and not run.kit.loadout.rewards18.is_empty():
		run.exp.field_credits += 20*run.kit.loadout.rewards18.size(); run.kit.loadout.rewards18.clear()

func clear() -> void:
	helper_clock=0; helper_stun=0; helper_safe=0; helper_health=0
	emp_left=0; combo_left=0; combo_swing=false
	ghost=false; pending.clear(); hammer=-1; slam_left=0; slam_bounced=false; touch_guard=0; shield=0
	buffered_hammer=false; slam_fueled=false; spin_swing=false
	buffered_e=false
	burst_left=0; burst_ammo=0; burst_clock=0
	constructs.clear(); impacts.clear(); ghosts.clear()
	hammer_cooldown=0; touch_grace=0; ghost_clock=0

func powered(run) -> bool:
	if SupportModules.enabled(run): return false
	if emp_left>0: return false
	for unit in constructs:
		if unit.id=="recovery_totem" and run.player.distance_to(unit.pos)<=unit.radius: return true
	return false

func cast(run, slot: String, cursor: Vector2) -> bool:
	var kit: MobaKit=run.kit
	kit.last_failure="Not ready"
	if emp_left>0 and slot in ReviewRules.MODULES+["d","f"]:
		kit.last_failure="EMP suppressed"; run.emit_event("cast_unready",run.player); return false
	if run.state!="running" or slot not in KEYS or not kit.unlocked(slot): return false
	if ArsenalBurst.enabled(run) and slam_left>0 and slot=="e":
		buffered_e=true; buffered_e_target=cursor; return true
	if slot=="d":
		if ghost: return true
		if kit.energy<2:
			kit.last_failure="Low energy"; run.emit_event("energy_empty",run.player); return false
		if not pending.is_empty() or slam_left>0: return false
		ghost=true; hammer=-1; run.attacks.stop(run)
		run.emit_event("v_drive",run.player); return true
	if SupportModules.enabled(run) and slam_left>0 and slot=="q":
		if slam_fueled or kit.charges.q<=0: return false
		var fuel: int=kit.charges.q
		kit.charges.q=0; slam_fueled=true
		if kit.recharge.q<=0: kit.recharge.q=kit.cooldown("q")
		slam_left+=float(fuel)*110.0/(REBOUND_SPEED if slam_bounced else SLAM_SPEED)
		poof(run.player,kit.effective_rank("q")); return true
	if drive_blocks(run) and not (SupportModules.enabled(run) and slot=="f"): kit.last_failure="Release D"; return false
	if slot=="p1": kit.orbit_far=not kit.orbit_far; kit.toggles[0]=true; run.emit_event("mode_switch",run.player); return true
	if (slam_left>0 and not (SupportModules.enabled(run) and slot=="f")) or (not pending.is_empty() and slot!="f"): return false
	if ArsenalBurst.enabled(run) and slot=="q" and burst_left>0 and emp_left<=0: return ArsenalBurst.fire(run,cursor)
	if kit.charges[slot]<=0: run.emit_event("cast_unready",run.player); return false
	var id: String=kit.loadout[slot]
	var cost: float=kit.ability_cost(id)
	if not powered(run) and kit.energy<cost:
		kit.last_failure="Low energy"; run.emit_event("energy_empty",run.player); return false
	var target: Vector2=kit.target_point(run,slot,cursor)
	if slot=="f": target=blink_target(run,target)
	if slot in ["f","e"] and target.distance_to(run.player)<1: return false
	if slot in ["x1","x2","x3"] and not (ArsenalBurst.enabled(run) and slot=="x3") and not valid_point(run,target,22): kit.last_failure="Blocked"; return false
	if not powered(run): kit.energy-=cost; kit.energy_spent+=cost
	kit.charges[slot]-=1
	if kit.recharge[slot]<=0: kit.recharge[slot]=kit.cooldown(slot)
	kit.cast_counts[id]=int(kit.cast_counts.get(id,0))+1
	if ArsenalBurst.enabled(run) and slot=="x3":
		burst_left=8; burst_clock=0; return true
	if Conductor.enabled(run) and slot in ["q","w","e","r"]:
		conductor.cast(run,slot,target); return true
	if slot=="f":
		poof(run.player,kit.effective_rank(slot)); poof(target,kit.effective_rank(slot))
		run.player=target; run.stop_movement()
		if SupportModules.enabled(run):
			ghost=false; kit.sprint=0; kit.dash_left=0
			if slam_left>0:
				slam_left=0
				blast(run,target,95*kit.area_scale("e"),32*kit.damage_scale("e"),"body_slam",0.6 if kit.effective_rank("e")>=5 else 0,240)
				if kit.effective_rank("e")>=10 and not ArsenalBurst.enabled(run): shield=1.0
				finish_slam(run,true)
			elif spin_swing and hammer>=0: hit_hammer(run)
		if kit.effective_rank("f")>=10:
			blast(run,target,110,30*kit.damage_scale("f"),"phase_hop",0,100)
			impacts.back().rank=10
		run.emit_event("v_blink",target)
		return true
	if slot=="e":
		slam_bounced=false
		slam_fueled=false; buffered_hammer=false; spin_swing=false
		slam_direction=(cursor-run.player).normalized(); slam_left=kit.cast_range("e")/SLAM_SPEED
		touch_guard=0.4; hammer=-1; run.attacks.stop(run)
		if kit.effective_rank(slot)>=10 and not ArsenalBurst.enabled(run): shield=0.45
		run.emit_event("v_slam",run.player); return true
	if slot in ["x1","x2","x3"]:
		constructs=constructs.filter(func(u): return u.id!=id)
		var lifetime: float=(5.0+kit.milestone(slot)*2.0) if slot=="x3" else 35.0
		if SupportModules.enabled(run): lifetime=35.0
		constructs.append({"id":id,"pos":target,"life":lifetime,"duration":lifetime,"clock":0.3,"shots":0,"bank":0.0,"radius":125.0+kit.milestone(slot)*20,"hp":135.0*power(kit.effective_rank(slot)),"max_hp":135.0*power(kit.effective_rank(slot)),"slot":slot,"pulse":2.0,"hurt_clock":0.0})
		constructs.back().rank=kit.effective_rank(slot)
		if SupportModules.enabled(run) and slot=="x1": constructs.back().radius=340.0
		poof(target,kit.effective_rank(slot)); return true
	# 80ms anticipation: F can move the unreleased origin; world aim stays fixed.
	pending={"slot":slot,"target":cursor,"left":0.08}
	run.emit_event("cast",run.player,{"ability":id,"target":target,"milestone":kit.milestone(slot)})
	kit.last_failure=""
	return true

func swing(run, cursor: Vector2) -> bool:
	if SupportModules.enabled(run) and run.state=="running" and slam_left>0:
		buffered_hammer=true; hammer_direction=(cursor-run.player).normalized(); return true
	if run.state!="running" or drive_blocks(run) or slam_left>0 or hammer_cooldown>0 or hammer>=0 or not pending.is_empty(): return false
	combo_swing=ReviewRules.enabled(run) and combo_left>0
	spin_swing=SupportModules.enabled(run) and combo_swing
	combo_left=0
	hammer=0.12 if combo_swing else 0.20; hammer_direction=(cursor-run.player).normalized()
	if hammer_direction==Vector2.ZERO: hammer_direction=Vector2.RIGHT
	hammer_cooldown=run.attacks.interval(run)
	if hammer_roots(run): run.stop_movement()
	run.aim=hammer_direction
	if ArsenalBurst.enabled(run) and spin_swing: hit_hammer(run)
	return true

func finish_slam(run, immediate: bool=false) -> void:
	if ArsenalBurst.enabled(run):
		combo_left=0.1
		if buffered_hammer:
			buffered_hammer=false; combo_swing=true; spin_swing=true
			hammer_cooldown=run.attacks.interval(run); combo_left=0; hit_hammer(run)
		if buffered_e:
			buffered_e=false
			cast(run,"e",buffered_e_target)
		return
	if ReviewRules.enabled(run): combo_left=1.2
	if buffered_hammer:
		var started:=swing(run,run.player+hammer_direction)
		buffered_hammer=not started
		if started and immediate: hit_hammer(run)

func hit_hammer(run) -> void:
	var reach: float=run.attacks.attack_range(run)
	var spin_bonus: float=1.15 if spin_swing and ArsenalBurst.enabled(run) else 1.0
	for enemy in run.enemies:
		var offset: Vector2=enemy.pos-run.player
		if run.attacks.valid(enemy) and offset.length()<=reach+enemy.radius and (spin_swing or absf(hammer_direction.angle_to(offset))<=hammer_angle(run)):
			var head: bool=offset.length()>=reach*0.512
			run.hit_enemy(enemy,(38 if head else 9)*power(hammer_rank(run))*(1+run.kit.attack_damage_bonus)*(ReviewRules.hammer_multiplier(run,enemy) if ReviewRules.enabled(run) else 1.0)*spin_bonus,"hammer",offset.normalized()*190 if head and not enemy.has("role") else Vector2.ZERO)
			if head and not enemy.has("role"): enemy.stun=0.25
	impacts.append({"kind":"hammer","pos":run.player,"direction":hammer_direction,"life":0.30,"duration":0.30,"radius":reach,"angle":PI if spin_swing else hammer_angle(run),"rank":hammer_rank(run)})
	run.emit_event("v_hammer",run.player); hammer=-1; spin_swing=false

func poof(point: Vector2, rank_value: int=1) -> void:
	impacts.append({"kind":"poof","pos":point,"life":0.3,"duration":0.3,"radius":30.0,"rank":rank_value})

func release(run) -> void:
	var slot: String=pending.slot
	var cursor: Vector2=pending.target
	var direction: Vector2=(cursor-run.player).normalized()
	var kit: MobaKit=run.kit
	var scale_value: float=kit.damage_scale(slot)
	if direction==Vector2.ZERO: direction=run.aim
	if slot=="q":
		var before: int=run.projectiles.size()
		run._add_projectile(run.player,direction*790,15*scale_value,"rocket",0)
		if run.projectiles.size()>before:
			var bullet: Dictionary=run.projectiles.back()
			bullet.life=kit.cast_range(slot)/790; bullet.blast=8*scale_value; bullet.radius=62*kit.area_scale(slot); bullet.milestone=kit.milestone(slot)
	else:
		var p: Vector2=kit.target_point(run,slot,cursor)
		impacts.append({"kind":"strike" if slot=="w" else "reactor","pos":p,"life":0.55 if slot=="w" else 0.75,"duration":0.55 if slot=="w" else 0.75,"radius":100.0*kit.area_scale(slot) if slot=="w" else 170.0*kit.area_scale(slot),"slot":slot,"damage":38.0*scale_value if slot=="w" else 135.0*scale_value,"rank":kit.effective_rank(slot)})
		if ReviewRules.enabled(run) and slot=="r": impacts.back().life=1.0; impacts.back().duration=1.0
		if slot=="r" and kit.effective_rank(slot)>=10: impacts.back().damage*=0.8
	pending.clear()

func tick(run, delta: float) -> void:
	burst_left=maxf(0,burst_left-delta); burst_clock=maxf(0,burst_clock-delta)
	if burst_left<=0: burst_ammo=0
	if Conductor.enabled(run): conductor.tick(run,delta)
	if ReviewRules.enabled(run): ReviewRules.tick(run,delta)
	orbit_angle=fposmod(orbit_angle+delta*(lerpf(3.0,10.2,float(clampi(rank_of(run,"p1"),1,10)-1)/9.0) if ReviewRules.enabled(run) else 10.2),TAU)
	if run.kit.passive_active("orbit"):
		while run.orbit.size()<mini(run.capacity(),3+int(run.rank_of("grinder"))/2):
			run.orbit.append({"slot":run.orbit.size(),"hits":9999,"cooldown":0.0})
	touch_guard=maxf(0,touch_guard-delta); touch_grace=maxf(0,touch_grace-delta); shield=maxf(0,shield-delta)
	hammer_cooldown=maxf(0,hammer_cooldown-delta)
	for trace in ghosts: trace.life-=delta
	ghosts=ghosts.filter(func(g): return g.life>0)
	if ghost:
		var upkeep: float=ReviewRules.drive_cost(run) if ReviewRules.enabled(run) else drive_upkeep(run.kit.effective_rank("d"))
		if run.kit.energy<delta*upkeep: ghost=false; run.kit.sprint=0
		else:
			run.kit.energy-=delta*upkeep; run.kit.energy_spent+=delta*upkeep
			run.kit.sprint=0.1
			ghost_clock-=delta
			if ghost_clock<=0:
				ghost_clock=0.08; ghosts.append({"pos":run.player,"life":0.32})
	if not pending.is_empty():
		pending.left-=delta
		if pending.left<=0: release(run)
	if hammer>=0:
		hammer-=delta
		if hammer_roots(run): run.stop_movement()
		if hammer<=0:
			hit_hammer(run)
	if buffered_hammer and slam_left<=0:
		if combo_left<=0: buffered_hammer=false
		elif hammer<0 and hammer_cooldown<=0: finish_slam(run)
	if slam_left>0:
		step_slam(run,delta)
		if slam_left<=0: finish_slam(run)
		run.stop_movement()
	for unit in constructs.duplicate():
		if emp_left>0:
			unit.life-=delta
			if unit.life<=0: constructs.erase(unit)
			continue
		var current_rank: int=run.kit.effective_rank(unit.slot)
		if unit.get("rank",current_rank)!=current_rank:
			var hull_fraction: float=unit.hp/unit.max_hp
			unit.max_hp=135.0*power(current_rank); unit.hp=unit.max_hp*hull_fraction
			unit.radius=125.0+run.kit.milestone(unit.slot)*20
			if SupportModules.enabled(run) and unit.slot=="x1": unit.radius=340.0
			if unit.id=="recovery_totem" and not SupportModules.enabled(run):
				var duration: float=5.0+run.kit.milestone(unit.slot)*2.0
				unit.life+=duration-unit.duration; unit.duration=duration
			unit.rank=current_rank
		unit.life-=delta; unit.clock-=delta; unit.pulse-=delta; unit.hurt_clock=maxf(0,unit.hurt_clock-delta)
		var inside: bool=run.player.distance_to(unit.pos)<=unit.radius
		var rank_value: int=run.kit.effective_rank(unit.slot)
		if unit.id=="guard_bot" and SupportModules.enabled(run):
			pass
		elif unit.id=="guard_bot":
			if unit.clock<=0:
				var enemy: Dictionary=run.nearest_enemy(unit.pos)
				var reach: float=520 if gun_special(run,unit.shots) else TURRET_RANGE
				if not enemy.is_empty() and Vector2(enemy.pos).distance_to(unit.pos)<reach:
					var direction: Vector2=(Vector2(enemy.pos)-Vector2(unit.pos)).normalized()
					if gun_bullet(run,unit.pos,direction,3.4*GUN_POWER[gun_rank(run)],reach,unit.shots,"sentry"):
						unit.shots+=1; unit.clock=0.8*GUN_INTERVAL[gun_rank(run)]/0.24; unit["aim"]=direction
			if unit.pulse<=0:
				unit.pulse=1.8 if rank_value>=5 else 2.4
				blast(run,unit.pos,unit.radius,6*power(rank_value),"bulwark",0.3 if rank_value>=10 else 0,40)
		elif unit.id=="reserve_totem":
			if not inside or rank_value>=10: unit.bank=minf(86*power(rank_value),unit.bank+delta*6*power(rank_value))
			if inside and unit.bank>0:
				var amount: float=minf(unit.bank,delta*45*sqrt(power(rank_value)))
				unit.bank-=amount
				var heal: float=minf(amount,run.max_health()-run.health); run.health+=heal; amount-=heal
				var energy: float=minf(amount,run.kit.energy_max()-run.kit.energy); run.kit.energy+=energy; amount-=energy
				if amount>0 and unit.pulse<=0: unit.pulse=1; blast(run,unit.pos,unit.radius,13*power(rank_value),"reserve",0,80)
		elif unit.id=="recovery_totem":
			if SupportModules.enabled(run):
				SupportModules.energy(run,unit,delta)
				if unit.life<=0: constructs.erase(unit)
				continue
			run.kit.charges[unit.slot]=0; run.kit.recharge[unit.slot]=run.kit.cooldown(unit.slot)
			if inside:
				for slot in KEYS:
					if slot!="p1" and slot!=unit.slot and run.kit.recharge[slot]>0: run.kit.recharge[slot]=maxf(0,run.kit.recharge[slot]-delta*(2.0 if rank_value>=10 else 1.0))
		if unit.life<=0 or unit.hp<=0: constructs.erase(unit)
	for effect in impacts.duplicate():
		effect.life-=delta
		if effect.life>0: continue
		impacts.erase(effect)
		if effect.kind not in ["strike","reactor"]: continue
		for enemy in run.enemies:
			if not run.attacks.valid(enemy) or Vector2(enemy.pos).distance_to(effect.pos)>effect.radius+enemy.radius: continue
			var multiplier:=2.0 if effect.kind=="strike" and Vector2(enemy.pos).distance_to(effect.pos)<=effect.radius*0.4 else 1.0
			run.hit_enemy(enemy,effect.damage*multiplier,effect.kind)
			if ReviewRules.enabled(run) and effect.kind=="strike": ReviewRules.strike_status(run,enemy,multiplier>1)
			if effect.rank>=10 and not enemy.has("role") and (not ReviewRules.enabled(run) or effect.kind!="strike"): enemy.stun=0.75
		if effect.kind=="reactor" and effect.rank>=5 and run.player.distance_to(effect.pos)<=effect.radius: shield=maxf(shield,1.5)
		if effect.kind=="reactor" and effect.rank>=10 and not effect.get("second",false):
			var second: Dictionary=effect.duplicate(); second.life=0.4; second.duration=0.4; second.second=true; second.damage*=0.25; impacts.append(second)
		run.emit_event("nuke_impact",effect.pos,{"radius":effect.radius})
		var duration: float=0.65 if effect.kind=="reactor" else 0.4
		impacts.append({"kind":"detonation" if effect.kind=="reactor" else "blast","pos":effect.pos,"radius":effect.radius,"life":duration,"duration":duration,"rank":effect.rank,"source":effect.kind})

func blast(run, point: Vector2, radius: float, damage: float, source: String, stun: float, knock: float) -> void:
	for enemy in run.enemies:
		if not run.attacks.valid(enemy) or Vector2(enemy.pos).distance_to(point)>radius+enemy.radius: continue
		var ordinary: bool=not enemy.has("role") and enemy.kind!=2
		run.hit_enemy(enemy,damage,source,(Vector2(enemy.pos)-point).normalized()*knock if ordinary else Vector2.ZERO)
		if ordinary and stun>0: enemy.stun=stun
	impacts.append({"kind":"slam_hit" if source=="body_slam" else "blast","pos":point,"radius":radius,"direction":slam_direction,"life":0.4,"duration":0.4,"rank":run.kit.effective_rank("e") if source=="body_slam" else 1,"source":source})
	if source in ["bulwark","reserve","phase_hop"]: impacts.back().rank=run.kit.effective_rank({"bulwark":"x1","reserve":"x2","phase_hop":"f"}[source])

func step_slam(run, delta: float) -> void:
	var budget:=delta
	# Four-unit sweeps avoid tunnelling through capsule walls at low frame rates.
	while budget>0.000001 and slam_left>0.000001:
		var speed: float=REBOUND_SPEED if slam_bounced else SLAM_SPEED
		var dt:=minf(budget,minf(slam_left,4.0/speed))
		var before: Vector2=run.player
		var desired: Vector2=before+slam_direction*dt*speed
		var blocked:=not valid_point(run,desired,16)
		var used:=dt
		if blocked:
			var low:=0.0; var high:=1.0
			for i in range(12):
				var middle: float=(low+high)*0.5
				if valid_point(run,before.lerp(desired,middle),16): low=middle
				else: high=middle
			run.player=before.lerp(desired,low); used=dt*low
		else: run.player=desired
		slam_left=maxf(0,slam_left-used); budget=maxf(0,budget-used)
		for enemy in run.enemies:
			if not run.attacks.valid(enemy): continue
			if Geometry2D.get_closest_point_to_segment(enemy.pos,before,run.player).distance_to(enemy.pos)<=enemy.radius+24:
				slam_left=0
				blast(run,run.player,95*run.kit.area_scale("e"),32*run.kit.damage_scale("e"),"body_slam",0.6 if run.kit.effective_rank("e")>=5 else 0,240)
				if run.kit.effective_rank("e")>=10 and not ArsenalBurst.enabled(run): shield=1.0
				run.emit_event("v_impact",run.player); return
		if blocked:
			var normal:=Vector2.ZERO
			var nearest:=INF
			for wall in run.kit.extra.walls:
				var point: Vector2=Geometry2D.get_closest_point_to_segment(run.player,wall.a,wall.b)
				var distance: float=run.player.distance_to(point)-16-float(wall.get("width",6))
				if distance<nearest and distance<0.1:
					nearest=distance; normal=(run.player-point).normalized()
			if ArsenalBurst.enabled(run) and normal.is_zero_approx():
				var bounds: Rect2=run.ARENA.grow(-16)
				if desired.x<=bounds.position.x: normal.x=1
				elif desired.x>=bounds.end.x: normal.x=-1
				if desired.y<=bounds.position.y: normal.y=1
				elif desired.y>=bounds.end.y: normal.y=-1
				normal=normal.normalized()
			# One rebound per cast, including arena edges on current runs.
			if slam_bounced or normal.is_zero_approx() or slam_direction.dot(normal)>=0:
				slam_left=0; return
			var remaining_distance:=slam_left*SLAM_SPEED
			slam_direction=slam_direction.bounce(normal).normalized()
			slam_bounced=true; slam_left=remaining_distance*2.0/REBOUND_SPEED
			poof(run.player,run.kit.effective_rank("e"))
			run.emit_event("v_impact",run.player)
	if slam_left<0.000001: slam_left=0

static func valid_point(run, point: Vector2, radius: float) -> bool:
	if not run.ARENA.grow(-radius).has_point(point): return false
	for wall in run.kit.extra.walls:
		if Geometry2D.get_closest_point_to_segment(point,wall.a,wall.b).distance_to(point)<radius+float(wall.get("width",6)): return false
	return true

static func blink_target(run, requested: Vector2) -> Vector2:
	if valid_point(run,requested,16): return requested
	var start: Vector2=run.player
	var direction: Vector2=(requested-start).normalized()
	if direction==Vector2.ZERO: return start
	# Find only the connected obstruction containing the requested endpoint.
	var near_point:=requested; var far_point:=requested
	for i in range(450):
		near_point-=direction*2
		if valid_point(run,near_point,16): break
	for i in range(450):
		far_point+=direction*2
		if valid_point(run,far_point,16): break
	var pick: Vector2=far_point if requested.distance_to(far_point)<requested.distance_to(near_point) else near_point
	return pick if valid_point(run,pick,16) and pick.distance_to(requested)<=900 else start
