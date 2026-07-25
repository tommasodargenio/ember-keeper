@tool
@icon("uid://bwg2h1doftblx")
extends MainMenu


@export var blur_rect : ColorRect


var blur_tween : Tween
var is_paused : bool = false

# Called when the node enters the scene tree for the first time._on_menu_show()
func _ready() -> void:
	super()
	_register_events()

func _register_events() -> void:
	if Engine.is_editor_hint():
		return
	EventBus.menu_loaded.connect(func():
		_pause()
	)
	EventBus.game_resumed.connect(func():
	# Check if the game is currently paused
		if get_tree().is_paused():
			# Check if there is a valid pause menu instance
			_blur_off()
			# Un pause the game
			get_tree().paused = false
			_pop_out_menu()
)	


func _create_label(text: String) -> HBoxContainer:
	var c := HBoxContainer.new()
	var l := RichTextLabel.new()
	
	c.add_child(l)
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.size_flags_vertical = Control.SIZE_EXPAND
	l.add_theme_font_override("normal", label_setting.font)
	l.add_theme_font_size_override("font_size", label_setting.font_size)
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.bbcode_enabled = true
	l.fit_content = true
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return c


func _blur_on() -> void:
	if not blur_rect: return
	if blur_tween and blur_tween.is_running():
		blur_tween.kill()
		
	blur_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	blur_tween.tween_property(blur_rect, "color:a", 1.0, 0.01)
	
func _blur_off() -> void:
	if not blur_rect: return
	if blur_tween and blur_tween.is_running():
		blur_tween.kill()
		
	blur_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	blur_tween.tween_property(blur_rect, "color:a", 0.0, 0.01)	


func _pause():
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not get_tree().paused:
			EventBus.game_paused.emit()
			# Pause the game
			#_update_stats()
			_blur_on()
			_pop_up_menu()
		else:
			EventBus.game_resumed.emit()
