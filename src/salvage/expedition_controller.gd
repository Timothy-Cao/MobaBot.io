extends "res://src/salvage/workshop.gd"
## The expanded game entry point. Legacy workshop scene remains a regression fixture.
var collection = ForgeEquipment.new()
var fullscreen_setting := true
var pending_discovery := -1
var keyboard_target := 0
var keyboard_return := "build"
var class_choice := "ranged"
var ascension_choice := 0
var gear_slot := "helmet"
var gear_item := "courier_helmet"
var banked_camp := -1
var library_choice := ""
var practice_skill := "rocket"
var practice_enemy := "dummy"
var practice_count := 1
var practice_key := KEY_Q
var practice_rank := 1
var practice_page := "Build"
var practice_formation := "Cluster"
var practice_placing := false
var practice_slot := "q"
var volume_setting := 1.0
var camera_speed := 620.0
var mouse_speed := 1.0
var hud_scale := 0.9
var cast_quick := {"q":true,"w":true,"e":true,"r":false,"p1":true,"x1":false,"x2":false,"x3":false}
var camera_offset := Vector2.ZERO
var minimap_held := false
var pointer_warp := Vector2(-9999,-9999)
var review_tab := "Round clear"
var combat_feedback: CombatFeedback

func _ready() -> void:
	collection.load_profile()
	super._ready()
	combat_feedback=CombatFeedback.new(); combat_feedback.name="CombatFeedback"; ui.root.add_child(combat_feedback)
	combat_feedback.visible=false
	ui.expedition_ui = true
	ui.host=self
	ui.keyboard_requested.connect(open_keyboard)
	if persistent_run(): apply_fullscreen()
	if screen == "home": ui.show_home()
	select_class(class_choice)
	get_window().title="MobaBot.io · Expedition"

func select_class(id: String) -> void:
	class_choice = id
	ui.loadout_config = BotExpedition.class_loadout(id).duplicate(true)

func persistent_run() -> bool:
	if model!=null and model.exp!=null and model.exp.practice: return false
	return not auto_play and capture_kind.is_empty() and persist_settings

func start_run(mode: String="salvage") -> void:
	if auto_play or not capture_kind.is_empty(): super.start_run(mode); return
	screen="prepare"
	ExpeditionView.prepare(self)

func launch_expedition(resume: bool=false) -> void:
	if collection.blocked:
		ui.announce(collection.message,2); return
	camera_offset=Vector2.ZERO; minimap_held=false
	seed_value=int(collection.checkpoint.get("seed",2407)) if resume else int(Time.get_unix_time_from_system())%2147483647
	super.start_run("salvage")
	if resume:
		if not collection.resume_into(model): show_home(); return
		model.exp.enable_revision(model)
		banked_camp=model.exp.route_index
		# Upgrade an older stage-end checkpoint once, preserving existing stock.
		if Vanguard.enabled(model) and model.exp.is_shop(true) and model.exp.shop_stock.is_empty():
			collection.bank_camp(model,persistent_run())
		screen="camp"; ExpeditionView.camp(self)
	else:
		var expedition:=BotExpedition.new()
		expedition.start(model,class_choice,ascension_choice)
		BotKeyboard.enable(model)
		expedition.enable_revision(model)
		Vanguard.setup(model)
		ReviewRules.enable(model)
		collection.apply_to(model)
		model.health=model.max_health(); model.kit.energy=model.kit.energy_max()
		banked_camp=-1
		collection.checkpoint.clear()
		if persistent_run() and not collection.save(): ui.announce("Save unavailable; run is not protected",2)
		ui.show_running()
	free_center=model.player
	_update_camera(); ui.update_hud(model)

func confirm_new_run() -> void:
	if collection.checkpoint.is_empty(): launch_expedition(false); return
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = "Replace the saved expedition? Banked equipment stays."
	dialog.title = "New expedition"
	dialog.confirmed.connect(func() -> void: launch_expedition(false); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog); dialog.popup_centered(Vector2i(440,140))

