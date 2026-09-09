extends SceneTree
## Source validation + actual-size imported texture / Base icon comparisons.
var failures:=0
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	root.size=Vector2i(1600,1000); root.content_scale_size=Vector2i(1600,1000)
	var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/painted/manifest.json"))
	var rendered: bool="--render" in OS.get_cmdline_user_args()
	var pages:=ceili(manifest.assets.size()/20.0)
	for page in range(pages):
		var canvas:=Control.new(); root.add_child(canvas)
		var background:=ColorRect.new(); background.size=Vector2(1600,1000); background.color=Color("14242c"); canvas.add_child(background)
		for i in range(page*20,mini((page+1)*20,manifest.assets.size())):
			var id: String=manifest.assets[i].id
			var path: String="res://assets/painted/"+id+".png"
			if not FileAccess.file_exists(path): failures+=1; push_error("Missing "+id); continue
			var source:=Image.new()
			source.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
			if source==null or source.get_width()!=source.get_height() or source.detect_alpha()!=Image.ALPHA_NONE:
				failures+=1; push_error("Expected square opaque icon: %s (%d x %d, alpha %d)"%[id,source.get_width(),source.get_height(),source.detect_alpha()]); continue
			var texture: Texture2D=PaintedIcons.texture(id)
			if texture==null: failures+=1; push_error("Unimported "+id); continue
			if texture.get_width()>256: failures+=1; push_error("Import budget exceeded: "+id)
			var index:=i%20; var p:=Vector2(18+(index%5)*316,24+(index/5)*234)
			var label:=Label.new(); label.text=id; label.position=p; label.add_theme_font_size_override("font_size",15); canvas.add_child(label)
			var x:=0.0
			for side in [128,64,32]:
				var picture:=TextureRect.new(); picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; picture.texture=texture; picture.position=p+Vector2(x,32+128-side)
				picture.size=Vector2.ONE*side; picture.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS; canvas.add_child(picture); x+=side+8
			var base=load("res://src/salvage/ability_icon.gd").new(); base.ability=id; base.base_only=true; base.position=p+Vector2(x,128); base.size=Vector2(32,32); canvas.add_child(base)
			var caption:=Label.new(); caption.text="128                  64       32      Base"; caption.position=p+Vector2(0,174); caption.add_theme_font_size_override("font_size",12); canvas.add_child(caption)
		await process_frame
		if rendered:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://output/painted-page-%d.png"%page)
		canvas.queue_free(); await process_frame
	print("PAINTED ART: %d assets, %d failures"%[manifest.assets.size(),failures]); quit(0 if failures==0 else 1)
