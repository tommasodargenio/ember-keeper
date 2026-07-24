extends StaticBody2D

@export var start_filled: bool = true
@export var water_given : int = 10
@onready var tex: Sprite2D = %Tex

@onready var interact_sensor: Area2D = %InteractSensor


var water_qty : int = 100
var model_filled: Rect2 = Rect2(144.0, 128.0, 16.0, 16.0)
var model_empty : Rect2 = Rect2(128.0, 128.0, 16.0, 16.0)
var can_interact : bool = false



func _ready() -> void:
	_register_events()
	_reset_tex()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		_handle_interact()	
	
func _handle_interact() -> void:
	if water_qty - water_given >= 0:
		water_qty -= water_given
		EventBus.player_has_water.emit(water_given)
	else:
		if water_qty <= 0:
			tex.region_rect = model_empty
		EventBus.show_message.emit(Constants.MESSAGE_WINDOW_FLAG.WARNING, "Warning", LD.WATER_BUCKET_EMPTY, "TIMEOUT")
	
func _reset_tex() -> void:
	tex.region_rect = model_filled if start_filled else model_empty
	

func _register_events() -> void:
	interact_sensor.body_entered.connect(func(body: Node2D):
		if body is Player:
			can_interact = true
	)
	interact_sensor.body_exited.connect(func(body: Node2D):
		if body is Player:
			can_interact = false
	)
