extends RefCounted
## Mastery purchases plus ability-rank, stat and equipment inspection.
## Ability rank previews are not additional purchases.

static func draw(ui: CanvasLayer, model: SalvageRun) -> void:
	ui._panel(Rect2(24, 24, 912, 492), Color("172932"))
	ui._label(ui.overlay, "Build", Rect2(47, 39, 212, 42), 30, ui.CREAM, true)
	ui._tab("Mastery", Rect2(253, 42, 104, 34), func() -> void:
		ui.build_page = "mastery"
		ui.show_build(model, false), ui.build_page == "mastery")
	ui._tab("Upgrades", Rect2(363, 42, 104, 34), func() -> void:
		ui.build_page = "upgrades"
		ui.show_build(model, false), ui.build_page == "upgrades")
	ui._tab("Stats", Rect2(473, 42, 104, 34), func() -> void:
		ui.build_page = "stats"
		ui.show_build(model, false), ui.build_page == "stats")
	if model.kit != null:
		ui._tab("Abilities", Rect2(583, 42, 104, 34), func() -> void:
			ui.build_page = "abilities"
			ui.show_build(model, false), ui.build_page == "abilities")
	ui._tab("Gear", Rect2(693, 42, 104, 34), func() -> void:
		ui.build_page = "gear"
		ui.show_build(model, false), ui.build_page == "gear")
	var close: Button = ui._button("Back", Rect2(811, 42, 102, 34), func() -> void: ui.build_closed.emit(), false)
	if ui.build_page == "mastery":
		_mastery(ui, model)
	elif ui.build_page == "upgrades":
		_tree(ui, model)
	elif ui.build_page == "abilities":
		_abilities(ui, model)
	elif ui.build_page == "gear":
		_gear(ui, model)
	else:
		_stats(ui, model)
	close.grab_focus()

static func _mastery(ui, model: SalvageRun) -> void:
	preload("res://src/salvage/mastery_view.gd").draw(ui, model)

static func _gear(ui, model: SalvageRun) -> void:
	for i in range(model.equipment_snapshot.size()):
		var item: Dictionary = model.equipment_snapshot[i]
		var x := 46 + i * 291
		ui._surface(ui.overlay, Rect2(x, 106, 279, 279), ui.PANEL)
		ui._label(ui.overlay, item.slot, Rect2(x + 18, 119, 243, 22), 13, ui.TEAL, true)
		ui._icon(ui.overlay, item.icon, Rect2(x + 72, 153, 134, 134))
		ui._label(ui.overlay, item.name, Rect2(x + 18, 285, 243, 28), 20, ui.CREAM, true)
		ui._label(ui.overlay, "%d stars / %s" % [item.stars, item.stats], Rect2(x + 18, 326, 243, 48), 12, ui.GOLD)
	ui._label(ui.overlay, "%d run credits / Repair x%d / Energy x%d" % [model.coins, model.consumables[0], model.consumables[1]], Rect2(47, 407, 866, 26), 17, ui.CREAM, true)
	ui._label(ui.overlay, "Bonus drop chance +%.0f%% / Ability damage +%.1f%% / Gear move speed +%.1f%%" % [model.drop_bonus * 100, model.kit.gear_damage * 100, model.kit.gear_speed * 100], Rect2(47, 446, 866, 23), 13, ui.MUTED)

static func _wire(ui: CanvasLayer, a: Vector2, b: Vector2, color: Color) -> void:
	var line := Line2D.new()
	line.points = PackedVector2Array([a, b])
	line.width = 2
	line.default_color = color
	line.antialiased = true
	ui.overlay.add_child(line)

static func _select(ui: CanvasLayer, model: SalvageRun, id: String, rank_value: int) -> void:
	ui.selected_item = id
	ui.selected_rank = rank_value
	ui.show_build(model, false)

