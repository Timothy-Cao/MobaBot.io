extends CanvasLayer

signal start_requested(mode: String)
signal upgrade_selected(index: int)
signal resume_requested
signal restart_requested
signal menu_requested
signal mute_changed(value: bool)
signal effects_changed(value: bool)
signal build_requested
signal build_closed
signal quit_requested
signal loadout_requested
signal loadout_closed
signal loadout_changed(config: Dictionary, keys: Dictionary)
signal stage_reward_selected(index: int)
signal zoom_changed(value: float)
signal settings_requested
signal settings_closed
signal camera_lock_changed(value: bool)
signal quickcast_changed(value: bool)
signal gear_requested

const INK := Color("14242c")
const CREAM := Color("eceddf")
const TEAL := Color("78cbb6")
const GOLD := Color("efc16b")
const PANEL := Color("21333d")
const EDGE := Color("425863")
const MUTED := Color("a0b3b7")
const ICON_PATH := "res://assets/upgrades/"
const BUILD_VIEW = preload("res://src/salvage/build_view.gd")
const LOADOUT_VIEW = preload("res://src/salvage/loadout_view.gd")
const GLYPH = preload("res://src/salvage/ability_glyph.gd")
const ABILITY_ICON = preload("res://src/salvage/ability_icon.gd")
var zoom_value := 1.0
var settings_in_run := false
var energy_bar: ProgressBar
var energy_label: Label
var stage_label: Label
var objective_label: Label
var boss_label: Label
var boss_bar: ProgressBar
var damage_label: Label
var threat_compass: Control
var toggle_tiles: Array[Control] = []
var toggle_labels: Array[Label] = []
var loadout_config := MobaKit.preset()
var key_config := MobaKit.DEFAULT_BINDS.duplicate()
var loadout_page := "abilities"
var loadout_slot := "q"
var passive_index := 0
var rebind_slot := ""
var loadout_message := "Applies to your next run."
var ability_bar: Control
var ability_labels: Dictionary = {}
var ability_shades: Dictionary = {}
var ability_recharge: Dictionary = {}
var bar_signature := ""
var root: Control
var overlay: Control
var hud: Control
var time_label: Label
var stat_label: Label
var health_bar: ProgressBar
var xp_bar: ProgressBar
var load_label: Label
var help_label: Label
var notice: Label
var notice_time := 0.0
var notice_priority := 0
var font := SystemFont.new()
var bold_font := SystemFont.new()
var muted := false
var reduced := false
var textures: Dictionary = {}
var build_model: SalvageRun
var build_page := "upgrades"
var track_group := "skills"
var selected_item := "grinder"
var selected_rank := 1
var mini_map: Control
var settings_open := false
var camera_locked := true
var r_quickcast := false
var gear_selected := "coil"
var consumable_label: Label

func _ready() -> void:
	font.font_names = PackedStringArray(["Segoe UI", "Arial"])
	bold_font.font_names = font.font_names
	bold_font.font_weight = 700
	root = Control.new()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud = Control.new()
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hud)
	_surface(hud, Rect2(0, 0, 960, 72), Color("14242cef"), 0, INK, 0)
	time_label = _label(hud, "01:30", Rect2(414, 10, 132, 39), 29, CREAM, true, HORIZONTAL_ALIGNMENT_CENTER)
	stat_label = _label(hud, "", Rect2(640, 16, 293, 24), 14, CREAM, true, HORIZONTAL_ALIGNMENT_RIGHT)
	_label(hud, "HULL", Rect2(24, 8, 55, 14), 9, MUTED, true)
	health_bar = _bar(hud, Rect2(85, 12, 225, 8), TEAL, 5)
	energy_bar = _bar(hud, Rect2(85, 30, 225, 6), Color("6abbeb"), 100)
	energy_label = _label(hud, "ENERGY", Rect2(24, 25, 60, 14), 9, Color("8bccef"), true)
	stage_label = _label(hud, "", Rect2(408, 41, 145, 15), 9, MUTED, true, HORIZONTAL_ALIGNMENT_CENTER)
	xp_bar = _bar(hud, Rect2(85, 46, 225, 4), GOLD, 1)
	_label(hud, "XP", Rect2(24, 41, 55, 14), 9, GOLD, true)
	load_label = _label(hud, "", Rect2(24, 34, 340, 18), 11, MUTED)
	help_label = _label(hud, "Wheel Zoom / S Stop / Shift + ability Aim / Hold Tab Inspect / Esc Settings", Rect2(250, 514, 678, 19), 10, CREAM, false, HORIZONTAL_ALIGNMENT_RIGHT)
	help_label.visible = false
	load_label.visible = false
	consumable_label = _label(hud, "", Rect2(887, 442, 60, 62), 11, CREAM, true)
	consumable_label.z_index = 2
	ability_bar = Control.new()
	ability_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(ability_bar)
	notice = _label(hud, "", Rect2(250, 85, 460, 30), 17, GOLD, true, HORIZONTAL_ALIGNMENT_CENTER)
	mini_map = load("res://src/salvage/mini_map.gd").new()
	mini_map.position = Vector2(24, 399)
	mini_map.size = Vector2(131, 94)
	mini_map.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(mini_map)
	_label(hud, "Caches / threats", Rect2(24, 376, 146, 18), 11, GOLD)
	threat_compass = load("res://src/salvage/threat_compass.gd").new()
	threat_compass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(threat_compass)
	damage_label = _label(hud, "", Rect2(24, 73, 430, 20), 12, Color("ee796c"), true)
	overlay = Control.new()
	root.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	notice_time = maxf(0, notice_time - delta)
	notice.visible = notice_time > 0

