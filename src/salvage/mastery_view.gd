extends RefCounted
## One screen, one point pool. Hover/focus reveals details without moving nodes.

static func draw(ui, model: SalvageRun) -> void:
	ui._label(ui.overlay, "RUN PREVIEW" if model.mastery.read_only else "◇ %d AVAILABLE" % model.mastery.available(model.level), Rect2(47, 99, 405, 26), 17, ui.GOLD, true)
	ui._rule(Vector2(47, 131), 866)
	for branch in range(3):
		ui._label(ui.overlay, ["SALVAGE", "SURVIVAL", "OVERLOAD"][branch], Rect2(64 + branch * 194, 143, 173, 24), 12, ui.TEAL, true, HORIZONTAL_ALIGNMENT_CENTER)
	var detail := Control.new()
	detail.position = Vector2(659, 146)
	detail.size = Vector2(254, 341)
	detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.overlay.add_child(detail)
	ui._surface(ui.overlay, Rect2(639, 147, 1, 340), ui.EDGE, 0, ui.EDGE, 0)
	for id in BotMastery.NODES:
		var data: Dictionary = BotMastery.NODES[id]
		var center := Vector2(150 + data.branch * 194, 214 + data.row * 103)
		var rank_value := model.mastery.rank_of(id)
		var available := model.mastery.can_buy(id, model.level) and model.state in ["running", "upgrade", "stage_reward"]
		if not data.parent.is_empty():
			var line := Line2D.new()
			line.points = PackedVector2Array([center + Vector2(29, -103), center + Vector2(77, -103), center + Vector2(77, 0), center + Vector2(33, 0)])
			line.width = 2
			line.default_color = ui.TEAL if model.mastery.rank_of(data.parent) > 0 else ui.EDGE
			line.antialiased = true
			ui.overlay.add_child(line)
		var extent := 66 if data.row == 2 else 58
		var node: Button = ui._button("", Rect2(center - Vector2.ONE * extent / 2, Vector2.ONE * extent), func() -> void:
			ui.mastery_focus = id
			if model.mastery.buy(model, id):
				ui.show_build(model, false)
				_focus(ui, id), false)
		node.set_meta("mastery_id", id)
		node.add_theme_stylebox_override("normal", ui._style(ui.PANEL, 0, ui.GOLD if available else (ui.TEAL if rank_value > 0 else ui.EDGE), 2))
		ui._icon(node, data.icon, Rect2(5, 5, extent - 10, extent - 10), not available and rank_value == 0)
		ui._surface(node, Rect2(16, extent - 15, 36, 17), ui.INK, 0, ui.INK, 0)
		ui._label(node, "%d/%d" % [rank_value, data.max], Rect2(16, extent - 15, 36, 17), 10, ui.GOLD if available else ui.CREAM, true, HORIZONTAL_ALIGNMENT_CENTER)
		if available:
			ui._label(node, "+", Rect2(extent - 6, -9, 15, 20), 15, ui.GOLD, true)
		node.tooltip_text = "%s  %d/%d\n%s\n%s" % [data.name, rank_value, data.max, data.text, "Run preview" if model.mastery.read_only else ("Max rank" if rank_value == data.max else "1 mastery point")]
		ui._label(ui.overlay, data.name, Rect2(center.x - 93, center.y + 37, 186, 23), 13, ui.CREAM, true, HORIZONTAL_ALIGNMENT_CENTER)
		var select := func() -> void:
			ui.mastery_focus = id
			_detail(ui, model, detail, id)
		node.mouse_entered.connect(select)
		node.focus_entered.connect(select)
	_detail(ui, model, detail, ui.mastery_focus if BotMastery.NODES.has(ui.mastery_focus) else "reach")

static func _focus(ui, id: String) -> void:
	for node in ui.overlay.get_children():
		if node.get_meta("mastery_id", "") == id:
			node.grab_focus()
			return

static func _detail(ui, model: SalvageRun, panel: Control, id: String) -> void:
	for child in panel.get_children():
		panel.remove_child(child)
		child.queue_free()
	var data: Dictionary = BotMastery.NODES[id]
	var rank_value := model.mastery.rank_of(id)
	ui._icon(panel, data.icon, Rect2(0, 0, 65, 65))
	ui._label(panel, ["SALVAGE", "SURVIVAL", "OVERLOAD"][data.branch], Rect2(78, 7, 175, 20), 10, ui.TEAL, true)
	ui._label(panel, "%d / %d" % [rank_value, data.max], Rect2(78, 31, 175, 27), 20, ui.GOLD, true)
	ui._label(panel, data.name, Rect2(0, 85, 254, 31), 23, ui.CREAM, true)
	var text = ui._label(panel, data.text, Rect2(0, 130, 251, 100), 14, ui.CREAM)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var values: Dictionary = {"reach": [35, "px reach"], "learning": [10, "% bonus XP"], "fortune": [25, "% drop odds"], "hull": [1, "max hull"], "recovery": [1, "energy / sec"], "focus": [6, "% damage"]}
	var next: String = "Enabled" if rank_value == data.max else "Locked → Enabled"
	if values.has(id): next = "%d → %d %s" % [rank_value * values[id][0], mini(data.max, rank_value + 1) * values[id][0], values[id][1]]
	ui._label(panel, next, Rect2(0, 238, 254, 26), 17, ui.GOLD, true)
	var status := "MAX RANK" if rank_value == data.max else ("1 MASTERY POINT" if model.mastery.available(model.level) > 0 else "NO POINTS")
	if not data.parent.is_empty() and model.mastery.rank_of(data.parent) == 0: status = "Requires " + BotMastery.NODES[data.parent].name
	if model.mastery.read_only: status = "Earn points during a run"
	ui._label(panel, status, Rect2(0, 284, 254, 24), 12, ui.MUTED, true)
