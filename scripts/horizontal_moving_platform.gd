extends AnimatableBody2D
class_name HorizontalMovingPlatform

## A platform that moves left and right continuously

@export var move_distance: float = 100.0  # Total distance to move
@export var move_speed: float = 80.0  # Speed of movement
@export var start_direction: float = 1.0  # 1 = right, -1 = left
@export var start_delay: float = 0.0  # Delay before starting movement

var original_position: Vector2
var direction: float = 1.0
var is_moving: bool = false


func _ready() -> void:
	original_position = position
	direction = start_direction
	
	if start_delay > 0:
		await get_tree().create_timer(start_delay).timeout
	is_moving = true


func _physics_process(delta: float) -> void:
	if not is_moving:
		return
	
	# Move in current direction
	position.x += direction * move_speed * delta
	
	# Check bounds and reverse
	if position.x >= original_position.x + move_distance:
		direction = -1.0  # Start moving left
	elif position.x <= original_position.x - move_distance:
		direction = 1.0  # Start moving right


func reset() -> void:
	position = original_position
	direction = start_direction
	is_moving = true