static func _tree(ui: CanvasLayer, model: SalvageRun) -> void:
	if model.staged:
		_rank_tree(ui, model)
		return
	ui._label(ui.overlay, "WEAPONS", Rect2(49, 103, 230, 23), 11, ui.MUTED, true)
	ui._surface(ui.overlay, Rect2(248, 139, 150, 34), ui.PANEL, 5)
	ui._label(ui.overlay, "Scrap tools", Rect2(248, 143, 150, 25), 15, ui.CREAM, true, HORIZONTAL_ALIGNMENT_CENTER)
	_wire(ui, Vector2(323, 173), Vector2(323, 194), ui.EDGE)
	_wire(ui, Vector2(141, 194), Vector2(503, 194), ui.EDGE)
	var paths := ["grinder", "ricochet", "pulse"]
	for column in range(3):
		var id: String = paths[column]
		var x := 66 + column * 181
		var active := model.rank_of(id)
		var available := model.upgrade_available(id)
		_wire(ui, Vector2(x + 75, 194), Vector2(x + 75, 210), ui.TEAL if active > 0 else ui.EDGE)
		var card: Button = ui._button("", Rect2(x, 210, 150, 123), func() -> void: _select(ui, model, id, mini(3, active + 1)), false)
		if ui.selected_item == id:
			card.add_theme_stylebox_override("normal", ui._style(Color("29434c"), 6, ui.GOLD, 2))
		ui._icon(card, id, Rect2(38, 9, 74, 75), not available)
		ui._label(card, SalvageRun.UPGRADES[id].name, Rect2(8, 86, 134, 26), 17, ui.CREAM, true, HORIZONTAL_ALIGNMENT_CENTER)
		_wire(ui, Vector2(x + 75, 333), Vector2(x + 75, 355), ui.EDGE)
		_wire(ui, Vector2(x + 30, 371), Vector2(x + 120, 371), ui.EDGE)
		for r in range(1, 4):
			var rank_button: Button = ui._button(str(r), Rect2(x + 13 + (r - 1) * 45, 355, 34, 32), func() -> void: _select(ui, model, id, r), r <= active)
			if ui.selected_item == id and ui.selected_rank == r:
				rank_button.add_theme_stylebox_override("normal", ui._style(Color("35594f"), 5, ui.GOLD, 2))
			ui._label(rank_button, "", Rect2(), 10, ui.CREAM)
	ui._label(ui.overlay, "SUPPORT", Rect2(49, 406, 230, 19), 11, ui.MUTED, true)
	var support := ["power", "rapid", "magnet", "capacity", "reactor", "cell"]
	for i in range(6):
		var id: String = support[i]
		var x := 49 + i * 94
		var tile: Button = ui._button("", Rect2(x, 433, 87, 55), func() -> void: _select(ui, model, id, mini(SalvageRun.UPGRADES[id].max, model.rank_of(id) + 1)), false)
		ui._icon(tile, id, Rect2(4, 4, 31, 31), not model.upgrade_available(id))
		ui._label(tile, {"power": "Bolts", "rapid": "Rate", "magnet": "Magnet", "capacity": "Rack", "reactor": "Regen", "cell": "Energy"}[id], Rect2(37, 10, 48, 20), 10, ui.CREAM, true)
		ui._pips(tile, Vector2(7, 42), model.rank_of(id), int(SalvageRun.UPGRADES[id].max))
	_detail(ui, model)
	ui._label(ui.overlay, "Level-up ranks. Dim paths require a matching equipped passive.", Rect2(49, 491, 571, 18), 10, ui.MUTED)

