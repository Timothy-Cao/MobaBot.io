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
	run.spawn_clock = 999
	return run

func finish_beat(run: SalvageRun) -> void:
	run.invincible = 99
	for i in range(90): run.step(1.0 / 60, Vector2.ZERO)

func boss_at(run: SalvageRun, role: String, pos: Vector2) -> Dictionary:
	DemoCampaign.spawn_special(run, role)
	var enemy: Dictionary = run.enemies.back()
	enemy.pos = pos
	enemy.warmup = 0
	enemy.clock = 0
	return enemy

func _run() -> void:
	var run := fresh()
	check(run.demo_mode and run.stage == 1 and run.encounter_seconds() == 75, "Demo starts at Stage 1 Level 1")
	for r in range(5):
		run.state = "upgrade"
		run.offers.assign(["skill_w"])
		check(run.choose_upgrade(0), "First-level build can reach first milestone")
	run.state = "upgrade"
	run.offers.assign(["skill_w"])
	check(not run.choose_upgrade(0) and run.kit.ranks.w == 5, "Rank six is deferred to the second demo level")
	run.state = "running"
	run.stage_time = 74.9
	run._spawn_step(0.01)
	check(not run.boss_spawned and not DemoCampaign.ready_to_clear(run), "No Level 1 boss or early exit")
	run.stage_time = 75
	finish_beat(run)
	check(run.state == "stage_reward" and run.demo_history.size() == 1 and not run.boss_spawned, "Mobs-only level ends at survival timer")
	check(run.choose_stage_reward(0) and run.stage == 2 and run.rank_limit("skill_w") == 8, "Reward advances to Level 2 and opens middle ranks")
	check(run.kit.ranks.w == 5 and run.player == DemoCampaign.LEVELS[1].start, "Build carries to next workshop sector")
	run.invincible = 99
	run.stage_time = 25
	run._spawn_step(0.01)
	var first: Dictionary = run.enemies.filter(func(e: Dictionary) -> bool: return e.has("role"))[0]
	check(first.role == "rammer", "First miniboss teaches charge")
	run.hit_enemy(first, 99999, "active")
	check(run.demo_minis_killed == 1 and not run.boss_defeated, "Miniboss kill cannot end the level as a final boss")
	run.stage_time = 60
	run._spawn_step(0.01)
	var second: Dictionary = run.enemies.filter(func(e: Dictionary) -> bool: return e.get("role", "") == "artillery")[0]
	check(second.role == "artillery" and run.demo_minis_spawned == 2, "Second miniboss teaches ground tells")
	run.stage_time = 90
	check(not DemoCampaign.ready_to_clear(run), "Unfinished miniboss blocks exit after wave timer")
	run.hit_enemy(second, 99999, "active")
	finish_beat(run)
	check(run.state == "stage_reward" and run.demo_minis_killed == 2, "Level 2 requires both wardens and its timer")
	check(run.choose_stage_reward(0) and run.stage == 3 and run.rank_limit("skill_w") == 10, "Final level opens rank-ten transformations")
	run.stage_time = 89.9
	run._spawn_step(0.01)
	check(not run.boss_spawned, "Final level has its horde phase first")
	run.stage_time = 90
	run._spawn_step(0.01)
	check(run.boss_spawned and run.enemies.size() == 1 and run.enemies[0].role == "foreman", "Wave ends in a distinct final boss encounter")
	var final_boss: Dictionary = run.enemies[0]
	check(not Rect2(run.camera_origin(), run.view_size).has_point(final_boss.pos), "Final boss enters from off-screen")
	run._add_projectile(run.player, Vector2.ZERO, 1, "hostile", 0)
	run.hit_enemy(final_boss, 99999, "ultimate")
	check(run.projectiles.all(func(b: Dictionary) -> bool: return b.kind != "hostile" or b.life <= 0), "Final boss death cancels lingering hostile projectiles")
	finish_beat(run)
	check(run.state == "won" and run.stage == 3 and run.demo_history.size() == 3, "Third-level victory terminates demo; no Level 4")
	check(not run.choose_stage_reward(0), "No post-victory progression")
	# Explicit boss states, counterplay and matching hit geometry.
	run = fresh()
	var boss := boss_at(run, "rammer", run.player - Vector2(220, 0))
	DemoCampaign.enemy_step(run, boss, 0.01)
	check(boss.phase == "telegraph" and boss.clock >= 0.85, "Charge retains a 0.9 second reaction window")
	var locked: Vector2 = boss.target
	run.player += Vector2(0, 120)
	DemoCampaign.enemy_step(run, boss, 1.26)
	check(boss.phase == "charge" and boss.target == locked, "Charge commits to aim rather than tracking player through windup")
	DemoCampaign.enemy_step(run, boss, 0.7)
	check(run.health == 5 and boss.phase == "recover", "Ordinary sidestep avoids charge and exposes recovery")
	var hp: float = boss.hp
	run.hit_enemy(boss, 10, "active")
	check(is_equal_approx(hp - boss.hp, 15), "Recovery grants a real fifty-percent damage opening")
	run = fresh()
	boss = boss_at(run, "artillery", run.player - Vector2(220, 0))
	DemoCampaign.enemy_step(run, boss, 0.01)
	check(run.hazards.size() == 1 and run.health == 5, "Artillery marks ground before damage")
	var origin: Vector2 = run.hazards[0].pos
	run.player += Vector2(0, 205 * 0.95)
	DemoCampaign.hazards_step(run, 1.3)
	check(run.health == 5 and run.hazards.is_empty(), "Marked blast is avoidable with walking, no blink required")
	run.hazards.append({"pos": run.player, "radius": 82, "time": 0.01, "duration": 1.25, "owner": boss.id, "spent": false})
	DemoCampaign.hazards_step(run, 0.02)
	check(run.health == 3, "Standing in a completed tell deals two hull damage")
	run.invincible = 0
	DemoCampaign.hazards_step(run, 1)
	check(run.health == 3, "Blast cannot hit repeatedly after resolving")
	run.hazards.append({"pos": run.player, "radius": 82, "time": 1, "duration": 1, "owner": boss.id, "spent": false})
	boss.dead = true
	DemoCampaign.hazards_step(run, 2)
	check(run.health == 3 and run.hazards.is_empty(), "Killing a caster cancels its pending ground attack")
	run = fresh()
	boss = boss_at(run, "foreman", run.player - Vector2(220, 0))
	boss.hp = boss.max_hp / 2
	boss.sequence = 2
	DemoCampaign.enemy_step(run, boss, 0.01)
	check(boss.enraged and boss.attack == "fan" and boss.clock >= 0.6, "Final boss phase two retains a 0.65 second tell")
	DemoCampaign.enemy_step(run, boss, 1)
	check(run.projectiles.size() == 7 and boss.phase == "recover", "Final boss fan is seven dodgeable projectiles followed by recovery")
	var scene := load("res://src/salvage/workshop.tscn").instantiate() as Node2D
	root.add_child(scene)
	await process_frame
	scene.start_run()
	scene.ui.update_hud(scene.model)
	check(scene.model.demo_mode and scene.ui.stage_label.text.contains("STAGE 1"), "Main game launches the demo, not old three-boss mode")
	scene.queue_free()
	await process_frame
	for precision in [false, true]:
		for seed_value in [2407, 2408]:
			run = SalvageRun.new(seed_value)
			run.enable_moba(MobaKit.preset(precision))
			run.enable_demo()
			for tick in range(36000):
				if run.state == "upgrade": run.choose_upgrade(0)
				elif run.state == "stage_reward": run.choose_stage_reward(0)
				if run.state in ["won", "lost"]: break
				var direction := DemoCampaign.test_direction(run)
				run.command_move(run.player + direction * 120)
				if tick % 66 == 0:
					var target := run.nearest_enemy(run.player)
					if not target.is_empty():
						for slot in ["q", "w", "e", "r", "t"]: run.kit.cast(run, slot, target.pos)
					run.kit.cast(run, "d", run.player + direction * 100)
					run.kit.cast(run, "f", run.player + direction * 100)
				run.step(1.0 / 60, Vector2.ZERO)
				run.events.clear()
			check(run.state in ["won", "lost"], "Demo simulation reaches a terminal state")
			check(run.stage <= 3 and run.hazards.size() <= 6 and run.enemies.size() <= run.MAX_ENEMIES, "Demo simulation respects content and object bounds")
			print("DEMO_SIM ", JSON.stringify({"precision": precision, "seed": seed_value, "result": run.state, "time": run.time, "kills": run.kills, "hits": run.damage_taken, "levels": run.demo_history, "current_level": run.stage}))
	print("DEMO TESTS: ", checks, " checks; ", failures, " failures")
	quit(0 if failures == 0 else 1)
