extends Node2D

@export var is_lit: bool = false
@export var use_fx: bool = false

@export var profile : Furnace:
	set(value):
		profile = value
		if is_node_ready():
			_update_tex()


@onready var tex: Sprite2D = %Tex
@onready var interact_sensor: Area2D = %InteractSensor
@onready var fuel_burning_timer: Timer = %FuelBurningTimer

var can_interact : bool = false
var interacting_player : Player

var current_fuel_load : int = 0

var model_lit : Dictionary = {
	"stone" : [Rect2(0, 0, 32, 64), Rect2(0, 0, 32, 64),Rect2(48, 0, 48, 64),Rect2(112, 0, 48, 64)],
	"brick" : [Rect2(0, 80, 32, 64),Rect2(0, 80, 32, 64),Rect2(48, 64, 48, 64),Rect2(112, 64, 48, 64)],
	"iron" : [Rect2(0, 144, 32, 64),Rect2(0, 144, 32, 64),Rect2(48, 128, 48, 64),Rect2(112, 128, 48, 64)]
}
var model_unlit : Dictionary = {
	"stone" : [Rect2(0, 192, 32, 64),Rect2(0, 192, 32, 64),Rect2(48, 192, 48, 64),Rect2(112, 192, 48, 64)],
	"brick" : [Rect2(0, 256, 32, 64),Rect2(0, 256, 32, 64),Rect2(48, 256, 48, 64),Rect2(112, 256, 48, 64)],
	"iron" : [Rect2(0, 320, 32, 64),Rect2(0, 320, 32, 64),Rect2(48, 320, 48, 64),Rect2(112, 320, 48, 64)]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_tex()
	_register_events()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		_handle_interact()
		
func _register_events() -> void:
	interact_sensor.body_entered.connect(func(body: Node2D):
		if body is Player:
			can_interact = true
			interacting_player = body
	)
	interact_sensor.body_exited.connect(func(body: Node2D):
		if body is Player:
			can_interact = false
			interacting_player = null
	)
	
func _handle_interact() -> void:
	if interacting_player is Player:
		if interacting_player.carrying.fuel is Fuel:
			var player_carrying: Dictionary = interacting_player.carrying
			if profile.fuel_type == player_carrying.fuel.type:
				if player_carrying.quantity and player_carrying.quantity > 0:
					var projected_load = current_fuel_load + player_carrying.quantity
					
					if projected_load > profile.max_fuel_capacity:
						print("Furnate at max capacity, can't load")
						return
					
					current_fuel_load = projected_load
					print("We are burning baby, current load %s" % current_fuel_load)
					EventBus.player_unloaded_fuel.emit(player_carrying.fuel, player_carrying.quantity)
				else:
					print("You have nothing to load")
			else:
				print("You can't load %s into this furnace which only accepts %s" % [player_carrying.fuel.name, Fuel.fuel_type.keys()[profile.fuel_type]])	
		else:
			print("Not sure what you are carrying but this ain't fuel!!")

func _update_tex() -> void:
	if not profile: return
	
	var f_type_literal = Furnace.furnace_type.keys()[profile.type].to_lower()
	
	if is_lit and f_type_literal in model_lit:
		tex.region_rect = model_lit[f_type_literal][profile.level]
	elif not is_lit and f_type_literal in model_unlit:
		tex.region_rect = model_unlit[f_type_literal][profile.level]
