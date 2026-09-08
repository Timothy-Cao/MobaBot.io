extends SceneTree
var checks := 0
var failures := 0

func _init() -> void: call_deferred("_run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func fresh() -> SalvageRun:
	var run := SalvageRun.new()
	run.enable_moba()
	run.enable_demo()
	run.pickups.clear()
	return run

func _run() -> void:
	var run := fresh()
	for i in range(run.MAX_PROJECTILES): run._add_projectile(run.player, Vector2.RIGHT, 1, "bolt", 0)
	DemoCampaign.spawn_special(run, "foreman")
	var boss: Dictionary = run.enemies.back()
	boss.pos = run.player - Vector2(200, 0)
	boss.phase = "telegraph"
	boss.attack = "fan"
	boss.clock = 0.01
	boss.dir = Vector2.RIGHT
	DemoCampaign.enemy_step(run, boss, 0.02)
	check(run.projectiles.size() == run.MAX_PROJECTILES, "Threat reservation never exceeds pool cap")
	check(run.projectiles.filter(func(b: Dictionary) -> bool: return b.kind == "hostile").size() == 7, "Full friendly pool cannot erase promised seven-shot boss fan")
	run.projectiles.clear()
	for i in range(run.MAX_PROJECTILES): run._add_projectile(run.player, Vector2.RIGHT, 1, "hostile", 0)
	run._add_projectile(run.player, Vector2.RIGHT, 1, "hostile", 0)
	check(run.projectiles.size() == run.MAX_PROJECTILES, "Fully hostile pool stays bounded")
	run = fresh()
	run.kit.shield = 1
	run.kit.shield_hits = 1
	run.hurt_player(run.player + Vector2.RIGHT, "Foreman charge")
	check(run.last_damage.is_empty() and run.damage_history.is_empty(), "Shield blocks do not falsely claim hull damage")
	run.invincible = 0
	run.hurt_player(run.player + Vector2.RIGHT, "Foreman charge")
	check(run.last_damage == "Foreman charge" and run.last_damage_direction == Vector2.RIGHT, "Damage records source and direction")
	run.hurt_player(run.player, "Artillery blast")
	check(run.damage_history.size() == 1 and run.last_damage == "Foreman charge", "Invulnerability cannot overwrite last real hit")
	check(CombatReadability.hint(run.last_damage).contains("sideways"), "Charge recap suggests the relevant response")
	check(CombatReadability.hint("Artillery blast").contains("marked ground"), "Ground recap suggests the relevant response")
	check(CombatReadability.hint("Hostile projectile").contains("gap"), "Projectile recap suggests the relevant response")
	for i in range(40):
		run.invincible = 0
		run.health = 5
		run.hurt_player(run.player, "Bumper contact")
	check(run.damage_history.size() == 32 and run.summary().recent_damage.size() == 32, "Run damage diagnostics stay bounded and serialize")
	run = fresh()
	DemoCampaign.spawn_special(run, "rammer")
	var ram: Dictionary = run.enemies.back()
	DemoCampaign.spawn_special(run, "artillery")
	var artillery: Dictionary = run.enemies.back()
	for zoom in [0.65, 1.0]:
		run.view_size = Vector2(960, 540) / zoom
		for position in [Vector2(480, 300), run.ARENA.position + Vector2(20, 20), run.ARENA.end - Vector2(20, 20)]:
			run.player = position
			for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2(1, 1)]:
				ram.pos = run.player + direction * 1700
				artillery.pos = run.player - direction * 1700
				var markers := CombatReadability.markers(run)
				check(markers.size() == 2, "Both required targets remain findable")
				check(markers.all(func(m: Dictionary) -> bool: return m.pos.is_finite() and CombatReadability.SAFE_VIEW.grow(0.1).has_point(m.pos)), "Markers remain outside HUD at zoom and world edges")
	run.player = Vector2(480, 300)
	run.view_size = Vector2(960, 540)
	ram.pos = run.player + Vector2(100, 0)
	artillery.pos = run.player + Vector2(200, 0)
	check(CombatReadability.markers(run).is_empty(), "Visible enemies have no redundant edge marker")
	check(CombatReadability.nearest_objective(run).id == ram.id, "HUD selects nearest objective")
	ram.dead = true
	check(CombatReadability.nearest_objective(run).id == artillery.id, "Dead objective immediately hands off HUD")
	var game := load("res://src/salvage/workshop.tscn").instantiate() as Node2D
	root.add_child(game)
	await process_frame
	game.persist_settings = false
	game.camera_locked = true
	game.r_quickcast = false
	var first_focus: Control = root.gui_get_focus_owner()
	var tab := InputEventKey.new()
	tab.keycode = KEY_TAB
	tab.pressed = true
	Input.parse_input_event(tab)
	await process_frame
	check(root.gui_get_focus_owner() != first_focus and game.screen == "home", "Tab navigates main-menu buttons instead of being swallowed by inspection")
	tab.pressed = false
	Input.parse_input_event(tab)
	await process_frame
	game.key_setting = MobaKit.DEFAULT_BINDS.duplicate()
	game.key_setting.q = KEY_1
	game.key_setting.p1 = KEY_Q
	game.start_run()
	game._drain_events()
	check(game.ui.notice.text == "Loading bay" and game.model.kit.bindings.q == KEY_1, "Opening label stays clean and saved rebinding remains intact")
	game.ui.announce("Boss warning", 2)
	game.ui.announce("Scrap cache")
	check(game.ui.notice.text == "Boss warning", "Routine loot cannot replace critical warning")
	game.ui.notice_time = 0
	game.ui.announce("Scrap cache")
	check(game.ui.notice.text == "Scrap cache", "Expired warning releases notice priority")
	game.start_run()
	check(game.ui.notice.text == "Loading bay", "Restart resets previous announcement priority")
	game.screen = "upgrade"
	var combat_time: float = game.model.time
	game._record_screen_time(4)
	check(game.screen_seconds.upgrade == 4 and game.model.time == combat_time, "Choice dwell time records separately without advancing combat")
	game.screen = "paused"
	game._record_screen_time(2)
	check(game.screen_seconds.paused == 2 and game.run_wall_seconds >= 6, "Pause time remains distinguishable from upgrade time")
	game.start_run()
	check(game.screen_seconds.is_empty() and game.run_wall_seconds == 0, "New run resets timing diagnostics")
	game.model.hurt_player(game.model.player + Vector2.LEFT, "Artillery blast")
	game.ui.update_hud(game.model)
	check(game.ui.damage_label.visible and game.ui.damage_label.text.contains("Artillery blast"), "HUD explains actual hull loss")
	game.model.time += 3
	game.ui.update_hud(game.model)
	check(not game.ui.damage_label.visible, "Damage text expires without filling the HUD permanently")
	game.sound.set_muted(false)
	game.sound.receive({"kind": "boss_windup"})
	var important_stream: AudioStream = game.sound.players[9].stream
	for i in range(20):
		game.sound.cooldowns.clear()
		game.sound.receive({"kind": "pickup"})
	check(game.sound.players[9].stream == important_stream and game.sound.cursor < 9, "Pickup burst cannot steal the reserved warning voice")
	for fixture in ["wardens", "threats", "damage", "death_recap"]:
		game._fixture(fixture)
		await process_frame
		check(game.model.demo_mode, "Readability fixture loads: " + fixture)
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("READABILITY TESTS: ", checks, " checks; ", failures, " failures")
	quit(0 if failures == 0 else 1)
