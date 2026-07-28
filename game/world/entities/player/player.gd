class_name Player extends CharacterBody2D


const SPEED : int = 100
const ACCELERATION : int = 5
const FRICTION : int = 8

@export var step_interval: float = 0.35 
@onready var tex: AnimatedSprite2D = %Tex
@onready var sfx_step_stone: SoundFxCo = %SFXStepStone
@onready var sfx_step_soft: SoundFxCo = %SFXStepSoft
@onready var sfx_rumble: SoundFxCo = %SFXRumble
@onready var sfx_watering: SoundFxCo = %SFXWatering

@onready var step_timer: Timer = %StepTimer

var _stepping: bool = false
var last_direction : Vector2 = Vector2.RIGHT
var carrying : Dictionary = {"fuel": null, "quantity": 0}
var can_walk : bool = true
var is_sitting : bool = false
var is_watering : bool = false
var carrying_water : int = 0

func _ready() -> void:
	_register_events()
	step_timer.one_shot = true

	

func _physics_process(delta: float) -> void:
	_handle_movements(delta)
	_animation_state()
	move_and_slide()

#region events
func _register_events() -> void:
	step_timer.timeout.connect(func(): _stepping = false)
	
	EventBus.player_set_position.connect(func(pos: Vector2):
		position = pos
	)
	EventBus.player_reset.connect(func(pos: Vector2): 
		position = pos
		carrying = {"fuel": null, "quantity": 0}
		can_walk = true
		is_sitting = false
		carrying_water = 0
	)
	EventBus.player_has_water.connect(func(quantity: int):
		carrying_water += quantity
		EventBus.add_to_hotbar.emit("Water",load(Constants.RESOURCES["WaterBucket"]), quantity, Utility.get_action_key_binding("watering") )
	)
	EventBus.player_loading_fuel.connect(func(fuel : Fuel, quantity: int):
		carrying.fuel = fuel
		carrying.quantity += quantity
		var fuel_tex = Constants.RESOURCES["FuelWood"] if fuel.type == Fuel.fuel_type.WOOD else Constants.RESOURCES["FuelCoal"]
		EventBus.add_to_hotbar.emit(fuel.name, load(fuel_tex), quantity,  Utility.get_action_key_binding("interact"))
	)
	EventBus.player_sitting.connect(func():
		is_sitting = true
		can_walk = false
		tex.play("sitting")
	)
	EventBus.player_standing.connect(func():
		tex.play("standing")
	)
	EventBus.player_watering.connect(func(_quantity: int):
		can_walk = false
		is_watering = true
		tex.play("water_up")
		sfx_watering.play()
	)
	tex.animation_finished.connect(func():
		if tex.animation == "sitting":
			EventBus.player_sat.emit()
		if tex.animation == "standing":
			is_sitting = false
			can_walk = true
			last_direction.y = 1.0
			tex.play("idle_down")
		if tex.animation == "water_up":
			can_walk = true
			is_watering = false
			last_direction.y = 1.0
			tex.play("idle_down")
	)
	
#endregion



#region Movement and Animation
func _handle_movements(delta: float) -> void:
	if not can_walk:
		velocity = Vector2.ZERO
		return
	
	var direction := Input.get_vector("player_left", "player_right", "player_up", "player_down")
	
	if direction != Vector2.ZERO:
		var lerp_weight = delta * (ACCELERATION if direction else FRICTION)
		velocity = lerp(velocity, direction * SPEED, lerp_weight)
		last_direction = direction
	else:
		velocity = Vector2.ZERO
		

func _animation_state() -> void:
	if is_sitting: return
	if is_watering: return
	
	if velocity != Vector2.ZERO:
		_handle_animation("walking", last_direction)
		_play_footstep()		
	else:
		_handle_animation("idle", last_direction)
		_stepping = false
		step_timer.stop()
		
func _play_footstep() -> void:
	if _stepping:
		return
	_stepping = true
	step_timer.start(step_interval)

	if GameManager.player_in_chair_room:
		sfx_step_soft.play()
	elif GameManager.player_in_furnace_room:
		sfx_step_stone.play()
		
func _handle_animation(prefix: String, dir: Vector2) -> void:
	if prefix != "idle":
		tex.speed_scale = (velocity/SPEED).distance_to(Vector2.ZERO) + 0.5
	else:
		tex.speed_scale = .75
		
	if dir.x > 0:
		tex.play(prefix + "_right")
		return
	if dir.x < 0:
		tex.play(prefix + "_left")
		return
	if dir.y > 0:
		tex.play(prefix + "_down")
		return
	if dir.y < 0:
		tex.play(prefix + "_up")
		return		
#endregion
