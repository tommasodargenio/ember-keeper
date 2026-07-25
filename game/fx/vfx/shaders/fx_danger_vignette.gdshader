shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 vignette_color : source_color = vec4(0.6, 0.05, 0.05, 1.0);
uniform float radius : hint_range(0.0, 1.5) = 0.65;    // distance from center where the vignette starts appearing
uniform float softness : hint_range(0.0, 1.5) = 0.55;  // how gradual the falloff is — larger = softer edge

void fragment() {
	vec2 centered_uv = UV - vec2(0.5);
	float dist = length(centered_uv) * 2.0;  // ~0 at center, ~1.4 at corners

	float vignette = smoothstep(radius, radius + softness, dist);

	COLOR = vec4(vignette_color.rgb, vignette * intensity * vignette_color.a);
}