func _style(color: Color, corners: int = 8, border: Color = EDGE, width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(corners)
	style.set_border_width_all(width)
	style.border_color = border
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	return style

func _surface(parent: Node, rect: Rect2, color: Color = PANEL, corners: int = 8, border: Color = EDGE, width: int = 1) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _style(color, corners, border, width))
	parent.add_child(panel)
	return panel

func _label(parent: Node, text: String, rect: Rect2, size_value: int, color: Color, bold: bool = false, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.clip_text = true
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_override("font", bold_font if bold else font)
	label.add_theme_font_size_override("font_size", size_value)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = align
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.set_meta("layout_rect", rect)
	parent.add_child(label)
	label.size = rect.size
	return label

func _panel(rect: Rect2, color: Color = PANEL) -> Panel:
	return _surface(overlay, rect, color)

func _bar(parent: Node, rect: Rect2, color: Color, maximum: float) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = rect.position
	bar.max_value = maximum
	bar.step = 0.001
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("background", _style(Color("101f27"), 2, INK, 0))
	bar.add_theme_stylebox_override("fill", _style(color, 2, color, 0))
	parent.add_child(bar)
	bar.size = rect.size
	return bar

func _button(text: String, rect: Rect2, action: Callable, primary: bool = true) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", bold_font)
	button.add_theme_font_size_override("font_size", 16)
	for state_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(state_name, INK if primary else CREAM)
	button.add_theme_stylebox_override("normal", _style(GOLD if primary else PANEL, 6))
	button.add_theme_stylebox_override("hover", _style(Color("ffda8d") if primary else Color("2a4650"), 6, TEAL, 2))
	button.add_theme_stylebox_override("pressed", _style(TEAL if primary else Color("36545c"), 6))
	button.add_theme_stylebox_override("focus", _style(Color(0, 0, 0, 0), 6, TEAL, 2))
	button.pressed.connect(action)
	overlay.add_child(button)
	return button

func _icon(parent: Node, id: String, rect: Rect2, dim: bool = false) -> TextureRect:
	var icon := TextureRect.new()
	var asset_id: String = {"bolt": "power", "repair": "power", "reactor": "pulse", "cell": "capacity"}.get(id, id)
	var path := ICON_PATH + asset_id + ".png"
	if not textures.has(asset_id) and ResourceLoader.exists(path):
		textures[asset_id] = load(path)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	icon.texture = textures.get(asset_id)
	icon.position = rect.position
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if dim:
		icon.modulate = Color(0.62, 0.66, 0.68, 0.7)
	parent.add_child(icon)
	icon.size = rect.size
	return icon

func _pips(parent: Node, point: Vector2, rank_value: int, maximum: int, next_rank: bool = false) -> void:
	for i in range(maximum):
		var color := TEAL if i < rank_value else Color("354b54")
		if next_rank and i == rank_value:
			color = GOLD
		_surface(parent, Rect2(point + Vector2(i * 19, 0), Vector2(13, 5)), color, 2, color, 0)

func _glyph(parent: Node, id: String, rect: Rect2) -> Control:
	var glyph: Control = GLYPH.new()
	glyph.glyph = id
	glyph.position = rect.position
	glyph.size = rect.size
	glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(glyph)
	return glyph

func _ability_icon(parent: Node, id: String, rect: Rect2) -> Control:
	var icon: Control = ABILITY_ICON.new()
	icon.ability = id
	icon.position = rect.position
	icon.size = rect.size
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(icon)
	return icon

func _upgrade_icon(parent: Node, model: SalvageRun, id: String, rect: Rect2) -> Control:
	if id.begins_with("skill_"):
		return _ability_icon(parent, model.kit.loadout[id.trim_prefix("skill_")], rect)
	return _icon(parent, id, rect)

func show_loadout() -> void:
	LOADOUT_VIEW.draw(self)

func capture_binding(key: int) -> void:
	if rebind_slot.is_empty():
		return
	if key == KEY_ESCAPE:
		rebind_slot = ""
		loadout_message = "Binding cancelled."
	else:
		var next := key_config.duplicate()
		for slot in MobaKit.BIND_SLOTS:
			if next[slot] == key:
				next[slot] = key_config[rebind_slot]
		next[rebind_slot] = key
		if MobaKit.valid_bindings(next):
			key_config = next
			rebind_slot = ""
			loadout_message = "Keys updated. Applies to your next run."
			loadout_changed.emit(loadout_config, key_config)
		else:
			loadout_message = "Reserved: S stop, L camera, M mute, 5/6 items."
	show_loadout()

func _ability_hud(model: SalvageRun) -> void:
	ability_bar.visible = model.kit != null
	if model.kit == null:
		return
	var kit := model.kit
	var signature := JSON.stringify([kit.loadout, kit.bindings, kit.tiers, kit.ranks])
	if signature != bar_signature:
		bar_signature = signature
		for child in ability_bar.get_children():
			ability_bar.remove_child(child)
			child.queue_free()
		ability_labels.clear()
		ability_shades.clear()
		ability_recharge.clear()
		toggle_tiles.clear()
		toggle_labels.clear()
		_surface(ability_bar, Rect2(174, 421, 758, 87), Color("14242cf2"), 8)
		_label(ability_bar, "TOGGLES", Rect2(185, 429, 137, 17), 9, MUTED, true)
		for i in range(4):
			var id: String = kit.loadout.passives[i]
			var data: Dictionary = MobaKit.PASSIVES[id]
			var tile := _surface(ability_bar, Rect2(186 + i * 37, 451, 33, 41), PANEL, 4)
			tile.mouse_filter = Control.MOUSE_FILTER_STOP
			tile.tooltip_text = "[%s] %s\n%s\n%s" % [OS.get_keycode_string(kit.bindings["p%d" % (i + 1)]), data.name, data.text, "%s energy / sec" % MobaKit.UPKEEP[id] if MobaKit.UPKEEP.has(id) else "Free while enabled"]
			_icon(tile, data.icon, Rect2(1, 0, 31, 31))
			toggle_tiles.append(tile)
			toggle_labels.append(_label(tile, "", Rect2(0, 29, 33, 14), 8, TEAL, true, HORIZONTAL_ALIGNMENT_CENTER))
		for i in range(MobaKit.SLOTS.size()):
			var slot: String = MobaKit.SLOTS[i]
			var data: Dictionary = MobaKit.ABILITIES[kit.loadout[slot]]
			var x: int = [344, 419, 494, 575, 671, 731, 812][i]
			_label(ability_bar, ["ACTIVE", "ACTIVE", "ACTIVE", "ULTIMATE", "SPEED", "BLINK/DASH", "SUMMON"][i], Rect2(x - 1, 426, 77, 17), 8, GOLD if slot == "r" else MUTED, true, HORIZONTAL_ALIGNMENT_CENTER)
			var tile := _surface(ability_bar, Rect2(x + 8, 445, 59, 54), PANEL, 5, MobaKit.RARITY_COLORS[kit.tiers[slot]])
			if i >= 4: tile.scale = Vector2.ONE * 0.78
			tile.mouse_filter = Control.MOUSE_FILTER_STOP
			tile.tooltip_text = "%s [%s] / %s\n%s\n%.1fs per charge / max %d / %s" % [data.name, OS.get_keycode_string(kit.bindings[slot]), MobaKit.RARITIES[kit.tiers[slot]], data.text, kit.cooldown(slot), data.max, MobaKit.cost_text(kit.loadout[slot])]
			if MobaKit.deals_damage(kit.loadout[slot]):
				tile.tooltip_text += "\nDamage multiplier x%.2f" % kit.damage_scale(slot)
			_ability_icon(tile, kit.loadout[slot], Rect2(5, 1, 48, 48))
			if kit.ranks[slot] > 0:
				_label(tile, str(kit.ranks[slot]) + ("*" if kit.milestone(slot) > 0 else ""), Rect2(30, 28, 25, 16), 10, GOLD, true, HORIZONTAL_ALIGNMENT_RIGHT)
			var shade := ColorRect.new()
			shade.color = Color("0a182bbf")
			shade.size = Vector2(57, 52)
			shade.position = Vector2.ONE
			shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tile.add_child(shade)
			ability_shades[slot] = shade
			_label(tile, OS.get_keycode_string(kit.bindings[slot]), Rect2(3, 1, 25, 20), 13, CREAM, true)
			ability_labels[slot] = _label(tile, "", Rect2(7, 22, 45, 25), 17, GOLD, true, HORIZONTAL_ALIGNMENT_CENTER)
			ability_recharge[slot] = _bar(tile, Rect2(3, 49, 53, 3), TEAL, kit.cooldown(slot))
	for i in range(4):
		var active := kit.passive_active(kit.loadout.passives[i])
		toggle_tiles[i].modulate = Color.WHITE if active else Color(0.45, 0.48, 0.53)
		var state_text := "ON" if active else "OFF"
		if kit.onboarding and kit.loadout.passives[i] == "orbit" and active: state_text = "FAR" if kit.orbit_far else "NEAR"
		if not kit.unlocked("p%d" % (i + 1)): state_text = "LOCK"
		toggle_labels[i].text = "%s %s" % [OS.get_keycode_string(kit.bindings["p%d" % (i + 1)]), state_text]
	for slot in MobaKit.SLOTS:
		var data: Dictionary = MobaKit.ABILITIES[kit.loadout[slot]]
		var affordable: bool = kit.energy >= kit.ability_cost(kit.loadout[slot])
		ability_shades[slot].visible = kit.charges[slot] == 0 or not affordable or not kit.unlocked(slot)
		ability_labels[slot].text = str(ceili(kit.recharge[slot])) if kit.charges[slot] == 0 else ("LOW" if not affordable else (str(kit.charges[slot]) if data.max > 1 else ""))
		ability_recharge[slot].value = kit.cooldown(slot) - kit.recharge[slot]
		if not kit.unlocked(slot): ability_labels[slot].text = "%ds" % ceili(kit.UNLOCKS[slot] - kit.elapsed)

func clear_overlay() -> void:
	for child in overlay.get_children():
		overlay.remove_child(child)
		child.queue_free()

func _dim() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.035, 0.07, 0.10, 0.90)
	overlay.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func update_hud(model: SalvageRun) -> void:
	_ability_hud(model)
	var remaining := maxi(0, ceili(SalvageRun.DURATION - model.time))
	if model.staged:
		remaining = maxi(0, ceili(model.encounter_seconds() - model.stage_time))
	time_label.text = "%02d:%02d" % [remaining / 60, remaining % 60]
	if model.staged and model.boss_spawned:
		time_label.text = "BOSS"
	stage_label.text = "STAGE %d / %d" % [model.stage, SalvageRun.STAGE_COUNT] if model.staged else ""
	if model.demo_mode:
		stage_label.text = "STAGE 1 / LEVEL %d OF 3" % model.stage
		if model.stage == 2 and remaining == 0: time_label.text = "HUNT"
	energy_bar.visible = model.kit != null
	energy_label.visible = model.kit != null
	if model.kit != null:
		energy_bar.max_value = model.kit.energy_max()
		energy_bar.value = model.kit.energy
		energy_label.text = "ENERGY"
		energy_bar.tooltip_text = "%d / %d energy" % [model.kit.energy, model.kit.energy_max()]
	stat_label.text = "Power %d     %d kills" % [model.level, model.kills]
	consumable_label.text = "5  +  x%d\n\n6  E  x%d" % [model.consumables[0], model.consumables[1]]
	health_bar.value = model.health
	var previous := 0 if model.level == 1 else model.next_level - ((12 + model.level * 8) if model.staged else (8 + model.level * 4))
	xp_bar.value = clampf(float(model.total_xp - previous) / maxf(1, model.next_level - previous), 0, 1)
	load_label.text = "%d / %d tools" % [model.orbit.size(), model.capacity()] if model.mode == "salvage" else "Bolt gun only"
	if model.kit != null:
		load_label.text = ("%d / %d tools" % [model.orbit.size(), model.capacity()] if model.passive_enabled("orbit") else "4 automatic passives") + " / " + MobaKit.PETS[model.kit.loadout.pet]
	mini_map.model = model
	mini_map.queue_redraw()
	threat_compass.model = model
	threat_compass.queue_redraw()
	damage_label.text = "-1 hull / " + model.last_damage
	damage_label.visible = model.time - model.last_damage_time < 2.5
	if objective_label == null:
		objective_label = _label(hud, "", Rect2(250, 62, 660, 22), 12, GOLD, true, HORIZONTAL_ALIGNMENT_RIGHT)
	objective_label.text = ""
	if model.demo_mode:
		var goal: String = DemoCampaign.info(model).goal
		if model.stage == 2: goal += " / %d of 2" % model.demo_minis_killed
		objective_label.text = "%s / %s" % [DemoCampaign.info(model).name, goal]
	if boss_label == null:
		boss_label = _label(hud, "", Rect2(302, 375, 505, 21), 12, CREAM, true, HORIZONTAL_ALIGNMENT_CENTER)
		boss_bar = _bar(hud, Rect2(312, 400, 485, 5), Color("ee796c"), 1)
	boss_label.visible = false
	boss_bar.visible = false
	if model.demo_mode:
		var enemy := CombatReadability.nearest_objective(model)
		if not enemy.is_empty():
			boss_label.visible = true
			boss_bar.visible = true
			var name_text: String = {"rammer": "Ram Warden", "artillery": "Artillery Warden", "foreman": "Foreman"}[enemy.role]
			var phase_text := "EXPOSED +50% damage" if enemy.phase == "recover" else ("OVERCLOCKED" if enemy.enraged else "")
			boss_label.text = "%s / %d of %d HP" % [name_text, maxi(0, ceili(enemy.hp)), enemy.max_hp]
			if not phase_text.is_empty(): boss_label.text += " / " + phase_text
			boss_bar.max_value = enemy.max_hp
			boss_bar.value = enemy.hp