func _physics_process(delta: float) -> void:
	if combat_feedback!=null and model!=null:
		combat_feedback.sync(model.health/maxf(1,model.max_health()),screen=="running" and model.state=="running",ui.reduced)
	_update_pointer_mode()
	_apply_hud_scale()
	if model!=null and model.kit!=null: model.kit.extra.cursor=get_global_mouse_position()
	if model!=null and model.exp!=null and model.exp.practice: delta*=model.vanguard.time_scale
	if model!=null and Vanguard.enabled(model) and screen!="running": model.vanguard.ghost=false
	art.placement_points.clear()
	if practice_placing: art.placement_points.assign(PracticeSandbox.points(self,get_global_mouse_position()))
	art.placement_radius=65 if practice_enemy=="foreman" else 36 if practice_enemy in ["rammer","artillery"] else 25
	art.placement_valid=PracticeSandbox.placement_valid(self,art.placement_points) if practice_placing else false
	super._physics_process(delta)
	if model==null or model.exp==null: return
	if screen=="result" and collection.message.begins_with("Could not save") and not ui.overlay.has_node("ExpeditionSaveError"):
		var warning: Label=ui._label(ui.overlay,collection.message,Rect2(220,449,500,21),12,ui.CORAL)
		warning.name="ExpeditionSaveError"
	if screen=="running" and model.state=="chest":
		_clear_held_movement(); screen="chest"; ExpeditionView.chest(self)
	elif screen=="running" and model.state=="camp":
		_clear_held_movement(); screen="camp"; review_tab="Round clear"
		if banked_camp!=model.exp.route_index:
			if collection.bank_camp(model,persistent_run()): banked_camp=model.exp.route_index
		ExpeditionView.camp(self)

func open_discovery() -> void:
	if Vanguard.enabled(model):
		Vanguard.progression(model); ui.update_hud(model); return
	if model.exp.pending_chests<=0: return
	model.exp.make_chest(model); model.state="chest"; screen="chest"
	ExpeditionView.chest(self)

func choose_discovery(index: int) -> void:
	if index<0 or index>=model.exp.chest_choices.size(): return
	var incoming: String=model.exp.chest_choices[index].id
	if model.kit.flexible() and BotKeyboard.learned(model.kit,incoming)=="" and not SkillLibrary.stored(model.kit,incoming) and SkillLibrary.has_space(model.kit,incoming):
		pending_discovery=index; keyboard_target=0; screen="keyboard"; KeyboardView.draw(self); return
	if not model.exp.choose_chest(model,index): return
	finish_discovery()

func finish_discovery() -> void:
	if model.state=="camp":
		collection.bank_camp(model,persistent_run()); screen="camp"; ExpeditionView.camp(self)
	else: screen="running"; ui.show_running()

func continue_expedition() -> void:
	if not collection.bank_camp(model,persistent_run()): ExpeditionView.camp(self); return
	model.exp.shop_stock.clear()
	model.exp.advance(model)
	screen="running"; ui.show_running()
	camera_offset=Vector2.ZERO; free_center=model.player; _update_camera()

func buy_review_module(slot: String) -> void:
	ReviewRules.buy_module(self,slot)
	ReviewView.camp(self)

func buy_item(index: int) -> void:
	var exp: BotExpedition=model.exp
	if model.state!="camp" or not exp.is_shop(Vanguard.enabled(model)) or index<0 or index>=exp.shop_stock.size(): return
	var id: String=exp.shop_stock[index]
	if id == "": return
	var price: int=100+ForgeEquipment.ITEMS[id].tier*100
	if exp.field_credits<price: return
	exp.field_credits-=price; exp.pending_items.append(id); exp.shop_stock[index] = ""
	if not collection.bank_camp(model,persistent_run()):
		exp.field_credits+=price; exp.pending_items.erase(id); exp.shop_stock[index] = id
	ExpeditionView.camp(self)

