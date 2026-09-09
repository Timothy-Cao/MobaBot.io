extends RefCounted
## Three fast choices; detailed mechanics remain available without permanent prose.

static func draw(ui, model: SalvageRun) -> void:
	ui._label(ui.overlay, "Power up", Rect2(42, 84, 430, 42), 31, ui.CREAM, true)
	ui._label(ui.overlay, "POWER %d" % model.level, Rect2(44, 130, 275, 21), 12, ui.TEAL, true)
	var build: Button = ui._button("Build", Rect2(802, 88, 114, 32), func() -> void: ui.build_requested.emit(), false)
	build.set_meta("utility", true)
	build.tooltip_text = "Inspect build and mastery. Tab."
	if model.kit != null:
		for i in range(11):
			var tile = ui._surface(ui.overlay, Rect2(554 + i * 33, 129, 29, 29), ui.PANEL, 0)
			tile.mouse_filter = Control.MOUSE_FILTER_STOP
			if i < 4:
				var id: String = model.kit.loadout.passives[i]
				ui._icon(tile, MobaKit.PASSIVES[id].icon, Rect2(1, 1, 27, 27), not model.kit.unlocked("p%d" % (i + 1)))
				tile.tooltip_text = MobaKit.PASSIVES[id].name
			else:
				var slot: String = MobaKit.SLOTS[i - 4]
				var icon = ui._ability_icon(tile, model.kit.loadout[slot], Rect2(1, 1, 27, 27))
				if not model.kit.unlocked(slot): icon.modulate = Color("60717c")
				tile.tooltip_text = MobaKit.ABILITIES[model.kit.loadout[slot]].name
	var first: Button
	for i in range(model.offers.size()):
		var id: String = model.offers[i]
		var data: Dictionary = model.upgrade_data(id)
		var current := model.rank_of(id)
		var milestone := model.staged and id != "repair" and (current + 1) % 5 == 0
		var x := 42 + i * 298
		var card: Button = ui._button("", Rect2(x, 184, 278, 305), func() -> void: ui.upgrade_selected.emit(i), false)
		card.set_meta("upgrade_card", true)
		card.set_meta("upgrade_id", id)
		card.add_theme_stylebox_override("normal", ui._style(Color("172b34"), 0, ui.GOLD if milestone else ui.EDGE, 2 if milestone else 1))
		ui._surface(card, Rect2(1, 1, 276, 3), ui.GOLD if milestone else ui.TEAL, 0, ui.INK, 0)
		if first == null: first = card
		ui._label(card, data.tag, Rect2(18, 15, 215, 19), 10, ui.TEAL, true)
		ui._label(card, str(i + 1), Rect2(239, 12, 21, 24), 15, ui.MUTED, true, HORIZONTAL_ALIGNMENT_RIGHT)
		var icon = ui._upgrade_icon(card, model, id, Rect2(91, 45, 96, 96))
		icon.pivot_offset = icon.size * 0.5
		card.mouse_entered.connect(func() -> void:
			if not ui.reduced: icon.create_tween().tween_property(icon, "scale", Vector2.ONE * 1.04, 0.1))
		card.mouse_exited.connect(func() -> void: icon.create_tween().tween_property(icon, "scale", Vector2.ONE, 0.1))
		if milestone: ui._label(card, "MILESTONE", Rect2(18, 148, 242, 18), 11, ui.GOLD, true, HORIZONTAL_ALIGNMENT_CENTER)
		ui._label(card, data.name, Rect2(18, 174, 244, 30), 23, ui.CREAM, true, HORIZONTAL_ALIGNMENT_CENTER)
		if id != "repair": ui._pips(card, Vector2(45, 212), current, mini(10, int(data.max)), true)
		var before := model.upgrade_values(id)
		var after := model.upgrade_values(id, current + 1)
		var rows: Array[int] = [0]
		if before.size() > 1: rows.append(before.size() - 1 if id.begins_with("skill_") and not milestone else 1)
		for row in range(rows.size()):
			var index: int = rows[row]
			var next: Variant = after[index].value if id != "repair" else minf(model.max_health(), model.health + (20 if model.exp != null else 1))
			ui._label(card, before[index].label, Rect2(18, 238 + row * 28, 135, 24), 12, ui.MUTED)
			ui._label(card, "%s → %s%s" % [number(before[index].value), number(next), before[index].unit], Rect2(139, 238 + row * 28, 121, 24), 14, ui.GOLD, true, HORIZONTAL_ALIGNMENT_RIGHT)
		var details: String = data.name + "\n" + ("Rank %d → %d\n" % [current, current + 1] if id != "repair" else "")
		for row in range(before.size()): details += "%s: %s → %s%s\n" % [before[row].label, before[row].value, after[row].value if id != "repair" else minf(model.max_health(), model.health + (20 if model.exp != null else 1)), before[row].unit]
		card.tooltip_text = details + model.upgrade_note(id, current + 1)
	if first != null: first.grab_focus()

static func number(value: Variant) -> String:
	if (value is int or value is float) and is_equal_approx(value,floorf(value)): return str(int(value))
	return str(value)