func show_home() -> void:
	settings_open = false
	clear_overlay()
	hud.visible = false
	_surface(overlay, Rect2(0, 0, 500, 540), Color("14242cf4"), 0, INK, 0)
	_label(overlay, "MOBA", Rect2(62, 80, 390, 27), 18, TEAL, true)
	_label(overlay, "BOT.io", Rect2(58, 108, 440, 70), 55, CREAM, true)
	var play := _button("Play", Rect2(64, 237, 292, 48), func() -> void: start_requested.emit("salvage"))
	_button("Loadout", Rect2(64, 298, 142, 38), func() -> void: loadout_requested.emit(), false)
	_button("Equipment", Rect2(214, 298, 142, 38), func() -> void: gear_requested.emit(), false)
	_button("Upgrades", Rect2(64, 342, 292, 38), func() -> void: build_requested.emit(), false)
	_button("Settings", Rect2(64, 386, 142, 38), func() -> void: settings_requested.emit(), false)
	_button("Quit", Rect2(214, 386, 142, 38), func() -> void: quit_requested.emit(), false)
	_label(overlay, "Right-click to move / S to stop", Rect2(65, 474, 310, 22), 12, MUTED)
	_label(overlay, "0.9", Rect2(883, 501, 40, 18), 11, MUTED, false, HORIZONTAL_ALIGNMENT_RIGHT)
	_label(overlay, "Stage 1 / Three levels / Demo", Rect2(65, 189, 386, 25), 15, GOLD)
	_icon(overlay, "grinder", Rect2(554, 78, 150, 150))
	_icon(overlay, "pulse", Rect2(788, 153, 114, 114))
	_icon(overlay, "ricochet", Rect2(790, 355, 114, 114))
	play.grab_focus()

