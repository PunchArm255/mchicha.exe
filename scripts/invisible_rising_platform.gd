extends StaticBody2D
class_name InvisibleRisingPlatform

## An invisible platform that:
## 1. Becomes visible when player lands on TOP of it
## 2. Starts rising to crush player against ceiling
## 3. Resets when player dies
## 4. Can be re-activated for second phase

signal player_landed
signal crushing_started

@export var rise_speed: float = 200.0
@export var rise_delay: float = 0.3  # Delay before rising after landing

var is_visible_now: bool = false
var is_rising: bool = false
var original_position: Vector2
var player_on_platform: Player = null
var activation_count: int = 0  # Track how many times activated

@onready var sprite: Sprite2D = $Sprite
@onready var trigger_area: Area2D = $TopTriggerArea


func _ready() -> void:
	original_position = position
	# Start invisible
	sprite.modulate.a = 0.0
	
	# Connect top trigger (for landing on top)
	trigger_area.body_entered.connect(_on_top_entered)
	trigger_area.body_exited.connect(_on_top_exited)


func _physics_process(delta: float) -> void:
	if is_rising:
		position.y -= rise_speed * delta


func _on_top_entered(body: Node2D) -> void:
	if body is Player and not is_visible_now:
		# Player landed on TOP - reveal and start rising
		player_on_platform = body
		is_visible_now = true
		sprite.modulate.a = 1.0
		activation_count += 1
		emit_signal("player_landed")
		
		# Start rising after delay
		await get_tree().create_timer(rise_delay).timeout
		is_rising = true
		emit_signal("crushing_started")


func _on_top_exited(body: Node2D) -> void:
	if body is Player:
		player_on_platform = null


## Reset for second phase (keeps activation tracking)
func reset_for_second_phase() -> void:
	is_visible_now = false
	is_rising = false
	position = original_position
	sprite.modulate.a = 0.0
	player_on_platform = null


## Full reset (for death/retry)
func reset() -> void:
	reset_for_second_phase()
	activation_count = 0
