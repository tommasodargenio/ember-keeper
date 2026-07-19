@tool
class_name MenuBtn extends Button

@export var label_font : Font:
	set(value):
		label_font = value
		if is_node_ready():
			add_theme_font_override("font", label_font)
@export var label_font_size : int:
	set(value):
		label_font_size = value
		if is_node_ready():
			add_theme_font_size_override("font_size", label_font_size)

@export var min_height: float = 50.0:
	set(value):
		min_height = value
		if is_node_ready():
			custom_minimum_size.y = min_height

@export var min_width: float = 250.0:
	set(value):
		min_width = value
		if is_node_ready():
			custom_minimum_size.x = min_width
	
@export var float_animation : bool = false

const WIDTH_FULL_ROT := 10.0
const HOVER_SCALE := Vector2(1.08, 1.08)
const NORMAL_SCALE := Vector2.ONE
const CLICK_SCALE := Vector2(0.95, 0.95)

const HOVER_DURATION := 0.15
const CLICK_DURATION := 0.08
const RELEASE_DURATION := 0.12

# Idle animation
const FLOAT_AMOUNT := 1.2      # pixels to float up and down
const FLOAT_DURATION := 1.0    # seconds for one full up-down cycle
const BREATHE_AMOUNT := 0.018  # how much the scale pulses
const BREATHE_DURATION := 1.2  # seconds for one full breathe cycle

var _tween: Tween
var _idle_tween: Tween
var _is_hovered := false
var _base_position_y: float

var scale_ratio : float
var scale_target : float

func _ready() -> void:
	add_theme_font_override("font", label_font)
	add_theme_font_size_override("font_size", label_font_size)
	add_theme_stylebox_override("hover", load(Constants.BUTTON_STYLEBOX["hover"]))
	add_theme_stylebox_override("normal", load(Constants.BUTTON_STYLEBOX["normal"]))
	add_theme_stylebox_override("pressed", load(Constants.BUTTON_STYLEBOX["pressed"]))
	
	custom_minimum_size.x = min_width
	custom_minimum_size.y = min_height
	
	pivot_offset = size / 2
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)
	button_down.connect(_on_click)
	button_up.connect(_on_release)
	resized.connect(func(): pivot_offset = size / 2)
	
	# Stagger idle animation per button so they don't move in sync
	await get_tree().process_frame
	_base_position_y = position.y
	var random_offset := randf_range(0.0, PI * 2)
	if float_animation: _start_idle(random_offset)	

func _animate(target_scale: Vector2, duration: float) -> void:

	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "scale:x", target_scale.x, duration)
	_tween.parallel().tween_property(self, "scale:y", target_scale.y, duration * 2.0)
	_tween.parallel().tween_property(self, "rotation_degrees", 5.0 * scale_ratio * [-1.0,1.0].pick_random(), 0.1)
	_tween.parallel().tween_property(self, "rotation_degrees", 0.0, 0.1).set_delay(0.1)

func _start_idle(phase_offset: float = 0.0) -> void:
	if _idle_tween:
		_idle_tween.kill()

	# Use a single tween with a method call to drive a sine wave each frame
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_method(_apply_idle.bind(phase_offset), 0.0, PI * 2, FLOAT_DURATION)

func _apply_idle(phase: float, phase_offset: float) -> void:
	if _is_hovered:
		return
	var t := phase + phase_offset
	# Vertical float
	position.y = _base_position_y + sin(t) * FLOAT_AMOUNT
	# Gentle breathe on scale — use a different frequency for organic feel
	var breathe := 1.0 + sin(t * (FLOAT_DURATION / BREATHE_DURATION)) * BREATHE_AMOUNT
	scale = Vector2(breathe, breathe)

func _on_hover() -> void:
	scale_ratio = clampf(WIDTH_FULL_ROT/size.x, 0.5, 1.0)
	scale_target = 1.0 + (0.2) * scale_ratio	
	_animate(Vector2(scale_target, scale_target), HOVER_DURATION)

func _on_unhover() -> void:
	_animate(NORMAL_SCALE, HOVER_DURATION)

func _on_click() -> void:
	_animate(CLICK_SCALE, CLICK_DURATION)

func _on_release() -> void:
	_animate(HOVER_SCALE, RELEASE_DURATION)
