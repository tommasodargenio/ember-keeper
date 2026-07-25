extends CanvasLayer

@export var max_intensity: float = 0.6
@export var pulse_speed: float = 4.0        # only kicks in once danger is high, for urgency right before an incident fires
@export var pulse_start_level: float = 0.7

@onready var glow: ColorRect = %Glow

var _last_level: float = 0.0


func _ready() -> void:
	_apply_intensity(0.0)
	NightOutcome.danger_level_changed.connect(_on_danger_level_changed)


func _process(_delta: float) -> void:
	# re-applied every frame (not just on signal) so the pulse animates
	# smoothly rather than only updating whenever danger_level_changed fires
	if _last_level >= pulse_start_level:
		_apply_intensity(_last_level)


func _on_danger_level_changed(level: float) -> void:
	_last_level = level
	_apply_intensity(level)


func _apply_intensity(level: float) -> void:
	var intensity: float = level * max_intensity

	if level >= pulse_start_level:
		var pulse: float = 0.85 + 0.15 * sin(Time.get_ticks_msec() / 1000.0 * pulse_speed)
		intensity *= pulse

	glow.material.set_shader_parameter("intensity", intensity)
