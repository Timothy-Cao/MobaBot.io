extends SceneTree
var checks := 0
var failures := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1; push_error(message)

func fresh(class_id: String="ranged", difficulty: int=0) -> SalvageRun:
	var run:=SalvageRun.new(6127)
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo()
	run.attacks.enabled=true; run.kit.starting_gun=true; run.kit.onboarding=true
	BotExpedition.new().start(run,class_id,difficulty)
	return run

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	check(BotExpedition.ROUTE.size()==22,"22 authored rounds")
	check(ExpeditionTree.TREE.size()==48,"48 mastery nodes")
	check(ExpeditionGear.ITEMS.size()==40,"40 equipment items")
	for class_id in BotExpedition.CLASSES:
		var run:=fresh(class_id)
		check(run.kit.unlocked("q") and run.kit.unlocked("p1") and not run.kit.unlocked("w"),"Starter gates")
		check(run.health>=100,"High resolution hull")
		run.exp.pending_chests=1; run.exp.make_chest(run); run.state="chest"
		var slot: String=run.exp.chest_choices[0].slot
		check(run.exp.choose_chest(run,0),"Chest choice")
		check(run.kit.unlocked(slot),"Useful early discovery")
		check(run.exp.pending_chests==0 and run.level==1,"Chest no recursive XP")
		run.health=run.max_health()-1
		run.exp.finish_step(run,0.1)
		check(run.health>run.max_health()-1,"Fractional recovery")
		for id in ExpeditionTree.TREE:
			run.level=100
			while run.mastery.can_buy(id,run.level): check(run.mastery.buy(run,id),"Tree purchase "+id)
		check(run.kit.extra.capacity<=4 and run.kit.cooldown_bonus<=0.6,"Stat caps")
		run.state="camp"
		check(run.mastery.refund(run) and run.mastery.spent==0,"Safe respec")
	for id in BotSkillCatalog.SPECS:
		var run:=fresh()
		var category: String=MobaKit.ABILITIES[id].category
		var slot: String={"active":"q","ultimate":"r","mobility":"f","speed":"d","summon":"t"}[category]
		run.exp.install(run,slot,id)
		run.kit.energy=1000
		run.spawn_enemy(run.player+Vector2(100,0),0)
		var enemy: Dictionary=run.enemies.back()
		enemy.warmup=0; enemy.hp=40; enemy.max_hp=100
		var target: Vector2=enemy.pos
		if id=="vault":
			run.kit.extra.walls=[{"uid":99,"a":run.player+Vector2(50,-90),"b":run.player+Vector2(50,90),"life":5.0}]
		if id=="recall": run.kit.extra.plates.append(run.player+Vector2(200,0))
		check(run.kit.cast(run,slot,target),"Cast "+id)
		if id in ["crosswire","echo_dash","artillery","roller"]: check(run.kit.cast(run,slot,target+Vector2(0,100)),"Recast "+id)
		for i in range(240):
			run.kit.extra.cursor=run.player+Vector2(200,0)
			run.kit.step(run,1.0/60)
			if run.kit.dash_left>0: run.kit.move_dash(run,1.0/60)
		check(is_finite(run.health) and is_finite(run.player.x),"Finite simulation "+id)
		check(run.kit.extra.summons.size()<=run.kit.extra.capacity,"Summon bound "+id)
	var gear:=ExpeditionGear.new()
	check(gear.valid(gear.snapshot()),"Fresh gear schema")
	var run:=fresh()
	gear.apply_to(run)
	run.state="camp"; run.exp.pending_chests=2; run.exp.carry_credits=75
	check(gear.bank_camp(run,false),"Bank in memory")
	check(gear.valid(gear.snapshot()),"Checkpoint schema")
	var credits:=gear.credits
	check(gear.bank_camp(run,false) and gear.credits==credits,"No double banking")
	var restored:=fresh()
	check(gear.resume_into(restored),"Resume checkpoint")
	check(restored.exp.pending_chests==2 and restored.state=="camp","Restore pending choices")
	mechanics()
	checkpoint_checks()
	chest_checks()
	for i in range(22):
		var encounter:=fresh("ranged",5)
		encounter.exp.route_index=i; encounter.exp.enter(encounter)
		encounter.stage_time=encounter.exp.round_seconds()
		encounter.exp.spawns(encounter,0.1)
		check(encounter.boss_spawned==(BotExpedition.ROUTE[i][1] in ["boss","final"]),"Boss ownership "+str(i))
		for enemy in encounter.enemies: encounter.hit_enemy(enemy,99999,"test")
		for j in range(100): encounter.exp.finish_step(encounter,0.02)
		check(encounter.state in ["camp","chest","upgrade"],"Round resolves "+str(i))
	print("EXPEDITION TESTS: %d checks; %d failures" % [checks,failures])
	quit(1 if failures else 0)

