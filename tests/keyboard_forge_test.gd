extends SceneTree
var checks:=0
var failures:=0
func check(value: bool, text: String) -> void:
	checks+=1
	if not value: failures+=1; push_error(text)
func fresh() -> SalvageRun:
	var run:=SalvageRun.new(6127)
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo()
	run.attacks.enabled=true; run.kit.starting_gun=true; run.kit.onboarding=true
	BotExpedition.new().start(run,"ranged",0); BotKeyboard.enable(run)
	return run
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var run:=fresh()
	check(run.kit.flexible() and run.kit.loadout.passives.size()==9,"Flexible bank shape")
	check(BotKeyboard.slot_at(run.kit,KEY_1)=="p1" and BotKeyboard.slot_at(run.kit,KEY_Q)=="q","Gun and Q starters")
	run.kit.recharge.q=1.2; run.kit.charges.q=1; run.kit.rank_up("q"); run.upgrades.skill_q=1
	var clock: float=run.kit.recharge.q
	check(BotKeyboard.swap(run.kit,KEY_Q,KEY_1),"Active/toggle swap")
	check(BotKeyboard.slot_at(run.kit,KEY_1)=="q" and run.kit.ranks.q==1 and is_equal_approx(run.kit.recharge.q,clock),"Swap retains rank and recharge")
	check(not BotKeyboard.swap(run.kit,KEY_Q,KEY_D),"Movement bank isolation")
	check(BotKeyboard.swap(run.kit,KEY_D,KEY_F),"D/F swap")
	check(not BotKeyboard.place(run,"nuke",KEY_D),"General skill cannot replace movement")
	check(BotKeyboard.place(run,"lightning",KEY_W) and run.kit.passive_active("lightning"),"Passive placed on W activates")
	check(BotKeyboard.place(run,"returner",KEY_2),"Active placed on 2")
	check(BotKeyboard.place(run,"orbit",KEY_3),"Orbit on 3")
	check(BotKeyboard.place(run,"ricochet",KEY_4),"Dependent passive")
	check(not BotKeyboard.place(run,"flame",KEY_3),"Dependency cannot be orphaned")
	check(not BotKeyboard.place(run,"returner",KEY_T),"No duplicated skill state")
	for id in ["gravity","strike","laser"]:
		var key: int={"gravity":KEY_E,"strike":KEY_R,"laser":KEY_T}[id]
		check(BotKeyboard.place(run,id,key),"Mixed full keyboard "+id)
	check(run.kit.discovered.size()==11,"Eleven equipped skills maximum")
	var forge:=ForgeEquipment.new()
	check(forge.valid(forge.snapshot()),"Fresh forging profile")
	forge.apply_to(run); run.state="camp"
	check(forge.bank_camp(run,false),"Bank flexible checkpoint")
	check(forge.valid(forge.snapshot()),"Checkpoint validates")
	var serialized: Dictionary=JSON.parse_string(JSON.stringify(forge.snapshot()))
	check(forge.valid(serialized),"JSON number roundtrip")
	var restored:=ForgeEquipment.new(); restored.restore(serialized)
	var resumed:=fresh()
	check(restored.resume_into(resumed),"Resume flexible checkpoint")
	check(BotKeyboard.slot_at(resumed.kit,KEY_T)==BotKeyboard.slot_at(run.kit,KEY_T),"Binding persisted")
	var broken: Dictionary=serialized.duplicate(true)
	broken.checkpoint.bindings.q=KEY_D
	check(not forge.valid(broken),"Illegal restored key rejected")
	forge.inventory.courier_helmet.copies=3
	check(forge.transact("forge","courier_helmet",false),"Forge consumes exactly three")
	check(forge.inventory.courier_helmet.copies==0 and forge.inventory.bastion_helmet.copies==1,"Forge yields one next tier")
	check(forge.equipped.helmet=="bastion_helmet","Forged equipped piece advances automatically")
	check(not forge.transact("reroll","bastion_helmet",false) and not forge.transact("star","bastion_helmet",false),"Removed operations rejected")
	forge.inventory.relay_chest.copies=1; forge.equipped.chest="relay_chest"; forge.apply_to(run)
	check(run.kit.rank_bonus==1 and not run.kit.forge_pet,"Tier 4 ranks only")
	forge.inventory.reclaimer_boots.copies=1; forge.equipped.boots="reclaimer_boots"; forge.apply_to(run)
	check(run.kit.rank_bonus==1 and run.kit.forge_pet,"Tier 5 one companion and nonstacking rank")
	forge.path="res://output/missing-directory/forging.json"
	forge.inventory.bastion_helmet.copies=3
	var before:=forge.snapshot()
	check(not forge.transact("forge","bastion_helmet") and forge.snapshot()==before,"Failed write rolls back")
	var legacy:=ExpeditionGear.new(); legacy.inventory.dynamo_helmet.copies=2; legacy.inventory.dynamo_helmet.stars=2
	var migration:=ForgeEquipment.new()
	check(migration.import_previous(legacy.snapshot()),"Old profile accepted")
	check(migration.inventory.courier_helmet.copies==6 and migration.migration.original==legacy.snapshot(),"Migration retains source and invested duplicates")
	var keys: Dictionary=BotKeyboard.SYSTEM_DEFAULTS.duplicate()
	check(BotKeyboard.valid_system(keys),"Default protected controls")
	keys.attack=KEY_G; check(BotKeyboard.valid_system(keys),"Rebind to G")
	keys.build=KEY_G; check(not BotKeyboard.valid_system(keys),"Control collision rejected")
	keys=BotKeyboard.SYSTEM_DEFAULTS.duplicate(); keys.attack=KEY_1
	check(not BotKeyboard.valid_system(keys),"Ability keys protected")
	for all_passives in [false,true]:
		var packed:=fresh()
		var roster: Array=["bolt","orbit","pulse","ricochet","plating","thorns","lightning","poison","mounted"] if all_passives else ["rocket","flame","nuke","laser","returner","gravity","strike","crosswire","sweep"]
		for i in range(9):
			var old_slot:=BotKeyboard.learned(packed.kit,roster[i])
			if old_slot!="":
				if packed.kit.bindings[old_slot]!=BotKeyboard.GENERAL[i]: BotKeyboard.swap(packed.kit,packed.kit.bindings[old_slot],BotKeyboard.GENERAL[i])
			else: check(BotKeyboard.place(packed,roster[i],BotKeyboard.GENERAL[i]),"Full-bank placement "+roster[i])
		check(packed.kit.discovered.size()==11,"Nine general plus two movement")
		var collection:=ForgeEquipment.new(); collection.apply_to(packed); packed.state="camp"; collection.bank_camp(packed,false)
		check(collection.valid(collection.snapshot()),"Maximum-bank checkpoint")
		if not all_passives:
			var bank:=BotKeyboard.learned(packed.kit,"sweep")
			check(bank.begins_with("x") and packed.upgrade_available("skill_"+bank),"Overflow bank gets real upgrades")
			packed.state="upgrade"; packed.offers.assign(["skill_"+bank]); check(packed.choose_upgrade(0) and packed.kit.ranks[bank]==1,"Overflow upgrade purchase")
	var channels:=fresh()
	check(BotKeyboard.place(channels,"repair_channel",KEY_W),"Place repair channel")
	channels.kit.extra.repair_left=3
	check(BotKeyboard.place(channels,"gravity",KEY_W) and channels.kit.extra.repair_left==0,"Replacing a channel cancels it")
	check(BotKeyboard.place(channels,"roller",KEY_D),"Place roller")
	channels.kit.extra.roll_left=4
	check(BotKeyboard.place(channels,"blink",KEY_D)==false,"Duplicate movement rejected")
	check(BotKeyboard.place(channels,"vault",KEY_D) and channels.kit.extra.roll_left==0,"Replacing roller cancels it")
	for i in range(100):
		var r:=fresh(); r.exp.pending_chests=1; r.exp.chests_opened=i%4; r.offer_rng.seed=i; r.exp.make_chest(r); r.state="chest"
		check(r.exp.chest_choices.size()==3,"Three discoveries")
		check(r.exp.choose_chest(r,i%3),"Valid bounded reward "+str(i))
		check(MobaKit.valid_loadout(r.kit.loadout),"Result valid")
	print("KEYBOARD/FORGE: %d checks, %d failures"%[checks,failures]); quit(0 if failures==0 else 1)
