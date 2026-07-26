@tool
extends MainMenu

@onready var controls_btn: MenuBtn = %ControlsBtn
@onready var music_toggle: CheckButton = %MusicToggle
@onready var sfx_toggle: CheckButton = %SFXToggle
@onready var main_volume: HSlider = %MainVolume
@onready var music_volume: HSlider = %MusicVolume
@onready var sound_volume: HSlider = %SoundVolume
@onready var sfx_toggle_p: SoundFxCo = %SFXToggleP

var active_timer: SceneTreeTimer = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	var go_back : MenuItem = MenuItem.new()
	go_back.name = "Back"
	go_back.transition = true
	go_back.action = "Close"
	go_back.unhide_scene = "PauseMenu"
	go_back.source_node = "Settings"

	var save_item: MenuItem = MenuItem.new()
	save_item.name = "Save"
	save_item.action = "SavePrefs"
	
	var quit_item: MenuItem = MenuItem.new()
	quit_item.name = "Quit To Desktop"
	quit_item.action = "Quit"

	var go_back_to_main_menu : MenuItem = MenuItem.new()
	go_back_to_main_menu.name = "Back To Main"
	go_back_to_main_menu.transition = true
	go_back_to_main_menu.destination_scene = "MainMenu"
	go_back_to_main_menu.action = "Back"
	
	if get_tree().paused:
		menu_items = [go_back, save_item]
	else:
		menu_items = [go_back_to_main_menu, save_item]	
	
	set_values_from_user_prefs()
	
	if not Engine.is_editor_hint():
		EventBus.game_paused.connect(func():
			menu_items = [go_back, save_item, quit_item]
			set_values_from_user_prefs()
		)
		
	controls_btn.pressed.connect(func():
		if SceneTransition:
			var settings : SceneTransition.TransitionSettings = SceneTransition.TransitionSettings.new()
			settings.target = Constants.SCENE_PATHS["KeyBindings"]
			settings.transitionMode = SceneTransition.mode.STANDARD
			settings.transitionType = SceneTransition.type.CURTAIN
			settings.sourceTransition = SceneTransition.type.WIPE
			settings.targetTransition = SceneTransition.type.WIPE
			settings.sourceNode = self
			settings.useLoadingScreen = false
			if get_tree().paused:
				settings.unhide = true
				settings.nodeToNode = true
				settings.targetNode = get_tree().root.find_child("KeyBindingsMenu", true, false)
				SceneTransition.transition_node_to_node(settings)
			else:
				SceneTransition.transition_scene_to_file(settings)
				
		else:
			get_tree().change_scene_to_file(Constants.SCENE_PATHS["KeyBindings"])
	)
			
	main_volume.value_changed.connect(func(value: float):
		await trigger_debounced_action()
		EventBus.main_volume.emit(value)
		active_timer = null
	)
	music_toggle.toggled.connect(func(toggled_on: bool):
		sfx_toggle_p.play_with_random_pitch()
		EventBus.music_toggle.emit(toggled_on)
	)
	music_volume.value_changed.connect(func(value: float):
		await trigger_debounced_action()
		EventBus.music_volume.emit(value)
		active_timer = null
	)	
	sfx_toggle.toggled.connect(func(toggled_on: bool):
		sfx_toggle_p.play_with_random_pitch()
		EventBus.sound_toggle.emit(toggled_on)
	)
	sound_volume.value_changed.connect(func(value: float):
		await trigger_debounced_action()
		EventBus.sound_volume.emit(value)
		active_timer = null
	)
	
func set_values_from_user_prefs() -> void:
	if Engine.is_editor_hint(): return
	if not GameManager: return
	if not GameManager.player_prefs: return
	
	sound_volume.value = GameManager.player_prefs.sfx_volume
	sfx_toggle.button_pressed = GameManager.player_prefs.sfx_toggle
	
	music_volume.value = GameManager.player_prefs.music_volume
	music_toggle.button_pressed = GameManager.player_prefs.music_toggle
	
	main_volume.value = GameManager.player_prefs.main_volume
	
	
	
func trigger_debounced_action() -> void:
	if is_instance_valid(active_timer):
		return
	active_timer = get_tree().create_timer(0.25)
	await active_timer.timeout
