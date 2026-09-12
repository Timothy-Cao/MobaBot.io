class_name OperationRules
extends RefCounted
## Short, authored reset boundary. Legacy expeditions never opt in on resume.
const CHAPTERS := 8
const ROUND_SECONDS := [90.0,105.0,120.0]
const SURVIVAL_XP := [40,60,80]
const FIELD_REWARD := [350,500,650]
const XP_PER_LEVEL := 20
const ENRAGE_SECONDS := 180.0

static func enabled(run) -> bool:
	return ReviewRules.enabled(run) and run.exp!=null and run.exp.operation_chapter>0 and not run.exp.practice

static func enable(run, chapter: int) -> void:
	run.exp.operation_chapter=clampi(chapter,1,CHAPTERS)
	run.kit.loadout.operation20=run.exp.operation_chapter
	run.kit.loadout.operation_xp=[0,0,0]
	run.level=1; run.total_xp=0; run.next_level=XP_PER_LEVEL; run.xp_fraction=0
	run.exp.route_index=0; run.exp.enter(run)

static func chapter_health(chapter: int) -> float: return 1.0+0.22*(chapter-1)
static func pickup_divisor(chapter: int) -> float: return 18.0*(1.0+0.36*(chapter-1))

static func difficulty_text(value: int) -> String:
	var text: String="Incoming damage +%d%% · Speed +%d%%\nBoss health +%d%%"%[value*12,value*2,value*12]
	if value>=2: text+="\nOrdinary enemy hull +20%; extra pressure packs"
	if value>=3: text+="\n15 less energy; repair regeneration -20%"
	if value>=5: text+="\n1 less energy/sec"
	return text+"\nClear Chapter 8 to unlock the next Ascension."
static func reference_rank(round_index: int) -> int: return [2,5,8][clampi(round_index,0,2)]

static func survival_budget(index: int, demo: bool=false) -> int:
	return roundi(SURVIVAL_XP[index]*(DemoPacing.XP_RATE if demo else 1.0))

static func pace(run) -> void:
	if not enabled(run) or run.exp.clear_clock>=0: return
	var index: int=run.exp.route_index
	var expected:=floori(survival_budget(index,DemoPacing.enabled(run))*clampf(run.stage_time/run.exp.round_seconds(),0,1))
	var granted: int=run.kit.loadout.operation_xp[index]
	if expected>granted:
		run.xp_fraction+=(expected-granted)*DiscoveryRules.xp_rate(run)
		var gain:=floori(run.xp_fraction+0.000001)
		run.total_xp+=gain; run.xp_fraction=maxf(0,run.xp_fraction-gain)
		run.kit.loadout.operation_xp[index]=expected

static func boss_hp(run) -> float:
	return 6000.0*DemoPacing.enemy_rate(run)*chapter_health(run.exp.operation_chapter)*(1.0+0.12*run.exp.ascension)

static func roster(run) -> Array:
	var result:=ReviewRules.specialist_roster(run.exp.route_index)
	if run.exp.operation_chapter>=2 and "emp" not in result: result.append("emp")
	return result
