class_name BotSkillCatalog
extends RefCounted
## Original mechanics built from a small, shared visual vocabulary.
const SPECS := {
	"returner": ["Return blade", "active", "line", 460, 7, 2, 14, "Throw a blade for 22 damage each way. Move to steer its return."],
	"gravity": ["Gravity well", "active", "ground", 430, 13, 1, 24, "Pull ordinary enemies into a 115-radius field for 3s. 12 damage/sec. Bosses resist the pull."],
	"strike": ["Core strike", "active", "ground", 490, 9, 2, 18, "Strike after 0.6s: 32 damage, doubled in the center."],
	"crosswire": ["Crosswire", "active", "ground", 440, 12, 1, 18, "Place two anchors within 4s. The connecting wire deals 30 damage and stuns ordinary enemies for 0.7s."],
	"repulsor": ["Repulsor", "active", "line", 230, 8, 1, 16, "Push a cone for 20 damage. Nearby placed plates fire forward for another 18 damage."],
	"sweep": ["Guard sweep", "active", "line", 160, 7, 1, 16, "Sweep a broad arc for 26 damage. Hitting an enemy grants one shield for 2s."],
	"reap": ["Rim cutter", "active", "self", 165, 8, 1, 18, "Sweep for 16 damage. The outer rim deals 36 and repairs up to 15% hull per cast."],
	"thrust": ["Piston thrust", "active", "line", 230, 3, 2, 9, "Thrust for 25 damage. Every third cast extends to 440 and stuns ordinary enemies for 0.6s."],
	"tractor": ["Tractor cone", "active", "line", 245, 10, 1, 18, "Pull enemies in a cone toward you for 18 damage. Bosses resist displacement."],
	"consume": ["Scrap crusher", "active", "ground", 145, 14, 1, 20, "Crush an ordinary enemy below half health. Restore 15% hull. Cannot consume bosses or elites."],
	"repair_channel": ["Self repair", "active", "self", 0, 16, 1, 22, "Channel for 3s to restore 24% hull. Movement, another cast or damage interrupts."],
	"wall": ["Bulkhead", "active", "ground", 330, 14, 1, 22, "Raise a 190-wide barrier for 5s. Blocks movement and projectiles; enemies route around its ends."],
	"recall": ["Plate recall", "active", "self", 650, 8, 1, 12, "Recall planted plates through enemies for 18 damage per plate. Three plates stun ordinary enemies."],
	"tumble": ["Tumble jets", "mobility", "line", 135, 5, 3, 0, "A short directional dodge. Empowers the next commanded basic attack by 75%."],
	"echo_dash": ["Echo drive", "active", "ground", 260, 10, 1, 16, "Dash into a 24-damage landing. Recast within 3s to return to the starting point."],
	"veil_dash": ["Veil drive", "mobility", "line", 250, 10, 2, 0, "Dash through enemies. Become intangible for 1s; enemies briefly pursue your last position."],
	"hop": ["Spring vault", "mobility", "ground", 210, 9, 2, 0, "Hop untouchably for 0.55s, then slam for 24 damage. Can cross barriers."],
	"vault": ["Wall runner", "mobility", "ground", 290, 4, 2, 0, "Vault over a nearby barrier. Each barrier has a separate 12s reuse lockout."],
	"pursuit": ["Scrap pursuit", "active", "ground", 310, 8, 1, 12, "Lunge to a target for 32 damage. A kill refunds the charge, once per target."],
	"landing": ["Orbital entry", "ultimate", "ground", 800, 32, 1, 36, "Commit to a 0.9s leap. Land for 120 damage in a 150-radius impact."],
	"artillery": ["Siege battery", "ultimate", "ground", 850, 30, 1, 36, "Root for up to 6s. Recast to fire 3 aimed shells for 65 damage each. Right-click cancels."],
	"roller": ["Ballast roll", "speed", "line", 0, 17, 1, 0, "Accelerate for up to 4s, steering with the cursor. Crash for 35–100 damage. Recast to brake."],
	"forward_sentry": ["Line sentry", "summon", "ground", 340, 10, 2, 20, "Deploy an 18s sentry. Fires in the cursor direction. Replaces the oldest when capacity is full."],
	"pulse_sentry": ["Pulse anchor", "summon", "ground", 340, 12, 2, 22, "Deploy an 18s anchor. Pulses for 12 damage every 1.5s. Recast nearby to swap positions."],
	"medic_sentry": ["Repair anchor", "summon", "ground", 340, 14, 1, 24, "Deploy a 20s repair aura: 2% hull/sec within 120. Recast nearby to teleport to it."],
	"mirror_sentry": ["Echo sentry", "summon", "ground", 340, 13, 2, 24, "For 20s, mirrors an eligible skillshot or sweep at 45% strength every 3s. Mirrors never trigger mirrors."],
	"hook_sentry": ["Winch sentry", "summon", "ground", 340, 12, 2, 22, "For 20s, hooks a nearby enemy every 2s for 16 damage. Bosses cannot be dragged."],
	"crawler": ["Blast crawler", "summon", "ground", 340, 12, 2, 22, "A moving 20s summon. Fires 5-damage shots; detonates for 55 when surrounded by 4 enemies."],
}
const PASSIVE_SPECS := {
	"sidebolts": ["Split barrel", "returner", 3, "Commanded basic attacks fire two additional non-proccing bolts at nearby targets for 45% damage."],
	"plates": ["Plate magazine", "recall", 3, "Commanded hits plant plates, up to 12. Plate recall pulls them through enemies."],
	"threehit": ["Third contact", "thrust", 3, "Every third commanded hit on one target deals 12 bonus damage. Counters expire after 6s."],
	"momentum": ["Flywheel", "roller", 3, "Moving builds momentum. At full speed, collide for a capped 45-damage blast. Five-second crash recovery."],
	"hopdrive": ["Hop drive", "tumble", 2, "After a commanded basic attack, your next move order makes a short 65-distance hop. Never moves you without a command."],
	"converter": ["Life converter", "repair_channel", 0, "Cycle energy-to-hull, hull-to-energy, off. Transfers 10 energy/sec for 2% hull/sec; reverse stops at 30% hull."],
	"mounted": ["Shoulder drones", "forward_sentry", 3, "Two small mounted drones fire alternating 3-damage bolts. They do not use major summon capacity."],
}
const DISCOVERY_WEIGHTS := {"gravity":2,"crosswire":2,"echo_dash":2,"consume":2,"recall":2,"pursuit":2,"landing":1,"artillery":2,"vault":2,"mirror_sentry":2,"hook_sentry":2,"crawler":2}

