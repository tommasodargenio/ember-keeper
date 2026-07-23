extends Node2D

@onready var chair_sensor: Area2D = %ChairSensor

var can_sit : bool = false
var is_sitting : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_register_events()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_sit:
		_handle_interact()

func _register_events() -> void:
	chair_sensor.body_entered.connect(func(body: Node2D):
		if body is Player:
			can_sit = true
	)
	chair_sensor.body_exited.connect(func(body: Node2D):
		if body is Player:
			can_sit = false
	)
	
func _handle_interact() -> void:
	if is_sitting:
		is_sitting = false
		EventBus.player_standing.emit()
	else:
		is_sitting = true
		EventBus.player_sitting.emit()
