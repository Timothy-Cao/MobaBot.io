class_name StarCollectible
extends Area2D

signal collected(collectible: StarCollectible)

var _elapsed: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_elapsed += delta
	rotation += delta * 1.8
	scale = Vector2.ONE * (1.0 + sin(_elapsed * 4.0) * 0.08)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_deferred("monitoring", false)
		collected.emit(self)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 24.0, Color(1.0, 0.76, 0.16, 0.12))
	var points := PackedVector2Array()
	for index in range(10):
		var radius := 17.0 if index % 2 == 0 else 7.5
		var angle := -PI / 2.0 + index * PI / 5.0
		points.append(Vector2.from_angle(angle) * radius)
	draw_colored_polygon(points, Color("ffd85c"))
	points.append(points[0])
	draw_polyline(points, Color("fff4bf"), 2.0, true)
