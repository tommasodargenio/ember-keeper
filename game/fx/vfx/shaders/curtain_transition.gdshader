shader_type canvas_item;

uniform float progress: hint_range(0.0, 2.0) = 0.0;


void fragment() {
	float actual_progress = progress;
	if (progress > 1.0) {
		actual_progress = 2.0 - progress;
	}
	
	bool covered;
	
	covered = UV.x < actual_progress;
	
	COLOR = vec4(0.0, 0.0, 0.0, covered ? 1.0 : 0.0);
}
