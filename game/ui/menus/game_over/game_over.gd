@tool
extends MainMenu

@onready var message: RichTextLabel = %Message

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_register_events()
		
func _register_events() -> void:
	EventBus.game_ended.connect(func(_won: bool, forced_reason: String):
		message.text = "[wave amp=20.0 freq=4.0][color=%s][b]%s[/b][/color][/wave]" % [Palette.get_color("bright"), forced_reason]
		_pop_up_menu()
	)
	EventBus.game_restart.connect(func():
		print("game over should go now")
		_pop_out_menu()
	)
	