static func _rank_tree(ui, model: SalvageRun) -> void:
	for i in range(3):
		var group: String = ["skills", "weapons", "utility"][i]
		ui._tab(group.capitalize(), Rect2(47 + i * 143, 102, 134, 31), func() -> void:
			ui.track_group = group
			ui.selected_item = "skill_q" if group == "skills" else ("power" if group == "weapons" else "magnet")
			ui.selected_rank = mini(int(model.upgrade_data(ui.selected_item).max), model.rank_of(ui.selected_item) + 1)
			ui.show_build(model, false), group == ui.track_group)
	var ids: Array = ["magnet"] if ui.track_group == "utility" else (SalvageProgression.WEAPONS.duplicate() if ui.track_group == "weapons" else MobaKit.SLOTS.map(func(slot: String) -> String: return "skill_" + slot))
	if ui.selected_item not in ids:
		ui.selected_item = ids[0]
		ui.selected_rank = mini(int(model.upgrade_data(ui.selected_item).max), model.rank_of(ui.selected_item) + 1)
	for i in range(ids.size()):
		var id: String = ids[i]
		var y := 146 + i * 42
		var tile = ui._button("", Rect2(47, y, 420, 37), func() -> void: _select(ui, model, id, mini(int(model.upgrade_data(id).max), model.rank_of(id) + 1)), false)
		if ui.selected_item == id:
			tile.add_theme_stylebox_override("normal", ui._style(Color("29434c"), 5, ui.TEAL, 2))
		ui._upgrade_icon(tile, model, id, Rect2(4, 3, 31, 31))
		ui._label(tile, model.upgrade_data(id).name, Rect2(43, 7, 188, 23), 13, ui.CREAM, true)
		ui._label(tile, "%d/%d" % [model.rank_of(id), model.upgrade_data(id).max], Rect2(374, 8, 42, 20), 11, ui.GOLD)
		for r in range(int(model.upgrade_data(id).max)):
			ui._surface(tile, Rect2(242 + r * 12, 17, 8, 5), ui.GOLD if r < model.rank_of(id) and (r + 1) % 5 == 0 else (ui.TEAL if r < model.rank_of(id) else ui.EDGE), 1)
	if ui.track_group == "utility":
		var utility = ui._label(ui.overlay, "Magnet", Rect2(55, 210, 405, 32), 24, ui.CREAM, true)
		utility.mouse_filter = Control.MOUSE_FILTER_STOP
		utility.tooltip_text = "Always equipped. Free ranks every 3 power levels. Mastery adds pickup reach. Bonus drops require close collection."
	var id: String = ui.selected_item
	var data: Dictionary = model.upgrade_data(id)
	var r: int = clampi(ui.selected_rank, 1, data.max)
	ui._surface(ui.overlay, Rect2(489, 103, 423, 384), ui.PANEL, 8)
	ui._upgrade_icon(ui.overlay, model, id, Rect2(507, 118, 78, 78))
	ui._label(ui.overlay, data.tag, Rect2(600, 120, 298, 20), 10, ui.TEAL, true)
	ui._label(ui.overlay, data.name, Rect2(600, 144, 298, 29), 22, ui.CREAM, true)
	ui._label(ui.overlay, "Rank %d / %d  •  %s" % [r, data.max, "owned" if r <= model.rank_of(id) else "preview"], Rect2(600, 176, 293, 22), 12, ui.GOLD)
	for n in range(1, int(data.max) + 1):
		var button = ui._button(str(n) + (" *" if n % 5 == 0 else ""), Rect2(509 + ((n - 1) % 5) * 77, 218 + ((n - 1) / 5) * 38, 67, 30), func() -> void: _select(ui, model, id, n), n <= model.rank_of(id))
		if n == r: button.add_theme_stylebox_override("normal", ui._style(Color("35594f"), 5, ui.GOLD, 2))
	var before := model.upgrade_values(id, r - 1)
	var after := model.upgrade_values(id, r)
	for i in range(after.size()):
		ui._label(ui.overlay, after[i].label, Rect2(509, 305 + i * 27, 192, 24), 14, ui.MUTED)
		ui._label(ui.overlay, "%s -> %s%s" % [before[i].value, after[i].value, after[i].unit], Rect2(704, 305 + i * 27, 186, 24), 14, ui.CREAM, true, HORIZONTAL_ALIGNMENT_RIGHT)
	ui._label(ui.overlay, "MILESTONES" if id != "magnet" else "FREE UTILITY", Rect2(509, 402, 380, 19), 11, ui.GOLD, true)
	var note = ui._label(ui.overlay, model.upgrade_note(id, r), Rect2(509, 427, 380, 45), 13, ui.CREAM)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

