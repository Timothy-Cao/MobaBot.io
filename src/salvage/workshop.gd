extends Node2D

@onready var art := $Artwork
@onready var sound := $Sound
@onready var ui := $Interface
var model: SalvageRun
var screen := "home"
var selected_mode := "salvage"
var seed_value := 2407
var saved_result := false
var auto_play := false
var capture_path := ""
var capture_kind := ""
var capture_requested := false
var run_frames := 0
var mute_setting := false
var reduced_setting := false
var frame_times: Array[float] = []
var quit_on_result := false
var capture_at_end := false
var previous_frame_us := 0
var peak_enemies := 0
var closing := false
var camera := Camera2D.new()
var build_return_screen := "home"
var loadout_setting := MobaKit.demo_preset()
var key_setting := MobaKit.DEFAULT_BINDS.duplicate()
var mouse_moving := false
var bot_cast_clock := 0.0
var pending_cast_slot := ""
var pending_attack := false
var zoom_value := 1.0
const MIN_ZOOM := 0.65
const MAX_ZOOM := 1.0
var tab_held := false
var settings_return_screen := "home"
var screen_seconds: Dictionary = {}
var run_wall_seconds := 0.0
var camera_locked := true
var recenter_held := false
var free_center := Vector2.ZERO
var r_quickcast := false
var persist_settings := true
var gear = preload("res://src/salvage/equipment.gd").new()
var music_player = preload("res://src/salvage/music_director.gd").new()
var gear_return := "home"

func _ready() -> void:
	get_window().title = "MobaBot.io - 0.13 Minimal UI"
	get_tree().auto_accept_quit = false
	var cursor_theme:=BotCursor.new()
	cursor_theme.host=self
	add_child(cursor_theme)
	add_child(camera)
	camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	camera.enabled = false
	_load_settings()
	gear.load_profile()
	add_child(music_player)
	ui.gear_requested.connect(_open_gear)
	ui.ui_interaction.connect(func(kind: String) -> void: sound.receive({"kind": kind}))
	ui.consumable_requested.connect(func(index: int) -> void:
		if screen == "running" and model.use_consumable(index): _drain_events())
	ui.camera_lock_changed.connect(func(value: bool) -> void:
		_set_camera_lock(value))
	ui.quickcast_changed.connect(func(value: bool) -> void:
		r_quickcast = value
		ui.r_quickcast = value
		_save_settings()
		ui.show_settings())
	ui.start_requested.connect(start_run)
	ui.upgrade_selected.connect(_choose)
	ui.resume_requested.connect(_pause_toggle)
	ui.restart_requested.connect(func() -> void: start_run(selected_mode))
	ui.menu_requested.connect(show_home)
	ui.mute_changed.connect(_set_mute)
	ui.effects_changed.connect(_set_effects)
	ui.build_requested.connect(_open_build)
	ui.build_closed.connect(_close_build)
	ui.quit_requested.connect(func() -> void: _quit_cleanly(0))
	ui.stage_reward_selected.connect(_choose_stage)
	ui.zoom_changed.connect(_set_zoom)
	ui.settings_requested.connect(_open_settings)
	ui.settings_closed.connect(_close_settings)
	ui.loadout_requested.connect(func() -> void:
		screen = "loadout"
		ui.loadout_page = "abilities"
		ui.show_loadout())
	ui.loadout_closed.connect(func() -> void:
		ui.rebind_slot = ""
		show_home())
	ui.loadout_changed.connect(func(config: Dictionary, keys: Dictionary) -> void:
		loadout_setting = config.duplicate(true)
		key_setting = keys.duplicate()
		_save_settings())
	for argument in OS.get_cmdline_user_args():
		if argument == "--autoplay":
			auto_play = true
		elif argument == "--quit-on-result":
			quit_on_result = true
		elif argument == "--capture-on-result":
			capture_at_end = true
		elif argument.begins_with("--seed="):
			seed_value = int(argument.trim_prefix("--seed="))
		elif argument.begins_with("--capture="):
			capture_path = argument.trim_prefix("--capture=")
		elif argument.begins_with("--fixture="):
			capture_kind = argument.trim_prefix("--fixture=")
	show_home()
	if auto_play:
		start_run("salvage")
	if not capture_kind.is_empty():
		_fixture(capture_kind)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and not closing:
		_quit_cleanly(0)
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT and not auto_play:
		recenter_held = false
		if screen == "build" and tab_held:
			_close_build()
		if screen == "running":
			_pause_toggle()

func _quit_cleanly(code: int) -> void:
	if closing:
		return
	closing = true
	sound.set_muted(true)
	music_player.shutdown()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit(code)

func show_home() -> void:
	art.visible = false
	tab_held = false
	mouse_moving = false
	pending_cast_slot = ""
	camera.enabled = false
	art.world_mode = false
	model = SalvageRun.new(seed_value)
	model.player = Vector2(729, 294)
	model.pickups.clear()
	model.upgrades.grinder = 1
	model.upgrades.ricochet = 1
	for slot in range(6):
		model.orbit.append({"slot": slot, "hits": 2, "cooldown": 0.0})
	for p in [Vector2(615, 216), Vector2(852, 361), Vector2(634, 378)]:
		model.spawn_enemy(p, 1 if p.x > 800 else 0)
	for enemy in model.enemies:
		enemy.warmup = 0.0
	for i in range(8):
		model._drop(Vector2(611 + i * 29, 336 + sin(i) * 20), 1)
	art.model = model
	art.effects.clear()
	screen = "home"
	ui.show_home()

