extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_scene := load("res://src/main/main.tscn") as PackedScene
	if packed_scene == null:
		_fail("Main scene could not be loaded.")
		return

	var game := packed_scene.instantiate()
	root.add_child(game)
	await process_frame

	var player := game.get_node_or_null("Player")
	var spawned_objects := game.get_node_or_null("SpawnedObjects")
	var hud := game.get_node_or_null("Hud")
	if player == null or spawned_objects == null or hud == null:
		_fail("Expected main-scene nodes are missing.")
		return
	if spawned_objects.get_child_count() != 3:
		_fail("A new round should spawn one collectible and two hazards.")
		return
	if not InputMap.has_action("move_left") or not InputMap.has_action("restart"):
		_fail("Required input actions are missing.")
		return
	if not _action_has_key("move_left", KEY_A, true) or not _action_has_key("move_left", KEY_LEFT, false):
		_fail("Move-left should support both A and Left Arrow.")
		return
	if not _action_has_key("move_right", KEY_D, true) or not _action_has_key("move_right", KEY_RIGHT, false):
		_fail("Move-right should support both D and Right Arrow.")
		return
	if not _action_has_key("move_up", KEY_W, true) or not _action_has_key("move_up", KEY_UP, false):
		_fail("Move-up should support both W and Up Arrow.")
		return
	if not _action_has_key("move_down", KEY_S, true) or not _action_has_key("move_down", KEY_DOWN, false):
		_fail("Move-down should support both S and Down Arrow.")
		return

	var collectible := get_first_node_in_group("collectibles") as StarCollectible
	collectible.collected.emit(collectible)
	await process_frame
	if game.get("score") != 1 or spawned_objects.get_child_count() != 3:
		_fail("Collecting a star should score once and spawn its replacement.")
		return

	var hazard := get_first_node_in_group("hazards") as HazardDrone
	hazard.player_hit.emit()
	if game.get("lives") != 2:
		_fail("A hazard signal should remove one shield.")
		return

	print("SMOKE TEST PASSED: scene, input, scoring, hazards, HUD, and spawns are ready.")
	game.queue_free()
	quit(0)


func _fail(message: String) -> void:
	push_error("SMOKE TEST FAILED: " + message)
	quit(1)


func _action_has_key(action: StringName, keycode: int, use_physical: bool) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var key_event := event as InputEventKey
			if use_physical and key_event.physical_keycode == keycode:
				return true
			if not use_physical and key_event.keycode == keycode:
				return true
	return false
