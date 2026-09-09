extends RefCounted
static func draw(ui) -> void:
	if ui.expedition_ui and ui.host!=null: KeyboardView.settings(ui); return
	ui._panel(Rect2(24, 24, 912, 492))
	ui._label(ui.overlay, "Settings", Rect2(47, 39, 300, 42), 30, ui.CREAM, true)
	for i in range(2):
		var page: String = ["options", "controls"][i]
		ui._tab(page.capitalize(), Rect2(491 + i * 154, 42, 140, 34), func() -> void:
			ui.settings_page = page
			ui.rebind_slot = ""
			ui.show_settings(), ui.settings_page == page)
	var back: Button = ui._button("Back", Rect2(811, 42, 102, 34), func() -> void: ui.settings_closed.emit(), false)
	if ui.settings_in_run:
		ui._button("Main menu", Rect2(747, 453, 165, 34), func() -> void:
			var confirm := ConfirmationDialog.new()
			confirm.title = "Leave run?"
			confirm.dialog_text = "Unbanked loot will be lost."
			confirm.ok_button_text = "Leave"
			ui.add_child(confirm)
			confirm.confirmed.connect(func() -> void:
				ui.menu_requested.emit()
				confirm.queue_free())
			confirm.canceled.connect(confirm.queue_free)
			confirm.popup_centered(), false)
	if ui.settings_page == "controls":
		_controls(ui)
	else:
		var rows := [
			["Sound", "Off" if ui.muted else "On", "Mute music and effects. M.", func() -> void: ui.mute_changed.emit(not ui.muted)],
			["Reduced effects", "On" if ui.reduced else "Off", "Reduces decorative effects; keeps damage warnings. F2.", func() -> void: ui.effects_changed.emit(not ui.reduced)],
			["Camera lock", "On" if ui.camera_locked else "Off", "L toggles lock. Hold Space to recenter. Wheel zooms.", func() -> void: ui.camera_lock_changed.emit(not ui.camera_locked)],
			["Area quick cast", "On" if ui.r_quickcast else "Off", "Off: press E, then click to confirm. R laser always starts immediately.", func() -> void: ui.quickcast_changed.emit(not ui.r_quickcast)]]
		for i in range(rows.size()):
			var row: Array = rows[i]
			var y := 149 + i * 72
			ui._label(ui.overlay, row[0], Rect2(204, y + 4, 349, 29), 19, ui.CREAM)
			var button: Button = ui._button(row[1], Rect2(616, y, 140, 36), row[3], false)
			button.set_meta("setting", row[0])
			button.tooltip_text = row[2]
			ui._rule(Vector2(204, y + 51), 552)
	back.grab_focus()

static func _controls(ui) -> void:
	var fixed := [["Move / target", "Right-click"], ["Attack move", "A + click"], ["Stop", "S"], ["Inspect build", "Hold Tab"], ["Camera lock", "L / hold Space"], ["Zoom", "Wheel"], ["Consumables", "5 / 6"]]
	for i in range(fixed.size()):
		ui._label(ui.overlay, fixed[i][0], Rect2(49, 119 + i * 43, 181, 25), 14, ui.MUTED)
		ui._label(ui.overlay, fixed[i][1], Rect2(235, 119 + i * 43, 184, 25), 14, ui.CREAM, true, HORIZONTAL_ALIGNMENT_RIGHT)
	ui._surface(ui.overlay, Rect2(448, 115, 1, 325), ui.EDGE, 0, ui.EDGE, 0)
	for i in range(MobaKit.BIND_SLOTS.size()):
		var slot: String = MobaKit.BIND_SLOTS[i]
		var position_index := i if i < 7 else i + 1
		var x := 487 + (position_index % 2) * 218
		var y := 115 + (position_index / 2) * 51
		var passive := slot.begins_with("p")
		var id: String = ui.loadout_config.passives[int(slot.substr(1)) - 1] if passive else ui.loadout_config[slot]
		var icon = ui._icon(ui.overlay, MobaKit.PASSIVES[id].icon, Rect2(x, y, 39, 39)) if passive else ui._ability_icon(ui.overlay, id, Rect2(x, y, 39, 39))
		var bind: Button = ui._button("…" if ui.rebind_slot == slot else OS.get_keycode_string(ui.key_config[slot]), Rect2(x + 48, y + 2, 143, 35), func() -> void:
			ui.rebind_slot = slot
			ui.loadout_message = ""
			ui.show_settings(), false)
		bind.set_meta("bind_slot", slot)
		bind.tooltip_text = (MobaKit.PASSIVES[id].name if passive else MobaKit.ABILITIES[id].name) + ". Select, then press a key. Applies next run. Esc cancels; occupied keys swap."
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var reset: Button = ui._button("Reset keys", Rect2(49, 453, 165, 34), func() -> void:
		ui.key_config = MobaKit.DEFAULT_BINDS.duplicate()
		ui.rebind_slot = ""
		ui.loadout_changed.emit(ui.loadout_config, ui.key_config)
		ui.show_settings(), false)
	reset.tooltip_text = "Restore ability bindings for the next run. Does not reset your loadout or progress."
	ui._label(ui.overlay, "Applies next run", Rect2(487, 458, 240, 26), 12, ui.MUTED)
	if ui.loadout_message.begins_with("Reserved"):
		ui._label(ui.overlay, "Reserved key", Rect2(242, 458, 405, 26), 12, ui.GOLD)
