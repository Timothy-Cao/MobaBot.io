extends SceneTree
var checks := 0
var failures := 0
func _init() -> void: call_deferred("_run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func nodes(node: Node) -> Array[Node]:
	var result: Array[Node] = [node]
	for child in node.get_children(): result.append_array(nodes(child))
	return result
func button(node: Node, label: String) -> Button:
	for child in nodes(node):
		if child is Button and child.text == label: return child
	return null
func tagged(node: Node, tag: String, value: String) -> Button:
	for child in nodes(node):
		if child is Button and child.get_meta(tag, "") == value: return child
	return null
func key(code: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	return event
func _run() -> void:
	var game := load("res://src/salvage/workshop.tscn").instantiate() as Node2D
	root.add_child(game)
	await process_frame
	game.persist_settings = false
	game.ui.persist_equipment = false
	game.auto_play = true
	game.set_physics_process(false)
	game.show_home()
	check(nodes(game.ui.overlay).filter(func(n: Node) -> bool: return n is Button).size() == 5, "Home has five essential actions")
	check(button(game.ui.overlay, "Mastery") == null, "No title-screen mastery preview")
	game._open_settings()
	check(nodes(game.ui.overlay).filter(func(n: Node) -> bool: return n.has_meta("setting")).size() == 4, "Options contains four preferences")
	check(nodes(game.ui.overlay).all(func(n: Node) -> bool: return not n is HSlider), "No redundant zoom slider")
	for setting in ["Sound", "Reduced effects", "Camera lock", "Area quick cast"]:
		var option := tagged(game.ui.overlay, "setting", setting)
		var before := option.text
		option.grab_focus()
		option.pressed.emit()
		check(tagged(game.ui.overlay, "setting", setting).text != before, setting + " toggles")
		check(tagged(game.ui.overlay, "setting", setting).has_focus(), setting + " retains focus")
	button(game.ui.overlay, "Controls").pressed.emit()
	check(nodes(game.ui.overlay).filter(func(n: Node) -> bool: return n.has_meta("bind_slot")).size() == 11, "All eleven bindings remain accessible")
	tagged(game.ui.overlay, "bind_slot", "q").pressed.emit()
	game._input(key(KEY_Z))
	check(game.ui.key_config.q == KEY_Z and game.screen == "settings", "Rebinding stays in Settings")
	tagged(game.ui.overlay, "bind_slot", "q").pressed.emit()
	game._input(key(KEY_A))
	check(game.ui.key_config.q == KEY_Z and game.ui.rebind_slot == "q", "Reserved key is rejected without leaving controls")
	game._input(key(KEY_ESCAPE))
	check(game.ui.rebind_slot.is_empty() and game.screen == "settings", "Escape cancels binding before closing settings")
	button(game.ui.overlay, "Reset keys").pressed.emit()
	check(game.ui.key_config == MobaKit.DEFAULT_BINDS, "Reset restores bindings only")
	game._close_settings()
	check(game.screen == "home", "Settings returns to home")
	button(game.ui.overlay, "Loadout").pressed.emit()
	check(button(game.ui.overlay, "Utility") == null and button(game.ui.overlay, "Keys") == null, "Loadout removes utility and duplicate bindings tabs")
	check(button(game.ui.overlay, "Abilities") != null and button(game.ui.overlay, "Passives") != null, "Core loadout choices remain")
	game.start_run()
	game._open_build()
	check(game.ui.build_page == "overview", "Build opens the compact overview")
	for old_page in ["Stats", "Upgrades", "Abilities", "Gear"]:
		check(button(game.ui.overlay, old_page) == null, "Removed build navigation: " + old_page)
	check(nodes(game.ui.overlay).filter(func(n: Node) -> bool: return n.has_meta("core_stat")).size() == 6, "Overview shows only six core stat rows")
	check(nodes(game.ui.overlay).filter(func(n: Node) -> bool: return n.has_meta("overview_slot")).size() == 7, "All equipped active slots can be inspected")
	tagged(game.ui.overlay, "overview_slot", "q").pressed.emit()
	await process_frame
	var detail := game.ui.overlay.get_node_or_null("BuildDetail") as Control
	check(detail != null and detail.visible, "Click or keyboard activation opens ability details")
	var navigate := InputEventAction.new()
	navigate.action = "ui_down"
	navigate.pressed = true
	root.push_input(navigate)
	await process_frame
	check(root.gui_get_focus_owner() == detail.get_node("DetailBack"), "Detail focus cannot activate controls behind the modal")
	if detail != null: game._input(key(KEY_ESCAPE))
	await process_frame
	check(game.screen == "build" and not game.ui.overlay.has_node("BuildDetail"), "Escape dismisses details before the build screen")
	button(game.ui.overlay, "Mastery").pressed.emit()
	var points: int = game.model.mastery.available(game.model.level)
	tagged(game.ui.overlay, "mastery_id", "reach").pressed.emit()
	check(game.model.mastery.available(game.model.level) == points - 1, "Mastery spending preserved")
	game._close_build()
	game._open_settings()
	check(button(game.ui.overlay, "Main menu") != null, "In-run settings keeps an exit")
	button(game.ui.overlay, "Main menu").pressed.emit()
	await process_frame
	var confirmations := nodes(game.ui).filter(func(n: Node) -> bool: return n is ConfirmationDialog)
	check(confirmations.size() == 1 and game.screen == "settings", "Leaving run requires confirmation")
	if not confirmations.is_empty():
		confirmations[0].canceled.emit()
	await process_frame
	check(game.screen == "settings", "Cancel leave preserves paused run")
	game._close_settings()
	check(game.screen == "running", "Back resumes the same run")
	game.sound.set_muted(true)
	game.music_player.shutdown()
	await create_timer(0.2).timeout
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	print("MOBABOT 13 TESTS: ", checks, " checks; ", failures, " failures")
	quit(0 if failures == 0 else 1)
