extends SceneTree
func _initialize() -> void:
	var symbols: Font=load("res://assets/fonts/NotoSansSymbols2-Regular.ttf")
	var failed:=false
	for character in "◇○●":
		if not symbols.has_char(character.unicode_at(0)): failed=true; push_error("Missing HUD symbol: "+character)
	var preset:=ConfigFile.new(); preset.load("res://export_presets.cfg")
	if preset.get_value("preset.1.options","variant/thread_support")!=false: failed=true; push_error("Default browser target must remain single-threaded")
	print("WEB COMPAT: ","FAIL" if failed else "PASS"); quit(1 if failed else 0)
