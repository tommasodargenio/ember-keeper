extends Node2D

const FUEL_TEX_GROUP = "FuelTex"


@export var fuel: Fuel:
	set(value):
		fuel = value
		if is_node_ready():
			_update_fuel_tex()
			
@export var quantity : int = 0:
	set(value):
		quantity = value
		if is_node_ready():
			_update_crate_tex()
				

@onready var crate_tex: Sprite2D = %CrateTex
@onready var interact_sensor: Area2D = %InteractSensor

var empty_create : Rect2 = Rect2(0, 157, 15, 19)
var can_interact : bool = false

func _ready() -> void:
	_update_crate_tex()
	_update_fuel_tex()
	_register_events()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		_handle_interact()

func _register_events() -> void:
	interact_sensor.body_entered.connect(func(body: Node2D):
		if body is Player:
			can_interact = true
	)
	interact_sensor.body_exited.connect(func(body: Node2D):
		if body is Player:
			can_interact = false
	)

func _handle_interact() -> void:
	if fuel and quantity > 0:
		quantity -= 1
		EventBus.player_loading_fuel.emit(fuel, 1)
	else:
		print("Argh nothing in this crate to pickup")

func _update_fuel_tex() -> void:
	for n in get_tree().get_nodes_in_group(FUEL_TEX_GROUP):
		if fuel.tex and quantity > 0:
			n.texture = fuel.tex
		else:
			n.texture = null
	
func _update_crate_tex() -> void:
	pass
