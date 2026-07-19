@tool
extends MainMenu


@export var placeholder_awaiting_input : String = "..."
@onready var controls_container: GridContainer = %ControlsContainer

var input_button := preload("res://ui/key_bindings_menu_co/control_map_button.tscn")

var current_actions : Array[StringName]

func _ready() -> void:
	super()
	
	var go_back_when_paused : MenuItem = MenuItem.new()
	go_back_when_paused.name = "Back"
	go_back_when_paused.transition = true
	go_back_when_paused.action = "Close"
	go_back_when_paused.unhide_scene = "Settings"
	go_back_when_paused.source_node = "KeyBindingsMenu"	
	
	var go_back_from_main : MenuItem = MenuItem.new()
	go_back_from_main.name = "Back"
	go_back_from_main.transition = true
	go_back_from_main.action = "Back"
	go_back_from_main.unhide_scene = ""
	go_back_from_main.destination_scene = "Settings"
	
	var save_item: MenuItem = MenuItem.new()
	save_item.name = "Save"
	save_item.action = "SavePrefs"
	
	if get_tree().paused:
		menu_items = [go_back_when_paused, save_item]
	else:
		menu_items = [go_back_from_main, save_item]

	_update_actions()
	_register_events([go_back_when_paused, save_item])	
	
func _register_events(item_list : Array[MenuItem]) -> void:
	if Engine.is_editor_hint(): return
	EventBus.game_paused.connect(func():
		menu_items = item_list
	)

func _update_actions() -> void:
	current_actions.clear()
	current_actions = InputMap.get_actions()
	current_actions.sort()
	
	for action_category in Constants.DEFAULT_KEY_BINDINGS:
		var category_label = RichTextLabel.new()
		category_label.text = "[hr width=100%% color=DIM_GRAY][bgcolor=CHOCOLATE][b]%s[/b][/bgcolor][hr width=100%% color=DIM_GRAY]" % action_category.capitalize()
		category_label.bbcode_enabled = true
		category_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		category_label.fit_content = true
		controls_container.add_child(category_label)
		
		for c_a in Constants.DEFAULT_KEY_BINDINGS[action_category]:
			if not InputMap.has_action(c_a): continue
			var i_b = input_button.instantiate().duplicate()
			i_b.action_name = c_a
			i_b.placeholder = placeholder_awaiting_input
			controls_container.add_child(i_b)
