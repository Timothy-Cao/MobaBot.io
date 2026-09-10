class_name RunDiagnostics
extends RefCounted
## Metadata only. Never reads/writes equipment or changes the simulation.
const BUILD := "vanguard-18-pressure-audio"
const REVIEW_BUILD := "vanguard-19.1-progression-review"

static func sample_progression(run) -> void:
	var exp=run.exp
	if exp.sample_time<0:
		exp.sample_time=run.time; exp.sample_damage=run.damage_dealt.duplicate(); return
	var elapsed: float=run.time-exp.sample_time
	if elapsed<15: return
	var damage:=0.0
	var sources: Dictionary={}
	for source in run.damage_dealt:
		var amount:=maxf(0,float(run.damage_dealt[source])-float(exp.sample_damage.get(source,0)))
		sources[source]=snappedf(amount,0.01); damage+=amount
	var ranks: Dictionary={}
	for slot in ReviewRules.CORE+ReviewRules.MODULES: ranks[slot]=Vanguard.rank_of(run,slot)
	var boss_hp: float=-1
	for enemy in run.enemies:
		if enemy.has("exp_boss") and not enemy.dead: boss_hp=enemy.hp
	exp.progression_samples.append({"route":exp.route_index,"round_seconds":snappedf(run.stage_time,0.1),"interval_seconds":snappedf(elapsed,0.1),"credited_damage_per_second":snappedf(damage/elapsed,0.01),"damage_by_source":sources,"level":run.level,"xp":run.total_xp,"ranks":ranks,"mastery_spent":run.mastery.spent,"field_credits":exp.field_credits,"boss_hp":snappedf(boss_hp,0.1)})
	if exp.progression_samples.size()>96: exp.progression_samples.pop_front()
	exp.sample_time=run.time; exp.sample_damage=run.damage_dealt.duplicate()
static func annotate(record: Dictionary, run, automated: bool) -> void:
	record.log_schema=2
	record.build=BUILD if Vanguard.enabled(run) else "slice-16-keyboard-forge" if run.exp!=null else "slice-13-mobabot"
	if ReviewRules.enabled(run): record.build=REVIEW_BUILD
	if ReviewRules.enabled(run): record.progression_samples=run.exp.progression_samples.duplicate(true)
	if OperationRules.enabled(run): record.build="vanguard-20-chapter-operations"; record.chapter=run.exp.operation_chapter; record.operation_rounds=run.exp.route().size()
	record.practice=run.exp!=null and run.exp.practice
	record.automated=automated
	if Vanguard.enabled(run):
		record.earned_tool_ranks={}
		for tool in Vanguard.KEYS.keys()+["gun","hammer"]: record.earned_tool_ranks[tool]=Vanguard.rank_of(run,tool)
