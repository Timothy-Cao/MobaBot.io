extends SceneTree
var checks:=0
var failures:=0
class FailedForge extends ForgeEquipment:
	func save() -> bool: return false
func check(ok: bool, label: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(label)
func fresh(level: int=1) -> SalvageRun:
	var run:=SalvageRun.new(7127); run.loot_rng.seed=8028
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
	BotExpedition.new().start(run,"ranged",4); run.exp.enable_revision(run)
	Vanguard.setup(run); ReviewRules.enable(run); OperationRules.enable(run,level); LevelMastery.enable(run)
	return run
func _initialize() -> void: execute.call_deferred()
func execute() -> void:
	var run:=fresh()
	check(run.exp.ascension==0 and run.mastery.modern,"New levels have no Ascension and use new mastery")
	check(run.mastery.value("health")==0 and run.mastery.value("damage")==0,"No passive offensive/defensive mastery at start")
	var cd: float=run.kit.cooldown("w"); run.kit.loadout.erase("level22")
	check(is_equal_approx(cd,run.kit.cooldown("w")*1.15),"W recharge 15 percent longer")
	run.kit.loadout.level22=true; run.level=26
	check(not run.mastery.buy(run,"charge"),"Cannot skip Utility prerequisites")
	for id in ["field","reach","economy","insulation","charge"]:
		while run.mastery.can_buy(id,run.level): check(run.mastery.buy(run,id),"Utility purchase "+id)
	check(not run.kit.extra_q_charge and run.mastery.value("starting_ability")==1,"Capstone unlocks a starting ability instead of a Q charge")
	check(run.kit.ability_cost("rocket")<8 and run.kit.energy_regen()>8,"Utility energy efficiency and regeneration work")
	check(is_equal_approx(UpgradePreview.stats(run,"f",1).Energy,run.kit.ability_cost("blink")),"Flash card includes mastery energy efficiency")
	check(is_equal_approx(UpgradePreview.stats(run,"d",1)["Energy / sec"],ReviewRules.drive_cost(run)),"Drive card includes mastery energy efficiency")
	ReviewRules.suppress(run); check(is_equal_approx(run.vanguard.emp_left,2.1),"EMP resistance reduces duration")
	run.state="camp"; run.exp.clear_clock=-2
	var collection:=ForgeEquipment.new(); check(collection.bank_camp(run,false),"Modern tree checkpoint banks")
	check(ForgeEquipment.valid_checkpoint(collection.checkpoint),"Modern tree validates")
	var resumed:=fresh(); check(collection.resume_into(resumed) and resumed.mastery.modern and collection.starting_ability,"Modern tree banks starting ability")
	var bad: Dictionary=collection.checkpoint.duplicate(true); bad.spent+=1
	check(not ForgeEquipment.valid_checkpoint(bad),"Reject forged mastery point count")
	check(fresh().mastery.spent==0,"New level resets mastery")
	var old:=collection.snapshot(); old.erase("recovery_used"); old.erase("recovery_target")
	check(collection.valid(old),"Old v3 profile stays valid")
	collection.inventory.courier_helmet.copies=27
	check(collection.bulk("craft",false) and collection.inventory.relay_helmet.copies==1,"Craft chains through tiers")
	collection.inventory.reclaimer_boots.copies=1
	check(collection.bulk("equip",false) and collection.equipped.boots=="reclaimer_boots","Auto equip chooses highest tier")
	var fail:=FailedForge.new(); fail.inventory.courier_helmet.copies=27
	var before:=fail.snapshot()
	check(not fail.bulk("craft",true) and fail.snapshot()==before,"Bulk craft rolls back failed save")
	fail.inventory.reclaimer_boots.copies=1; before=fail.snapshot()
	check(not fail.bulk("equip",true) and fail.snapshot()==before,"Auto equip rolls back failed save")
	collection=ForgeEquipment.new(); collection.chapter_cleared=1
	run=fresh(2); run.state="lost"; run.time=10; run.kills=100; collection.record_failure(run)
	check(collection.recovery_target==0,"Quick intentional deaths do not arm recovery")
	run.time=120; collection.record_failure(run)
	check(collection.recovery_target==1 and collection.recovery_used==[2],"Meaningful frontier failure arms one recovery")
	collection.record_failure(run); check(collection.recovery_used.size()==1,"Repeated failure cannot stack")
	var previous:=fresh(1); previous.state="camp"; previous.exp.route_index=2; previous.exp.clear_clock=-2
	var credits: int=collection.credits
	check(collection.bank_camp(previous,false) and collection.credits==credits+45,"Previous level clear redeems bounded recovery")
	collection.record_failure(run); check(collection.recovery_target==0,"Same frontier cannot renew consumed bonus")
	credits=collection.credits; collection.bank_camp(previous,false)
	check(collection.credits==credits,"Repeated banking cannot duplicate recovery")
	run=fresh(); run.level=26
	for id in ["field","companion","collector","repair","disruptor"]:
		while run.mastery.can_buy(id,run.level): run.mastery.buy(run,id)
	run.spawn_enemy(run.player+Vector2(80,0),0); var enemy: Dictionary=run.enemies.back(); enemy.hp=100
	run.kit.pet_position=run.player; LevelMastery.tick(run,0.1)
	check(enemy.hp==94 and enemy.stun>0,"Pet deals small damage and occasional stun")
	ReviewRules.suppress(run); var hp: float=enemy.hp; LevelMastery.tick(run,2)
	check(enemy.hp==hp,"Pet suppressed by EMP")
	run.health=10; run._collect_supply({"kind":"repair","value":5})
	check(run.health==15,"Recovery drops use HP, not legacy hull-unit multiplier")
	await ui_checks()
	print("LEVEL PROGRESSION: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
func capture(name: String) -> void:
	if "--render" not in OS.get_cmdline_user_args(): return
	await process_frame; await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://output/levels22")
	root.get_texture().get_image().save_png("res://output/levels22/"+name+".png")
func ui_checks() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate()
	game.persist_settings=false; root.add_child(game); await process_frame
	game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown(); game.collection=ForgeEquipment.new()
	game.start_run(); await capture("Levels")
	check(game.ui.overlay.get_children().filter(func(node): return node.has_meta("chapter")).size()==3,"Demo offers exactly three levels")
	game.launch_expedition(); check(LevelMastery.enabled(game.model),"Controller starts latest rules")
	game.model.state="camp"; game.model.exp.clear_clock=-2; game.screen="camp"
	for tab in ["Round clear","Build","Mastery","Equipment"]:
		game.review_tab=tab; ReviewView.camp(game)
		check(game.ui.overlay.get_children().any(func(node): return node.has_meta("continue_round")),"Continue available on "+tab)
		await capture(tab.replace(" ","-"))
	game.model.state="won"; game.ui.show_result(game.model,true); await capture("Victory")
	game.result_next(); check(game.chapter_choice==2,"Victory routes to next level")
	game.model.exp.operation_chapter=8; game.result_next(); check(game.chapter_choice==3,"Historical final level returns to demo level selection")
	game.chapter_choice=1; game.launch_expedition()
	game.model.kit.rank_up("x2"); game.model.kit.discovered.append("x2")
	game.model.vanguard.cast(game.model,"x2",game.model.player+Vector2(130,0))
	for unit in game.model.vanguard.constructs: unit.bank=42
	game.model.health=25; game.art.queue_redraw(); await capture("Combat")
	game.art.reduced_effects=true; game.art.queue_redraw(); await capture("Combat-reduced")
	game.queue_free(); await process_frame
