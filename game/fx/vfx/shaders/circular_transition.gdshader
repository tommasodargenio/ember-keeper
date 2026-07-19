shader_type canvas_item;

uniform vec2 center = vec2(0.5, 0.5);
uniform float radius : hint_range(0.0, 1.5) = 0.0;

void fragment() {
	float dist = distance(UV, center);
	float circle = 1.0 - step(radius, dist);
	COLOR = vec4(0.0, 0.0, 0.0, circle);
}
