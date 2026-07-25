extends Control

@export var start_hidden : bool = true
@export var hide_ui : bool = true

@onready var close: Button = %Close

@onready var town_mood_status: RichTextLabel = %TownMoodStatus
@onready var lantern_count: RichTextLabel = %LanternCount
@onready var energy_network_status: RichTextLabel = %EnergyNetworkStatus

var network_status_str: Dictionary = {
	"DARK": 0.0,
	"FAILING": 0.25,
	"FLICKERING": 0.6,
	"STABLE": 0.9,
	"THRIVING": 1.0
}

var network_status_color: Dictionary = {
	"DARK": "#8a2f2f",
	"FAILING": "#c2462b",
	"FLICKERING": "#d99a2b",
	"STABLE": "#5a9b5a",
	"THRIVING": "#4fc76a"
}

var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show()
	pivot_offset = size / 2.0
	_register_events()
	if start_hidden:
		self.modulate.a = 0.0
	else:
		self.modulate.a = 1.0
		
func _register_events() -> void:
	EventBus.game_ready.connect(update_mood_status)
	EventBus.town_mood_updated.connect(update_mood_status)	
	EventBus.player_sat.connect(func():
		_transition_in()
		update_data()
		if hide_ui:
			EventBus.hide_ui.emit()
	)
	close.pressed.connect(func():
		EventBus.player_standing.emit()
		_transition_out()
		if hide_ui:
			EventBus.show_ui.emit()
	)

	EnergyNetwork.network_updated.connect(func(_supply: int, _demand: int, lit_count: int, total_count: int):
		var ratio: float = float(lit_count) / float(total_count) if total_count > 0 else 0.0
		var status_word: String = _get_network_status(ratio)
		var status_color: String = network_status_color[status_word]

		energy_network_status.text = "[font_size=%s][color=%s]%s[/color][/font_size]\n%d / %d lanterns lit" % [
			10, status_color, status_word, lit_count, total_count
		]
	)
func update_data() -> void:
	update_mood_status()
	lantern_count.text = "Lanterns: [b]%s[/b]" % [GameManager.total_lanterns]

func _get_network_status(ratio: float) -> String:
	var names: Array = network_status_str.keys()
	names.sort_custom(func(a, b): return network_status_str[a] < network_status_str[b])

	var result: String = names[0]
	for status_name in names:
		if ratio >= network_status_str[status_name]:
			result = status_name
		else:
			break
	return result
	
func update_mood_status() -> void:
		var mood_str =  GameManager.get_town_mood(true)
		var mood_color = GameManager.mood_color[mood_str]
		town_mood_status.text = "Town mood: [color=%s][b]%s[/b][/color]" % [mood_color, mood_str]	
	

func _transition_in() -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()	
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3).from(Vector2.ZERO)

func _transition_out() -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(_hide)
	
	
func _hide() -> void:
	self.modulate.a = 0.0
