extends Node2D


@onready var game_lanterns: Node = %GameLanterns
@onready var chair_marker: Marker2D = %ChairMarker
@onready var chair_room_marker: Marker2D = %ChairRoomMarker
@onready var ui: CanvasLayer = %UI
@onready var player_start_marker: Marker2D = $PlayerStartMarker


var tutorial_shown : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_register_events()
	if GameManager and \
	 GameManager.player_prefs and \
	GameManager.player_prefs.tutorial_newspaper_shown and \
	GameManager.game_in_progress == false:
		_init_game()

	
		
func _init_game() -> void:
	get_tree().paused = false
	GameManager.game_over = false
	GameManager.town_mood = 100
	GameManager.reported_incidents = 0
	GameManager.player_in_chair_room = false
	GameManager.player_in_furnace_room = true
	GameManager._init_town_lantern(game_lanterns)
	GameManager._refresh_lanterns_count()
	GameManager.current_furnace.init_furnace()
	GameClock.start_night()
	NightOutcome._reset()
	EnergyNetwork.distribute()
	EventBus.player_reset.emit(player_start_marker.position)
	EventBus.reset_hotbar.emit()
	
	EventBus.game_ready.emit()
	GameManager.game_in_progress = true
	if  GameManager and \
	GameManager.player_prefs and \
	not GameManager.player_prefs.tutorial_chair_room_shown and \
	GameManager.show_tutorial:
		_show_tutorial_sequence()


func _register_events() -> void:
	if GameManager and GameManager.current_furnace:
		GameManager.current_furnace.furnace_shutdown.connect(func(reason: String):
			if reason == "overheat_damage":
				#game over maybe
				pass
		)
	EventBus.player_entered_room.connect(func(room_name: String):
		if room_name == "Chair" and not tutorial_shown:
			if GameManager.show_tutorial:
				_show_chair_key_prompt()
	)
	EventBus.game_restart.connect(func():
		_init_game()
	)
	EventBus.intro_finished.connect(_init_game)
	
func _show_tutorial_sequence() -> void:
	await get_tree().create_timer(2.0).timeout
	var arrow := preload(Constants.SCENE_PATHS["FloatingIcon"]).instantiate()
	add_child(arrow)
	arrow.place_at(chair_room_marker.global_position)
	arrow.set_icon(preload(Constants.RESOURCES["EmoteArrowRight"]))
	arrow.display_duration = 2.0
	GameManager.player_prefs.tutorial_chair_room_shown = true
	EventBus.tutorial_progress.emit()



func _show_chair_key_prompt() -> void:
	var prompt := preload(Constants.SCENE_PATHS["FloatingIcon"]).instantiate()
	add_child(prompt)
	prompt.place_at(chair_marker.global_position)
	prompt.set_icon(preload(Constants.RESOURCES["EmpytEmote"]))
	prompt.set_key_text(Utility.get_action_key_binding("interact"))
	prompt.display_duration = 2.0
	GameManager.player_prefs.tutorial_dashboard_shown = true
	EventBus.tutorial_progress.emit()
