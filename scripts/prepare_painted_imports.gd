extends SceneTree
## Mechanical importer metadata normalization; source illustrations stay untouched.
func _initialize() -> void:
	var count:=0
	for file in DirAccess.get_files_at("res://assets/painted"):
		if not file.ends_with(".png.import"): continue
		var config:=ConfigFile.new(); var path: String="res://assets/painted/"+file
		if config.load(path)!=OK: continue
		config.set_value("params","process/size_limit",256)
		config.set_value("params","mipmaps/generate",true)
		if config.save(path)!=OK: push_error("Could not configure "+file); quit(1); return
		count+=1
	print("PAINTED IMPORTS: ",count); quit()
