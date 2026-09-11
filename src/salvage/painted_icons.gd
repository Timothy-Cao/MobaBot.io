class_name PaintedIcons
extends RefCounted
## Base vectors remain unchanged. Missing painted assets fall back individually.
static var enabled := true
static var cache: Dictionary={}
static func texture(id: String) -> Texture2D:
	if not enabled: return null
	if cache.has(id): return cache[id]
	var path: String=("res://assets/vanguard_icons/" if id.begins_with("vanguard_") else "res://assets/painted/")+id+".png"
	if id.begins_with("mastery_"): path="res://assets/mastery_icons/"+id+".png"
	if id.begins_with("conductor_"): path="res://assets/painted/"+{"conductor_q":"laser","conductor_w":"crosswire","conductor_e":"thrust","conductor_r":"lightning"}.get(id,"laser")+".png"
	if not ResourceLoader.exists(path): return null
	var value:=load(path) as Texture2D
	cache[id]=value
	return value
