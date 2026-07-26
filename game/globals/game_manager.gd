extends Node

var mood_str : Dictionary = {
	"FURIOUS" : 0,
	"BLEAK" : 10, 
	"SAD" : 20, 
	"MEH" : 50, 
	"HAPPY" : 70, 
	"MERRY" : 90
}
var mood_color : Dictionary = {
	"FURIOUS": Color.DARK_RED.to_html(),
	"BLEAK": Color.BLACK.to_html(),
	"SAD": Color.DIM_GRAY.to_html(),
	"MEH": Color.SALMON.to_html(),
	"HAPPY": Color.GREEN_YELLOW.to_html(),
	"MERRY": Color.GREEN.to_html()
}
var game_in_progress : bool = false
var game_loaded : bool = false
var game_over : bool = false
var game_win : bool = false

var show_tutorial : bool = false

var current_furnace : Furnace

var player_prefs: Preferences

# Game Stats
var reported_incidents : int = 0
var total_lanterns : int = 0
var town_mood : int = 100:
	set(value):
		town_mood = clamp(value, 0, 100)

var fuel_quantity : int = 0

func _game_bootstrap() -> void:
	_register_events()
	
func _register_events() -> void:
	EventBus.game_ready.connect(func():
		game_in_progress = true
	)
	EventBus.main_volume.connect(func(level: float):
		player_prefs.main_volume = level
	)
	EventBus.sound_volume.connect(func(level: float):
		player_prefs.sfx_volume = level
	)
	EventBus.music_volume.connect(func(level: float):
		player_prefs.music_volume = level
	)
	EventBus.music_toggle.connect(func(status: bool):
		player_prefs.music_toggle = status
	)
	EventBus.sound_toggle.connect(func(status: bool):
		player_prefs.sfx_toggle_toggle = status
	)	
	EventBus.game_ended.connect(func(_w: bool, _r: String):
		game_in_progress = false
	)
	EventBus.order_fuel.connect(func(quantity: int):
		await get_tree().create_timer(Constants.FUEL_ORDER_TIMEOUT).timeout
		fuel_quantity += quantity
		EventBus.fuel_restocked.emit()
	)

func _refresh_lanterns_count() -> void:
	total_lanterns = get_tree().get_node_count_in_group(Constants.LANTERNS_GROUP)
		

func _init_town_lantern(folder_node: Node) -> void:
	var lantern_ = preload(Constants.SCENE_PATHS["Lantern"])
	if Constants.STARTING_TOWN_LANTERNS > 0:
		var town_lantern = load("uid://cwnfoj65xk8d1")
		for i in range(Constants.STARTING_TOWN_LANTERNS):
			var l = lantern_.instantiate()
			folder_node.add_child(l)
			l.profile = town_lantern
			l.hide()
			l.add_to_group(Constants.LANTERNS_GROUP)
			l.add_to_group(Constants.CITY_LANTERNS_GROUP)
			total_lanterns += 1
	if Constants.STARTING_WOODS_LANTERNS > 0:
		var wood_lantern = load("uid://bvimwp5f46eal")
		for i in range(Constants.STARTING_WOODS_LANTERNS):
			var l = lantern_.instantiate()
			folder_node.add_child(l)
			l.profile = wood_lantern
			l.hide()
			l.add_to_group(Constants.LANTERNS_GROUP)
			l.add_to_group(Constants.WOODS_LANTERNS_GROUP)
			total_lanterns += 1
			

func get_town_mood(to_str: bool = true) -> String:
	if not to_str:
		return "%s" % town_mood

	# Sort explicitly by threshold rather than trusting dictionary order —
	# makes this safe even if entries get added out of order later.
	var mood_names: Array = mood_str.keys()
	mood_names.sort_custom(func(a, b): return mood_str[a] < mood_str[b])

	var result: String = mood_names[0]  # fallback for anything below the lowest threshold

	for mood_name in mood_names:
		if town_mood >= mood_str[mood_name]:
			result = mood_name
		else:
			break

	return result
	
