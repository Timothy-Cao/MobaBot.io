extends SceneTree
class CursorHost:
	extends Node
	var screen: String="home"
	var pending_attack:=false
	var pending_cast_slot: String=""
var failures:=0
var checks:=0
func check(ok: bool, caption: String) -> void:
	checks+=1
	if not ok: failures+=1; push_error(caption)
func _initialize() -> void: execute.call_deferred()
func execute() -> void:
	check(BotCursor.choose("home",false,false)=="menu","Home pointer")
	check(BotCursor.choose("running",false,false)=="combat","World crosshair")
	check(BotCursor.choose("running",false,true)=="aim","Armed ability cursor")
	check(BotCursor.choose("placement",false,false)=="aim","Practice placement cursor")
	check(BotCursor.choose("running",true,true)=="menu","UI takes priority over aiming")
	check(BotCursor.choose("settings",false,true)=="menu","Menus never inherit combat cursor")
	var panel:=Control.new(); root.add_child(panel)
	for i in range(3):
		var id: String=BotCursor.FILES.keys()[i]
		var texture: Texture2D=load(BotCursor.FILES[id]); var bitmap:=texture.get_image()
		check(texture.get_size()==Vector2(40,40),id+" native size")
		check(Rect2(Vector2.ZERO,texture.get_size()).has_point(BotCursor.HOTSPOTS[id]),id+" valid hotspot")
		check(bitmap.get_pixel(0,0).a==0 and bitmap.get_pixel(39,39).a==0,id+" clean transparent corners")
		var label:=Label.new(); label.text=id.capitalize()+" · 40 px / 80 px"; label.position=Vector2(20,15+i*130); panel.add_child(label)
		for j in range(3):
			var bg:=ColorRect.new(); bg.position=Vector2(20+j*200,45+i*130); bg.size=Vector2(185,92); bg.color=[Color("14242c"),Color("314d56"),Color("fff0c7")][j]; panel.add_child(bg)
			for size_value in [40,80]:
				var icon:=TextureRect.new(); icon.texture=texture; icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; icon.size=Vector2.ONE*size_value; icon.position=Vector2(12 if size_value==40 else 85,6); bg.add_child(icon)
	if "--render" in OS.get_cmdline_user_args():
		root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED
		root.content_scale_size=Vector2i.ZERO
		root.size=Vector2i(640,440)
		await process_frame; await RenderingServer.frame_post_draw
		DirAccess.make_dir_recursive_absolute("res://output/cursors")
		root.get_texture().get_image().save_png("res://output/cursors/review.png")
	panel.queue_free(); await process_frame
	var host:=CursorHost.new(); root.add_child(host)
	var theme:=BotCursor.new(); theme.host=host; host.add_child(theme)
	if DisplayServer.get_name()!="headless":
		check(theme.installed and theme.textures.size()==3,"Native cursor resources installed")
		theme.apply("combat"); check(theme.current=="combat","Hardware combat transition")
		theme.apply("aim"); check(theme.current=="aim","Hardware aim transition")
	host.queue_free(); await process_frame; await process_frame
	print("CURSORS: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
