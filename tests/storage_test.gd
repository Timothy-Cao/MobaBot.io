extends SceneTree
## Opt-in integration check; saves current preferences without changing them.

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var game := load("res://src/salvage/workshop.tscn").instantiate() as Node2D
	root.add_child(game)
	await process_frame
	game._save_settings()
	var config := ConfigFile.new()
	var valid := config.load("user://salvage_settings.cfg") == OK
	valid = valid and config.get_value("audio", "muted", null) == game.mute_setting
	valid = valid and config.get_value("visual", "reduced_effects", null) == game.reduced_setting
	valid = valid and config.get_value("moba", "loadout", {}) == game.loadout_setting
	valid = valid and config.get_value("moba", "keys", {}) == game.key_setting
	valid = valid and is_equal_approx(config.get_value("visual", "zoom", 1.0), game.zoom_value)
	var records := FileAccess.open("user://salvage_runs.jsonl", FileAccess.READ)
	var last: Dictionary = {}
	if records != null:
		while not records.eof_reached():
			var line := records.get_line()
			if not line.is_empty():
				var record: Variant = JSON.parse_string(line)
				if record is Dictionary:
					last = record
	valid = valid and last.get("result", "") in ["won", "lost"] and last.get("build", "") in ["slice-01", "slice-02", "slice-03", "slice-04", "slice-05", "slice-06-demo", "slice-07-demo", "slice-08-demo", "slice-09-mobabot", "slice-10-mobabot"]
	valid = valid and config.get_value("visual", "camera_locked", null) == game.camera_locked
	valid = valid and config.get_value("moba", "r_quickcast", null) == game.r_quickcast
	print("STORAGE TEST: ", "PASS" if valid else "FAIL", " preferences and completed run readback; directory=", OS.get_user_data_dir())
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	quit(0 if valid else 1)
