extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dissolve_rect: ColorRect = %DissolveRect

enum type {FADE, WIPE, CURTAIN, DISSOLVE, CIRCULAR, PIXELATED}
enum mode {STANDARD, GAME_STARTUP, GAME_INIT}
enum game_mode {NONE, NEW, CONTINUE}
var is_transitioning : bool = false
var half_done : bool = false
var tween : Tween
var duration : float = 1.0
var count := 0

#var transition_settings = {
	#"target": "",
	#"useLoadingScreen": false,
	#"transitionType": type.FADE,
	#"transitionMode": mode.STANDARD
#}

var transition_settings : TransitionSettings

class TransitionSettings:
	var target: String
	var sourceNode: Node
	var targetNode: Node
	var gameMode: game_mode = game_mode.NONE
	var useLoadingScreen: bool = false
	var transitionType: type = type.FADE
	var transitionMode: mode = mode.STANDARD
	var duration: float = 1.0
	var sourceTransition : type = type.FADE 
	var targetTransition: type = type.WIPE
	var nodeToNode : bool
	var unhide: bool

func _ready() -> void:
	layer = 200

#target: String, source_node : Node, target_node: Node, source_transition_out : type = type.WIPE, target_transition_in: type = type.WIPE, transition_duration : float = 1.0
func transition_node_to_node(settings: TransitionSettings) -> void:
	if is_transitioning: return
	transition_settings = settings
	duration = transition_settings.duration
	transition_settings.nodeToNode = true
	#transition_settings["target"] = target
	#transition_settings["sourceNode"] = source_node
	#transition_settings["targetNode"] = target_node
	#transition_settings["sourceTransition"] = source_transition_out
	#transition_settings["targetTransition"] = target_transition_in
	#transition_settings["nodeToNode"] = true
	_register_events()			
	
	is_transitioning = true
	transition_both()


# Called using the SceneTransition singleton in place of the 
#target: String, use_loading_screen: bool = false, transition_mode: mode = mode.STANDARD, transition_type: type = type.FADE, transition_duration: float = 1.0
func transition_scene_to_file(settings: TransitionSettings) -> void:
	if is_transitioning: return
	transition_settings = settings
	duration = transition_settings.duration
	#duration = transition_duration
	#
	#transition_settings["target"] = target
	#transition_settings["useLoadingScreen"] = use_loading_screen
	#transition_settings["transitionType"] = transition_type
	#transition_settings["transitionMode"] = transition_mode

	
	_register_events()			
	
	is_transitioning = true
	transition_in(dissolve_rect,  transition_settings["transitionType"])

func _register_events() -> void:
	EventBus.transition_half_completed.connect(func():
		if half_done: return
		change_scene()
		half_done = true
	)
	
	EventBus.transition_completed.connect(func():
		is_transitioning = false
		half_done = false
		count = 0
	)
	

func change_scene() -> void:
	count += 1
	if transition_settings["useLoadingScreen"]:
		var loading_scene = load(Constants.SCENE_PATHS["LoadingScreen"])
		if not loading_scene:
			push_error("SceneTransition: failed to load loading screen from %s" % Constants.SCENE_PATHS["LoadingScreen"])
			return		
		var loading_screen = loading_scene.instantiate()
		if not loading_screen:
			push_error("SceneTransition: failed to instantiate loading screen")
			return
		loading_screen.next_scene = transition_settings["target"]
		loading_screen.game_mode = transition_settings["gameMode"]
		if transition_settings["transitionMode"] == mode.GAME_STARTUP:
			loading_screen._is_game_startup = true
		elif transition_settings["transitionMode"] == mode.GAME_INIT:
			loading_screen._is_game_startup = false
			
		get_tree().root.add_child(loading_screen)
		var old_scene = get_tree().current_scene
		get_tree().current_scene = loading_screen
		old_scene.queue_free()
	else:
		if transition_settings["nodeToNode"]:
			if not transition_settings["unhide"]:
				var loaded_scene = load(transition_settings["target"]).instantiate()
				#var target_node = get_tree().root.get_node(transition_settings["targetNode"])
				transition_settings["targetNode"].add_child(loaded_scene)
				print("trans in %s with %s" % [transition_settings["target"], type.keys()[transition_settings["targetTransition"]]])
				transition_in(loaded_scene, transition_settings["targetTransition"])		
			else:
				transition_settings.targetNode.show()
				transition_in(transition_settings.targetNode, transition_settings["targetTransition"])
		else:
			# Let's change the scene to the target file
			get_tree().change_scene_to_file(transition_settings["target"])
			await get_tree().scene_changed

		
	# Now we play the dissolve backwards to make the new scene appears
	if not transition_settings["nodeToNode"]:
		transition_out(dissolve_rect, transition_settings["transitionType"])
			
