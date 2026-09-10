extends SceneTree
const Reference=preload("res://tests/balance_reference.gd")
var checks:=0
var failures:=0
func check(ok: bool, label: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(label)
func _initialize() -> void:
	var lines: Array[String]=["# Current balance benchmark", "", "Generated from live stat functions; analytical references, not measured perfect play. A0, equal core allocation, full indicated gear tier, no modules/pets/proc damage. Mastery profiles spend equal points. Tier is a sensitivity axis, not an assumed Chapter requirement.", "", "| Chapter | Round | Gear tier | Mastery | Level | DPS ref | Boss seconds* | At 50%* | Standard hit % | Tank / W |", "|---|---|---|---|---|---|---|---|---|---|"]
	for chapter in [1,4,8]:
		for round_index in range(3):
			for tier in [0,1,3,5]:
				for focus in ["balanced","offense","defense","utility"]:
					var run=Reference.build(chapter,round_index,tier,focus)
					var row=Reference.measure(run)
					check(is_finite(row.reference_dps) and row.reference_dps>0,"Finite positive reference")
					check(run.mastery.spent==run.level,"Equal mastery point budget")
					check(row.mobile_spell_energy_factor<=row.energy_factor,"Movement consumes the shared resource budget")
					check(is_equal_approx(row.ttk_at_half,2*row.ideal_ttk),"Half delivery doubles kill time")
					lines.append("| %d | %d | %d | %s | %d | %.1f | %s | %s | %.1f | %.2f |"%[chapter,round_index+1,tier,focus,row.level,row.reference_dps,"%.1f"%row.ideal_ttk if round_index==2 else "—","%.1f"%row.ttk_at_half if round_index==2 else "—",row.standard_hit_fraction*100,row.tank_w_hits])
	var a=Reference.build(1,2,1,"offense"); var b=Reference.build(1,2,1,"defense")
	check(OperationRules.boss_hp(a)==OperationRules.boss_hp(b),"Enemies do not adapt to the player's spending")
	check(Reference.measure(b).effective_health>Reference.measure(a).effective_health,"Defense has a measurable survival payoff")
	var again=Reference.build(1,2,1,"offense")
	check(Reference.measure(a)==Reference.measure(again),"Reference is reproducible")
	lines.append("\n*Boss timing appears only for round three. Standard hit is one hull-unit before scaling; it is a normalized defense comparison, not every enemy's actual attack. W counts ignore vulnerability and regeneration. See BALANCE_BENCHMARKS_21.md for acceptance targets and limitations.\n")
	if "--report" in OS.get_cmdline_user_args():
		DirAccess.make_dir_recursive_absolute("res://output/balance")
		var file:=FileAccess.open("res://output/balance/current.md",FileAccess.WRITE)
		if file: file.store_string("\n".join(lines))
		else: check(false,"Report can be written")
		for chapter in [1,4,8]:
			var row=Reference.measure(Reference.build(chapter,2,1))
			print("BALANCE_REFERENCE "+JSON.stringify({"chapter":chapter,"tier":1,"profile":"balanced","result":row}))
	print("Balance benchmark: %d checks, %d failures (integrity, not balance acceptance)"%[checks,failures])
	quit(1 if failures else 0)
