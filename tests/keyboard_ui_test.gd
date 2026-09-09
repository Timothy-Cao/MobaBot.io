extends SceneTree
var failures:=0
var labels:=0
var rendered:=false
func _initialize() -> void: _run.call_deferred()
func audit(node: Node, page: String) -> void:
	if node is Label and node.is_visible_in_tree() and node.has_meta("layout_rect") and not node.text.is_empty():
		labels+=1
		var rect: Rect2=node.get_meta("layout_rect")
		if node.autowrap_mode==TextServer.AUTOWRAP_OFF:
			for line in node.text.split("\n"):
				if node.get_theme_font("font").get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,node.get_theme_font_size("font_size")).x>rect.size.x+2:
					failures+=1; push_error(page+" overflow: "+line)
	for child in node.get_children(): audit(child,page)
func capture(game, page: String) -> void:
	await create_timer(0.4).timeout
	audit(game.ui.root,page)
	if rendered:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/keyboard-"+page+".png")
func _run() -> void:
	rendered="--render" in OS.get_cmdline_user_args()
	var game=load("res://src/salvage/expedition.tscn").instantiate()
	game.persist_settings=false; root.add_child(game); await process_frame
	game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.collection=ForgeEquipment.new(); game.ui.reduced=false
	game.show_home(); await capture(game,"home")
	game.launch_expedition(); game.ui.update_hud(game.model); await capture(game,"combat")
	game.model.exp.pending_chests=1; game.open_discovery()
	game.model.exp.chest_choices.assign([{"id":"nuke","slot":"","tier":1},{"id":"lightning","slot":"","tier":0},{"id":"laser","slot":"","tier":2}])
	ExpeditionView.chest(game); await capture(game,"reward")
	game.choose_discovery(0); await capture(game,"placement")
	game.keyboard_key(KEY_2); game.place_discovery()
	if BotKeyboard.slot_at(game.model.kit,KEY_2)=="": failures+=1; push_error("Placement failed")
	game._open_build(); game.ui.build_page="overview"; game.ui.show_build(game.model,false)
	await capture(game,"overview")
	game.open_keyboard(); await capture(game,"arrange")
	game.keyboard_key(KEY_Q); game.keyboard_key(KEY_W); game.close_keyboard(); game._close_build()
	game._open_settings(); game.ui.settings_page="options"; game.ui.show_settings(); await capture(game,"options")
	game.ui.settings_page="controls"; game.ui.show_settings(); await capture(game,"controls")
	game.ui.system_keys.attack=KEY_G
	game._close_settings(); game.screen="running"
	var event:=InputEventKey.new(); event.keycode=KEY_G; event.pressed=true; game._input(event)
	if not game.pending_attack: failures+=1; push_error("Rebound attack did not arm")
	game.pending_attack=false; event.keycode=KEY_A; game._input(event)
	if game.pending_attack: failures+=1; push_error("Old binding still active")
	game.model.exp.pending_chests=1; game.open_discovery(); game._open_settings(); game._close_settings()
	if game.screen!="chest" or not game.ui.overlay.visible: failures+=1; push_error("Chest settings return lost")
	game.model.state="upgrade"; game.model.offers.assign(["skill_q","power","reactor"]); game.ui.show_upgrades(game.model)
	await capture(game,"power")
	game.model.state="camp"; game.screen="camp"; ExpeditionView.camp(game); await capture(game,"camp")
	game._open_gear()
	for id in ForgeEquipment.ITEMS: game.collection.inventory[id].copies=3
	for i in range(5):
		game.gear_item=ForgeEquipment.SETS[i]+"_boots"; game.gear_slot="boots"; ExpeditionView.gear(game)
		await capture(game,"forge-"+str(i+1))
	game.gear_action("forge","courier_boots")
	game.close_gear(); game.screen="running"; game.model.state="running"; game.ui.show_running()
	for i in range(36):
		game.model.spawn_enemy(game.model.player+Vector2.from_angle(i*TAU/36)*(145+(i%4)*55),i%3)
	game.model.health=game.model.max_health()*0.55; game.model.kit.energy=game.model.kit.energy_max()*0.6
	for reduced in [false,true]:
		game.ui.reduced=reduced; game.art.reduced_effects=reduced
		game.ui.bar_signature=""; game.ui.update_hud(game.model); game.art.queue_redraw()
		await capture(game,"crowd-reduced" if reduced else "crowd")
	PaintedIcons.enabled=false; game.ui.bar_signature=""; game.ui.update_hud(game.model)
	await capture(game,"base-skin")
	PaintedIcons.enabled=true
	game.queue_free(); await process_frame
	print("KEYBOARD UI: %d labels, %d issues"%[labels,failures]); quit(0 if failures==0 else 1)
