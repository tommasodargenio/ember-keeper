class_name Furnace extends Resource

enum furnace_type {STONE, BRICK, IRON}

@export var name : String = ""
@export var description: String = ""

@export var level : int = 1:
	set(value):
		level = clamp(value, 1, max_level)
		
@export var type : furnace_type
		
var max_level : int = 3

@export var max_fuel_capacity : int = 0
@export var energy_burning_capacity : int = 0

@export var energy_output : int = 0
@export var max_energy_output: int = 0

@export var fuel_type : Fuel.fuel_type
