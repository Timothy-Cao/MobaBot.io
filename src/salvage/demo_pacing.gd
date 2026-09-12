class_name DemoPacing
extends RefCounted
const LEVELS:=3
const XP_RATE:=1.1
const ROUND_SECONDS:=300.0
# First eligibility measured in survival seconds across a three-round Level.
const INTRO:={"breacher":90,"lancer":120,"volley":150,"scatter":270,"mosquito":330,"mender":390,"bomber":450,"hatchery":510}
static func enabled(run) -> bool: return run.exp!=null and run.exp.demo_pace and not run.exp.practice
static func enable(run) -> void:
	run.field_pickups=FieldPickups.new()
	run.exp.demo_pace=true; run.kit.loadout.demo27=true
static func xp_rate(run) -> float: return XP_RATE if enabled(run) else 1.0
static func enemy_rate(run) -> float: return 0.9 if enabled(run) and run.exp.operation_chapter==1 else 1.0
static func reward_rate(run) -> float:
	return OperationRules.ROUND_SECONDS[run.exp.route_index]/ROUND_SECONDS if enabled(run) else 1.0
static func elapsed(run) -> float:
	return (run.exp.operation_chapter-1)*900.0+run.exp.route_index*300.0+run.stage_time
static func specialist(run, wave: int) -> String:
	if DiscoveryRules.enabled(run) and run.exp.route_index==0 and run.stage_time<120: return ""
	var available: Array[String]=[]
	for id in INTRO:
		if elapsed(run)>=INTRO[id]:
			available.append(id)
			if is_equal_approx(elapsed(run)-fmod(run.stage_time,30),float(INTRO[id])): return id
	return "" if available.is_empty() else available[(wave-1)%available.size()]