func show_settings() -> void:
	settings_open = true
	clear_overlay()
	_dim()
	_panel(Rect2(176, 22, 608, 496))
	_label(overlay, "Settings", Rect2(204, 33, 550, 40), 28, CREAM, true)
	_settings(204, 85)
	_button("Camera: " + ("Locked" if camera_locked else "Free"), Rect2(204, 142, 260, 34), func() -> void: camera_lock_changed.emit(not camera_locked), false)
	_button("R: " + ("Quick cast" if r_quickcast else "Click to confirm"), Rect2(480, 142, 276, 34), func() -> void: quickcast_changed.emit(not r_quickcast), false)
	_label(overlay, "Camera zoom", Rect2(204, 187, 240, 23), 16, CREAM, true)
	var zoom_label := _label(overlay, "%d%%" % roundi(zoom_value * 100), Rect2(650, 187, 100, 23), 15, GOLD, true, HORIZONTAL_ALIGNMENT_RIGHT)
	var slider := HSlider.new()
	slider.position = Vector2(204, 220)
	slider.size = Vector2(552, 24)
	slider.min_value = 0.65
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = zoom_value
	slider.value_changed.connect(func(value: float) -> void:
		zoom_label.text = "%d%%" % roundi(value * 100)
		zoom_changed.emit(value))
	overlay.add_child(slider)
	_label(overlay, "Right-click move / S stop / Wheel zoom\nL toggle lock / Hold Space follow / Screen edges pan\nHold Tab inspect / Esc settings / Shift + key aim\n5 repair (+2 hull) / 6 energy (+50) / Two each per run\nR then left-click: cast / Right-click or Esc: cancel", Rect2(204, 259, 552, 125), 13, MUTED)
	if not settings_in_run:
		_button("Loadout & keybinds", Rect2(204, 393, 552, 36), func() -> void: loadout_requested.emit(), false)
	else:
		_label(overlay, "Run paused. Change loadouts from the main menu.", Rect2(204, 393, 552, 24), 13, MUTED)
	var back := _button("Back", Rect2(204, 452, 552, 38), func() -> void: settings_closed.emit())
	back.grab_focus()

