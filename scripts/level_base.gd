extends Node2D
class_name LevelBase

## Base class for all levels
## Handles player spawning, door completion, death, and trap resets

signal level_completed
signal player_died

@export var level_name: String = "STAGE"
@export var level_number: int = 1

# Node references - set in inherited scenes
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var door: Area2D = $Door
@onready var player: Player = $Player

var player_start_position: Vector2
var falling_platforms: Array = []
var rising_platforms: Array = []
var moving_platforms: Array = []
var sawblades: Array = []
var teleporting_doors: Array = []
var flying_spikes: Array = []
var chasing_lasers: Array = []
var horizontal_platforms: Array = []
var closing_lasers: Array = []
var chasing_suns: Array = []


func _ready() -> void:
	# Store spawn position
	if spawn_point:
		player_start_position = spawn_point.position
	elif player:
		player_start_position = player.position
	
	# Connect door signal (check if it's a teleporting door or regular door)
	if door:
		door.body_entered.connect(_on_door_entered)
		# If it's a teleporting door, connect the teleported signal
		if door is TeleportingDoor:
			door.teleported.connect(_on_door_teleported)
	
	# Connect player death signal
	if player:
		player.died.connect(_on_player_died)
		# Add player to group for easy finding
		player.add_to_group("player")
	
	# Initially disable player movement
	if player:
		player.can_move = false
	
	# Find all special objects
	_find_special_objects(self)


func _find_special_objects(node: Node) -> void:
	for child in node.get_children():
		if child is FallingPlatform:
			falling_platforms.append(child)
		elif child is InvisibleRisingPlatform:
			rising_platforms.append(child)
			child.player_landed.connect(_on_invisible_platform_landed)
		elif child is MovingPlatform:
			moving_platforms.append(child)
		elif child is Sawblade:
			sawblades.append(child)
		elif child is TeleportingDoor:
			teleporting_doors.append(child)
		elif child is FlyingSpikes:
			flying_spikes.append(child)
		elif child is ChasingLaser:
			chasing_lasers.append(child)
		elif child is HorizontalMovingPlatform:
			horizontal_platforms.append(child)
		elif child is ClosingLaser:
			closing_lasers.append(child)
		elif child is ChasingSun:
			chasing_suns.append(child)
		_find_special_objects(child)


func _on_invisible_platform_landed() -> void:
	# When player lands on invisible platform, trigger sawblades
	for sawblade in sawblades:
		sawblade.start_attack()


## Called when a teleporting door teleports - triggers second phase
func _on_door_teleported() -> void:
	# Reset the invisible platform for second phase
	for platform in rising_platforms:
		if platform and is_instance_valid(platform):
			platform.reset_for_second_phase()
	
	# Reset sawblades so they can attack again from opposite side
	for sawblade in sawblades:
		if sawblade and is_instance_valid(sawblade):
			sawblade.reset()
	
	# NOTE: Flying spikes are NOT reset after door teleport - they stay gone
	
	# Resume chasing lasers from opposite side
	for laser in chasing_lasers:
		if laser and is_instance_valid(laser):
			laser.resume_chase_phase2()
	
	# Reconnect platform landing to trigger sawblade from opposite side
	for platform in rising_platforms:
		if platform and is_instance_valid(platform):
			if platform.player_landed.is_connected(_on_invisible_platform_landed):
				platform.player_landed.disconnect(_on_invisible_platform_landed)
			platform.player_landed.connect(_on_invisible_platform_landed_phase2)


func _on_invisible_platform_landed_phase2() -> void:
	# Second phase - sawblade comes from opposite side
	for sawblade in sawblades:
		sawblade.start_attack_from_opposite()


func start_level() -> void:
	if player:
		player.can_move = true


func _on_door_entered(body: Node2D) -> void:
	if body is Player:
		player.can_move = false
		player.is_invincible = true  # Prevent death during transition
		emit_signal("level_completed")
		GameManager.complete_level()


func _on_player_died() -> void:
	emit_signal("player_died")
	GameManager.on_player_death()


func respawn_player() -> void:
	if player:
		player.reset_at_position(player_start_position)


func reset_platforms() -> void:
	# Reset falling platforms
	for platform in falling_platforms:
		if platform and is_instance_valid(platform):
			platform.reset()
	
	# Reset rising platforms
	for platform in rising_platforms:
		if platform and is_instance_valid(platform):
			platform.reset()
			# Re-establish phase 1 connections
			if platform.player_landed.is_connected(_on_invisible_platform_landed_phase2):
				platform.player_landed.disconnect(_on_invisible_platform_landed_phase2)
			if not platform.player_landed.is_connected(_on_invisible_platform_landed):
				platform.player_landed.connect(_on_invisible_platform_landed)
	
	# Reset moving platforms
	for platform in moving_platforms:
		if platform and is_instance_valid(platform):
			platform.reset()
	
	# Reset sawblades
	for sawblade in sawblades:
		if sawblade and is_instance_valid(sawblade):
			sawblade.reset()
	
	# Reset teleporting doors
	for door_obj in teleporting_doors:
		if door_obj and is_instance_valid(door_obj):
			door_obj.reset()
	
	# Reset flying spikes
	for spikes in flying_spikes:
		if spikes and is_instance_valid(spikes):
			spikes.reset()
	
	# Reset chasing lasers
	for laser in chasing_lasers:
		if laser and is_instance_valid(laser):
			laser.reset()
	
	# Reset horizontal platforms
	for platform in horizontal_platforms:
		if platform and is_instance_valid(platform):
			platform.reset()
	
	# Reset closing lasers
	for laser in closing_lasers:
		if laser and is_instance_valid(laser):
			laser.reset()
	
	# Reset chasing suns
	for sun in chasing_suns:
		if sun and is_instance_valid(sun):
			sun.reset()


func get_display_name() -> String:
	return "%s %d" % [level_name, level_number]
