shader_type canvas_item;

uniform float pixel_size : hint_range(1.0, 100.0) = 1.0;
uniform float darkness : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D screen_texture: hint_screen_texture;

void fragment() {
	vec2 uv = floor(UV * TEXTURE_PIXEL_SIZE * pixel_size) / (TEXTURE_PIXEL_SIZE * pixel_size);
	vec4 pixelated = texture(screen_texture, uv);
	COLOR = mix(pixelated, vec4(0.0, 0.0, 0.0, 1.0), darkness);
}
