extends SceneTree
## Deterministic visual fixtures. No controller/profile/audio nodes or player saves.
const SHOWCASE := ["returner","gravity","strike","tractor","reap","wall","mirror_sentry","roller"]
var checks := 0
var failures := 0
var art
var title: Label
var frame_number := 0
var folder := "res://output/skill-review"

func _initialize() -> void: review.call_deferred()

func check(value: bool, label: String) -> void:
	checks += 1
	if not value: failures += 1; push_error(label)

func snapshot(run: SalvageRun) -> int:
	var engine: BotSkillEngine=run.kit.extra
	return hash([run.player,run.health,run.kit.energy,run.spawn_rng.state,run.offer_rng.state,run.loot_rng.state,run.enemies,run.projectiles,engine.fields,engine.blades,engine.walls,engine.summons,engine.plates,engine.recasts,run.vanguard.constructs,run.vanguard.impacts,run.vanguard.ghosts])

func fixture(id: String, rank_value: int) -> SalvageRun:
	var run:=SalvageRun.new(715)
	run.loot_rng.seed=run.run_seed+901
	run.enable_moba(MobaKit.demo_preset()); run.enable_demo()
	run.attacks.enabled=true; run.kit.onboarding=true; run.kit.starting_gun=true
	BotExpedition.new().start(run,"ranged",0)
	if "--revised" in OS.get_cmdline_user_args(): run.exp.enable_revision(run)
	run.player=Vector2(310,300); run.kit.pet_position=run.player
	run.kit.extra.clear_combat(); run.kit.toggles=[false,false,false,false]
	run.kit.discovered.assign(MobaKit.BIND_SLOTS)
	var slot: String={"active":"q","ultimate":"r","speed":"d","mobility":"f","summon":"t"}[MobaKit.ABILITIES[id].category]
	run.exp.install(run,slot,id); run.kit.ranks[slot]=rank_value
	run.health=60; run.kit.energy=1000
	for offset in [Vector2(165,0),Vector2(200,75),Vector2(240,-55)]:
		run.spawn_enemy(run.player+offset,0)
		var enemy: Dictionary=run.enemies.back()
		enemy.warmup=0; enemy.hp=2000; enemy.max_hp=5000
	if id=="vault": run.kit.extra.walls=[{"uid":99,"a":run.player+Vector2(50,-70),"b":run.player+Vector2(50,70),"life":5.0}]
	if id=="recall":
		for i in range(3): run.kit.extra.plates.append(run.player+Vector2(240,i*24-24))
	if id=="thrust": run.kit.extra.combo=2
	var point: Vector2=run.player+Vector2(165,0)
	if id=="consume": point=run.player+Vector2(140,0); run.enemies[0].pos=point
	if MobaKit.ABILITIES[id].category=="summon": point=run.player+Vector2(85,-85)
	if id=="roller":
		for enemy in run.enemies: enemy.pos+=Vector2(440,0)
	run.kit.extra.cursor=run.player+Vector2(250,0)
	check(run.kit.cast(run,slot,point),"Visual fixture casts "+id)
	if id=="crosswire": run.kit.cast(run,slot,point+Vector2(35,95))
	if id=="artillery": run.kit.cast(run,slot,point)
	return run