static func _detail(ui: CanvasLayer, model: SalvageRun) -> void:
	var id: String = ui.selected_item
	var data: Dictionary = SalvageRun.UPGRADES[id]
	var r: int = ui.selected_rank
	ui._surface(ui.overlay, Rect2(638, 104, 275, 384), ui.PANEL, 8)
	ui._label(ui.overlay, data.tag, Rect2(658, 119, 235, 23), 10, ui.TEAL, true)
	ui._icon(ui.overlay, id, Rect2(709, 144, 132, 131))
	ui._label(ui.overlay, data.name, Rect2(657, 286, 239, 30), 24, ui.CREAM, true)
	var current := model.rank_of(id)
	ui._label(ui.overlay, "Rank %d of %d  /  %s" % [r, data.max, "owned" if r <= current else "preview"], Rect2(658, 321, 240, 22), 12, ui.GOLD)
	var values := model.upgrade_values(id, r)
	var previous := model.upgrade_values(id, r - 1)
	for i in range(values.size()):
		ui._label(ui.overlay, values[i].label, Rect2(658, 353 + i * 25, 126, 24), 12, ui.MUTED)
		ui._label(ui.overlay, "%s > %s%s" % [previous[i].value, values[i].value, values[i].unit], Rect2(784, 353 + i * 25, 108, 24), 13, ui.CREAM, true, HORIZONTAL_ALIGNMENT_RIGHT)
	var note: String = data.description
	if not model.upgrade_available(id):
		note = "Not offered with this loadout."
	ui._label(ui.overlay, note, Rect2(658, 451, 239, 25), 11, ui.MUTED)

static func _stat_row(ui: CanvasLayer, x: float, y: float, title: String, base: String, current: String, source: String) -> void:
	ui._label(ui.overlay, title, Rect2(x, y, 126, 20), 12, ui.MUTED)
	ui._label(ui.overlay, base, Rect2(x + 123, y, 42, 20), 12, ui.MUTED, false, HORIZONTAL_ALIGNMENT_RIGHT)
	ui._label(ui.overlay, current, Rect2(x + 177, y, 72, 20), 15, ui.GOLD, true, HORIZONTAL_ALIGNMENT_RIGHT)
	ui._label(ui.overlay, source, Rect2(x, y + 21, 252, 17), 10, Color("738d96"))

static func _stats(ui: CanvasLayer, model: SalvageRun) -> void:
	var s := model.stats()
	var groups := [
		{"title": "COMBAT", "x": 49, "rows": [
			["Bolt damage", "%.2f" % s.bolt_damage, "Heavy bolts. Automatic weapon only."],
			["Fire rate", "%.2f /s" % s.fire_rate, "Automatic fire rate."],
			["Orbit damage", "%.2f" % s.orbit_damage, "Per tool hit; only while Scrap orbit is enabled."],
			["Ability power", "+%.0f%%" % ((model.kit.gear_damage + model.kit.mastery_damage) * 100), "Equipment + mastery. Each ability also has its own rank and rarity multiplier."]]},
		{"title": "SURVIVAL", "x": 342, "rows": [
			["Hull", "%d / %d" % [model.health, model.max_health()], "Reinforced mastery increases maximum hull."],
			["Move speed", "%.0f" % (s.move_speed * (0.8 if model.slow_left > 0 else 1.0)), "Current movement speed, including boosts and slows."],
			["Energy", "%d / %d" % [model.kit.energy, model.kit.energy_max()], "Stored / capacity."],
			["Net energy", "%+.1f /s" % (model.kit.energy_regen() - model.kit.drain_rate()), "Regeneration %.1f / upkeep %.1f per second." % [model.kit.energy_regen(), model.kit.drain_rate()]]]},
		{"title": "SALVAGE", "x": 635, "rows": [
			["Pickup reach", "%.0f" % s.magnet_radius, "Magnet + Long reach mastery. Bonus drops still require proximity."],
			["Bonus XP", "+%d%%" % (model.mastery.rank_of("learning") * 10), "Fast learner mastery. Scrap XP only."],
			["Bonus drops", "+%.0f%%" % (model.drop_bonus * 100), "Relative increase to money/boost drop odds, not percentage points."],
			["Credits", str(model.coins), "Banked at a clear or defeat."]]}
	]
	for group in groups:
		ui._label(ui.overlay, group.title, Rect2(group.x, 106, 263, 24), 12, ui.TEAL, true)
		for i in range(group.rows.size()):
			var row: Array = group.rows[i]
			var y := 148 + i * 47
			var surface = ui._surface(ui.overlay, Rect2(group.x, y, 264, 42), Color(0, 0, 0, 0), 0, Color(0, 0, 0, 0), 0)
			surface.mouse_filter = Control.MOUSE_FILTER_STOP
			surface.tooltip_text = row[2]
			ui._label(surface, row[0], Rect2(0, 4, 147, 23), 14, ui.MUTED)
			ui._label(surface, row[1], Rect2(148, 4, 112, 23), 17, ui.CREAM, true, HORIZONTAL_ALIGNMENT_RIGHT)
			ui._surface(surface, Rect2(0, 36, 260, 1), ui.EDGE, 0, ui.EDGE, 0)
	ui._label(ui.overlay, "DAMAGE DEALT", Rect2(49, 357, 812, 24), 12, ui.TEAL, true)
	var sources := model.damage_dealt.keys()
	sources.sort_custom(func(a, b) -> bool: return model.damage_dealt[a] > model.damage_dealt[b])
	var largest := 1.0
	for value in model.damage_dealt.values(): largest = maxf(largest, value)
	for i in range(mini(8, sources.size())):
		var id: String = sources[i]
		var x := 49 + (i % 4) * 219
		var y := 394 + (i / 4) * 54
		ui._label(ui.overlay, id.capitalize(), Rect2(x, y, 119, 20), 13, ui.MUTED)
		ui._label(ui.overlay, "%.0f" % model.damage_dealt[id], Rect2(x + 121, y, 81, 20), 15, ui.GOLD, true, HORIZONTAL_ALIGNMENT_RIGHT)
		var bar = ui._bar(ui.overlay, Rect2(x, y + 28, 200, 3), ui.TEAL, largest)
		bar.value = model.damage_dealt[id]

