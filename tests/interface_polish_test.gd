extends SceneTree
var checks:=0
var failures:=0
func check(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void: run.call_deferred()
func controls(node: Node) -> Array:
	var result: Array=[node]
	for child in node.get_children(): result.append_array(controls(child))
	return result
func run() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate()
	game.persist_settings=false
	var default_cast: Dictionary=game.cast_quick.duplicate()
	root.add_child(game)
	await process_frame
	# Exercise shipped defaults independently of the owner's saved preferences.
	game.cast_quick=default_cast
	game.set_physics_process(false)
	var collection_before: String=JSON.stringify(game.collection.snapshot())
	game.launch_practice()
	check(game.practice_rank==1,"Practice starts at rank one")
	for rank_value in [1,5,10]:
		game.practice_rank=rank_value; Vanguard.setup(game.model,rank_value)
		for slot in Vanguard.KEYS: check(Vanguard.rank_of(game.model,slot)==rank_value,"Shared preset includes every tool")
		check(Vanguard.hammer_rank(game.model)==rank_value and Vanguard.gun_rank(game.model)==rank_value,"Shared preset includes both weapons")
	for page in ["Build","Player","Enemies"]:
		game.practice_page=page; PracticeSandbox.draw(game)
		await process_frame
		for node in controls(game.ui.overlay):
			if node is Button: check(node.text not in ["Clear","Session","Starter"],"Practice pruned controls")
	check(BotTooltip.make("")==null,"Empty tooltip has no panel")
	check(BotTooltip.make("  ")==null,"Whitespace tooltip has no panel")
	var tooltip_button=load("res://src/salvage/tooltip_button.gd").new()
	check(tooltip_button._make_custom_tooltip("")==null,"Empty button tooltip suppressed")
	tooltip_button.free()
	game.close_practice()
	var key:=InputEventKey.new(); key.pressed=true; key.keycode=KEY_B
	game._input(key)
	check(game.screen=="placement" and game.practice_enemy=="dummy" and game.practice_count==1,"B arms one dummy")
	check(PracticeSandbox.place(game,game.model.player+Vector2(500,0)),"Dummy can be placed")
	game.close_practice(); key.keycode=KEY_C; game._input(key)
	check(game.model.enemies.is_empty() and game.screen=="running","C clears enemies without opening menu")
	game.model.exp.practice=false; key.keycode=KEY_B; game._input(key)
	check(game.screen=="running","Practice shortcuts absent from campaign")
	game.model.exp.practice=true
	game.camera_locked=true; game.camera_offset=Vector2.ZERO; game._update_camera()
	var original: Vector2=game.camera.position
	var player: Vector2=game.model.player
	var click:=InputEventMouseButton.new(); click.button_index=MOUSE_BUTTON_LEFT; click.pressed=true
	click.position=game.ui.mini_map.global_position+game.ui.mini_map.size*0.75
	game._input(click)
	check(game.minimap_held and game.model.detached_camera and game.camera.position.distance_to(original)>100,"Locked minimap inspection detaches camera")
	check(game.model.player==player,"Minimap never moves player")
	click.pressed=false; game._input(click)
	check(not game.minimap_held and game.camera.position.is_equal_approx(original),"Locked minimap release recenters")
	game.camera_locked=false; click.pressed=true; game._input(click)
	var inspected: Vector2=game.camera.position
	click.pressed=false; game._input(click)
	check(game.camera.position.is_equal_approx(inspected),"Unlocked minimap release retains view")
	game.ui.system_keys.lock=-MOUSE_BUTTON_LEFT
	click.pressed=true; game._input(click)
	check(game.camera_locked and not game.minimap_held,"Explicit mouse lock binding takes priority over minimap")
	game.ui.system_keys.lock=KEY_L
	game.camera_locked=false
	game.recenter_held=true; game._update_camera()
	check(game.camera.position.is_equal_approx(original),"Space recenters unlocked camera")
	game.recenter_held=false; game.camera_locked=true
	game.camera_offset=Vector2.ZERO; game.camera_speed=620; game.zoom_value=1
	game._edge_pan(Vector2(959,270),0.1)
	check(game.free_center.is_equal_approx(original),"Locked edges never move camera")
	game.camera_locked=false; game._edge_pan(Vector2(959,270),0.1)
	check(game.free_center.is_equal_approx(original+Vector2(62,0)),"Unlocked edge pan uses camera speed")
	game.camera_locked=true; game.recenter_held=true; game._edge_pan(Vector2(959,270),0.1)
	check(game.free_center.is_equal_approx(original+Vector2(62,0)),"Space suppresses edge pan")
	game.recenter_held=false; game.minimap_held=true; game._edge_pan(Vector2(959,270),0.1)
	check(game.free_center.is_equal_approx(original+Vector2(62,0)),"Minimap inspection suppresses edge pan")
	game.minimap_held=false; game.mouse_speed=2
	check(game._scaled_pointer(Vector2(110,100),Vector2(10,0))==Vector2(120,100),"Mouse multiplier doubles relative travel")
	check(game._scaled_pointer(Vector2(958,100),Vector2(10,0)).x==959,"Scaled cursor stays inside viewport")
	game.mouse_speed=1
	game.camera_offset=Vector2(100,0); game._update_camera()
	check(game.camera.position.is_equal_approx(original),"Locked camera ignores stale edge offset")
	game.camera_locked=false; game.free_center+=Vector2(300,0); game.minimap_held=true
	game._set_camera_lock(true)
	check(game.camera.position.is_equal_approx(original) and not game.minimap_held,"Turning lock on immediately cancels inspection and snaps home")
	for scale_value in [0.7,0.9,1.0]:
		game.hud_scale=scale_value; game._apply_hud_scale()
		game.minimap_held=true
		game._minimap_point(game.ui.mini_map.get_global_transform()*(game.ui.mini_map.size/2))
		check(game.free_center.is_equal_approx(SalvageRun.ARENA.get_center()),"Scaled minimap maps center correctly")
		check(game.ui.ability_bar.scale.is_equal_approx(Vector2.ONE*scale_value),"HUD scale applied")
	game.minimap_held=false; game.hud_scale=0.9; game._apply_hud_scale()
	for slot in game.cast_quick:
		check(game._confirm_cast(slot)==(slot in ["r","x1","x2","x3"]),"Requested cast defaults")
		if slot=="p1": continue
		game.cast_quick[slot]=false
		key.keycode=Vanguard.KEYS[slot]; key.pressed=true; game._input(key)
		check(game.pending_cast_slot==slot,"Normal press arms preview")
		key.pressed=false; game._input(key)
		check(game.pending_cast_slot==slot,"Normal release waits for left click")
		key.keycode=KEY_ESCAPE; key.pressed=true; game._input(key)
		check(game.pending_cast_slot=="" and game.screen=="running","Escape cancels preview without opening menu")
		game.cast_quick[slot]=true
		check(not game._confirm_cast(slot),"Quick setting skips confirmation")
	game.cast_quick={"q":true,"w":true,"e":true,"r":false,"p1":true,"x1":false,"x2":false,"x3":false}
	game.cast_quick.q=false
	game.pending_attack=true
	var charges_before: int=game.model.kit.charges.q
	key.keycode=KEY_Q; key.pressed=true; game._input(key)
	check(not game.pending_attack and game.model.kit.charges.q==charges_before,"Preview replaces attack aim without spending charge")
	click.pressed=true; click.position=Vector2(600,270)
	game._unhandled_input(click)
	check(game.pending_cast_slot=="" and game.model.kit.charges.q==charges_before-1,"Left click confirms exactly one cast")
	game.model.vanguard.pending.clear(); game.cast_quick.q=true
	game.ui.update_hud(game.model)
	for slot in ["p1","x1","x2","x3"]:
		if slot!="p1": game.model.vanguard.constructs.append({"slot":slot})
	game.ui.update_hud(game.model)
	for slot in ["x1","x2","x3"]:
		check(game.ui.ability_shades[slot].get_parent().get_node("Active").active,"Deployed module has active overlay")
		check(game.ui.ability_labels[slot].text=="","Active module avoids status words")
	game.model.vanguard.constructs.clear(); game.ui.update_hud(game.model)
	check(not game.ui.ability_shades.x1.get_parent().get_node("Active").active,"Expired construct clears overlay")
	game._notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not game.minimap_held and game.camera_offset==Vector2.ZERO,"Alt-tab clears temporary inspection")
	game.screen="settings"; game.ui.settings_page="options"; game.ui.show_settings()
	await process_frame
	var sliders: Array=controls(game.ui.overlay).filter(func(n): return n is HSlider)
	check(sliders.size()==4,"Sound, camera, mouse and HUD sliders")
	for node in controls(game.ui.overlay):
		if node is Label: check(node.text!="Icon skin","No skin setting")
	var volume=sliders.filter(func(n): return n.name=="sound")[0]
	volume.value=0
	check(game.mute_setting and AudioServer.is_bus_mute(0),"Slider zero mutes effects and music")
	volume.value=100
	check(not game.mute_setting and not AudioServer.is_bus_mute(0) and is_zero_approx(AudioServer.get_bus_volume_db(0)),"Slider 100 restores full mix")
	for slot in VanguardHud.SLOT_X:
		var texture:=PaintedIcons.texture(VanguardHud.icon(slot))
		check(texture!=null,"Official Vanguard painted icon exists")
		if texture!=null:
			var source:=Image.new()
			check(source.load_png_from_buffer(FileAccess.get_file_as_bytes("res://assets/vanguard_icons/"+VanguardHud.icon(slot)+".png"))==OK,"Generated source decodes")
			check(source.get_width()==source.get_height() and source.detect_alpha()==Image.ALPHA_NONE,"Source square and opaque")
			var image:=texture.get_image()
			check(image.get_size()==Vector2i(128,128),"Icon import is 128 square")
			check(not image.is_invisible() and not image.detect_alpha(),"Icon is opaque, not empty")
	check(JSON.stringify(game.collection.snapshot())==collection_before,"Practice and interface never mutate collection")
	if "--render" in OS.get_cmdline_user_args():
		DirAccess.make_dir_recursive_absolute("res://output/interface-polish")
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/interface-polish/settings.png")
		game.ui.settings_page="controls"; game.ui.show_settings()
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/interface-polish/controls.png")
		game.open_practice(); game.practice_page="Build"; PracticeSandbox.draw(game)
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/interface-polish/practice.png")
		game.close_practice(); game.ui.update_hud(game.model)
		for reduced in [false,true]:
			game.art.reduced_effects=reduced
			game.ui.reduced=reduced; game.ui.update_hud(game.model)
			await process_frame; await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://output/interface-polish/hud-%s.png"%str(reduced))
	game.queue_free(); await process_frame; await process_frame
	print("INTERFACE POLISH: %d checks, %d failures"%[checks,failures])
	quit(0 if failures==0 else 1)
