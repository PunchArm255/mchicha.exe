extends CanvasLayer
class_name LevelTimer

## HUD Timer that counts down from a set time
## When it reaches 0, the player dies
## Timer doesn't start until player moves

signal time_up

@export var start_time: float = 10.0

var time_remaining: float = 0.0
var is_running: bool = false
var is_waiting_for_movement: bool = false
var player_initial_pos: Vector2 = Vector2.ZERO
var tracked_player: Player = null

@onready var label: Label = $TimerLabel


func _ready() -> void:
	time_remaining = start_time
	_update_display()
	hide()


func _process(delta: float) -> void:
	# Check for player movement to start timer
	if is_waiting_for_movement and tracked_player and is_instance_valid(tracked_player):
		if tracked_player.position.distance_to(player_initial_pos) > 5:
			is_waiting_for_movement = false
			is_running = true
	
	if not is_running:
		return
	
	time_remaining -= delta
	_update_display()
	
	# Color changes as time runs out
	if time_remaining <= 3.0:
		label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))  # Red
	elif time_remaining <= 5.0:
		label.add_theme_color_override("font_color", Color(1, 0.6, 0.2))  # Orange
	
	if time_remaining <= 0:
		time_remaining = 0
		is_running = false
		_update_display()
		time_up.emit()


func _update_display() -> void:
	# Show as X.X format
	label.text = "%.1f" % max(0, time_remaining)


## Call this when level starts - timer shows but waits for player movement
func prepare_timer(player: Player) -> void:
	time_remaining = start_time
	is_running = false
	is_waiting_for_movement = true
	tracked_player = player
	if player:
		player_initial_pos = player.position
	label.remove_theme_color_override("font_color")
	_update_display()
	show()


func start_timer() -> void:
	time_remaining = start_time
	is_running = true
	is_waiting_for_movement = false
	label.remove_theme_color_override("font_color")
	show()


func stop_timer() -> void:
	is_running = false
	is_waiting_for_movement = false


func pause_timer() -> void:
	is_running = false


func resume_timer() -> void:
	is_running = true


func reset_timer() -> void:
	time_remaining = start_time
	is_running = false
	is_waiting_for_movement = false
	tracked_player = null
	label.remove_theme_color_override("font_color")
	_update_display()
