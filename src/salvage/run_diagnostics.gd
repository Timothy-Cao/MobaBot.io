class_name RunDiagnostics
extends RefCounted
## Metadata only. Never reads/writes equipment or changes the simulation.
const BUILD := "vanguard-18-pressure-audio"
static func annotate(record: Dictionary, run, automated: bool) -> void:
	record.log_schema=2
	record.build=BUILD if Vanguard.enabled(run) else "slice-16-keyboard-forge" if run.exp!=null else "slice-13-mobabot"
	record.practice=run.exp!=null and run.exp.practice
	record.automated=automated
	if Vanguard.enabled(run):
		record.earned_tool_ranks={}
		for tool in Vanguard.KEYS.keys()+["gun","hammer"]: record.earned_tool_ranks[tool]=Vanguard.rank_of(run,tool)
