extends HBoxContainer
@export var placeholder: String = "...":
	set(value):
		placeholder = value
		if is_node_ready() and input_re_map_button:
			input_re_map_button.placeholder = placeholder
@export var action_name : String = "":
	set(value):
		action_name = value
		if is_node_ready() and label:
			label.text = action_name.capitalize()
			if input_re_map_button:
				input_re_map_button.action = action_name

@onready var label: Label = %Label
@onready var input_re_map_button: InputReMapButton = %InputReMapButton


func _ready() -> void:
	label.text = action_name.capitalize()
	input_re_map_button.action = action_name
	input_re_map_button.placeholder = placeholder
	
