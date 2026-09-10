extends CanvasLayer
signal keyboard_requested
var host
var system_keys: Dictionary=BotKeyboard.SYSTEM_DEFAULTS.duplicate()
var rebind_system := ""

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
signal ui_interaction(kind: String)
signal consumable_requested(index: int)

const INK := Color("14242c")
const CREAM := Color("eceddf")
const TEAL := Color("78cbb6")
const GOLD := Color("efc16b")
const CORAL := Color("ee796c")
const PANEL := Color("172a33")
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
var loadout_gallery_page := 0
var expedition_ui := false
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
var build_page := "overview"
var track_group := "skills"
var selected_item := "grinder"
var selected_rank := 1
var mini_map: Control
var settings_open := false
var settings_page := "options"
var camera_locked := true
var r_quickcast := false
var gear_selected := "coil"
var persist_equipment := true
var mastery_focus := "reach"
var heading_font := SystemFont.new()
var mission_rail: Control
var consumable_counts: Array[Label] = []
var consumable_label: Label

func _ready() -> void:
	heading_font.font_names = PackedStringArray(["Bahnschrift", "Arial"])
	heading_font.font_weight = 700
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
	# Small independent readouts leave the arena visible between them.
	_surface(hud, Rect2(12, 10, 265, 53), Color("14242cce"), 0, INK, 0)
	_surface(hud, Rect2(396, 8, 168, 48), Color("14242cc9"), 0, INK, 0)
	_surface(hud, Rect2(802, 12, 146, 31), Color("14242cce"), 0, INK, 0)
	time_label = _label(hud, "01:30", Rect2(410, 8, 140, 28), 21, CREAM, true, HORIZONTAL_ALIGNMENT_CENTER)
	stat_label = _label(hud, "", Rect2(808, 15, 130, 22), 12, CREAM, true, HORIZONTAL_ALIGNMENT_RIGHT)
	_label(hud, "HULL", Rect2(22, 15, 50, 13), 9, MUTED, true)
	health_bar = _bar(hud, Rect2(75, 18, 188, 7), TEAL, 5)
	energy_bar = _bar(hud, Rect2(75, 35, 188, 5), Color("6abbeb"), 100)
	energy_label = _label(hud, "ENERGY", Rect2(22, 30, 50, 13), 9, Color("8bccef"), true)
	stage_label = _label(hud, "", Rect2(400, 35, 160, 16), 9, MUTED, true, HORIZONTAL_ALIGNMENT_CENTER)
	mission_rail = preload("res://src/salvage/mission_rail.gd").new()
	mission_rail.position = Vector2(428, 58)
	mission_rail.size = Vector2(104, 10)
	mission_rail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(mission_rail)
	xp_bar = _bar(hud, Rect2(75, 50, 188, 3), GOLD, 1)
	_label(hud, "XP", Rect2(22, 44, 50, 13), 9, GOLD, true)
	load_label = _label(hud, "", Rect2(24, 34, 340, 18), 11, MUTED)
	help_label = _label(hud, "Wheel Zoom / S Stop / Shift + ability Aim / Hold Tab Inspect / Esc Settings", Rect2(250, 514, 678, 19), 10, CREAM, false, HORIZONTAL_ALIGNMENT_RIGHT)
	help_label.visible = false
	load_label.visible = false
	consumable_label = _label(hud, "", Rect2(887, 442, 60, 62), 11, CREAM, true)
	consumable_label.z_index = 2
	consumable_label.visible = false
	ability_bar = Control.new()
	ability_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(ability_bar)
	notice = _label(hud, "", Rect2(250, 85, 460, 30), 17, GOLD, true, HORIZONTAL_ALIGNMENT_CENTER)
	mini_map = load("res://src/salvage/mini_map.gd").new()
	mini_map.position = Vector2(18, 439)
	mini_map.size = Vector2(112, 80)
	mini_map.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(mini_map)
	threat_compass = load("res://src/salvage/threat_compass.gd").new()
	threat_compass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(threat_compass)
	damage_label = _label(hud, "", Rect2(24, 73, 430, 20), 12, Color("ee796c"), true)
	overlay = Control.new()
	overlay.z_index = 20 # Modal dimmers must cover every HUD label and item counter.
	root.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	notice_time = maxf(0, notice_time - delta)
	notice.visible = notice_time > 0

