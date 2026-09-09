extends RefCounted
const SCHEMATIC = preload("res://src/salvage/workshop_schematic.gd")
const NAMES := {"damage": "Ability damage", "energy": "Max energy", "speed": "Move speed", "regen": "Energy / sec", "drop": "Bonus drops"}

static func draw(ui, gear: BotEquipment, back_action: Callable) -> void:
	ui._panel(Rect2(24, 24, 912, 492))
	ui._label(ui.overlay, "Equipment", Rect2(46, 38, 300, 40), 28, ui.CREAM, true)
	ui._label(ui.overlay, "%d credits" % gear.credits, Rect2(586, 45, 189, 24), 16, ui.GOLD, true, HORIZONTAL_ALIGNMENT_RIGHT)
	ui._button("Back", Rect2(810, 43, 102, 34), back_action, false)
	ui._rule(Vector2(46, 87), 866)
	var data: Dictionary = BotEquipment.ITEMS[ui.gear_selected]
	var chosen: Dictionary = gear.inventory[ui.gear_selected]
	ui._label(ui.overlay, "ASSEMBLY", Rect2(46, 103, 280, 20), 12, ui.TEAL, true)
	var schematic := SCHEMATIC.new()
	schematic.position = Vector2(81, 129)
	schematic.size = Vector2(215, 212)
	schematic.highlighted = data.slot
	schematic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.overlay.add_child(schematic)
	for i in range(3):
		var slot: String = ["Core", "Chassis", "Drive"][i]
		var id: String = gear.equipped[slot]
		var y := 352 + i * 43
		var tile: Button = ui._button("", Rect2(46, y, 280, 38), func() -> void:
			ui.gear_selected = id
			ui.show_equipment(gear, back_action), false)
		tile.set_meta("fitted_slot", slot)
		ui._icon(tile, BotEquipment.ITEMS[id].icon, Rect2(3, 3, 32, 32))
		ui._label(tile, slot.to_upper(), Rect2(43, 2, 151, 15), 9, ui.TEAL, true)
		ui._label(tile, BotEquipment.ITEMS[id].name, Rect2(43, 15, 171, 22), 13, ui.CREAM, true)
		ui._label(tile, "★%d" % gear.inventory[id].stars, Rect2(225, 9, 46, 20), 12, ui.GOLD, true, HORIZONTAL_ALIGNMENT_RIGHT)
		tile.tooltip_text = gear.item_text(id)
	ui._surface(ui.overlay, Rect2(345, 103, 1, 371), ui.EDGE, 0, ui.EDGE, 0)
	ui._label(ui.overlay, "COLLECTION", Rect2(367, 103, 220, 20), 12, ui.TEAL, true)
	var order := ["coil", "reactor", "rack", "shell", "jets", "rotor"]
	for i in range(6):
		var id: String = order[i]
		var item: Dictionary = gear.inventory[id]
		var x := 367 + (i % 2) * 108
		var y := 148 + (i / 2) * 112
		if i % 2 == 0: ui._label(ui.overlay, BotEquipment.ITEMS[id].slot.to_upper(), Rect2(x, y - 21, 200, 18), 10, ui.MUTED, true)
		var tile: Button = ui._button("", Rect2(x, y, 92, 83), func() -> void:
			ui.gear_selected = id
			ui.show_equipment(gear, back_action), false)
		tile.set_meta("equipment_id", id)
		tile.add_theme_stylebox_override("normal", ui._style(ui.PANEL, 0, ui.GOLD if id == ui.gear_selected else ui.EDGE, 2 if id == ui.gear_selected else 1))
		ui._icon(tile, BotEquipment.ITEMS[id].icon, Rect2(16, 5, 59, 59), item.copies == 0)
		ui._label(tile, "II" if i % 2 else "I", Rect2(5, 3, 24, 18), 10, ui.GOLD, true)
		ui._label(tile, "FITTED" if id in gear.equipped.values() else ("—" if item.copies == 0 else "OWNED"), Rect2(6, 64, 57, 15), 9, ui.TEAL if id in gear.equipped.values() else ui.MUTED, true)
		ui._label(tile, "x%d" % item.copies, Rect2(61, 64, 27, 15), 10, ui.CREAM, true, HORIZONTAL_ALIGNMENT_RIGHT)
		tile.tooltip_text = BotEquipment.ITEMS[id].name + "\n" + gear.item_text(id)
	ui._surface(ui.overlay, Rect2(603, 103, 1, 371), ui.EDGE, 0, ui.EDGE, 0)
	ui._icon(ui.overlay, data.icon, Rect2(710, 101, 88, 88), chosen.copies == 0)
	ui._label(ui.overlay, data.name, Rect2(623, 190, 290, 30), 23, ui.CREAM, true, HORIZONTAL_ALIGNMENT_CENTER)
	ui._label(ui.overlay, "★".repeat(chosen.stars) + "☆".repeat(5 - chosen.stars), Rect2(623, 221, 290, 24), 16, ui.GOLD, true, HORIZONTAL_ALIGNMENT_CENTER)
	var lines: PackedStringArray = gear.item_text(ui.gear_selected).split("\n")
	ui._label(ui.overlay, "BASE", Rect2(625, 258, 58, 20), 10, ui.MUTED, true)
	ui._label(ui.overlay, lines[0], Rect2(683, 254, 225, 24), 14, ui.CREAM, true, HORIZONTAL_ALIGNMENT_RIGHT)
	ui._label(ui.overlay, "BONUS", Rect2(625, 288, 58, 20), 10, ui.MUTED, true)
	ui._label(ui.overlay, lines[1], Rect2(683, 284, 225, 24), 13, ui.GOLD, true, HORIZONTAL_ALIGNMENT_RIGHT)
	ui._rule(Vector2(625, 315), 281)
	var differences := gear.compare_to_fitted(ui.gear_selected)
	var fitted: bool = ui.gear_selected in gear.equipped.values()
	ui._label(ui.overlay, "FITTED" if fitted else "VS FITTED", Rect2(625, 324, 281, 18), 10, ui.TEAL, true)
	if differences.is_empty():
		var spare := maxi(0, chosen.copies - 1)
		ui._label(ui.overlay, "No stat change" if not fitted else "%d spare %s" % [spare, "copy" if spare == 1 else "copies"], Rect2(625, 347, 281, 22), 13, ui.MUTED)
	else:
		var i := 0
		for stat in differences:
			ui._label(ui.overlay, NAMES[stat], Rect2(625, 348 + i * 20, 175, 20), 12, ui.MUTED)
			ui._label(ui.overlay, _delta(stat, differences[stat]), Rect2(800, 348 + i * 20, 105, 20), 13, ui.TEAL if differences[stat] > 0 else ui.CORAL, true, HORIZONTAL_ALIGNMENT_RIGHT)
			i += 1
	var equip: Button = ui._button("Fitted" if fitted else ("Not owned" if chosen.copies == 0 else "Equip"), Rect2(625, 414, 281, 32), func() -> void:
		gear.transact("equip", ui.gear_selected, ui.persist_equipment)
		ui.show_equipment(gear, back_action))
	equip.set_meta("equipment_action", "equip")
	equip.disabled = fitted or chosen.copies == 0 or gear.save_blocked
	equip.tooltip_text = "Fit to %s. Applies next run." % data.slot
	for i in range(2):
		var action: String = "reroll" if i == 0 else "star"
		var cost := 35 if i == 0 else 25 * (int(chosen.stars) + 1)
		var button: Button = ui._button(("Reroll  %d" if i == 0 else "Star  %d") % cost, Rect2(625 + i * 146, 455, 135, 33), func() -> void:
			gear.transact(action, ui.gear_selected, ui.persist_equipment)
			ui.show_equipment(gear, back_action), false)
		button.set_meta("equipment_action", action)
		if action == "star" and chosen.stars >= 5: button.text = "Max stars"
		button.add_theme_font_size_override("font_size", 13)
		button.disabled = chosen.copies == 0 or gear.save_blocked or gear.credits < cost or (action == "star" and (chosen.stars >= 5 or chosen.copies <= chosen.stars + 1))
		button.tooltip_text = "35 credits. Replace only the bonus; keep stars. The new roll can be better, worse or the same." if i == 0 else ("Max stars" if chosen.stars >= 5 else "%d credits + %d spare copies. Guaranteed +20%% base stat.\nNext: %s" % [cost, chosen.stars + 1, _delta(data.stat, data.base * 0.2)])
	if gear.save_blocked or "failed" in gear.message.to_lower():
		ui._label(ui.overlay, gear.message, Rect2(46, 490, 858, 22), 12, ui.CORAL)

static func _delta(stat: String, value: float) -> String:
	return "%+.1f%s" % [value * (100 if stat in ["damage", "speed", "drop"] else 1), "%" if stat in ["damage", "speed", "drop"] else ""]
