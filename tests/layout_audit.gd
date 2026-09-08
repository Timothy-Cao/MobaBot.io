extends SceneTree
var issues: Array[String] = []
var labels_checked := 0
func _init() -> void: call_deferred("_run")

func audit(node: Node, context: String) -> void:
	if node is Label and node.is_visible_in_tree() and node.has_meta("layout_rect") and not node.text.is_empty():
		labels_checked += 1
		var intended: Rect2 = node.get_meta("layout_rect")
		var font: Font = node.get_theme_font("font")
		var font_size: int = node.get_theme_font_size("font_size")
		if node.autowrap_mode == TextServer.AUTOWRAP_OFF:
			for line in node.text.split("\n"):
				var width := font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
				if width > intended.size.x + 2:
					var issue := "%s: %.0f > %.0f: %s" % [context, width, intended.size.x, line]
					if issue not in issues: issues.append(issue)
	for child in node.get_children(): audit(child, context)

func _run() -> void:
	var game := load("res://src/salvage/workshop.tscn").instantiate() as Node2D
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	for name in ["home", "gameplay", "upgrade", "pause", "result", "build", "stats", "loadout", "passives", "keys", "abilities", "stage_reward", "settings", "utility", "utility_tree", "weapons", "milestone", "milestone_tree", "demo_recovery", "death_recap"]:
		game.show_home()
		game._fixture(name)
		await process_frame
		audit(game.ui.root, name)
	game.start_run()
	for precision in [false, true]:
		game.model.enable_moba(MobaKit.preset(precision))
		game.model.enable_demo()
		for id in game.model.upgrade_ids():
			for rank_value in [1, 5, 10]:
				if rank_value > game.model.upgrade_data(id).max: continue
				game.ui.show_build(game.model)
				game.ui.selected_item = id
				game.ui.selected_rank = rank_value
				game.ui.show_build(game.model, false)
				await process_frame
				audit(game.ui.root, "%s rank %d" % [id, rank_value])
	for issue in issues: print("LAYOUT_ISSUE ", issue)
	print("LAYOUT AUDIT: ", labels_checked, " visible labels; ", issues.size(), " width issues")
	game.queue_free()
	await process_frame
	quit(0 if issues.is_empty() else 1)
