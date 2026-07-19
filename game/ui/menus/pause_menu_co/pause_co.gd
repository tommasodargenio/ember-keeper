# Give this component a custom icon so we can easily distinguish it in the editor
@icon("res:///ui/pause_menu_co/pause-icon.svg")
# Give this component a class name so we can instance it from the scene editor
class_name PauseCo extends Node

# This variable will reference the pause menu scene file
@export var pause_menu: PackedScene
# Indicate where we need to instantiate the pause menu ui
@export var ui_node: Control
@export var pause_menu_name: StringName
# Internal variable holding the pause menu instance
var pause_menu_instance: Node

func _ready() -> void:
	if not pause_menu is PackedScene: return
	# connect to the game_resume signal to resume the game
	EventBus.game_resumed.connect(func():
		# Check if the game is currently paused
		if get_tree().is_paused():
			# Check if there is a valid pause menu instance
			if pause_menu_instance: 
				pause_menu_instance._blur_off()
			# Un pause the game
			get_tree().paused = false
			
			EventBus.close_menu.emit()
	)


func _input(event: InputEvent) -> void:
	# When we press the key associated with the pong_pause key binding
	if event.is_action_pressed("pause") and not get_tree().paused:
			var pause_menu_running = ui_node.find_child(pause_menu_name, true, false)
			if not pause_menu_running:
				# instance the pause menu scene
				pause_menu_instance = pause_menu.instantiate()
				# add the instance to the root tree
				ui_node.add_child(pause_menu_instance)
			else:
				pause_menu_instance = pause_menu_running
			# play blur animation
			pause_menu_instance._blur_on()
			pause_menu_instance._pop_up_menu()
			EventBus.menu_loaded.connect(func():
				# Signal we paused the game
				EventBus.game_paused.emit()
				# Pause the game
				get_tree().paused = true
			)
