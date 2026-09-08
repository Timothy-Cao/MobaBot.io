extends RefCounted

static func draw(ui) -> void:
	ui.clear_overlay()
	ui.hud.visible = false
	ui._dim()
	ui._panel(Rect2(24, 24, 912, 492), Color("172932"))
	ui._label(ui.overlay, "Loadout", Rect2(46, 38, 210, 45), 30, ui.CREAM, true)
	for i in range(4):
		var page: String = ["abilities", "passives", "utility", "keys"][i]
		ui._button(page.capitalize(), Rect2(300 + i * 123, 43, 115, 34), func() -> void:
			ui.loadout_page = page
			ui.rebind_slot = ""
			draw(ui), ui.loadout_page == page)
	ui._button("Back", Rect2(811, 43, 102, 34), func() -> void: ui.loadout_closed.emit(), false)
	if ui.loadout_page == "keys":
		_keys(ui)
	elif ui.loadout_page == "utility":
		_utility(ui)
	else:
		_equipment(ui)
	ui._label(ui.overlay, ui.loadout_message, Rect2(48, 481, 860, 23), 12, ui.GOLD)

static func _utility(ui) -> void:
	ui._surface(ui.overlay, Rect2(48, 105, 864, 349), ui.PANEL)
	ui._icon(ui.overlay, "magnet", Rect2(70, 128, 180, 180))
	ui._label(ui.overlay, "Magnet", Rect2(281, 128, 588, 39), 29, ui.CREAM, true)
	ui._label(ui.overlay, "ALWAYS EQUIPPED / FREE", Rect2(283, 178, 583, 24), 13, ui.TEAL, true)
	ui._label(ui.overlay, "No passive slot. No energy drain.\n\nStarts at 88 px. Free ranks every 3 level-ups,\nup to 180 px. Each rank pulls scrap faster.\n\nBonus drops need you within 48 px.\nNo full-map vacuum. Move to collect rewards.", Rect2(283, 220, 594, 209), 16, ui.MUTED)

static func _equipment(ui) -> void:
	var passive: bool = ui.loadout_page == "passives"
	var slots: Array = ["0", "1", "2", "3"] if passive else MobaKit.SLOTS
	var selected: String = str(ui.passive_index) if passive else ui.loadout_slot
	for i in range(slots.size()):
		var slot: String = slots[i]
		var id: String = ui.loadout_config.passives[i] if passive else ui.loadout_config[slot]
		var data: Dictionary = MobaKit.PASSIVES[id] if passive else MobaKit.ABILITIES[id]
		var row: Button = ui._button("", Rect2(47, 101 + i * 44, 227, 39), func() -> void:
			if passive:
				ui.passive_index = int(slot)
			else:
				ui.loadout_slot = slot
			draw(ui), false)
		if slot == selected:
			row.add_theme_stylebox_override("normal", ui._style(Color("35534f"), 5, ui.GOLD, 2))
		if passive:
			ui._icon(row, data.icon, Rect2(4, 2, 36, 34))
		else:
			ui._ability_icon(row, id, Rect2(5, 3, 33, 33))
		ui._label(row, OS.get_keycode_string(ui.key_config["p%d" % (i + 1)]) if passive else OS.get_keycode_string(ui.key_config[slot]), Rect2(44, 9, 30, 22), 13, ui.GOLD, true)
		ui._label(row, data.name, Rect2(78, 9, 146, 22), 13, ui.CREAM, true)
	var selected_id: String = ui.loadout_config.passives[ui.passive_index] if passive else ui.loadout_config[ui.loadout_slot]
	var pool: Array = []
	if passive:
		pool = MobaKit.PASSIVES.keys()
	else:
		for id in MobaKit.ABILITIES:
			if MobaKit.ABILITIES[id].category == MobaKit.category(ui.loadout_slot):
				pool.append(id)
	for i in range(pool.size()):
		var id: String = pool[i]
		var data: Dictionary = MobaKit.PASSIVES[id] if passive else MobaKit.ABILITIES[id]
		var tile: Button = ui._button("", Rect2(298 + (i % 3) * 205, 103 + (i / 3) * 91, 192, 85), func() -> void:
			var next: Dictionary = ui.loadout_config.duplicate(true)
			if passive:
				var previous: String = next.passives[ui.passive_index]
				var existing: int = next.passives.find(id)
				if existing >= 0:
					next.passives[existing] = previous
				next.passives[ui.passive_index] = id
			else:
				var previous: String = next[ui.loadout_slot]
				for other in MobaKit.SLOTS:
					if next[other] == id:
						next[other] = previous
				next[ui.loadout_slot] = id
			if MobaKit.valid_loadout(next):
				ui.loadout_config = next
				ui.loadout_message = "Applies to your next run."
				ui.loadout_changed.emit(next, ui.key_config)
			else:
				ui.loadout_message = "Replace Ricochet before removing Scrap orbit."
			draw(ui), false)
		if id == selected_id:
			tile.add_theme_stylebox_override("normal", ui._style(Color("29434c"), 6, ui.TEAL, 2))
		if passive:
			ui._icon(tile, data.icon, Rect2(9, 10, 51, 51))
		else:
			ui._ability_icon(tile, id, Rect2(9, 10, 51, 51))
		ui._label(tile, data.name, Rect2(67, 9, 121, 33), 12, ui.CREAM, true)
		ui._label(tile, "Toggle" if passive else "%ss / %d charge%s" % [data.cd, data.max, "s" if data.max > 1 else ""], Rect2(67, 37, 121, 18), 10, ui.MUTED)
		ui._label(tile, ("%s energy/s" % MobaKit.UPKEEP[id] if MobaKit.UPKEEP.has(id) else "Free") if passive else MobaKit.cost_text(id), Rect2(9, 64, 174, 18), 10, ui.TEAL)
	var info: Dictionary = MobaKit.PASSIVES[selected_id] if passive else MobaKit.ABILITIES[selected_id]
	ui._surface(ui.overlay, Rect2(298, 385, 602, 79), ui.PANEL)
	var description: Label = ui._label(ui.overlay, info.text, Rect2(313, 395, 570, 59), 14, ui.CREAM)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if passive and selected_id == "orbit": description.text = "Collected scrap becomes orbit blades. Press its number key to alternate close protection and a wider attack radius."
	if passive:
		ui._label(ui.overlay, "ONE PET", Rect2(48, 298, 220, 20), 11, ui.MUTED, true)
		ui._button(MobaKit.PETS[ui.loadout_config.pet], Rect2(48, 325, 226, 39), func() -> void:
			var pets: Array = MobaKit.PETS.keys()
			ui.loadout_config.pet = pets[(pets.find(ui.loadout_config.pet) + 1) % pets.size()]
			ui.loadout_changed.emit(ui.loadout_config, ui.key_config)
			draw(ui), false)
		var text := "Scout attracts scrap within 105 range. Drone fires at nearby enemies. No pet controls needed."
		var note: Label = ui._label(ui.overlay, text, Rect2(48, 373, 221, 78), 12, ui.MUTED)
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		ui._button("Default kit", Rect2(48, 422, 109, 37), func() -> void:
			ui.loadout_config = MobaKit.demo_preset()
			ui.loadout_changed.emit(ui.loadout_config, ui.key_config)
			draw(ui), false)
		ui._button("Relaxed", Rect2(165, 422, 109, 37), func() -> void: _preset(ui, false), false)

