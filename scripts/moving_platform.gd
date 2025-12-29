extends AnimatableBody2D
class_name MovingPlatform

## A platform that moves up and down continuously

@export var move_distance: float = 100.0  # Total distance to move
@export var move_speed: float = 80.0  # Speed of movement
@export var start_delay: float = 0.0  # Delay before starting movement

var original_position: Vector2
var direction: float = -1.0  # -1 = up, 1 = down
var is_moving: bool = false


func _ready() -> void:
	original_position = position
	
	if start_delay > 0:
		await get_tree().create_timer(start_delay).timeout
	is_moving = true


func _physics_process(delta: float) -> void:
	if not is_moving:
		return
	
	# Move in current direction
	position.y += direction * move_speed * delta
	
	# Check bounds and reverse
	if position.y <= original_position.y - move_distance:
		direction = 1.0  # Start moving down
	elif position.y >= original_position.y:
		direction = -1.0  # Start moving up


func reset() -> void:
	position = original_position
	direction = -1.0
	is_moving = true
