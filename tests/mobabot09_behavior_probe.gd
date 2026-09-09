extends SceneTree
## Diagnostic policies, not proof of human difficulty or fun. Normal hull, real damage.
func _init() -> void:
	var refined := "--refined" in OS.get_cmdline_user_args()
	for policy in ["idle", "stationary_cast", "moving_cast"]:
		for seed_value in [2407, 2408, 2409]:
			var run := SalvageRun.new(seed_value)
			run.enable_moba(MobaKit.demo_preset())
			run.enable_demo()
			run.kit.onboarding = true
			run.attacks.enabled = refined
			run.kit.starting_gun = refined
			run.mastery.every_level = refined
			run.loot_rng.seed = seed_value + 901
			BotEquipment.new().apply_to(run)
			for tick in range(36000):
				if run.state == "upgrade": run.choose_upgrade(0)
				elif run.state == "stage_reward": run.choose_stage_reward(0)
				if run.state in ["won", "lost"]: break
				if policy == "moving_cast":
					run.command_move(run.player + DemoCampaign.test_direction(run) * 120)
				var target := run.nearest_enemy(run.player)
				if policy != "idle" and not target.is_empty():
					run.kit.flame_direction = (Vector2(target.pos) - run.player).normalized()
					if tick % 66 == 0:
						for slot in ["q", "w", "e", "r", "t"]: run.kit.cast(run, slot, target.pos)
				if policy == "moving_cast" and tick % 540 == 0:
					var direction := DemoCampaign.test_direction(run)
					run.kit.cast(run, "d", run.player + direction * 150)
					run.kit.cast(run, "f", run.player + direction * 150)
				run.step(1.0 / 60, Vector2.ZERO)
				run.events.clear()
			print("MOBABOT_BEHAVIOR ", JSON.stringify({"refined": refined, "policy": policy, "seed": seed_value, "result": run.state, "seconds": snappedf(run.time, 0.01), "level": run.stage, "power": run.level, "hits": run.damage_taken, "kills": run.kills, "coins": run.coins, "basic_shots": run.attacks.shots, "auto_shots": run.attacks.auto_shots}))
	quit()
