extends Node2D


enum furnace_type {STONE, BRICK, IRON}

@export var is_lit: bool = false
@export var type : furnace_type = furnace_type.STONE:
	set(value):
		type = value
		if is_node_ready():
			_update_tex()
@export var level : int = 0:
	set(value):
		level = clamp(value, 0, max_level-1)

@onready var tex: Sprite2D = %Tex

var max_level = 3

var model_lit : Dictionary = {
	"stone" : [Rect2(0, 0, 32, 64),Rect2(48, 0, 48, 64),Rect2(112, 0, 48, 64)],
	"brick" : [Rect2(0, 80, 32, 64),Rect2(48, 64, 48, 64),Rect2(112, 64, 48, 64)],
	"iron" : [Rect2(0, 144, 32, 64),Rect2(48, 128, 48, 64),Rect2(112, 128, 48, 64)]
}
var model_unlit : Dictionary = {
	"stone" : [Rect2(0, 192, 32, 64),Rect2(48, 192, 48, 64),Rect2(112, 192, 48, 64)],
	"brick" : [Rect2(0, 256, 32, 64),Rect2(48, 256, 48, 64),Rect2(112, 256, 48, 64)],
	"iron" : [Rect2(0, 320, 32, 64),Rect2(48, 320, 48, 64),Rect2(112, 320, 48, 64)]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_tex()



func _update_tex() -> void:
	var f_type_literal = furnace_type.keys()[type].to_lower()
	
	if is_lit and f_type_literal in model_lit:
		tex.region_rect = model_lit[f_type_literal][level]
	elif not is_lit and f_type_literal in model_unlit:
		tex.region_rect = model_unlit[f_type_literal][level]