func _open_gear() -> void:
	gear_return = "camp" if screen == "camp" else "home"
	screen="gear"; ExpeditionView.gear(self)

func close_gear() -> void:
	if gear_return == "camp":
		if ReviewRules.enabled(model): review_tab="Round clear"
		screen = "camp"; ExpeditionView.camp(self)
	else: show_home()

func gear_action(action: String, id: String) -> void:
	if collection.transact(action,id,persistent_run()) and gear_return == "camp":
		collection.apply_to(model)
		collection.bank_camp(model,persistent_run())
	ExpeditionView.gear(self)

func _open_build() -> void:
	if ReviewRules.enabled(model) and model.state=="camp":
		review_tab="Build"; screen="camp"; ReviewView.camp(self); return
	super._open_build()

func _close_build() -> void:
	super._close_build()
	if screen=="camp":
		collection.bank_camp(model,persistent_run()); ExpeditionView.camp(self)

func _close_settings() -> void:
	super._close_settings()
	ui.rebind_system=""
	match screen:
		"chest": ExpeditionView.chest(self)
		"camp": ExpeditionView.camp(self)
		"gear": ExpeditionView.gear(self)
		"prepare": ExpeditionView.prepare(self)
		"build": ui.show_build(model,false)

func _bank_loot(completed_level: int) -> void:
	if model.exp==null: super._bank_loot(completed_level); return
	if not persistent_run(): return
	var before:=collection.snapshot()
	collection.credits=mini(10000000,collection.credits+model.coins)
	if model.state=="won": collection.unlocked_ascension=mini(5,maxi(collection.unlocked_ascension,model.exp.ascension+1))
	collection.checkpoint.clear()
	if not collection.save(): collection.restore(before); collection.message="Could not save rewards. Last checkpoint preserved."

func _input(event: InputEvent) -> void:
	if screen=="settings" and ui.rebind_system!="" and ((event is InputEventKey and event.pressed and not event.echo) or (event is InputEventMouseButton and event.pressed and ui.rebind_system=="lock")):
		var candidate: Dictionary=ui.system_keys.duplicate()
		candidate[ui.rebind_system]=event.keycode if event is InputEventKey else -int(event.button_index)
		if BotKeyboard.valid_system(candidate):
			ui.system_keys=candidate; ui.rebind_system=""; _save_settings(); ui.show_settings()
		else: ui.announce("Reserved or already assigned",1.5)
		get_viewport().set_input_as_handled(); return
	if _camera_input(event):
		get_viewport().set_input_as_handled(); return
	if model!=null and model.exp!=null and model.exp.practice and screen in ["running","practice","placement"] and event is InputEventKey and event.pressed and not event.echo:
		# Respect an explicitly rebound system action before Practice shortcuts.
		if event.keycode not in ui.system_keys.values():
			if event.keycode==KEY_C:
				model.enemies.clear(); model.hazards.clear(); model.practice_meter.clear()
				get_viewport().set_input_as_handled(); return
			if event.keycode==KEY_B:
				practice_enemy="dummy"; practice_count=1; practice_formation="Cluster"
				begin_practice_placement()
				get_viewport().set_input_as_handled(); return
	if screen=="keyboard" and event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode in BotKeyboard.GENERAL+BotKeyboard.MOVEMENT: keyboard_key(event.keycode)
			elif event.keycode==ui.system_keys.settings: close_keyboard()
		get_viewport().set_input_as_handled(); return
	event=system_event(event)
	if screen=="running" and Vanguard.enabled(model) and event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_QUOTELEFT:
		model.vanguard.gun_on=not model.vanguard.gun_on
		model.emit_event("mode_switch",model.player)
		get_viewport().set_input_as_handled(); return
	if screen=="placement":
		if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
			practice_placing=false; open_practice()
		if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_RIGHT:
			practice_placing=false; open_practice()
		return
	if Vanguard.enabled(model) and event is InputEventKey:
		if event.keycode==KEY_D and not event.pressed:
			model.vanguard.ghost=false; model.kit.sprint=0
			get_viewport().set_input_as_handled(); return
		if screen=="running" and event.pressed and not event.echo:
			for slot in Vanguard.KEYS:
				if event.keycode!=Vanguard.KEYS[slot]: continue
				if event.ctrl_pressed: Vanguard.spend(model,slot)
				elif _confirm_cast(slot) and not model.vanguard.drive_blocks(model) and model.kit.unlocked(slot): pending_attack=false; pending_cast_slot=slot
				elif event.shift_pressed and slot in ["q","w","e","f","x1","x2","x3"] and not model.vanguard.drive_blocks(model): pending_attack=false; pending_cast_slot=slot
				else:
					pending_cast_slot=""
					model.vanguard.cast(model,slot,get_global_mouse_position())
				get_viewport().set_input_as_handled(); return
	if event is InputEventKey and event.keycode==KEY_TAB:
		if event.pressed and not event.echo:
			if screen=="practice": close_practice()
			elif screen=="build": _close_build()
			elif screen in ["running","camp","paused","upgrade","result"]:
				if model.exp!=null and model.exp.practice: open_practice()
				else: _open_build()
			tab_held=false
		get_viewport().set_input_as_handled(); return
	if screen=="practice":
		if event is InputEventKey:
			if event.pressed and event.keycode==KEY_ESCAPE: close_practice()
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if screen=="chest" and event.keycode in [KEY_1,KEY_2,KEY_3]:
			choose_discovery(event.keycode-KEY_1); get_viewport().set_input_as_handled(); return
		if screen in ["prepare","camp","gear"] and event.keycode==KEY_ESCAPE:
			if screen == "gear": close_gear()
			else: show_home()
			get_viewport().set_input_as_handled(); return
		if screen=="camp" and event.keycode==KEY_TAB:
			_open_build(); get_viewport().set_input_as_handled(); return
	super._input(event)

