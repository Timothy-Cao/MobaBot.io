extends SceneTree
var failures := 0
var labels := 0
var rendered := false

func _initialize() -> void: _run.call_deferred()

func audit(node: Node, context: String) -> void:
	if node is Label and node.is_visible_in_tree() and node.has_meta("layout_rect") and not node.text.is_empty():
		labels += 1
		var intended: Rect2=node.get_meta("layout_rect")
		if node.autowrap_mode==TextServer.AUTOWRAP_OFF:
			for line in node.text.split("\n"):
				if node.get_theme_font("font").get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,node.get_theme_font_size("font_size")).x>intended.size.x+2:
					failures+=1; push_error(context+" overflow: "+line)
	for child in node.get_children(): audit(child,context)

func capture(game, id: String) -> void:
	await process_frame
	audit(game.ui.root,id)
	if rendered:
		await RenderingServer.frame_post_draw
		var path: String="res://output/expedition-"+id+".png"
		root.get_texture().get_image().save_png(path)
		print("CAPTURE ",path)

func _run() -> void:
	rendered="--render" in OS.get_cmdline_user_args()
	var game=load("res://src/salvage/expedition.tscn").instantiate()
	game.persist_settings=false
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	game.collection=ExpeditionGear.new()
	game.sound.set_muted(true); game.music_player.shutdown()
	game.start_run()
	await capture(game,"classes")
	game.launch_expedition()
	for i in range(60): game.model.step(1.0/60,Vector2.ZERO)
	await capture(game,"starter")
	game.model.exp.pending_chests=1
	game.open_discovery()
	await capture(game,"chest")
	game.choose_discovery(0)
	game.model.state="camp"; game.screen="camp"; game.model.exp.route_index=5; game.model.exp.field_credits=700
	ExpeditionView.camp(game)
	await capture(game,"shop")
	game.buy_item(0)
	game._open_gear()
	for id in ExpeditionGear.ITEMS: game.collection.inventory[id].copies=2
	game.gear_item="dynamo_cape"; game.gear_slot="cape"; ExpeditionView.gear(game)
	await capture(game,"equipment")
	game.close_gear(); game._open_build(); game.ui.build_page="mastery"; game.ui.show_build(game.model,false)
	await capture(game,"mastery")
	game.ui.build_page="overview"; game.ui.show_build(game.model,false)
	await capture(game,"overview")
	game.show_home(); game.ui.show_loadout()
	for slot in MobaKit.SLOTS:
		game.ui.loadout_slot=slot
		for page in range(3):
			game.ui.loadout_gallery_page=page
			game.ui.show_loadout()
			await capture(game,"loadout-"+slot+str(page))
	game.ui.loadout_page="passives"
	for page in range(2):
		game.ui.loadout_gallery_page=page; game.ui.show_loadout()
		await capture(game,"passives-"+str(page))
	game.launch_expedition()
	# Historical catalog fixtures intentionally exercise legacy offer IDs.
	game.model.kit.loadout.erase("review19")
	for id in BotSkillCatalog.SPECS:
		var slot: String={"active":"q","ultimate":"r","mobility":"f","speed":"d","summon":"t"}[MobaKit.ABILITIES[id].category]
		game.model.exp.install(game.model,slot,id)
		for rank_value in [4,9]:
			game.model.kit.ranks[slot]=rank_value; game.model.upgrades["skill_"+slot]=rank_value
			game.model.offers.assign(["skill_"+slot,"power","reactor"])
			game.ui.show_upgrades(game.model)
			await process_frame; audit(game.ui.root,id+str(rank_value))
		game.art.preview_slot=slot; game.art.cursor_world=game.model.player+Vector2(180,-60)
		game.art.queue_redraw(); await process_frame
	game.art.preview_slot=""
	game.launch_expedition(); game.model.exp.route_index=21; game.model.exp.enter(game.model)
	game.model.stage_time=game.model.exp.round_seconds(); game.model.exp.spawns(game.model,0.1)
	game.model.enemies.back().pos=game.model.player+Vector2(190,-85)
	game.model.enemies.back().warmup=0
	game.model.kit.extra.capacity=3
	for id in ["pulse_sentry","mirror_sentry","forward_sentry"]:
		game.model.kit.extra.cast(game.model,"t",id,game.model.player+Vector2(-95,35+game.model.kit.extra.summons.size()*45),Vector2.RIGHT,1)
	game.model.kit.extra.field(game.model.player+Vector2(180,-70),115,3,12,"gravity")
	game.model.kit.extra.blade(game.model.player,game.model.player+Vector2(230,0),22,false,1.5)
	game.model.kit.extra.plates.append(game.model.player+Vector2(150,30))
	game._drain_events(); game._update_camera(); game.ui.update_hud(game.model); game.art.queue_redraw()
	await capture(game,"combat")
	game.sound.set_muted(true); game.music_player.shutdown()
	await create_timer(0.2).timeout
	game.queue_free()
	await process_frame; await create_timer(0.2).timeout
	print("EXPEDITION UI: %d labels, %d overflow issues" % [labels,failures])
	quit(1 if failures else 0)
