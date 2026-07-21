class_name Player extends CharacterBody2D


const SPEED : int = 100
const ACCELERATION : int = 5
const FRICTION : int = 8

@onready var tex: AnimatedSprite2D = %Tex

var last_direction : Vector2 = Vector2.RIGHT
var carrying : Dictionary = {"fuel": null, "quantity": 0}

func _ready() -> void:
	_register_events()

func _physics_process(delta: float) -> void:
	_handle_movements(delta)
	_animation_state()
	move_and_slide()

#region events
func _register_events() -> void:
	EventBus.player_loading_fuel.connect(func(fuel : Fuel, quantity: int):
		print("Loading some %s" % fuel.name)
		carrying.fuel = fuel
		carrying.quantity = quantity
	)
	EventBus.player_unloaded_fuel.connect(func(fuel : Fuel, quantity: int):
		pass
		#if carrying.fuel == fuel:
			#carrying.quantity -= quantity
			#if carrying.quantity <= 0:
				#carrying = {"fuel": null, "quantity": 0}
	)
#endregion



#region Movement and Animation
func _handle_movements(delta: float) -> void:
	var direction := Input.get_vector("player_left", "player_right", "player_up", "player_down")
	
	if direction != Vector2.ZERO:
		var lerp_weight = delta * (ACCELERATION if direction else FRICTION)
		velocity = lerp(velocity, direction * SPEED, lerp_weight)
		last_direction = direction
	else:
		velocity = Vector2.ZERO
		

func _animation_state() -> void:
	if velocity != Vector2.ZERO:
		_handle_animation("walking", last_direction)
	else:
		_handle_animation("idle", last_direction)
		

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