func _unhandled_input(event: InputEvent) -> void:
	if screen=="running" and Vanguard.enabled(model) and model.vanguard.drive_blocks(model) and event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_RIGHT:
		pending_attack=false; pending_cast_slot=""; mouse_moving=true
		model.command_move(get_global_mouse_position())
		get_viewport().set_input_as_handled(); return
	if screen=="placement" and event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		if PracticeSandbox.place(self,get_global_mouse_position()) and not event.shift_pressed:
			practice_placing=false; open_practice()
		get_viewport().set_input_as_handled(); return
	if screen=="running" and Vanguard.enabled(model) and event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT and pending_cast_slot=="" and not pending_attack:
		model.vanguard.swing(model,get_global_mouse_position())
		if Vanguard.hammer_roots(model): mouse_moving=false
		get_viewport().set_input_as_handled(); return
	super._unhandled_input(event)


func open_keyboard() -> void:
	if Vanguard.enabled(model): ui.announce("Fixed Vanguard kit",1); return
	if model.exp!=null and model.exp.revised and model.state!="camp" and not model.exp.practice:
		ui.announce("Arrange at camp",1.5); return
	library_choice=""
	pending_discovery=-1; keyboard_target=0; keyboard_return=screen
	tab_held=false; _clear_held_movement(); screen="keyboard"
	KeyboardView.draw(self)

func close_keyboard() -> void:
	if pending_discovery>=0:
		pending_discovery=-1; screen="chest"; ExpeditionView.chest(self)
	else:
		screen="build"; ui.show_build(model,false)

func keyboard_key(key: int) -> void:
	if library_choice!="":
		if BotKeyboard.allowed(library_choice,key): keyboard_target=key
		KeyboardView.draw(self); return
	if pending_discovery>=0:
		if BotKeyboard.can_place(model.kit,model.exp.chest_choices[pending_discovery].id,key): keyboard_target=key
	elif keyboard_target==0: keyboard_target=key
	else:
		if not model.exp.revised or model.state=="camp" or model.exp.practice: BotKeyboard.swap(model.kit,keyboard_target,key)
		keyboard_target=0
	KeyboardView.draw(self)