func start_run(mode: String = "salvage") -> void:
	art.visible = true
	tab_held = false
	selected_mode = mode
	model = SalvageRun.new(seed_value, mode)
	model.enable_moba(MobaKit.with_starter_gun(loadout_setting), key_setting)
	model.enable_demo()
	model.kit.onboarding = true
	model.attacks.enabled = true
	model.mastery.every_level = true
	model.kit.starting_gun = true
	pending_attack = false
	model.loot_rng.seed = seed_value + 901
	gear.apply_to(model)
	free_center = model.follow_origin() + model.view_size / 2
	mouse_moving = false
	pending_cast_slot = ""
	bot_cast_clock = 1.0
	art.model = model
	art.effects.clear()
	art.shake = 0
	art.world_mode = true
	camera.enabled = true
	_update_camera()
	saved_result = false
	frame_times.clear()
	screen_seconds.clear()
	run_wall_seconds = 0
	peak_enemies = 0
	screen = "running"
	ui.show_running()
	ui.notice_time = 0
	ui.announce("Loading bay")
	model.events.clear() # Initial sector event must not overwrite the control prompt.
	ui.update_hud(model)

func _update_camera() -> void:
	if camera.enabled:
		camera.zoom = Vector2.ONE * zoom_value
		model.view_size = Vector2(960, 540) / zoom_value
		model.detached_camera = not camera_locked and not recenter_held
		if not model.detached_camera:
			free_center = model.follow_origin() + model.view_size / 2
		else:
			free_center = free_center.clamp(SalvageRun.ARENA.position + model.view_size / 2 - Vector2(48, 96) / zoom_value, SalvageRun.ARENA.end - model.view_size / 2 + Vector2(48, 200) / zoom_value)
		model.detached_origin = free_center - model.view_size / 2
		camera.position = free_center
		camera.force_update_scroll()

func _set_camera_lock(value: bool) -> void:
	camera_locked = value
	ui.camera_locked = value
	_update_camera()
	_save_settings()
	if screen == "settings": ui.show_settings()

func _open_gear() -> void:
	gear_return = screen
	_clear_held_movement()
	mouse_moving = false
	pending_cast_slot = ""
	screen = "equipment"
	ui.show_equipment(gear, func() -> void:
		show_home())

func _set_zoom(value: float, persist: bool = true) -> void:
	zoom_value = clampf(value, MIN_ZOOM, MAX_ZOOM)
	ui.zoom_value = zoom_value
	_update_camera()
	if persist:
		_save_settings()

func _open_settings() -> void:
	if screen == "settings":
		return
	if screen == "build" and tab_held:
		_close_build()
	settings_return_screen = screen
	ui.settings_in_run = screen != "home"
	ui.settings_page = "options"
	ui.rebind_slot = ""
	_clear_held_movement()
	mouse_moving = false
	pending_cast_slot = ""
	screen = "settings"
	ui.show_settings()

func _close_settings() -> void:
	if screen != "settings":
		return
	ui.rebind_slot = ""
	ui.settings_open = false
	screen = settings_return_screen
	match screen:
		"home": ui.show_home()
		"upgrade": ui.show_upgrades(model)
		"stage_reward": ui.show_stage_reward(model)
		"result": ui.show_result(model, saved_result)
		"paused": ui.show_pause()
		_: ui.show_running()

func _open_build() -> void:
	if screen == "build":
		_close_build()
		return
	build_return_screen = screen
	_clear_held_movement()
	screen = "build"
	if build_return_screen == "home":
		var preview := SalvageRun.new(seed_value)
		preview.enable_moba(loadout_setting, key_setting)
		preview.enable_demo()
		preview.mastery.read_only = true
		preview.kit.onboarding = true
		preview.attacks.enabled = true
		preview.kit.starting_gun = true
		preview.mastery.every_level = true
		preview.kit.elapsed = 120.0
		gear.apply_to(preview)
		ui.show_build(preview)
	else:
		ui.show_build(model)
	mouse_moving = false
	pending_cast_slot = ""

func _close_build() -> void:
	if screen != "build":
		return
	screen = build_return_screen
	tab_held = false
	match screen:
		"home": ui.show_home()
		"upgrade": ui.show_upgrades(model)
		"paused": ui.show_pause()
		"result": ui.show_result(model, saved_result)
		"stage_reward": ui.show_stage_reward(model)
		_: ui.show_running()

