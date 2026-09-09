extends RefCounted
## Current kit and six decision-relevant stats. Details stay on the inspected icon.
static func draw(ui, model: SalvageRun) -> void:
	var kit := model.kit
	if kit == null: return
	ui._label(ui.overlay, "ABILITIES", Rect2(49, 109, 370, 23), 12, ui.TEAL, true)
	for i in range(MobaKit.SLOTS.size()):
		var slot: String = MobaKit.SLOTS[i]
		var id: String = kit.loadout[slot]
		var x := 49 + (i if i < 4 else i - 4) * 92
		var y := 142 if i < 4 else 234
		var tile := _tile(ui, Rect2(x, y, 74, 66))
		tile.set_meta("overview_slot", slot)
		var icon = ui._ability_icon(tile, id, Rect2(12, 5, 50, 50))
		if not kit.unlocked(slot): icon.modulate = Color("60717c")
		ui._label(tile, OS.get_keycode_string(kit.bindings[slot]), Rect2(3, 1, 25, 20), 11, ui.GOLD, true)
		ui._label(ui.overlay, (str(kit.ranks[slot]) if kit.ranks[slot] > 0 else "") if kit.unlocked(slot) else "Locked", Rect2(x, y + 68, 74, 18), 11, ui.MUTED, false, HORIZONTAL_ALIGNMENT_CENTER)
		tile.tooltip_text = "%s · Rank %d\n%s\n%.1fs recharge · %s\nBase: %s" % [MobaKit.ABILITIES[id].name, kit.ranks[slot], MobaKit.RARITIES[kit.tiers[slot]], kit.cooldown(slot), MobaKit.cost_text(id), MobaKit.ABILITIES[id].text]
		if MobaKit.deals_damage(id): tile.tooltip_text += "\nDamage ×%.2f" % kit.damage_scale(slot)
		if not kit.unlocked(slot): tile.tooltip_text += "\nUnlocks in %ds" % ceili(kit.UNLOCKS[slot] - kit.elapsed)
	ui._label(ui.overlay, "PASSIVES", Rect2(49, 336, 370, 21), 12, ui.TEAL, true)
	for i in range(4):
		var id: String = kit.loadout.passives[i]
		var tile := _tile(ui, Rect2(49 + i * 92, 368, 74, 66))
		ui._icon(tile, MobaKit.PASSIVES[id].icon, Rect2(12, 5, 50, 50), not kit.passive_active(id))
		ui._label(tile, OS.get_keycode_string(kit.bindings["p%d" % (i + 1)]), Rect2(3, 1, 25, 20), 11, ui.GOLD, true)
		tile.tooltip_text = "%s · %s\n%s energy/sec\n%s" % [MobaKit.PASSIVES[id].name, "On" if kit.passive_active(id) else "Off", MobaKit.UPKEEP.get(id, 0), MobaKit.PASSIVES[id].text]
	ui._label(ui.overlay, "GEAR", Rect2(49, 467, 60, 20), 12, ui.TEAL, true)
	for i in range(model.equipment_snapshot.size()):
		var item: Dictionary = model.equipment_snapshot[i]
		var tile := _tile(ui, Rect2(124 + i * 66, 451, 50, 48))
		ui._icon(tile, item.icon, Rect2(4, 3, 42, 42))
		tile.tooltip_text = "%s · %s\n%d stars\n%s" % [item.slot, item.name, item.stars, item.stats]
	ui._surface(ui.overlay, Rect2(455, 112, 1, 379), ui.EDGE, 0, ui.EDGE, 0)
	var stats := model.stats()
	var rows := [
		["Hull", "%d / %d" % [model.health, model.max_health()], "Current / maximum health."],
		["Energy", "%d / %d" % [kit.energy, kit.energy_max()], "Net regeneration: %+.1f/sec" % (kit.energy_regen() - kit.drain_rate())],
		["Ability damage", "+%.0f%%" % (kit.gear_damage * 100 + kit.mastery_damage * 100), "Bonus from equipment and mastery. Ability ranks and rarity apply separately."],
		["Fire rate", "%.2f /s" % (1.0 / model.attacks.auto_interval(model)), "Auto gun. Basic attacks: %.2f/sec; %.2f damage. Auto damage: %.2f." % [1.0 / model.attacks.interval(model), model.attacks.damage(model), model.attacks.auto_damage(model)]],
		["Move speed", "%.0f" % (stats.move_speed * (0.8 if model.slow_left > 0 else 1.0)), "Includes current boosts and slows."],
		["Pickup reach", "%.0f" % stats.magnet_radius, "XP bonus: +%d%%. Drop bonus: +%.0f%%. Bonus drops require close collection." % [model.mastery.rank_of("learning") * 10, model.drop_bonus * 100]]]
	for i in range(rows.size()):
		var row: Array = rows[i]
		var tile := _tile(ui, Rect2(501, 112 + i * 51, 407, 43), false)
		tile.set_meta("core_stat", row[0])
		tile.tooltip_text = row[2]
		ui._label(tile, row[0], Rect2(0, 7, 205, 26), 16, ui.MUTED)
		ui._label(tile, row[1], Rect2(211, 7, 193, 26), 19, ui.CREAM, true, HORIZONTAL_ALIGNMENT_RIGHT)
		ui._surface(tile, Rect2(0, 42, 407, 1), ui.EDGE, 0, ui.EDGE, 0)
	ui._label(ui.overlay, "%d credits" % model.coins, Rect2(501, 466, 407, 23), 13, ui.GOLD, false, HORIZONTAL_ALIGNMENT_RIGHT)

static func _tile(ui, rect: Rect2, framed: bool = true) -> Button:
	var tile: Button = ui._button("", rect, func() -> void: pass, false)
	tile.add_theme_stylebox_override("normal", ui._style(ui.PANEL if framed else Color.TRANSPARENT, 0, ui.EDGE, 1 if framed else 0))
	tile.pressed.connect(func() -> void:
		var detail := Control.new()
		detail.name = "BuildDetail"
		detail.size = Vector2(960, 540)
		detail.z_index = 20
		detail.mouse_filter = Control.MOUSE_FILTER_STOP
		ui.overlay.add_child(detail)
		var shade := ColorRect.new()
		shade.color = Color(0, 0, 0, 0.65)
		shade.size = detail.size
		detail.add_child(shade)
		var content := BotTooltip.make(tile.tooltip_text)
		detail.add_child(content)
		content.position = Vector2(270, 150)
		content.size = Vector2(420, 230)
		var back: Button = ui._button("Back", Rect2(560, 392, 130, 34), func() -> void:
			detail.queue_free()
			if is_instance_valid(tile): tile.grab_focus(), false)
		back.name = "DetailBack"
		back.reparent(detail)
		for property in ["focus_neighbor_left", "focus_neighbor_right", "focus_neighbor_top", "focus_neighbor_bottom", "focus_next", "focus_previous"]:
			back.set(property, back.get_path())
		back.grab_focus())
	return tile
