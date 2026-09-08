extends RefCounted
## Read-only build inspection. Rank nodes describe real sequential levels,
## not additional purchases or mutually exclusive prerequisites.

static func draw(ui: CanvasLayer, model: SalvageRun) -> void:
	ui._panel(Rect2(24, 24, 912, 492), Color("172932"))
	ui._label(ui.overlay, "Build", Rect2(47, 39, 212, 42), 30, ui.CREAM, true)
	ui._button("Upgrades", Rect2(286, 42, 142, 34), func() -> void:
		ui.build_page = "upgrades"
		ui.show_build(model, false), ui.build_page == "upgrades")
	ui._button("Stats", Rect2(440, 42, 142, 34), func() -> void:
		ui.build_page = "stats"
		ui.show_build(model, false), ui.build_page == "stats")
	if model.kit != null:
		ui._button("Abilities", Rect2(594, 42, 142, 34), func() -> void:
			ui.build_page = "abilities"
			ui.show_build(model, false), ui.build_page == "abilities")
	var close: Button = ui._button("Back", Rect2(811, 42, 102, 34), func() -> void: ui.build_closed.emit(), false)
	if ui.build_page == "upgrades":
		_tree(ui, model)
	elif ui.build_page == "abilities":
		_abilities(ui, model)
	else:
		_stats(ui, model)
	close.grab_focus()

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
		ui._button(group.capitalize(), Rect2(47 + i * 143, 102, 134, 31), func() -> void:
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
		ui._label(ui.overlay, "Always equipped. No passive slot. No energy cost.\n\nMagnet starts at rank 1.\nGain another free rank every 3 level-ups.\n\n250 -> 350 -> 450 -> 550 -> 650 px pickup radius.\nPull speed also improves each rank.\n\nRank 5 adds a whole-map scrap sweep every 15s.\nCollection can feed Orbit and Pulse: indirect power.", Rect2(55, 210, 405, 247), 14, ui.MUTED)
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
	ui._label(ui.overlay, "Level 1: ranks 1–5 / Level 2: up to 8 / Level 3: up to 10. Stars are milestones." if model.demo_mode else "Preview ranks by clicking a number. Stars mark milestone upgrades.", Rect2(49, 491, 860, 18), 11, ui.MUTED)

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
	for i in range(3):
		var x := 46 + i * 293
		ui._surface(ui.overlay, Rect2(x, 105, 279, 218), ui.PANEL)
		ui._icon(ui.overlay, ["power", "grinder", "magnet"][i], Rect2(x + 14, 114, 34, 34))
		ui._label(ui.overlay, ["Bolt gun", "Orbit tools", "Movement & collection"][i], Rect2(x + 59, 116, 210, 28), 16, ui.CREAM, true)
		ui._label(ui.overlay, "BASE       NOW", Rect2(x + 138, 153, 127, 18), 10, ui.MUTED, true, HORIZONTAL_ALIGNMENT_RIGHT)
	_stat_row(ui, 61, 178, "Damage", "2", str(s.bolt_damage), "Heavy bolts; also scales Salvo / Rail")
	_stat_row(ui, 61, 222, "Shots / sec", "2.33", "%.2f" % s.fire_rate if model.passive_enabled("bolt") else "Off", "Fire rate ranks + milestone boosts" if model.staged else "Auto bolt: 1.22x per Fire rate rank")
	_stat_row(ui, 61, 266, "Pierces", "0", str(s.pierce), "Heavy bolts")
	var disabled := model.mode == "baseline" or not model.passive_enabled("orbit")
	_stat_row(ui, 354, 178, "Damage", "4", "—" if disabled else str(s.orbit_damage), "Grinder")
	_stat_row(ui, 354, 222, "Hits / tool", "1", "—" if disabled else str(s.orbit_hits), "Grinder")
	_stat_row(ui, 354, 266, "Slots", "6", "—" if disabled else str(s.capacity), "Tool rack")
	_stat_row(ui, 647, 178, "Move speed", "205", "%.0f px/s" % s.move_speed, "Sprint +65%; Overdrive +25% (additive)")
	_stat_row(ui, 647, 222, "Pickup radius", "250" if model.staged else "83", "%d px" % s.magnet_radius, "Free Utility: Magnet" if model.staged else "Magnet")
	_stat_row(ui, 647, 266, "Hull", "5", "%d / 5" % model.health, "Foreman kill restores 1 hull")
	ui._surface(ui.overlay, Rect2(46, 337, 572, 149), ui.PANEL)
	ui._label(ui.overlay, "Damage dealt this run", Rect2(62, 350, 510, 24), 16, ui.CREAM, true)
	var total := 0.0
	for value in model.damage_dealt.values():
		total += float(value)
	var sources := ["bolt", "orbit", "shard", "pulse", "homing", "rail", "active", "ultimate", "pet", "summon"]
	for i in range(sources.size()):
		var id: String = sources[i]
		var x := 62 + (i % 5) * 109
		var y := 382 + (i / 5) * 48
		ui._label(ui.overlay, "%.0f" % model.damage_dealt.get(id, 0), Rect2(x, y, 98, 23), 18, ui.GOLD, true)
		ui._label(ui.overlay, id.capitalize(), Rect2(x, y + 23, 98, 16), 10, ui.MUTED)
		var bar: ProgressBar = ui._bar(ui.overlay, Rect2(x, y + 40, 96, 3), ui.TEAL, maxf(1, total))
		bar.value = model.damage_dealt.get(id, 0)
	ui._surface(ui.overlay, Rect2(632, 337, 279, 149), ui.PANEL)
	ui._label(ui.overlay, "Energy", Rect2(648, 350, 247, 23), 16, ui.CREAM, true)
	if model.kit != null:
		ui._label(ui.overlay, "%d / %d stored\n+%.1f regen / sec\n-%.1f toggle upkeep / sec\n%.0f spent / %d hull paid" % [model.kit.energy, model.kit.energy_max(), model.kit.energy_regen(), model.kit.drain_rate(), model.kit.energy_spent, model.kit.health_spent], Rect2(648, 380, 247, 96), 13, ui.CREAM)
	ui._label(ui.overlay, "Stats reflect this run. Upgrades reset when you start a new run.", Rect2(48, 491, 860, 18), 10, ui.MUTED)

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
		ui._label(tile, "%d / %d ready%s" % [kit.charges[slot], data.max, " / next in %.1fs" % kit.recharge[slot] if kit.recharge[slot] > 0 else ""], Rect2(70, 49, 348, 18), 11, ui.GOLD)
	for i in range(4):
		var data: Dictionary = MobaKit.PASSIVES[kit.loadout.passives[i]]
		var x := 48 + i * 217
		ui._icon(ui.overlay, data.icon, Rect2(x, 426, 40, 40))
		ui._label(ui.overlay, "[%s] %s\n%s / %s energy/sec" % [OS.get_keycode_string(kit.bindings["p%d" % (i + 1)]), data.name, "ON" if kit.passive_active(kit.loadout.passives[i]) else "OFF", MobaKit.UPKEEP.get(kit.loadout.passives[i], 0)], Rect2(x + 46, 430, 171, 42), 11, ui.TEAL, true)
	ui._label(ui.overlay, "Energy: %d / %d (+%.1f/s net) / Pet: %s / Release Tab to close a held inspection." % [kit.energy, kit.energy_max(), kit.energy_regen() - kit.drain_rate(), MobaKit.PETS[kit.loadout.pet]], Rect2(48, 485, 857, 22), 12, ui.MUTED)
