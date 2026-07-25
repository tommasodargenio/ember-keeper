extends Control

@onready var top_left: Control = %TopLeft
@onready var top_center: Control = %TopCenter
@onready var top_right: Control = %TopRight
@onready var center_left: Control = %CenterLeft
@onready var center: Control = %Center
@onready var center_right: Control = %CenterRight
@onready var bottom_left: Control = %BottomLeft
@onready var bottom_center: Control = %BottomCenter
@onready var bottom_right: Control = %BottomRight



@onready var blink_timer: Timer = %BlinkTimer

@onready var clock_hour: RichTextLabel = %clock_hour
@onready var clock_separator: RichTextLabel = %clock_separator
@onready var clock_minute: RichTextLabel = %clock_minute
@onready var clock_ampm: RichTextLabel = %clock_ampm

var message_window = preload("uid://d2pd5vnpg5jxk")
var tween : Tween
var _current_time_str: String = ""
var _colon_visible: bool = true

func _ready() -> void:
	_register_events()
	init_hud()

func init_hud() -> void:
	var parts: Dictionary = GameClock.get_clock_parts()
	_on_clock_parts_updated(parts["hours"], parts["minutes"], parts["ampm"])
 

func _register_events() -> void:
	EventBus.show_message.connect(display_message)	
	EventBus.hide_ui.connect(_transition_out)
	EventBus.show_ui.connect(_transition_in)
	
	
	EventBus.game_ended.connect(func(won: bool, forced_reason: String):
		var msg = "won: %s - forced_reason: %s" % [won, forced_reason]
		display_message(Constants.MESSAGE_WINDOW_FLAG.INFO, "Game Ended", msg, "CLOSE", true)
	)
	

	GameClock.clock_parts_updated.connect(_on_clock_parts_updated)
	blink_timer.timeout.connect(_on_blink_timeout)	

func display_message(type: Constants.MESSAGE_WINDOW_FLAG, title: String, message: String, action: String = "CLOSE", disable_ui: bool = false):
	var new_msg = message_window.instantiate()
	new_msg.title_text = title
	new_msg.message_text = message
	new_msg.close_action = action
	new_msg.message_flag = type
	bottom_left.add_child(new_msg)
	
	if disable_ui:
		top_left.hide()
		top_right.hide()
		center_left.hide()
		center_right.hide()
		bottom_left.hide()
		bottom_right.hide()
	

func _on_blink_timeout() -> void:
	clock_separator.modulate.a = 1.0 if clock_separator.modulate.a < 1.0 else 0.0

func _on_clock_parts_updated(hours_str: String, minutes_str: String, ampm_str: String) -> void:
	clock_hour.text = hours_str
	clock_minute.text = minutes_str
	clock_ampm.text = ampm_str
	clock_ampm.visible = ampm_str != ""  # hide entirely in 24-hour mode
 	
func _transition_in() -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()	
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
func _transition_out() -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
