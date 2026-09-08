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
	var run := SalvageRun.new(1010)
	run.enable_moba(MobaKit.demo_preset())
	run.enable_demo()
	run.kit.onboarding = true
	run.kit.elapsed = 120
	run.kit.loadout.pet = "none"
	run.kit.toggles = [false, false, false, false]
	run.enemies.clear()
	run.pickups.clear()
	return run
func foe(run: SalvageRun, point: Vector2) -> Dictionary:
	run.spawn_enemy(run.player + point)
	var enemy: Dictionary = run.enemies.back()
	enemy.warmup = 0
	enemy.hp = 1000.0
	enemy.max_hp = 1000.0
	return enemy
func key(code: int, pressed: bool = true) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = pressed
	return event
func _run() -> void:
	var run := fresh()
	check(MobaKit.valid_loadout(run.kit.loadout), "Default loadout remains category-valid")
	run.kit.elapsed = 0
	check(not run.upgrade_available("power"), "No weapon power offer before any supported weapon unlocks")
	run.kit.elapsed = 10
	check(run.upgrade_available("power"), "Weapon power becomes available with Auto bolt")
	run.kit.elapsed = 120
	var power_values := SalvageProgression.values(run, "power", 5)
	check(power_values[1].label == "Arc damage" and is_equal_approx(power_values[1].value, 7 * 1.65), "Weapon rank preview includes lightning and its milestone bonus")
	check(run.kit.loadout.e == "nuke" and run.kit.loadout.r == "laser", "E/R roles")
	var old := MobaKit.preset()
	old.r = "nuke"
	check(MobaKit.valid_loadout(MobaKit.migrate_loadout(old)), "Old R-nuke saves migrate without losing equipment")
	for hz in [30, 60, 120, 144]:
		run = fresh()
		var target := foe(run, Vector2(200, 0))
		var behind := foe(run, Vector2(-100, 0))
		var outside := foe(run, Vector2(300, 60))
		check(run.kit.cast(run, "r", target.pos), "Laser starts")
		check(run.kit.energy == 60 and run.kit.charges.r == 0, "Channel charged exactly once")
		run.command_move(run.player + Vector2.DOWN * 100)
		check(not run.moving, "Channel cannot become a movement command")
		check(not run.kit.cast(run, "q", target.pos), "Other attacks cannot overlap the channel")
		for i in range(hz * 5 + 2): run.kit.step(run, 1.0 / hz)
		check(is_equal_approx(target.hp, 625), "Exactly 375 damage at %d Hz" % hz)
		check(behind.hp == 1000 and outside.hp == 1000, "Beam geometry excludes outside/behind")
		check(run.kit.laser_left == 0, "Channel ends at 5s")
		run = fresh()
		run.kit.cast(run, "r", run.player + Vector2.RIGHT * 100)
		run.kit.steer_laser(run, run.player + Vector2.DOWN * 100)
		run.kit.step(run, 1.0 / hz)
		check(run.kit.laser_angle > 0 and run.kit.laser_angle < 0.01, "Steering starts with inertia")
		for i in range(hz): run.kit.step(run, 1.0 / hz)
		check(run.kit.laser_angle > 0.7 and run.kit.laser_angle < 1.4, "Turn is slow and bounded")
		check(run.kit.cast(run, "r", run.player) and run.kit.laser_left == 0, "R cancels despite empty charge")
		check(run.kit.cast_counts.laser == 1, "Cancel is not another cast")
		run = fresh()
		run.kit.cast(run, "r", run.player + Vector2.RIGHT * 100)
		check(run.kit.cast(run, "d", run.player) and run.kit.laser_left == 0, "D cancels into an escape")
		run.hurt_player(run.player, "test", 3)
		check(run.health == 5, "Ghost blocks heavy damage")
		run.apply_slow(1.2)
		check(run.slow_left == 0, "Ghost blocks slows")
		run.invincible = 0
		run.hurt_player(run.player, "test", 2)
		check(run.health == 3 and run.damage_taken == 2, "Heavy monster damage is real")
	run = fresh()
	run.kit.toggles[2] = true
	var a := foe(run, Vector2(150, 0))
	var b := foe(run, Vector2(240, 20))
	var c := foe(run, Vector2(400, 80))
	run.kit._step_arc(run, 0.01)
	check(a.hp == 993 and b.hp == 993 and c.hp == 1000, "Lightning hops locally, not across the map")
	run.kit.toggle(2)
	check(run.kit.arc_focused and run.kit.passive_active("lightning"), "First arc toggle focuses")
	run.kit.arc_clock = 0
	run.kit._step_arc(run, 0.01)
	check(a.hp == 979 and b.hp == 993, "Focused arc doubles damage on one enemy")
	run.kit.arc_clock = -100
	run.kit._step_arc(run, 0.01)
	var arc_health: float = a.hp
	run.kit._step_arc(run, 0.01)
	check(a.hp == arc_health and run.kit.arc_clock > 1.7, "No stored lightning burst after idle time")
	run.kit.toggle(2)
	check(not run.kit.passive_active("lightning"), "Second arc toggle powers down")
	run.kit.toggle(2)
	check(run.kit.passive_active("lightning") and not run.kit.arc_focused, "Third toggle restores chain")
	run.kit.toggles = [true, true, true, true]
	check(run.kit.drain_rate() == 10, "Default full passive upkeep is 10/sec")
	run.kit.energy = 0
	run.kit.step(run, 0.1)
	check(run.kit.energy >= 0 and run.kit.drain_rate() == 0, "Brownout switches off powered passives")
	run.kit.energy = 20
	run.kit.toggle(1)
	check(run.kit.passive_active("orbit"), "Orbit can reactivate after a brownout")
	run = fresh()
	check(run.mastery.available(1) == 1 and run.mastery.available(3) == 2, "Quiet mastery point cadence")
	check(not run.mastery.buy(run, "aftershock"), "Tree enforces prerequisites")
	check(run.mastery.buy(run, "hull") and run.health == 6 and run.max_health() == 6, "Hull node increases real capacity")
	check(not run.mastery.buy(run, "hull"), "Cannot overspend")
	run.mastery.read_only = true
	run.level = 3
	check(not run.mastery.buy(run, "reach"), "Preview cannot spend points")
	run.mastery.read_only = false
	run.level = 99
	for id in ["reach", "learning", "fortune", "focus", "shock", "aftershock", "recovery", "resolve"]:
		check(run.mastery.buy(run, id), "Buy mastery " + id)
	check(run.magnet_radius() == 123, "Reach affects pickup simulation")
	check(run.drop_bonus == 0.25 and run.kit.mastery_damage == 0.06 and run.kit.regen_bonus == 1, "Mastery affects actual resources and power")
	for i in range(10): run.collect_pickup({"value": 1})
	check(run.total_xp == 11, "Fractional XP conserves bonus across small drops")
	var before_radius: float = run.magnet_radius()
	run.mastery.buy(run, "reach")
	run.mastery.buy(run, "reach")
	check(run.magnet_radius() == before_radius + 70 and not run.mastery.buy(run, "reach"), "Tree caps utility at three ranks")
	a = foe(run, Vector2(120, 0))
	run.kit.toggles[2] = true
	run.kit._step_arc(run, 0.01)
	check(a.get("stun", 0) == 0.35, "Shock mastery applies real stun")
	run.invincible = 0
	run.apply_slow(1.2)
	check(is_equal_approx(run.slow_left, 0.6), "Resolve halves slow duration")
	run.enemies.clear()
	var direct := foe(run, Vector2(150, 0))
	var outer := foe(run, Vector2(150, 90))
	run.kit.cast(run, "q", direct.pos)
	run._projectile_step(0.3)
	check(direct.get("stun", 0) == 0.35, "Q also benefits from Static lock")
	check(is_equal_approx(outer.hp, 1000 - 12 * 1.06), "Aftershock applies scaled damage beyond the base blast")
	run.state = "lost"
	check(not run.mastery.buy(run, "reach"), "Cannot purchase after death")
	run = fresh()
	DemoCampaign.spawn_special(run, "foreman")
	var boss: Dictionary = run.enemies.back()
	check(boss.radius == 60 and boss.hp == 1800, "Foreman physical scale and health")
	boss.pos = run.player + Vector2(200, 0)
	boss.warmup = 0
	# Shot grazes the outer part of the enlarged boss, beyond the old broadphase.
	run._add_projectile(run.player + Vector2(0, 58), Vector2.RIGHT * 500, 10, "rail", 0)
	run._projectile_step(0.4)
	check(boss.hp == 1790, "Enlarged boss edge is hittable")
	boss.summon_clock = 0
	DemoCampaign.spawns(run, 0.01)
	check(run.enemies.size() >= 5, "Foreman summons reinforcements")
	for slot in MobaKit.SLOTS:
		run = fresh()
		var before := run.kit.cooldown(slot)
		for i in range(5): check(run.kit.rank_up(slot), "Rank purchase " + slot)
		check(run.kit.cooldown(slot) < before * 0.85, "Rank cooldown reduction is meaningful " + slot)
		check(run.kit.milestone(slot) == 1, "Rank 5 milestone " + slot)
	var game := load("res://src/salvage/workshop.tscn").instantiate() as Node2D
	root.add_child(game)
	await process_frame
	game.persist_settings = false
	game.auto_play = true
	game.set_physics_process(false)
	game.loadout_setting = MobaKit.demo_preset()
	game.key_setting = MobaKit.DEFAULT_BINDS.duplicate()
	game.start_run()
	game.model.kit.elapsed = 120
	game.model.kit.cast(game.model, "r", game.model.player + Vector2.RIGHT * 200)
	game._input(key(KEY_R))
	check(game.model.kit.laser_left == 0, "Controller R cancels immediately")
	game._input(key(KEY_TAB))
	check(game.screen == "build" and game.ui.build_page == "mastery", "Tab opens mastery when points await")
	var clock_before: float = game.model.time
	game._physics_process(1)
	check(game.model.time == clock_before, "Tree pauses combat")
	var button: Button
	for node in game.ui.overlay.get_children():
		if node.get_meta("mastery_id", "") == "hull": button = node
	check(button != null and not button.tooltip_text.is_empty(), "Mastery nodes have hover details")
	var tooltip := button._make_custom_tooltip(button.tooltip_text) as Control
	check(tooltip != null, "Mastery hover uses the shared tooltip style")
	game.ui.overlay.add_child(tooltip)
	await process_frame
	await process_frame
	check(tooltip.size.x >= 290 and tooltip.size.x <= 340, "Long hover text has bounded width")
	check(tooltip.size.y > 40, "Hover text wraps into a readable panel")
	tooltip.queue_free()
	button.pressed.emit()
	check(game.model.mastery.rank_of("hull") == 1, "Mastery button spends the selected point")
	game._input(key(KEY_TAB, false))
	check(game.screen == "running" and game.model.max_health() == 6, "Release Tab returns to combat with bonuses")
	game.sound.set_channel(true)
	check(game.sound.channel_voice.playing, "Channel hum starts")
	game.sound.set_channel(false)
	check(not game.sound.channel_voice.playing, "Channel hum stops on pause or cancel")
	game.sound.set_muted(true)
	game.sound.set_channel(true)
	check(not game.sound.channel_voice.playing, "Mute prevents channel hum")
	game.music_player.shutdown()
	await create_timer(0.2).timeout # Let the audio mixer release stopped playback.
	game.queue_free()
	await process_frame
	print("MOBABOT 10 TESTS: ", checks, " checks; ", failures, " failures")
	quit(0 if failures == 0 else 1)
