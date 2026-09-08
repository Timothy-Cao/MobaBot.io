extends SceneTree

var checks := 0
var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)
		push_error(message)

func fresh(precision: bool = false) -> SalvageRun:
	var run := SalvageRun.new()
	run.enable_moba(MobaKit.preset(precision))
	run.spawn_clock = 999
	run.pickups.clear()
	return run

func enemy(run: SalvageRun, offset: Vector2, hp: float = 1000) -> Dictionary:
	run.spawn_enemy(run.player + offset)
	var e: Dictionary = run.enemies.back()
	e.warmup = 0.0
	e.hp = hp
	e.max_hp = hp
	return e

func key(code: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = code as Key
	event.pressed = true
	return event

func _run() -> void:
	check(MobaKit.valid_loadout(MobaKit.preset()) and MobaKit.valid_loadout(MobaKit.preset(true)), "Both loadout presets are valid")
	var config := MobaKit.preset()
	config.w = config.q
	check(not MobaKit.valid_loadout(config), "Duplicate regular abilities rejected")
	config = MobaKit.preset()
	config.passives[0] = "orbit"
	check(not MobaKit.valid_loadout(config), "Duplicate passives rejected")
	config = MobaKit.preset()
	config.passives[1] = "magnet"
	check(not MobaKit.valid_loadout(config), "Ricochet requires orbit")
	config = MobaKit.preset()
	config.r = "salvo"
	check(not MobaKit.valid_loadout(config), "Ultimate category cannot contain a normal active")
	config = MobaKit.preset()
	config.pet = "two pets"
	check(not MobaKit.valid_loadout(config), "Unknown pet rejected")
	check(MobaKit.new({"bad": true}).loadout == MobaKit.preset(), "Bad saved loadout safely falls back")
	var keys := MobaKit.DEFAULT_BINDS.duplicate()
	keys.q = KEY_1
	keys.p1 = KEY_Q
	check(MobaKit.valid_bindings(keys), "Number key supported for an active")
	keys.q = KEY_S
	check(not MobaKit.valid_bindings(keys), "S reserved for stop")
	keys.q = KEY_R
	check(not MobaKit.valid_bindings(keys), "Duplicate bindings rejected")
	var run := fresh()
	var origin := run.player
	run.step(0.016, Vector2.RIGHT)
	check(run.player == origin, "Legacy movement vector ignored in MOBA mode")
	run.command_move(origin + Vector2(5, 0))
	run.step(0.1, Vector2.ZERO)
	check(run.player == origin + Vector2(5, 0) and not run.moving and run.velocity == Vector2.ZERO, "Click arrival never overshoots or drifts")
	run.command_move(run.player + Vector2(400, 0))
	run.step(0.1, Vector2.ZERO)
	check(is_equal_approx(run.player.x, origin.x + 25.5), "Move speed is immediate 205, without acceleration delay")
	run.stop_movement()
	origin = run.player
	run.step(0.1, Vector2.ZERO)
	check(run.player == origin and run.velocity == Vector2.ZERO, "Stop cancels the destination")
	run.command_move(Vector2(90000, 90000))
	check(run.move_target == SalvageRun.ARENA.end - Vector2.ONE * 16, "Move order clamps to arena")
	run = fresh()
	check(not run.kit.cast(run, "q", run.player + Vector2.RIGHT) and run.kit.charges.q == 3, "No-target salvo does not consume a charge")
	var e := enemy(run, Vector2(100, 0))
	check(run.kit.cast(run, "q", e.pos), "Homing salvo casts with a target")
	run.kit.step(run, 0.01)
	check(run.projectiles.size() == 1, "Salvo begins with one shot, not five instantaneous hits")
	for i in range(4):
		run.kit.step(run, 0.2)
	check(run.projectiles.size() == 5 and run.kit.salvos.is_empty(), "Five shots released over the one-second volley window")
	run.projectiles[0].vel = Vector2(0, 430)
	run._projectile_step(0.016)
	check(run.projectiles[0].vel.x > 0, "Homing projectile turns toward its target")
	run.kit.cast(run, "q", e.pos)
	run.kit.cast(run, "q", e.pos)
	check(run.kit.charges.q == 0 and not run.kit.cast(run, "q", e.pos), "Charge pool depletes at three casts")
	run.kit.step(run, float(run.kit.recharge.q) + 0.01)
	check(run.kit.charges.q == 1 and run.kit.recharge.q > 7.9, "Charges regenerate sequentially, one per eight seconds")
	run.kit.step(run, 40)
	check(run.kit.charges.q == 3 and run.kit.recharge.q == 0, "Long time step fills but never overfills pool")
	run.state = "upgrade"
	var before := run.kit.charges.duplicate()
	check(not run.kit.cast(run, "r", e.pos) and run.kit.charges == before, "Casts blocked while choosing an upgrade")
	run.step(10, Vector2.ZERO)
	check(run.kit.charges == before, "Paused model does not advance charges")
	run = fresh()
	e = enemy(run, Vector2(90, 0))
	run.kit.cast(run, "w", run.player)
	check(e.hp == 991 and Vector2(e.knock).length() == 280, "Self blast damages and knocks back without an aim requirement")
	run.kit.cast(run, "e", run.player)
	run.hurt_player(run.player)
	check(run.health == 5 and run.kit.shield == 0, "Shell absorbs exactly one hit")
	run.invincible = 0
	run.hurt_player(run.player)
	check(run.health == 4, "Consumed shell does not block the following hit")
	run = fresh()
	run.kit.cast(run, "d", run.player)
	check(is_equal_approx(run.kit.speed(), 338.25), "Sprint adds 65 percent movement speed")
	run.kit.cast(run, "r", run.player)
	check(is_equal_approx(run.kit.speed(), 389.5), "Sprint and overdrive speed bonuses add, not multiply")
	e = enemy(run, Vector2(150, 0))
	for i in range(300):
		run.kit.step(run, 1.0 / 60)
	check(run.damage_dealt.ultimate >= 45 and run.kit.overdrive < 0.001, "Overdrive emits timed damaging rings and expires")
	run = fresh()
	origin = run.player
	run.command_move(origin + Vector2(400, 0))
	run.kit.cast(run, "f", origin + Vector2(1000, 0))
	check(run.player == origin + Vector2(185, 0) and not run.moving, "Blink clamps distance and cancels old movement order")
	check(run.invincible > 0, "Blink grants brief arrival protection")
	run.player = SalvageRun.ARENA.end - Vector2.ONE * 20
	run.kit.cast(run, "f", run.player + Vector2(1000, 1000))
	check(SalvageRun.ARENA.has_point(run.player), "Blink stays inside map")
	run = fresh(true)
	e = enemy(run, Vector2(100, 0))
	run.kit.cast(run, "e", run.player + Vector2(170, 0))
	origin = run.player
	run.kit.move_dash(run, 0.09)
	check(is_equal_approx(run.player.x, origin.x + 85), "Dash travels over time, rather than teleporting")
	run.kit.move_dash(run, 0.3)
	check(run.player == origin + Vector2(170, 0) and e.hp == 988, "Dash clamps duration and hits each crossed target only once")
	check(run.kit.dash_left == 0 and run.velocity == Vector2.ZERO, "Dash finishes without drift")
	run = fresh(true)
	e = enemy(run, Vector2(120, 0))
	run.kit.cast(run, "q", e.pos)
	run._projectile_step(0.2)
	check(e.hp == 990 and run.projectiles[0].pierce == 2, "Rail spike has real damage and piercing collision")
	run = fresh(true)
	e = enemy(run, Vector2(120, 0))
	run.kit.cast(run, "w", e.pos)
	run.kit.step(run, 0.4)
	check(e.hp == 1000 and run.kit.zones.size() == 1, "Ground blast visibly waits before damage")
	run.kit.step(run, 0.16)
	check(e.hp == 984 and run.kit.zones.is_empty(), "Ground blast damages once at the selected ground point")
	run.kit.cast(run, "r", e.pos + Vector2(300, 0))
	check(is_equal_approx(Vector2(run.kit.zones[0].end).distance_to(run.player), 620), "Ultimate aim indicator and actual beam share full cast range")
	run.kit.step(run, 0.41)
	check(e.hp == 929 and run.damage_dealt.ultimate == 55, "Aimed ultimate hits along its telegraphed line")
	run = fresh()
	e = enemy(run, Vector2(120, 0))
	run.kit.cast(run, "t", run.player + Vector2(80, 0))
	var old: Vector2 = run.kit.summon.pos
	run.kit.step(run, 0.3)
	check(run.projectiles.any(func(b: Dictionary) -> bool: return b.kind == "summon"), "Stationary sentry automatically fires")
	run.kit.step(run, 10)
	run.kit.cast(run, "t", run.player + Vector2(-80, 0))
	check(run.kit.summon.pos != old and run.kit.summon.life == 18, "Redeploy replaces the one existing summon")
	run.kit.step(run, 19)
	check(run.kit.summon.is_empty(), "Summon expires")
	config = MobaKit.preset()
	config.t = "pylon"
	run = fresh()
	run.enable_moba(config)
	run.health = 3
	run.kit.cast(run, "t", run.player + Vector2(40, 0))
	run.kit.step(run, 5.01)
	check(run.health == 4, "Repair beacon heals nearby player on a five-second interval")
	run.player += Vector2(400, 0)
	run.kit.step(run, 5)
	check(run.health == 4, "Beacon cannot heal from outside its range")
	run = fresh(true)
	e = enemy(run, Vector2(100, 0))
	run.kit.step(run, 0.1)
	check(run.projectiles.any(func(b: Dictionary) -> bool: return b.kind == "pet"), "Single drone pet fires without another input")
	config = MobaKit.preset()
	config.passives = ["pulse", "magnet", "plating", "bolt"]
	run = fresh()
	run.enable_moba(config)
	check(run.kit.loadout == MobaKit.migrate_loadout(config) and not MobaKit.PASSIVES.has("magnet"), "Old magnet slot migrates to a combat passive; utility no longer occupies passive slots")
	run._drop(run.player, 8)
	run._pickup_step(0.1)
	check(run.orbit.is_empty() and run.pulse_damage() == 5, "Unequipped orbit cannot secretly activate; equipped pulse has a base effect")
	run._make_offers()
	check(not run.offers.has("grinder") and not run.offers.has("ricochet") and not run.offers.has("capacity"), "Offers exclude unequipped passive mechanics")
	run.hurt_player(run.player)
	check(is_equal_approx(run.invincible, 2.0), "Reactive plating extends post-hit invulnerability")
	check(run.upgrade_values("magnet")[0].value == run.magnet_radius(), "Passive-adjusted pickup stat matches UI preview")
	check(run.upgrade_values("pulse")[0].value == run.pulse_damage(), "Equipped base pulse matches rank-zero UI preview")
	for kind in [0, 1, 2, 3]:
		run = fresh()
		run.spawn_enemy(run.player, kind)
		run.hit_enemy(run.enemies[0], 999, "active")
		var expected: int = [1, 6, 48, 12][kind]
		check(run.pickups.size() == expected, "Correct loot shower count for enemy kind %d" % kind)
		run._pickup_step(0.016)
		check(run.total_xp == 0, "Loot scatters before collection for kind %d" % kind)
		for i in range(150):
			run._pickup_step(0.016)
		check(run.total_xp == expected, "Shower conserves and collects XP once for kind %d" % kind)
	run = fresh()
	for i in range(SalvageRun.MAX_PICKUPS):
		run._drop(run.player, 1)
	run.loot_shower(run.player, 48)
	var sum := 0
	for pickup in run.pickups:
		sum += pickup.value
	check(run.pickups.size() == SalvageRun.MAX_PICKUPS and sum == SalvageRun.MAX_PICKUPS + 48, "Loot overflow merges without losing rewards")
	for precision in [false, true]:
		for seed_number in range(3):
			run = SalvageRun.new(2407 + seed_number)
			run.enable_moba(MobaKit.preset(precision))
			for tick in range(5405):
				if run.state == "upgrade":
					run.choose_upgrade(seed_number % run.offers.size())
				if run.state != "running":
					break
				var desired := (Vector2(480, 300) + Vector2(cos(run.time * 0.1) * 270, sin(run.time * 0.1) * 125) - run.player).normalized()
				for target in run.enemies:
					var offset: Vector2 = run.player - target.pos
					if offset.length() < 95:
						desired += offset.normalized() * (1 - offset.length() / 95) * 3
				run.command_move(run.player + desired.normalized() * 120)
				if tick % 66 == 0:
					var target := run.nearest_enemy(run.player)
					if not target.is_empty():
						for slot in ["q", "w", "e", "r", "t"]:
							run.kit.cast(run, slot, target.pos)
				run.step(1.0 / 60, Vector2.ZERO)
				run.events.clear()
			check(run.state in ["won", "lost"], "MOBA preset simulation finishes")
			check(run.player.is_finite() and run.pickups.size() <= SalvageRun.MAX_PICKUPS and run.enemies.size() <= SalvageRun.MAX_ENEMIES and run.projectiles.size() <= SalvageRun.MAX_PROJECTILES, "MOBA simulated run respects bounds and object caps")
			print("MOBA_SIM ", JSON.stringify(run.summary()))
	var game := load("res://src/salvage/workshop.tscn").instantiate() as Node2D
	root.add_child(game)
	await process_frame
	# UI tests don't overwrite the user's saved keys or loadout.
	for connection in game.ui.loadout_changed.get_connections():
		game.ui.loadout_changed.disconnect(connection.callable)
	game.loadout_setting = MobaKit.preset()
	game.key_setting = MobaKit.DEFAULT_BINDS.duplicate()
	game.start_run()
	game.model.spawn_clock = 999
	game.model.pickups.clear()
	check(game.model.kit != null, "Main scene starts MOBA mode")
	game.model.command_move(game.model.player + Vector2(400, 0))
	game.mouse_moving = true
	game._input(key(KEY_S))
	origin = game.model.player
	game._physics_process(0.1)
	check(game.model.player == origin and not game.mouse_moving, "S latches stop even when RMB was held")
	game.model.kills = 17
	game._input(key(KEY_R))
	check(game.model.kills == 17 and game.model.kit.overdrive > 0, "R casts ultimate and does not restart")
	game._input(key(KEY_W))
	game._physics_process(0.1)
	check(game.model.player == origin, "W is an ability, never walking")
	var remaining: float = game.model.kit.recharge.r
	game._pause_toggle()
	game._physics_process(2)
	check(game.model.kit.recharge.r == remaining, "Controller pause freezes ultimate cooldown")
	game._pause_toggle()
	var aim_event := key(KEY_Q)
	aim_event.shift_pressed = true
	game._input(aim_event)
	var aim_charges: int = game.model.kit.charges.q
	check(game.pending_cast_slot == "q", "Shift plus ability enters aim preview without casting")
	game._input(key(KEY_ESCAPE))
	check(game.pending_cast_slot == "" and game.screen == "running" and game.model.kit.charges.q == aim_charges, "Escape cancels an aimed cast without pausing or spending a charge")
	enemy(game.model, Vector2(100, 0))
	game._input(aim_event)
	aim_event.pressed = false
	game._input(aim_event)
	check(game.pending_cast_slot == "" and game.model.kit.charges.q == aim_charges - 1, "Releasing the ability commits the aimed cast once")
	aim_event.pressed = true
	game._input(aim_event)
	game._pause_toggle()
	check(game.pending_cast_slot == "", "Pausing discards pending casts")
	game._pause_toggle()
	game._open_build()
	game.ui.build_page = "abilities"
	game.ui.show_build(game.model, false)
	game._physics_process(2)
	check(game.model.kit.recharge.r == remaining, "Ability inspector pauses cooldowns")
	game._close_build()
	game.model.player += Vector2(780, -390)
	game._update_camera()
	var local_cursor := Vector2(530, 220)
	var transformed: Vector2 = game.get_canvas_transform().affine_inverse() * local_cursor
	check(transformed.is_equal_approx(game.model.camera_origin() + local_cursor / game.zoom_value), "Cursor coordinates map through the following camera and saved zoom to world space")
	game.screen = "loadout"
	game.ui.key_config = MobaKit.DEFAULT_BINDS.duplicate()
	game.ui.rebind_slot = "q"
	game._input(key(KEY_1))
	check(game.ui.key_config.q == KEY_1 and game.ui.rebind_slot == "", "Key capture accepts number input")
	game.ui.rebind_slot = "w"
	game._input(key(KEY_1))
	check(game.ui.key_config.w == KEY_1 and game.ui.key_config.q == KEY_W, "Rebinding an occupied key swaps safely")
	game.ui.rebind_slot = "r"
	game._input(key(KEY_S))
	check(game.ui.key_config.r == KEY_R and game.ui.rebind_slot == "r", "Reserved stop key cannot be rebound")
	game._input(key(KEY_ESCAPE))
	check(game.ui.rebind_slot == "" and game.screen == "loadout", "Escape cancels capture without leaving the editor")
	for fixture in ["loadout", "passives", "keys", "gameplay", "build", "stats"]:
		game._fixture(fixture)
		await process_frame
		check(game.ui.overlay.get_child_count() > 0 or fixture == "gameplay", "New UI fixture loads: " + fixture)
	game.key_setting.q = KEY_1
	game.key_setting.p1 = KEY_Q
	game.start_run()
	game.model.spawn_clock = 999
	game.model.pickups.clear()
	e = enemy(game.model, Vector2(100, 0))
	game._input(key(KEY_1))
	check(game.model.kit.charges.q == 2, "Rebound number fires an ability in combat")
	game.model.total_xp = 8
	game._physics_process(0.016)
	var charges_before: int = game.model.kit.charges.q
	game._unhandled_key_input(key(KEY_1))
	check(game.screen == "running" and game.model.kit.charges.q == charges_before, "Number keys choose upgrades without casting through the menu")
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("MOBA TESTS: ", checks, " checks; ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)
