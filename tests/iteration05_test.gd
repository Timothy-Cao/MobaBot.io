extends SceneTree
var checks := 0
var failures := 0

func _init() -> void:
	call_deferred("_run")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func fresh(config: Dictionary = {}) -> SalvageRun:
	var run := SalvageRun.new()
	run.enable_moba(config)
	run.enable_stages()
	run.pickups.clear()
	run.spawn_clock = 999
	return run

func buy(run: SalvageRun, id: String) -> bool:
	run.state = "upgrade"
	run.offers.assign([id])
	return run.choose_upgrade(0)

func rank_to(run: SalvageRun, slot: String, rank_value: int) -> void:
	for i in range(rank_value):
		buy(run, "skill_" + slot)

func _run() -> void:
	var run := fresh()
	check(not MobaKit.PASSIVES.has("magnet") and run.magnet_radius() == 250, "Magnet is free baseline utility, not a passive")
	for i in range(12): buy(run, "power" if i < 10 else "rapid")
	check(run.rank_of("magnet") == 5 and run.utility_history.size() == 4, "Four free utility ranks arrive across twelve level-ups")
	check(run.magnet_radius() == 650, "Magnet grows to 650 radius")
	for i in range(20):
		run._make_offers()
		check("magnet" not in run.offers, "Utility never replaces a combat offer")
	var far := run.player + Vector2(1700, 0)
	run._drop(far, 7)
	run.vacuum_clock = 0.01
	run._pickup_step(0.02)
	check(run.pickups[0].pull, "Rank-five vacuum attracts distant earned scrap")
	var old := MobaKit.preset()
	old.passives = ["pulse", "magnet", "plating", "bolt"]
	var migrated := MobaKit.migrate_loadout(old)
	check(MobaKit.valid_loadout(migrated) and "magnet" not in migrated.passives and migrated.q == old.q, "Old utility-in-passive save migrates without changing active loadout")
	for id in SalvageProgression.WEAPONS:
		run = fresh()
		for r in range(1, 11):
			var preview := run.upgrade_values(id, r)
			check(buy(run, id) and run.rank_of(id) == r, "Combat rank purchase " + id + str(r))
			check(preview == run.upgrade_values(id), "Rank preview matches applied state " + id + str(r))
			match id:
				"power": check(is_equal_approx(float(preview[1].value), run.bolt_damage()) and preview[2].value == run.bolt_pierces(), "Bolt numbers match combat")
				"rapid": check(is_equal_approx(float(preview[1].value), snappedf(1 / run.fire_interval(), 0.01)), "Fire rate preview matches cadence")
				"grinder": check(is_equal_approx(float(preview[1].value), run.orbit_damage()) and preview[2].value == run.orbit_hits(), "Orbit numbers match combat")
				"ricochet": check(is_equal_approx(float(preview[1].value), run.shard_damage()) and preview[2].value == run.shard_bounces(), "Shard numbers match combat")
				"pulse": check(is_equal_approx(float(preview[1].value), run.pulse_damage()) and preview[2].value == run.pulse_radius(), "Pulse numbers match combat")
				"capacity": check(preview[0].value == run.capacity(), "Rack preview matches capacity")
				"reactor": check(preview[0].value == run.kit.energy_regen(), "Regen preview matches resource simulation")
				"cell": check(preview[0].value == run.kit.energy_max(), "Energy preview matches resource simulation")
		check(not buy(run, id), "Rank ten cap enforced " + id)
	for slot in MobaKit.SLOTS:
		run = fresh()
		for r in range(1, 11):
			check(buy(run, "skill_" + slot) and run.kit.ranks[slot] == r, "Ability tree and actual rank stay synchronized " + slot)
			check(is_equal_approx(run.kit.cooldown(slot), run.kit.cooldown_at(slot, r)), "Recharge preview matches rank " + slot)
		check(not buy(run, "skill_" + slot), "Ability cap enforced " + slot)
		check(run.kit.milestone(slot) == 2, "Second milestone reached " + slot)
		var cd := run.kit.cooldown(slot)
		run.kit.recharge[slot] = cd / 2
		run.kit.promote(slot)
		check(is_equal_approx(run.kit.recharge[slot], run.kit.cooldown(slot) / 2), "Rarity preserves progress on ranked ability " + slot)
	for r in range(1, 6):
		check(roundi(SalvageProgression.bonus(r) * 100) == 15 + r * 5, "Damage ladder is 20/25/30/35/40")
	for rank_value in [5, 10]:
		run = fresh()
		rank_to(run, "q", rank_value)
		run.spawn_enemy(run.player + Vector2(90, 0))
		run.enemies[0].warmup = 0
		check(run.kit.cast(run, "q", run.enemies[0].pos) and run.kit.salvos[0].left == 5 + rank_value / 5 * 2, "Salvo milestone adds real projectiles")
		run = fresh()
		rank_to(run, "w", rank_value)
		check(run.kit.cast(run, "w", run.player) and is_equal_approx(run.events.back().radius, 155 * (1 + rank_value / 5 * 0.25)), "Ring milestone changes actual damage radius")
		run = fresh()
		rank_to(run, "e", rank_value)
		run.kit.cast(run, "e", run.player)
		for i in range(1 + rank_value / 5):
			run.invincible = 0
			run.hurt_player(run.player)
		check(run.health == 5 and run.kit.shield == 0, "Shield milestone blocks its exact hit count")
		run = fresh(MobaKit.preset(true))
		rank_to(run, "r", rank_value)
		run.kit.cast(run, "r", run.player + Vector2(300, 0))
		check(is_equal_approx(run.kit.zones[0].radius, 28 * (1 + rank_value / 5 * 0.25)), "Beam telegraph uses milestone collision width")
		run = fresh()
		rank_to(run, "f", rank_value)
		var before := run.player
		run.kit.cast(run, "f", run.player + Vector2(1000, 0))
		check(is_equal_approx(run.player.distance_to(before), run.kit.cast_range("f")), "Blink preview agrees with evolved travel")
	for zoom in [1.0, 0.65]:
		for point in [Vector2(480, 300), SalvageRun.ARENA.position + Vector2.ONE * 16, SalvageRun.ARENA.end - Vector2.ONE * 16, Vector2(SalvageRun.ARENA.position.x + 16, SalvageRun.ARENA.end.y - 16), Vector2(SalvageRun.ARENA.end.x - 16, SalvageRun.ARENA.position.y + 16)]:
			run = fresh()
			run.player = point
			run.view_size = Vector2(960, 540) / zoom
			var safe := true
			for i in range(150):
				var spawn := run._offscreen_point(i % 4)
				safe = safe and not Rect2(run.camera_origin(), run.view_size).grow(35).has_point(spawn) and SalvageRun.ARENA.has_point(spawn)
			check(safe, "All spawn sides remain off-screen inside arena at zoom and corner")
	run = fresh()
	run.stage_time = 16
	run._spawn_step(0.01)
	check(run.events.any(func(e: Dictionary) -> bool: return e.kind == "pressure_warning"), "Surge warning precedes pack")
	run.stage_time = 18
	run._spawn_step(0.01)
	check(run.enemies.size() == 11 and run.enemies.any(func(e: Dictionary) -> bool: return e.get("runner", false)), "First surge creates eleven mixed pressure enemies")
	check(run.enemies[0].hp > 3 and run.enemies.all(func(e: Dictionary) -> bool: return e.get("elite", false)), "Pressure pack is stronger and visibly elite")
	var count := run.enemies.size()
	run._spawn_step(0.01)
	check(run.enemies.size() == count, "Surge cannot repeat every frame")
	for kind in [0, 1, 2, 3]:
		run = fresh()
		run.spawn_enemy(run.player, kind)
		run.hit_enemy(run.enemies[0], 99999, "active")
		check(run.pickups.size() == [3, 10, 72, 20][kind], "Richer real scrap count for enemy type")
		check(kind == 0 or run.supply_drops.any(func(s: Dictionary) -> bool: return s.kind == "energy"), "Difficult enemies drop resource cells")
	run = fresh()
	for i in range(100):
		run._drop_supply(run.player, "energy", 2)
		run._drop_supply(run.player, "repair", 1)
	check(run.supply_drops.size() == 40, "Separate supply pool stays bounded")
	var energy_total := 0
	var repairs := 0
	for supply in run.supply_drops:
		if supply.kind == "energy": energy_total += supply.value
		else: repairs += supply.value
	check(energy_total == 200 and repairs == 100 and run.total_xp == 0, "Capped supply merging conserves types and never creates XP")
	run.kit.energy = 0
	run.health = 1
	run._supply_step(1)
	check(run.health == 5 and run.kit.energy == 100 and run.supply_drops.is_empty(), "Resource and repair drops actually refill correct stats")
	# Standing still with no casts should no longer be a viable default strategy.
	run = fresh()
	for i in range(7200):
		if run.state == "upgrade": run.choose_upgrade(0)
		elif run.state == "stage_reward": run.choose_stage_reward(0)
		run.step(1.0 / 60, Vector2.ZERO)
		if run.state in ["lost", "won"]: break
	check(run.damage_taken > 0, "Waves exert actual pressure on a stationary player")
	print("STATIONARY_PRESSURE seconds=", run.time, " state=", run.state, " hits=", run.damage_taken)
	var config := MobaKit.preset()
	config.passives[3] = "thorns"
	run = fresh(config)
	run.health = 1
	run.spawn_enemy(run.player, 2)
	run.enemies[0].hp = 1
	run.hurt_player(run.player)
	check(run.state == "lost" and run.health == 0 and not run.boss_defeated, "Lethal recoil cannot kill a boss and resurrect the player")
	print("ITERATION 05 TESTS: ", checks, " checks; ", failures, " failures")
	quit(0 if failures == 0 else 1)
