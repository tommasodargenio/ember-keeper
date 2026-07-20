class_name Fuel extends Resource

enum fuel_type {WOOD, COAL}

@export var name : String = ""
@export var description: String = ""

@export var cost : int = 0
@export var energy : int = 0
@export var combustion_time : int = 0
@export var type: fuel_type

@export var tex : Texture2D