func show_equipment(gear, back_action: Callable) -> void:
	clear_overlay()
	hud.visible = false
	_dim()
	_panel(Rect2(24, 24, 912, 492))
	_label(overlay, "Equipment", Rect2(46, 38, 300, 40), 28, CREAM, true)
	_label(overlay, "%d credits" % gear.credits, Rect2(585, 44, 190, 26), 17, GOLD, true, HORIZONTAL_ALIGNMENT_RIGHT)
	_button("Back", Rect2(809, 43, 104, 34), back_action, false)
	var index := 0
	for id in BotEquipment.ITEM_ORDER:
		var data: Dictionary = BotEquipment.ITEMS[id]
		var item: Dictionary = gear.inventory[id]
		var x := 46 + (index % 3) * 291
		var y := 98 + (index / 3) * 150
		var card := _button("", Rect2(x, y, 279, 138), func() -> void:
			gear_selected = id
			show_equipment(gear, back_action), false)
		card.add_theme_stylebox_override("normal", _style(PANEL, 6, GOLD if id == gear_selected else EDGE, 2 if id == gear_selected else 1))
		_icon(card, data.icon, Rect2(10, 27, 72, 76), item.copies == 0)
		_label(card, data.name, Rect2(91, 10, 177, 24), 16, CREAM, true)
		_label(card, "MK II" if id in ["reactor", "shell", "rotor"] else "MK I", Rect2(10, 6, 72, 18), 10, GOLD if id in ["reactor", "shell", "rotor"] else MUTED, true, HORIZONTAL_ALIGNMENT_CENTER)
		_label(card, "%s / %d stars / %d copies" % [data.slot, item.stars, item.copies], Rect2(91, 37, 178, 18), 10, GOLD)
		_label(card, gear.item_text(id), Rect2(91, 61, 179, 46), 10, MUTED)
		_label(card, "EQUIPPED" if id in gear.equipped.values() else ("Not owned" if item.copies == 0 else "Available"), Rect2(91, 111, 174, 17), 10, TEAL, true)
		index += 1
	var chosen: Dictionary = gear.inventory[gear_selected]
	for i in range(3):
		var action: String = ["equip", "reroll", "star"][i]
		var text_value: String = ["Equip", "Reroll / 35 credits", "Star / %d credits + %d spare" % [25 * (chosen.stars + 1), chosen.stars + 1]][i]
		var button := _button(text_value, Rect2(46 + i * 291, 406, 279, 36), func() -> void:
			gear.transact(action, gear_selected)
			show_equipment(gear, back_action), i == 0)
		button.add_theme_font_size_override("font_size", 13)
		button.disabled = chosen.copies == 0 or gear.save_blocked or (action == "star" and chosen.stars >= 5)
	_label(overlay, gear.message, Rect2(46, 453, 866, 22), 13, GOLD)
	_label(overlay, "One item per slot. Stars improve base stats; rerolls replace only the bonus. Max 5 stars.", Rect2(46, 483, 866, 18), 11, MUTED)

