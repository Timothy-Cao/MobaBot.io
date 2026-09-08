extends Node2D

const COLLECTIBLE_SCENE: PackedScene = preload("res://src/collectible/collectible.tscn")
const HAZARD_SCENE: PackedScene = preload("res://src/hazard/hazard.tscn")
const TARGET_SCORE: int = 10
const STARTING_LIVES: int = 3
const ROUND_SECONDS: float = 45.0
const MAX_HAZARDS: int = 6

@onready var player: PlayerShip = %Player
@onready var spawned_objects: Node2D = %SpawnedObjects
@onready var hud: GameHud = %Hud

var score: int = 0
var lives: int = STARTING_LIVES
var seconds_left: float = ROUND_SECONDS
var is_round_running: bool = false
var _random := RandomNumberGenerator.new()


func _ready() -> void:
	_random.randomize()
	_start_round()
	queue_redraw()


func _process(delta: float) -> void:
	if is_round_running:
		seconds_left = maxf(seconds_left - delta, 0.0)
		hud.set_stats(score, TARGET_SCORE, lives, ceili(seconds_left))
		if seconds_left <= 0.0:
			_finish_round(false, "TIME RAN OUT")
	elif Input.is_action_just_pressed("restart"):
		_start_round()


func _start_round() -> void:
	for child in spawned_objects.get_children():
		child.free()

	score = 0
	lives = STARTING_LIVES
	seconds_left = ROUND_SECONDS
	is_round_running = true
	player.reset_player(get_viewport_rect().size * Vector2(0.5, 0.62))
	hud.set_stats(score, TARGET_SCORE, lives, ceili(seconds_left))
	hud.show_running()
	_spawn_collectible()
	_spawn_hazard()
	_spawn_hazard()


func _spawn_collectible() -> void:
	var collectible := COLLECTIBLE_SCENE.instantiate() as StarCollectible
	collectible.position = _random_play_position(36.0, 150.0)
	collectible.collected.connect(_on_collectible_collected)
	spawned_objects.add_child(collectible)


func _spawn_hazard() -> void:
	if get_tree().get_nodes_in_group("hazards").size() >= MAX_HAZARDS:
		return
	var hazard := HAZARD_SCENE.instantiate() as HazardDrone
	var angle := _random.randf_range(0.0, TAU)
	var speed := _random.randf_range(115.0, 185.0) + score * 3.0
	hazard.setup(_random_play_position(42.0, 210.0), Vector2.from_angle(angle) * speed)
	hazard.player_hit.connect(_on_player_hit)
	spawned_objects.add_child(hazard)


func _random_play_position(margin: float, player_clearance: float) -> Vector2:
	var viewport_size := get_viewport_rect().size
	for attempt in range(16):
		var candidate := Vector2(
			_random.randf_range(margin, viewport_size.x - margin),
			_random.randf_range(88.0 + margin, viewport_size.y - 52.0)
		)
		if candidate.distance_to(player.position) >= player_clearance:
			return candidate
	return Vector2(viewport_size.x - margin * 2.0, viewport_size.y - margin * 2.0)


func _on_collectible_collected(collectible: StarCollectible) -> void:
	if not is_round_running:
		return
	collectible.queue_free()
	score += 1
	if score >= TARGET_SCORE:
		_finish_round(true, "ALL STARS SECURED")
		return
	if score % 3 == 0:
		_spawn_hazard()
	_spawn_collectible()


func _on_player_hit() -> void:
	if not is_round_running or not player.take_hit():
		return
	lives -= 1
	hud.set_stats(score, TARGET_SCORE, lives, ceili(seconds_left))
	if lives <= 0:
		_finish_round(false, "SHIELDS DEPLETED")


func _finish_round(did_win: bool, reason: String) -> void:
	is_round_running = false
	player.set_input_enabled(false)
	var title := "MISSION COMPLETE" if did_win else "MISSION FAILED"
	var detail := "%s\nPress Enter or Space to play again" % reason
	hud.show_result(title, detail)


func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color("050919"))
	for x in range(0, int(viewport_size.x) + 1, 48):
		draw_line(Vector2(x, 68), Vector2(x, viewport_size.y), Color(0.08, 0.24, 0.36, 0.34), 1.0)
	for y in range(68, int(viewport_size.y) + 1, 48):
		draw_line(Vector2(0, y), Vector2(viewport_size.x, y), Color(0.08, 0.24, 0.36, 0.34), 1.0)
	draw_circle(viewport_size * Vector2(0.16, 0.28), 130.0, Color(0.02, 0.34, 0.48, 0.06))
	draw_circle(viewport_size * Vector2(0.82, 0.76), 170.0, Color(0.30, 0.04, 0.32, 0.06))
