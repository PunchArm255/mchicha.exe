extends Node

## Controls visual glitch effects based on GameManager.glitch_intensity
## Updates shader parameters dynamically

# Shader parameters at different intensities
const GLITCH_PRESETS = {
	"clean": {
		"chromatic_aberration": 0.001,
		"scanline_count": 120.0,
		"distortion": 10.0,
		"static_intensity": 0.0
	},
	"moderate": {
		"chromatic_aberration": 0.004,
		"scanline_count": 200.0,
		"distortion": 6.0,
		"static_intensity": 0.1
	},
	"heavy": {
		"chromatic_aberration": 0.008,
		"scanline_count": 300.0,
		"distortion": 4.0,
		"static_intensity": 0.3
	},
	"corrupted": {
		"chromatic_aberration": 0.015,
		"scanline_count": 500.0,
		"distortion": 2.5,
		"static_intensity": 0.6
	}
}

var vhs_shader_material: ShaderMaterial = null
var screen_shake_enabled: bool = false
var shake_intensity: float = 0.0

# Reference to the game container for shake effects
var game_container: Control = null


func _ready() -> void:
	print("[GlitchManager] Initialized")


func register_shader(material: ShaderMaterial) -> void:
	vhs_shader_material = material
	update_glitch_effects()


func register_game_container(container: Control) -> void:
	game_container = container


func update_glitch_effects() -> void:
	if not vhs_shader_material:
		return
	
	var intensity = GameManager.glitch_intensity
	var preset: Dictionary
	
	# Select preset based on intensity
	if intensity < 0.25:
		preset = GLITCH_PRESETS["clean"]
	elif intensity < 0.5:
		preset = _lerp_presets(GLITCH_PRESETS["clean"], GLITCH_PRESETS["moderate"], (intensity - 0.25) / 0.25)
	elif intensity < 0.75:
		preset = _lerp_presets(GLITCH_PRESETS["moderate"], GLITCH_PRESETS["heavy"], (intensity - 0.5) / 0.25)
	else:
		preset = _lerp_presets(GLITCH_PRESETS["heavy"], GLITCH_PRESETS["corrupted"], (intensity - 0.75) / 0.25)
	
	# Apply to shader
	vhs_shader_material.set_shader_parameter("chromatic_aberration", preset["chromatic_aberration"])
	vhs_shader_material.set_shader_parameter("scanline_count", preset["scanline_count"])
	vhs_shader_material.set_shader_parameter("distortion", preset["distortion"])
	vhs_shader_material.set_shader_parameter("static_intensity", preset["static_intensity"])
	
	# Enable screen shake at higher intensities
	screen_shake_enabled = intensity > 0.6
	shake_intensity = clamp((intensity - 0.6) * 5.0, 0.0, 2.0)


func _lerp_presets(a: Dictionary, b: Dictionary, t: float) -> Dictionary:
	var result = {}
	for key in a.keys():
		result[key] = lerp(a[key], b[key], t)
	return result


func _process(delta: float) -> void:
	if screen_shake_enabled and game_container:
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		game_container.position = shake_offset


## Trigger a death glitch burst
func trigger_death_glitch() -> void:
	if not vhs_shader_material:
		return
	
	var intensity = GameManager.glitch_intensity
	
	# Temporary intense glitch on death
	if intensity > 0.3:
		var original_chroma = vhs_shader_material.get_shader_parameter("chromatic_aberration")
		vhs_shader_material.set_shader_parameter("chromatic_aberration", 0.02)
		vhs_shader_material.set_shader_parameter("static_intensity", 0.8)
		
		# Reset after brief moment
		await get_tree().create_timer(0.3).timeout
		update_glitch_effects()


## Called when transitioning between levels
func on_level_change() -> void:
	update_glitch_effects()