func _settings(x: float, y: float) -> void:
	_button("Sound: off" if muted else "Sound: on", Rect2(x, y, 185, 34), func() -> void:
		muted = not muted
		mute_changed.emit(muted), false)
	_button("Effects: low" if reduced else "Effects: full", Rect2(x + 195, y, 185, 34), func() -> void:
		reduced = not reduced
		effects_changed.emit(reduced), false)

func show_running() -> void:
	clear_overlay()
	hud.visible = true

func announce(text: String, priority: int = 0) -> void:
	if notice_time > 0 and priority < notice_priority: return
	notice.text = text
	notice_time = 2.6
	notice_priority = priority

func show_upgrades(model: SalvageRun) -> void:
	clear_overlay()
	hud.visible = true
	notice_time = 0
	_dim()
	_label(overlay, "Power up" if model.demo_mode else "Level up", Rect2(42, 81, 520, 43), 31, CREAM, true)
	_label(overlay, "Choose an upgrade", Rect2(44, 126, 520, 22), 13, MUTED)
	var build_button := _button("Build  [Tab]", Rect2(765, 94, 151, 36), func() -> void: build_requested.emit(), false)
	build_button.set_meta("utility", true)
	var first: Button
	for i in range(model.offers.size()):
		var id: String = model.offers[i]
		var data: Dictionary = model.upgrade_data(id)
		var x := 42 + i * 298
		var card := _button("", Rect2(x, 170, 278, 314), func() -> void: upgrade_selected.emit(i), false)
		card.set_meta("upgrade_card", true)
		if i == 0:
			first = card
		_label(card, data.tag, Rect2(17, 14, 218, 20), 10, TEAL, true)
		_label(card, str(i + 1), Rect2(237, 12, 23, 24), 14, MUTED, true, HORIZONTAL_ALIGNMENT_RIGHT)
		var item_art := _upgrade_icon(card, model, id, Rect2(84, 37, 110, 104))
		item_art.pivot_offset = item_art.size / 2
		card.mouse_entered.connect(func() -> void:
			if not reduced:
				item_art.create_tween().tween_property(item_art, "scale", Vector2.ONE * 1.06, 0.12))
		card.mouse_exited.connect(func() -> void:
			item_art.create_tween().tween_property(item_art, "scale", Vector2.ONE, 0.12))
		_label(card, data.name, Rect2(17, 167, 244, 28), 21, CREAM, true)
		_pips(card, Vector2(18, 201), model.rank_of(id), int(data.max), true)
		var milestone_next := model.staged and (model.rank_of(id) + 1) % 5 == 0
		_label(card, model.upgrade_note(id, model.rank_of(id) + 1) if milestone_next else ("Rank %d -> %d / %d" % [model.rank_of(id), model.rank_of(id) + 1, data.max] if model.staged and id != "repair" else data.description), Rect2(18, 214, 246, 28), 10, GOLD if milestone_next else MUTED)
		if milestone_next:
			card.add_theme_stylebox_override("normal", _style(PANEL, 8, GOLD, 2))
			_label(card, "MILESTONE", Rect2(18, 143, 242, 20), 12, GOLD, true, HORIZONTAL_ALIGNMENT_CENTER)
		var values := model.upgrade_values(id)
		var next := model.upgrade_values(id, model.rank_of(id) + 1)
		for row in range(values.size()):
			_label(card, values[row].label, Rect2(18, 247 + row * 20, 144, 22), 12, MUTED)
			var after: Variant = next[row].value if id != "repair" else mini(5, model.health + 1)
			_label(card, "%s > %s%s" % [values[row].value, after, values[row].unit], Rect2(138, 247 + row * 20, 122, 22), 13, GOLD, true, HORIZONTAL_ALIGNMENT_RIGHT)
	_label(overlay, "1 / 2 / 3  Select     Tab  Build", Rect2(42, 493, 874, 21), 12, MUTED, false, HORIZONTAL_ALIGNMENT_CENTER)
	if first:
		first.grab_focus()

