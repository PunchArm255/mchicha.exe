extends Node

# This file was causing parse errors because DiscordRPC class wasn't loading.
# The functionality has been moved to scripts/autoloads/discord_manager.gd
# which handles the integration safely.

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
