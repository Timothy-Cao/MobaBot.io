extends SceneTree
## Normal health, starter gear, real combat. Adaptive policy is diagnostic, not human QA.
func _init() -> void:
	var refined := "--refined" in OS.get_cmdline_user_args()
	var policies := ["moving_passives", "adaptive", "adaptive_basics"] if refined else ["moving_passives", "adaptive"]
	for policy in policies:
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
				if run.state == "upgrade":
					var choice := 0
					var priority := ["reactor", "skill_q", "skill_r", "skill_e", "power", "skill_w", "cell", "grinder"]
					for id in priority:
						if id in run.offers:
							choice = run.offers.find(id)
							break
					run.choose_upgrade(choice)
				elif run.state == "stage_reward": run.choose_stage_reward(0)
				if run.state in ["won", "lost"]: break
				var route := ["hull", "recovery", "resolve", "hull", "hull", "focus", "focus", "focus", "reach", "learning", "fortune"]
				if policy.begins_with("adaptive"):
					for id in route:
						if run.mastery.can_buy(id, run.level):
							run.mastery.buy(run, id)
							break
				var direction := DemoCampaign.test_direction(run)
				run.command_move(run.player + direction * 120)
				var target := run.nearest_enemy(run.player)
				if policy.begins_with("adaptive") and not target.is_empty():
					run.kit.flame_direction = (Vector2(target.pos) - run.player).normalized()
					var threatened := run.enemies.any(func(e: Dictionary) -> bool: return not e.dead and (Vector2(e.pos).distance_to(run.player) < 110 or (e.has("role") and e.phase in ["telegraph", "charge"])))
					if policy == "adaptive_basics" and not threatened and run.attacks.cooldown <= 0 and run.player.distance_to(target.pos) <= run.attacks.attack_range(run) + target.radius:
						run.attacks.attack(run, target)
					if run.health <= run.max_health() - 2: run.use_consumable(0)
					if run.kit.energy < 30: run.use_consumable(1)
					if threatened:
						if not run.kit.cast(run, "d", run.player): run.kit.cast(run, "f", run.player + direction * 180)
					if run.kit.laser_left > 0:
						run.kit.steer_laser(run, target.pos)
						if threatened: run.kit.cancel_laser()
					elif tick % 18 == 0:
						# Fire the ultimate into a recovery opening, not while danger is approaching.
						if target.get("role", "") == "foreman" and target.phase == "recover" and run.kit.energy >= 40:
							run.kit.cast(run, "r", target.pos)
						else:
							for slot in ["q", "w", "e", "t"]: run.kit.cast(run, slot, target.pos)
					if run.kit.energy > 65:
						for i in range(4):
							if not run.kit.toggles[i]: run.kit.toggle(i)
				run.step(1.0 / 60, Vector2.ZERO)
				run.events.clear()
			print("MOBABOT10_BEHAVIOR ", JSON.stringify({"refined": refined, "policy": policy, "seed": seed_value, "result": run.state, "seconds": snappedf(run.time, 0.01), "stage": run.stage, "power": run.level, "damage": run.damage_taken, "hull": run.health, "kills": run.kills, "mastery": run.mastery.ranks, "casts": run.kit.cast_counts, "basic_shots": run.attacks.shots, "auto_shots": run.attacks.auto_shots}))
	quit()