func show_pause() -> void:
	clear_overlay()
	notice_time = 0
	_dim()
	_panel(Rect2(258, 108, 444, 378))
	_label(overlay, "Paused", Rect2(289, 133, 382, 42), 30, CREAM, true)
	var resume := _button("Resume", Rect2(288, 198, 384, 42), func() -> void: resume_requested.emit())
	_button("Build", Rect2(288, 251, 384, 38), func() -> void: build_requested.emit(), false)
	_button("Restart", Rect2(288, 299, 185, 36), func() -> void: restart_requested.emit(), false)
	_button("Main menu", Rect2(483, 299, 189, 36), func() -> void: menu_requested.emit(), false)
	_settings(288, 355)
	_button("Settings", Rect2(288, 406, 384, 36), func() -> void: settings_requested.emit(), false)
	resume.grab_focus()

func show_build(model: SalvageRun, reset: bool = true) -> void:
	build_model = model
	if reset:
		build_page = "upgrades"
		selected_item = "grinder" if model.mode == "salvage" else "power"
		selected_rank = mini(3, model.rank_of(selected_item) + 1)
	clear_overlay()
	hud.visible = false
	notice_time = 0
	_dim()
	BUILD_VIEW.draw(self, model)

func show_result(model: SalvageRun, saved: bool = false) -> void:
	clear_overlay()
	notice_time = 0
	_dim()
	_panel(Rect2(188, 126, 584, 353))
	_label(overlay, ("Demo complete" if model.demo_mode else "Shift complete") if model.state == "won" else "Destroyed", Rect2(222, 151, 516, 52), 33, CREAM, true)
	_label(overlay, "%d\nKills" % model.kills, Rect2(230, 235, 150, 64), 24, GOLD, true, HORIZONTAL_ALIGNMENT_CENTER)
	_label(overlay, "%d\nScrap" % model.collected, Rect2(405, 235, 150, 64), 24, GOLD, true, HORIZONTAL_ALIGNMENT_CENTER)
	_label(overlay, "%ds\nSurvived" % int(model.time), Rect2(580, 235, 150, 64), 24, GOLD, true, HORIZONTAL_ALIGNMENT_CENTER)
	if model.state == "lost" and not model.last_damage.is_empty():
		_label(overlay, "Final hit: " + model.last_damage, Rect2(219, 305, 522, 20), 13, CREAM, true, HORIZONTAL_ALIGNMENT_CENTER)
		_label(overlay, CombatReadability.hint(model.last_damage), Rect2(219, 325, 522, 20), 12, MUTED, false, HORIZONTAL_ALIGNMENT_CENTER)
	var again := _button("Play again", Rect2(228, 353, 244, 44), func() -> void: restart_requested.emit())
	_button("Main menu", Rect2(488, 353, 244, 44), func() -> void: menu_requested.emit(), false)
	_button("View build", Rect2(388, 413, 184, 33), func() -> void: build_requested.emit(), false)
	_label(overlay, "Saved locally" if saved else "Not saved", Rect2(610, 445, 126, 18), 10, MUTED, false, HORIZONTAL_ALIGNMENT_RIGHT)
	again.grab_focus()

