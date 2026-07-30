class_name Preferences extends Resource

enum SCREEN {FULLSCREEN, WINDOWED, BORDERLESS_WINDOW}

class KeyBinding:
	var action_name : StringName
	var event : InputEvent
	
	func _init(_name : StringName, _ev: InputEvent) -> void:
		action_name = _name
		event = _ev
		
	func to_dict() -> Dictionary:
		var event_data := {}

		if event is InputEventKey:
			event_data = {
				"type":      "key",
				"keycode":   event.keycode,        # Physical key (layout-independent)
				"physical":  event.physical_keycode,
				"modifiers": {
					"shift": event.shift_pressed,
					"ctrl":  event.ctrl_pressed,
					"alt":   event.alt_pressed,
					"meta":  event.meta_pressed,
				}
			}
		elif event is InputEventMouseButton:
			event_data = {
				"type":        "mouse_button",
				"button_index": event.button_index,
				"modifiers": {
					"shift": event.shift_pressed,
					"ctrl":  event.ctrl_pressed,
					"alt":   event.alt_pressed,
					"meta":  event.meta_pressed,
				}
			}

		return {
			"action_name": action_name,
			"event":       event_data,
		}

@export var music_toggle : bool = true
@export var music_volume : float = 100.0

@export var sfx_toggle : bool = true
@export var sfx_volume : float = 100.0

@export var main_volume: float = 100.0

@export var screen_mode : SCREEN

@export var last_played_game : String
@export var key_bindings : Array
@export var last_game_saved_at: String

@export var tutorial_shown : bool = false
@export var tutorial_phone_shown : bool = false
@export var tutorial_newspaper_shown : bool = false
@export var tutorial_dashboard_shown : bool = false
@export var tutorial_furnace_shown : bool = false
@export var tutorial_water_bucket_shown : bool = false
@export var tutorial_fuel_crate_shown : bool = false
@export var tutorial_chair_room_shown : bool = false

func to_dict() -> Dictionary:
	return {
		"music_toggle":         music_toggle,
		"music_volume":         music_volume,
		"sfx_toggle":           sfx_toggle,
		"sfx_volume":           sfx_volume,
		"main_volume": 			main_volume,
		"screen_mode":          screen_mode,
		"last_played_game":     last_played_game,
		"last_game_saved_at": last_game_saved_at,
		"tutorial_shown": tutorial_shown,
		"tutorial_newspaper_shown": tutorial_newspaper_shown,
		"tutorial_dashboard_shown": tutorial_dashboard_shown,
		"tutorial_furnace_shown": tutorial_furnace_shown,
		"tutorial_water_bucket_shown": tutorial_water_bucket_shown,
		"tutorial_fuel_crate_shown": tutorial_fuel_crate_shown,
		"tutorial_chair_room_shown": tutorial_chair_room_shown,
		"tutorial_phone_shown": tutorial_phone_shown,
		"key_bindings":			save_key_bindings()
	}
	
static func from_dict(d: Dictionary) -> Preferences:
	var p := Preferences.new()
	p.music_toggle         = d.get("music_toggle",         true)
	p.music_volume         = d.get("music_volume",         100.0)
	p.sfx_toggle           = d.get("sfx_toggle",           true)
	p.sfx_volume           = d.get("sfx_volume",           100.0)
	p.main_volume		   = d.get("main_volume",		   100.0)
	p.screen_mode          = d.get("screen_mode",          SCREEN.FULLSCREEN)
	p.last_played_game     = d.get("last_played_game",     "")
	p.tutorial_shown		= d.get("tutorial_shown", false)
	p.tutorial_newspaper_shown	= d.get("tutorial_newspaper_shown", false)
	p.tutorial_dashboard_shown	= d.get("tutorial_dashboard_shown", false)
	p.tutorial_furnace_shown	= d.get("tutorial_furnace_shown", false)
	p.tutorial_water_bucket_shown	= d.get("tutorial_water_bucket_shown", false)
	p.tutorial_fuel_crate_shown	= d.get("tutorial_fuel_crate_shown", false)
	p.tutorial_chair_room_shown	= d.get("tutorial_chair_room_shown", false)
	p.tutorial_phone_shown = d.get("tutorial_phone_shown", false)
	p.last_game_saved_at = d.get("last_game_saved_at", "")
	p.key_bindings		   = d.get("key_bindings", [])
	
	apply_key_bindings(p.key_bindings)
	
	return p
	

func save_key_bindings() -> Array:
	var k_b := []  # Local only — never touches the member variable

	for action_category in Constants.DEFAULT_KEY_BINDINGS:
		for c_a in Constants.DEFAULT_KEY_BINDINGS[action_category]:
			if not InputMap.has_action(c_a): continue
			var events := InputMap.action_get_events(c_a)
			if events.size() > 0:
				k_b.append(KeyBinding.new(c_a, events[0]).to_dict())
	return k_b

static func apply_key_bindings(_key_bindings: Array) -> void:
	if _key_bindings.is_empty(): return

	for entry in _key_bindings:
		var action_name: StringName = entry.get("action_name", "")
		if action_name == "": continue

		var event := reconstruct_event(entry.get("event", {}))
		if event == null:
			push_warning("apply_key_bindings: could not reconstruct event for '%s'" % action_name)
			continue

		if not InputMap.has_action(action_name):
			push_warning("apply_key_bindings: action '%s' not in InputMap, skipping" % action_name)
			continue

		# Erase all existing events for this action before re-applying
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, event)

static func reconstruct_event(event_data: Dictionary) -> InputEvent:
	if event_data.is_empty(): return null

	match event_data.get("type", ""):
		"key":
			var ev := InputEventKey.new()
			ev.keycode          = event_data.get("keycode", KEY_NONE)
			ev.physical_keycode = event_data.get("physical", KEY_NONE)
			var mods: Dictionary = event_data.get("modifiers", {})
			ev.shift_pressed = mods.get("shift", false)
			ev.ctrl_pressed  = mods.get("ctrl",  false)
			ev.alt_pressed   = mods.get("alt",   false)
			ev.meta_pressed  = mods.get("meta",  false)
			return ev
		"mouse_button":
			var ev := InputEventMouseButton.new()
			ev.button_index  = event_data.get("button_index", MOUSE_BUTTON_NONE)
			var mods: Dictionary = event_data.get("modifiers", {})
			ev.shift_pressed = mods.get("shift", false)
			ev.ctrl_pressed  = mods.get("ctrl",  false)
			ev.alt_pressed   = mods.get("alt",   false)
			ev.meta_pressed  = mods.get("meta",  false)
			return ev

	push_warning("reconstruct_event: unknown event type '%s'" % event_data.get("type", ""))
	return null
