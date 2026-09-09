extends SceneTree
var checks := 0
var failures := 0
func _init() -> void: call_deferred("_run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func fresh() -> SalvageRun:
	var run := SalvageRun.new(1212)
	run.enable_moba(MobaKit.demo_preset())
	run.enable_stages()
	run.kit.onboarding = true
	run.kit.starting_gun = true
	run.kit.loadout.pet = "none"
	run.kit.toggles = [true, false, false, false]
	run.attacks.enabled = true
	run.enemies.clear()
	run.pickups.clear()
	run.spawn_clock = 10000
	return run
func foe(run: SalvageRun, point: Vector2) -> Dictionary:
	run.spawn_enemy(run.player + point)
	var enemy: Dictionary = run.enemies.back()
	enemy.warmup = 0
	enemy.hp = 10000.0
	enemy.max_hp = 10000.0
	enemy.speed = 0
	return enemy
func key(code: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = code
	return event
func _run() -> void:
	var old_config := MobaKit.demo_preset()
	old_config.passives = ["orbit", "ricochet", "poison", "plating"]
	var normalized := MobaKit.with_starter_gun(old_config)
	check(normalized.passives[0] == "bolt" and "orbit" in normalized.passives and "ricochet" in normalized.passives, "Starter gun preserves dependent orbit in custom kit")
	check(old_config.passives[0] == "orbit" and old_config.passives[3] == "plating", "Starter normalization does not mutate saved source")
	old_config.passives = ["poison", "ricochet", "plating", "orbit"]
	check("orbit" in MobaKit.with_starter_gun(old_config).passives, "Orbit dependency survives last-slot migration")
	var run := fresh()
	check(run.kit.unlocked("q") and run.kit.passive_active("bolt"), "Q and autonomous gun are available immediately")
	run.kit.elapsed = 9.99
	run.kit.step(run, 0.02)
	check(not run.events.any(func(e: Dictionary) -> bool: return e.get("kind") == "unlock" and e.get("slot") == "p1"), "Starter gun does not announce a second unlock")
	var enemy := foe(run, Vector2(180, 0))
	run.attacks.stop(run)
	run.attacks.fire(run)
	check(run.attacks.auto_shots == 1 and run.attacks.shots == 0, "S stops basic attacks but not autonomous gun")
	check(run.projectiles.back().kind == "bolt" and run.projectiles.back().get("autonomous", false), "Autonomous shot has distinct source")
	run.attacks.attack(run, enemy)
	run.attacks.fire(run)
	check(run.attacks.shots == 1 and run.attacks.auto_shots == 1, "Commanded attack has an independent cooldown")
	run.command_move(run.player + Vector2(100, 0))
	check(run.attacks.suppressed and run.attacks.target_id == -1, "Ground move cancels only commanded attack")
	run.attacks.auto_cooldown = 0
	run.attacks.fire(run)
	check(run.attacks.auto_shots == 2, "Movement does not stop powered automatic fire")
	run.kit.toggle(0)
	check(run.kit.gun_sniper and run.kit.passive_active("bolt"), "First toggle enters sniper")
	check(is_equal_approx(SalvageProgression.values(run, "power", 0)[0].value, 7.0), "Sniper upgrade preview matches actual base damage")
	check(is_equal_approx(SalvageProgression.values(run, "rapid", 0)[0].value, 1.25), "Sniper upgrade preview matches separate auto cadence")
	var clock_before := run.attacks.auto_cooldown
	check(run.attacks.auto_range(run) > run.attacks.attack_range(run), "Sniper range exceeds basic attack range")
	run.kit.toggle(0)
	check(not run.kit.passive_active("bolt"), "Second toggle powers weapon off")
	check(is_equal_approx(run.attacks.auto_cooldown, clock_before), "Toggle modes do not reset the weapon cooldown")
	run.attacks.auto_cooldown = 0
	run.attacks.fire(run)
	check(run.attacks.auto_shots == 2, "Off really stops automatic fire")
	run.attacks.attack(run, enemy)
	run.attacks.cooldown = 0
	run.attacks.fire(run)
	check(run.attacks.shots == 2, "Basic attack still works with autonomous weapon off")
	run.kit.toggle(0)
	check(run.kit.passive_active("bolt") and not run.kit.gun_sniper, "Third toggle returns to machine gun")
	check(absf(SalvageProgression.values(run, "power", 5)[0].value - 2.475) <= 0.00501, "Rank-five machine-gun preview includes milestone power to two decimals")
	check(is_equal_approx(SalvageProgression.values(run, "rapid", 0)[0].value, 6.25), "Machine-gun preview does not show basic attack cadence")
	run.kit.laser_left = 1
	run.attacks.cooldown = 0
	run.attacks.auto_cooldown = 0
	run.attacks.fire(run)
	check(run.attacks.shots == 2 and run.attacks.auto_shots == 3, "Laser blocks basic attack but not autonomous mechanism")
	run = fresh()
	var a := foe(run, Vector2(100, 0))
	var b := foe(run, Vector2(250, 0))
	run.attacks.attack_move(run, b.pos + Vector2(2, 0))
	run.attacks.prepare(run, 0.01)
	check(run.attacks.target_id == b.id and not run.moving, "A-click favors cursor target, not nearest player target")
	b.dead = true
	run.attacks.prepare(run, 0.01)
	check(run.attacks.target_id == a.id, "Attack move reacquires after death")
	a.dead = true
	run.attacks.prepare(run, 0.01)
	check(run.moving and run.attacks.target_id == -1, "Attack move resumes its destination when no target remains")
	run = fresh()
	enemy = foe(run, Vector2(600, 0))
	check(run.attacks.closest(run, enemy.pos, false, true).id == enemy.id, "Right-click hit test finds enemy")
	check(run.attacks.closest(run, run.player, false, true).is_empty(), "Ground click does not acquire a distant target")
	run.attacks.attack(run, enemy)
	for i in range(100): run.step(1.0 / 60, Vector2.ZERO)
	check(not run.moving and run.player.distance_to(enemy.pos) <= run.attacks.attack_range(run) + enemy.radius, "Target order approaches then holds in range")
	var held := run.player
	for i in range(60): run.step(1.0 / 60, Vector2.ZERO)
	check(run.player.distance_to(held) < 0.01, "No boundary oscillation around a stationary target")
	enemy.pos = run.player + Vector2(run.attacks.attack_range(run) + 200, 0)
	run.attacks.prepare(run, 0.01)
	check(run.moving, "Moving target is pursued again")
	run.attacks.stop(run)
	run.attacks.prepare(run, 0.1)
	check(not run.moving and run.attacks.target_id == -1, "S cancels pursuit persistently")
	for hz in [30, 60, 120, 144]:
		run = fresh()
		enemy = foe(run, Vector2(180, 0))
		for i in range(hz * 8):
			run.attacks.prepare(run, 1.0 / hz)
			run.attacks.fire(run)
			run.projectiles.clear()
		check(absi(run.attacks.auto_shots - 50) <= 1, "Stable machine-gun cadence at %d Hz" % hz)
		run.attacks.stop(run)
		run.enemies.clear()
		for i in range(hz * 2): run.attacks.prepare(run, 1.0 / hz)
		enemy = foe(run, Vector2(180, 0))
		var before := run.attacks.auto_shots
		run.attacks.fire(run)
		check(run.attacks.auto_shots == before + 1, "No stored burst after idle at %d Hz" % hz)
	run = fresh()
	enemy = foe(run, Vector2(200, 0))
	run.attacks.fire(run)
	var bullet: Dictionary = run.projectiles.back()
	var origin: Vector2 = bullet.pos
	run.enemies.clear()
	run._projectile_step(1.0)
	check(Vector2(bullet.pos).distance_to(origin) <= run.attacks.auto_range(run) - 20 + 0.01, "Auto projectile cannot travel beyond its stated range in a long frame")
	run = fresh()
	run.kit.loadout.passives[1] = "poison"
	run.kit.elapsed = 120
	run.kit.toggles = [false, true, false, false]
	check(is_equal_approx(run.kit.drain_rate(), 3.0), "Trail costs 3 energy/sec while enabled")
	enemy = foe(run, Vector2.ZERO)
	run.kit._step_poison(run, 0.25)
	check(is_equal_approx(enemy.hp, 9998), "Trail delivers 8 damage/sec")
	run.kit.poison_trail.append({"pos": run.player, "life": 4.0})
	run.kit._step_poison(run, 0.25)
	check(is_equal_approx(enemy.hp, 9996), "Overlapping patches do not multiply damage")
	check(run.health == 5, "Poison has no self-damage")
	run.kit.toggle(1)
	check(is_zero_approx(run.kit.drain_rate()), "Disabled trail costs no energy")
	var patch_count := run.kit.poison_trail.size()
	run.player += Vector2(100, 0)
	run.kit._step_poison(run, 0.25)
	check(run.kit.poison_trail.size() == patch_count, "Off creates no new patches; laid trail persists")
	for i in range(250): run.kit._step_poison(run, 0.02)
	check(run.kit.poison_trail.is_empty(), "Old trail expires after switching off")
	var bindings := MobaKit.DEFAULT_BINDS.duplicate()
	bindings.q = KEY_A
	check(not MobaKit.valid_bindings(bindings), "A is reserved for attack preview")
	check(MobaKit.valid_bindings(MobaKit.resolve_bindings(bindings)), "Old A binding migrates to a free valid key")
	var game := load("res://src/salvage/workshop.tscn").instantiate() as Node2D
	root.add_child(game)
	await process_frame
	game.persist_settings = false
	game.auto_play = true
	game.set_physics_process(false)
	game.loadout_setting = MobaKit.demo_preset()
	game.key_setting = MobaKit.DEFAULT_BINDS.duplicate()
	game.start_run()
	check(game.model.mastery.available(1) == 1 and game.model.mastery.available(6) == 6, "Live game awards one mastery point per Power level")
	game._input(key(KEY_A))
	check(game.pending_attack and game.pending_cast_slot.is_empty(), "A arms attack preview")
	game._input(key(KEY_ESCAPE))
	check(not game.pending_attack and game.screen == "running", "Esc cancels attack preview before settings")
	game._input(key(KEY_A))
	game._input(key(KEY_Q))
	check(not game.pending_attack, "Skill input replaces attack preview")
	game._input(key(KEY_A))
	game._input(key(KEY_TAB))
	check(not game.pending_attack and game.screen == "build", "Modal opening clears armed attack")
	game._close_build()
	game._input(key(KEY_S))
	check(game.model.attacks.suppressed and game.model.kit.passive_active("bolt"), "Controller S preserves autonomous toggle")
	game.sound.set_muted(true)
	game.music_player.shutdown()
	await create_timer(0.2).timeout
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	print("MOBABOT 12 TESTS: ", checks, " checks; ", failures, " failures")
	quit(0 if failures == 0 else 1)
