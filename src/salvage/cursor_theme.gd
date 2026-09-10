class_name BotCursor
extends Node
## Native hardware cursors: never a frame-delayed follower sprite.
const FILES := {"menu":"res://assets/cursors/menu.svg","combat":"res://assets/cursors/combat.svg","aim":"res://assets/cursors/aim.svg"}
const HOTSPOTS := {"menu":Vector2(4,4),"combat":Vector2(20,20),"aim":Vector2(20,20)}
var host: Node
var textures: Dictionary = {}
var current := ""
var installed := false

static func choose(screen: String, over_ui: bool, aiming: bool) -> String:
	if over_ui or screen not in ["running","placement"]: return "menu"
	return "aim" if aiming or screen=="placement" else "combat"

func _ready() -> void:
	if DisplayServer.get_name()=="headless": set_process(false); return
	for id in FILES: textures[id]=load(FILES[id])
	Input.set_custom_mouse_cursor(textures.menu,Input.CURSOR_POINTING_HAND,HOTSPOTS.menu)
	installed=true
	apply("menu")

func apply(id: String) -> void:
	if current==id or not installed: return
	current=id
	Input.set_custom_mouse_cursor(textures[id],Input.CURSOR_ARROW,HOTSPOTS[id])

func _process(_delta: float) -> void:
	if not is_instance_valid(host): return
	var control: Control=get_viewport().gui_get_hovered_control()
	var over_ui: bool=control!=null and control.mouse_filter!=Control.MOUSE_FILTER_IGNORE
	apply(choose(host.screen,over_ui,host.pending_attack or host.pending_cast_slot!=""))

func _exit_tree() -> void:
	if installed:
		Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
		Input.set_custom_mouse_cursor(null,Input.CURSOR_POINTING_HAND)
