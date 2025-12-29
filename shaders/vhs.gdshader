shader_type canvas_item;

// CRT Effect Shader with edge warp only (no vignette)

uniform float scanline_count : hint_range(0, 1800) = 120.0;
uniform float chromatic_aberration : hint_range(0.0, 0.05) = 0.001;
uniform float distortion : hint_range(1.0, 20.0) = 10.0;
uniform float static_intensity : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Random function for static noise
float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 uv_curve(vec2 uv) {
	uv = (uv - 0.5) * 2.0;
	uv.x *= 1.0 + pow(abs(uv.y) / distortion, 2.0);
	uv.y *= 1.0 + pow(abs(uv.x) / distortion, 2.0);
	uv /= 1.05;
	uv = (uv / 2.0) + 0.5;
	return uv;
}

void fragment() {
	vec2 curved_uv = uv_curve(SCREEN_UV);
	
	// Chromatic aberration - separate RGB channels
	float r = texture(screen_texture, curved_uv + vec2(chromatic_aberration, 0.0)).r;
	float g = texture(screen_texture, curved_uv).g;
	float b = texture(screen_texture, curved_uv + vec2(-chromatic_aberration, 0.0)).b;
	
	// Scanlines
	float scanline = sin(curved_uv.y * scanline_count * PI * 2.0);
	scanline = (scanline * 0.5 + 0.5) * 0.9 + 0.1;
	vec4 scan_line_color = vec4(vec3(pow(scanline, 0.25)), 1.0);
	
	// Static noise overlay
	float noise = random(curved_uv + vec2(TIME * 0.1, TIME * 0.2));
	vec3 static_color = vec3(noise) * static_intensity;
	
	// Combine all effects (NO vignette - removed)
	vec3 final_color = vec3(r, g, b);
	final_color = mix(final_color, static_color, static_intensity * 0.5);
	
	COLOR = vec4(final_color, 1.0) * scan_line_color;
}
