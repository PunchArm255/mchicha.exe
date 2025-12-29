extends Area2D
class_name TeleportingDoor

## A door that teleports to the opposite side when player gets close

signal teleported

@export var teleport_distance: float = 100.0  # How close player needs to be
@export var teleport_to_position: Vector2 = Vector2(100, 500)  # Where to teleport

var has_teleported: bool = false
var original_position: Vector2

@onready var sprite: Sprite2D = $DoorSprite


func _ready() -> void:
	original_position = position


func _physics_process(_delta: float) -> void:
	if has_teleported:
		return
	
	# Check for player proximity
	var player = _find_player()
	if player:
		var distance = position.distance_to(player.position)
		if distance < teleport_distance:
			_teleport()


func _find_player() -> Player:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as Player
	
	# Fallback: search in parent
	var parent = get_parent()
	if parent:
		for child in parent.get_children():
			if child is Player:
				return child
	return null


func _teleport() -> void:
	has_teleported = true
	
	# Quick flash effect
	modulate.a = 0
	position = teleport_to_position
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	
	# Emit signal AFTER teleporting so level can respond
	teleported.emit()


func reset() -> void:
	has_teleported = false
	position = original_position
	modulate.a = 1.0
