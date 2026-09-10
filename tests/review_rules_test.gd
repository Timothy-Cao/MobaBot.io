extends SceneTree
var checks:=0
var failures:=0
var rendered:=false

class Shop extends RefCounted:
	var model: SalvageRun
	var collection=ForgeEquipment.new()
	func persistent_run() -> bool: return false

class FailedCollection extends ForgeEquipment:
	func save() -> bool: return false

class FailedShop extends Shop:
	func persistent_run() -> bool: return true

func check(ok: bool, label: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(label)

func fresh(rank_value: int=0) -> SalvageRun:
	var run:=SalvageRun.new(17017); run.loot_rng.seed=17918
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
	BotExpedition.new().start(run,"ranged",0); BotKeyboard.enable(run); run.exp.enable_revision(run)
	Vanguard.setup(run,rank_value); ReviewRules.enable(run); run.kit.extra.walls.clear()
	return run

func _initialize() -> void: execute.call_deferred()

func execute() -> void:
	rendered="--render" in OS.get_cmdline_user_args()
	var run:=fresh()
	for slot in ReviewRules.MODULES: check(Vanguard.rank_of(run,slot)==0,"Modules start unowned")
	run.exp.pending_chests=71; Vanguard.progression(run)
	check(run.kit.loadout.rewards18.is_empty() and run.exp.reward_receipt.points==0,"Chests cannot bypass level progression")
	check(run.exp.field_credits==1420 and run.exp.reward_receipt.credits==1420,"Chest credit receipts exact")
	run.total_xp=run.next_level; Vanguard.progression(run); ReviewRules.offer(run)
	check(run.state=="upgrade" and run.kit.loadout.rewards18.size()==3,"One level yields three paused picks")
	check(run.offers.size()==3 and run.offers.all(func(s): return s in ReviewRules.CORE),"Only core tools offered")
	var before:=run.time; run.step(1,Vector2.RIGHT); check(run.time==before,"Upgrade freezes combat")
	for i in range(3): check(run.choose_upgrade(0),"Successive valid pick")
	check(run.state=="running" and run.kit.loadout.rewards18.is_empty(),"Third pick resumes combat")
	run.kit.ranks.q=5
	check("q" in ReviewRules.candidates(run),"Specialize without all-rank-five gate")
	check(not Vanguard.spend(run,"q"),"Cannot spend outside modal offer")
	# Same-slot tiers remain strictly monotonic; no profile reads/writes.
	var collection:=ForgeEquipment.new()
	for slot in ForgeEquipment.SLOTS:
		var previous: Dictionary={}
		for id in ForgeEquipment.ITEMS:
			if ForgeEquipment.ITEMS[id].slot!=slot: continue
			var current:=collection.values(id)
			for stat in previous: check(current[stat]>previous[stat],"Higher equipment tier improves same-slot stat")
			previous=current
	var shop:=Shop.new(); shop.model=fresh(); shop.model.state="camp"; shop.model.exp.field_credits=1000
	check(ReviewRules.buy_module(shop,"p1"),"Buy orbit after round one")
	check(Vanguard.rank_of(shop.model,"p1")==1 and shop.model.exp.field_credits==900,"Module price/ownership exact")
	check(ReviewRules.buy_module(shop,"p1") and shop.model.exp.field_credits==735,"Credit-only module upgrade")
	check(shop.collection.valid_checkpoint(shop.collection.checkpoint),"Revised checkpoint validates")
	var resumed:=fresh(); check(shop.collection.resume_into(resumed),"Revised checkpoint resumes")
	check(ReviewRules.enabled(resumed) and Vanguard.rank_of(resumed,"p1")==2,"Resume preserves bought module")
	check(Vanguard.rank_of(fresh(),"p1")==0,"New run resets module ownership")
	var failed:=FailedShop.new(); failed.model=fresh(); failed.model.state="camp"; failed.model.exp.field_credits=1000; failed.collection=FailedCollection.new()
	var old:=failed.model.kit.loadout.duplicate(true)
	check(not ReviewRules.buy_module(failed,"x1"),"Failed disk write reported")
	check(failed.model.exp.field_credits==1000 and Vanguard.rank_of(failed.model,"x1")==0 and failed.model.kit.loadout==old,"Failed module transaction rolls back")
	run=fresh(1)
	check(run.kit.charges.f==1,"F starts at one charge")
	run.kit.ranks.f=5; run.kit.recharge.f=0; run.kit.step(run,0.01)
	check(run.kit.charges.f==2,"F rank five adds second charge")
	check(is_equal_approx(100.0/(ReviewRules.drive_cost(run)-8),5.0),"Early D five-second net-drain reference")
	run.kit.ranks.d=10; check(is_equal_approx(8.0/ReviewRules.drive_cost(run),0.8),"Max D base duty cycle")
	run=fresh(5); run.vanguard.cast(run,"x1",run.player+Vector2(100,0)); run.vanguard.ghost=true
	ReviewRules.suppress(run)
	check(not run.vanguard.ghost and not run.kit.passive_active("orbit") and not run.vanguard.powered(run),"EMP suppresses ongoing powers")
	for slot in ReviewRules.MODULES+["d","f"]:
		var energy: float=run.kit.energy; var charges: Dictionary=run.kit.charges.duplicate()
		check(not run.vanguard.cast(run,slot,run.player+Vector2(100,0)),"EMP blocks affected cast")
		check(run.kit.energy==energy and run.kit.charges==charges,"EMP rejection spends nothing")
	check(run.vanguard.gun_on and not Vanguard.gun_paused(run),"EMP preserves gun")
	check(run.vanguard.cast(run,"q",run.player+Vector2(100,0)),"EMP preserves Q")
	run.vanguard.pending.clear(); check(run.vanguard.swing(run,run.player+Vector2(100,0)),"EMP preserves hammer")
	ReviewRules.tick(run,3.1); check(run.kit.emp_left==0 and run.kit.passive_active("orbit"),"EMP expires and orbit recovers")
	run=fresh(1); run.spawn_enemy(run.player+Vector2(100,0),0)
	var e: Dictionary=run.enemies.back(); e.hp=1000; e.max_hp=1000; e.warmup=0
	ReviewRules.strike_status(run,e,true)
	check(e.stun==1.1 and e.vulnerable==1.0,"W center sets stun and vulnerability")
	var hp: float=e.hp; run.hit_enemy(e,10,"probe"); check(is_equal_approx(hp-e.hp,15),"Vulnerability amplifies follow-up")
	ReviewRules.tick(run,1.1); hp=e.hp; run.hit_enemy(e,10,"probe"); check(is_equal_approx(hp-e.hp,10),"Vulnerability expires")
	e.role="foreman"; e.phase="approach"; e.stun=0
	ReviewRules.strike_status(run,e,true); e.stun=0; ReviewRules.strike_status(run,e,true)
	check(e.stun==0,"Boss resists consecutive W stuns")
	run.vanguard.combo_left=1.2; check(run.vanguard.swing(run,e.pos),"E follow-up arms a hammer swing")
	check(run.vanguard.combo_swing and run.vanguard.combo_left==0 and ReviewRules.hammer_multiplier(run,e)==3,"One boss combo multiplier consumed")
	# Enemy behavior and truthful durations; no random human hit-rate inference.
	for kind in ["lancer","volley","emp"]:
		run=fresh(); e=RangedThreats.spawn(run,kind,run.player+Vector2(250,0),true); run.exp.scale_enemy(run,e)
		check(e.hp>ReviewRules.reference_w(0),"Tank ranged survives reference center W")
	run=fresh(); e=RangedThreats.spawn(run,"emp",run.player+Vector2(250,0),true); e.clock=0
	ReviewEnemies.emp(run,e,0); check(e.phase=="emp_aim","EMP gives warning")
	ReviewEnemies.emp(run,e,1.11); ReviewEnemies.emp(run,e,0.4)
	check(run.vanguard.emp_left==3,"Caught in expanding EMP gets three-second suppression")
	run=fresh(); DemoCampaign.spawn_special(run,"foreman"); e=run.enemies.back(); e.exp_boss=1; e.hp=25000; e.max_hp=25000
	ReviewEnemies.boss(run,e,0); check(e.hp==25000 and e.radius==48,"Boss retains HP and smaller matching body")
	for attack in ["fan","shells","sweep","charge","ring","melee"]:
		e.attack=attack; e.phase="telegraph"; e.clock=0; e.dir=Vector2.RIGHT
		ReviewEnemies.boss(run,e,0.01)
		for i in range(90): ReviewEnemies.boss(run,e,1.0/30)
		check(run.projectiles.size()<=run.MAX_PROJECTILES,"Boss projectile budget")
	ReviewRules.terrain(run)
	check(run.kit.extra.walls.all(func(w): return w.width>=65),"Thick Practice-style campaign terrain")
	followup_checks()
	await ui_checks()
	print("REVIEW RULES: %d checks, %d failures"%[checks,failures]); quit(0 if failures==0 else 1)

func followup_checks() -> void:
	var run:=fresh(4)
	var collection:=ForgeEquipment.new()
	var snapshot:=collection.pack_run(run)
	for slot in ReviewRules.CORE:
		var label:=UpgradePreview.text(run,slot)
		check(label.contains("→") and label.split("\n").size()<=5,"Compact numerical preview: "+slot)
	check(collection.pack_run(run)==snapshot,"Preview does not mutate simulation or RNG")
	var preview:=UpgradePreview.stats(run,"w",5)
	run.kit.ranks.w=5; run.vanguard.pending={"slot":"w","target":run.player}; run.vanguard.release(run)
	check(is_equal_approx(preview["Center damage"],run.vanguard.impacts.back().damage*2),"Card matches actual W damage")
	check(UpgradePreview.text(run,"f").contains("Charges  1 → 2"),"F card exposes charge milestone")
	run.kit.rank_bonus=1; run.kit.ranks.f=9
	check(UpgradePreview.text(run,"f").contains("Equipment already"),"Effective-rank cap never promises false gains")
	run=fresh()
	check(run.mastery.nodes().size()==13 and run.mastery.can_buy("b0_0",1),"Unified mastery has 13 nodes and one starting point")
	for id in run.mastery.nodes():
		if id!="b0_0": check(not run.mastery.can_buy(id,25),"Branches require root")
	check(run.mastery.buy(run,"b0_0"),"Buy shared root")
	run.level=5
	for id in ["b0_1","b2_0","b3_0"]: check(run.mastery.can_buy(id,5),"Three branches unlock after root")
	check(run.mastery.buy(run,"b3_0") and run.mastery.buy(run,"b3_2"),"Utility path buys energy regeneration")
	check(run.mastery.value("regen")==0.6,"Unified mastery feeds actual resource stats")
	collection.checkpoint=collection.pack_run(run)
	check(ForgeEquipment.valid_checkpoint(collection.checkpoint),"Unified checkpoint validates")
	var restored:=fresh()
	check(collection.resume_into(restored) and restored.mastery.unified and restored.mastery.value("regen")==0.6,"Unified mastery resumes with same effects")
	var corrupt:=collection.checkpoint.duplicate(true); corrupt.tree.erase("b0_0"); corrupt.spent-=1
	check(not ForgeEquipment.valid_checkpoint(corrupt),"Disconnected mastery save rejected")
	check(collection.values("dynamo_helmet").regen>0 and collection.values("dynamo_chest").health_regen>0,"Middle-tier equipment offers regeneration")
	check("emp" not in ReviewRules.specialist_roster(1) and "emp" in ReviewRules.specialist_roster(3),"EMP introduced in stage two")
	run=fresh(); run.exp.route_index=2; run.boss_spawned=true; run.stage_time=run.exp.round_seconds()+ReviewRules.BOSS_ENRAGE_SECONDS
	var incoming: float=run.exp.incoming(run,1)
	check(ReviewRules.boss_overtime(run)==0,"Full five-minute boss window")
	run.stage_time+=30
	check(is_equal_approx(run.exp.incoming(run,1),incoming*4),"Overload damage ramps after deadline")
	DemoCampaign.spawn_special(run,"foreman"); var boss: Dictionary=run.enemies.back(); boss.exp_boss=1
	ReviewEnemies.boss(run,boss,0)
	check(boss.overload and run.state=="running" and run.projectiles.size()>0,"Overload adds physical threats without forced loss")
	run.exp.practice=true; check(ReviewRules.boss_overtime(run)==0,"Practice excluded from timed overload")
	run=fresh(); run.time=1000; run.damage_dealt={"hammer":10000.0}
	RunDiagnostics.sample_progression(run); run.time+=15; run.damage_dealt.hammer+=150
	RunDiagnostics.sample_progression(run)
	check(run.exp.progression_samples.size()==1 and run.exp.progression_samples[0].credited_damage_per_second==10,"Sample uses interval delta, not resumed aggregate")
	check(run.exp.progression_samples[0].ranks.q==1,"Sample records contemporaneous ranks")

func capture(game, name: String) -> void:
	await process_frame; await process_frame
	if not rendered: return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://output/review19")
	game.get_viewport().get_texture().get_image().save_png("res://output/review19/"+name+".png")

func ui_checks() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate()
	game.persist_settings=false; game.mute_setting=true
	root.add_child(game); await process_frame; game.set_physics_process(false)
	game.collection=ForgeEquipment.new(); game.launch_expedition()
	check(ReviewRules.enabled(game.model),"Actual new-expedition entry opts into review rules")
	game.model.total_xp=game.model.next_level; game._physics_process(1.0/60)
	check(game.screen=="upgrade" and game.model.state=="upgrade","Controller opens paused level-up screen")
	for i in range(3): game.ui.upgrade_selected.emit(0)
	check(game.screen=="running" and game.model.state=="running","Controller resumes only after three choices")
	game.collection=ForgeEquipment.new(); game.model=fresh(); game.art.model=game.model
	game.model.state="camp"; game.screen="camp"; game.model.exp.field_credits=750
	game.model.exp.reward_receipt={"chests":20,"points":0,"credits":480,"items":{"courier_helmet":1,"bastion_helmet":1,"courier_ring":1,"courier_boots":1,"courier_cape":1}}
	for tab in ["Round clear","Build","Mastery","Equipment"]:
		game.review_tab=tab; ReviewView.camp(game)
		if tab=="Round clear": game.ui.overlay.get_node("RoundReceipt").finish_reveal()
		await capture(game,tab.replace(" ","-"))
		check(game.ui.overlay.get_children().filter(func(n): return n is Button and n.text in ["Round clear","Build","Mastery","Equipment"]).size()==4,"Four peer camp tabs")
		if tab=="Round clear":
			var receipt: LootReceipt=game.ui.overlay.get_node("RoundReceipt")
			var scroll: ScrollContainer=receipt.get_child(1)
			check(scroll.get_v_scroll_bar().max_value<=scroll.size.y,"Six reward entries fit without scrolling")
	game.close_gear(); check(game.review_tab=="Round clear" and game.screen=="camp","Equipment Back returns to round clear")
	game.model.state="running"; game.model.exp.clear_clock=-1; Vanguard.earn(game.model); ReviewRules.offer(game.model)
	game.ui.show_upgrades(game.model); await capture(game,"upgrade")
	check(game.ui.overlay.get_children().filter(func(n): return n.has_meta("review_choice")).size()==3,"Three upgrade cards")
	game.model=fresh(5); game.art.model=game.model; game.model.exp.practice=true
	game.art.world_mode=true; game.camera.enabled=true; game.zoom_value=0.8
	game.model.player=Vector2(1400,1000); game.free_center=game.model.player; game.screen="running"; game.ui.show_running(); game.ui.update_hud(game.model); game._update_camera()
	DemoCampaign.spawn_special(game.model,"foreman"); var boss: Dictionary=game.model.enemies.back(); boss.exp_boss=1; boss.pos=game.model.player+Vector2(260,0)
	ReviewEnemies.boss(game.model,boss,0); boss.attack="sweep"; boss.phase="telegraph"; boss.dir=Vector2.LEFT; boss.clock=0.5
	var emp:=RangedThreats.spawn(game.model,"emp",game.model.player+Vector2(-200,-100),true); emp.phase="emp_aim"; emp.emp_target=game.model.player+Vector2(0,-70); emp.clock=0.7
	ReviewRules.terrain(game.model); game.art.visible=true
	for reduced in [false,true]:
		game.art.reduced_effects=reduced; game.ui.reduced=reduced
		# Late disappearing polygons at large world coordinates reproduce original risk.
		for progress in [0.0,0.5,0.99,0.99999]:
			game.art.effects.assign([{"kind":"rocket_impact","pos":game.model.player,"radius":100.0,"age":progress*0.6,"life":0.6}])
			game.art.queue_redraw(); await capture(game,"combat-"+str(reduced)+"-"+str(progress))
	game.queue_free(); await process_frame
