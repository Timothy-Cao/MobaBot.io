extends SceneTree
var checks:=0
var failures:=0
class FailedForge extends ForgeEquipment:
	func save() -> bool: return false

func check(ok: bool, label: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(label)

func fresh(chapter: int=1) -> SalvageRun:
	var run:=SalvageRun.new(7127); run.loot_rng.seed=8028
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
	BotExpedition.new().start(run,"ranged",0); run.exp.enable_revision(run)
	Vanguard.setup(run); ReviewRules.enable(run); OperationRules.enable(run,chapter)
	return run

func _initialize() -> void: execute.call_deferred()

func execute() -> void:
	var run:=fresh()
	check(run.exp.route().size()==3 and run.exp.round_seconds()==90,"Three-round Operation starts with shorter survival")
	check(run.next_level==20 and run.level==1 and run.exp.field_credits==0,"New Operation resets progression and field wallet")
	for slot in ReviewRules.MODULES: check(Vanguard.rank_of(run,slot)==0,"New Operation does not own modules")
	run.stage_time=90; OperationRules.pace(run); Vanguard.progression(run)
	check(run.level==3 and run.total_xp==40,"Survival XP foundation is bounded")
	OperationRules.pace(run); check(run.total_xp==40,"Repeated pacing cannot duplicate XP")
	run.total_xp=500; Vanguard.progression(run); ReviewRules.offer(run)
	var selections:=0
	while run.state=="upgrade" and selections<100:
		run.choose_upgrade(0); selections+=1
	check(run.level==26 and selections==75,"75 picks complete eight core tools at level 26")
	for slot in ReviewRules.CORE: check(Vanguard.rank_of(run,slot)==10,"Core reaches cap: "+slot)
	var collection:=ForgeEquipment.new()
	var old:=collection.snapshot(); old.erase("chapter_cleared"); old.erase("crate_rng")
	check(collection.valid(old),"Original v3 profile accepted without new fields")
	collection.restore(old); check(collection.chapter_cleared==0 and collection.credits==150,"Migration preserves balance and starts Chapter 1")
	run=fresh(); run.state="camp"; run.exp.clear_clock=-2; run.exp.carry_credits=45
	check(collection.bank_camp(run,false),"Round Salvage banks")
	check(collection.credits==195 and collection.chapter_cleared==0,"First round grants Salvage without Chapter unlock")
	check(ForgeEquipment.valid_checkpoint(collection.checkpoint),"Operation checkpoint validates")
	var resumed:=fresh(8); check(collection.resume_into(resumed),"Resume Operation checkpoint")
	check(resumed.exp.operation_chapter==1 and resumed.kit.loadout.operation_xp==[0,0,0],"Resume preserves Chapter and pacing claims")
	resumed.exp.advance(resumed); check(resumed.exp.route_index==1 and resumed.exp.round_seconds()==105,"Resume advances within Operation")
	run.exp.route_index=2; run.exp.carry_credits=75; run.state="camp"; run.exp.clear_clock=-2
	check(collection.bank_camp(run,false),"Final round banks transaction")
	check(collection.chapter_cleared==1 and collection.unlocked_chapter()==2 and collection.credits==370,"First Chapter unlock and first-clear reward")
	collection.bank_camp(run,false); check(collection.credits==370,"Repeated bank cannot duplicate first-clear or round rewards")
	run.exp.advance(run); check(run.state=="won","Third round finishes Operation")
	var bad:=collection.checkpoint.duplicate(true); bad.route=3
	check(not ForgeEquipment.valid_checkpoint(bad),"Reject out-of-range Operation checkpoint")
	var fail:=FailedForge.new(); fail.credits=300; fail.rng.seed=722
	var before:=fail.snapshot(); check(fail.buy_crate(true)=="" and fail.snapshot()==before,"Failed crate save restores currency, inventory and RNG")
	var item:=collection.buy_crate(false)
	check(item!="" and collection.credits==220 and collection.inventory[item].copies>0,"Crate grants equipment for persistent Salvage")
	check(collection.valid(collection.snapshot()),"Updated profile validates")
	var field_run:=fresh(); field_run._collect_supply({"kind":"coins","value":25})
	check(field_run.exp.field_credits==25 and field_run.coins==0,"Field coin pickup never enters permanent wallet")
	var rolls:=ForgeEquipment.new(); rolls.rng.seed=17918; rolls.credits=750000
	var counts: Array[int]=[0,0,0,0,0]
	for i in range(5000):
		var found:=rolls.buy_crate(false)
		if found!="": counts[ForgeEquipment.ITEMS[found].tier-1]+=1
	check(counts[0]>3850 and counts[0]<4150 and counts[1]>700 and counts[1]<1000,"Fixed-seed crate distribution mostly low tiers")
	check(counts[2]>75 and counts[2]<225 and counts[3]>0 and counts[3]<25 and counts[4]==0,"High-tier crate chances remain rare; tier five is forged")
	var failed_run:=fresh(2); failed_run.state="camp"; failed_run.exp.route_index=2; failed_run.exp.clear_clock=-2; failed_run.exp.carry_credits=80
	before=fail.snapshot()
	check(not fail.bank_camp(failed_run,true) and fail.snapshot()==before and failed_run.exp.carry_credits==80,"Failed Chapter save preserves reward and unlock for retry")
	for chapter in range(1,9):
		run=fresh(chapter); run.exp.route_index=2; run.stage_time=run.exp.round_seconds(); run.exp.spawns(run,0)
		var bosses: Array=run.enemies.filter(func(e): return e.has("exp_boss"))
		check(bosses.size()==1 and bosses[0].hp==OperationRules.boss_hp(run),"Authored Chapter boss HP: "+str(chapter))
		check(run.exp.stage_number()==chapter and ReviewRules.boss_deadline(run)==180,"Chapter identity and Operation deadline")
		run.state="camp"; run.exp.clear_clock=-2; var packed:=ForgeEquipment.new().pack_run(run)
		check(ForgeEquipment.valid_checkpoint(packed),"Chapter checkpoint remains valid: "+str(chapter))
	check("emp" not in OperationRules.roster(fresh(1)) and "emp" in OperationRules.roster(fresh(2)),"Chapter 2 introduces EMP")
	await ui_checks()
	print("OPERATIONS: %d checks, %d failures"%[checks,failures]); quit(0 if failures==0 else 1)

func capture(name: String) -> void:
	if "--render" not in OS.get_cmdline_user_args(): return
	await process_frame; await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://output/operations20")
	root.get_texture().get_image().save_png("res://output/operations20/"+name+".png")

func ui_checks() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate()
	game.persist_settings=false; root.add_child(game); await process_frame
	game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.collection=ForgeEquipment.new(); game.start_run()
	await capture("Chapters")
	game.chapter_choice=2; game.launch_expedition()
	check(game.screen=="prepare","Locked Chapter cannot launch")
	game.chapter_choice=1; game.launch_expedition()
	check(OperationRules.enabled(game.model),"Normal entry uses Operations")
	game.model.state="camp"; game.model.exp.clear_clock=-2; game.screen="camp"; game.model.exp.field_credits=600
	ReviewView.camp(game); await capture("Round-clear")
	game.model.state="running"; game.show_home(); game._open_gear()
	await capture("Equipment")
	game.buy_supply_crate()
	check(game.collection.credits==0 and game.collection.message.begins_with("Recovered"),"Home equipment crate interaction")
	await capture("Crate-result")
	game.queue_free(); await process_frame
