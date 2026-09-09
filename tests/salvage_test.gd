extends SceneTree

var failures: Array[String] = []
var checks := 0

func _init() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error(message)

func fresh(mode: String = "salvage") -> SalvageRun:
	var run := SalvageRun.new(2407, mode)
	run.pickups.clear()
	run.spawn_clock = 9999
	return run

func target(run: SalvageRun, point: Vector2, kind: int = 0) -> Dictionary:
	run.spawn_enemy(point, kind)
	var enemy: Dictionary = run.enemies.back()
	enemy.warmup = 0.0
	return enemy

func _run() -> void:
	var run := fresh()
	check(run.health == 5 and run.state == "running", "Fresh run defaults")
	run._drop(run.player, 20)
	var pickup: Dictionary = run.pickups[0]
	run.collect_pickup(pickup)
	run.collect_pickup(pickup)
	check(run.total_xp == 20 and run.collected == 20, "Pickup claimed exactly once")
	check(run.orbit.size() == 6, "Orbit respects capacity without losing XP")
	run.step(1.0 / 60, Vector2.ZERO)
	check(run.state == "upgrade" and run.offers == ["grinder", "ricochet", "pulse"], "First choice teaches salvage branches")
	var frozen_time := run.time
	run.step(2, Vector2.RIGHT)
	check(run.time == frozen_time, "Upgrade menu freezes simulation")
	check(not run.choose_upgrade(9) and run.choose_upgrade(0), "Upgrade bounds and application")
	check(run.rank_of("grinder") == 1 and run.orbit[0].hits == 2, "Grinder upgrades existing tools")
	check(run.total_xp == 20 and run.level == 2, "Upgrades preserve cumulative XP")

	run = fresh()
	var enemy := target(run, run.player + Vector2(70, 0))
	run.hit_enemy(enemy, 99, "bolt")
	run.hit_enemy(enemy, 99, "orbit")
	check(run.kills == 1 and run.pickups.size() == 1 and run.damage_dealt.bolt == 3, "Kills and damage cannot double count")
	run = fresh()
	for i in range(SalvageRun.MAX_PICKUPS + 20):
		run._drop(Vector2(i, 120), 1)
	var value := 0
	for item in run.pickups:
		value += int(item.value)
	check(run.pickups.size() == SalvageRun.MAX_PICKUPS and value == SalvageRun.MAX_PICKUPS + 20, "Pickup cap merges rewards without discarding XP")

	run = fresh()
	enemy = target(run, Vector2(500, 300))
	run._add_projectile(Vector2(400, 300), Vector2(10000, 0), 4, "bolt", 0)
	run._projectile_step(0.02)
	check(run.kills == 1 and run.projectiles.is_empty(), "Swept collision catches fast projectile crossing")
	run = fresh()
	var far := target(run, Vector2(560, 300))
	var near := target(run, Vector2(460, 300))
	run._add_projectile(Vector2(400, 300), Vector2(10000, 0), 4, "bolt", 0)
	run._projectile_step(0.02)
	check(near.dead and not far.dead, "Non-piercing bolt hits near target despite reverse spawn order")
	run = fresh()
	enemy = target(run, Vector2(-12, 300))
	run._add_projectile(Vector2(-50, 300), Vector2(2000, 0), 4, "bolt", 0)
	run._projectile_step(0.04)
	check(enemy.dead, "Spatial index handles negative edge cells")
	run = fresh()
	run.orbit.append({"slot": 0, "hits": 1, "cooldown": 0.0})
	run.upgrades.ricochet = 1
	enemy = target(run, run.orbit_position(0))
	target(run, Vector2(620, 300))
	run._orbit_step(0.016)
	check(run.kills == 1 and run.orbit.is_empty(), "Orbit kills and consumes a tool")
	check(run.projectiles.size() == 1 and run.projectiles[0].kind == "shard", "Spent tool creates ricochet shard")
	run._projectile_step(0.2)
	check(run.kills == 2, "Ricochet shard can kill another target")

	run = fresh()
	run.upgrades.pulse = 1
	run.pulse_charge = 7
	target(run, run.player + Vector2(55, 0))
	run._drop(run.player, 1)
	run._pickup_step(0.016)
	check(run.kills == 1 and run.total_xp == 1 and run.pickups.size() == 1, "Pulse creates new drops without recursive pickup mutation")
	check(run.pulse_charge == 0 and run.damage_dealt.pulse == 3, "Pulse charge and damage tracked")
	run = fresh()
	run.upgrades.pulse = 1
	run._drop(run.player, 24)
	run._pickup_step(0)
	check(run.pending_pulses == 2, "Bulk scrap preserves all earned pulse charges")
	run._pulse_step(0.16)
	run._pulse_step(0.16)
	check(run.pending_pulses == 0 and run.events.filter(func(e: Dictionary) -> bool: return e.kind == "pulse").size() == 3, "Bulk pulses are staggered and resolve exactly once per eight scrap")
	run = fresh("baseline")
	run._drop(run.player, 30)
	run._pickup_step(0.016)
	run.step(0.016, Vector2.ZERO)
	check(run.orbit.is_empty() and run.offers.size() == 3, "Baseline gets XP and choices but no orbit")
	for id in run.offers:
		check(id in ["power", "rapid", "magnet"], "Baseline choice is applicable")
	for id in SalvageRun.UPGRADES:
		run.upgrades[id] = SalvageRun.UPGRADES[id].max
	run.level = 20
	run._make_offers()
	check(run.offers == ["repair"], "Maxed build has repair fallback")

	run = fresh()
	run.hurt_player(run.player)
	run.hurt_player(run.player)
	check(run.health == 4 and run.damage_taken == 1, "Contact grants invulnerability")
	run.health = 1
	run.invincible = 0
	run.hurt_player(run.player)
	check(run.state == "lost", "Zero hull ends run")
	run = fresh()
	run.time = 89.995
	run.total_xp = 100
	run.step(0.016, Vector2.ZERO)
	check(run.state == "won", "Ninety-second finish precedes upgrade menu")

	var a := fresh()
	var b := fresh()
	a.spawn_clock = 0
	b.spawn_clock = 0
	for i in range(300):
		var direction := Vector2.from_angle(i * 0.02)
		a.step(1.0 / 60, direction)
		b.step(1.0 / 60, direction)
	check(a.enemies == b.enemies and a.player == b.player, "Same seed and inputs are deterministic")

	run = fresh()
	check(SalvageRun.ARENA.size.x > 960 * 5 and SalvageRun.ARENA.size.y > 540 * 5, "World spans multiple screens at unchanged zoom")
	var initial_camera := run.camera_origin()
	run.player += Vector2(900, 700)
	check(run.camera_origin() - initial_camera == Vector2(900, 700), "Camera follows world movement at 1:1 scale")
	run.spawn_clock = 0
	run._spawn_step(0.016)
	check(not Rect2(run.camera_origin(), Vector2(960, 540)).has_point(run.enemies[0].pos), "Enemies spawn outside the moving camera")
	run.player = SalvageRun.ARENA.end - Vector2.ONE * 16
	check(run.camera_origin() == SalvageRun.ARENA.end - Vector2(960, 540), "Camera clamps to distant world boundary")
	run.player = run.caches[0].pos
	run._cache_step()
	run._cache_step()
	check(run.caches_opened == 1 and run.pickups.size() == 8, "Exploration cache opens once and yields eight scrap")
	for id in SalvageRun.UPGRADES:
		var maximum: int = SalvageRun.UPGRADES[id].max
		for r in range(maximum + 1):
			var rows := run.upgrade_values(id, r)
			check(not rows.is_empty(), "Stat preview defined: %s rank %d" % [id, r])
			if r < maximum:
				var next_rows := run.upgrade_values(id, r + 1)
				for row in range(rows.size()):
					check(next_rows[row].value > rows[row].value, "Rank preview increases actual stat: " + id)
		run.upgrades[id] = maximum
	check(run.bolt_damage() == run.upgrade_values("power")[0].value, "Displayed bolt damage equals combat formula")
	check(is_equal_approx(snappedf(1.0 / run.fire_interval(), 0.01), run.upgrade_values("rapid")[0].value), "Displayed fire rate equals combat formula")
	check(run.orbit_damage() == run.upgrade_values("grinder")[0].value and run.capacity() == run.upgrade_values("capacity")[0].value, "Orbit stats match combat rules")
	check(run.shard_damage() == run.upgrade_values("ricochet")[0].value and run.pulse_damage() == run.upgrade_values("pulse")[0].value, "Secondary damage previews match combat rules")

	var max_tick_us := 0
	var started := Time.get_ticks_usec()
	for mode in ["salvage", "baseline"]:
		for seed_number in range(3):
			run = SalvageRun.new(2407 + seed_number, mode)
			for i in range(5405):
				if run.state == "upgrade":
					run.choose_upgrade(seed_number % run.offers.size())
				if run.state in ["won", "lost"]:
					break
				var destination := Vector2(480, 300) + Vector2(cos(run.time * 0.1) * 270, sin(run.time * 0.1) * 125)
				var desired := (destination - run.player).normalized()
				for e in run.enemies:
					var offset := run.player - Vector2(e.pos)
					if offset.length() < 95:
						desired += offset.normalized() * (1.0 - offset.length() / 95.0) * 3
				var tick := Time.get_ticks_usec()
				run.step(1.0 / 60, desired.normalized())
				max_tick_us = maxi(max_tick_us, Time.get_ticks_usec() - tick)
				run.events.clear()
			check(run.state in ["won", "lost"], "Automated run reaches a terminal state")
			check(run.player.is_finite() and SalvageRun.ARENA.has_point(run.player), "Player stays finite and in bounds")
			check(run.enemies.size() <= SalvageRun.MAX_ENEMIES and run.projectiles.size() <= SalvageRun.MAX_PROJECTILES and run.pickups.size() <= SalvageRun.MAX_PICKUPS, "Simulation respects object caps")
			print("SIMULATION ", JSON.stringify(run.summary()))
	print("SIM_BENCH six runs wall_ms=", (Time.get_ticks_usec() - started) / 1000.0, " max_tick_us=", max_tick_us)

	# Deliberately exceed expected slice density; report actual costs, not an FPS promise.
	run = fresh()
	run.invincible = 999
	for i in range(SalvageRun.MAX_ENEMIES + 20):
		run.spawn_enemy(Vector2(70 + (i % 30) * 27, 130 + (i / 30) * 48), 1)
	for e in run.enemies:
		e.warmup = 0.0
		e.hp = 10000.0
	for i in range(SalvageRun.MAX_PROJECTILES + 20):
		run._add_projectile(Vector2(40, 120 + i % 360), Vector2(130, 0), 1, "bolt", 180)
	check(run.enemies.size() == 180 and run.projectiles.size() == 240, "Enemy and projectile caps hold at deliberate overfill")
	var stress_start := Time.get_ticks_usec()
	var stress_max := 0
	for i in range(120):
		var tick := Time.get_ticks_usec()
		run.step(1.0 / 60, Vector2.ZERO)
		stress_max = maxi(stress_max, Time.get_ticks_usec() - tick)
		run.events.clear()
	print("STRESS 180 enemies / 240 projectiles: mean_tick_ms=", (Time.get_ticks_usec() - stress_start) / 120000.0, " max_tick_ms=", stress_max / 1000.0)
	check(run.state == "running" and run.player.is_finite(), "Dense synthetic combat remains valid")

	var game := load("res://src/salvage/workshop.tscn").instantiate() as Node2D
	root.add_child(game)
	await process_frame
	check(game.screen == "home" and game.ui.overlay.get_child_count() > 0, "Actual scene opens on usable menu")
	game.start_run()
	game._pause_toggle()
	var before: float = game.model.time
	game._physics_process(1)
	check(game.screen == "paused" and game.model.time == before, "Controller pause freezes run")
	game._pause_toggle()
	check(game.screen == "running", "Resume restores play")
	game.model.total_xp = 8
	game._physics_process(0.016)
	check(game.screen == "upgrade", "XP routes controller to upgrade screen")
	var pending_offers: Array = game.model.offers.duplicate()
	game._open_build()
	var paused_at: float = game.model.time
	game._physics_process(1)
	check(game.screen == "build" and game.model.time == paused_at, "Build inspector pauses simulation")
	game.ui.build_page = "stats"
	game.ui.show_build(game.model, false)
	game._close_build()
	check(game.screen == "upgrade" and game.model.offers == pending_offers, "Closing build restores original pending upgrade choices")
	var cards: Array[Node] = game.ui.overlay.get_children().filter(func(n: Node) -> bool: return n is Button and n.has_meta("upgrade_card"))
	check(cards.size() == 3, "Three interactive upgrade cards exist")
	(cards[1] as Button).pressed.emit()
	check(game.screen == "running" and game.model.rank_of(pending_offers[1]) == 1, "Card signal chooses the offered branch")
	game.start_run("baseline")
	check(game.model.mode == "baseline" and game.model.kills == 0 and game.model.time == 0, "Restart resets run and respects mode")
	for fixture in ["gameplay", "upgrade", "pause", "result", "build", "stats", "world"]:
		game._fixture(fixture)
		await process_frame
		check(game.model != null, "Fixture builds: " + fixture)
		for node in game.ui.overlay.find_children("*", "TextureRect", true, false):
			var icon := node as TextureRect
			check(icon.texture != null and icon.size.x <= 160 and icon.size.y <= 160, "Illustration loaded and constrained to its UI slot")
	game.start_run()
	game._open_build()
	game._close_build()
	check(game.screen == "running" and game.ui.hud.visible, "Build returns directly to playing with HUD restored")
	game.show_home()
	game._open_build()
	check(game.ui.build_model.rank_of("grinder") == 0, "Home upgrade browser does not claim decorative preview upgrades as owned")
	game._close_build()
	check(game.screen == "home", "Home browser returns to menu")
	game.sound.set_muted(true)
	game.music_player.shutdown()
	await create_timer(0.2).timeout
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout # Let the audio mixer retire stopped voices before shutdown.
	print("SALVAGE TESTS: ", checks, " checks; ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)
