extends Node2D

@onready var game_lanterns: Node = %GameLanterns

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_game()
	_register_events()
	
func _init_game() -> void:
	GameManager._init_town_lantern(game_lanterns)
	EventBus.game_ready.emit()


func _register_events() -> void:
	if GameManager and GameManager.current_furnace:
		GameManager.current_furnace.furnace_shutdown.connect(func(reason: String):
			if reason == "overheat_damage":
				#game over maybe
				pass
		)
