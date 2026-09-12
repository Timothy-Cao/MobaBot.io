extends "res://tests/demo_pacing_test.gd"
func free_point(p: Vector2, walls: Array, radius: float=24) -> bool:
	for wall in walls:
		if Geometry2D.get_closest_point_to_segment(p,wall.a,wall.b).distance_to(p)<wall.width+radius: return false
	return true
func execute() -> void:
	var signatures: Array=[]
	for level in range(1,4):
		for stage in range(3):
			var run:=fresh(level); FactoryMaps.enable(run); run.exp.route_index=stage; run.exp.enter(run)
			var walls: Array=run.kit.extra.walls
			check(free_point(run.player,walls,150),"Clear arrival arena")
			check(walls.size()<=14,"Bounded prop count")
			var before:=var_to_str(walls); var rng_state: int=run.loot_rng.state
			run.player+=Vector2(300,400); RunTerrain.build(run)
			check(before==var_to_str(run.kit.extra.walls) and rng_state==run.loot_rng.state,"Geometry independent of player and loot RNG")
			for w in walls:
				check(run.ARENA.grow(-120).has_point(w.a) and run.ARENA.grow(-120).has_point(w.b),"Wall endpoints inside arena")
			# Coarse cardinal flood: every sampled walkable cell must connect.
			var cells: Dictionary={}; var queue: Array[Vector2i]=[]
			for x in range(66):
				for y in range(41):
					var cell:=Vector2i(x,y); var p:=Vector2(-2160+x*80,-1360+y*80)
					if free_point(p,walls,40): cells[cell]=false
			queue.append(cells.keys()[0]); cells[queue[0]]=true; var index:=0
			while index<queue.size():
				var cell: Vector2i=queue[index]; index+=1
				for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
					var next: Vector2i=cell+d
					if cells.has(next) and not cells[next]: cells[next]=true; queue.append(next)
			check(queue.size()==cells.size(),"All sampled routes connected")
			if stage==0: signatures.append(before)
	check(signatures[0]!=signatures[1] and signatures[1]!=signatures[2],"Distinct level geometry")
	var saved:=fresh(2); FactoryMaps.enable(saved); saved.state="camp"; saved.exp.clear_clock=-2
	var forge:=ForgeEquipment.new(); check(forge.bank_camp(saved,false),"Factory checkpoint banks without saving")
	var resumed:=fresh(); check(forge.resume_into(resumed) and FactoryMaps.enabled(resumed),"Resume retains factory rules")
	check(var_to_str(resumed.kit.extra.walls)==var_to_str(saved.kit.extra.walls),"Resume rebuilds the same layout")
	var corrupt:=forge.checkpoint.duplicate(true); corrupt.loadout.factory31="yes"
	check(not ForgeEquipment.valid_checkpoint(corrupt),"Reject invalid map flag")
	var legacy:=fresh(); check(not FactoryMaps.enabled(legacy),"Existing checkpoints retain old maps")
	FactoryMaps.enable(legacy); legacy.exp.practice=true; check(not FactoryMaps.enabled(legacy),"Practice remains unchanged")
	if "--render" in OS.get_cmdline_user_args(): await captures()
	print("FACTORY MAPS: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
func captures() -> void:
	var game=load("res://src/salvage/expedition.tscn").instantiate(); game.persist_settings=false
	root.add_child(game); await process_frame; game.set_physics_process(false); game.sound.set_muted(true); game.music_player.shutdown()
	game.collection=ForgeEquipment.new(); game.launch_expedition(); game.auto_play=true
	for level in range(1,4):
		game.model.exp.operation_chapter=level; game.model.exp.enter(game.model); game.ui.show_running(); game.ui.update_hud(game.model); game.ui.announce(FactoryMaps.NAMES[level-1])
		game.art.queue_redraw(); await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://output/factory-level-%d.png"%level)
	game.chapter_choice=1; OperationView.prepare(game)
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://output/factory-selector.png")
	game.queue_free(); await process_frame
