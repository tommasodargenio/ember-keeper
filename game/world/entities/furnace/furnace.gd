extends StaticBody2D

@export var is_lit: bool = false:
	set(value):
		is_lit = value
		if is_node_ready():
			_update_tex()	
@export var use_fx: bool = false

@export var profile : Furnace:
	set(value):
		profile = value
		if is_node_ready():
			_update_tex()


@onready var tex: Sprite2D = %Tex
@onready var interact_sensor: Area2D = %InteractSensor

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
	EnergyNetwork.register_furnace(profile)
	
func _exit_tree() -> void:
	EnergyNetwork.unregister_furnace(profile)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		_handle_interact()
	if event.is_action_pressed("ui_accept"):
		var f = preload("res://game/resources/models/game/basic_wood.tres")
		
		profile.load_fuel(f, 20)

func _process(delta: float) -> void:
	profile.tick(delta)
	_handle_state()
	
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

func _handle_state() -> void:
	match profile.state:
		Furnace.furnace_state.BURNING:
			is_lit = true
		Furnace.furnace_state.SHUTDOWN_LOW_PRESSURE:
			is_lit = false
		Furnace.furnace_state.IDLE:
			is_lit = false
		Furnace.furnace_state.OFF:
			is_lit = false
		_:	_update_tex()

func _handle_interact() -> void:
	if not (interacting_player is Player):
		return

	if not (interacting_player.carrying.fuel is Fuel):
		EventBus.show_message.emit(Constants.MESSAGE_WINDOW_FLAG.WARNING, "Warning", LD.FURNACE_NOT_FUEL)
		print(LD.FURNACE_NOT_FUEL)
		return

	var player_carrying: Dictionary = interacting_player.carrying

	if player_carrying.quantity <= 0:
		EventBus.show_message.emit(Constants.MESSAGE_WINDOW_FLAG.WARNING, "Warning", LD.PLAYER_EMPTY_HANDED)
		print(LD.PLAYER_EMPTY_HANDED)
		return

	if player_carrying.fuel.type != profile.fuel_type:
		var msg = LD.FURNACE_WRONG_FUEL % [
			player_carrying.fuel.name, Fuel.fuel_type.keys()[profile.fuel_type]
		]
		EventBus.show_message.emit(Constants.MESSAGE_WINDOW_FLAG.WARNING, "Warning", msg)

		print(msg)
		return

	var accepted := profile.load_fuel(player_carrying.fuel, player_carrying.quantity)

	if accepted == 0:
		EventBus.show_message.emit(Constants.MESSAGE_WINDOW_FLAG.WARNING, "Warning", LD.FURNACE_FULL)
		print(LD.FURNACE_FULL)
		return

	player_carrying.quantity -= accepted
	EventBus.player_unloaded_fuel.emit(player_carrying.fuel, accepted)

	if accepted < player_carrying.quantity + accepted:
		var msg = LD.FURNACE_FUEL_LOADED % [accepted, player_carrying.quantity]
		EventBus.show_message.emit(Constants.MESSAGE_WINDOW_FLAG.WARNING, "Warning", msg)
		print(msg)
	else:
		var msg = LD.FURNACE_BURNING_FUEL % profile.current_fuel_units
		EventBus.show_message.emit(Constants.MESSAGE_WINDOW_FLAG.WARNING, "Warning", msg)
		print(msg)
			
func _update_tex() -> void:
	if not profile: return
	
	var f_type_literal = Furnace.furnace_type.keys()[profile.type].to_lower()
	
	if is_lit and f_type_literal in model_lit:
		tex.region_rect = model_lit[f_type_literal][profile.level]
	elif not is_lit and f_type_literal in model_unlit:
		tex.region_rect = model_unlit[f_type_literal][profile.level]
