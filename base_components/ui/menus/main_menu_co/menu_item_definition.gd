@tool
class_name MenuItem extends Resource

var id : String
@export var name: String:
	set(value):
		name = value
		id = "menu|%s|%s" % [name, randf_range(0,1000)]
@export var transition: bool
@export var game_mode : SceneTransition.game_mode = SceneTransition.game_mode.NONE
@export_category("Same Scene transition")
@export var add_to_scene: bool = false
@export var source_node: StringName
@export var target_node: StringName
@export var source_transition_type : SceneTransition.type = SceneTransition.type.WIPE
@export var target_transition_type : SceneTransition.type = SceneTransition.type.WIPE
@export_category("New Scene transition")
@export var transition_type : SceneTransition.type = SceneTransition.type.CURTAIN 
@export var transition_mode : SceneTransition.mode = SceneTransition.mode.STANDARD
@export var transition_duration : float = 1.0
@export var use_loading_screen : bool = false
@export var unhide_scene: StringName
@export var resume_game_if_paused: bool = false

var destination_scene: String = ""
var action : String = "None"
var source_scene: String = ""
var menu_item_parent: Control
func _get_property_list() -> Array[Dictionary]:
# Scene dropdown
	var scene_keys: Array = Constants.SCENE_PATHS.keys()
	var scene_hints := ["None"]
	for i in scene_keys.size():
		if scene_keys[i] != "":
			scene_hints.append("%s" % [scene_keys[i]])

# Action dropdown
	var action_keys: Array = Constants.MENU_ACTIONS.keys()
	var action_hints: PackedStringArray = []
	for i in action_keys.size():
		action_hints.append("%s" % [action_keys[i]])

	return [
		{
			"name":        "destination_scene",
			"type":        TYPE_STRING,
			"usage":       PROPERTY_USAGE_DEFAULT,
			"hint":        PROPERTY_HINT_ENUM_SUGGESTION,
			"hint_string": ",".join(scene_hints),
		},
		{
			"name":        "action",
			"type":        TYPE_STRING,
			"usage":       PROPERTY_USAGE_DEFAULT,
			"hint":        PROPERTY_HINT_ENUM_SUGGESTION,
			"hint_string": ",".join(action_hints),
		},
	]

func _execute_action(action_key: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if not tree:
		var msg : String = "Error executing menu action %s [%s]!" % [action_key, "Can't acquire tree from Engine main loop"]
		EventBus.show_message.emit(Constants.MESSAGE_WINDOW_FLAG.ERROR, "Error", msg, "QUIT", true)		
		return
	match action_key:
		"Quit":			_handle_save_on_quit(tree)
		"Pause":		EventBus.game_paused.emit()
		"Resume":		EventBus.game_resumed.emit()
		"SavePrefs":	print("save options")
		"SaveAndQuit":  _handle_save_and_quit(tree)
		"Back":			_go_back(tree)
		"Close":		_close(tree)


func _quit_if_not_in_game(tree: SceneTree) -> void:
	if not GameManager or not GameManager.game_in_progress or not GameManager.player_prefs:
		tree.quit()
	


func _handle_save_and_quit(tree: SceneTree) -> void:
	# If game is not in progress we quit directly
	_quit_if_not_in_game(tree)
	
	# If current game is loaded from an existing save, we save on it
	
	#SaveManager.save_game("", true)

func _handle_save_on_quit(tree: SceneTree) -> void:
	# Not in game yet still in menus, we ca quit directly
	_quit_if_not_in_game(tree)

	# A game is in progress
		# if save before exit is on we save, and then quit
		# we quit otherwise
	if GameManager.game_in_progress:
		if GameManager.player_prefs and GameManager.player_prefs.save_before_exiting:
			print("save")
			#SaveManager.save_game(Constants.SESSION_SAVE_DIRECTORY_NAME, true)
		else:
			tree.quit()

func _close(tree: SceneTree) -> void:
	if self.menu_item_parent and  self.menu_item_parent.has_method("_pop_out_menu"):
		if unhide_scene:
			var settings : SceneTransition.TransitionSettings = SceneTransition.TransitionSettings.new()
			settings.unhide = true
			settings.targetNode = tree.root.find_child(unhide_scene, true, false)
			settings.sourceNode = tree.root.find_child(source_node, true, false)			
			settings.sourceTransition = source_transition_type
			settings.targetTransition = target_transition_type			
			SceneTransition.transition_node_to_node(settings)						
		else:
			self.menu_item_parent._pop_out_menu()
	else:
		print_debug("Something went wrong while trying to close the menu %s" % self.menu_item_parent.name)
		return

func _go_back(tree: SceneTree) -> void:
	if destination_scene != "": 
		if resume_game_if_paused:
			EventBus.game_resumed.emit()
		if transition and SceneTransition:
			var uid: String = Constants.SCENE_PATHS.get(destination_scene, "")
			var settings : SceneTransition.TransitionSettings = SceneTransition.TransitionSettings.new()
			settings.target = uid
			settings.transitionMode = transition_mode
			settings.transitionType = transition_type
			settings.duration = transition_duration
			settings.useLoadingScreen = false
			if uid != "" and not add_to_scene:
				SceneTransition.transition_scene_to_file(settings)
			elif uid != "" and add_to_scene:
				settings.sourceNode = tree.root.find_child(source_node, true, false)
				settings.targetNode = tree.root.find_child(target_node, true, false)
				settings.sourceTransition = source_transition_type
				settings.targetTransition = target_transition_type
				#uid, tree.root.find_child(source_node, true, false), tree.root.get_node(target_node), source_transition_type, target_transition_type, transition_duration
				SceneTransition.transition_node_to_node(settings)
		else:
			tree.change_scene_to_file(Constants.SCENE_PATHS[destination_scene])

func _run() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	# Run action if one is set
	if resume_game_if_paused:
		EventBus.game_resumed.emit()
	if action != "" and action != "None":
		_execute_action(action)
		return
	if transition and SceneTransition:
		var uid: String = ""
		if destination_scene != "":
			uid = Constants.SCENE_PATHS.get(destination_scene, "")
		var settings : SceneTransition.TransitionSettings = SceneTransition.TransitionSettings.new()
		settings.unhide = false
		if uid != "":
			settings.target = uid
			settings.transitionMode = transition_mode
			settings.transitionType = transition_type
			settings.duration = transition_duration
			settings.useLoadingScreen = use_loading_screen		
			settings.gameMode = game_mode
		if uid != "" and not add_to_scene:
			#uid, use_loading_screen, transition_mode, transition_type, transition_duration
			SceneTransition.transition_scene_to_file(settings)
		elif add_to_scene or unhide_scene != null:
			settings.sourceNode = tree.root.find_child(source_node, true, false)
			if target_node:
				settings.targetNode = tree.root.find_child(target_node, true, false)
			elif unhide_scene:
				settings.unhide = true
				settings.targetNode = tree.root.find_child(unhide_scene, true, false)
			settings.sourceTransition = source_transition_type
			settings.targetTransition = target_transition_type			
			#uid,  tree.root.find_child(source_node, true, false), tree.root.get_node(target_node), source_transition_type, target_transition_type, transition_duration
			SceneTransition.transition_node_to_node(settings)			
		return
	elif destination_scene != "":
		tree.change_scene_to_file(Constants.SCENE_PATHS[destination_scene])
	elif unhide_scene:
		var target = tree.root.find_child(unhide_scene, true, false)
		if not target: return
		target.show()
		var source = tree.root.find_child(source_node, true, false)
		if not source: return
		source.hide()
	
		
