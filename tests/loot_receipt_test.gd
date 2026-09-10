extends SceneTree
var checks:=0
var failures:=0
var rendered:=false
func check(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(message)
func fresh(rank_value: int=0) -> SalvageRun:
	var run:=SalvageRun.new(17017)
	run.loot_rng.seed=17918
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
	BotExpedition.new().start(run,"ranged",0); BotKeyboard.enable(run); run.exp.enable_revision(run)
	Vanguard.setup(run,rank_value)
	return run
func _initialize() -> void: execute.call_deferred()
func execute() -> void:
	rendered="--render" in OS.get_cmdline_user_args()
	var run:=fresh(); var exp: BotExpedition=run.exp
	var shops:=0
	for i in range(BotExpedition.ROUTE.size()):
		exp.route_index=i
		var expected: bool=i in [2,5,8,10,12,16,19,21]
		check(exp.is_shop(true)==expected,"Shop only at each stage end %d"%i)
		check(exp.is_shop()==(i in [5,12,19]),"Legacy schedule preserved")
		if exp.is_shop(true): shops+=1
	check(shops==8,"All eight stages have shops")
	exp.route_index=2; run.state="camp"; exp.ensure_shop(run)
	var stock:=exp.shop_stock.duplicate(); var rng_state: int=run.loot_rng.state
	exp.ensure_shop(run)
	check(stock==exp.shop_stock and rng_state==run.loot_rng.state,"No stock reroll")
	exp.shop_stock.assign(["","",""]); exp.ensure_shop(run)
	check(exp.shop_stock==["","",""] and rng_state==run.loot_rng.state,"Sold stock never restocks")
	run=fresh(); exp=run.exp
	exp.pending_chests=20; run.events.clear(); Vanguard.progression(run)
	var receipt: Dictionary=exp.reward_receipt.duplicate(true)
	check(receipt.chests==20 and receipt.points==20 and receipt.credits==400,"Exact batch receipt")
	check(run.kit.loadout.rewards18.size()==receipt.points and exp.field_credits==receipt.credits,"Points and credits match actual awards")
	var item_count:=0
	for id in receipt.items:
		item_count+=receipt.items[id]
		check(exp.pending_items.count(id)==receipt.items[id],"Item quantities match actual awards")
	check(item_count>0 and item_count==exp.pending_items.size(),"Fixed seed covers equipment drops")
	check(run.events.filter(func(event): return event.kind=="chest_contents").size()==1,"One batch event")
	Vanguard.progression(run)
	check(receipt==exp.reward_receipt and exp.field_credits==400,"Progression cannot double claim")
	var forge:=ForgeEquipment.new(); var original:=forge.snapshot()
	run.state="camp"; exp.route_index=2
	check(forge.bank_camp(run,false),"Memory-only banking succeeds")
	check(forge.checkpoint.receipt==receipt and ForgeEquipment.valid_checkpoint(forge.checkpoint),"Receipt checkpoint validates")
	for id in receipt.items: check(forge.inventory[id].copies==original.inventory[id].copies+receipt.items[id],"Bank each actual item once")
	var banked:=forge.snapshot(); forge.bank_camp(run,false)
	check(forge.snapshot()==banked,"Repeated bank is idempotent")
	var resumed:=fresh()
	check(forge.resume_into(resumed) and resumed.exp.reward_receipt==receipt,"Continue retains results")
	check(resumed.exp.shop_stock==exp.shop_stock and resumed.loot_rng.state==run.loot_rng.state,"Continue preserves shop and RNG")
	check(resumed.exp.pending_items.is_empty(),"Receipt is not pending loot")
	var failed_run:=fresh(); failed_run.state="camp"; failed_run.exp.route_index=2
	failed_run.exp.pending_items.append("courier_helmet"); failed_run.exp.reward_receipt={"chests":1,"points":0,"credits":20,"items":{"courier_helmet":1}}
	var failed_forge:=ForgeEquipment.new(); failed_forge.path="res://output/receipt-intentionally-missing/profile.json"
	var before_failure:=failed_forge.snapshot()
	check(not failed_forge.bank_camp(failed_run,true) and failed_forge.snapshot()==before_failure,"Failed disk save rolls back collection/checkpoint")
	check(failed_run.exp.pending_items==["courier_helmet"] and not failed_forge.message.is_empty(),"Failed save keeps pending item and visible error")
	var retry_stock: Array=failed_run.exp.shop_stock.duplicate(); var retry_rng: int=failed_run.loot_rng.state
	check(failed_forge.bank_camp(failed_run,false),"Retry can bank pending rewards")
	check(failed_run.exp.shop_stock==retry_stock and failed_run.loot_rng.state==retry_rng,"Retry retains stock and RNG")
	check(failed_forge.checkpoint.receipt.items.courier_helmet==1 and failed_run.exp.pending_items.is_empty(),"Retry retains receipt without pending duplicate")
	var old:=forge.checkpoint.duplicate(true); old.erase("receipt"); forge.checkpoint=old
	check(ForgeEquipment.valid_checkpoint(old) and forge.resume_into(resumed),"Old checkpoint accepted")
	check(resumed.exp.reward_receipt==RewardLedger.empty(),"Do not fabricate old chest results")
	for bad in [{}, {"chests":-1,"points":0,"credits":0,"items":{}}, {"chests":1,"points":0,"credits":0,"items":{"unknown":1}}, {"chests":1,"points":0,"credits":0,"items":{"courier_helmet":0}}]:
		var broken:=old.duplicate(true); broken.receipt=bad
		check(not ForgeEquipment.valid_checkpoint(broken),"Malformed receipts rejected")
	run=fresh(10); run.exp.pending_chests=1; Vanguard.progression(run)
	check(run.exp.reward_receipt.points==0 and run.exp.reward_receipt.credits==40 and run.exp.field_credits==40,"Maxed kit receives stated credit fallback")
	run=fresh(); run.boss_defeated=true; run.exp.route_index=2; run.exp.clear_clock=0.001
	run.exp.finish_step(run,0.01)
	check(run.state=="camp" and run.exp.reward_receipt.chests==1 and run.exp.reward_receipt.credits==100,"Round clear receipt includes chest and clear credits")
	run.exp.advance(run)
	check(run.exp.reward_receipt==RewardLedger.empty(),"Next round starts a fresh receipt")
	await ui_checks(receipt)
	print("LOOT RECEIPT: %d checks, %d failures"%[checks,failures]); quit(0 if failures==0 else 1)
func labels_in(node: Node) -> String:
	var result: String=node.text if node is Label else ""
	for child in node.get_children(): result+="\n"+labels_in(child)
	return result
func capture(name_value: String) -> void:
	await create_timer(0.85).timeout
	if rendered:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/receipt-"+name_value+".png")
func ui_checks(sample: Dictionary) -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate()
	game.persist_settings=false; root.add_child(game); await process_frame
	game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.collection=ForgeEquipment.new(); game.model=fresh(); game.model.state="camp"; game.model.exp.route_index=2
	game.art.model=game.model
	game.model.exp.field_credits=800; game.model.exp.reward_receipt=sample.duplicate(true)
	game.collection.bank_camp(game.model,false); game.screen="camp"
	for reduced in [false,true]:
		game.ui.reduced=reduced; ExpeditionView.camp(game)
		var panel: LootReceipt=game.ui.overlay.get_node("RoundReceipt")
		var words:=labels_in(panel)
		check("+20 skill points" in words and "+400 field credits" in words,"Actual quantities visible")
		for id in sample.items: check(ForgeEquipment.ITEMS[id].name in words,"Actual gear name visible")
		if reduced:
			for card in panel.reveal_cards: check(card.modulate.a==1,"Reduced effects immediate")
		await capture("stage-reduced" if reduced else "stage")
		var before: Dictionary=game.collection.snapshot()
		var click:=InputEventMouseButton.new(); click.button_index=MOUSE_BUTTON_LEFT; click.pressed=true
		panel.reveal_cards[0].gui_input.emit(click)
		for card in panel.reveal_cards: check(card.modulate.a==1 and card.scale==Vector2.ONE,"Click skips reveal")
		ExpeditionView.camp(game)
		check(game.collection.snapshot()==before,"Reveal/skip/redraw never grants rewards")
	var item: String=game.model.exp.shop_stock[0]; var price: int=100+ForgeEquipment.ITEMS[item].tier*100
	var copies: int=game.collection.inventory[item].copies
	game.buy_item(0)
	check(game.model.exp.field_credits==800-price and game.collection.inventory[item].copies==copies+1,"Purchase exact price and one piece")
	check(game.model.exp.shop_stock[0]=="" and game.collection.checkpoint.shop[0]=="","Sold slot checkpointed")
	game.buy_item(0)
	check(game.model.exp.field_credits==800-price and game.collection.inventory[item].copies==copies+1,"Double click cannot buy twice")
	# Force a safe failed transaction without touching a real profile.
	game.collection.blocked=true
	var balance: int=game.model.exp.field_credits; var pending: Array=game.model.exp.pending_items.duplicate()
	var before_stock: Array=game.model.exp.shop_stock.duplicate(); var profile: Dictionary=game.collection.snapshot()
	game.buy_item(1)
	check(game.model.exp.field_credits==balance and game.model.exp.pending_items==pending and game.model.exp.shop_stock==before_stock and game.collection.snapshot()==profile,"Failed buy restores money/items/stock")
	game.collection.blocked=false
	# One ordinary chest fits completely; large batches remain scrollable.
	game.model.exp.reward_receipt={"chests":1,"points":1,"credits":100,"items":{"courier_helmet":1}}
	ExpeditionView.camp(game); await capture("single")
	var single: LootReceipt=game.ui.overlay.get_node("RoundReceipt")
	var scroll: ScrollContainer=single.get_child(1)
	check(scroll.get_v_scroll_bar().max_value<=scroll.size.y,"Three standard rewards fit without scrolling")
	game.model.exp.route_index=0; ExpeditionView.camp(game); await capture("round")
	check(not "Shop" in labels_in(game.ui.overlay),"No shop between rounds")
	game.screen="running"; game.model.state="running"; game.ui.show_running(); game.ui.update_hud(game.model)
	game.free_center=game.model.player; game._update_camera(); game.art.visible=true; game.art.queue_redraw()
	game.model.events.clear(); game.model.emit_event("chest_contents",game.model.player,{"receipt":{"chests":1,"points":1,"credits":20,"items":{"courier_helmet":1}}})
	game._drain_events()
	check(game.ui.hud.has_node("ChestReceipt"),"Combat receipt exists")
	check("Salvaged Visor" in labels_in(game.ui.hud.get_node("ChestReceipt")),"Combat receipt names the actual item")
	await capture("toast")
	game.queue_free(); await process_frame