static func _preset(ui, precision: bool) -> void:
	ui.loadout_config = MobaKit.preset(precision)
	ui.loadout_changed.emit(ui.loadout_config, ui.key_config)
	ui.loadout_message = "Precision: aimed attacks." if precision else "Relaxed: homing, area damage and protection."
	draw(ui)

static func _keys(ui) -> void:
	ui._label(ui.overlay, "Wheel: zoom / Hold Tab: inspect / Esc: settings / S: stop", Rect2(49, 97, 860, 23), 13, ui.CREAM)
	for i in range(MobaKit.BIND_SLOTS.size()):
		var slot: String = MobaKit.BIND_SLOTS[i]
		var x := 49 + (i % 2) * 442
		var y := 134 + (i / 2) * 47
		ui._surface(ui.overlay, Rect2(x, y, 419, 41), ui.PANEL)
		ui._label(ui.overlay, "%s / %s" % [slot.to_upper(), "Toggle" if slot.begins_with("p") else MobaKit.category(slot).capitalize()], Rect2(x + 14, y + 7, 264, 26), 14, ui.CREAM, true)
		ui._button("Press key..." if ui.rebind_slot == slot else OS.get_keycode_string(ui.key_config[slot]), Rect2(x + 284, y + 4, 123, 33), func() -> void:
			ui.rebind_slot = slot
			ui.loadout_message = "Press a letter or number. Escape cancels. Occupied keys swap slots."
			draw(ui), ui.rebind_slot == slot)
	ui._button("Reset keys", Rect2(49, 425, 180, 37), func() -> void:
		ui.key_config = MobaKit.DEFAULT_BINDS.duplicate()
		ui.rebind_slot = ""
		ui.loadout_changed.emit(ui.loadout_config, ui.key_config)
		draw(ui), false)
	ui._label(ui.overlay, "1–4 passives / 5–6 items / L lock / Hold Space follow\nS, M, L, 5, 6, Tab, Space and Esc reserved. Occupied keys swap.", Rect2(248, 423, 650, 47), 12, ui.MUTED)
