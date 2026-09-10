extends SceneTree
## Analytical reference, not a play policy or a human-DPS claim. No saves.
func _initialize() -> void:
	for rank_value in [1,5,9,10]:
		var run:=SalvageRun.new(7127); run.loot_rng.seed=8028
		run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
		BotExpedition.new().start(run,"ranged",0); run.exp.enable_revision(run)
		Vanguard.setup(run,rank_value); ReviewRules.enable(run)
		var q:=UpgradePreview.stats(run,"q",rank_value)
		var w:=UpgradePreview.stats(run,"w",rank_value)
		var e:=UpgradePreview.stats(run,"e",rank_value)
		var r:=UpgradePreview.stats(run,"r",rank_value)
		var hammer:=UpgradePreview.stats(run,"hammer",rank_value)
		var gun:=UpgradePreview.stats(run,"gun",rank_value)
		var energy: float=8/q["Recharge sec"]+18/w["Recharge sec"]+14/e["Recharge sec"]+32/r["Recharge sec"]
		var spells: float=q["Direct + blast"]/q["Recharge sec"]+w["Center damage"]/w["Recharge sec"]+e["Impact damage"]/e["Recharge sec"]+r["Impact damage"]*(1.25 if rank_value>=10 else 1)/r["Recharge sec"]
		var autos: float=hammer["Head damage"]*hammer["Swing / sec"]+gun.Damage*gun["Shots / sec"]
		var ceiling: float=autos+spells
		print("PROGRESSION_BUDGET "+JSON.stringify({"rank":rank_value,"w_center":w["Center damage"],"perfect_contact_dps_ceiling":snappedf(ceiling,0.1),"spell_energy_per_sec":snappedf(energy,0.1),"energy_limited_reference":snappedf(autos+spells*minf(1,8/energy),0.1),"gear_mastery":"none","excludes":"movement, cast lockouts, misses, vulnerability, combo, modules and boss recovery"}))
	quit()
