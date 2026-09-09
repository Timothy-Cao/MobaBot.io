extends RefCounted
## Full-bleed key art; every word and control is rendered by Godot.
const BACKDROP = preload("res://assets/menu/foundry-bay-v1.png")

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
	var play := _nav(ui, "Play", Rect2(54, 229, 267, 44), func() -> void: ui.start_requested.emit("salvage"), true)
	_nav(ui, "Loadout", Rect2(54, 281, 267, 36), func() -> void: ui.loadout_requested.emit())
	_nav(ui, "Equipment", Rect2(54, 322, 267, 36), func() -> void: ui.gear_requested.emit())
	_nav(ui, "Settings", Rect2(54, 377, 122, 30), func() -> void: ui.settings_requested.emit())
	_nav(ui, "Quit", Rect2(188, 377, 132, 30), func() -> void: ui.quit_requested.emit())
	ui._label(ui.overlay, "0.15" if ui.expedition_ui else "0.13", Rect2(55, 492, 249, 20), 11, ui.MUTED, true)
	play.grab_focus()

static func _nav(ui, text: String, rect: Rect2, action: Callable, primary: bool = false) -> Button:
	var button: Button = ui._button(text, rect, action, primary)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 22 if primary else 18)
	var normal: StyleBoxFlat = ui._style(ui.GOLD if primary else Color("101f2748"), 0, ui.GOLD if primary else Color("718b8750"), 0)
	normal.content_margin_left = 18
	normal.border_width_bottom = 1
	button.add_theme_stylebox_override("normal", normal)
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color("ffe0a0") if primary else Color("29484cec")
	hover.border_width_left = 3
	hover.border_color = ui.GOLD
	button.add_theme_stylebox_override("hover", hover)
	var press: StyleBoxFlat = hover.duplicate()
	press.bg_color = ui.TEAL if primary else Color("335459")
	button.add_theme_stylebox_override("pressed", press)
	button.tooltip_text = {"Play": "Start Stage 1.", "Loadout": "Abilities, passives and key bindings.", "Equipment": "Fit, reroll and star equipment.", "Mastery": "Preview the run-only mastery tree.", "Settings": "Audio, effects, camera and controls.", "Quit": "Close MobaBot.io."}[text]
	return button