func _input(event: InputEvent) -> void:
	if screen == "build" and ui.overlay.has_node("BuildDetail") and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		ui.overlay.get_node("BuildDetail/DetailBack").pressed.emit()
		get_viewport().set_input_as_handled()
		return
	if screen == "settings" and not ui.rebind_slot.is_empty() and event is InputEventKey and event.pressed and not event.echo:
		ui.capture_binding(event.keycode)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.keycode == KEY_SPACE:
		recenter_held = event.pressed and screen == "running"
		get_viewport().set_input_as_handled()
		return
	if screen == "running" and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_A:
			pending_cast_slot = ""
			pending_attack = true
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_L:
			_set_camera_lock(not camera_locked)
			get_viewport().set_input_as_handled()
			return
		if event.keycode in [KEY_5, KEY_6]:
			model.use_consumable(event.keycode - KEY_5)
			get_viewport().set_input_as_handled()
			return
	if event is InputEventKey and event.keycode == KEY_TAB and not event.echo:
		if event.pressed and screen in ["running", "upgrade", "paused", "result", "stage_reward"]:
			_open_build()
			tab_held = true
			ui.build_page = "mastery" if model.mastery.available(model.level) > 0 else "overview"
			ui.show_build(model, false)
			get_viewport().set_input_as_handled()
			return
		elif not event.pressed and tab_held:
			_close_build()
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and screen == "running":
		pending_attack = false
		pending_cast_slot = ""
		if model.kit.laser_left > 0:
			model.kit.steer_laser(model, get_global_mouse_position())
			mouse_moving = false
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
		mouse_moving = false
	if event is InputEventKey and not event.pressed and screen == "running" and not pending_cast_slot.is_empty() and event.keycode == model.kit.bindings[pending_cast_slot] and not _confirm_cast(pending_cast_slot):
		var slot := pending_cast_slot
		pending_cast_slot = ""
		_cast_slot(slot)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if screen == "loadout" and not ui.rebind_slot.is_empty():
			ui.capture_binding(event.keycode)
			get_viewport().set_input_as_handled()
			return
		if screen == "running":
			if event.keycode == KEY_ESCAPE and pending_attack:
				pending_attack = false
				get_viewport().set_input_as_handled()
				return
			if event.keycode == KEY_ESCAPE and not pending_cast_slot.is_empty():
				pending_cast_slot = ""
				get_viewport().set_input_as_handled()
				return
			if event.keycode == KEY_S:
				pending_attack = false
				mouse_moving = false
				pending_cast_slot = ""
				model.attacks.stop(model)
				get_viewport().set_input_as_handled()
				return
			for slot in model.kit.active_slots():
				if model.kit.flexible() and not model.kit.unlocked(slot): continue
				if event.keycode == model.kit.bindings[slot]:
					pending_attack = false
					if model.kit.laser_left > 0 and slot == model.kit.laser_slot:
						model.kit.cancel_laser()
					elif (event.shift_pressed and model.kit.loadout[slot] != "laser") or _confirm_cast(slot):
						pending_cast_slot = slot
					else:
						pending_cast_slot = ""
						_cast_slot(slot)
					get_viewport().set_input_as_handled()
					return
			for i in range(model.kit.loadout.passives.size()):
				if model.kit.flexible() and not model.kit.unlocked("p%d"%(i+1)): continue
				if event.keycode == model.kit.bindings["p%d" % (i + 1)]:
					model.kit.toggle(i)
					get_viewport().set_input_as_handled()
					return

func _confirm_cast(slot: String) -> bool:
	return not r_quickcast and (model.kit.loadout[slot] == "nuke" or (MobaKit.ABILITIES[model.kit.loadout[slot]].category == "ultimate" and model.kit.loadout[slot] != "laser"))

func _cast_slot(slot: String) -> void:
	if not model.kit.cast(model, slot, get_global_mouse_position()):
		ui.announce(model.kit.last_failure)
	elif model.kit.loadout[slot] in ["lunge", "dash", "blink", "laser"] or model.kit.extra.rooted() or model.kit.dash_left > 0 or model.kit.extra.roll_left > 0:
		mouse_moving = false

func _unhandled_input(event: InputEvent) -> void:
	if screen == "running" and pending_attack and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pending_attack = false
		mouse_moving = false
		model.attacks.attack_move(model, get_global_mouse_position())
		model.emit_event("move", model.attacks.destination)
		get_viewport().set_input_as_handled()
		return
	if screen == "running" and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not pending_cast_slot.is_empty():
		var slot := pending_cast_slot
		pending_cast_slot = ""
		_cast_slot(slot)
		get_viewport().set_input_as_handled()
		return
	if screen == "running" and event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		_set_zoom(zoom_value + (0.05 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -0.05))
		get_viewport().set_input_as_handled()
		return
	if screen == "running" and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if model.kit.laser_left > 0:
			model.kit.steer_laser(model, get_global_mouse_position())
			get_viewport().set_input_as_handled()
			return
		pending_cast_slot = ""
		var target := model.attacks.closest(model, get_global_mouse_position(), false, true)
		if model.attacks.attack(model, target):
			mouse_moving = false
			get_viewport().set_input_as_handled()
			return
		mouse_moving = true
		model.command_move(get_global_mouse_position())
		model.emit_event("move", model.move_target)
		get_viewport().set_input_as_handled()
	elif screen == "running" and mouse_moving and event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		model.command_move(get_global_mouse_position())

