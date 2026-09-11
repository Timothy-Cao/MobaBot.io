extends SceneTree
var checks:=0
var failures:=0
func check(ok: bool, label: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(label)
func fresh() -> SalvageRun:
	var run:=SalvageRun.new(7127); run.loot_rng.seed=8028
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo(); run.attacks.enabled=true
	BotExpedition.new().start(run,"ranged",0); run.exp.enable_revision(run)
	Vanguard.setup(run,5); ReviewRules.enable(run); OperationRules.enable(run,1); LevelMastery.enable(run); run.kit.loadout.support23=true
	return run
func _initialize() -> void: execute.call_deferred()
func execute() -> void:
	var run:=fresh()
	check(run.vanguard.cast(run,"x3",run.player+Vector2(200,0)),"Energy reserve deploys")
	var energy: Dictionary=run.vanguard.constructs.back()
	check(energy.life==35 and energy.bank==0,"Reserve starts empty with bounded life")
	SupportModules.energy(run,energy,5); check(energy.bank>0,"Charges while away")
	run.player=energy.pos; run.kit.energy=0; var stored: float=energy.bank
	var health: float=run.health
	run.kit.recharge.q=2.0
	SupportModules.energy(run,energy,0.5)
	check(run.kit.energy>0 and energy.bank<stored,"Returns stored energy while occupied")
	check(not run.vanguard.powered(run),"New energy reserve does not give free casts")
	check(run.health==health and run.kit.recharge.q==2.0,"Energy support does not heal or accelerate cooldown clocks")
	run.kit.energy=run.kit.energy_max(); stored=energy.bank; SupportModules.energy(run,energy,1)
	check(energy.bank==stored,"Full energy does not waste stored reserve")
	ReviewRules.suppress(run); stored=energy.bank; run.vanguard.tick(run,0.1)
	check(energy.bank==stored,"EMP suppresses transfer")
	run.vanguard.emp_left=0; run.kit.emp_left=0
	check(run.vanguard.cast(run,"x1",run.player+Vector2(100,0)),"Anchor deploys")
	var anchor: Dictionary=run.vanguard.constructs.back()
	check(anchor.radius==340 and anchor.hp>0,"Anchor has health and truthful attraction radius")
	run.spawn_enemy(anchor.pos+Vector2(80,0),0); var enemy: Dictionary=run.enemies.back()
	var distance: float=Vector2(enemy.pos).distance_to(anchor.pos)
	check(SupportModules.attract(run,enemy,0.2) and Vector2(enemy.pos).distance_to(anchor.pos)<distance,"Ordinary enemy approaches anchor")
	enemy.pos=anchor.pos; var hp: float=anchor.hp
	SupportModules.attract(run,enemy,1); check(anchor.hp<hp,"Enemy damages anchor")
	enemy.role="foreman"; check(not SupportModules.attract(run,enemy,1),"Boss ignores anchor"); enemy.erase("role")
	enemy.gunner_kind="lancer"; check(SupportModules.attract(run,enemy,1),"Ordinary ranged specialist is attracted")
	anchor.hp=0; check(not SupportModules.attract(run,enemy,1),"Dead anchor cannot attract")
	run=fresh(); run.vanguard.cast(run,"x1",run.player); run.vanguard.tick(run,3)
	check(run.projectiles.is_empty(),"Anchor has no turret gun")
	run.state="camp"; run.exp.clear_clock=-2
	var forge:=ForgeEquipment.new(); check(forge.bank_camp(run,false),"Support checkpoint saves")
	var resumed:=fresh(); check(forge.resume_into(resumed) and SupportModules.enabled(resumed),"Support rules resume")
	var old: Dictionary=forge.checkpoint.duplicate(true); old.loadout.erase("support23")
	check(ForgeEquipment.valid_checkpoint(old),"Previous checkpoints remain accepted")
	for id in ["mastery_utility","mastery_looting","mastery_pet","vanguard_anchor","vanguard_energy"]:
		var path: String=("res://assets/mastery_icons/" if id.begins_with("mastery") else "res://assets/vanguard_icons/")+id+".png"
		var source:=Image.new(); source.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
		check(source!=null and source.get_width()==source.get_height(),"Square source "+id)
		check(source.detect_alpha()==Image.ALPHA_NONE,"Opaque source alpha "+id)
		check(PaintedIcons.texture(id)!=null,"Runtime asset resolves "+id)
		check(PaintedIcons.texture(id).get_width()<=128,"Bounded UI import "+id)
	await render_checks()
	print("SUPPORT ART: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
func capture(name: String) -> void:
	if "--render" not in OS.get_cmdline_user_args(): return
	await process_frame; await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://output/support23")
	root.get_texture().get_image().save_png("res://output/support23/"+name+".png")
func render_checks() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
	root.add_child(game); await process_frame; game.set_physics_process(false)
	game.sound.set_muted(true); game.music_player.shutdown(); game.collection=ForgeEquipment.new(); game.launch_expedition()
	check(SupportModules.enabled(game.model),"Normal entry uses support replacements")
	game.model.state="camp"; game.model.exp.clear_clock=-2; game.screen="camp"; game.review_tab="Mastery"; ReviewView.camp(game)
	var nodes:=0
	for button in game.ui.overlay.get_children():
		if not button.has_meta("mastery_node"): continue
		nodes+=1
		var found:=false
		for icon in button.get_children():
			if not icon.has_meta("mastery_base"): continue
			for badge in icon.get_children():
				if badge is MasteryBadge:
					found=badge.symbol in MasteryBadge.SYMBOLS and badge.position.y<0 and badge.position.x+badge.size.x>icon.size.x
		check(found and not button.tooltip_text.is_empty(),"Node has reusable overhanging badge and hover details")
	check(nodes==LevelMastery.TREE.size(),"Every modern node is illustrated")
	await capture("Mastery")
	game.review_tab="Round clear"; ReviewView.camp(game); await capture("Shop")
	game.open_practice(); check(SupportModules.enabled(game.model),"Practice uses support replacements")
	game.practice_rank=5; game.practice_reset()
	check(SupportModules.enabled(game.model),"Practice rank preset retains support rules")
	game.screen="running"; game.model.state="running"; game.ui.show_running()
	for slot in ["x1","x2","x3"]:
		game.model.kit.energy=game.model.kit.energy_max(); game.model.vanguard.cast(game.model,slot,game.model.player+Vector2((int(slot.substr(1))-2)*170,-120))
	for unit in game.model.vanguard.constructs: unit.bank=45
	game.ui.update_hud(game.model); game.art.queue_redraw(); await capture("Modules")
	game.art.reduced_effects=true; game.art.queue_redraw(); await capture("Modules-reduced")
	game.ui.clear_overlay(); ExpeditionView.frame(game.ui,"Reusable icons",game.show_home)
	var ids: Array=["mastery_utility","mastery_looting","mastery_pet","vanguard_anchor","vanguard_energy"]
	for i in range(ids.size()):
		game.ui._label(game.ui.overlay,ids[i],Rect2(48,126+i*70,300,30),14,game.ui.CREAM)
		for j in range(3):
			var size_value: int=[64,40,32][j]
			game.ui._ability_icon(game.ui.overlay,ids[i],Rect2(380+j*140,115+i*70,size_value,size_value))
	await capture("Icon-scales")
	game.ui.clear_overlay(); ExpeditionView.frame(game.ui,"Reusable effect badges",game.show_home)
	for i in range(MasteryBadge.SYMBOLS.size()):
		var at:=Vector2(65+(i%4)*225,130+(i/4)*105)
		MasteryBadge.attach(game.ui,game.ui.overlay,["mastery_utility","mastery_looting","mastery_pet"][i%3],MasteryBadge.SYMBOLS[i],Rect2(at,Vector2(36,36)))
		game.ui._label(game.ui.overlay,MasteryBadge.SYMBOLS[i],Rect2(at+Vector2(54,5),Vector2(140,25)),14,game.ui.CREAM)
	await capture("Badge-catalog")
	game.queue_free(); await process_frame
