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
		if GameManager:
			GameManager.fuel_quantity = quantity
		if is_node_ready():
			_update_crate_tex()
				

@onready var crate_tex: Sprite2D = %CrateTex
@onready var interact_sensor: Area2D = %InteractSensor
@onready var icon_position: Marker2D = %IconPosition

var empty_create : Rect2 = Rect2(0, 157, 15, 19)
var can_interact : bool = false

var tutorial_shown : bool = false

func _ready() -> void:
	_update_crate_tex()
	_update_fuel_tex()
	_register_events()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		_handle_interact()

func _register_events() -> void:
	EventBus.fuel_restocked.connect(func():
		if GameManager:
			quantity = GameManager.fuel_quantity
			EventBus.show_message.emit(Constants.MESSAGE_WINDOW_FLAG.INFO, "INFO", LD.FUEL_RESTOCKED, "TIMEOUT")
	)
	interact_sensor.body_entered.connect(func(body: Node2D):
		if body is Player:
			can_interact = true
			if GameManager.show_tutorial and not tutorial_shown:
				_tutorial_sequence()
				tutorial_shown = true			
	)
	interact_sensor.body_exited.connect(func(body: Node2D):
		if body is Player:
			can_interact = false
	)

func _tutorial_sequence() -> void:
	var tutorial := preload(Constants.SCENE_PATHS["FloatingIcon"]).instantiate()
	add_child(tutorial)
	tutorial.place_at(icon_position.global_position)
	tutorial.set_icon(preload(Constants.RESOURCES["EmpytEmote"]))
	tutorial.set_key_text(Utility.get_action_key_binding("interact"))
	tutorial.display_duration = 2.0
	
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
