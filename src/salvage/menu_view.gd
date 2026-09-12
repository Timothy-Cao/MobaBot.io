extends RefCounted
## Full-bleed key art; every word and control is rendered by Godot.
const BACKDROP = preload("res://assets/menu/foundry-empty-v2.png")
const HOVER = preload("res://src/salvage/menu_hover.gd")

static func draw(ui: CanvasLayer) -> void:
	var art := TextureRect.new()
	art.name = "FoundryBackdrop"
	art.texture = BACKDROP
	art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.size = Vector2(960, 540)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.overlay.add_child(art)
	var robot:=Control.new(); robot.set_script(HOVER)
	robot.name="HoverBot"; robot.position=Vector2(555,75); robot.size=Vector2(286,310)
	robot.scale=Vector2.ONE*1.15
	robot.mouse_filter=Control.MOUSE_FILTER_IGNORE; robot.reduced=ui.reduced
	ui.overlay.add_child(robot)
	# Native gradient protects text without a visible seam or a boxed illustration.
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0, 0.33, 0.57, 1])
	gradient.colors = PackedColorArray([Color("09151be8"), Color("09151ba8"), Color("09151b00"), Color("09151b00")])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2.ZERO
	texture.fill_to = Vector2.RIGHT
	var shade := TextureRect.new()
	shade.texture = texture
	shade.size = Vector2(960, 540)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.overlay.add_child(shade)
	ui._label(ui.overlay, "MOBA", Rect2(53, 65, 270, 45), 35, ui.TEAL, true)
	ui._label(ui.overlay, "BOT", Rect2(48, 94, 271, 86), 76, ui.CREAM, true)
	ui._label(ui.overlay, ".io", Rect2(188, 125, 95, 49), 37, ui.GOLD, true)
	ui._label(ui.overlay,"SCRAP. UPGRADE. REPEAT.",Rect2(55,187,340,22),13,ui.GOLD,true)
	var play := _nav(ui, "Play", Rect2(54, 231, 324, 64), func() -> void: ui.start_requested.emit("salvage"), true)
	if not ui.expedition_ui: _nav(ui, "Loadout", Rect2(54, 307, 324, 52), func() -> void: ui.loadout_requested.emit())
	_nav(ui, "Equipment", Rect2(54, 307 if ui.expedition_ui else 370, 324, 52), func() -> void: ui.gear_requested.emit())
	if ui.expedition_ui: _nav(ui,"Practice",Rect2(54,370,324,52),func(): ui.host.launch_practice())
	_nav(ui, "Settings", Rect2(54, 440, 157, 38), func() -> void: ui.settings_requested.emit())
	_nav(ui, "Quit", Rect2(221, 440, 157, 38), func() -> void: ui.quit_requested.emit())
	ui._label(ui.overlay, "0.18" if ui.expedition_ui else "0.13", Rect2(55, 492, 249, 20), 11, ui.MUTED, true)
	play.grab_focus()

static func _nav(ui, text: String, rect: Rect2, action: Callable, primary: bool = false) -> Button:
	var button: Button = ui._button(text, rect, action, primary)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 26 if primary else 16 if rect.size.y<42 else 21)
	for state in ["normal","hover","pressed","focus"]:
		var style:=StyleBoxEmpty.new()
		style.content_margin_left=48 if rect.size.y<42 else 67
		style.content_margin_right=12 if rect.size.y<42 else 45
		style.content_margin_bottom=2 if state=="pressed" else 5
		button.add_theme_stylebox_override(state,style)
	var plate:=preload("res://src/salvage/menu_plate.gd").new()
	plate.primary=primary; plate.symbol=text; plate.size=rect.size
	button.add_child(plate)
	button.tooltip_text = {"Play": "Start Stage 1.", "Practice":"Test skills and spawn enemies. No saved progression.", "Loadout": "Abilities, passives and key bindings.", "Equipment": "Equip and forge." if ui.expedition_ui else "Fit, reroll and star equipment.", "Mastery": "Preview the run-only mastery tree.", "Settings": "Audio, effects, camera and controls.", "Quit": "Close MobaBot.io."}[text]
	return button
