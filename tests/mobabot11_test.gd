extends SceneTree
var checks := 0
var failures := 0
func _init() -> void: call_deferred("_run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func button(parent: Node, label: String) -> Button:
	for node in parent.get_children():
		if node is Button and node.text == label: return node
	return null
func tagged(parent: Node, tag: String, value: Variant) -> Button:
	for node in parent.get_children():
		if node is Button and node.has_meta(tag) and node.get_meta(tag) == value: return node
	return null
func fresh() -> SalvageRun:
	var run := SalvageRun.new(1111)
	run.enable_moba(MobaKit.demo_preset())
	run.enable_demo()
	return run
func _run() -> void:
	var art := Image.load_from_file(ProjectSettings.globalize_path("res://assets/menu/foundry-bay-v1.png"))
	check(art != null and art.get_size() == Vector2i(1672, 941), "Menu artwork dimensions")
	check(art.detect_alpha() == Image.ALPHA_NONE, "Opaque illustration contains no unintended transparency")
	var gear := BotEquipment.new()
	gear.inventory.reactor.copies = 1
	gear.inventory.reactor.bonus = "damage"
	gear.inventory.reactor.roll = 5
	gear.inventory.coil.stars = 2
	var delta := gear.compare_to_fitted("reactor")
	check(delta.damage > 0 and delta.regen < 0, "Comparison shows both gain and sacrificed affix")
	check(gear.compare_to_fitted("coil").is_empty(), "Fitted item has no phantom improvement")
	for id in BotEquipment.ITEMS:
		for bonus in ["damage", "regen", "drop"]:
			gear.inventory[id].bonus = bonus
			gear.inventory[id].roll = 4
			var run := fresh()
			gear.equipped[BotEquipment.ITEMS[id].slot] = id
			var expected := {"damage": 0.0, "energy": 0.0, "speed": 0.0, "regen": 0.0, "drop": 0.0}
			for fitted in gear.equipped.values():
				var values := gear.stats_for(fitted)
				for stat in expected: expected[stat] += values[stat]
			gear.apply_to(run)
			for pair in [[run.kit.gear_damage, expected.damage], [run.kit.energy_bonus, expected.energy], [run.kit.gear_speed, expected.speed], [run.kit.regen_bonus, expected.regen], [run.drop_bonus, expected.drop]]:
				check(is_equal_approx(pair[0], pair[1]), "Inspector matches simulation: " + id + "/" + bonus)
	var run := fresh()
	run.kit.gear_damage = 0.23
	run.kit.mastery_damage = 0.18
	for slot in MobaKit.SLOTS:
		for rank_value in [0, 4, 5, 10]:
			run.kit.ranks[slot] = rank_value
			run.kit.tiers[slot] = 0
			for tier in [1, 2]:
				var predicted := run.kit.damage_scale_at(slot, rank_value, tier)
				run.kit.promote(slot)
				check(is_equal_approx(predicted, run.kit.damage_scale(slot)), "Promotion preview matches applied damage")
	var game := load("res://src/salvage/workshop.tscn").instantiate() as Node2D
	root.add_child(game)
	await process_frame
	game.persist_settings = false
	game.auto_play = true
	game.set_physics_process(false)
	game.ui.persist_equipment = false
	game.gear = BotEquipment.new()
	game.show_home()
	check(game.ui.overlay.get_node_or_null("FoundryBackdrop") != null, "Home uses full-bleed illustration")
	for label in ["Play", "Loadout", "Equipment", "Settings", "Quit"]:
		check(button(game.ui.overlay, label) != null, "Home action exists: " + label)
	var play := button(game.ui.overlay, "Play")
	check(play.has_focus(), "Play receives initial keyboard focus")
	var nav := InputEventAction.new()
	nav.action = "ui_down"
	nav.pressed = true
	root.push_input(nav)
	await process_frame
	check(root.gui_get_focus_owner() != play, "Native directional navigation moves focus")
	check(button(game.ui.overlay, "Mastery") == null, "Home omits the nonessential mastery preview route")
	game._open_build()
	game.ui.build_page = "mastery"
	game.ui.show_build(game.ui.build_model, false)
	check(game.screen == "build" and game.ui.build_page == "mastery", "Retained preview supports internal inspection")
	var preview = game.ui.build_model
	check(preview.mastery.read_only, "Home mastery is read-only")
	tagged(game.ui.overlay, "mastery_id", "reach").pressed.emit()
	check(preview.mastery.rank_of("reach") == 0, "Preview does not spend points")
	game.show_home()
	button(game.ui.overlay, "Equipment").pressed.emit()
	check(game.screen == "equipment", "Equipment route works")
	tagged(game.ui.overlay, "equipment_id", "reactor").pressed.emit()
	check(tagged(game.ui.overlay, "equipment_action", "equip").disabled, "Unowned item cannot equip")
	tagged(game.ui.overlay, "equipment_id", "coil").pressed.emit()
	tagged(game.ui.overlay, "equipment_action", "star").pressed.emit()
	check(game.gear.inventory.coil.stars == 1 and game.gear.credits == 125, "Fixture star transaction uses memory only")
	game.show_home()
	button(game.ui.overlay, "Loadout").pressed.emit()
	check(game.screen == "loadout", "Loadout route works")
	game.show_home()
	button(game.ui.overlay, "Settings").pressed.emit()
	check(game.screen == "settings", "Settings route works")
	game.show_home()
	button(game.ui.overlay, "Play").pressed.emit()
	check(game.screen == "running", "Play starts a run")
	game.model.level = 13
	game.ui.show_build(game.model)
	game.ui.build_page = "mastery"
	game.ui.show_build(game.model, false)
	var hull := tagged(game.ui.overlay, "mastery_id", "hull")
	hull.grab_focus()
	check(game.ui.mastery_focus == "hull", "Keyboard focus updates stable inspector")
	hull.pressed.emit()
	check(game.model.mastery.rank_of("hull") == 1, "Mastery purchase applies")
	check(tagged(game.ui.overlay, "mastery_id", "hull").has_focus(), "Purchase preserves keyboard focus")
	check(game.ui.overlay.z_index > 2, "All overlay content stays above raised HUD labels")
	game.ui.show_running()
	game.model.health = 1
	var before: int = game.model.consumables[0]
	game.ui.consumable_requested.emit(0)
	check(game.model.health > 1 and game.model.consumables[0] == before - 1, "HUD consumable dispatch heals during combat")
	game.screen = "paused"
	before = game.model.consumables[0]
	game.ui.consumable_requested.emit(0)
	check(game.model.consumables[0] == before, "Consumable click blocked while paused")
	game.ui.update_hud(game.model)
	game.model.kit.elapsed = 120
	game.model.kit.toggles[2] = true
	game.model.kit.arc_focused = true
	game.ui.update_hud(game.model)
	var passive_label: Label = game.ui.toggle_labels[2]
	check(passive_label.get_theme_font("font").get_string_size(passive_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, passive_label.get_theme_font_size("font_size")).x <= 35, "Focused lightning label fits its compact tile")
	check(game.ui.mission_rail.stage == game.model.stage and game.ui.mission_rail.progress >= 0 and game.ui.mission_rail.progress <= 1, "Mission rail tracks current encounter")
	game.music_player.update_context("home", game.model, false)
	for voice in game.music_player.voices: check(voice.stream == null, "Dummy driver does not retain MP3 streams")
	game.music_player.shutdown()
	game.sound.set_muted(true)
	await create_timer(0.2).timeout
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	print("MOBABOT 11 TESTS: ", checks, " checks; ", failures, " failures")
	quit(0 if failures == 0 else 1)
