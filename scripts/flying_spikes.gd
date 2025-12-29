extends Area2D
class_name FlyingSpikes

## A single spike that launches upward when player enters the trigger zone
## Has a separate kill zone on the spike sprite itself

signal launched

@export var launch_speed: float = 600.0

var is_launched: bool = false
var original_position: Vector2

@onready var spike_hitbox: Area2D = $SpikeHitbox


func _ready() -> void:
	original_position = position
	
	# Main Area2D is the TRIGGER zone (tall box for detecting player jumping over)
	body_entered.connect(_on_trigger_entered)
	
	# Spike hitbox is the KILL zone (small box on the spike itself)
	if spike_hitbox:
		spike_hitbox.body_entered.connect(_on_spike_hit)


func _physics_process(delta: float) -> void:
	if is_launched:
		# Move upward
		position.y -= launch_speed * delta
		
		# Stop when off screen
		if position.y < -100:
			hide()


func _on_trigger_entered(body: Node2D) -> void:
	# Player entered the tall trigger zone - launch the spike!
	if body is Player and not is_launched:
		_launch()


func _on_spike_hit(body: Node2D) -> void:
	# Player touched the actual spike - kill them!
	if body is Player:
		body.die()


func _launch() -> void:
	if is_launched:
		return
	is_launched = true
	launched.emit()


func reset() -> void:
	is_launched = false
	position = original_position
	show()
