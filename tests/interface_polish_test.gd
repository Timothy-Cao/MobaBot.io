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
	root.add_child(game)
	await process_frame
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
	check(game.camera_offset.is_equal_approx(Vector2(62,0)),"Locked edge pan uses camera speed")
	game.camera_locked=false; game._edge_pan(Vector2(959,270),0.1)
	check(game.camera_offset.is_equal_approx(Vector2(62,0)),"Unlocked mode does not edge pan")
	game.camera_locked=true; game.recenter_held=true; game._edge_pan(Vector2(959,270),0.1)
	check(game.camera_offset.is_equal_approx(Vector2(62,0)),"Space suppresses edge pan")
	game.recenter_held=false; game.minimap_held=true; game._edge_pan(Vector2(959,270),0.1)
	check(game.camera_offset.is_equal_approx(Vector2(62,0)),"Minimap inspection suppresses edge pan")
	game.minimap_held=false; game.mouse_speed=2
	check(game._scaled_pointer(Vector2(110,100),Vector2(10,0))==Vector2(120,100),"Mouse multiplier doubles relative travel")
	check(game._scaled_pointer(Vector2(958,100),Vector2(10,0)).x==959,"Scaled cursor stays inside viewport")
	game.mouse_speed=1
	game.camera_offset=Vector2(100,0); game._update_camera()
	check(game.camera.position.x>original.x,"Locked edge offset pans view")
	game._notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not game.minimap_held and game.camera_offset==Vector2.ZERO,"Alt-tab clears temporary inspection")
	game.screen="settings"; game.ui.settings_page="options"; game.ui.show_settings()
	await process_frame
	var sliders: Array=controls(game.ui.overlay).filter(func(n): return n is HSlider)
	check(sliders.size()==3,"Only sound and camera/mouse sliders")
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
		game.open_practice(); game.practice_page="Build"; PracticeSandbox.draw(game)
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/interface-polish/practice.png")
		game.close_practice(); game.ui.update_hud(game.model)
		for reduced in [false,true]:
			game.art.reduced_effects=reduced
			await process_frame; await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://output/interface-polish/hud-%s.png"%str(reduced))
	game.queue_free(); await process_frame; await process_frame
	print("INTERFACE POLISH: %d checks, %d failures"%[checks,failures])
	quit(0 if failures==0 else 1)
