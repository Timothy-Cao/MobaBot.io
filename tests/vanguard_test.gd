extends SceneTree
var failures:=0
var checks:=0
func check(value: bool, message: String) -> void:
	checks+=1
	if not value: failures+=1; push_error(message)
func fresh(rank_value: int=1) -> SalvageRun:
	var run:=SalvageRun.new(17017)
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
	BotExpedition.new().start(run,"ranged",0); BotKeyboard.enable(run); run.exp.enable_revision(run)
	Vanguard.setup(run,rank_value); run.kit.extra.walls.clear(); run.exp.practice=true; run.exp.god_mode=false; run.exp.free_energy=false
	return run
func _initialize() -> void: execute.call_deferred()
func execute() -> void:
	var run:=fresh(0)
	check(run.kit.discovered==["q","d","f"],"Starter fixed kit")
	check(run.passive_enabled("bolt") and BotKeyboard.learned(run.kit,"bolt")=="","Permanent gun consumes no slot")
	run.exp.practice=false; run.total_xp=run.next_level
	Vanguard.progression(run)
	check(run.state=="running" and run.level==2 and Vanguard.reward_kind(run)=="upgrade","XP non-modal")
	check("w" in Vanguard.candidates(run,Vanguard.reward_kind(run)),"Same point can learn or upgrade")
	check(Vanguard.spend(run,"q") and run.kit.ranks.q==2,"Spend owned rank")
	Vanguard.earn(run)
	check(Vanguard.reward_kind(run)=="upgrade" and Vanguard.spend(run,"w"),"Universal point learns W")
	var gear:=ForgeEquipment.new()
	run.state="camp"
	var packed:=gear.pack_run(run)
	check(ForgeEquipment.valid_checkpoint(packed),"New checkpoint validates")
	gear.checkpoint=packed
	var restored:=fresh()
	check(gear.resume_into(restored) and Vanguard.enabled(restored) and restored.kit.ranks.w==1,"Fixed kit roundtrip")
	var bad:=packed.duplicate(true); bad.loadout.rewards18=["cheat"]
	check(not ForgeEquipment.valid_checkpoint(bad),"Malformed queue rejected")
	bad=packed.duplicate(true); bad.bindings=1
	check(not ForgeEquipment.valid_checkpoint(bad),"Malformed fixed bindings rejected without exceptions")
	run=fresh(5)
	run.spawn_enemy(run.player+Vector2(120,0),3); run.enemies[0].warmup=0; run.enemies[0].hp=10000; run.enemies[0].max_hp=10000
	run.vanguard.cast(run,"d",run.player)
	check(run.vanguard.ghost and not run.vanguard.cast(run,"q",run.player+Vector2(100,0)),"D prevents active casts")
	run.attacks.stop(run); run.attacks.fire(run)
	check(run.attacks.auto_shots==1,"D/S never stop gun")
	run.vanguard.ghost=false
	run.projectiles.clear()
	var before: Vector2=run.player
	check(run.vanguard.cast(run,"q",before+Vector2(400,0)),"Queue Q")
	check(run.vanguard.cast(run,"f",before+Vector2(100,100)),"Blink in cast buffer")
	run.vanguard.tick(run,0.081)
	check(run.projectiles.size()==1 and run.projectiles[0].pos==run.player and run.player!=before,"Q release from blink endpoint")
	check(run.kit.cast_counts.rocket==1 and run.kit.cast_counts.blink==1,"Costs and counts once")
	run=fresh()
	var p: Vector2=run.player
	run.kit.extra.walls.append({"uid":-1,"a":p+Vector2(200,-150),"b":p+Vector2(200,150),"width":170.0,"life":9999.0,"terrain":true})
	var far:=Vanguard.blink_target(run,p+Vector2(220,0))
	var near:=Vanguard.blink_target(run,p+Vector2(180,0))
	check(far.x>p.x+385 and Vanguard.valid_point(run,far,16),"Past-half thick blink exits far side")
	check(near.x<p.x+15 and Vanguard.valid_point(run,near,16),"Near half stays near side")
	run=fresh(5); run.vanguard.touch_guard=1
	var hp: float=run.health
	run.hurt_player(run.player,"touch",1,"touch")
	check(run.health==hp,"Slam contact guard")
	run.hurt_player(run.player,"projectile",1,"projectile")
	check(run.health<hp,"Projectile bypasses contact guard")
	run.vanguard.shield=1; hp=run.health; run.hurt_player(run.player,"ground",1,"ground")
	check(run.health==hp,"Full shield blocks ground")
	run=fresh(5)
	run.spawn_enemy(run.player+Vector2(95,0),3); run.enemies[0].warmup=0; run.enemies[0].hp=1000
	check(run.vanguard.swing(run,run.player+Vector2(95,0)),"Hammer starts")
	run.vanguard.tick(run,0.21)
	check(run.damage_dealt.get("hammer",0)>30,"Hammer head payoff")
	run=fresh(5)
	run.spawn_enemy(run.player+Vector2(95,0),3); run.enemies[0].warmup=0; run.enemies[0].hp=1000
	check(run.vanguard.cast(run,"e",run.player+Vector2(200,0)),"Slam begins")
	for i in range(15): run.vanguard.tick(run,1.0/60)
	check(run.damage_dealt.get("body_slam",0)>0 and run.vanguard.slam_left==0,"Slam first contact impact")
	for dt in [1.0/120,1.0/60,1.0/30,0.1,0.5]:
		run=fresh(1); run.player=Vector2(1200,1000)
		var origin: Vector2=run.player
		run.kit.extra.walls=[{"a":origin+Vector2(80,-400),"b":origin+Vector2(80,400),"width":20,"life":100}]
		run.vanguard.cast(run,"e",origin+Vector2(400,0))
		for i in range(ceili(0.6/dt)): run.vanguard.tick(run,dt)
		check(run.vanguard.slam_bounced and run.vanguard.slam_left==0,"Wall produces one completed rebound")
		check(absf(run.player.x-(origin.x+44-2*(209-44)))<0.1,"Rebound travels twice remaining distance across frame rates")
		check(Vanguard.valid_point(run,run.player,16),"Rebound remains outside collision")
		check(run.kit.charges.e==1 and run.damage_dealt.get("body_slam",0)==0,"Wall bounce consumes no extra charge and deals no phantom damage")
		run.vanguard.clear(); check(not run.vanguard.slam_bounced,"Reset clears rebound state")
	run=fresh(1); run.player=Vector2(1200,1000)
	var bounce_origin: Vector2=run.player
	run.kit.extra.walls=[{"a":Vector2(1280,600),"b":Vector2(1280,1400),"width":20,"life":100},{"a":Vector2(1000,600),"b":Vector2(1000,1400),"width":20,"life":100}]
	run.vanguard.cast(run,"e",run.player+Vector2(400,0)); run.vanguard.tick(run,0.6)
	check(absf(run.player.x-1036)<0.1 and run.vanguard.slam_left==0,"Second wall stops rebound without tunnelling or chaining")
	run.kit.extra.walls.pop_back(); run.player=bounce_origin
	run.kit.charges.e=2; run.vanguard.cast(run,"e",run.player+Vector2(400,200)); run.vanguard.tick(run,0.6)
	check(run.vanguard.slam_direction.x<0 and run.vanguard.slam_direction.y>0,"Angled wall contact reflects with forward tangent retained")
	check(Vanguard.valid_point(run,run.player,16),"Angled rebound lands outside wall")
	run=fresh(1); run.player=Vector2(1200,1000)
	run.kit.extra.walls=[{"a":Vector2(1436,600),"b":Vector2(1436,1400),"width":20,"life":100}]
	run.vanguard.cast(run,"e",run.player+Vector2(400,0)); run.vanguard.tick(run,0.6)
	check(absf(run.player.x-1382)<0.1,"Late wall contact has only a short rebound")
	run=fresh(5); run.player=Vector2(1200,1000)
	run.kit.extra.walls=[{"a":Vector2(1280,600),"b":Vector2(1280,1400),"width":20,"life":100}]
	run.spawn_enemy(Vector2(1050,1000),3); run.enemies[0].hp=1000; run.enemies[0].warmup=0
	run.vanguard.cast(run,"e",run.player+Vector2(400,0)); run.vanguard.tick(run,0.6)
	check(run.vanguard.slam_bounced and run.vanguard.slam_left==0 and run.damage_dealt.get("body_slam",0)>0,"Rebound retains normal first-enemy impact")
	run=fresh(1); run.player=Vector2(run.ARENA.end.x-25,1000)
	run.vanguard.cast(run,"e",run.player+Vector2(400,0)); run.vanguard.tick(run,0.6)
	check(not run.vanguard.slam_bounced and run.vanguard.slam_left==0 and Vanguard.valid_point(run,run.player,16),"Arena edge stops dash safely")
	run=fresh(5)
	check(run.vanguard.cast(run,"x3",run.player),"Recovery deployment")
	check(run.vanguard.powered(run),"Inside recovery aura")
	run.vanguard.tick(run,4)
	check(run.kit.charges.x3==0 and run.kit.recharge.x3==run.kit.cooldown("x3"),"Totem cooldown waits for expiry")
	run.player+=Vector2(400,0)
	check(not run.vanguard.powered(run),"Aura benefit stays local")
	for rank_value in [1,5,10]:
		for slot in ["q","w","e","r","x1","x2","x3"]:
			run=fresh(rank_value); run.exp.free_energy=true
			run.spawn_enemy(run.player+Vector2(160,0),3); run.enemies[0].warmup=0; run.enemies[0].hp=10000; run.enemies[0].max_hp=10000; run.enemies[0]["dummy"]=true
			check(run.vanguard.cast(run,slot,run.enemies[0].pos),"Cast %s rank %d"%[slot,rank_value])
			for tick in range(120): run.step(1.0/60,Vector2.ZERO); run.events.clear()
			check(is_finite(run.health) and run.vanguard.impacts.size()<30,"Bounded complete simulation")
			if slot in ["q","w","e","r"]: check(run.damage_dealt.size()>1,"Skill damage lands")
	run=fresh(5); run.exp.practice=false; run.exp.god_mode=false
	run.spawn_enemy(run.player+Vector2(60,0),0); run.enemies[0].warmup=0
	run.hit_enemy(run.enemies[0],100,"test")
	check(not run.pickups.is_empty(),"Campaign still awards loot")
	run=fresh(5); run.spawn_enemy(run.player+Vector2(60,0),0); run.enemies[0].warmup=0
	run.hit_enemy(run.enemies[0],100,"test")
	check(run.pickups.is_empty() and run.supply_drops.is_empty() and run.total_xp==0,"Practice kills award nothing")
	run=fresh(5); run.exp.practice=false; run.exp.encounter_spawned=true; run.stage_time=180
	run.exp.finish_step(run,0.1)
	check(run.exp.clear_clock>11,"Vanguard keeps collection window")
	run.exp.finish_step(run,12)
	check(run.state=="camp" and run.exp.pending_chests==0 and run.kit.loadout.rewards18.size()>0,"Camp rewards queued without popup")
	check(ForgeEquipment.valid_checkpoint(gear.pack_run(run)),"End-round save validates")
	playtest_refinements()
	rank_milestones()
	new_milestones()
	stage_and_gear()
	machine_gun_milestones()
	await ui_checks()
	print("VANGUARD: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)

func machine_gun_milestones() -> void:
	for rank_value in [1,4,5,9,10]:
		for movement in ["ghost","slam","dash"]:
			var run:=fresh(rank_value)
			run.spawn_enemy(run.player+Vector2(90,0),3); run.enemies[0].warmup=0
			if movement=="ghost": run.vanguard.ghost=true
			elif movement=="slam": run.vanguard.slam_left=0.2
			else: run.kit.dash_left=0.2
			run.attacks.stop(run); run.attacks.fire(run)
			check((run.attacks.auto_shots==1)==(rank_value>=5),"MG rank-five movement gate "+movement)
			run.vanguard.ghost=false; run.vanguard.slam_left=0; run.kit.dash_left=0
			run.attacks.auto_cooldown=0; run.attacks.fire(run)
			check(run.attacks.auto_shots>0,"MG resumes automatically after dash")
	var run:=fresh(10)
	run.spawn_enemy(run.player+Vector2(100,0),3); run.enemies[0].warmup=0
	for shot in range(1,11):
		run.attacks.auto_cooldown=0; run.attacks.fire(run)
		var bullet: Dictionary=run.projectiles.back()
		check(bullet.gun_special==(shot%5==0),"Exactly every fifth successful shot is empowered")
		check(bullet.pierce==(3 if shot%5==0 else 0),"Only empowered MG shots pierce")
		check(is_equal_approx(bullet.damage,run.attacks.auto_damage(run)*(2 if shot%5==0 else 1)),"Empowered damage budget")
	run.vanguard.gun_shots=4; run.projectiles.clear(); run.attacks.auto_cooldown=0
	run.enemies[0].pos=run.player+Vector2(400,0)
	run.attacks.fire(run)
	check(run.projectiles.size()==1 and run.projectiles[0].gun_special,"Fifth shot acquires targets beyond ordinary range")
	check(is_equal_approx(run.projectiles[0].life*Vector2(run.projectiles[0].vel).length()+20,450),"Empowered range is finite and exact")
	run.enemies.clear(); run.projectiles.clear()
	for distance in [70,130,190,250,310]:
		run.spawn_enemy(run.player+Vector2(distance,0),3)
		run.enemies.back().warmup=0; run.enemies.back().hp=10000; run.enemies.back().max_hp=10000
	Vanguard.gun_bullet(run,run.player,Vector2.RIGHT,10,450,4,"bolt")
	run._projectile_step(0.5)
	check(run.enemies.filter(func(e): return e.hp<10000).size()==4,"Piercing shot hits four enemies then stops")
	check(run.enemies[0].hp==9980,"Piercing hit applies double damage once")
	run.projectiles.clear(); run.vanguard.gun_shots=4; run.vanguard.gun_on=false; run.attacks.auto_cooldown=0
	run.attacks.fire(run); check(run.vanguard.gun_shots==4,"Toggle off preserves fifth-shot counter")
	run.vanguard.gun_on=true
	for i in range(run.MAX_PROJECTILES): run._add_projectile(run.player,Vector2.RIGHT,0,"bolt",0)
	run.attacks.fire(run); check(run.vanguard.gun_shots==4,"Full projectile pool cannot consume fifth shot")
	var previous_damage:=0.0; var previous_interval:=1.0
	for rank_value in range(1,11):
		run=fresh(rank_value)
		check(run.attacks.auto_damage(run)>previous_damage and run.attacks.auto_interval(run)<previous_interval,"MG grows damage and speed every rank")
		previous_damage=run.attacks.auto_damage(run); previous_interval=run.attacks.auto_interval(run)
	run=fresh(1); run.upgrades.power=9
	run.vanguard.cast(run,"x1",run.player+Vector2(40,0))
	var turret: Dictionary=run.vanguard.constructs[0]
	run.spawn_enemy(turret.pos+Vector2(100,0),3); run.enemies[0].warmup=0
	for shot in range(1,6):
		turret.clock=0; run.vanguard.tick(run,0.001)
		check(run.projectiles.back().gun_special==(shot==5),"Rank-one turret inherits rank-ten MG milestone")
	check(turret.shots==5 and run.vanguard.gun_shots==0,"Turret has independent firing counter")
	check(is_equal_approx(run.projectiles.back().damage,3.4*Vanguard.GUN_POWER[10]*2),"Turret inherits MG damage")
	check(is_equal_approx(turret.clock,0.5),"Turret inherits MG cadence")

func stage_and_gear() -> void:
	var names: Array=[]
	for id in ForgeEquipment.ITEMS:
		var item: Dictionary=ForgeEquipment.ITEMS[id]
		check(item.name not in names,"Equipment names unique")
		names.append(item.name)
		check(item.name.begins_with(ForgeEquipment.TIER_NAMES[item.tier-1]),"Name carries tier identity")
	check(ForgeEquipment.TIER_COLORS.size()==5,"Five rarity glow colors")
	for number in range(1,9):
		var run:=fresh(1); run.exp.practice=false
		for index in range(BotExpedition.ROUTE.size()):
			if BotExpedition.ROUTE[index][0]==number: run.exp.route_index=index; break
		run._spawn_pack(3,true); RangedThreats.spawn(run,"lancer")
		var health: Array=[]
		for enemy in run.enemies: health.append(enemy.hp)
		run._enemy_step(0)
		for i in range(run.enemies.size()):
			check(is_equal_approx(run.enemies[i].hp,health[i]*BotExpedition.stage_health(number)),"Surge and ranged enemies share stage health")
		var scaled: float=run.enemies[0].hp
		run._enemy_step(0)
		check(run.enemies[0].hp==scaled,"Stage scaling applied exactly once")
		check(is_equal_approx(run.exp.incoming(run,1),20*BotExpedition.stage_damage(number)*100/(100+run.exp.resistance)),"Stage damage curve applies before resistance")
	var run:=fresh(1); run.exp.practice=false; run.exp.route_index=2; run.stage_time=180
	run.exp.encounter_spawned=false; run.exp.spawns(run,0)
	var boss: Dictionary=run.enemies.back()
	check(boss.get("exp_boss",0)==1 and boss.hp==25000,"Stage-one main boss has 50x health")
	run._enemy_step(0); check(boss.hp==25000,"Boss does not double-scale")
	check(is_equal_approx(run.exp.incoming(run,1),25*100/(100+run.exp.resistance)),"Boss encounter damage increases 25 percent")
	run=fresh(1); run.exp.practice=false; run.exp.route_index=0; run.stage_time=180
	run.exp.encounter_spawned=false; run.exp.spawns(run,0); run._enemy_step(0)
	check(run.enemies.back().hp==130,"Stage-one guardian health preserved")

func new_milestones() -> void:
	for rank_value in [1,5,10]:
		var run:=fresh(rank_value)
		var origin: Vector2=run.player
		check(run.vanguard.cast(run,"e",origin+Vector2(600,0)),"Milestone E starts")
		run.vanguard.tick(run,1.0)
		check(is_equal_approx(run.player.distance_to(origin),Vanguard.slam_range(rank_value)),"E range matches preview at each milestone")
		for slot in ["q","w","e","r","f","p1","x1","x2","x3"]:
			run=fresh(rank_value); run.vanguard.cast(run,"d",run.player)
			check(run.vanguard.cast(run,slot,run.player+Vector2(100,0))==(rank_value>=10),"D unlocks all casts only at ten")
		run=fresh(rank_value)
		run.spawn_enemy(run.player+Vector2(100,0),3); run.enemies[0].hp=10000; run.enemies[0].warmup=0
		run.vanguard.cast(run,"f",run.player+Vector2(100,0))
		check((run.damage_dealt.get("phase_hop",0)>0)==(rank_value>=10),"Flash landing damage only at ten")
		run=fresh(rank_value); run.vanguard.cast(run,"x3",run.player)
		check(run.vanguard.constructs[0].duration==5+run.kit.milestone("x3")*2,"Well duration milestone")
		run.kit.recharge.q=4; run.vanguard.tick(run,0.1)
		check(is_equal_approx(run.kit.recharge.q,3.8 if rank_value>=10 else 3.9),"Well adds correct recharge including charge refill")
		run=fresh(rank_value); run.vanguard.cast(run,"x2",run.player); run.health=1
		run.vanguard.tick(run,0.1)
		check((run.health>1)==(rank_value>=10),"Reserve banks while inside only at ten")
		run=fresh(rank_value); run.vanguard.cast(run,"x1",run.player); run.vanguard.constructs[0].pulse=0
		run.spawn_enemy(run.player+Vector2(70,0),3); run.enemies[0].warmup=0; run.enemies[0].hp=10000
		run.vanguard.tick(run,0.01)
		check(is_equal_approx(run.vanguard.constructs[0].pulse,1.8 if rank_value>=5 else 2.4),"Bulwark faster pulses at five")
		check((run.enemies[0].get("stun",0)>0)==(rank_value>=10),"Bulwark pulse stun at ten")
	var low:=fresh(1); var high:=fresh(5)
	check(high.kit.cooldown("f")<low.kit.cooldown("f")*0.7 and high.kit.ability_cost("blink")<=low.kit.ability_cost("blink")*0.6,"Flash rank five efficiency spike")
	check(Vanguard.drive_upkeep(5)<Vanguard.drive_upkeep(1)*0.6,"D rank five upkeep spike")
	var run:=fresh(4); run.vanguard.cast(run,"x3",run.player)
	run.kit.ranks.x3=5; run.vanguard.tick(run,0.01)
	check(run.vanguard.constructs[0].radius==145 and run.vanguard.constructs[0].duration==7,"Live tower upgrade updates geometry and duration")
	run=fresh(0); run.kit.loadout.rewards18=["learn","upgrade"]
	check(Vanguard.spend(run,"q") and Vanguard.spend(run,"w"),"Legacy queued kinds both spend anywhere")
	run=fresh(5); run.kit.ranks.w=4; Vanguard.earn(run)
	check(not Vanguard.spend(run,"q") and run.kit.loadout.rewards18.size()==1,"Gate preserves rejected point")
	check(Vanguard.spend(run,"w"),"Last tool reaches five")
	Vanguard.earn(run); check(Vanguard.spend(run,"q"),"All-five unlocks sixth rank")
	run=fresh(1); run.exp.stats.xp=0
	for i in range(360): run._drop(Vector2(3000+(i%12)*96,3000+(i%3)),1)
	var before: Array=run.pickups.duplicate(true)
	var started:=Time.get_ticks_usec(); run.pickup_merge_clock=1000
	for i in range(200): run._pickup_step(1.0/60)
	var unmerged_us:=Time.get_ticks_usec()-started
	run.pickups.assign(before); run.compact_pickups()
	check(run.pickups.size()==12,"360 local drops become twelve bundles")
	var total:=0
	for pickup in run.pickups: total+=pickup.value
	check(total==360,"Compaction preserves all reward value")
	started=Time.get_ticks_usec()
	for i in range(200): run._pickup_step(1.0/60)
	var merged_us:=Time.get_ticks_usec()-started
	print("PICKUP_BENCH 200 ticks: 360 drops=%dus; 12 bundles=%dus (CPU only)"%[unmerged_us,merged_us])
	for pickup in run.pickups: run.collect_pickup(pickup)
	check(run.total_xp==120 and run.collected==360,"One-third XP, full collection value")
	run=fresh(1); run._drop(Vector2(3000,3000),2); run._drop(Vector2(3001,3000),3)
	run.pickups[0].settle=0.2; run.compact_pickups()
	check(run.pickups.size()==2,"Fresh shower remains separate")
	run.pickups[0].settle=0; run.pickups[0].pull=true; run.compact_pickups()
	check(run.pickups.size()==2,"Flying pickup remains separate")

func rank_milestones() -> void:
	var run:=fresh(1)
	check("hammer" in Vanguard.candidates(run,"upgrade"),"Hammer participates in upgrade queue")
	for rank_value in range(2,11):
		if rank_value==6:
			run.kit.loadout.rewards18=["upgrade"]
			check(not Vanguard.spend(run,"hammer"),"Rank six blocked while other tools below five")
			Vanguard.setup(run,5)
		run.kit.loadout.rewards18=["upgrade"]
		check(Vanguard.spend(run,"hammer") and Vanguard.hammer_rank(run)==rank_value,"Hammer earned rank %d"%rank_value)
	check("hammer" not in Vanguard.candidates(run,"upgrade"),"Hammer cap is ten")
	var gear:=ForgeEquipment.new()
	run.state="camp"
	var packed:=gear.pack_run(run)
	check(ForgeEquipment.valid_checkpoint(packed),"Rank ten hammer checkpoint valid")
	gear.checkpoint=packed
	var restored:=fresh()
	check(gear.resume_into(restored) and Vanguard.hammer_rank(restored)==10,"Hammer checkpoint roundtrip")
	packed.loadout.erase("hammer_rank")
	check(ForgeEquipment.valid_checkpoint(packed),"Old checkpoint without hammer rank remains valid")
	gear.checkpoint=packed
	check(gear.resume_into(restored) and Vanguard.hammer_rank(restored)==1,"Old checkpoint defaults hammer rank one")
	packed.loadout.hammer_rank=11
	check(not ForgeEquipment.valid_checkpoint(packed),"Out of range hammer rejected")
	for rank_value in [1,5,10]:
		run=fresh(rank_value)
		run.vanguard.gun_on=false
		var origin: Vector2=run.player
		run.command_move(origin+Vector2(400,0))
		check(run.vanguard.swing(run,origin+Vector2(100,0)),"Hammer accepts moving swing")
		for i in range(8): run.step(0.025,Vector2.ZERO)
		check((run.player.distance_to(origin)>5)==(rank_value==10),"Only rank ten moves during windup")
		check(is_equal_approx(run.attacks.damage(run),38*Vanguard.power(rank_value)),"Hammer damage curve")
		check(is_equal_approx(run.kit.damage_scale("q"),1.2*Vanguard.power(rank_value)),"Q damage curve")
		run=fresh(rank_value); run.vanguard.gun_on=false
		run.spawn_enemy(run.player+Vector2.from_angle(deg_to_rad(54))*110,3)
		run.enemies[0].warmup=0; run.enemies[0].hp=10000
		run.vanguard.swing(run,run.player+Vector2(200,0)); run.vanguard.tick(run,0.21)
		check((run.enemies[0].hp<10000)==(rank_value>=5),"Rank five wider collision sweep")
		check(is_equal_approx(run.vanguard.impacts.back().angle,Vanguard.hammer_angle(run)),"Rendered hammer angle follows collision")
	for rank_value in range(2,11): check(Vanguard.power(rank_value)>Vanguard.power(rank_value-1),"Strictly growing rank power")
	run=fresh(10); run.vanguard.gun_on=false
	var start: Vector2=run.player
	run.spawn_enemy(start+Vector2(100,0),3); run.enemies[0].warmup=0; run.enemies[0].hp=10000
	run.attacks.attack_move(run,start+Vector2(400,0))
	for i in range(10): run.step(0.025,Vector2.ZERO)
	check(run.player.distance_to(start)>10,"Rank ten attack-move keeps walking through a nearby attack")
	var baseline:=fresh(1)
	for rank_value in [1,5,10]:
		run=fresh(rank_value)
		var hammer_dps: float=run.attacks.damage(run)/run.attacks.interval(run)
		var gun_dps: float=run.attacks.auto_damage(run)/run.attacks.auto_interval(run)
		var active_ratio: float=(run.kit.damage_scale("q")/run.kit.cooldown("q"))/(baseline.kit.damage_scale("q")/baseline.kit.cooldown("q"))
		check(active_ratio>=1 and active_ratio<=4.5,"Sustained active curve stays inside budget")
		print("VANGUARD_POWER rank=%d hammer_dps=%.2f gun_dps=%.2f active_ratio=%.2f radius_ratio=%.2f"%[rank_value,hammer_dps,gun_dps,active_ratio,run.kit.area_scale("q")])
	run=fresh(10); run.vanguard.cast(run,"r",run.player)
	run.vanguard.tick(run,0.081)
	var first: float=run.vanguard.impacts[0].damage
	run.vanguard.tick(run,0.8)
	var echo: Dictionary=run.vanguard.impacts.filter(func(e): return e.get("second",false))[0]
	check(is_equal_approx(first+echo.damage,135*run.kit.damage_scale("r")),"R echo shares milestone damage budget")

func playtest_refinements() -> void:
	var run:=fresh(1)
	run.exp.fast_cooldowns=false
	check(run.kit.charges.q==2 and run.kit.charges.w==2 and run.kit.charges.e==2,"Q/W/E start with two charges")
	run.kit.charges.e=0; run.kit.recharge.e=run.kit.cooldown("e")
	run.kit.step(run,run.kit.cooldown("e")+0.01)
	check(run.kit.charges.e==1,"E refills one charge at a time")
	run.kit.step(run,run.kit.cooldown("e"))
	check(run.kit.charges.e==2,"E caps at two charges")
	run.kit.charges.e=0; run.exp.fast_cooldowns=true; run.exp.finish_step(run,0.01)
	check(run.kit.charges.e==2,"Practice instant recharge restores both E charges")
	run.exp.fast_cooldowns=false
	check(is_equal_approx(run.kit.cooldown("q"),4.0),"Rank-one Q recharges in four seconds")
	run.kit.charges.q=0; run.kit.recharge.q=4
	run.kit.step(run,3.9); check(run.kit.charges.q==0,"Q charge cannot refill early")
	run.kit.step(run,0.11); check(run.kit.charges.q==1,"Q refills one charge at a time")
	run.kit.step(run,4); check(run.kit.charges.q==2 and run.kit.recharge.q==0,"Q caps at two")
	run.vanguard.gun_on=false; run.spawn_enemy(run.player+Vector2(90,0),3)
	run.enemies.back().warmup=0
	run.attacks.auto_cooldown=0; run.attacks.fire(run)
	check(run.attacks.auto_shots==0,"Gun toggle actually suppresses automatic fire")
	run.vanguard.gun_on=true; run.attacks.stop(run); run.attacks.fire(run)
	check(run.attacks.auto_shots==1,"S leaves reenabled gun firing")
	run.kit.extra.walls=[{"uid":-50,"a":Vector2(700,200),"b":Vector2(700,400),"width":65.0,"life":9999.0,"terrain":true}]
	for cursor in [Vector2(700,300),Vector2(710,300),Vector2(700,195)]:
		run.player=Vector2(480,300); run.enemies.clear(); run.command_move(cursor)
		var target: Vector2=run.move_target
		check(Geometry2D.get_closest_point_to_segment(target,Vector2(700,200),Vector2(700,400)).distance_to(target)>=82.9,"Wall click projects outside body clearance")
		for i in range(1200): run.step(1.0/60,Vector2.ZERO); run.events.clear()
		check(run.player.distance_to(target)<1 and not run.moving,"Projected wall destination reached without oscillation")
	run.player=Vector2(480,300); run.attacks.attack_move(run,Vector2(700,300))
	check(run.attacks.destination==Vector2(617,300) and run.attacks.cursor_point==Vector2(700,300),"Attack-move projects walking while preserving target acquisition point")
	run=fresh(1); run.vanguard.gun_on=false
	run.kit.extra.walls=[{"uid":-99,"a":Vector2(600,200),"b":Vector2(600,400),"width":65.0,"life":9999.0,"terrain":true}]
	run.spawn_enemy(Vector2(750,300),3); var target: Dictionary=run.enemies.back(); target.warmup=0; target["dummy"]=true
	run._add_projectile(run.player,Vector2(600,0),10,"bolt",0)
	for i in range(40): run._projectile_step(1.0/60)
	check(run.damage_dealt.get("bolt",0)==10,"Friendly projectile hits through thick wall")
	check(run.attacks.line_of_fire(run,target.pos),"Attack acquisition ignores shot cover")
	check(RangedThreats.beam_end(run,run.player,Vector2.RIGHT)==run.player+Vector2(740,0),"Enemy laser geometry ignores wall")
	run._add_projectile(Vector2(750,300),Vector2(-600,0),1,"hostile",0)
	var health_before: float=run.health
	for i in range(40): run._projectile_step(1.0/60)
	check(run.health<health_before,"Hostile projectile also passes through wall")
	check(run.kit.extra.solid_point(Vector2(510,300),Vector2(620,300),16).x<535,"Bodies still collide with wall")
	run=fresh(5)
	run.vanguard.tick(run,0.1)
	check(is_equal_approx(run.vanguard.orbit_angle,1.02),"Close orbit spins three times faster")
	var angle: float=run.vanguard.orbit_angle
	run.vanguard.cast(run,"p1",run.player); run.vanguard.tick(run,0.1)
	check(is_equal_approx(run.vanguard.orbit_angle-angle,1.02),"Far orbit uses the same fast speed and continuous angle")
	var keys: Dictionary=BotKeyboard.SYSTEM_DEFAULTS.duplicate()
	keys.lock=-8; check(BotKeyboard.valid_system(keys),"Mouse side camera binding valid")
	keys.lock=KEY_G; check(BotKeyboard.valid_system(keys),"Unused camera key valid")
	keys.lock=KEY_Q; check(not BotKeyboard.valid_system(keys),"Camera cannot steal a skill key")
	keys.lock=KEY_QUOTELEFT; check(not BotKeyboard.valid_system(keys),"Gun toggle key protected")

func ui_checks() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate()
	game.persist_settings=false; game.mute_setting=true
	root.add_child(game); await process_frame; game.set_physics_process(false)
	var before:=JSON.stringify(game.collection.snapshot())
	game.launch_practice(); await process_frame
	check(game.screen=="practice" and Vanguard.enabled(game.model),"Practice fixed-kit default")
	game.close_practice()
	game.ui.system_keys=BotKeyboard.SYSTEM_DEFAULTS.duplicate()
	game._notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(game.screen=="paused","Alt-Tab pauses active combat")
	game._notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	check(game.screen=="paused","Returning focus does not resume automatically")
	var escape:=InputEventKey.new(); escape.keycode=KEY_ESCAPE; escape.pressed=true
	game._unhandled_key_input(escape)
	check(game.screen=="running","Esc resumes the focus-loss pause directly")
	game._unhandled_key_input(escape)
	check(game.screen=="settings","Esc during combat still opens settings")
	game._unhandled_key_input(escape)
	check(game.screen=="running","Esc closes settings back to combat")
	game.open_practice()
	check(game.practice_enemy=="dummy" and game.practice_count==1 and game.practice_formation=="Cluster","Single clustered dummy is default")
	game.practice_page="Enemies"; PracticeSandbox.draw(game); await process_frame
	game.practice_enemy="bumper"; game.practice_count=10; game.practice_formation="Cluster"
	var point: Vector2=game.model.player+Vector2(600,0)
	check(PracticeSandbox.place(game,point) and game.model.enemies.size()==10,"World cluster placement")
	check(not PracticeSandbox.place(game,point),"Reject overlapping batch atomically")
	game.practice_clear(); check(game.model.enemies.is_empty() and game.model.vanguard.constructs.is_empty(),"Clear simulation")
	check(JSON.stringify(game.collection.snapshot())==before,"Practice collection unchanged")
	Vanguard.setup(game.model,5); game.close_practice()
	Vanguard.earn(game.model); game.ui.update_hud(game.model)
	await process_frame; await process_frame
	var hud_slots:=0
	var upgrade_buttons:=0
	for child in game.ui.ability_bar.get_children():
		if child.has_meta("vanguard_slot"):
			hud_slots+=1
			var slot: String=child.get_meta("vanguard_slot")
			check(child.get_rect()==VanguardHud.slot_rect(slot),"HUD slot uses authored layout")
			check(child.size.x in [48.0,54.0],"Icons use consistent size with modest QWER emphasis")
		if child.has_meta("vanguard_upgrade"):
			upgrade_buttons+=1
			var slot: String=child.get_meta("vanguard_upgrade")
			var rect:=VanguardHud.slot_rect(slot)
			check(is_equal_approx(child.size.x,rect.size.x) and child.size.y<=18,"Upgrade bar is full width and flat after layout")
			check(child.position.x==rect.position.x and child.position.y+child.size.y<rect.position.y,"Upgrade bar clears icon and key label")
		if child is Button: check(child.text not in ["5","6"],"No consumable HUD buttons")
	check(hud_slots==12 and upgrade_buttons==12,"All twelve abilities have consistent upgrade affordances")
	for slot in VanguardHud.SLOT_X:
		for other in VanguardHud.SLOT_X:
			if slot!=other: check(not VanguardHud.slot_rect(slot).intersects(VanguardHud.slot_rect(other)),"Ability icons do not overlap")
	var hammer_button=game.ui.ability_bar.get_children().filter(func(c): return c.get_meta("vanguard_upgrade","")=="hammer")[0]
	hammer_button.pressed.emit()
	check(Vanguard.hammer_rank(game.model)==6,"Wide upgrade button still spends the intended rank")
	Vanguard.earn(game.model); game.ui.update_hud(game.model)
	var gun_key:=InputEventKey.new(); gun_key.keycode=KEY_QUOTELEFT; gun_key.pressed=true
	game._input(gun_key); check(not game.model.vanguard.gun_on,"Backtick toggles gun off")
	game._input(gun_key); check(game.model.vanguard.gun_on,"Backtick toggles gun back on")
	game.ui.system_keys.lock=-8
	var mouse:=InputEventMouseButton.new(); mouse.button_index=MOUSE_BUTTON_XBUTTON1; mouse.pressed=true
	var camera_before: bool=game.camera_locked
	game._input(mouse); check(game.camera_locked!=camera_before,"Mouse camera lock input works")
	var old_key:=InputEventKey.new(); old_key.keycode=KEY_L; old_key.pressed=true
	game._input(old_key); check(game.camera_locked!=camera_before,"Old camera key disabled after rebind")
	game.ui.system_keys.lock=KEY_L
	var event:=InputEventKey.new(); event.keycode=KEY_D; event.pressed=true
	game._input(event); check(game.model.vanguard.ghost,"D key down starts drive")
	event.pressed=false; game._input(event); check(not game.model.vanguard.ghost,"D key up stops drive")
	event.keycode=KEY_Q; event.pressed=true; event.ctrl_pressed=true
	game._input(event); check(game.model.kit.ranks.q==6 and game.model.vanguard.pending.is_empty(),"Ctrl-Q upgrades without casting")
	if "--render" in OS.get_cmdline_user_args():
		DirAccess.make_dir_recursive_absolute("res://output/vanguard")
		var saved_model=game.model
		for reduced in [false,true]:
			game.model=fresh(5); game.model.player=Vector2(1200,1000)
			game.model.kit.extra.walls.assign([{"a":Vector2(1280,800),"b":Vector2(1280,1200),"width":20,"life":100,"terrain":true}])
			game.art.model=game.model; game.art.effects.clear(); game.art.reduced_effects=reduced
			game.camera_offset=Vector2.ZERO; game.camera_locked=true; game._update_camera()
			game.model.vanguard.cast(game.model,"e",Vector2(1500,1000))
			game.model.vanguard.tick(game.model,0.08)
			game.ui.update_hud(game.model); game.art.queue_redraw()
			await process_frame; await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://output/vanguard/wall-rebound-%s.png"%str(reduced))
		game.model=saved_model; game.art.model=game.model; game.art.reduced_effects=false
		game._update_camera(); game.ui.update_hud(game.model)
		await process_frame; await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/vanguard/hud.png")
		game.model.spawn_enemy(game.model.player+Vector2(190,0),3)
		var dummy: Dictionary=game.model.enemies.back(); dummy["dummy"]=true
		game.model.hit_enemy(dummy,38,"q"); game.model.practice_meter.tick(1); game.model.hit_enemy(dummy,76,"w")
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/vanguard/dummy.png")
		game.art.reduced_effects=true
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/vanguard/dummy-reduced.png")
		game.art.reduced_effects=false
		game.model.enemies.clear(); game.model.practice_meter.clear()
		game.open_practice(); game.practice_page="Enemies"; PracticeSandbox.draw(game)
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/vanguard/practice.png")
		game.close_practice(); game.model.kit.extra.walls.clear()
		for reduced in [false,true]:
			game.art.reduced_effects=reduced; game.art.effects.clear()
			game.model.enemies.clear(); game.model.projectiles.clear(); game.model.orbit.clear()
			Vanguard.setup(game.model,10); game.model.player=Vector2(480,300)
			game.model.vanguard.gun_shots=4
			Vanguard.gun_bullet(game.model,game.model.player+Vector2(90,0),Vector2.RIGHT,game.model.attacks.auto_damage(game.model),450,4,"bolt")
			Vanguard.gun_bullet(game.model,game.model.player+Vector2(90,45),Vector2.RIGHT,game.model.attacks.auto_damage(game.model),265,0,"bolt")
			game._update_camera(); game.ui.update_hud(game.model)
			await process_frame; await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://output/vanguard/gun-%s.png"%("reduced" if reduced else "normal"))
		for rank_value in [1,5,10]:
			for reduced in [false,true]:
				game.art.reduced_effects=reduced; game.art.effects.clear()
				game.model.enemies.clear(); game.model.projectiles.clear(); game.model.orbit.clear()
				Vanguard.setup(game.model,rank_value); game.model.vanguard.gun_on=false
				game.model.player=Vector2(480,300)
				game.model.vanguard.swing(game.model,game.model.player+Vector2(200,0))
				game.model.vanguard.tick(game.model,0.21); game.model.vanguard.tick(game.model,0.055)
				game._update_camera(); game.ui.update_hud(game.model)
				await process_frame; await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("res://output/vanguard/hammer-%d-%s.png"%[rank_value,"reduced" if reduced else "normal"])
		for reduced in [false,true]:
			for phase in ["slam-travel","slam-impact","reactor-impact"]:
				game.art.reduced_effects=reduced; game.model.enemies.clear(); game.art.effects.clear()
				game.model.player=Vector2(480,300); Vanguard.setup(game.model,5); game.model.kit.energy=100
				game.model.spawn_enemy(game.model.player+Vector2(130,0),3)
				game.model.enemies.back()["dummy"]=true; game.model.enemies.back().warmup=0
				game.model.vanguard.cast(game.model,"r" if phase=="reactor-impact" else "e",game.model.player+Vector2(130,0))
				if phase=="slam-travel": game.model.vanguard.tick(game.model,0.03)
				elif phase=="slam-impact": game.model.vanguard.tick(game.model,0.10)
				else: game.model.vanguard.tick(game.model,0.09); game.model.vanguard.tick(game.model,0.7)
				game.model.vanguard.tick(game.model,0.08 if phase!="slam-travel" else 0)
				game._update_camera(); game.ui.update_hud(game.model)
				await process_frame; await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("res://output/vanguard/%s-%s.png"%[phase,"reduced" if reduced else "normal"])
		for reduced in [false,true]:
			game.art.reduced_effects=reduced
			for slot in ["q","w","e","r","x1","x2","x3"]:
				game.model.projectiles.clear(); game.model.orbit.clear(); game.art.effects.clear(); game.model.player=Vector2(480,300); game._update_camera()
				Vanguard.setup(game.model,10); game.model.kit.energy=100; game.model.vanguard.cast(game.model,slot,game.model.player+Vector2(160,0))
				game.model.vanguard.tick(game.model,0.12)
				game.ui.update_hud(game.model)
				await process_frame; await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("res://output/vanguard/%s-%s.png"%[slot,"reduced" if reduced else "normal"])
	game.queue_free(); await process_frame