func _physics_process(delta: float) -> void:
	if model == null:
		return
	if screen == "home":
		model.time += delta
	elif screen == "running":
		if model.kit.laser_left > 0 and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			model.kit.steer_laser(model, get_global_mouse_position())
		_pan_camera(delta)
		if model.kit.flame_left > 0:
			var facing := (get_global_mouse_position() - model.player).normalized()
			if auto_play:
				var enemy := model.nearest_enemy(model.player)
				if not enemy.is_empty(): facing = (Vector2(enemy.pos) - model.player).normalized()
			if facing != Vector2.ZERO: model.kit.flame_direction = facing
		var direction := Vector2.ZERO
		if auto_play:
			direction = _bot_direction()
			model.command_move(model.player + direction * 120)
			bot_cast_clock -= delta
			if bot_cast_clock <= 0:
				bot_cast_clock = 1.1
				var target := model.nearest_enemy(model.player)
				if not target.is_empty():
					for slot in ["q", "w", "e", "r", "t"]:
						if model.kit.laser_left <= 0: model.kit.cast(model, slot, target.pos)
					model.kit.steer_laser(model, target.pos)
				if model.boss_spawned and not model.demo_mode:
					for boss in model.enemies:
						if boss.kind == 2 and not boss.dead:
							model.command_move(boss.pos + Vector2(130, 0))
				if int(model.time) % 9 == 0:
					model.kit.cast(model, "d", model.player + direction * 150)
					model.kit.cast(model, "f", model.player + direction * 150)
		elif mouse_moving:
			model.command_move(get_global_mouse_position())
		model.step(delta, direction)
		_drain_events()
		if model.state == "upgrade":
			pending_cast_slot = ""
			if auto_play:
				_choose(0)
			else:
				_clear_held_movement()
				mouse_moving = false
				screen = "upgrade"
				ui.show_upgrades(model)
		elif model.state == "stage_reward":
			pending_cast_slot = ""
			mouse_moving = false
			if auto_play:
				_choose_stage(0)
			else:
				screen = "stage_reward"
				ui.show_stage_reward(model)
		elif model.state in ["won", "lost"]:
			pending_cast_slot = ""
			mouse_moving = false
			screen = "result"
			_save_result()
			ui.show_result(model, saved_result)
			if quit_on_result:
				if not capture_path.is_empty():
					capture_requested = true
					_capture.call_deferred()
				else:
					_quit_cleanly(0 if saved_result else 1)
	_update_camera()
	ui.update_hud(model)

func _process(delta: float) -> void:
	art.preview_attack = (pending_attack and screen == "running") or capture_kind in ["attack_orders", "coolant_trail"]
	if screen != "running": pending_attack = false
	if music_player.is_inside_tree(): music_player.update_context(screen, model, mute_setting)
	sound.set_channel(screen == "running" and model != null and model.kit != null and model.kit.laser_left > 0)
	_record_screen_time(delta)
	art.preview_slot = pending_cast_slot if screen == "running" else ""
	art.cursor_world = get_global_mouse_position()
	if capture_kind in ["aim", "motion_lowenergy", "nuke_aim"]:
		art.preview_slot = "e" if capture_kind == "nuke_aim" else "r"
		art.cursor_world = model.player + Vector2(380, -120)
	run_frames += 1
	var now := Time.get_ticks_usec()
	if screen == "running" and frame_times.size() < 20000 and previous_frame_us > 0:
		frame_times.append((now - previous_frame_us) / 1000.0)
		peak_enemies = maxi(peak_enemies, model.enemies.size())
	previous_frame_us = now
	if not capture_at_end and not capture_path.is_empty() and run_frames >= 8 and not capture_requested:
		capture_requested = true
		_capture.call_deferred()

func _record_screen_time(delta: float) -> void:
	if model == null or not model.demo_mode or saved_result or screen not in ["running", "upgrade", "stage_reward", "build", "paused", "settings"]: return
	run_wall_seconds += delta
	screen_seconds[screen] = float(screen_seconds.get(screen, 0.0)) + delta

func _drain_events() -> void:
	for event in model.events:
		art.receive(event)
		sound.receive(event)
		if event.kind == "boss":
			ui.announce("Foreman incoming")
		elif event.kind == "boss_down":
			ui.announce("Foreman destroyed  +1 hull")
		elif event.kind == "cache":
			ui.announce("Scrap cache  +8")
			sound.receive({"kind": "equipped"})
		elif event.kind == "equipped":
			if Vanguard.enabled(model): continue
			var id: String = event.id
			if not BotMastery.NODES.has(id): ui.announce(model.upgrade_data(id).name if id != "repair" else "Repaired")
		elif event.kind == "milestone":
			if Vanguard.enabled(model): continue
			ui.announce("%s / Rank %d milestone" % [model.upgrade_data(event.id).name, event.rank], 1)
		elif event.kind == "utility":
			ui.announce("Magnet +1")
		elif event.kind == "pressure_warning":
			ui.announce("Reinforcements incoming" if model.demo_mode and model.stage == 1 else "Fast pack incoming", 1)
		elif event.kind == "pressure":
			ui.announce("Surge")
		elif event.kind == "vacuum":
			ui.announce("Magnet sweep")
		elif event.kind == "energy_low":
			ui.announce("Passives offline")
		elif event.kind == "stage_start":
			ui.announce(model.exp.label() if model.exp != null else ("Level %d / %s" % [model.stage, DemoCampaign.info(model).name] if model.demo_mode else "Stage %d" % model.stage))
		elif event.kind == "demo_level":
			ui.announce(model.exp.label() if model.exp != null else "Level %d / %s" % [model.stage, DemoCampaign.info(model).name])
		elif event.kind == "demo_boss":
			ui.announce(BotExpedition.BOSSES[model.exp.stage_number()-1] if model.exp != null and event.role == "foreman" else CombatReadability.NAMES[event.role], 2)
		elif event.kind == "miniboss_down":
			ui.announce("Warden defeated" if model.exp != null else "Warden defeated / %d of 2" % model.demo_minis_killed)
		elif event.kind == "boss_phase":
			ui.announce("OVERCLOCKED", 2)
		elif event.kind == "unlock":
			var slot: String = event.slot
			var title: String = MobaKit.PASSIVES[model.kit.loadout.passives[int(slot.substr(1)) - 1]].name if slot.begins_with("p") else MobaKit.ABILITIES[model.kit.loadout[slot]].name
			ui.announce("%s  [%s]" % [title, OS.get_keycode_string(model.kit.bindings[slot])], 1)
		elif event.kind == "supply":
			if event.supply in ["coins", "speed", "reset"]:
				ui.announce({"coins": "Credits collected", "speed": "Overclock / 6 seconds", "reset": "Active skills refreshed" if model.kit.flexible() else "Q W E refreshed"}[event.supply])
	model.events.clear()

