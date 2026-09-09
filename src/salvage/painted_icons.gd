class_name PaintedIcons
extends RefCounted
## Base vectors remain unchanged. Missing painted assets fall back individually.
static var enabled := true
static var cache: Dictionary={}
static func texture(id: String) -> Texture2D:
	if not enabled: return null
	if cache.has(id): return cache[id]
	var path: String="res://assets/painted/"+id+".png"
	if not ResourceLoader.exists(path): return null
	var value:=load(path) as Texture2D
	cache[id]=value
	return value
