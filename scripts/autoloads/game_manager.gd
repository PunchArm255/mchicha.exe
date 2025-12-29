extends Node

## Global game state manager
## Tracks level progression, deaths, and glitch intensity

signal level_started(level_number: int)
signal player_died(death_count: int)
signal level_completed(level_number: int)
signal game_reset()

# Current game state
var current_level: int = 1
var death_count: int = 0
var total_deaths: int = 0  # Never resets, used for glitch intensity
var game_beaten: bool = false  # Tracks if player beat the game (unlocks Powerplay)

# Level configuration
var level_scenes: Array[String] = [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn",
	"res://scenes/levels/level_4.tscn",
	"res://scenes/levels/level_5.tscn",
]

# Glitch intensity increases with deaths and level progression
var glitch_intensity: float:
	get:
		# Base intensity from level (0.0 to 0.5)
		var level_factor = clamp((current_level - 1) * 0.1, 0.0, 0.5)
		# Death factor (0.0 to 0.5)
		var death_factor = clamp(total_deaths * 0.02, 0.0, 0.5)
		return clamp(level_factor + death_factor, 0.0, 1.0)

# Death screen style based on glitch intensity
enum DeathStyle { CLEAN, GLITCHY, CORRUPTED }
var death_style: DeathStyle:
	get:
		if glitch_intensity < 0.3:
			return DeathStyle.CLEAN
		elif glitch_intensity < 0.6:
			return DeathStyle.GLITCHY
		else:
			return DeathStyle.CORRUPTED


func _ready() -> void:
	print("[GameManager] Initialized")


func start_game() -> void:
	current_level = 1
	death_count = 0
	emit_signal("level_started", current_level)


func on_player_death() -> void:
	death_count += 1
	total_deaths += 1
	emit_signal("player_died", death_count)
	print("[GameManager] Player died. Deaths this level: %d, Total: %d, Glitch: %.2f" % [death_count, total_deaths, glitch_intensity])


func complete_level() -> void:
	emit_signal("level_completed", current_level)
	print("[GameManager] Level %d completed!" % current_level)


func advance_to_next_level() -> void:
	current_level += 1
	death_count = 0
	if current_level <= level_scenes.size():
		emit_signal("level_started", current_level)
	else:
		# Game completed - could trigger ending sequence
		print("[GameManager] All levels completed!")


func get_current_level_scene() -> String:
	var index = current_level - 1
	if index >= 0 and index < level_scenes.size():
		return level_scenes[index]
	return ""


func reset_game() -> void:
	current_level = 1
	death_count = 0
	total_deaths = 0
	emit_signal("game_reset")