func enemy_at(run, offset: Vector2) -> Dictionary:
	run.spawn_enemy(run.player+offset,0)
	var enemy: Dictionary=run.enemies.back()
	enemy.warmup=0; enemy.hp=1000.0; enemy.max_hp=1000.0
	return enemy

func mechanics() -> void:
	var run:=fresh()
	var target:=enemy_at(run,Vector2(100,0))
	var outside:=enemy_at(run,Vector2(100,100))
	run.kit.extra.blade(run.player,run.player+Vector2(200,0),22,false,1)
	for i in range(50): run.kit.extra.step(run,0.02)
	check(is_equal_approx(target.hp,956),"Return blade exactly one hit per leg")
	check(outside.hp==1000,"Return blade does not hit outside its width")
	run.kit.extra.field(target.pos,110,0.6,32,"strike")
	run.kit.extra.step(run,0.61)
	check(target.hp==892 and outside.hp==968,"Strike center vs outer damage")
	run=fresh(); target=enemy_at(run,Vector2(50,0)); outside=enemy_at(run,Vector2(130,0))
	run.health=50
	run.kit.extra.cast(run,"q","reap",run.player,Vector2.RIGHT,1)
	check(target.hp==984 and outside.hp==964,"Rim cutter inner/outer damage")
	check(is_equal_approx(run.health,55),"Only rim hit heals")
	for i in range(5): enemy_at(run,Vector2.from_angle(i*0.6)*140)
	run.health=50
	run.kit.extra.cast(run,"q","reap",run.player,Vector2.RIGHT,1)
	check(is_equal_approx(run.health,65),"Rim heal capped at 15 percent")
	run=fresh(); target=enemy_at(run,Vector2(100,0))
	run.exp.install(run,"q","consume"); var energy:=run.kit.energy
	check(not run.kit.cast(run,"q",target.pos) and run.kit.energy==energy and run.kit.charges.q==1,"Invalid crusher costs no charge or energy")
	target.hp=400; target.elite=true
	check(not run.kit.cast(run,"q",target.pos),"Crusher rejects elites")
	target.elite=false
	run.kit.extra.walls=[{"uid":99,"a":run.player+Vector2(50,-90),"b":run.player+Vector2(50,90),"life":5.0}]
	check(not run.kit.cast(run,"q",target.pos),"Crusher rejects through-wall target")
	var start: Vector2=run.player
	check(run.kit.extra.solid_point(start,start+Vector2(100,0),12)==start,"Wall blocks movement crossing")
	check(run.kit.extra.route(start,start+Vector2(100,0),12)!=start+Vector2(100,0),"Wall generates end detour")
	run.exp.install(run,"w","echo_dash")
	check(run.kit.cast(run,"w",start+Vector2(100,0)),"Echo cast against barrier")
	check(run.kit.extra.fields.back().pos==start,"Echo impact stays on reachable side")
	run.kit.dash_left=0; run.exp.install(run,"f","vault")
	check(run.kit.cast(run,"f",start+Vector2(100,0)),"Vault crosses eligible wall")
	for i in range(12): run.kit.move_dash(run,0.02)
	check(run.player.x>start.x+50,"Vault reaches other side")
	check(not run.kit.extra.vault_wall(run,start).size(),"Vault per-wall reuse lock")
	run=fresh(); target=enemy_at(run,Vector2(100,0))
	run.kit.loadout.passives[1]="threehit"; run.kit.discovered.append("p2"); run.kit.toggles[1]=true
	for i in range(3): run.kit.extra.commanded_hit(run,target)
	check(target.hp==988,"Third contact procs exactly once")
	run.kit.extra.commanded_hit(run,target); run.kit.extra.step(run,6.01)
	check(run.kit.extra.hits.is_empty(),"Third contact counters expire")
	run.kit.loadout.passives[1]="converter"; run.kit.energy=0; run.health=31; run.kit.extra.converter_mode=1
	run.kit.extra.step(run,10)
	check(is_equal_approx(run.health,30) and is_equal_approx(run.kit.energy,5),"Converter reverse respects 30 percent floor")
	run.kit.extra.converter_mode=0; run.kit.energy=10; run.health=99
	run.kit.extra.step(run,1)
	check(is_equal_approx(run.health,100) and is_equal_approx(run.kit.energy,5),"Converter never spends past full hull")
	run=fresh(); run.kit.extra.capacity=2
	for i in range(5): run.kit.extra.cast(run,"t","mirror_sentry",run.player+Vector2(i*40,0),Vector2.RIGHT,1)
	check(run.kit.extra.summons.size()==2 and run.kit.extra.summons.front().uid==4,"Summon capacity replaces oldest")
	run.kit.extra.mirror(run,"returner",Vector2.RIGHT,1)
	check(run.kit.extra.blades.size()==2 and is_equal_approx(run.kit.extra.blades.front().damage,9.9),"Mirror uses 45 percent base hit")
	run.kit.extra.mirror(run,"returner",Vector2.RIGHT,1)
	check(run.kit.extra.blades.size()==2,"Mirror cooldown blocks recursive volume")
	run.kit.ranks.t=5; run.kit.extra.cast(run,"t","mirror_sentry",run.player,Vector2.RIGHT,1)
	check(run.kit.extra.summons.back().life==25,"Summon milestone increases lifetime")
	run.kit.ranks.q=5; run.kit.extra.cast(run,"q","repair_channel",run.player,Vector2.RIGHT,1)
	check(is_equal_approx(run.kit.extra.repair_rate,0.1),"Repair milestone has actual effect")

