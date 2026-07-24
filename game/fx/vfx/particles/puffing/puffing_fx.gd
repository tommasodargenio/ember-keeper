extends Node2D
## Fire-geyser puffback effect: fire spits out of a small hole in bursts,
## trailed by lingering smoke, repeating on a timer while the furnace is in
## an active puffback state (furnace_puffback / furnace_puffback_ended).
##
## Scene setup expected as children, with unique names (%):
##   FireParticles  (GPUParticles2D)
##   SmokeParticles (GPUParticles2D)
##   BurstTimer     (Timer)
## Position this node at the furnace's hole/vent point.

@export_group("Textures")
@export var fire_texture: Texture2D    # try one of the more turbulent trace sprites
@export var smoke_texture: Texture2D   # your smoke sprite

@export_group("Timing")
@export var burst_interval: float = 1.2              # seconds between spits
@export var burst_interval_variance: float = 0.35     # randomized +/- so it doesn't feel metronomic

@export_group("Fire")
@export var fire_amount: int = 12
@export var fire_lifetime: float = 0.4
@export var fire_scale_min: float = 0.04    # fraction of the source texture's native pixel size
@export var fire_scale_max: float = 0.08
@export var fire_velocity_min: float = 30.0
@export var fire_velocity_max: float = 55.0
@export var fire_gravity: float = 90.0
@export var fire_spread_deg: float = 8.0

@export_group("Smoke")
@export var smoke_amount: int = 7
@export var smoke_lifetime: float = 1.0
@export var smoke_scale_min: float = 0.08
@export var smoke_scale_max: float = 0.14
@export var smoke_velocity_min: float = 10.0
@export var smoke_velocity_max: float = 22.0
@export var smoke_spread_deg: float = 16.0

@onready var fire_particles: GPUParticles2D = %FireParticles
@onready var smoke_particles: GPUParticles2D = %SmokeParticles
@onready var burst_timer: Timer = %BurstTimer

var _active: bool = false
var _furnace: Furnace


func _ready() -> void:
	_configure_fire()
	_configure_smoke()

	fire_particles.emitting = false
	smoke_particles.emitting = false

	burst_timer.one_shot = true
	burst_timer.timeout.connect(_spit)

	EventBus.active_furnace_changed.connect(_set_furnace)
	if GameManager and GameManager.current_furnace:
		_set_furnace(GameManager.current_furnace)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_home"):
		_start()

func _set_furnace(furnace: Furnace) -> void:
	if _furnace:
		if _furnace.furnace_puffback.is_connected(_start):
			_furnace.furnace_puffback.disconnect(_start)
		if _furnace.furnace_puffback_ended.is_connected(_stop):
			_furnace.furnace_puffback_ended.disconnect(_stop)

	_furnace = furnace

	if _furnace:
		_furnace.furnace_puffback.connect(_start)
		_furnace.furnace_puffback_ended.connect(_stop)


func _start() -> void:
	if _active:
		return
	_active = true
	_spit()


func _stop() -> void:
	_active = false
	burst_timer.stop()


func _spit() -> void:
	if not _active:
		return

	fire_particles.restart()
	fire_particles.emitting = true

	smoke_particles.restart()
	smoke_particles.emitting = true

	var next_interval: float = burst_interval + randf_range(-burst_interval_variance, burst_interval_variance)
	burst_timer.start(max(next_interval, 0.1))


func _configure_fire() -> void:
	fire_particles.texture = fire_texture
	fire_particles.amount = fire_amount
	fire_particles.lifetime = fire_lifetime
	fire_particles.one_shot = true
	fire_particles.explosiveness = 0.85  # most particles fire near-simultaneously — a "spit," not a steady stream
	fire_particles.randomness = 0.3
	fire_particles.local_coords = false
	fire_particles.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR  # keeps the soft trace gradient smooth even under integer pixel-scaling

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = fire_spread_deg
	mat.initial_velocity_min = fire_velocity_min
	mat.initial_velocity_max = fire_velocity_max
	mat.gravity = Vector3(0, fire_gravity, 0)  # pulls particles back down — "spits up, falls back"
	mat.scale_min = fire_scale_min
	mat.scale_max = fire_scale_max
	mat.scale_curve = _make_curve([0.3, 1.0, 0.5, 0.0])  # grows fast, tapers toward end of life
	mat.angle_min = -15.0
	mat.angle_max = 15.0
	mat.angular_velocity_min = -90.0
	mat.angular_velocity_max = 90.0
	mat.color_ramp = _make_fire_ramp()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT

	fire_particles.process_material = mat


func _configure_smoke() -> void:
	smoke_particles.texture = smoke_texture
	smoke_particles.amount = smoke_amount
	smoke_particles.lifetime = smoke_lifetime
	smoke_particles.one_shot = true
	smoke_particles.explosiveness = 0.5   # trails out a bit looser than the sharp fire burst
	smoke_particles.randomness = 0.4
	smoke_particles.local_coords = false
	smoke_particles.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = smoke_spread_deg
	mat.initial_velocity_min = smoke_velocity_min
	mat.initial_velocity_max = smoke_velocity_max
	mat.gravity = Vector3(0, -8.0, 0)        # slight upward drift once the fire's push fades
	mat.damping_min = 10.0
	mat.damping_max = 25.0
	mat.scale_min = smoke_scale_min
	mat.scale_max = smoke_scale_max
	mat.scale_curve = _make_curve([0.4, 1.0, 1.0, 1.0])  # grows and lingers large as it dissipates
	mat.angular_velocity_min = -30.0
	mat.angular_velocity_max = 30.0
	mat.color_ramp = _make_smoke_ramp()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT

	smoke_particles.process_material = mat


func _make_curve(points: Array) -> CurveTexture:
	var curve := Curve.new()
	for i in range(points.size()):
		curve.add_point(Vector2(float(i) / float(points.size() - 1), points[i]))
	var tex := CurveTexture.new()
	tex.curve = curve
	return tex


func _make_fire_ramp() -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.3, 0.7, 1.0])
	gradient.colors = PackedColorArray([
		Color(1.0, 0.95, 0.6, 1.0),   # pale yellow-white at the base
		Color(1.0, 0.55, 0.1, 1.0),   # orange
		Color(0.9, 0.15, 0.05, 0.8),  # red, fading
		Color(0.3, 0.05, 0.05, 0.0),  # dark red, transparent
	])
	var tex := GradientTexture1D.new()
	tex.gradient = gradient
	return tex


func _make_smoke_ramp() -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	gradient.colors = PackedColorArray([
		Color(0.5, 0.48, 0.45, 0.7),
		Color(0.35, 0.35, 0.35, 0.4),
		Color(0.2, 0.2, 0.2, 0.0),
	])
	var tex := GradientTexture1D.new()
	tex.gradient = gradient
	return tex
