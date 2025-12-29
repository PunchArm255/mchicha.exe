extends StaticBody2D
class_name FallingPlatform

## A platform that falls when the player touches it

signal fallen

@export var fall_delay: float = 0.1  # Time before falling after triggered
@export var fall_speed: float = 1500.0  # How fast it falls

var is_triggered: bool = false
var is_falling: bool = false
var original_position: Vector2


func _ready() -> void:
	original_position = position
	# Connect the body entered signal from Area2D child
	if has_node("TriggerArea"):
		$TriggerArea.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if is_falling:
		position.y += fall_speed * delta
		# Remove when off screen
		if position.y > 800:
			hide()


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_triggered:
		is_triggered = true
		_start_fall_sequence()


func _start_fall_sequence() -> void:
	# Brief shake before falling
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x + 3, 0.05)
	tween.tween_property(self, "position:x", position.x - 3, 0.05)
	tween.tween_property(self, "position:x", position.x + 2, 0.05)
	tween.tween_property(self, "position:x", position.x, 0.05)
	
	await get_tree().create_timer(fall_delay).timeout
	
	is_falling = true
	# Disable collision so player falls through if still on it
	set_collision_layer_value(1, false)
	emit_signal("fallen")


func reset() -> void:
	is_triggered = false
	is_falling = false
	position = original_position
	set_collision_layer_value(1, true)
	show()
