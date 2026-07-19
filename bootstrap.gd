extends Control

@export var wait_time: float = 4.0
@export var fade_duration : float = 1.2
@export var logo_margins : float = 15.0
@onready var texture_rect: TextureRect = %TextureRect


var tween : Tween
var next : int = 0
func _ready() -> void:
	if Constants.DEBUG and Constants.SCENE_PATHS["MainMenu"] != "":
		var settings : SceneTransition.TransitionSettings = SceneTransition.TransitionSettings.new()
		settings.target = Constants.SCENE_PATHS["MainMenu"]
		settings.transitionMode = SceneTransition.mode.GAME_STARTUP
		settings.useLoadingScreen = false				
		SceneTransition.transition_scene_to_file(settings)
	else:
		set_texture_rect()
		fade_out()
		

func set_texture_rect() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.custom_minimum_size = Vector2.ZERO

	var screen_size := get_viewport().get_visible_rect().size
	var margin := screen_size * (logo_margins/100)  # 15% margin on each side
	texture_rect.offset_left = margin.x
	texture_rect.offset_right = -margin.x
	texture_rect.offset_top = margin.y
	texture_rect.offset_bottom = -margin.y	

func next_tex() -> void:
	if next < Constants.LOGO_CAROUSEL.size():
		texture_rect.texture = load(Constants.LOGO_CAROUSEL.get(next))
		await get_tree().process_frame
		fade_in()
	else:
		print("Going to Main Menu or Game")
		#var settings : SceneTransition.TransitionSettings = SceneTransition.TransitionSettings.new()
		#settings.target = Constants.SCENE_PATHS["MainMenu"]
		#settings.transitionMode = SceneTransition.mode.GAME_STARTUP
		#settings.useLoadingScreen = true		
		#SceneTransition.transition_scene_to_file(settings)
		

func fade_in() -> void:
	texture_rect.modulate = Color(0,0,0,1)
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(texture_rect, "modulate", Color(1,1,1,1), fade_duration / 2)
	tween.tween_callback(func():
		await get_tree().create_timer(wait_time).timeout
		next += 1
		fade_out()
	)
	
func fade_out() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(texture_rect, "modulate", Color(1,1,1,0), fade_duration / 2)
	tween.tween_callback(next_tex)
