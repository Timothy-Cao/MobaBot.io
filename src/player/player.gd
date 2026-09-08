class_name PlayerShip
extends CharacterBody2D

@export var speed: float = 320.0
@export var edge_padding: float = 24.0

var _input_enabled: bool = true
var _invulnerability_left: float = 0.0


func _physics_process(delta: float) -> void:
	if _invulnerability_left > 0.0:
		_invulnerability_left = maxf(_invulnerability_left - delta, 0.0)
		modulate.a = 0.35 if fmod(_invulnerability_left, 0.16) > 0.08 else 1.0
	else:
		modulate.a = 1.0

	var direction := Vector2.ZERO
	if _input_enabled:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	velocity = direction * speed
	move_and_slide()

	var viewport_size := get_viewport_rect().size
	position.x = clampf(position.x, edge_padding, viewport_size.x - edge_padding)
	position.y = clampf(position.y, 88.0, viewport_size.y - edge_padding)

	if direction.length_squared() > 0.01:
		rotation = lerp_angle(rotation, direction.angle() + PI / 2.0, 0.18)


func reset_player(start_position: Vector2) -> void:
	position = start_position
	velocity = Vector2.ZERO
	rotation = 0.0
	_input_enabled = true
	_invulnerability_left = 0.0
	modulate.a = 1.0


func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO


func take_hit() -> bool:
	if not _input_enabled or _invulnerability_left > 0.0:
		return false
	_invulnerability_left = 1.15
	return true


func _draw() -> void:
	# A small code-drawn ship keeps the starter project asset-free.
	draw_circle(Vector2.ZERO, 23.0, Color(0.05, 0.85, 1.0, 0.12))
	var hull := PackedVector2Array([
		Vector2(0.0, -21.0),
		Vector2(16.0, 17.0),
		Vector2(0.0, 11.0),
		Vector2(-16.0, 17.0),
	])
	draw_colored_polygon(hull, Color("56e7ff"))
	draw_polyline(hull, Color("e7fbff"), 2.0, true)
	draw_circle(Vector2.ZERO, 5.0, Color("092237"))
