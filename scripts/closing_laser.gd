extends Area2D
class_name ClosingLaser

## A vertical laser that closes in from the side
## Starts when player moves, kills on contact

@export var close_speed: float = 40.0
@export var from_direction: int = -1  # -1 = from left, 1 = from right

var is_closing: bool = false
var original_position: Vector2
var has_started: bool = false
var player_initial_pos: Vector2 = Vector2.ZERO
var player_has_moved: bool = false


func _ready() -> void:
	original_position = position
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	var player = _find_player()
	if not player:
		return
	
	# Track initial player position
	if player_initial_pos == Vector2.ZERO:
		player_initial_pos = player.position
	
	# Check if player has started moving
	if not player_has_moved:
		if player.position.distance_to(player_initial_pos) > 5:
			player_has_moved = true
			is_closing = true
		return
	
	if not is_closing:
		return
	
	# Actively check for player collision
	_check_player_collision(player)
	
	# Close in from the side
	position.x += from_direction * close_speed * delta


func _check_player_collision(player: Player) -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is Player:
			body.die()
			return


func _find_player() -> Player:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as Player
	return null


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()


func reset() -> void:
	is_closing = false
	player_has_moved = false
	player_initial_pos = Vector2.ZERO
	position = original_position