func review() -> void:
	root.size=Vector2i(960,540)
	root.content_scale_size=Vector2i(960,540)
	art=load("res://src/salvage/workshop_art.gd").new()
	root.add_child(art); art.set_process(false); art.world_mode=true
	title=Label.new(); title.position=Vector2(30,25); title.add_theme_font_size_override("font_size",22)
	root.add_child(title)
	var showcase: bool="--showcase" in OS.get_cmdline_user_args()
	var vanguard_showcase: bool="--vanguard-showcase" in OS.get_cmdline_user_args()
	var rendered: bool=DisplayServer.get_name()!="headless"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--folder="): folder=arg.trim_prefix("--folder=")
	if (showcase or vanguard_showcase) and rendered: DirAccess.make_dir_recursive_absolute(folder)
	var ids: Array=SHOWCASE if showcase else []
	if not showcase and not vanguard_showcase:
		for category in ["active","ultimate","speed","mobility","summon"]: ids.append_array(BotSkillCatalog.modern_ids(category))
	for id in ids:
		for rank_value in ([5] if showcase else [0,5,10]):
			for reduced in ([false] if showcase else [false,true]):
				var run:=fixture(id,rank_value); art.model=run; art.effects.clear(); art.visual_time=0
				art.reduced_effects=reduced; art.shake=0
				title.text="%s · Rank %d%s" % [MobaKit.ABILITIES[id].name,rank_value," · Reduced" if reduced else ""]
				for frame in range(45):
					run.time+=1.0/30; run.kit.step(run,1.0/30)
					if run.kit.dash_left>0: run.kit.move_dash(run,1.0/30)
					run._projectile_step(1.0/30)
					if id=="mirror_sentry" and frame==20: run.kit.extra.mirror(run,"returner",Vector2.RIGHT,1)
					for event in run.events: art.receive(event)
					run.events.clear(); art._process(1.0/30)
					if not showcase and frame not in [1,5,12,24,44]: continue
					var state: int=snapshot(run)
					art.queue_redraw(); await process_frame
					if rendered: await RenderingServer.frame_post_draw
					if rendered and "--stills" in OS.get_cmdline_user_args() and id in ["flame","sweep","reap","thrust"] and frame==5 and rank_value in [0,5]:
						root.get_texture().get_image().save_png("res://output/skill17-%s-%d-%s.png"%[id,rank_value,"reduced" if reduced else "normal"])
					check(state==snapshot(run),"Rendering is simulation-independent")
					check(art.effects.size()<=(65 if reduced else 180),"Visual event pool stays bounded")
					if showcase and rendered:
						root.get_texture().get_image().save_png(folder+"/frame-%04d.png"%frame_number); frame_number+=1
	for rank_value in ([5,10] if vanguard_showcase else [1,5,10]):
		for reduced in ([false] if vanguard_showcase else [false,true]):
			for slot in Vanguard.KEYS.keys()+["hammer","gun"]:
				var run:=fixture("rocket",0)
				BotKeyboard.enable(run); run.exp.enable_revision(run); Vanguard.setup(run,rank_value)
				run.projectiles.clear(); run.kit.extra.walls.clear()
				art.model=run; art.effects.clear(); art.reduced_effects=reduced
				art.visual_time=0; art.auto_flash=0; art.cast_pose=0
				var target: Vector2=run.player+(Vector2(80,45) if slot in ["x1","x2","x3"] else Vector2(160,0))
				title.text="Vanguard / %s / Rank %d"%[slot.to_upper(),rank_value]
				if slot=="gun":
					run.vanguard.gun_shots=4; run.attacks.auto_cooldown=0; run.attacks._fire_auto(run)
					check(not run.projectiles.is_empty(),"MG milestone visual shot")
				else: check(run.vanguard.swing(run,target) if slot=="hammer" else run.vanguard.cast(run,slot,target),"Vanguard visual cast")
				if slot=="x2": run.vanguard.constructs[0].bank=70; run.health=30
				for tick in range(60 if vanguard_showcase else 30):
					run.time+=1.0/30
					run.vanguard.tick(run,1.0/30)
					run._projectile_step(1.0/30)
					if slot=="gun": run.attacks.auto_cooldown-=1.0/30; run.attacks._fire_auto(run)
					if slot=="d": run.velocity=Vector2(120,0); run.player+=Vector2(2,0)
					for event in run.events: art.receive(event)
					run.events.clear(); art._process(1.0/30)
					if not vanguard_showcase and tick not in [0,6,15,29]: continue
					var state:=snapshot(run)
					art.queue_redraw(); await process_frame
					if rendered: await RenderingServer.frame_post_draw
					check(snapshot(run)==state,"Vanguard renderer stays read-only")
					check(run.vanguard.impacts.size()<32,"Vanguard effects bounded")
					if vanguard_showcase and rendered:
						root.get_texture().get_image().save_png(folder+"/frame-%04d.png"%frame_number); frame_number+=1
	for reduced in [false,true]:
		art.reduced_effects=reduced; art.effects.clear()
		var limit: int=65 if reduced else 180
		for i in range(limit+20): art.receive({"kind":"hit","pos":Vector2.ZERO})
		check(art.effects.size()==limit,"Cosmetic saturation respects pool cap")
		art.receive({"kind":"nuke_impact","pos":Vector2.ZERO,"radius":150})
		check(art.effects.any(func(e): return e.kind=="nuke_impact"),"Major impact displaces a cosmetic event")
		check(art.effects.size()==limit,"Important effects do not grow the pool")
		art._process(2)
		check(art.effects.is_empty(),"Effects expire without residual trails")
	if rendered and showcase: await icon_sheet()
	art.queue_free(); title.queue_free(); await process_frame
	print("SKILL VISUAL TEST: %d checks; %d failures; %d captured frames" % [checks,failures,frame_number])
	quit(1 if failures else 0)

func icon_sheet() -> void:
	art.hide(); title.text="Ability icons · 64 / 32 px"
	var ids: Array=[]
	for category in ["active","ultimate","speed","mobility","summon"]: ids.append_array(BotSkillCatalog.modern_ids(category))
	for i in range(ids.size()):
		var at:=Vector2(20+(i%6)*155,65+(i/6)*78)
		for side in [64,32]:
			var icon=load("res://src/salvage/ability_icon.gd").new()
			icon.ability=ids[i]; icon.position=at+Vector2(0 if side==64 else 68,0)
			icon.size=Vector2(side,side); root.add_child(icon)
		var label:=Label.new(); label.position=at+Vector2(67,34); label.text=MobaKit.ABILITIES[ids[i]].name.replace(" ","\n")
		label.add_theme_font_size_override("font_size",11); root.add_child(label)
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(folder+"/icons.png")