func place_discovery() -> void:
	if library_choice!="":
		if SkillLibrary.equip(model,library_choice,keyboard_target): library_choice=""; keyboard_target=0; KeyboardView.draw(self)
		return
	if keyboard_target==0 or not KeyboardRewards.choose(model,pending_discovery,keyboard_target): return
	pending_discovery=-1; keyboard_target=0; finish_discovery()

func system_event(event: InputEvent) -> InputEvent:
	if event is InputEventMouseButton and screen=="running" and ui.system_keys.get("lock",KEY_L)==-int(event.button_index):
		var key:=InputEventKey.new(); key.keycode=KEY_L; key.pressed=event.pressed
		return key
	if not event is InputEventKey: return event
	var mapped: InputEventKey=event.duplicate()
	for action in BotKeyboard.SYSTEM_DEFAULTS:
		if event.keycode==ui.system_keys.get(action,BotKeyboard.SYSTEM_DEFAULTS[action]):
			mapped.keycode=BotKeyboard.SYSTEM_DEFAULTS[action]; return mapped
	if event.keycode in BotKeyboard.SYSTEM_DEFAULTS.values(): mapped.keycode=0
	return mapped

func _unhandled_key_input(event: InputEvent) -> void:
	if screen=="keyboard": return
	super._unhandled_key_input(system_event(event))

func _drain_events() -> void:
	for event in model.events:
		if combat_feedback!=null: combat_feedback.receive(event)
		if event.kind!="chest_contents" or screen!="running": continue
		var old=ui.hud.get_node_or_null("ChestReceipt")
		if old!=null: ui.hud.remove_child(old); old.queue_free()
		var receipt:=LootReceipt.new(); receipt.name="ChestReceipt"
		receipt.position=Vector2(250,78); receipt.size=Vector2(460,82)
		ui.hud.add_child(receipt); receipt.build(ui,event.receipt,true)
		var tween:=receipt.create_tween()
		tween.tween_interval(5.0); tween.tween_property(receipt,"modulate:a",0.0,0.25); tween.tween_callback(receipt.queue_free)
	super._drain_events()

func _load_settings() -> void:
	super._load_settings()
	PaintedIcons.enabled=true
	var config:=ConfigFile.new()
	if config.load("user://salvage_settings.cfg")!=OK: return
	fullscreen_setting=bool(config.get_value("visual","fullscreen",true))
	PaintedIcons.enabled=true
	volume_setting=clampf(float(config.get_value("audio","volume",1.0)),0,1)
	camera_speed=clampf(float(config.get_value("camera","speed",620.0)),200,1400)
	mouse_speed=clampf(float(config.get_value("camera","mouse_speed",1.0)),0.5,2.0)
	hud_scale=clampf(float(config.get_value("visual","hud_scale",0.9)),0.7,1.0)
	var saved_cast: Variant=config.get_value("controls","cast_quick",{})
	if saved_cast is Dictionary:
		for slot in cast_quick:
			if saved_cast.get(slot) is bool: cast_quick[slot]=saved_cast[slot]
	_apply_volume()
	var keys: Variant=config.get_value("keyboard","system",BotKeyboard.SYSTEM_DEFAULTS)
	if keys is Dictionary and BotKeyboard.valid_system(keys):
		ui.system_keys=BotKeyboard.SYSTEM_DEFAULTS.duplicate(); ui.system_keys.merge(keys,true)

func _save_settings() -> void:
	super._save_settings()
	if not persist_settings: return
	var config:=ConfigFile.new(); config.load("user://salvage_settings.cfg")
	config.set_value("visual","fullscreen",fullscreen_setting)
	config.set_value("visual","icon_skin","painted")
	config.set_value("audio","volume",volume_setting)
	config.set_value("camera","speed",camera_speed)
	config.set_value("camera","mouse_speed",mouse_speed)
	config.set_value("visual","hud_scale",hud_scale)
	config.set_value("controls","cast_quick",cast_quick)
	config.set_value("keyboard","system",ui.system_keys)
	if config.save("user://salvage_settings.cfg")!=OK: ui.announce("Could not save settings",2)

