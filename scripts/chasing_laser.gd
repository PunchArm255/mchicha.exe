extends Area2D
class_name ChasingLaser

## A vertical laser bar that chases the player horizontally
## Hidden until player moves, kills on contact
## Pauses at door trigger, then chases from RIGHT side after teleport

signal reached_door_area

@export var chase_speed: float = 120.0
@export var door_trigger_x: float = 600.0  # X position where laser pauses
@export var start_delay: float = 1.0  # Delay after player moves before chasing

var is_chasing: bool = false
var is_paused: bool = false
var has_started: bool = false
var original_position: Vector2
var phase: int = 1  # 1 = chase left-to-right, 2 = chase right-to-left
var player_has_moved: bool = false
var initial_player_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	original_position = position
	body_entered.connect(_on_body_entered)
	
	# Hide initially - don't show until player moves
	hide()
	monitoring = false


func _physics_process(delta: float) -> void:
	var player = _find_player()
	if not player:
		return
	
	# Track initial player position
	if initial_player_pos == Vector2.ZERO:
		initial_player_pos = player.position
	
	# Check if player has started moving
	if not player_has_moved:
		if player.position.distance_to(initial_player_pos) > 10:
			player_has_moved = true
			_start_chase()
		return
	
	if not is_chasing or is_paused:
		return
	
	# ACTIVELY check for player collision every frame (fixes standing still issue)
	if monitoring:
		_check_player_collision(player)
	
	# Chase based on phase - ALWAYS move toward player, don't stop early!
	if phase == 1:
		# Phase 1: Chase left to right - keep moving until door trigger
		position.x += chase_speed * delta
		
		# Check if we've reached the door trigger area
		if position.x >= door_trigger_x:
			_pause_at_door()
	else:
		# Phase 2: Chase right to left - keep moving 
		position.x -= chase_speed * delta


func _check_player_collision(player: Player) -> void:
	# Get overlapping bodies and check if player is among them
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


func _start_chase() -> void:
	if has_started:
		return
	has_started = true
	
	# Show and enable after delay
	await get_tree().create_timer(start_delay).timeout
	show()
	monitoring = true
	is_chasing = true


func _pause_at_door() -> void:
	is_paused = true
	is_chasing = false
	reached_door_area.emit()
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): monitoring = false; hide())


## Called when door teleports - chase from RIGHT side going LEFT
func resume_chase_phase2() -> void:
	phase = 2
	# Move to RIGHT side of screen
	position = Vector2(830, original_position.y)
	modulate.a = 1.0
	is_paused = false
	is_chasing = true
	monitoring = true
	show()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()


func reset() -> void:
	is_chasing = false
	is_paused = false
	has_started = false
	player_has_moved = false
	initial_player_pos = Vector2.ZERO
	position = original_position
	modulate.a = 1.0
	phase = 1
	hide()
	monitoring = false