func change_scene_to_packed(target: PackedScene) -> void:
	animation_player.play("dissolve")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(target)
	animation_player.play_backwards("dissolve")
	
# SceneTransition.gd
#region transitions
func transition_in(object : Node = dissolve_rect, transition_type : type = type.FADE) -> void:
	match transition_type:
		type.FADE: fade_in(object)
		type.WIPE: wipe_in(object)
		type.CURTAIN: curtain_in(object)
		type.DISSOLVE: dissolve_in(object)
		type.CIRCULAR: circular_in(object)
		type.PIXELATED: pixelated_in(object)
		_: fade_in(object)
	if transition_settings["nodeToNode"]:
		tween.tween_callback(func(): EventBus.transition_completed.emit())
	else:
		tween.tween_callback(func(): EventBus.transition_half_completed.emit())
		
func transition_out(object : Node = dissolve_rect, transition_type : type = type.FADE) -> void:
	match transition_type:
		type.FADE: fade_out(object)
		type.WIPE: wipe_out(object)
		type.CURTAIN: curtain_out(object)
		type.DISSOLVE: dissolve_out(object)
		type.CIRCULAR: circular_out(object)
		type.PIXELATED: pixelated_out(object)
		_: fade_out(object)
	if transition_settings["nodeToNode"]:
		tween.tween_callback(func(): EventBus.transition_half_completed.emit())
	else:
		tween.tween_callback(func(): EventBus.transition_completed.emit())

func transition_both() -> void:
	# Source Scene should transition out
	# while Target Scene transition in
	if transition_settings["nodeToNode"]:
		if transition_settings["sourceNode"]:
			print("trans out %s with %s" % [transition_settings["sourceNode"], type.keys()[transition_settings["sourceTransition"]]])

			transition_out(transition_settings["sourceNode"], transition_settings["sourceTransition"])


func fade_in(object : Node = dissolve_rect) -> void:
	if "color" in object:
		object.color = Color(0,0,0,1)
	object.modulate.a = 1.0		
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(object, "modulate:a", 1.0, duration / 2)
	
	
func fade_out(object : Node = dissolve_rect) -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(object, "modulate:a", 0.0, duration / 2)
	


func wipe_in(object : Node = dissolve_rect) -> void:
	if tween and tween.is_running():
		tween.kill()
		
	object.position.x = -get_viewport().size.x
	if "color" in object:
		object.color = Color(0,0,0,1)
	object.modulate.a = 1.0
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(object, "position:x", 0, duration / 2)
	#tween.tween_callback(func(): EventBus.transition_half_completed.emit())
	
func wipe_out(object : Node = dissolve_rect) -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(object, "position:x", get_viewport().size.x, duration / 2)
	#tween.tween_callback(func(): EventBus.transition_completed.emit())
	
func curtain_in(object : Node = dissolve_rect) -> void:
	if "color" in object:
		object.color = Color(0,0,0,1)
	object.modulate.a = 1.0
	object.material = ShaderMaterial.new()
	object.material.shader = load(Constants.TRANSITIONS_SHADERS["Curtain"])
	object.material.set_shader_parameter("progress", 0.0)
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_method(set_param.bind("progress", object), 0.0, 1.0, duration / 2)
	#tween.tween_callback(func(): EventBus.transition_half_completed.emit())
	
func set_param(value: float, param_name: String, object : Node = dissolve_rect) -> void:
	object.material.set_shader_parameter(param_name, value)
	