func _confirm_cast(slot: String) -> bool:
	if model!=null and Vanguard.enabled(model):
		return slot!="p1" and cast_quick.has(slot) and not cast_quick[slot]
	return super._confirm_cast(slot)

func _apply_hud_scale() -> void:
	# Scale each HUD island toward its screen anchor, never the menus or world.
	for child in ui.hud.get_children():
		if not child is Control or child==ui.threat_compass: continue
		if not child.has_meta("hud_origin"): child.set_meta("hud_origin",child.position)
		var origin: Vector2=child.get_meta("hud_origin")
		var anchor:=Vector2(0 if origin.x<300 else 960 if origin.x>700 else 480,540 if origin.y>350 or child==ui.ability_bar else 0)
		if child==ui.ability_bar: anchor=Vector2(480,540)
		child.scale=Vector2.ONE*hud_scale
		child.position=anchor+(origin-anchor)*hud_scale

func apply_fullscreen() -> void:
	get_window().mode=Window.MODE_FULLSCREEN if fullscreen_setting else Window.MODE_WINDOWED
	if not fullscreen_setting: get_window().size=Vector2i(1536,864)

func toggle_fullscreen() -> void:
	fullscreen_setting=not fullscreen_setting; apply_fullscreen(); _save_settings(); ui.show_settings()

func _apply_volume() -> void:
	AudioServer.set_bus_volume_db(0,linear_to_db(maxf(volume_setting,0.0001)))
	AudioServer.set_bus_mute(0,mute_setting or volume_setting<=0)

func set_volume(value: float) -> void:
	volume_setting=clampf(value,0,1); mute_setting=volume_setting<=0
	sound.set_muted(mute_setting); ui.muted=mute_setting
	_apply_volume(); _save_settings()

func _set_mute(value: bool) -> void:
	if not value and volume_setting<=0: volume_setting=1.0
	super._set_mute(value)
	_apply_volume()

func _update_pointer_mode() -> void:
	if DisplayServer.get_name()=="headless": return
	var confined: bool=screen=="running" and get_window().has_focus()
	var desired: int=Input.MOUSE_MODE_CONFINED if confined else Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode!=desired: Input.mouse_mode=desired; pointer_warp=Vector2(-9999,-9999)
	if screen!="running": minimap_held=false

func _camera_input(event: InputEvent) -> bool:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and not event.pressed and minimap_held:
		minimap_held=false
		if camera_locked: camera_offset=Vector2.ZERO
		_update_camera()
		return true
	if screen!="running": return false
	if event is InputEventMouseButton and ui.system_keys.get("lock",KEY_L)==-int(event.button_index): return false
	if minimap_held and not event is InputEventMouseMotion and not (event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT):
		# Inspection owns the pointer; never cast or order units into a map click.
		if event is InputEventMouseButton: return true
	var map_rect: Rect2=ui.mini_map.get_global_rect()
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed and map_rect.has_point(event.position):
		minimap_held=true; pending_attack=false; pending_cast_slot=""; mouse_moving=false
		_minimap_point(event.position)
		return true
	if event is InputEventMouseMotion:
		if Input.mouse_mode==Input.MOUSE_MODE_CONFINED and not is_equal_approx(mouse_speed,1.0):
			if event.position.distance_to(pointer_warp)<1.0:
				pointer_warp=Vector2(-9999,-9999)
			else:
				var adjusted: Vector2=_scaled_pointer(event.position,event.relative)
				pointer_warp=adjusted; get_viewport().warp_mouse(adjusted); event.position=adjusted
		if minimap_held:
			_minimap_point(event.position)
			return true
	return false

