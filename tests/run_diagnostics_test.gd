extends SceneTree
func _initialize() -> void:
	var run:=SalvageRun.new(17017)
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo()
	BotExpedition.new().start(run,"ranged",0); BotKeyboard.enable(run); run.exp.enable_revision(run); Vanguard.setup(run,5)
	var before:=run.summary(); var record:=run.summary()
	RunDiagnostics.annotate(record,run,false)
	var ok: bool=record.build==RunDiagnostics.BUILD and record.log_schema==2 and not record.practice and not record.automated
	ok=ok and record.earned_tool_ranks.size()==12 and record.earned_tool_ranks.q==5 and record.earned_tool_ranks.gun==5 and record.earned_tool_ranks.hammer==5
	ok=ok and before==run.summary()
	run.exp.practice=true; RunDiagnostics.annotate(record,run,true)
	ok=ok and record.practice and record.automated
	if not ok: push_error("Run diagnostic metadata or isolation failed")
	print("RUN DIAGNOSTICS: ","PASS" if ok else "FAIL"); quit(0 if ok else 1)
