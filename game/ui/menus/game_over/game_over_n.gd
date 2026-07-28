@tool
extends MainMenu

@onready var message: RichTextLabel = %Message
@export var blur_rect : ColorRect


var blur_tween : Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_register_events()
		
func _register_events() -> void:
	if Engine.is_editor_hint(): return
	EventBus.game_ended.connect(func(won: bool, forced_reason: String):
		message.text = "[wave amp=20.0 freq=4.0][color=%s][b]%s[/b][/color][/wave]" % [Palette.get_color("bright"), forced_reason]
		if won:
			menu_title = LD.GAME_OVER_WIN_TITLE
		else:
			menu_title = LD.GAME_OVER_LOSE_TITLE
		_blur_on()
		_pop_up_menu()
	)
	EventBus.game_restart.connect(func():
		get_tree().paused = false
		_blur_off()
		_pop_out_menu()
	)

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