func _choose(index: int) -> void:
	if model.choose_upgrade(index):
		if ReviewRules.enabled(model) and model.state=="upgrade":
			screen="upgrade"; ui.show_upgrades(model); return
		screen = "running"
		ui.show_running()
		_drain_events()

func _choose_stage(index: int) -> void:
	if model.state == "stage_reward" and index >= 0 and index < model.stage_rewards.size():
		_bank_loot(model.stage)
	if model.choose_stage_reward(index):
		screen = "running"
		ui.show_running()
		_drain_events()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		if screen == "paused":
			_pause_toggle()
		elif screen == "equipment":
			show_home()
		elif screen == "settings":
			_close_settings()
		elif screen == "loadout":
			ui.rebind_slot = ""
			show_home()
		elif screen == "build":
			_close_build()
		elif screen == "home" and ui.settings_open:
			ui.show_home()
		else:
			_open_settings()
	elif event.keycode == KEY_M:
		_set_mute(not mute_setting)
	elif event.keycode == KEY_F2:
		_set_effects(not reduced_setting)
	elif screen == "upgrade" and event.keycode in [KEY_1, KEY_2, KEY_3]:
		_choose(event.keycode - KEY_1)
	elif screen == "stage_reward" and event.keycode in [KEY_1, KEY_2, KEY_3]:
		_choose_stage(event.keycode - KEY_1)

func _pause_toggle() -> void:
	if screen == "running":
		_clear_held_movement()
		mouse_moving = false
		pending_cast_slot = ""
		screen = "paused"
		ui.show_pause()
	elif screen == "paused":
		screen = "running"
		ui.show_running()

func _pan_camera(delta: float) -> void:
	if not camera_locked and not recenter_held:
		var cursor := get_viewport().get_mouse_position()
		if Rect2(0, 0, 960, 540).has_point(cursor):
			var pan := Vector2(float(cursor.x > 948) - float(cursor.x < 12), float(cursor.y > 528) - float(cursor.y < 12))
			free_center += pan.normalized() * 620.0 / zoom_value * delta

func _clear_held_movement() -> void:
	pending_attack = false
	# Release a steering gesture when UI takes focus, without discarding a deliberate
	# click-to-move destination. An ability dash is paused, not silently cancelled.
	if mouse_moving and model != null:
		model.stop_movement()

func _set_mute(value: bool) -> void:
	mute_setting = value
	sound.set_muted(value)
	ui.muted = value
	_save_settings()
	_refresh_settings_screen()

func _set_effects(value: bool) -> void:
	reduced_setting = value
	art.reduced_effects = value
	art.shake = 0
	ui.reduced = value
	_save_settings()
	_refresh_settings_screen()

func _refresh_settings_screen() -> void:
	if screen == "settings":
		ui.show_settings()
	elif screen == "home":
		if ui.settings_open:
			ui.show_settings()
		else:
			ui.show_home()
	elif screen == "paused":
		ui.show_pause()
	else:
		ui.announce("SOUND %s  /  EFFECTS %s" % ["OFF" if mute_setting else "ON", "REDUCED" if reduced_setting else "FULL"])

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://salvage_settings.cfg") == OK:
		mute_setting = bool(config.get_value("audio", "muted", false))
		reduced_setting = bool(config.get_value("visual", "reduced_effects", false))
		zoom_value = clampf(float(config.get_value("visual", "zoom", 1.0)), MIN_ZOOM, MAX_ZOOM)
		camera_locked = bool(config.get_value("visual", "camera_locked", true))
		r_quickcast = bool(config.get_value("moba", "r_quickcast", false))
		var loaded: Variant = config.get_value("moba", "loadout", {})
		if loaded is Dictionary: loaded = MobaKit.migrate_loadout(loaded)
		var keys: Variant = config.get_value("moba", "keys", {})
		if keys is Dictionary: keys = MobaKit.resolve_bindings(keys)
		if loaded is Dictionary: loaded = MobaKit.migrate_loadout(loaded)
		if loaded is Dictionary and MobaKit.valid_loadout(loaded) and int(config.get_value("moba", "version", 0)) >= 9:
			loadout_setting = loaded
		if keys is Dictionary and MobaKit.valid_bindings(keys):
			key_setting = MobaKit.resolve_bindings(keys)
	loadout_setting = MobaKit.with_starter_gun(loadout_setting)
	ui.zoom_value = zoom_value
	ui.camera_locked = camera_locked
	ui.r_quickcast = r_quickcast
	ui.loadout_config = loadout_setting.duplicate(true)
	ui.key_config = key_setting.duplicate()
	sound.set_muted(mute_setting)
	art.reduced_effects = reduced_setting
	ui.muted = mute_setting
	ui.reduced = reduced_setting

