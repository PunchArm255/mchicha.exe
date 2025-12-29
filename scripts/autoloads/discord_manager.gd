extends Node

## Discord RPC Manager - Updates Discord presence based on game state
## Uses dynamic access to avoid parse errors when DiscordRPC addon isn't loaded

const APP_ID: int = 1452821934722125834

var start_time: int = 0
var discord_rpc = null  # Will hold reference to DiscordRPC singleton


func _ready() -> void:
	start_time = int(Time.get_unix_time_from_system())
	
	# Try to get DiscordRPC singleton dynamically
	if Engine.has_singleton("DiscordRPC"):
		print("DiscordRPC: Linked via Engine.get_singleton")
		discord_rpc = Engine.get_singleton("DiscordRPC")
	else:
		# Try to access as global class
		var rpc_class = ClassDB.class_exists("DiscordRPC")
		if rpc_class:
			print("DiscordRPC: Linked via ClassDB")
			discord_rpc = ClassDB.instantiate("DiscordRPC")
	
	if discord_rpc == null:
		push_warning("DiscordRPC not available - Discord integration disabled")
		print("DiscordRPC: Failed to load singleton. Make sure the addon is enabled and 'libdiscord_game_sdk' is in bin/")
		return
	
	print("DiscordRPC: Successfully loaded!")
	
	# Initialize Discord RPC
	discord_rpc.app_id = APP_ID
	discord_rpc.details = "On Desktop"
	discord_rpc.state = "Browsing"
	discord_rpc.large_image = "icon"
	discord_rpc.large_image_text = "mchicha.exe"
	discord_rpc.start_timestamp = start_time
	
	discord_rpc.refresh()
	
	# Connect to GameManager signals
	GameManager.level_started.connect(_on_level_started)
	GameManager.player_died.connect(_on_player_died)
	GameManager.level_completed.connect(_on_level_completed)
	GameManager.game_reset.connect(_on_game_reset)


func update_presence(details: String, state: String = "") -> void:
	if discord_rpc == null:
		return
	discord_rpc.details = details
	discord_rpc.state = state
	discord_rpc.refresh()


func set_desktop() -> void:
	update_presence("On Desktop", "Browsing")


func set_title_screen() -> void:
	update_presence("On Title Screen", "Ready to play")


func set_playing_level(level_num: int, level_name: String = "") -> void:
	var display_name = level_name if level_name else "Stage %d" % level_num
	update_presence("Playing %s" % display_name, "Deaths: %d" % GameManager.death_count)


func set_3d_room() -> void:
	update_presence("In the room", "Escaped the game")


func _on_level_started(level_number: int) -> void:
	set_playing_level(level_number)


func _on_player_died(death_count: int) -> void:
	if discord_rpc == null:
		return
	discord_rpc.state = "Deaths: %d" % death_count
	discord_rpc.refresh()


func _on_level_completed(level_number: int) -> void:
	if discord_rpc == null:
		return
	discord_rpc.state = "Completed Stage %d!" % level_number
	discord_rpc.refresh()


func _on_game_reset() -> void:
	set_title_screen()


func _process(_delta: float) -> void:
	if discord_rpc:
		discord_rpc.run_callbacks()