func _minimap_point(point: Vector2) -> void:
	var local_point: Vector2=ui.mini_map.get_global_transform().affine_inverse()*point-Vector2(7,7)
	var fraction: Vector2=(local_point/(ui.mini_map.size-Vector2(14,14))).clamp(Vector2.ZERO,Vector2.ONE)
	free_center=SalvageRun.ARENA.position+fraction*SalvageRun.ARENA.size
	_update_camera()

func _pan_camera(delta: float) -> void:
	if DisplayServer.get_name()!="headless" and not get_window().has_focus(): return
	_edge_pan(get_viewport().get_mouse_position(),delta)

func _scaled_pointer(point: Vector2, motion: Vector2) -> Vector2:
	return (point+motion*(mouse_speed-1.0)).clamp(Vector2.ZERO,get_viewport_rect().size-Vector2.ONE)

func _edge_pan(cursor: Vector2, delta: float) -> void:
	if camera_locked or recenter_held or minimap_held: return
	if not get_viewport_rect().has_point(cursor): return
	var extent:=get_viewport_rect().size
	var pan:=Vector2(float(cursor.x>extent.x-12)-float(cursor.x<12),float(cursor.y>extent.y-12)-float(cursor.y<12))
	free_center+=pan.normalized()*camera_speed/zoom_value*delta

func _set_camera_lock(value: bool) -> void:
	camera_offset=Vector2.ZERO
	minimap_held=false
	super._set_camera_lock(value)
	_update_pointer_mode()

func _update_camera() -> void:
	if not camera.enabled or model==null: return
	camera.zoom=Vector2.ONE*zoom_value
	model.view_size=Vector2(960,540)/zoom_value
	var follow: Vector2=model.follow_origin()+model.view_size/2
	if recenter_held and not minimap_held:
		camera_offset=Vector2.ZERO; free_center=follow
	elif camera_locked and not minimap_held:
		camera_offset=Vector2.ZERO; free_center=follow
	free_center=free_center.clamp(SalvageRun.ARENA.position+model.view_size/2-Vector2(48,96)/zoom_value,SalvageRun.ARENA.end-model.view_size/2+Vector2(48,200)/zoom_value)
	model.detached_camera=minimap_held or (not recenter_held and not camera_locked)
	model.detached_origin=free_center-model.view_size/2
	camera.position=free_center; camera.force_update_scroll()

func _notification(what: int) -> void:
	if what==MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		minimap_held=false; camera_offset=Vector2.ZERO
		if DisplayServer.get_name()!="headless": Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	super._notification(what)

func _exit_tree() -> void:
	if DisplayServer.get_name()!="headless": Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	AudioServer.set_bus_mute(0,false); AudioServer.set_bus_volume_db(0,0)

func confirm_leave() -> void:
	var dialog:=ConfirmationDialog.new(); dialog.title="Leave run?"
	dialog.dialog_text="Continue returns to the last cleared round."
	dialog.confirmed.connect(func() -> void: show_home(); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog); dialog.popup_centered(Vector2i(440,140))

func launch_practice(legacy: bool=false) -> void:
	practice_rank=1; practice_page="Build"; camera_offset=Vector2.ZERO
	seed_value=17017
	super.start_run("salvage")
	var expedition:=BotExpedition.new()
	expedition.start(model,"ranged",0)
	BotKeyboard.enable(model); expedition.enable_revision(model)
	expedition.practice=true
	if not legacy: Vanguard.setup(model,1); ReviewRules.enable(model); PracticeSandbox.terrain(model)
	PracticeSandbox.terrain(model)
	model.health=model.max_health(); model.kit.energy=model.kit.energy_max()
	model.events.clear(); ui.notice_time=0
	free_center=model.player; _update_camera()
	open_practice()
	if legacy: PracticeView.draw(self)

func open_practice() -> void:
	_clear_held_movement(); pending_cast_slot=""; pending_attack=false
	model.vanguard.ghost=false
	screen="practice"; PracticeSandbox.draw(self)