static func _abilities(ui, model: SalvageRun) -> void:
	var kit := model.kit
	for i in range(MobaKit.SLOTS.size()):
		var slot: String = MobaKit.SLOTS[i]
		var data: Dictionary = MobaKit.ABILITIES[kit.loadout[slot]]
		var x := 47 + (i % 2) * 439
		var y := 102 + (i / 2) * 78
		var tile = ui._surface(ui.overlay, Rect2(x, y, 426, 69), ui.PANEL)
		tile.mouse_filter = Control.MOUSE_FILTER_STOP
		tile.tooltip_text = data.text + "\n" + model.upgrade_note("skill_" + slot, kit.ranks[slot]) if model.staged else data.text
		ui._ability_icon(tile, kit.loadout[slot], Rect2(6, 6, 55, 55))
		ui._label(tile, "[%s] %s  %d/10" % [OS.get_keycode_string(kit.bindings[slot]), data.name, kit.ranks[slot]], Rect2(70, 6, 350, 23), 15, ui.CREAM, true)
		var details := "%s / %.1fs / %s" % [MobaKit.RARITIES[kit.tiers[slot]], kit.cooldown(slot), MobaKit.cost_text(kit.loadout[slot])]
		if MobaKit.deals_damage(kit.loadout[slot]):
			details += " / x%.2f damage" % kit.damage_scale(slot)
		ui._label(tile, details, Rect2(70, 31, 348, 18), 11, MobaKit.RARITY_COLORS[kit.tiers[slot]])
		ui._label(tile, ("Unlocks in %ds" % ceili(kit.UNLOCKS[slot] - kit.elapsed)) if not kit.unlocked(slot) else "%d / %d ready%s" % [kit.charges[slot], data.max, " / next in %.1fs" % kit.recharge[slot] if kit.recharge[slot] > 0 else ""], Rect2(70, 49, 348, 18), 11, ui.GOLD)
	for i in range(4):
		var data: Dictionary = MobaKit.PASSIVES[kit.loadout.passives[i]]
		var x := 48 + i * 217
		ui._icon(ui.overlay, data.icon, Rect2(x, 426, 40, 40))
		ui._label(ui.overlay, "[%s] %s\n%s / %s energy/sec" % [OS.get_keycode_string(kit.bindings["p%d" % (i + 1)]), data.name, "ON" if kit.passive_active(kit.loadout.passives[i]) else "OFF", MobaKit.UPKEEP.get(kit.loadout.passives[i], 0)], Rect2(x + 46, 430, 171, 42), 11, ui.TEAL, true)
