extends SceneTree
## Optional diagnostic, not a human-fun test. No perfect knowledge of boss tells.
func _init() -> void:
	for policy in ["passive_only", "few_buttons"]:
		for seed_value in [2407, 2408]:
			var run := SalvageRun.new(seed_value)
			run.enable_moba(MobaKit.preset())
			run.enable_demo()
			var rng := RandomNumberGenerator.new()
			rng.seed = seed_value
			var direction := Vector2.RIGHT
			var choices := 0
			var chain := 0
			var max_chain := 0
			var last_choice_time := -10.0
			for tick in range(54000):
				if run.state == "upgrade":
					chain = chain + 1 if run.time - last_choice_time < 1 else 1
					max_chain = maxi(chain, max_chain)
					last_choice_time = run.time
					choices += 1
					run.choose_upgrade(rng.randi_range(0, run.offers.size() - 1))
				elif run.state == "stage_reward": run.choose_stage_reward(0)
				if run.state in ["won", "lost"]: break
				# React at 5 Hz only to positions, never windup state or hazard timing.
				if tick % 12 == 0:
					var center: Vector2 = DemoCampaign.info(run).start
					var target := center + Vector2(cos(run.time * 0.15), sin(run.time * 0.15)) * 240
					var boss := CombatReadability.nearest_objective(run)
					if not boss.is_empty():
						target = Vector2(boss.pos) + Vector2.from_angle(run.time * 0.65) * 190
					direction = (target - run.player).normalized()
					for enemy in run.enemies:
						var offset: Vector2 = run.player - Vector2(enemy.pos)
						if offset.length() < 80: direction += offset.normalized() * 2
					run.command_move(run.player + direction.normalized() * 120)
				if policy == "few_buttons" and tick % 180 == 0:
					var target := run.nearest_enemy(run.player)
					if not target.is_empty():
						for slot in ["q", "w", "e"]: run.kit.cast(run, slot, target.pos)
					run.kit.cast(run, "r", run.player)
				run.step(1.0 / 60, Vector2.ZERO)
				run.events.clear()
			print("BEHAVIOR_PROBE ", JSON.stringify({"policy": policy, "seed": seed_value, "result": run.state, "seconds": snappedf(run.time, 0.01), "level": run.stage, "power": run.level, "hits": run.damage_taken, "kills": run.kills, "choices": choices, "max_choice_chain_under_1s": max_chain, "last_damage": run.last_damage}))
	quit()
