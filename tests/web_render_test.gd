extends SceneTree
## Native defaults plus optional GPU parity/state-preservation check. No player data.
class Preview extends "res://src/salvage/workshop_art.gd":
	func _draw() -> void:
		draw_rect(Rect2(0,0,960,540),INK)
		for enemy in model.enemies: _enemy(enemy)
		for pickup in model.pickups: _scrap(pickup)

func _initialize() -> void: execute.call_deferred()
func execute() -> void:
	var art:=Preview.new(); art.model=SalvageRun.new(8124)
	assert(art.web_cached_art==OS.has_feature("web"),"Native must keep original renderer")
	art.web_cached_art=false; root.add_child(art); art.set_process(false); art.visual_time=1.25
	assert(art.web_atlas==null,"Native never allocates an atlas")
	for i in range(4):
		art.model.spawn_enemy(Vector2(90+i*120,110),0)
		art.model.enemies.back().warmup=1 if i==2 else 0
		art.model.enemies.back().flash=1 if i==1 else 0
		art.model.enemies.back().elite=i==3
	for i in range(3): art.model.pickups.append({"id":i,"pos":Vector2(90+i*120,230),"value":[1,5,20][i],"pull":false,"speed":0.0})
	var frozen:=var_to_str([art.model.enemies,art.model.pickups,art.model.loot_rng.state])
	if "--render" in OS.get_cmdline_user_args():
		root.size=Vector2i(960,540)
		for reduced in [false,true]:
			art.reduced_effects=reduced; art.web_cached_art=false; art.queue_redraw()
			await process_frame; await RenderingServer.frame_post_draw
			var before:=root.get_texture().get_image()
			if art.web_atlas==null:
				art.web_atlas=WebArtAtlas.new(); art.web_atlas.attach(art)
				await process_frame; await RenderingServer.frame_post_draw
			art.web_cached_art=true; art.queue_redraw()
			await process_frame; await RenderingServer.frame_post_draw
			var after:=root.get_texture().get_image()
			assert(art.web_atlas.ready,"Atlas must be rendered before reuse")
			var difference:=0.0
			for y in range(70,270):
				for x in range(45,500):
					var a:=before.get_pixel(x,y); var b:=after.get_pixel(x,y)
					difference+=absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b)
			difference/=200*455*3
			assert(difference<0.002,"Cached art must retain shape/colors, allowing raster edge differences")
			# A premultiplied viewport sampled as straight alpha darkens these shadows.
			for x in [90,210,330,450]:
				var a:=before.get_pixel(x,124); var b:=after.get_pixel(x,124)
				assert(absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b)<0.04,"Shadow alpha must match native")
			before.save_png("res://output/web41-native-%s.png"%reduced)
			after.save_png("res://output/web41-cached-%s.png"%reduced)
			print("WEB ART PIXEL ERROR ",reduced," ",difference)
	assert(frozen==var_to_str([art.model.enemies,art.model.pickups,art.model.loot_rng.state]),"Rendering cannot mutate enemies, loot or RNG")
	art.queue_free(); await process_frame
	print("WEB RENDER: native defaults and immutable fixtures PASS"); quit()
