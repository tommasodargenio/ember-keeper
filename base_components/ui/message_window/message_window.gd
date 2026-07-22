extends Control

@export var title_text: String
@export var message_text: String
@export var close_action: String
@export var message_flag: Constants.MESSAGE_WINDOW_FLAG

@onready var title: RichTextLabel = %Title
@onready var message: RichTextLabel = %Message
@onready var close: Button = %Close

var timeout : int = 3

func _ready() -> void:
	if close_action != "":
		if close_action == "TIMEOUT":
			var t = get_tree().create_timer(timeout)
			t.timeout.connect(func():
				var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
				tween.tween_property(self, "modulate:a", 0, 0.5)
				tween.tween_callback(queue_free)
			)
		close.pressed.connect(func():
			if close_action == "QUIT":
				EventBus.message_window_closed.emit(title)
				get_tree().quit()
			elif close_action == "CLOSE" or close_action == "TIMEOUT":
				EventBus.message_window_closed.emit(title)
				queue_free()
		)
	
	var emoji = "" 
	match message_flag:
		Constants.MESSAGE_WINDOW_FLAG.INFO:
			emoji = "[char=%s]" % Constants.INFO_UTF_CODE
		Constants.MESSAGE_WINDOW_FLAG.WARNING:
			emoji = "[char=%s]" % Constants.WARNING_UTF_CODE
		Constants.MESSAGE_WINDOW_FLAG.ERROR:
			emoji = "[char=%s]" % Constants.ERROR_UTF_CODE

	title.text = "%s [b]%s[/b]" % [emoji, title_text]
	
	message.text = message_text