func show_stage_reward(model: SalvageRun) -> void:
	clear_overlay()
	_dim()
	_label(overlay, "%s %d cleared" % ["Level" if model.demo_mode else "Stage", model.stage], Rect2(43, 65, 650, 45), 32, CREAM, true)
	_label(overlay, ("Next: %s / +1 hull / full energy" % DemoCampaign.LEVELS[mini(2, model.stage)].name) if model.demo_mode else "Cache secured / +1 hull / energy refilled after your choice", Rect2(45, 116, 850, 25), 14, GOLD)
	for i in range(model.stage_rewards.size()):
		var reward: Dictionary = model.stage_rewards[i]
		var tier: int = reward.tier
		var color: Color = MobaKit.RARITY_COLORS[tier]
		var card := _button("", Rect2(42 + i * 298, 169, 278, 315), func() -> void: stage_reward_selected.emit(i), false)
		card.add_theme_stylebox_override("normal", _style(PANEL, 8, color, 2))
		_label(card, MobaKit.RARITIES[tier].to_upper(), Rect2(18, 13, 216, 22), 12, color, true)
		_label(card, str(i + 1), Rect2(240, 13, 21, 22), 12, MUTED, true)
		var title := "Reactor cache"
		var description := "+20 maximum energy\n+2 energy regeneration / sec\nFor the rest of this run."
		if reward.kind == "ability":
			var id: String = model.kit.loadout[reward.slot]
			title = MobaKit.ABILITIES[id].name
			_ability_icon(card, id, Rect2(82, 49, 114, 114))
			description = "%s -> %s\nDamage x%.2f -> x%.2f\nRecharge %.1fs -> %.1fs" % [MobaKit.RARITIES[tier - 1], MobaKit.RARITIES[tier], model.kit.damage_scale(reward.slot), (1 + tier * 0.15) * (1 + SalvageProgression.bonus(model.kit.ranks[reward.slot])), model.kit.cooldown(reward.slot), model.kit.cooldown_at(reward.slot, model.kit.ranks[reward.slot], tier)]
			if id in ["shield", "sprint", "blink", "dash", "pylon", "sacrifice"]:
				description = "%s -> %s\nRecharge %.1fs -> %.1fs\nCosts and utility stay unchanged." % [MobaKit.RARITIES[tier - 1], MobaKit.RARITIES[tier], model.kit.cooldown(reward.slot), model.kit.cooldown_at(reward.slot, model.kit.ranks[reward.slot], tier)]
		else:
			_icon(card, "reactor", Rect2(78, 45, 122, 122))
		_label(card, title, Rect2(18, 186, 244, 28), 21, CREAM, true)
		var text := _label(card, description, Rect2(18, 230, 244, 70), 13, MUTED)
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
