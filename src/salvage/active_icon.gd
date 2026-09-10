extends Control
var active := false
var reduced := false
var angle := 0.0

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	visible=active
	if active:
		if not reduced: angle=fposmod(angle+delta*2.8,TAU)
		queue_redraw()

func _draw() -> void:
	if not active: return
	var center:=size/2
	var radius:=size.x*0.43
	draw_arc(center,radius,0,TAU,40,Color(0.6,0.9,0.82,0.25),1.0,true)
	for i in range(2):
		var start: float=(0.0 if reduced else angle)+i*PI
		draw_arc(center,radius,start,start+1.5,15,Color(0.74,0.97,0.86,0.85),2.0,true)
