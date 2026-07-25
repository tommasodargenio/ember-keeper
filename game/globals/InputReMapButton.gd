class_name InputReMapButton extends Button
@export var placeholder: String = "..."
@export var action: String:
	set(value):
		action = value
		if is_node_ready():
			update_key_text()
@export var action_event_index: int = 0

var _just_toggled := true

func _init():
	toggle_mode = true

func _ready() -> void:
	set_process_unhandled_input(false)
	set_process_input(false)
	update_key_text()

func _input(event: InputEvent) -> void:
	if not button_pressed: return

	_handle_event(event)
	get_viewport().set_input_as_handled()

func _handle_event(event: InputEvent) -> void:
	if event is InputEventKey:
		if not event.pressed: return
		if _is_modifier_key(event.keycode):
			text = _format_modifiers(event)
			return
		var full_event := InputEventKey.new()
		full_event.keycode = event.keycode
		full_event.ctrl_pressed = event.ctrl_pressed
		full_event.shift_pressed = event.shift_pressed
		full_event.alt_pressed = event.alt_pressed
		full_event.meta_pressed = event.meta_pressed
		_commit_event(full_event)
	elif event is InputEventMouseButton:
		if not event.pressed: return
		var full_event := InputEventMouseButton.new()
		full_event.button_index = event.button_index
		full_event.ctrl_pressed = event.ctrl_pressed
		full_event.shift_pressed = event.shift_pressed
		full_event.alt_pressed = event.alt_pressed
		full_event.meta_pressed = event.meta_pressed
		full_event.double_click = false
		_commit_event(full_event)

func _commit_event(event: InputEvent) -> void:
	var action_events_list = InputMap.action_get_events(action)
	if action_event_index < action_events_list.size():
		InputMap.action_erase_event(action, action_events_list[action_event_index])
	InputMap.action_add_event(action, event)
	EventBus.key_binding_changed.emit()
	button_pressed = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	update_key_text()	
	
func _is_modifier_key(keycode: Key) -> bool:
	return keycode in [KEY_CTRL, KEY_SHIFT, KEY_ALT, KEY_META]
	
func _format_modifiers(event: InputEvent) -> String:
	var parts: Array[String] = []
	if event.ctrl_pressed or event.keycode in [KEY_CTRL]:
		parts.append("Ctrl")
	if event.shift_pressed or event.keycode in [KEY_SHIFT]:
		parts.append("Shift")
	if event.alt_pressed or event.keycode in [KEY_ALT]:
		parts.append("Alt")
	if event.meta_pressed or event.keycode in [KEY_META]:
		parts.append("Meta")
	parts.append(placeholder)
	return "+".join(parts)

func update_key_text():
	var events = InputMap.action_get_events(action)
	if events.is_empty() or action_event_index >= events.size():
		text = "unset"
		return
	text = events[action_event_index].as_text().replacen("- Physical", "").strip_edges()	
	
	
func _toggled(button_pressed: bool) -> void:
	set_process_unhandled_input(false)
	set_process_input(button_pressed)
	if button_pressed:
		_just_toggled = false
		text = placeholder
		release_focus()
		await get_tree().process_frame
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		_just_toggled = true
	else:
		_just_toggled = false
		update_key_text()
		mouse_filter = Control.MOUSE_FILTER_STOP
		grab_focus()
		