func curtain_out(object : Node = dissolve_rect) -> void:
	if tween and tween.is_running():
		tween.kill()
	if object.material == null:
		object.material = ShaderMaterial.new()
		object.material.shader = load(Constants.TRANSITIONS_SHADERS["Curtain"])
		object.material.set_shader_parameter("progress", 1.0)		
	
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_method(set_param.bind("progress", object), 1.0, 2.0, duration / 2)
	#tween.tween_callback(func(): EventBus.transition_completed.emit())

func dissolve_in(object : Node = dissolve_rect) -> void:
	var noise_texture = NoiseTexture2D.new()
	noise_texture.noise = FastNoiseLite.new()
	noise_texture.noise.seed = randi()
	noise_texture.noise.frequency = 0.05
	
	
	if "color" in object:
		object.color = Color(0,0,0,1)
	object.modulate.a = 1.0	
	object.material = ShaderMaterial.new()
	object.material.shader = load(Constants.TRANSITIONS_SHADERS["Dissolve"])
	object.material.set_shader_parameter("noise_texture", noise_texture)
	object.material.set_shader_parameter("threshold", 0.0)
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_method(set_param.bind("threshold", object), 0.0, 1.0, duration / 2)
	#tween.tween_callback(func(): EventBus.transition_half_completed.emit())	

func dissolve_out(object : Node = dissolve_rect) -> void:
	if tween and tween.is_running():
		tween.kill()
		
	if object.material == null:
		var noise_texture = NoiseTexture2D.new()
		noise_texture.noise = FastNoiseLite.new()
		noise_texture.noise.seed = randi()
		noise_texture.noise.frequency = 0.05
		
		
		if "color" in object:
			object.color = Color(0,0,0,1)
		object.modulate.a = 1.0	
		object.material = ShaderMaterial.new()
		object.material.shader = load(Constants.TRANSITIONS_SHADERS["Dissolve"])
		object.material.set_shader_parameter("noise_texture", noise_texture)
		object.material.set_shader_parameter("threshold", 1.0)
		
		
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_method(set_param.bind("threshold", object), 1.0, 0.0, duration / 2)
	#tween.tween_callback(func(): EventBus.transition_completed.emit())

func circular_in(object : Node = dissolve_rect) -> void:
	if "color" in object:
		object.color = Color(0,0,0,1)
	object.modulate.a = 1.0
	object.material = ShaderMaterial.new()
	object.material.shader = load(Constants.TRANSITIONS_SHADERS["Circular"])
	object.material.set_shader_parameter("center", Vector2(0.5, 0.5))
	object.material.set_shader_parameter("radius", 0.0)
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_method(set_param.bind("radius", object), 0.0, 1.5, duration / 2)
	#tween.tween_callback(func(): EventBus.transition_half_completed.emit())	
	
func circular_out(object : Node = dissolve_rect) -> void:
	if tween and tween.is_running():
		tween.kill()
		
	if object.material == null:
		object.material = ShaderMaterial.new()
		object.material.shader = load(Constants.TRANSITIONS_SHADERS["Circular"])
		object.material.set_shader_parameter("center", Vector2(0.5, 0.5))
		object.material.set_shader_parameter("radius", 1.5)				
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_method(set_param.bind("radius", object), 1.5, 0.0, duration / 2)
	#tween.tween_callback(func(): EventBus.transition_completed.emit())

func pixelated_in(object : Node = dissolve_rect) -> void:
	if "color" in object:
		object.color = Color(0,0,0,1)
	object.modulate.a = 1.0
	object.material = ShaderMaterial.new()
	object.material.shader = load(Constants.TRANSITIONS_SHADERS["Pixelated"])
	object.material.set_shader_parameter("pixel_size", 1.0)
	object.material.set_shader_parameter("darkness", 0.0)
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_method(set_param.bind("pixel_size", object), 1.0, 20.0, duration / 4)
	tween.tween_method(set_param.bind("darkness", object), 0.0, 1.0, duration / 4)
	#tween.tween_callback(func(): EventBus.transition_half_completed.emit())	
	
func pixelated_out(object : Node = dissolve_rect) -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_method(set_param.bind("darkness", object), 1.0, 0.0, duration / 4)
	tween.tween_method(set_param.bind("pixel_size", object), 20.0, 1.0, duration / 4)
	tween.tween_property(object, "modulate:a", 0.0, duration / 4)
	#tween.tween_callback(func(): EventBus.transition_completed.emit())
	
#endregion