static func draw_discovery(pool: Array, rng: RandomNumberGenerator) -> String:
	var total := 0
	for id in pool: total += int(DISCOVERY_WEIGHTS.get(id,4))
	var roll := rng.randi_range(0,total-1)
	for id in pool:
		roll -= int(DISCOVERY_WEIGHTS.get(id,4))
		if roll < 0: return id
	return pool[0]

static func actives() -> Dictionary:
	var result := {}
	for id in SPECS:
		var s: Array = SPECS[id]
		result[id] = {"name": s[0], "category": s[1], "aim": s[2], "range": float(s[3]), "cd": float(s[4]), "max": s[5], "cost": float(s[6]), "text": s[7], "icon": id, "glyph": id}
	return result

static func passives() -> Dictionary:
	var result := {}
	for id in PASSIVE_SPECS:
		var s: Array = PASSIVE_SPECS[id]
		result[id] = {"name": s[0], "icon": s[1], "text": s[3]}
	return result

static func modern_ids(category: String) -> Array:
	var ids: Array = {"active": ["rocket", "flame", "nuke"], "ultimate": ["laser"], "speed": ["sprint"], "mobility": ["blink"], "summon": []}.get(category, []).duplicate()
	for id in SPECS:
		if SPECS[id][1] == category: ids.append(id)
	return ids