func _style(color: Color, corners: int = 8, border: Color = EDGE, width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(mini(corners, 2))
	style.set_border_width_all(width)
	style.border_color = border
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	return style

func _surface(parent: Node, rect: Rect2, color: Color = PANEL, corners: int = 8, border: Color = EDGE, width: int = 1) -> Panel:
	var panel: Panel = preload("res://src/salvage/tooltip_panel.gd").new()
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
	label.add_theme_font_override("font", heading_font if bold and size_value >= 22 else (bold_font if bold else font))
	label.add_theme_font_size_override("font_size", size_value)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = align
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.set_meta("layout_rect", rect)
	parent.add_child(label)
	label.size = rect.size
	return label

func _panel(rect: Rect2, color: Color = PANEL) -> Panel:
	var panel := _surface(overlay, rect, color, 0)
	_surface(panel, Rect2(0, 0, 38, 3), GOLD, 0, GOLD, 0)
	_surface(panel, Rect2(rect.size - Vector2(38, 3), Vector2(38, 3)), TEAL, 0, TEAL, 0)
	return panel

func _rule(point: Vector2, width: float) -> void:
	_surface(overlay, Rect2(point, Vector2(width, 1)), EDGE, 0, EDGE, 0)

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
	var button: Button = preload("res://src/salvage/tooltip_button.gd").new()
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
	button.mouse_entered.connect(func() -> void: ui_interaction.emit("ui_focus"))
	button.pressed.connect(func() -> void: ui_interaction.emit("ui_confirm"))
	button.pressed.connect(action)
	overlay.add_child(button)
	return button

func _icon(parent: Node, id: String, rect: Rect2, dim: bool = false) -> Control:
	var extent := minf(rect.size.x, rect.size.y)
	var box := Rect2(rect.position + (rect.size - Vector2.ONE * extent) * 0.5, Vector2.ONE * extent)
	var icon := _ability_icon(parent, {"bolt": "power", "repair": "pylon", "chassis-v1": "chassis", "drive-v1": "jets"}.get(id, id), box)
	if dim:
		icon.modulate = Color(0.62, 0.66, 0.68, 0.7)
	return icon

func _tab(text: String, rect: Rect2, action: Callable, selected: bool = false) -> Button:
	var button := _button(text, rect, action, false)
	var normal := _style(Color.TRANSPARENT, 0, GOLD if selected else EDGE, 0)
	normal.border_width_bottom = 3 if selected else 1
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_color_override("font_color", GOLD if selected else MUTED)
	return button

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
	if model.kit.flexible() and id in ["power","rapid","grinder","ricochet","pulse"]:
		return _ability_icon(parent,{"power":"bolt","rapid":"bolt","grinder":"orbit","ricochet":"ricochet","pulse":"pulse"}[id],rect)
	return _icon(parent, id, rect)

func show_loadout() -> void:
	settings_open = false
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
			loadout_message = "Reserved: A attack, S stop, L camera, M mute, 5/6 items."
	if settings_open: show_settings()
	else: show_loadout()

func _ability_hud(model: SalvageRun) -> void:
	ability_bar.visible = model.kit != null
	if model.kit == null:
		return
	if Vanguard.enabled(model): VanguardHud.draw(self,model); return
	if model.kit.flexible(): KeyboardView.hud(self,model); return
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
		consumable_counts.clear()
		_surface(ability_bar, Rect2(174, 434, 758, 80), Color("14242cf2"), 0)
		_label(ability_bar, "PASSIVES", Rect2(185, 439, 137, 17), 9, MUTED, true)
		for i in range(4):
			var id: String = kit.loadout.passives[i]
			var data: Dictionary = MobaKit.PASSIVES[id]
			var tile := _surface(ability_bar, Rect2(185 + i * 39, 462, 35, 43), PANEL, 0)
			tile.mouse_filter = Control.MOUSE_FILTER_STOP
			tile.tooltip_text = "[%s] %s\n%s\n%s" % [OS.get_keycode_string(kit.bindings["p%d" % (i + 1)]), data.name, data.text, "%s energy / sec" % MobaKit.UPKEEP[id] if MobaKit.UPKEEP.has(id) else "Free while enabled"]
			_icon(tile, data.icon, Rect2(1, 0, 31, 31))
			toggle_tiles.append(tile)
			toggle_labels.append(_label(tile, "", Rect2(0, 30, 35, 14), 9, TEAL, true, HORIZONTAL_ALIGNMENT_CENTER))
		for i in range(MobaKit.SLOTS.size()):
			var slot: String = MobaKit.SLOTS[i]
			var data: Dictionary = MobaKit.ABILITIES[kit.loadout[slot]]
			var x: int = [344, 419, 494, 575, 671, 731, 812][i]
			if i in [0, 3, 4, 6]:
				_label(ability_bar, {0: "ACTIVES", 3: "ULTIMATE", 4: "ESCAPES", 6: "SUMMON"}[i], Rect2(x - 1, 439, 217 if i == 0 else (125 if i == 4 else 77), 17), 9, GOLD if slot == "r" else MUTED, true, HORIZONTAL_ALIGNMENT_CENTER)
			var tile := _surface(ability_bar, Rect2(x + 8, 457, 59, 54), PANEL, 0, MobaKit.RARITY_COLORS[kit.tiers[slot]])
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
		for i in range(2):
			var item := _button("", Rect2(876, 457 + i * 27, 50, 24), func() -> void: consumable_requested.emit(i), false)
			item.reparent(ability_bar, false)
			item.set_meta("consumable_index", i)
			item.tooltip_text = "5 · Repair 2 hull" if i == 0 else "6 · Restore 50 energy"
			_label(item, str(5 + i), Rect2(2, 3, 12, 17), 10, CREAM, true)
			_icon(item, "pylon" if i == 0 else "cell", Rect2(13, 1, 21, 21))
			consumable_counts.append(_label(item, "", Rect2(35, 3, 14, 17), 10, GOLD, true, HORIZONTAL_ALIGNMENT_CENTER))
	for i in range(consumable_counts.size()): consumable_counts[i].text = str(model.consumables[i])
	for i in range(4):
		var active := kit.passive_active(kit.loadout.passives[i])
		toggle_tiles[i].modulate = Color.WHITE if active else Color(0.45, 0.48, 0.53)
		var state_text := "ON" if active else "OFF"
		if kit.onboarding and kit.loadout.passives[i] == "orbit" and active: state_text = "FAR" if kit.orbit_far else "NEAR"
		if kit.loadout.passives[i] == "lightning" and active: state_text = "FOCUS" if kit.arc_focused else "CHAIN"
		if kit.discovery and kit.loadout.passives[i] == "lightning" and active: state_text = "LONG" if kit.arc_focused else "NEAR"
		if kit.loadout.passives[i] == "converter" and active: state_text = "HULL" if kit.extra.converter_mode == 0 else "CELL"
		if kit.starting_gun and kit.loadout.passives[i] == "bolt" and active: state_text = "SNIPE" if kit.gun_sniper else "AUTO"
		if model.attacks.enabled and kit.loadout.passives[i] == "bolt":
			toggle_tiles[i].tooltip_text = "%s\n%.1f damage · %.2f shots/sec · %d range\nCycle machine gun / sniper / off. Independent of movement and S.\n2 energy/sec while powered." % ["Auto sniper" if kit.gun_sniper else "Auto machine gun", model.attacks.auto_damage(model), 1.0 / model.attacks.auto_interval(model), model.attacks.auto_range(model)]
		if not kit.unlocked("p%d" % (i + 1)): state_text = "LOCK"
		toggle_labels[i].text = "%s %s" % [OS.get_keycode_string(kit.bindings["p%d" % (i + 1)]), state_text]
		toggle_labels[i].add_theme_font_size_override("font_size", 8 if toggle_labels[i].text.length() > 6 else 9)
	for slot in MobaKit.SLOTS:
		var data: Dictionary = MobaKit.ABILITIES[kit.loadout[slot]]
		var affordable: bool = kit.energy >= kit.ability_cost(kit.loadout[slot])
		ability_shades[slot].visible = kit.charges[slot] == 0 or not affordable or not kit.unlocked(slot)
		ability_labels[slot].text = str(ceili(kit.recharge[slot])) if kit.charges[slot] == 0 else ("LOW" if not affordable else (str(kit.charges[slot]) if data.max > 1 else ""))
		ability_recharge[slot].value = kit.cooldown(slot) - kit.recharge[slot]
		if not kit.unlocked(slot): ability_labels[slot].text = "LOCK" if kit.discovery else "%ds" % ceili(kit.UNLOCKS[slot] - kit.elapsed)
		if kit.extra.recasts.has(slot):
			ability_shades[slot].visible = false
			ability_labels[slot].text = "↻ %d" % ceili(kit.extra.recasts[slot].life)
		if kit.laser_left > 0 and slot == kit.laser_slot:
			ability_labels[slot].text = "%.1f" % kit.laser_left
			ability_recharge[slot].value = kit.cooldown(slot) * kit.laser_left / 5.0

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
		stage_label.text = "%02d  %s" % [model.stage, DemoCampaign.info(model).name.to_upper()]
		if model.stage == 2 and remaining == 0: time_label.text = "HUNT"
	mission_rail.visible = model.demo_mode
	mission_rail.stage = model.stage
	mission_rail.progress = clampf(model.stage_time / maxf(1, model.encounter_seconds()), 0, 1)
	mission_rail.queue_redraw()
	if model.exp != null:
		stage_label.text = model.exp.label().to_upper()
		time_label.text = "BOSS" if model.boss_spawned else ("CLEAR" if remaining == 0 else "%02d:%02d" % [remaining / 60, remaining % 60])
		if model.exp.revised:
			if model.exp.practice: time_label.text="PRACTICE"
			elif model.exp.clear_clock>=0: time_label.text="LOOT %02d"%ceili(model.exp.clear_clock)
			elif remaining==0 and not model.boss_spawned: time_label.text="ELITE"
		mission_rail.visible = false
	energy_bar.visible = model.kit != null
	energy_label.visible = model.kit != null
	if model.kit != null:
		energy_bar.max_value = model.kit.energy_max()
		energy_bar.value = model.kit.energy
		energy_label.text = "ENERGY"
		energy_bar.tooltip_text = "%d / %d energy" % [model.kit.energy, model.kit.energy_max()]
	stat_label.text = "Power %d   ◇ %d" % [model.level, model.mastery.available(model.level)]
	stat_label.mouse_filter = Control.MOUSE_FILTER_STOP
	stat_label.tooltip_text = "Tab: Build and mastery. ◇ Available points."
	consumable_label.text = "5  +  x%d\n\n6  E  x%d" % [model.consumables[0], model.consumables[1]]
	health_bar.max_value = model.max_health()
	health_bar.value = model.health
	health_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	health_bar.tooltip_text = "%d / %d hull" % [model.health, model.max_health()]
	var previous := 0 if model.level == 1 else model.next_level - ((12 + model.level * 8) if model.staged else (8 + model.level * 4))
	xp_bar.value = clampf(float(model.total_xp - previous) / maxf(1, model.next_level - previous), 0, 1)
	load_label.text = "%d / %d tools" % [model.orbit.size(), model.capacity()] if model.mode == "salvage" else "Bolt gun only"
	if model.kit != null:
		load_label.text = ("%d / %d tools" % [model.orbit.size(), model.capacity()] if model.passive_enabled("orbit") else "4 automatic passives") + " / " + MobaKit.PETS[model.kit.loadout.pet]
	mini_map.model = model
	mini_map.queue_redraw()
	threat_compass.model = model
	threat_compass.queue_redraw()
	damage_label.text = model.last_damage
	damage_label.visible = model.time - model.last_damage_time < 2.5
	if objective_label == null:
		objective_label = _label(hud, "", Rect2(250, 62, 660, 22), 12, GOLD, true, HORIZONTAL_ALIGNMENT_RIGHT)
	objective_label.text = ""
	if model.demo_mode:
		var goal: String = DemoCampaign.info(model).goal
		if model.stage == 2: goal += " / %d of 2" % model.demo_minis_killed
		objective_label.text = "%d / 2 wardens" % model.demo_minis_killed if model.stage == 2 else ""
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
			var name_text: String = CombatReadability.enemy_name(enemy)
			var phase_text := "EXPOSED" if enemy.phase == "recover" else ("OVERCLOCKED" if enemy.enraged else "")
			boss_label.text = name_text
			if not phase_text.is_empty(): boss_label.text += " / " + phase_text
			boss_bar.max_value = enemy.max_hp
			boss_bar.value = enemy.hp

func show_home() -> void:
	settings_open = false
	clear_overlay()
	hud.visible = false
	preload("res://src/salvage/menu_view.gd").draw(self)

func show_settings() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	var focus_setting: String = focused.get_meta("setting", "") if is_instance_valid(focused) else ""
	var focus_bind: String = focused.get_meta("bind_slot", "") if is_instance_valid(focused) else ""
	settings_open = true
	clear_overlay()
	_dim()
	preload("res://src/salvage/settings_view.gd").draw(self)
	for child in overlay.get_children():
		if child is Button and ((not focus_setting.is_empty() and child.get_meta("setting", "") == focus_setting) or (not focus_bind.is_empty() and child.get_meta("bind_slot", "") == focus_bind)):
			child.grab_focus()

func show_equipment(gear, back_action: Callable) -> void:
	clear_overlay()
	hud.visible = false
	_dim()
	preload("res://src/salvage/gear_view.gd").draw(self, gear, back_action)

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
	if ReviewRules.enabled(model): ReviewView.upgrades(self,model); return
	clear_overlay()
	hud.visible = true
	notice_time = 0
	_dim()
	preload("res://src/salvage/upgrade_view.gd").draw(self, model)

func show_pause() -> void:
	clear_overlay()
	notice_time = 0
	_dim()
	_panel(Rect2(258, 108, 444, 328))
	_label(overlay, "Paused", Rect2(289, 133, 382, 42), 30, CREAM, true)
	var resume := _button("Resume", Rect2(288, 198, 384, 42), func() -> void: resume_requested.emit())
	_button("Settings", Rect2(288, 251, 384, 38), func() -> void: settings_requested.emit(), false)
	_button("Main menu", Rect2(288, 304, 384, 38), func() -> void: menu_requested.emit(), false)
	resume.grab_focus()

func show_build(model: SalvageRun, reset: bool = true) -> void:
	build_model = model
	if reset:
		build_page = "overview"
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
	_label(overlay, ("Expedition complete" if model.exp != null else ("Demo complete" if model.demo_mode else "Shift complete")) if model.state == "won" else "Destroyed", Rect2(222, 151, 516, 52), 33, CREAM, true)
	_label(overlay, "%d\nKills" % model.kills, Rect2(230, 235, 150, 64), 24, GOLD, true, HORIZONTAL_ALIGNMENT_CENTER)
	_label(overlay, "%d\nRounds" % (model.exp.route_index+(1 if model.state=="won" else 0)) if model.exp != null else "%d\nCredits" % model.coins, Rect2(405, 235, 150, 64), 24, GOLD, true, HORIZONTAL_ALIGNMENT_CENTER)
	_label(overlay, "%ds\nSurvived" % int(model.time), Rect2(580, 235, 150, 64), 24, GOLD, true, HORIZONTAL_ALIGNMENT_CENTER)
	if model.state == "lost" and not model.last_damage.is_empty():
		_label(overlay, "Final hit: " + model.last_damage, Rect2(219, 305, 522, 20), 13, CREAM, true, HORIZONTAL_ALIGNMENT_CENTER)
	var again := _button("Play again", Rect2(228, 353, 244, 44), func() -> void: restart_requested.emit())
	_button("Main menu", Rect2(488, 353, 244, 44), func() -> void: menu_requested.emit(), false)
	_button("View build", Rect2(388, 413, 184, 33), func() -> void: build_requested.emit(), false)
	if not saved: _label(overlay, "Run not saved", Rect2(610, 445, 126, 18), 10, MUTED, false, HORIZONTAL_ALIGNMENT_RIGHT)
	again.grab_focus()

func show_stage_reward(model: SalvageRun) -> void:
	clear_overlay()
	_dim()
	_label(overlay, "%s %d cleared" % ["Level" if model.demo_mode else "Stage", model.stage], Rect2(43, 65, 650, 45), 32, CREAM, true)
	_label(overlay, ("NEXT  /  %s" % DemoCampaign.LEVELS[mini(2, model.stage)].name.to_upper()) if model.demo_mode else "CACHE SECURED", Rect2(45, 116, 560, 25), 14, GOLD, true)
	var recovery := _label(overlay, "+1 hull  ·  Full energy", Rect2(624, 116, 290, 25), 14, TEAL, true, HORIZONTAL_ALIGNMENT_RIGHT)
	recovery.mouse_filter = Control.MOUSE_FILTER_STOP
	recovery.tooltip_text = "Restored after selecting a reward. Hull cannot exceed its maximum."
	for i in range(model.stage_rewards.size()):
		var reward: Dictionary = model.stage_rewards[i]
		var tier: int = reward.tier
		var color: Color = MobaKit.RARITY_COLORS[tier]
		var card := _button("", Rect2(42 + i * 298, 169, 278, 315), func() -> void: stage_reward_selected.emit(i), false)
		card.set_meta("stage_reward_card", i)
		card.add_theme_stylebox_override("normal", _style(PANEL, 0, color, 2))
		_surface(card, Rect2(1, 1, 276, 3), color, 0, color, 0)
		if i == 0: card.grab_focus()
		_label(card, MobaKit.RARITIES[tier].to_upper(), Rect2(18, 13, 216, 22), 12, color, true)
		_label(card, str(i + 1), Rect2(240, 13, 21, 22), 12, MUTED, true)
		var title := "Reactor cache"
		var description := "+20 max energy\n+2 energy / sec"
		if reward.kind == "ability":
			var id: String = model.kit.loadout[reward.slot]
			title = MobaKit.ABILITIES[id].name
			_ability_icon(card, id, Rect2(82, 49, 114, 114))
			description = "Damage  ×%.2f → ×%.2f\nRecharge  %.1fs → %.1fs" % [model.kit.damage_scale(reward.slot), model.kit.damage_scale_at(reward.slot, model.kit.ranks[reward.slot], tier), model.kit.cooldown(reward.slot), model.kit.cooldown_at(reward.slot, model.kit.ranks[reward.slot], tier)]
			if id in ["shield", "sprint", "blink", "dash", "pylon", "sacrifice"]:
				description = "Recharge  %.1fs → %.1fs" % [model.kit.cooldown(reward.slot), model.kit.cooldown_at(reward.slot, model.kit.ranks[reward.slot], tier)]
		else:
			_icon(card, "reactor", Rect2(78, 45, 122, 122))
		_label(card, title, Rect2(18, 186, 244, 28), 21, CREAM, true)
		var text := _label(card, description, Rect2(18, 230, 244, 70), 13, MUTED)
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.tooltip_text = title + "\n" + description + "\nFor the rest of this run. Costs and utility are unchanged."