func close_practice() -> void:
	practice_placing=false
	screen="running"; model.state="running"; ui.show_running()

func begin_practice_placement() -> void:
	_clear_held_movement(); pending_attack=false; pending_cast_slot=""
	practice_placing=true; screen="placement"; ui.clear_overlay(); ui.hud.visible=true
	ui._button("Cancel placement",Rect2(26,25,180,34),func(): practice_placing=false; open_practice(),false)

func practice_reset() -> void:
	practice_clear(); model.player=Vector2(480,300); PracticeSandbox.terrain(model)
	Vanguard.setup(model,practice_rank); ReviewRules.enable(model); PracticeSandbox.terrain(model)
	model.damage_dealt.clear(); model.time=0; camera_offset=Vector2.ZERO
	free_center=model.player; _update_camera(); PracticeSandbox.draw(self)

func _clear_held_movement() -> void:
	super._clear_held_movement()
	if Vanguard.enabled(model): model.vanguard.ghost=false; model.kit.sprint=0

func practice_fit() -> void:
	var existing:=BotKeyboard.learned(model.kit,practice_skill)
	if not BotKeyboard.allowed(practice_skill,practice_key): return
	if existing!="": BotKeyboard.swap(model.kit,int(model.kit.bindings[existing]),practice_key)
	else:
		SkillLibrary.remember(model.kit,practice_skill,practice_rank)
		if not SkillLibrary.equip(model,practice_skill,practice_key): return
	var slot:=BotKeyboard.learned(model.kit,practice_skill)
	if not slot.begins_with("p"):
		model.kit.ranks[slot]=practice_rank; model.upgrades["skill_"+slot]=practice_rank
	else:
		var upgrade:=KeyboardRewards.passive_upgrade(practice_skill)
		if model.upgrades.has(upgrade): model.upgrades[upgrade]=mini(practice_rank,model.rank_limit(upgrade))
	model._sync_resource_ranks()
	PracticeView.draw(self)

func practice_spawn() -> void:
	for i in range(practice_count):
		if model.enemies.size()>=model.MAX_ENEMIES: break
		var point: Vector2=model.player+Vector2.from_angle(i*2.39996)*minf(620,230+sqrt(i)*26)
		point=point.clamp(model.ARENA.position+Vector2.ONE*40,model.ARENA.end-Vector2.ONE*40)
		point=model.kit.extra.solid_point(point,point,25)
		if RangedThreats.NAMES.has(practice_enemy): RangedThreats.spawn(model,practice_enemy,point,true)
		elif practice_enemy in ["rammer","artillery","foreman"]:
			DemoCampaign.spawn_special(model,practice_enemy); model.enemies.back().pos=point
		else: model.spawn_enemy(point,{"bumper":0,"charger":1,"tank":3,"dummy":3}.get(practice_enemy,0))
		if practice_enemy=="dummy":
			model.enemies.back()["dummy"]=true; model.enemies.back().hp=1000000.0; model.enemies.back().max_hp=1000000.0
	close_practice()

func practice_clear() -> void:
	model.practice_meter.clear()
	model.enemies.clear(); model.projectiles.clear(); model.hazards.clear(); model.pickups.clear(); model.supply_drops.clear()
	model.kit.extra.fields.clear(); model.kit.extra.summons.clear(); model.kit.extra.blades.clear()
	model.health=model.max_health(); model.kit.energy=model.kit.energy_max()
	model.kit.salvos.clear(); model.kit.zones.clear(); model.kit.poison_trail.clear(); model.kit.summon.clear()
	model.kit.cancel_laser(); model.kit.flame_left=0; model.kit.dash_left=0
	model.vanguard.clear(); model.attacks.stop(model); model.events.clear(); art.effects.clear()
	model.orbit.clear(); model.kit.extra.clear_combat(); PracticeSandbox.terrain(model)
	PracticeSandbox.draw(self)
