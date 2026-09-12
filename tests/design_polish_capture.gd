extends SceneTree
## Render-only review fixture. No player collection or checkpoint writes.
func _initialize() -> void: capture.call_deferred()
func shot(game, label: String) -> void:
	game.art.queue_redraw(); await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/polish37-"+label+".png")
func capture() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
	root.add_child(game); await process_frame
	game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.collection=ForgeEquipment.new(); game.launch_expedition(); game.auto_play=true
	for level in range(1,4):
		game.model.exp.operation_chapter=level; game.model.exp.enter(game.model)
		game.model.factory_works.ensure(game.model)
		game.ui.show_running(); game.ui.announce(FactoryMaps.NAMES[level-1]); game.ui.update_hud(game.model)
		game.model.enemies.clear()
		for i in range(24):
			game.model.spawn_enemy(game.model.player+Vector2.from_angle(i*2.4)*(120+(i%5)*45),0)
			game.model.enemies.back().warmup=0
		var laser:=RangedThreats.spawn(game.model,"lancer",game.model.player+Vector2(300,-100),true)
		assert(not laser.is_empty(),"Capture requires an actual ranged attacker")
		laser.warmup=0; laser.phase="aim"; laser.dir=Vector2(-1,0.3).normalized()
		laser.beam_end=RangedThreats.beam_end(game.model,laser.pos,laser.dir)
		var walls:=var_to_str(game.model.kit.extra.walls)
		var actors:=var_to_str(game.model.enemies)
		var rng_state: int=game.model.loot_rng.state
		for state in ["ready","armed","active","cooldown"]:
			var m: Dictionary=game.model.factory_works.machines[0]
			m.armed=state=="armed"; m.windup=0.4 if m.armed else 0.0
			m.active=(5.0 if level==3 else 0.5) if state=="active" else 0.0
			m.cooldown=20.0 if state=="cooldown" else 0.0
			var machines:=var_to_str(game.model.factory_works.machines)
			await shot(game,"level-%d-%s"%[level,state])
			assert(machines==var_to_str(game.model.factory_works.machines),"Rendering must not mutate machinery")
		game.model.factory_works.machines[0].active=5.0 if level==3 else 0.5
		game.art.reduced_effects=true; await shot(game,"level-%d-reduced"%level); game.art.reduced_effects=false
		assert(walls==var_to_str(game.model.kit.extra.walls) and actors==var_to_str(game.model.enemies) and rng_state==game.model.loot_rng.state,"Rendering must not mutate combat, terrain or loot RNG")
	game.model.state="camp"; game.model.exp.clear_clock=-2; game.screen="camp"; game.review_tab="Round clear"
	game.model.exp.reward_receipt={"chests":0,"points":0,"credits":240,"items":{ForgeEquipment.ITEMS.keys()[0]:1}}
	for credits in [350,0]:
		game.model.exp.field_credits=credits; ReviewView.camp(game)
		game.ui.overlay.find_child("RoundReceipt",true,false).finish_reveal()
		var count:=0
		for b in game.ui.overlay.find_children("*","Button",true,false):
			if b.has_meta("module_purchase"):
				count+=1; assert(b.disabled==(credits==0),"Module availability must match credits")
		assert(count==4,"Four modules must remain accessible")
		await shot(game,"camp-%d"%credits)
	for id in ForgeEquipment.ITEMS.keys().slice(0,5): game.model.exp.reward_receipt.items[id]=1
	ReviewView.camp(game); game.ui.overlay.find_child("RoundReceipt",true,false).finish_reveal()
	await shot(game,"camp-six-rewards")
	game.review_tab="Mastery"; ReviewView.camp(game); await shot(game,"mastery")
	game.model.state="upgrade"; game.model.offers.assign(["q","xp_gain","pickup_range"]); Vanguard.earn(game.model)
	ReviewView.upgrades(game.ui,game.model); await shot(game,"cards")
	game.ui.reduced=true; game.art.reduced_effects=true; ReviewView.upgrades(game.ui,game.model); await shot(game,"cards-reduced")
	print("DESIGN POLISH: state, collision and RNG preserved; module affordability checked; normal/reduced captures complete")
	game.queue_free(); await process_frame; quit()
