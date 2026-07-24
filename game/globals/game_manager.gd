extends Node

var mood_str : Dictionary = {
	"FURIOUS" : 0,
	"BLEAK" : 10, 
	"SAD" : 20, 
	"MEH" : 50, 
	"HAPPY" : 70, 
	"MERRY" : 90
}

var game_in_progress : bool = false
var game_loaded : bool = false
var game_over : bool = false
var game_win : bool = false


var current_furnace : Furnace



# Game Stats
var reported_incidents : int = 0
var total_lanterns : int = 0
var town_mood : int = 100:
	set(value):
		town_mood = clamp(value, 0, 100)


func _init_town_lantern(folder_node: Node) -> void:
	var lantern_ = preload(Constants.SCENE_PATHS["Lantern"])
	if Constants.STARTING_TOWN_LANTERNS > 0:
		var town_lantern = load("uid://cwnfoj65xk8d1")
		for i in range(Constants.STARTING_TOWN_LANTERNS):
			var l = lantern_.instantiate()
			folder_node.add_child(l)
			l.profile = town_lantern
			l.hide()
	if Constants.STARTING_WOODS_LANTERNS > 0:
		var wood_lantern = load("uid://bvimwp5f46eal")
		for i in range(Constants.STARTING_WOODS_LANTERNS):
			var l = lantern_.instantiate()
			folder_node.add_child(l)
			l.profile = wood_lantern
			l.hide()
			

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
