extends Area2D
class_name ChasingSun

## A giant sun that swings in and out attacking the player
## Moves in a sweeping pattern across the screen

@export var attack_speed: float = 300.0
@export var start_delay: float = 2.0
@export var swing_height: float = 150.0  # How high it swings

var is_attacking: bool = false
var has_started: bool = false
var player_has_moved: bool = false
var player_initial_pos: Vector2 = Vector2.ZERO
var original_position: Vector2
var attack_direction: float = -1.0  # -1 = left, 1 = right
var swing_time: float = 0.0


func _ready() -> void:
	original_position = position
	body_entered.connect(_on_body_entered)
	
	# Start off-screen to the right
	position.x = 900
	hide()
	monitoring = false


func _physics_process(delta: float) -> void:
	var player = _find_player()
	if not player:
		return
	
	# Track initial player position
	if player_initial_pos == Vector2.ZERO:
		player_initial_pos = player.position
	
	# Check if player has started moving
	if not player_has_moved:
		if player.position.distance_to(player_initial_pos) > 10:
			player_has_moved = true
			_start_attack()
		return
	
	if not is_attacking:
		return
	
	# Actively check for collision
	_check_player_collision(player)
	
	# Swing attack pattern - sweep across screen with vertical oscillation
	swing_time += delta * 3.0
	position.x += attack_direction * attack_speed * delta
	position.y = original_position.y + sin(swing_time * 2.0) * swing_height
	
	# When sun goes off screen, come back from the other side
	if position.x < -150:
		attack_direction = 1.0
		position.x = -150
	elif position.x > 950:
		attack_direction = -1.0
		position.x = 950


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


func _start_attack() -> void:
	if has_started:
		return
	has_started = true
	
	await get_tree().create_timer(start_delay).timeout
	show()
	monitoring = true
	is_attacking = true


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()


func reset() -> void:
	is_attacking = false
	has_started = false
	player_has_moved = false
	player_initial_pos = Vector2.ZERO
	position = Vector2(900, original_position.y)  # Reset off-screen right
	attack_direction = -1.0
	swing_time = 0.0
	hide()
	monitoring = false