func checkpoint_checks() -> void:
	var run:=fresh(); var gear:=ExpeditionGear.new()
	run.state="camp"; run.upgrades.reactor=5; run.upgrades.cell=5; run._sync_resource_ranks()
	run.exp.install(run,"f","tumble"); run.kit.gun_sniper=true; run.kit.orbit_far=true
	run.kit.toggles[0]=false; run.consumables=[0,1]
	run.exp.shop_stock.assign(["","dynamo_cape","relay_ring"])
	gear.bank_camp(run,false)
	var restored:=fresh()
	check(gear.resume_into(restored),"Extended checkpoint resumes")
	check(restored.kit.rank_regen==run.kit.rank_regen and restored.kit.rank_energy==run.kit.rank_energy,"Resume preserves resource ranks")
	check(restored.kit.charges.f==3 and restored.kit.recharge.f==0,"Resume initializes replacement charges")
	check(restored.kit.gun_sniper and restored.kit.orbit_far and not restored.kit.toggles[0],"Resume preserves toggle modes")
	check(restored.consumables==run.consumables and restored.exp.shop_stock==run.exp.shop_stock,"Resume preserves consumables and sold stock")
	check(restored.loot_rng.randi()==run.loot_rng.randi(),"Resume restores exact RNG state")
	for key in ["consumables","rng","shop","toggles","sniper"]:
		var broken:=gear.checkpoint.duplicate(true); broken.erase(key)
		check(not gear.valid_checkpoint(broken),"Reject missing checkpoint "+key)
	var corrupt:=gear.checkpoint.duplicate(true); corrupt.tree={"unknown":1}
	check(not gear.valid_checkpoint(corrupt),"Reject unknown mastery node")
	var before:=gear.snapshot()
	gear.path="res://output/expedition-intentionally-missing-directory/profile.json"
	check(not gear.transact("reroll","courier_helmet"),"Failed save rejects transaction")
	check(gear.snapshot()==before,"Failed save rolls back complete profile")
	DirAccess.make_dir_recursive_absolute("res://output")
	gear.path="res://output/expedition-test-profile-%d.json" % Time.get_ticks_usec()
	check(gear.save(),"Atomic profile writes to isolated test path")
	var disk:=ExpeditionGear.new(); disk.path=gear.path; disk.load_profile()
	check(not disk.blocked and disk.valid(disk.snapshot()),"On-disk JSON profile validates")
	check(disk.resume_into(restored) and restored.kit.gun_sniper,"On-disk checkpoint round trip")
	check(disk.checkpoint.rng==gear.checkpoint.rng,"64-bit RNG string survives JSON")
	check(DirAccess.remove_absolute(gear.path)==OK,"Remove isolated test profile")

func chest_checks() -> void:
	var run:=fresh()
	run.kit.discovered.assign(MobaKit.BIND_SLOTS)
	run.kit.loadout.passives=["bolt","orbit","ricochet","lightning"]
	for i in range(100):
		run.exp.pending_chests=1; run.state="running"; run.exp.make_chest(run); run.state="chest"
		var seen: Array=[]
		for choice in run.exp.chest_choices:
			check(choice.slot not in seen,"Chest choices use distinct slots")
			seen.append(choice.slot)
		check(run.exp.choose_chest(run,i%3),"Chest choice commits")
		check(MobaKit.valid_loadout(run.kit.loadout),"Discovery preserves unique slots and passive dependencies")
	run=fresh(); run.kit.ranks.q=4; run.upgrades.skill_q=4
	run.state="chest"; run.exp.pending_chests=1; run.exp.chest_choices.assign([{"slot":"q","id":"rocket","tier":1}])
	check(run.exp.choose_chest(run,0) and run.kit.ranks.q==6 and run.kit.tiers.q==1,"Duplicate grants two ranks and rarity")
	run.kit.ranks.q=9; run.upgrades.skill_q=9
	run.state="chest"; run.exp.pending_chests=1; run.exp.chest_choices.assign([{"slot":"q","id":"rocket","tier":0}])
	check(run.exp.choose_chest(run,0) and run.kit.ranks.q==10 and run.exp.field_credits==20 and run.kit.tiers.q==1,"Overflow pays currency and never downgrades rarity")
