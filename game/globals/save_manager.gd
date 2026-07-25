@tool
class_name SaveManager extends Node

static var load_save_methods : Dictionary = {"save":"_save_state", "load":"_load_state"}

static func _save_path(slot_name: String, filename: String) -> String:
	return "%s/%s" % [_save_slot_dir(slot_name), filename]
	
static func _save_slot_dir(slot_name: String) -> String:
	return "%s/%s" % [Constants.SAVE_BASE_DIR, slot_name]
	

static func save_preferences(user_prefs: Preferences) -> Error:
	var saved_at := str(Time.get_datetime_string_from_system())
	var previous_saved_at = user_prefs.last_game_saved_at
	user_prefs.last_game_saved_at = saved_at
	var prefs: Dictionary = {
		"created_at": "",
		"updated_at": "",
		"preferences": user_prefs.to_dict()
	}
	var _save_file :=  _save_path("", Constants.SAVE_PREFERENCES_FILE)
	if not FileAccess.file_exists(_save_file):
		prefs["created_at"] = saved_at
	
	prefs["updated_at"] = saved_at
	
	var err : Error = FileHandler.store_file(prefs, _save_file, true, FileHandler.STORE_TYPE.JSON, FileHandler.STORE_MODE.PLAIN)	
	if err != OK:
		user_prefs.last_game_saved_at = previous_saved_at
		print_debug("Error while saving preferences: %s" % err)
		return err
		
	Utility.logger(Constants.DEBUG_LAYERS.GAME,	"SaveManager: User game preferences saved in %s at %s" % [_save_file, Time.get_time_string_from_system()])
	EventBus.call_deferred("emit_signal", "game_options_saved")
	
	return err
	
static func load_preferences() -> Array:
	var _save_file :=  _save_path("", Constants.SAVE_PREFERENCES_FILE)
	if not FileAccess.file_exists(_save_file):
		return [ERR_FILE_NOT_FOUND, null]
		
	var u_prefs : Preferences
	var data : Dictionary
	var err: Error = FileHandler.load_file(_save_file, data, FileHandler.STORE_TYPE.JSON, FileHandler.STORE_MODE.PLAIN)
	
	if err != OK:
		return [err, null]

	if data.has("preferences"):
		u_prefs = Preferences.from_dict(data.get("preferences"))

	Utility.logger(Constants.DEBUG_LAYERS.GAME,	"SaveManager: User game preferences loaded from %s at %s" % [_save_file, Time.get_time_string_from_system()])
	
	return [err, u_prefs]
	

static func _get_nodes_in_group(group_name: String) -> Array:
	var tree := Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_nodes_in_group(group_name)
	return []
