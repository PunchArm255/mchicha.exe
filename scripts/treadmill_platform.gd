extends AnimatableBody2D
class_name TreadmillPlatform

## A platform that pushes the player in a direction when they're standing on it
## Uses AnimatableBody2D so it can move/push the player

@export var push_direction: Vector2 = Vector2.LEFT
@export var push_speed: float = 150.0

var player_on_platform: Player = null

@onready var trigger_area: Area2D = $TriggerArea


func _ready() -> void:
	if trigger_area:
		trigger_area.body_entered.connect(_on_body_entered)
		trigger_area.body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	if player_on_platform and is_instance_valid(player_on_platform):
		# Push the player in the specified direction
		player_on_platform.velocity.x += push_direction.x * push_speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_on_platform = body


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_on_platform = null


func reset() -> void:
	player_on_platform = null
