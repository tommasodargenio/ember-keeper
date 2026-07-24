extends Node2D

@onready var game_lanterns: Node = %GameLanterns

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager._init_town_lantern(game_lanterns)
