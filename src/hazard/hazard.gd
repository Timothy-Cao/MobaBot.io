class_name HazardDrone
extends Area2D

signal player_hit

@export var velocity: Vector2 = Vector2(150.0, 110.0)
@export var radius: float = 20.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += velocity * delta
	rotation += delta * 1.7

	var viewport_size := get_viewport_rect().size
	if position.x < radius:
		position.x = radius
		velocity.x = absf(velocity.x)
	elif position.x > viewport_size.x - radius:
		position.x = viewport_size.x - radius
		velocity.x = -absf(velocity.x)

	if position.y < 88.0 + radius:
		position.y = 88.0 + radius
		velocity.y = absf(velocity.y)
	elif position.y > viewport_size.y - radius:
		position.y = viewport_size.y - radius
		velocity.y = -absf(velocity.y)


func setup(start_position: Vector2, start_velocity: Vector2) -> void:
	position = start_position
	velocity = start_velocity


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_hit.emit()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius + 6.0, Color(1.0, 0.18, 0.34, 0.10))
	draw_circle(Vector2.ZERO, radius, Color("ff315d"))
	draw_circle(Vector2.ZERO, radius - 6.0, Color("56152d"))
	for index in range(4):
		var direction := Vector2.from_angle(index * PI / 2.0)
		draw_line(direction * 7.0, direction * 17.0, Color("ff9aaf"), 3.0, true)
	draw_circle(Vector2.ZERO, 4.0, Color("fff1f4"))
