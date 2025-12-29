extends CharacterBody2D
class_name Player

## Player controller with movement, death detection, screen bounds, and SFX

signal died

const SPEED = 300.0
const JUMP_VELOCITY = -550.0
const GRAVITY = 2000.0

# Screen bounds (4:3 at 800x600)
const SCREEN_LEFT = 20.0
const SCREEN_RIGHT = 780.0

var can_move: bool = false
var is_invincible: bool = false  # Prevents death during transitions

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sfx: AudioStreamPlayer2D = $JumpSFX
@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX


func _ready() -> void:
	# Ensure animation exists
	if anim:
		anim.play("idle")


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Check for death by falling
	if position.y > 700:  # Below screen
		die()
		return
	
	if not can_move:
		move_and_slide()
		if anim:
			anim.play("idle")
		return
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_play_jump_sound()
	
	# Handle horizontal movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if anim:
			anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	update_animation(direction)
	move_and_slide()
	
	# Clamp position to screen bounds (invisible walls)
	position.x = clamp(position.x, SCREEN_LEFT, SCREEN_RIGHT)


func update_animation(direction: float) -> void:
	if not anim:
		return
	
	if not is_on_floor():
		anim.play("jump")
	elif direction != 0:
		anim.play("walk")
	else:
		anim.play("idle")


func _play_jump_sound() -> void:
	if jump_sfx:
		jump_sfx.play()


func _play_death_sound() -> void:
	if death_sfx:
		death_sfx.play()


func die() -> void:
	if is_invincible:
		return  # Can't die during transitions
	can_move = false
	_play_death_sound()
	emit_signal("died")


func reset_at_position(pos: Vector2) -> void:
	position = pos
	velocity = Vector2.ZERO
	can_move = true