func _save_settings() -> void:
	if not persist_settings: return
	var config := ConfigFile.new()
	config.load("user://salvage_settings.cfg")
	config.set_value("audio", "muted", mute_setting)
	config.set_value("visual", "reduced_effects", reduced_setting)
	config.set_value("visual", "zoom", zoom_value)
	config.set_value("visual", "camera_locked", camera_locked)
	config.set_value("moba", "r_quickcast", r_quickcast)
	config.set_value("moba", "version", 13)
	config.set_value("moba", "loadout", loadout_setting)
	config.set_value("moba", "keys", key_setting)
	if config.save("user://salvage_settings.cfg") != OK:
		ui.announce("SETTINGS APPLY NOW; COULD NOT SAVE TO DISK")

func _save_result() -> void:
	if saved_result:
		return
	_bank_loot(3 if model.state == "won" else 0)
	var record := model.summary()
	var measured := frame_times.slice(mini(60, frame_times.size()))
	measured.sort()
	if not measured.is_empty():
		record.render_timing = {"frames": measured.size(), "median_ms": measured[measured.size() / 2],
			"p95_ms": measured[int(measured.size() * 0.95)], "peak_enemies": peak_enemies}
	RunDiagnostics.annotate(record,model,auto_play or not capture_kind.is_empty() or not persist_settings)
	record.equipment = gear.equipped.duplicate()
	if model.exp != null:
		record.campaign = {"round":model.exp.route_index+1,"stage":model.exp.stage_number(),"ascension":model.exp.ascension,"class":model.exp.class_id,"chests":model.exp.chests_opened}
		record.equipment = model.equipment_snapshot.duplicate(true)
	record.wall_seconds = snappedf(run_wall_seconds, 0.01)
	record.screen_seconds = screen_seconds.duplicate()
	record.timestamp = Time.get_datetime_string_from_system()
	var file := FileAccess.open("user://salvage_runs.jsonl", FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open("user://salvage_runs.jsonl", FileAccess.WRITE)
	if file != null:
		file.seek_end()
		file.store_line(JSON.stringify(record))
		file.flush()
		saved_result = file.get_error() == OK
	print("RUN_SUMMARY ", JSON.stringify(record))

func _bank_loot(completed_level: int) -> void:
	if auto_play or not capture_kind.is_empty(): return
	if gear.award(model.coins + (50 if completed_level > 0 else 0), completed_level):
		model.coins = 0
	else:
		ui.announce(gear.message, 2)

func _bot_direction() -> Vector2:
	if model.demo_mode: return DemoCampaign.test_direction(model)
	var target := Vector2(480, 300) + Vector2(cos(model.time * 0.10) * 270, sin(model.time * 0.10) * 125)
	if model.staged and model.boss_spawned:
		for enemy in model.enemies:
			if enemy.kind == 2 and not enemy.dead:
				target = enemy.pos + Vector2(110, 0)
	var desired := (target - model.player).normalized()
	for enemy in model.enemies:
		var offset := model.player - Vector2(enemy.pos)
		if offset.length() < 95:
			desired += offset.normalized() * (1.0 - offset.length() / 95.0) * 3.0
	return desired.normalized()

func _fixture(kind: String) -> void:
	ui.persist_equipment = false
	# Visual fixtures must not inherit a tester's custom loadout or bindings.
	loadout_setting = MobaKit.demo_preset()
	key_setting = MobaKit.DEFAULT_BINDS.duplicate()
	ui.loadout_config = loadout_setting.duplicate(true)
	ui.key_config = key_setting.duplicate()
	camera_locked = true
	ui.camera_locked = true
	r_quickcast = false
	ui.r_quickcast = false
	# QA images use repeatable presentation, without overwriting saved preferences.
	zoom_value = MAX_ZOOM
	ui.zoom_value = zoom_value
	art.set_process(true)
	art.reduced_effects = false
	ui.reduced = false
	if kind.ends_with("_reduced"):
		art.reduced_effects = true
		ui.reduced = true
		kind = kind.trim_suffix("_reduced")
	if kind.ends_with("_wide"):
		zoom_value = MIN_ZOOM
		kind = kind.trim_suffix("_wide")
	if kind == "home":
		return
	if kind in ["equipment", "equipment_compare", "equipment_max"]:
		if kind != "equipment":
			gear = BotEquipment.new()
			gear.credits = 1250
			gear.inventory.reactor.copies = 6
			gear.inventory.reactor.stars = 5 if kind == "equipment_max" else 2
			gear.inventory.reactor.bonus = "drop"
			gear.inventory.reactor.roll = 5
			ui.gear_selected = "reactor"
		_open_gear()
		return
	if kind == "gear":
		_open_build()
		ui.build_page = "gear"
		ui.show_build(ui.build_model, false)
		return
	if kind in ["settings", "controls"]:
		_open_settings()
		if kind == "controls":
			ui.settings_page = "controls"
			ui.show_settings()
		return
	if kind in ["loadout", "passives", "keys", "utility"]:
		screen = "loadout"
		ui.loadout_page = "abilities" if kind == "loadout" else kind
		ui.show_loadout()
		return
	start_run("salvage")
	screen = "fixture"
	ui.notice_time = 0
	model.pickups.clear()
	model.time = 48
	model.kit.elapsed = 48
	if kind in ["aim", "flame", "nuke_aim", "nuke_impact", "laser", "laser_milestone", "mastery", "rocket"]: model.kit.elapsed = 120
	model.stage_time = 48
	model.kills = 64
	model.total_xp = 81
	model.collected = 81
	model.next_level = 108
	model.level = 5
	model.upgrades.grinder = 2
	model.upgrades.pulse = 1
	model.upgrades.ricochet = 1
	model.pulse_charge = 5
	for slot in range(6):
		model.orbit.append({"slot": slot, "hits": 3, "cooldown": 0.0})
	var rng := RandomNumberGenerator.new()
	rng.seed = 8
	for i in range(36):
		var point := Vector2(rng.randf_range(70, 890), rng.randf_range(137, 462))
		if point.distance_to(model.player) > 100:
			model.spawn_enemy(point, 1 if i % 5 == 0 else 0)
	for enemy in model.enemies:
		enemy.warmup = 0.0
	model.kit.cast(model, "t", model.player + Vector2(135, -75))
	model.kit.cast(model, "q", model.player + Vector2.RIGHT * 100)
	model.command_move(model.player + Vector2(190, -50))
	if kind == "aim":
		model.enable_moba(MobaKit.preset(true))
	for i in range(24):
		model._drop(Vector2(210 + i * 20, 360 + sin(i * 0.7) * 28), 1)
	if kind in ["upgrade", "upgrade_milestone"]:
		model.state = "upgrade"
		model.offers.assign(["grinder", "ricochet", "pulse"])
		if kind == "upgrade_milestone":
			model.upgrades.skill_q = 4
			model.upgrades.skill_r = 4
			model.kit.ranks.q = 4
			model.kit.ranks.r = 4
			model.offers.assign(["skill_q", "skill_r", "reactor"])
		ui.show_upgrades(model)
	elif kind == "result":
		model.state = "won"
		model.time = 90
		ui.show_result(model)
	elif kind == "pause":
		ui.show_pause()
	elif kind in ["build", "overview", "overview_detail", "stats", "abilities", "utility_tree", "weapons", "milestone_tree"]:
		ui.show_build(model)
		if kind == "overview_detail":
			for child in ui.overlay.get_children():
				if child.get_meta("overview_slot", "") == "q": child.pressed.emit()
		if kind in ["utility_tree", "weapons", "milestone_tree"]:
			ui.build_page = "upgrades"
			ui.track_group = "utility" if kind == "utility_tree" else ("weapons" if kind == "weapons" else "skills")
			ui.selected_item = "skill_w" if kind == "milestone_tree" else ("magnet" if kind == "utility_tree" else "grinder")
			ui.selected_rank = 5
			ui.show_build(model, false)
		if kind in ["stats", "abilities"]:
			ui.build_page = kind
			ui.show_build(model, false)
	elif kind == "milestone":
		model.upgrades.skill_w = 4
		model.kit.ranks.w = 4
		model.state = "upgrade"
		model.offers.assign(["skill_w", "power", "reactor"])
		ui.show_upgrades(model)
	elif kind in ["motion_dash", "motion_lowenergy"]:
		model.enable_moba(MobaKit.preset(true), MobaKit.DEFAULT_BINDS)
		if kind == "motion_dash":
			model.kit.cast(model, "f", model.player + Vector2(400, -10))
			model.kit.move_dash(model, 0.05)
		else:
			model.kit.energy = 0
	elif kind == "motion_charger":
		model.enemies.clear()
		model.spawn_enemy(model.player + Vector2(-150, -40), 1)
		var charger: Dictionary = model.enemies.back()
		charger.warmup = 0
		charger.phase = "windup"
		charger.dir = (model.player - Vector2(charger.pos)).normalized()
	elif kind == "motion_impact":
		model.hurt_player(model.player + Vector2.LEFT * 100, "Charger charge")
		art.receive({"kind": "hurt", "pos": model.player})
		art.visual_time = 0.03
		art.set_process(false)
		model.spawn_enemy(model.player + Vector2(135, 0), 3)
		model.enemies.back().flash = 1
		model.enemies.back().warmup = 0
	elif kind in ["demo_charge", "demo_shells", "demo_recovery", "demo_level2", "wardens", "threats", "damage", "death_recap", "motion_edge", "motion_overlap"]:
		model.enemies.clear()
		model.stage = 2 if kind in ["demo_level2", "wardens", "threats"] else 3
		model.stage_time = 90
		model.boss_spawned = model.stage == 3
		DemoCampaign.spawn_special(model, "rammer" if model.stage == 2 else "foreman")
		var boss: Dictionary = model.enemies.back()
		boss.pos = model.player + Vector2(-190, -40)
		boss.warmup = 0
		boss.clock = 0
		boss.sequence = 1 if kind == "demo_shells" else 0
		DemoCampaign.enemy_step(model, boss, 0.01)
		if kind == "demo_recovery": boss.phase = "recover"
		if kind == "motion_edge":
			model.player = SalvageRun.ARENA.end - Vector2(16, 210)
			boss.pos = model.player - Vector2(120, 100)
			boss.phase = "approach"
			boss.clock = 0
			boss.sequence = 0
			DemoCampaign.enemy_step(model, boss, 0.01)
		if kind == "motion_overlap":
			model.stage = 2
			model.boss_spawned = false
			boss.role = "rammer"
			boss.phase = "approach"
			boss.pos = model.player + Vector2(600, 1000)
			DemoCampaign.spawn_special(model, "artillery")
			model.enemies.back().pos = boss.pos + Vector2(1, 1)
		if kind in ["wardens", "threats"]:
			boss.role = "rammer"
			DemoCampaign.spawn_special(model, "artillery")
			var artillery: Dictionary = model.enemies.back()
			artillery.pos = model.player + Vector2(215, -30)
			artillery.warmup = 0
			if kind == "threats":
				boss.pos = model.player + Vector2(-1200, -550)
				boss.phase = "approach"
				artillery.pos = model.player + Vector2(1200, 100)
		if kind in ["damage", "death_recap"]:
			model.health = 1 if kind == "death_recap" else 5
			model.hurt_player(model.player + Vector2(-100, -30), "Foreman charge")
		ui.show_running()
		if kind == "death_recap": ui.show_result(model)
	elif kind == "loot":
		model.loot_shower(model.player + Vector2(110, -25), 72)
		model._drop_supply(model.player + Vector2(180, -20), "energy", 18)
		model._drop_supply(model.player + Vector2(190, 15), "repair", 1)
		for i in range(12):
			model._pickup_step(1.0 / 60)
		model.spawn_enemy(model.player + Vector2(-150, -30), 3)
		model.enemies.back().warmup = 0
		model.kit.cast(model, "e", model.player)
		model.kit.cast(model, "r", model.player)
		_drain_events()
	elif kind == "world":
		var offset := Vector2(780, -390)
		model.player += offset
		for enemy in model.enemies:
			enemy.pos += offset
		for pickup in model.pickups:
			pickup.pos += offset
	elif kind == "zoom":
		zoom_value = MIN_ZOOM
	elif kind == "stage_reward":
		model.state = "stage_reward"
		model.make_stage_rewards()
		ui.show_stage_reward(model)
	_update_camera()
	ui.update_hud(model)
	if kind == "flame":
		pending_cast_slot = "w"
		model.kit.cast(model, "w", model.player + Vector2(180, -40))
	if kind in ["attack_orders", "coolant_trail"]:
		model.kit.elapsed = 120
		if kind == "coolant_trail":
			model.kit.loadout.passives[3] = "poison"
			model.kit.toggles[3] = true
			for i in range(14): model.kit.poison_trail.append({"pos": model.player + Vector2(-i * 16, sin(i * 0.3) * 42), "life": 4.0 - i * 0.1})
		var target := model.attacks.closest(model, model.player)
		model.attacks.attack(model, target)
		model.attacks.fire(model)
		model._projectile_step(0.08)
		ui.update_hud(model)
	if kind == "nuke_impact":
		model.kit.cast(model, "e", model.player + Vector2(185, -100))
		model.kit.step(model, 0.66)
		_drain_events()
	if kind in ["mastery", "tooltip"]:
		model.level = 13
		for id in ["reach", "hull", "focus", "shock"]: model.mastery.buy(model, id)
		ui.show_build(model)
		ui.build_page = "mastery"
		ui.show_build(model, false)
		if kind == "tooltip":
			var tooltip := BotTooltip.make("Static lock\nArc coil and Impact bolt briefly stun ordinary enemies. Bosses resist stuns. Requires Hot core.\n1 mastery point")
			tooltip.position = Vector2(615, 345)
			ui.overlay.add_child(tooltip)
	if kind in ["laser", "laser_milestone", "rocket"]:
		model.enemies.clear()
		DemoCampaign.spawn_special(model, "foreman")
		var boss: Dictionary = model.enemies.back()
		boss.pos = model.player + Vector2(300, -70)
		boss.warmup = 0
		boss.phase = "telegraph"
		boss.attack = "ring"
		boss.dir = Vector2.LEFT
		if kind == "laser_milestone": model.kit.ranks.r = 5
		if kind == "rocket":
			model.kit.cast(model, "q", boss.pos)
			model._projectile_step(0.18)
		else: model.kit.cast(model, "r", boss.pos)
		_drain_events()
		ui.update_hud(model)

func _capture() -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png(capture_path)
	print("CAPTURE ", capture_path, " error=", error)
	await _quit_cleanly(error)
