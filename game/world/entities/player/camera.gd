extends Camera2D

# Two independent trauma sources, combined by taking the stronger one each frame:
#   - _pulse_trauma: one-off jolts (e.g. ignition) that decay away over time.
#   - _sustained_trauma: a held level set directly from the current pressure
#     zone — recomputed on every pressure_changed, not stacked/accumulated,
#     so it doesn't pin itself at max just because the signal fires a lot.

@export var decay_rate: float = 1.5          # trauma/sec lost from the pulse, AFTER the hold period ends
@export var pulse_hold_time: float = 1.4    # seconds the pulse stays at full peak before decaying — gives it a felt "thud" instead of an instant spike-and-fade
@export var amplitude: float = 15.0
@export var trauma_power: float = 2.0

@export var noise_speed: float = 12.0        # how fast we travel through noise-space per second
@export var noise_frequency: float = 0.6     # FastNoiseLite frequency — higher = jitterier/more tremor-like, lower = smoother rolling waves

@export var ignite_trauma: float = 0.35
@export var mid_pressure_trauma: float = 0.55
@export var high_pressure_trauma: float = 0.55
@export var mid_pressure_range: Vector2 = Vector2(0.5, 0.6)
@export var high_pressure_threshold: float = 0.85

var _pulse_trauma: float = 0.0
var _pulse_hold_remaining: float = 0.0
var _sustained_trauma: float = 0.0
var _noise_offset: float = 0.0

@onready var _noise_x := FastNoiseLite.new()
@onready var _noise_y := FastNoiseLite.new()

var furnace: Furnace


func _ready() -> void:
	randomize()
	_noise_x.seed = randi()
	_noise_y.seed = randi()
	_noise_x.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise_y.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise_x.frequency = noise_frequency
	_noise_y.frequency = noise_frequency

	EventBus.active_furnace_changed.connect(_set_furnace)
	if GameManager.current_furnace:
		_set_furnace(GameManager.current_furnace)


func _set_furnace(new_furnace: Furnace) -> void:
	if furnace:
		if furnace.furnace_ignited.is_connected(_on_ignited):
			furnace.furnace_ignited.disconnect(_on_ignited)
		if furnace.pressure_changed.is_connected(_on_pressure_changed):
			furnace.pressure_changed.disconnect(_on_pressure_changed)

	furnace = new_furnace

	if furnace:
		furnace.furnace_ignited.connect(_on_ignited)
		furnace.pressure_changed.connect(_on_pressure_changed)


func _physics_process(delta: float) -> void:
	if _pulse_hold_remaining > 0.0:
		_pulse_hold_remaining -= delta
	else:
		_pulse_trauma = max(_pulse_trauma - decay_rate * delta, 0.0)
	_noise_offset += noise_speed * delta
	_shake()


func _on_ignited() -> void:
	add_trauma(ignite_trauma)


func _on_pressure_changed(pressure: float) -> void:
	var t: float = clamp(pressure, 0.0, 100.0) / 100.0

	if t >= high_pressure_threshold:
		_sustained_trauma = high_pressure_trauma
	elif t >= mid_pressure_range.x and t <= mid_pressure_range.y:
		_sustained_trauma = mid_pressure_trauma
	else:
		_sustained_trauma = 0.0


func add_trauma(amount: float) -> void:
	_pulse_trauma = min(_pulse_trauma + amount, 1.0)
	_pulse_hold_remaining = pulse_hold_time


func _shake() -> void:
	var trauma: float = max(_pulse_trauma, _sustained_trauma)
	var amount: float = pow(trauma, trauma_power)
	offset.x = amplitude * amount * _noise_x.get_noise_1d(_noise_offset)
	offset.y = amplitude * amount * _noise_y.get_noise_1d(_noise_offset)
