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

@onready var network: RichTextLabel = %Network

var message_window = preload("uid://d2pd5vnpg5jxk")
var tween : Tween

func _ready() -> void:
	_register_events()

func _register_events() -> void:
	EventBus.show_message.connect(func(type: Constants.MESSAGE_WINDOW_FLAG, title: String, message: String, action: String = "CLOSE", disable_ui: bool = false):
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
	)	
	EventBus.hide_ui.connect(_transition_out)
	EventBus.show_ui.connect(_transition_in)
	
	EnergyNetwork.network_updated.connect(func(supply: int, demand: int, lit_count: int, total_count: int):
		var msg = "S: %s - D: %s - L: %s - T: %s" % [supply, demand, lit_count, total_count]
		network.text = msg
	)
	
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
