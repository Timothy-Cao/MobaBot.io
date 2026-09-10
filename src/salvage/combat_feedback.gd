class_name CombatFeedback
extends Control
## Edge-only danger feedback; never changes simulation/camera or blocks input.
var fraction:=1.0
var hit_left:=0.0
var reduced:=false

static func severity(value: float) -> int:
	return 2 if value<0.25 else 1 if value<0.5 else 0

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	size=Vector2(960,540)

func receive(event: Dictionary) -> void:
	if event.kind!="hurt": return
	fraction=float(event.get("health_fraction",1))
	hit_left=0.55 if severity(fraction)==2 else 0.35
	queue_redraw()

func _process(dt: float) -> void:
	if hit_left>0: hit_left=maxf(0,hit_left-dt); queue_redraw()

func sync(value: float, active: bool, minimal: bool) -> void:
	visible=active; reduced=minimal
	if not active: hit_left=0
	if fraction!=value: fraction=value; queue_redraw()

func _draw() -> void:
	var level:=severity(fraction)
	if level==0: return
	var tint:=Color("dc7752") if level==1 else Color("ec514e")
	# Persistent small corner marks at critical hull; no heartbeat/strobe.
	var strength: float=(0.32 if level==2 else 0.0)+(0.28 if reduced else 0.50)*clampf(hit_left/0.55,0,1)
	if strength<=0: return
	for corner in [Vector2(5,5),Vector2(955,5),Vector2(5,535),Vector2(955,535)]:
		var direction:=Vector2(1 if corner.x<480 else -1,1 if corner.y<270 else -1)
		draw_line(corner,corner+Vector2(direction.x*65,0),Color(tint,strength),3 if reduced else 5,true)
		draw_line(corner,corner+Vector2(0,direction.y*65),Color(tint,strength),3 if reduced else 5,true)
	if not reduced and hit_left>0:
		for i in range(8):
			var alpha:=strength*(1-i/8.0)*0.16
			draw_rect(Rect2(i*3,i*3,960-i*6,540-i*6),Color(tint,alpha),false,3)
