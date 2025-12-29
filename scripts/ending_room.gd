extends Node3D

## 3D Ending room - player wakes up in a simple room after "exiting" the game

@onready var player: CharacterBody3D = $Player
@onready var computer_screen: MeshInstance3D = $ComputerScreen
@onready var interact_label: Label3D = $InteractLabel

const MOUSE_SENSITIVITY: float = 0.002
const MOVE_SPEED: float = 5.0
const GRAVITY: float = 20.0

var camera_rotation: Vector2 = Vector2.ZERO
var near_computer: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	interact_label.hide()
	
	# Update Discord presence
	DiscordManager.set_3d_room()
	
	# Start with zoom-out effect from computer screen
	_play_zoom_out()


func _play_zoom_out() -> void:
	# Start camera close to computer screen and zoom out
	var camera = $Player/Camera3D
	camera.fov = 20
	
	var tween = create_tween()
	tween.tween_property(camera, "fov", 70.0, 2.0)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_rotation.x -= event.relative.y * MOUSE_SENSITIVITY
		camera_rotation.y -= event.relative.x * MOUSE_SENSITIVITY
		camera_rotation.x = clamp(camera_rotation.x, -1.5, 1.5)
		
		player.rotation.y = camera_rotation.y
		$Player/Camera3D.rotation.x = camera_rotation.x
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not player.is_on_floor():
		player.velocity.y -= GRAVITY * delta
	
	# Movement - WASD and arrow keys
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	
	input_dir = input_dir.normalized()
	
	var direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = direction.x * MOVE_SPEED
		player.velocity.z = direction.z * MOVE_SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, MOVE_SPEED)
		player.velocity.z = move_toward(player.velocity.z, 0, MOVE_SPEED)
	
	player.move_and_slide()
	
	# Check distance to computer for interaction
	var dist_to_computer = player.global_position.distance_to(computer_screen.global_position)
	near_computer = dist_to_computer < 3.0
	
	if near_computer:
		interact_label.show()
		if Input.is_key_pressed(KEY_E):
			_return_to_game()
	else:
		interact_label.hide()


func _return_to_game() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Mark game as beaten so Powerplay unlocks
	GameManager.game_beaten = true
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/desktop.tscn")
