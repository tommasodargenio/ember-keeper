extends Control

@export var start_hidden : bool = true
@onready var close: Button = %Close

@onready var town_mood_status: RichTextLabel = %TownMoodStatus

var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
		print("dashboard in")
		_transition_in()
	)
	close.pressed.connect(func():
		EventBus.player_standing.emit()
		_transition_out()
	)

func update_mood_status() -> void:
		town_mood_status.text = "%s" % [GameManager.get_town_mood(true)]	
	

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
