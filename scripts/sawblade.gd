extends Area2D
class_name Sawblade

## A sawblade that moves toward the player
## Kills on contact

@export var speed: float = 400.0
@export var start_delay: float = 0.5

var is_moving: bool = false
var move_direction: Vector2 = Vector2.LEFT
var original_position: Vector2
var original_direction: Vector2 = Vector2.LEFT

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	original_position = position
	original_direction = move_direction
	body_entered.connect(_on_body_entered)
	hide()


func _physics_process(delta: float) -> void:
	if is_moving:
		position += move_direction * speed * delta
		# Rotate the sawblade for effect
		sprite.rotation += 10 * delta
		
		# Remove when off screen
		if position.x < -50 or position.x > 850:
			stop()


func start_attack() -> void:
	show()
	await get_tree().create_timer(start_delay).timeout
	is_moving = true


## Start attack from the opposite side
func start_attack_from_opposite() -> void:
	# Move to opposite side of screen
	if original_position.x > 400:
		position = Vector2(20, original_position.y)
		move_direction = Vector2.RIGHT
	else:
		position = Vector2(780, original_position.y)
		move_direction = Vector2.LEFT
	
	show()
	await get_tree().create_timer(start_delay).timeout
	is_moving = true


func stop() -> void:
	is_moving = false
	hide()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()


func reset() -> void:
	is_moving = false
	position = original_position
	move_direction = original_direction
	sprite.rotation = 0
	hide()
